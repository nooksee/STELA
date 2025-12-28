<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

final class AppConfig
{
    /** @var array<string,mixed>|null */
    private static ?array $cfg = null;

    /** @return array<string,mixed> */
    public static function all(): array
    {
        if (self::$cfg !== null) return self::$cfg;

        $file = dirname(__DIR__, 2) . '/config/config.php';
        $data = [];
        if (is_file($file)) {
            $tmp = include $file;
            if (is_array($tmp)) $data = $tmp;
        }
        self::$cfg = $data;
        return self::$cfg;
    }

    public static function getBool(string $key, bool $default = false): bool
    {
        $cfg = self::all();
        if (!array_key_exists($key, $cfg)) return $default;
        return (bool)$cfg[$key];
    }

    public static function getString(string $key, string $default = ''): string
    {
        $cfg = self::all();
        if (!array_key_exists($key, $cfg)) return $default;
        return is_string($cfg[$key]) ? $cfg[$key] : $default;
    }
}
