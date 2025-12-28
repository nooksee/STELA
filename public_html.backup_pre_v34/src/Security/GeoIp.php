<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Security;

use PDO;
use Throwable;

final class GeoIp
{
    private static ?PDO $pdo = null;

    private static function pdo(): ?PDO
    {
        if (self::$pdo instanceof PDO) return self::$pdo;
        try {
            if (!function_exists('nukece_db') && defined('NUKECE_ROOT')) {
                $p = NUKECE_ROOT . '/includes/db.php';
                if (is_file($p)) require_once $p;
            }

            if (function_exists('nukece_db')) {
                /** @var PDO $pdo */
                $pdo = nukece_db();
                self::$pdo = $pdo;
                return $pdo;
            }
        } catch (Throwable $e) {
            return null;
        }
        return null;
    }

    /**
     * Returns ISO2 country code (e.g., "US") or empty string if unknown/unavailable.
     * Fail-open: returns '' on errors.
     */
    public static function countryForIp(string $ip): string
    {
        $pdo = self::pdo();
        if (!$pdo) return '';

        try {
            if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
                $st = $pdo->prepare("SELECT iso2 FROM nsec_geoip_country_v4
                    WHERE start_int <= INET_ATON(?) AND end_int >= INET_ATON(?)
                    ORDER BY start_int DESC LIMIT 1");
                $st->execute([$ip, $ip]);
                $iso2 = $st->fetchColumn();
                return is_string($iso2) ? strtoupper($iso2) : '';
            }

            if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV6)) {
                $st = $pdo->prepare("SELECT iso2 FROM nsec_geoip_country_v6
                    WHERE start_bin <= INET6_ATON(?) AND end_bin >= INET6_ATON(?)
                    ORDER BY start_bin DESC LIMIT 1");
                $st->execute([$ip, $ip]);
                $iso2 = $st->fetchColumn();
                return is_string($iso2) ? strtoupper($iso2) : '';
            }
        } catch (Throwable $e) {
            return '';
        }

        return '';
    }

    /**
     * Returns [asn => int|null, org => string|null] for IP, or null if unknown/unavailable.
     * Fail-open: returns null on errors.
     */
    public static function asnForIp(string $ip): ?array
    {
        $pdo = self::pdo();
        if (!$pdo) return null;

        try {
            if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
                $st = $pdo->prepare("SELECT asn, org FROM nsec_geoip_asn_v4
                    WHERE start_int <= INET_ATON(?) AND end_int >= INET_ATON(?)
                    ORDER BY start_int DESC LIMIT 1");
                $st->execute([$ip, $ip]);
                $row = $st->fetch(PDO::FETCH_ASSOC);
                if (!is_array($row) || ($row['asn'] ?? null) === null) return null;
                return [
                    'asn' => isset($row['asn']) ? (int)$row['asn'] : null,
                    'org' => isset($row['org']) ? (string)$row['org'] : null,
                ];
            }

            if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV6)) {
                $st = $pdo->prepare("SELECT asn, org FROM nsec_geoip_asn_v6
                    WHERE start_bin <= INET6_ATON(?) AND end_bin >= INET6_ATON(?)
                    ORDER BY start_bin DESC LIMIT 1");
                $st->execute([$ip, $ip]);
                $row = $st->fetch(PDO::FETCH_ASSOC);
                if (!is_array($row) || ($row['asn'] ?? null) === null) return null;
                return [
                    'asn' => isset($row['asn']) ? (int)$row['asn'] : null,
                    'org' => isset($row['org']) ? (string)$row['org'] : null,
                ];
            }
        } catch (Throwable $e) {
            return null;
        }

        return null;
    }
}
