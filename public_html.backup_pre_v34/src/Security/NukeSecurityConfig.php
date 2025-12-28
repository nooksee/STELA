<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Security;

use PDO;
use PDOException;

/**
 * NukeSecurityConfig
 *
 * Loads/saves NukeSecurity configuration from data/nukesecurity.json,
 * and provides a compatibility layer for legacy "NukeSentinel" / "nsnst_*"
 * style keys and files.
 *
 * COMPAT SOURCES (read-only):
 * - legacy JSON files (data/nukesentinel.json, data/nsnst.json, etc.)
 * - legacy PHP config arrays (config/*sentinel*.php, includes/*sentinel*.php, etc.) if they return arrays
 * - legacy DB tables (best-effort) for common NukeSentinel-style config tables
 *
 * Goal: preserve user settings from older installs WITHOUT renaming vendor code
 * or breaking existing forums integrations.
 */
final class NukeSecurityConfig
{
    public const FILE = 'data/nukesecurity.json';

    public static function load(string $rootDir): array
    {
        $rootDir = rtrim($rootDir, '/\\');
        $file = $rootDir . '/' . self::FILE;

        $cfg = self::defaults();

        if (is_file($file)) {
            $raw = @file_get_contents($file);
            $j = $raw ? json_decode($raw, true) : null;
            if (is_array($j)) {
                $cfg = self::deepMerge($cfg, $j);
            }
        }

        // One-time migration import from legacy sources (safe, idempotent)
        $cfg = self::migrateLegacy($rootDir, $cfg);

        return $cfg;
    }

    public static function save(string $rootDir, array $cfg): void
    {
        $rootDir = rtrim($rootDir, '/\\');
        $file = $rootDir . '/' . self::FILE;
        @mkdir(dirname($file), 0755, true);
        @file_put_contents($file, json_encode($cfg, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT), LOCK_EX);
    }

    public static function defaults(): array
    {
        return [
            'mode' => 'log_only',
            'alerts' => [
                'enabled' => false,
                'error_threshold' => 10,
                'email_to' => '',
                'webhook_url' => '',
            ],
            'autoban' => [
                'enabled' => false,
                'rate_limit_per_min' => 120,
                'ban_minutes' => 60,
            ],
            // Optional legacy mirror keys (nsec_*)
            'nsec_email' => '',
            'nsec_webhook' => '',
            'nsec_threshold_errors' => null,
            'nsec_alerts' => null,
            'nsec_autoban' => null,

            'compat' => [
                'migrated' => false,
                'migrated_at' => '',
                'migrated_from' => [],
                'legacy_key_map' => [
                    // canonical mappings for common legacy patterns
                    'nsnst_email' => 'alerts.email_to',
                    'nsnst_webhook' => 'alerts.webhook_url',
                    'nsnst_threshold_errors' => 'alerts.error_threshold',
                    'nsnst_alerts' => 'alerts.enabled',
                    'nsnst_autoban' => 'autoban.enabled',
                ],
                'legacy_import' => [],
                'legacy_php_sources' => [],
                'legacy_db_sources' => [],
            ],
        ];
    }

