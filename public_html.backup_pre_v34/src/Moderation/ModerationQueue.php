<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Moderation;

use NukeCE\Core\Model;
use PDO;

final class ModerationQueue extends Model
{
    public static function ensureTable(): void
    {
        $pdo = parent::pdo();
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS moderation_queue (
              id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
              queue_type VARCHAR(32) NOT NULL,
              source_module VARCHAR(64) NOT NULL,
              source_id VARCHAR(64) NOT NULL,
              reason VARCHAR(255) NULL,
              status VARCHAR(16) NOT NULL DEFAULT 'open',
              severity VARCHAR(16) NOT NULL DEFAULT 'low',
              created_at DATETIME NOT NULL,
              created_by VARCHAR(64) NOT NULL DEFAULT 'system',
              reviewed_at DATETIME NULL,
              reviewed_by VARCHAR(64) NULL,
              resolution_note VARCHAR(255) NULL,
              KEY idx_status (status),
              KEY idx_type (queue_type),
              KEY idx_created_at (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        ");
    }

    public static function list(array $filters, int $limit = 100): array
    {
        self::ensureTable();
        $pdo = parent::pdo();

        $where = [];
        $args = [];
        if (!empty($filters['status'])) { $where[] = "status = :st"; $args[':st'] = $filters['status']; }
        if (!empty($filters['type'])) { $where[] = "queue_type = :qt"; $args[':qt'] = $filters['type']; }
        if (!empty($filters['severity'])) { $where[] = "severity = :sev"; $args[':sev'] = $filters['severity']; }

        $sql = "SELECT * FROM moderation_queue";
        if ($where) $sql .= " WHERE " . implode(" AND ", $where);
        $sql .= " ORDER BY id DESC LIMIT :lim";

        $st = $pdo->prepare($sql);
        foreach ($args as $k => $v) $st->bindValue($k, $v);
        $st->bindValue(':lim', $limit, PDO::PARAM_INT);
        $st->execute();
        return $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
    }

    public static function setStatus(int $id, string $status, string $reviewer, string $note = ''): bool
    {
        self::ensureTable();
        $pdo = parent::pdo();
        $now = gmdate('Y-m-d H:i:s');
        $st = $pdo->prepare("UPDATE moderation_queue
            SET status=:st, reviewed_at=:at, reviewed_by=:by, resolution_note=:note
            WHERE id=:id
        ");
        return $st->execute([
            ':st'=>$status, ':at'=>$now, ':by'=>$reviewer, ':note'=>$note, ':id'=>$id
        ]);
    }
}
