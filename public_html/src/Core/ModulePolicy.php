<?php
declare(strict_types=1);

namespace NukeCE\Core;

final class ModulePolicy
{
    /** @var array<string,mixed>|null */
    private static ?array $cfg = null;

    /** @return array<string,mixed> */
    private static function cfg(): array
    {
        if (self::$cfg !== null) {
            return self::$cfg;
        }

        $file = dirname(__DIR__, 2) . '/config/modules.php';
        $data = [];
        if (is_file($file)) {
            $tmp = include $file;
            if (is_array($tmp)) {
                $data = $tmp;
            }
        }
        self::$cfg = $data;
        return self::$cfg;
    }

    public static function mapLegacy(string $name): string
    {
        $n = strtolower(trim($name));
        $n = str_replace(['-', ' '], '_', $n);

        $aliases = self::cfg()['aliases'] ?? [];
        if (is_array($aliases) && isset($aliases[$n]) && is_string($aliases[$n])) {
            return (string)$aliases[$n];
        }
        return $name;
    }

    public static function isEnabled(string $slug): bool
    {
        $slug = strtolower($slug);
        $enabled = self::cfg()['enabled'] ?? [];
        if (!is_array($enabled)) return true; // fail-open for dev safety
        return in_array($slug, $enabled, true);
    }
}