    private static function migrateLegacy(string $rootDir, array $cfg): array
    {
        $sources = [];
        $phpSources = [];
        $dbSources = [];

        // 1) Legacy JSON files (common)
        $legacyFiles = [
            $rootDir . '/data/nukesentinel.json',
            $rootDir . '/data/nukeSentinel.json',
            $rootDir . '/data/nsnst.json',
            $rootDir . '/data/nsnst.cfg.json',
        ];

        foreach ($legacyFiles as $lf) {
            if (!is_file($lf)) continue;
            $raw = @file_get_contents($lf);
            $j = $raw ? json_decode($raw, true) : null;
            if (!is_array($j)) continue;

            $sources[] = basename($lf);
            $cfg = self::applyLegacyKeyMap($cfg, $j);
            $cfg = self::importLegacyPrefixKeys($cfg, $j, 'nsnst_', 'nsec_');
        }

        // 2) Legacy PHP config arrays (best-effort, only if file returns array)
        $phpCandidates = self::findLegacyPhpConfigCandidates($rootDir);
        foreach ($phpCandidates as $path) {
            $arr = self::safeIncludeArray($path);
            if (!is_array($arr)) continue;

            $phpSources[] = basename($path);
            $sources[] = basename($path);

            $cfg = self::applyLegacyKeyMap($cfg, $arr);
            $cfg = self::importLegacyPrefixKeys($cfg, $arr, 'nsnst_', 'nsec_');

            // Some legacy configs store under nested keys like ['nsnst'] or ['sentinel']
            foreach (['nsnst', 'sentinel', 'nukesentinel', 'nuke_sentinel'] as $k) {
                if (isset($arr[$k]) && is_array($arr[$k])) {
                    $cfg = self::applyLegacyKeyMap($cfg, $arr[$k]);
                    $cfg = self::importLegacyPrefixKeys($cfg, $arr[$k], 'nsnst_', 'nsec_');
                }
            }
        }

        // 3) Legacy DB tables (best-effort)
        $db = self::loadLegacyDbConfig($rootDir);
        if ($db) {
            $rows = self::readLegacyDbConfigRows($db);
            if ($rows) {
                $dbSources = array_merge($dbSources, $rows['sources']);
                $sources = array_merge($sources, $rows['sources']);

                $cfg = self::applyLegacyKeyMap($cfg, $rows['kv']);
                $cfg = self::importLegacyPrefixKeys($cfg, $rows['kv'], 'nsnst_', 'nsec_');
            }
        }

        // Also handle legacy keys embedded directly inside nukesecurity.json (if someone copied values forward)
        $cfg = self::applyLegacyKeyMap($cfg, $cfg);
        $cfg = self::importLegacyPrefixKeys($cfg, $cfg, 'nsnst_', 'nsec_');

        if ($phpSources) $cfg['compat']['legacy_php_sources'] = array_values(array_unique($phpSources));
        if ($dbSources) $cfg['compat']['legacy_db_sources'] = array_values(array_unique($dbSources));

        if (!empty($sources) && empty($cfg['compat']['migrated'])) {
            $cfg['compat']['migrated'] = true;
            $cfg['compat']['migrated_at'] = gmdate('c');
            $cfg['compat']['migrated_from'] = array_values(array_unique($sources));
        }

        return $cfg;
    }

    /**
     * Find reasonable legacy PHP config candidates, without being too invasive.
     */
    private static function findLegacyPhpConfigCandidates(string $rootDir): array
    {
        $cands = [];

        $dirs = [
            $rootDir . '/config',
            $rootDir . '/includes',
            $rootDir . '/legacy/includes',
        ];

        $patterns = [
            '*sentinel*.php',
            '*Sentinel*.php',
            '*nsnst*.php',
            '*nukesentinel*.php',
            '*NukeSentinel*.php',
        ];

        foreach ($dirs as $d) {
            if (!is_dir($d)) continue;
            foreach ($patterns as $pat) {
                foreach (glob($d . '/' . $pat) ?: [] as $p) {
                    if (is_file($p)) $cands[] = $p;
                }
            }
        }

        // De-dup and keep deterministic order
        $cands = array_values(array_unique($cands));
        sort($cands, SORT_NATURAL | SORT_FLAG_CASE);
        return $cands;
    }

