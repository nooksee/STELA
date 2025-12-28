<?php
declare(strict_types=1);

namespace NukeCE\Core;

/**
 * SafeFile
 *
 * Safer file writes:
 * - appendLocked(): append with LOCK_EX (creates dir if needed)
 * - writeAtomic(): write temp then rename (creates dir if needed)
 */
final class SafeFile
{
    private function __construct() {}

    public static function appendLocked(string $file, string $data): bool
    {
        $dir = dirname($file);
        if (!is_dir($dir)) {
            @mkdir($dir, 0755, true);
        }
        $bytes = @file_put_contents($file, $data, FILE_APPEND | LOCK_EX);
        return $bytes !== false;
    }

    public static function writeAtomic(string $file, string $data): bool
    {
        $dir = dirname($file);
        if (!is_dir($dir)) {
            @mkdir($dir, 0755, true);
        }
        $tmp = $file . '.tmp.' . bin2hex(random_bytes(6));
        $ok = @file_put_contents($tmp, $data, LOCK_EX);
        if ($ok === false) return false;
        return @rename($tmp, $file);
    }
}
