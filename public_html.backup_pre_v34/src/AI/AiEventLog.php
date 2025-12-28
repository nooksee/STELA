<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\AI;

use NukeCE\Core\Model;
use PDO;

final class AiEventLog extends Model
{
    public static function ensureTables(): void
    {
        $pdo = parent::pdo();
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS ai_event_log (
              id INT UNSIGNED NOT NULL AUTO_INCREMENT,
              created_at DATETIME NOT NULL,
              actor VARCHAR(64) NOT NULL DEFAULT 'system',
              source_module VARCHAR(64) NOT NULL DEFAULT '',
              source_id VARCHAR(64) NOT NULL DEFAULT '',
              feature_key VARCHAR(64) NOT NULL DEFAULT '',
              provider VARCHAR(32) NOT NULL DEFAULT '',
              model VARCHAR(64) NOT NULL DEFAULT '',
              prompt MEDIUMTEXT NULL,
              response MEDIUMTEXT NULL,
              meta_json MEDIUMTEXT NULL,
              ok TINYINT(1) NOT NULL DEFAULT 1,
              PRIMARY KEY (id),
              KEY idx_created_at (created_at),
              KEY idx_feature (feature_key),
              KEY idx_source (source_module, source_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        ");
    }

    public static function add(array $row): void
    {
        self::ensureTables();
        $pdo = parent::pdo();
        $st = $pdo->prepare("
            INSERT INTO ai_event_log
            (created_at, actor, source_module, source_id, feature_key, provider, model, prompt, response, meta_json, ok)
            VALUES (:at,:actor,:sm,:sid,:fk,:prov,:model,:prompt,:resp,:meta,:ok)
        ");
        $st->execute([
            ':at' => $row['created_at'] ?? gmdate('Y-m-d H:i:s'),
            ':actor' => $row['actor'] ?? 'system',
            ':sm' => $row['source_module'] ?? '',
            ':sid' => $row['source_id'] ?? '',
            ':fk' => $row['feature_key'] ?? '',
            ':prov' => $row['provider'] ?? '',
            ':model' => $row['model'] ?? '',
            ':prompt' => $row['prompt'] ?? null,
            ':resp' => $row['response'] ?? null,
            ':meta' => $row['meta_json'] ?? null,
            ':ok' => !empty($row['ok']) ? 1 : 0,
        ]);
    }

    /** @return array<int, array<string,mixed>> */
    public static function recent(int $limit = 50): array
    {
        self::ensureTables();
        $pdo = parent::pdo();
        $st = $pdo->prepare("SELECT * FROM ai_event_log ORDER BY id DESC LIMIT :lim");
        $st->bindValue(':lim', $limit, PDO::PARAM_INT);
        $st->execute();
        return $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }
}
