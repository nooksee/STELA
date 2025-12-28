<?php
declare(strict_types=1);

namespace NukeCE\Core;

/**
 * StoragePaths
 *
 * Centralizes filesystem paths derived from AppConfig.
 * Provides safe join helpers and optional directory ensure.
 */
final class StoragePaths
{
    private function __construct() {}

    public static function uploadsDir(): string
    {
        return self::norm(AppConfig::getString('uploads_dir', NUKECE_ROOT . '/uploads'));
    }

    public static function cacheDir(): string
    {
        return self::norm(AppConfig::getString('cache_dir', NUKECE_ROOT . '/cache'));
    }

    public static function tmpDir(): string
    {
        return self::norm(AppConfig::getString('tmp_dir', NUKECE_ROOT . '/tmp'));
    }

    public static function logsDir(): string
    {
        return self::norm(AppConfig::getString('logs_dir', NUKECE_ROOT . '/logs'));
    }

    public static function dataDir(): string
    {
        return self::norm(AppConfig::getString('data_dir', NUKECE_ROOT . '/data'));
    }

    /** Join path segments safely under a base directory. */
    public static function join(string $baseDir, string ...$parts): string
    {
        $baseDir = self::norm($baseDir);
        $path = rtrim($baseDir, "/\\");
        foreach ($parts as $p) {
            $p = self::sanitizePart($p);
            if ($p === '') continue;
            $path .= '/' . $p;
        }
        return $path;
    }

    /** Ensure directory exists (0755) */
    public static function ensureDir(string $dir): bool
    {
        $dir = self::norm($dir);
        if (is_dir($dir)) return true;
        return @mkdir($dir, 0755, true);
    }

    private static function norm(string $path): string
    {
        $path = str_replace('\\', '/', $path);
        return rtrim($path, "/");
    }

    private static function sanitizePart(string $part): string
    {
        $part = str_replace('\\', '/', $part);
        $part = trim($part, "/");
        if ($part === '.' || $part === '..') return '';
        $part = str_replace(['../', '..\\', './', '.\\'], '', $part);
        $part = preg_replace('#\.{2,}#', '', (string)$part);
        return (string)$part;
    }
}
