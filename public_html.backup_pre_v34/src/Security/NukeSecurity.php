<?php
declare(strict_types=1);

namespace NukeCE\Security;

use NukeCE\Core\StoragePaths;
use NukeCE\Core\SafeFile;
use PDO;

/**
 * NukeSecurity
 *
 * Early-request policy enforcement (fail-open except explicit block actions).
 *
 * Currently supported:
 * - GeoIP (country rules) enforcement
 * - Tor exit-node policy enforcement
 *
 * Configuration is stored via NukeSecurityConfig (JSON under config dir).
 */
final class NukeSecurity
{
    private function __construct() {}

    public static function guardRequest(): void
    {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'cli';
        if ($ip === 'cli') return;

        $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2);
        $cfg  = NukeSecurityConfig::load($root);

        // Allowlist bypass
        $allow = $cfg['allowlist'] ?? [];
        $allowEnabled = (bool)($allow['enabled'] ?? false);
        if ($allowEnabled) {
            $ips = (array)($allow['ips'] ?? []);
            if (in_array($ip, $ips, true)) {
                self::log('gate', 'allowlist_bypass', ['ip'=>$ip]);
                return;
            }
        }

        // GeoIP rules
        self::enforceGeoIp($cfg, $ip);

        // Tor exit nodes
        self::enforceTor($cfg, $ip);

        // (future) ASN rules, rate limits, WAF-like checks...
    }

    private static function enforceGeoIp(array $cfg, string $ip): void
    {
        $geo = $cfg['geoip'] ?? [];
        if (!(bool)($geo['enabled'] ?? false)) return;

        $enforcement = (string)($geo['enforcement'] ?? 'log_only'); // log_only|block
        $defaultAction = (string)($geo['default_action'] ?? 'allow'); // allow|flag|block

        $iso2 = GeoIp::countryForIp($ip);
        if ($iso2 === '' || $iso2 === 'ZZ') return;

        $asn = GeoIp::asnForIp($ip);

        $action = self::countryRuleAction($iso2, $defaultAction);
        if ($action === 'allow') return;

        if ($action === 'flag' || $enforcement === 'log_only') {
            self::log('geoip', 'country_flag', ['ip'=>$ip,'country'=>$iso2,'asn'=>$asn['asn'] ?? null,'org'=>$asn['org'] ?? null,'action'=>$action]);
            return;
        }

        // block
        self::log('geoip', 'country_block', ['ip'=>$ip,'country'=>$iso2,'asn'=>$asn['asn'] ?? null,'org'=>$asn['org'] ?? null,'action'=>$action]);
        http_response_code(403);
        header('Content-Type: text/html; charset=utf-8');
        echo "<html><body style=\"font-family:system-ui\"><h1>403 Forbidden</h1><p>Request blocked.</p><p><small>nukeCE NukeSecurity (Geo/IP)</small></p></body></html>";
        exit;
    }

    private static function enforceTor(array $cfg, string $ip): void
    {
        $tor = $cfg['tor'] ?? [];
        if (!(bool)($tor['enabled'] ?? false)) return;

        $mode = (string)($tor['mode'] ?? 'flag'); // allow|flag|block
        if ($mode === 'allow') return;

        $url = (string)($tor['source_url'] ?? '');
        try {
            $pdo = self::db();
            $isExit = TorExit::isExitNode($pdo, $ip);
        } catch (\Throwable $e) {
            self::log('tor', 'tor_check_error', ['msg'=>$e->getMessage()]);
            return; // fail-open
        }

        if (!$isExit) return;

        if ($mode === 'flag') {
            self::log('tor', 'exit_node_flag', ['ip'=>$ip,'source'=>$url]);
            return;
        }

        // block
        self::log('tor', 'exit_node_block', ['ip'=>$ip,'source'=>$url]);
        http_response_code(403);
        header('Content-Type: text/html; charset=utf-8');
        echo "<html><body style=\"font-family:system-ui\"><h1>403 Forbidden</h1><p>Request blocked.</p><p><small>nukeCE NukeSecurity (Tor)</small></p></body></html>";
        exit;
    }

    private static function countryRuleAction(string $iso2, string $defaultAction): string
    {
        $iso2 = strtoupper($iso2);
        try {
            $pdo = self::db();
            // Ensure table exists (best-effort)
            $pdo->exec("CREATE TABLE IF NOT EXISTS nsec_country_rules (
                iso2 CHAR(2) NOT NULL PRIMARY KEY,
                action ENUM('allow','flag','block') NOT NULL DEFAULT 'allow',
                enabled TINYINT(1) NOT NULL DEFAULT 1,
                note VARCHAR(255) NULL,
                updated_at DATETIME NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            $st = $pdo->prepare("SELECT action, enabled FROM nsec_country_rules WHERE iso2=? LIMIT 1");
            $st->execute([$iso2]);
            $row = $st->fetch(PDO::FETCH_ASSOC);
            if (is_array($row) && (int)($row['enabled'] ?? 0) === 1) {
                $a = (string)($row['action'] ?? '');
                if (in_array($a, ['allow','flag','block'], true)) return $a;
            }
        } catch (\Throwable $e) {
            self::log('geoip', 'country_rule_error', ['msg'=>$e->getMessage()]);
        }
        return in_array($defaultAction, ['allow','flag','block'], true) ? $defaultAction : 'allow';
    }

    private static function db(): PDO
    {
        $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2);
        require_once $root . '/includes/db.php';
        return nukece_db();
    }

    public static function log(string $area, string $event, array $meta = []): void
    {
        $file = StoragePaths::join(StoragePaths::logsDir(), 'nukesecurity.log');

        $ip = $_SERVER['REMOTE_ADDR'] ?? 'cli';
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $line = sprintf(
            "[%s] area=%s event=%s ip=%s ua=%s meta=%s",
            gmdate('c'),
            self::clean($area),
            self::clean($event),
            self::clean($ip),
            self::clean(substr($ua, 0, 80)),
            $meta ? json_encode($meta, JSON_UNESCAPED_SLASHES) : "{}"
        );

        SafeFile::appendLocked($file, $line . PHP_EOL);
    }

    private static function clean(string $s): string
    {
        return preg_replace('/[^a-z0-9_\-\.]/i', '_', $s) ?? $s;
    }
}
