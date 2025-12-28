<?php
declare(strict_types=1);

namespace NukeCE\Security;

use PDO;

/**
 * TorExit
 *
 * Stores a normalized list of Tor exit node IPs and provides fast membership checks.
 *
 * Source formats supported:
 * - Tor bulk exit list (one IP per line)
 * - Onionoo-style "ExitAddress <ip> <timestamp>" lines
 */
final class TorExit
{
    private function __construct() {}

    public static function ensureSchema(PDO $pdo): void
    {
        $pdo->exec("CREATE TABLE IF NOT EXISTS nsec_tor_exit_nodes (
            ip VARBINARY(16) NOT NULL PRIMARY KEY,
            ip_text VARCHAR(45) NOT NULL,
            source VARCHAR(255) NULL,
            fetched_at DATETIME NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        $pdo->exec("CREATE INDEX IF NOT EXISTS idx_nsec_tor_fetched_at ON nsec_tor_exit_nodes (fetched_at)");
    }

    public static function refreshFromUrl(PDO $pdo, string $url, int $timeoutSeconds = 8): array
    {
        self::ensureSchema($pdo);

        $ctx = stream_context_create([
            'http' => [
                'timeout' => $timeoutSeconds,
                'user_agent' => 'nukeCE NukeSecurity/1.0 (Tor feed fetcher)',
            ],
            'https' => [
                'timeout' => $timeoutSeconds,
                'user_agent' => 'nukeCE NukeSecurity/1.0 (Tor feed fetcher)',
            ],
        ]);

        $raw = @file_get_contents($url, false, $ctx);
        if ($raw === false || $raw === '') {
            return ['ok'=>false, 'error'=>'Unable to fetch feed', 'count'=>0];
        }

        $ips = self::parseIps($raw);
        $count = count($ips);

        $pdo->beginTransaction();
        try {
            $pdo->exec("DELETE FROM nsec_tor_exit_nodes");
            $st = $pdo->prepare("INSERT INTO nsec_tor_exit_nodes (ip, ip_text, source, fetched_at)
                VALUES (INET6_ATON(?), ?, ?, NOW())
                ON DUPLICATE KEY UPDATE ip_text=VALUES(ip_text), source=VALUES(source), fetched_at=VALUES(fetched_at)");
            foreach ($ips as $ip) {
                $st->execute([$ip, $ip, $url]);
            }
            $pdo->commit();
        } catch (\Throwable $e) {
            $pdo->rollBack();
            return ['ok'=>false, 'error'=>$e->getMessage(), 'count'=>0];
        }

        return ['ok'=>true, 'error'=>null, 'count'=>$count];
    }


    public static function getStats(PDO $pdo): array
    {
        self::ensureSchema($pdo);
        $row = $pdo->query("SELECT COUNT(*) AS c, MAX(fetched_at) AS last_ts FROM nsec_tor_exit_nodes")->fetch(PDO::FETCH_ASSOC) ?: [];
        return [
            'count' => (int)($row['c'] ?? 0),
            'last_ts' => (string)($row['last_ts'] ?? ''),
        ];
    }

    public static function isExitNode(PDO $pdo, string $ip): bool
    {
        self::ensureSchema($pdo);
        $st = $pdo->prepare("SELECT 1 FROM nsec_tor_exit_nodes WHERE ip = INET6_ATON(?) LIMIT 1");
        $st->execute([$ip]);
        return (bool)$st->fetchColumn();
    }

    /** @return string[] */
    public static function parseIps(string $raw): array
    {
        $ips = [];
        foreach (preg_split('/\r?\n/', $raw) as $line) {
            $line = trim($line);
            if ($line === '' || $line[0] === '#') continue;

            // ExitAddress <ip> <timestamp>
            if (stripos($line, 'ExitAddress ') === 0) {
                $parts = preg_split('/\s+/', $line);
                if (isset($parts[1]) && filter_var($parts[1], FILTER_VALIDATE_IP)) {
                    $ips[] = $parts[1];
                }
                continue;
            }

            // plain IP
            if (filter_var($line, FILTER_VALIDATE_IP)) {
                $ips[] = $line;
                continue;
            }
        }
        $ips = array_values(array_unique($ips));
        return $ips;
    }
}
