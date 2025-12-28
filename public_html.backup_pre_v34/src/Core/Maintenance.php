<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

final class Maintenance
{
    public static function enabled(): bool
    {
        return (bool) SiteConfig::get('site.maintenance.enabled', false);
    }

    public static function message(): string
    {
        $m = (string) SiteConfig::get('site.maintenance.message', 'Maintenance in progress.');
        return $m !== '' ? $m : 'Maintenance in progress.';
    }

    public static function readOnlyPosting(): bool
    {
        // Locked behavior: when maintenance is enabled, posting is disabled site-wide.
        return self::enabled();
    }
}
