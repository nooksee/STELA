<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

use PDO;

/**
 * DB-backed site configuration (hybrid model).
 * - Secrets remain in config/config.php or env.
 * - Admin-editable settings live here (table: site_config).
 * - Changes are mirrored to site_config_history for rollback/audit.
 */
final class SiteConfig extends Model
{
    public static function ensureTables(): void
    {
        $pdo = parent::pdo();
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS site_config (
              config_key VARCHAR(128) NOT NULL PRIMARY KEY,
              config_value TEXT NOT NULL,
              value_type VARCHAR(24) NOT NULL DEFAULT 'string',
              updated_at DATETIME NOT NULL,
              updated_by VARCHAR(64) NOT NULL DEFAULT 'system'
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        ");
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS site_config_history (
              id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
              config_key VARCHAR(128) NOT NULL,
              old_value MEDIUMTEXT NULL,
              new_value MEDIUMTEXT NOT NULL,
              value_type VARCHAR(24) NOT NULL DEFAULT 'string',
              changed_at DATETIME NOT NULL,
              changed_by VARCHAR(64) NOT NULL DEFAULT 'system',
              change_source VARCHAR(32) NOT NULL DEFAULT 'admin_settings',
              change_note VARCHAR(255) NULL,
              KEY idx_key (config_key),
              KEY idx_changed_at (changed_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        ");
    }

    /** @return array<string, array{value:mixed,type:string,updated_at:string,updated_by:string}> */
    public static function all(): array
    {
        self::ensureTables();
        $pdo = parent::pdo();
        $st = $pdo->query("SELECT config_key, config_value, value_type, updated_at, updated_by FROM site_config");
        $out = [];
        if ($st) {
            while ($r = $st->fetch(PDO::FETCH_ASSOC)) {
                $key = (string)$r['config_key'];
                $type = (string)($r['value_type'] ?? 'string');
                $val = self::decode((string)$r['config_value'], $type);
                $out[$key] = [
                    'value' => $val,
                    'type' => $type,
                    'updated_at' => (string)$r['updated_at'],
                    'updated_by' => (string)$r['updated_by'],
                ];
            }
        }
        return $out;
    }

    /** @return mixed */
    public static function get(string $key, $default = null)
    {
        self::ensureTables();
        $pdo = parent::pdo();
        $st = $pdo->prepare("SELECT config_value, value_type FROM site_config WHERE config_key = :k LIMIT 1");
        $st->execute([':k' => $key]);
        $r = $st->fetch(PDO::FETCH_ASSOC);
        if (!$r) return $default;
        return self::decode((string)$r['config_value'], (string)($r['value_type'] ?? 'string'));
    }

    public static function set(string $key, $value, string $type, string $actor, string $note = null): void
    {
        self::ensureTables();
        $pdo = parent::pdo();

        $oldEncoded = null;
        $st = $pdo->prepare("SELECT config_value FROM site_config WHERE config_key = :k LIMIT 1");
        $st->execute([':k' => $key]);
        if ($r = $st->fetch(PDO::FETCH_ASSOC)) {
            $oldEncoded = (string)$r['config_value'];
        }

        $now = gmdate('Y-m-d H:i:s');
        $encoded = self::encode($value, $type);

        $up = $pdo->prepare("
            INSERT INTO site_config (config_key, config_value, value_type, updated_at, updated_by)
            VALUES (:k,:v,:t,:at,:by)
            ON DUPLICATE KEY UPDATE config_value=VALUES(config_value), value_type=VALUES(value_type),
              updated_at=VALUES(updated_at), updated_by=VALUES(updated_by)
        ");
        $up->execute([
            ':k' => $key, ':v' => $encoded, ':t' => $type, ':at' => $now, ':by' => $actor,
        ]);

        $hist = $pdo->prepare("
            INSERT INTO site_config_history (config_key, old_value, new_value, value_type, changed_at, changed_by, change_source, change_note)
            VALUES (:k,:o,:n,:t,:at,:by,'admin_settings',:note)
        ");
        $hist->execute([
            ':k' => $key,
            ':o' => $oldEncoded,
            ':n' => $encoded,
            ':t' => $type,
            ':at' => $now,
            ':by' => $actor,
            ':note' => $note,
        ]);
    }

    /** @return array<int, array<string,mixed>> */
    public static function history(int $limit = 50): array
    {
        self::ensureTables();
        $pdo = parent::pdo();
        $st = $pdo->prepare("SELECT * FROM site_config_history ORDER BY id DESC LIMIT :lim");
        $st->bindValue(':lim', $limit, PDO::PARAM_INT);
        $st->execute();
        return $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    public static function rollback(int $historyId, string $actor): bool
    {
        self::ensureTables();
        $pdo = parent::pdo();
        $st = $pdo->prepare("SELECT * FROM site_config_history WHERE id = :id LIMIT 1");
        $st->execute([':id' => $historyId]);
        $r = $st->fetch(PDO::FETCH_ASSOC);
        if (!$r) return false;

        $key = (string)$r['config_key'];
        $type = (string)($r['value_type'] ?? 'string');
        $oldEncoded = $r['old_value'];
        if ($oldEncoded === null) {
            $del = $pdo->prepare("DELETE FROM site_config WHERE config_key = :k");
            $del->execute([':k' => $key]);
            self::set($key, '', $type, $actor, 'rollback-delete');
            return true;
        }

        $val = self::decode((string)$oldEncoded, $type);
        self::set($key, $val, $type, $actor, 'rollback');
        return true;
    }

    private static function encode($value, string $type): string
    {
        if ($type === 'bool') return $value ? '1' : '0';
        if ($type === 'int') return (string)((int)$value);
        if ($type === 'json') return json_encode($value, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES) ?: '[]';
        return (string)$value;
    }

    private static function decode(string $raw, string $type)
    {
        if ($type === 'bool') return $raw === '1';
        if ($type === 'int') return (int)$raw;
        if ($type === 'json') {
            $v = json_decode($raw, true);
            return $v === null ? [] : $v;
        }
        return $raw;
    }
}
