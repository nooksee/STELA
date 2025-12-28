<?php
/**
 * PHP-Nuke CE (Community Edition)
 * Theme asset resolver (theme-first, legacy-friendly)
 */

declare(strict_types=1);

namespace NukeCE\Theme;

final class AssetResolver
{
    /**
     * Resolve an icon filename by trying preferred base names in order.
     * Example: ['links','weblinks','link'] will return the first matching file found.
     */
    public static function resolveIcon(string $themeName, array $baseNames, array $exts = ['svg','png','gif','jpg']): ?string
    {
        $themeDir = dirname(__DIR__, 2) . '/themes/' . $themeName;
        $candidates = [];
        foreach ($baseNames as $base) {
            foreach ($exts as $ext) {
                $candidates[] = "images/{$base}.{$ext}";
                $candidates[] = "admin/{$base}.{$ext}";
            }
        }

        foreach ($candidates as $rel) {
            $path = $themeDir . '/' . $rel;
            if (is_file($path)) {
                return 'themes/' . $themeName . '/' . $rel;
            }
        }
        return null;
    }
}
