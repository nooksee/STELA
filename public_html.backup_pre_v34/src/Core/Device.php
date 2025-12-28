<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

/**
 * Minimal device detection for "mobile mode".
 * Conservative: only returns true for obvious mobile user agents.
 */
final class Device
{
    public static function isMobileUserAgent(?string $ua): bool
    {
        if (!$ua) return false;
        $ua = strtolower($ua);

        // Common mobile indicators
        $needles = [
            'iphone','ipod','android','blackberry','bb10','iemobile','windows phone',
            'opera mini','mobile','fennec','webos','palm','silk','kindle','nokia',
        ];

        foreach ($needles as $n) {
            if (strpos($ua, $n) !== false) return true;
        }

        // iPad/tablets are intentionally NOT treated as mobile by default.
        if (strpos($ua, 'ipad') !== false) return false;

        return false;
    }
}