    /**
     * Safely include a PHP file ONLY if it looks like it returns an array.
     * We avoid including arbitrary legacy files with side effects.
     */
    private static function safeIncludeArray(string $path): ?array
    {
        $raw = @file_get_contents($path);
        if (!is_string($raw) || $raw === '') return null;

        // Heuristic: must contain "return" and "[" to resemble a return array config file
        if (stripos($raw, 'return') === false || strpos($raw, '[') === false) return null;

        // Quiet include
        try {
            $val = (static function ($p) {
                ob_start();
                $r = @include $p;
                ob_end_clean();
                return $r;
            })($path);

            return is_array($val) ? $val : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /**
     * Read DB credentials from config/config.php, return PDO or null.
     */
    private static function loadLegacyDbConfig(string $rootDir): ?PDO
    {
        $cfgFile = $rootDir . '/config/config.php';
        if (!is_file($cfgFile)) return null;

        $cfg = @include $cfgFile;
        if (!is_array($cfg)) return null;

        if (empty($cfg['db_host']) || empty($cfg['db_name']) || !isset($cfg['db_user'])) return null;

        $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', (string)$cfg['db_host'], (string)$cfg['db_name']);
        try {
            $pdo = new PDO($dsn, (string)$cfg['db_user'], (string)($cfg['db_pass'] ?? ''), [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]);
            return $pdo;
        } catch (PDOException $e) {
            return null;
        }
    }

    /**
     * Best-effort read of legacy sentinel config rows from common table patterns.
     *
     * Supports:
     * - tables with (config_name, config_value)
     * - tables with (name, value)
     * - tables with (key, value)
     */
    private static function readLegacyDbConfigRows(PDO $pdo): ?array
    {
        $sources = [];
        $kv = [];

        // Find candidate tables
        $tables = [];
        try {
            $stmt = $pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE()");
            foreach ($stmt->fetchAll() as $row) {
                $t = (string)($row['table_name'] ?? '');
                if ($t === '') continue;
                if (preg_match('/(nsnst|sentinel|nukesentinel)/i', $t)) $tables[] = $t;
            }
        } catch (\Throwable $e) {
            return null;
        }

        if (!$tables) return null;

        // Prefer config-like tables
        usort($tables, function($a, $b){
            $score = function($t){
                $s = 0;
                if (preg_match('/config/i', $t)) $s += 5;
                if (preg_match('/nsnst/i', $t)) $s += 3;
                if (preg_match('/sentinel/i', $t)) $s += 2;
                return -$s;
            };
            return $score($a) <=> $score($b);
        });

        foreach ($tables as $t) {
            // Try to detect columns
            $cols = [];
            try {
                $stmt = $pdo->query("SHOW COLUMNS FROM `$t`");
                foreach ($stmt->fetchAll() as $r) {
                    $cols[] = strtolower((string)$r['Field']);
                }
            } catch (\Throwable $e) {
                continue;
            }

            $nameCol = null;
            $valCol = null;

            $pairs = [
                ['config_name','config_value'],
                ['name','value'],
                ['key','value'],
                ['var','val'],
            ];

            foreach ($pairs as $pair) {
                if (in_array($pair[0], $cols, true) && in_array($pair[1], $cols, true)) {
                    $nameCol = $pair[0];
                    $valCol = $pair[1];
                    break;
                }
            }

            if (!$nameCol || !$valCol) continue;

            try {
                $stmt = $pdo->query("SELECT `$nameCol` AS k, `$valCol` AS v FROM `$t`");
                $rows = $stmt->fetchAll();
                if (!$rows) continue;

                $sources[] = "db:$t";
                foreach ($rows as $r) {
                    $k = (string)($r['k'] ?? '');
                    if ($k === '') continue;
                    $kv[$k] = $r['v'];
                }

                // Stop after first good config table
                break;
            } catch (\Throwable $e) {
                continue;
            }
        }

        if (!$kv) return null;

        return ['sources' => $sources, 'kv' => $kv];
    }

    private static function applyLegacyKeyMap(array $cfg, array $legacy): array
    {
        $map = $cfg['compat']['legacy_key_map'] ?? [];
        if (!is_array($map)) return $cfg;

        foreach ($map as $legacyKey => $path) {
            if (!is_string($legacyKey) || !is_string($path)) continue;
            if (!array_key_exists($legacyKey, $legacy)) continue;

            $legacyVal = $legacy[$legacyKey];
            $existing = self::getPath($cfg, $path);

            // Only set if not already configured
            $isEmpty = $existing === null || $existing === '' || $existing === [];
            if ($isEmpty) {
                $cfg = self::setPath($cfg, $path, $legacyVal);
            }
        }

        return $cfg;
    }

    private static function importLegacyPrefixKeys(array $cfg, array $legacy, string $fromPrefix, string $toPrefix): array
    {
        $import = $cfg['compat']['legacy_import'] ?? [];
        if (!is_array($import)) $import = [];

        foreach ($legacy as $k => $v) {
            if (!is_string($k)) continue;
            if (stripos($k, $fromPrefix) !== 0) continue;

            $import[$k] = $v;

            // If there's a corresponding nsec_* slot in cfg and it's empty, populate it.
            $newKey = $toPrefix . substr($k, strlen($fromPrefix));
            if (!array_key_exists($newKey, $cfg) || $cfg[$newKey] === '' || $cfg[$newKey] === null) {
                $cfg[$newKey] = $v;
            }
        }

        $cfg['compat']['legacy_import'] = $import;
        return $cfg;
    }

    private static function deepMerge(array $a, array $b): array
    {
        foreach ($b as $k => $v) {
            if (is_array($v) && isset($a[$k]) && is_array($a[$k])) {
                $a[$k] = self::deepMerge($a[$k], $v);
            } else {
                $a[$k] = $v;
            }
        }
        return $a;
    }

    private static function getPath(array $arr, string $path)
    {
        $parts = explode('.', $path);
        $cur = $arr;
        foreach ($parts as $p) {
            if (!is_array($cur) || !array_key_exists($p, $cur)) return null;
            $cur = $cur[$p];
        }
        return $cur;
    }

    private static function setPath(array $arr, string $path, $value): array
    {
        $parts = explode('.', $path);
        $cur =& $arr;
        foreach ($parts as $p) {
            if (!isset($cur[$p]) || !is_array($cur[$p])) $cur[$p] = [];
            $cur =& $cur[$p];
        }
        $cur = $value;
        return $arr;
    }
}
