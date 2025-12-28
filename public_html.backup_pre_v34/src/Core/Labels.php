<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

final class Labels
{
    public static function get(string $key, string $default): string
    {
        try {
            $v = SiteConfig::get('label.' . $key, null);
            if (is_string($v) && trim($v) !== '') return trim($v);
        } catch (\Throwable $e) {
            // fall through
        }
        return $default;
    }
}
