<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

final class MobileMode
{
    public const STATE_FILE = 'data/mobile_state.json';

    public static function state(): array
    {
        $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2);
        $file = rtrim($root, '/\\') . '/' . self::STATE_FILE;

        $defaults = [
            'enabled' => true,
            'auto_detect' => true,
            'cookie_name' => 'nukece_mobile',
            'theme_slug' => 'subSilver',
            'allow_user_toggle' => true,
            'force_param' => 'mobile', // ?mobile=1 / ?mobile=0
        ];

        if (!is_file($file)) return $defaults;

        $raw = @file_get_contents($file);
        $j = $raw ? json_decode($raw, true) : null;
        if (!is_array($j)) return $defaults;

        return array_replace_recursive($defaults, $j);
    }

    public static function save(array $state): void
    {
        $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2);
        $file = rtrim($root, '/\\') . '/' . self::STATE_FILE;
        @mkdir(dirname($file), 0755, true);
        @file_put_contents($file, json_encode($state, JSON_UNESCAPED_SLASHES|JSON_PRETTY_PRINT), LOCK_EX);
    }

    public static function cookieName(): string
    {
        $st = self::state();
        return (string)($st['cookie_name'] ?? 'nukece_mobile');
    }

    public static function isEnabled(): bool
    {
        $st = self::state();
        return (bool)($st['enabled'] ?? true);
    }

    public static function allowUserToggle(): bool
    {
        $st = self::state();
        return (bool)($st['allow_user_toggle'] ?? true);
    }

    public static function themeSlug(): string
    {
        $st = self::state();
        return (string)($st['theme_slug'] ?? 'subSilver');
    }

    /**
     * Determine if the current request should be in "mobile mode".
     * Priority:
     *  1) explicit ?mobile=1 / ?mobile=0 (if allow_user_toggle)
     *  2) cookie
     *  3) auto-detect user agent
     */
    public static function isMobileRequest(): bool
    {
        if (!self::isEnabled()) return false;

        $st = self::state();
        $param = (string)($st['force_param'] ?? 'mobile');
        $cookie = self::cookieName();
        $allowToggle = self::allowUserToggle();

        if ($allowToggle && isset($_GET[$param])) {
            $v = (string)$_GET[$param];
            if ($v === '1' || strtolower($v) === 'true' || strtolower($v) === 'on') return true;
            if ($v === '0' || strtolower($v) === 'false' || strtolower($v) === 'off') return false;
        }

        if (isset($_COOKIE[$cookie])) {
            $v = (string)$_COOKIE[$cookie];
            if ($v === '1') return true;
            if ($v === '0') return false;
        }

        if (!empty($st['auto_detect'])) {
            return Device::isMobileUserAgent($_SERVER['HTTP_USER_AGENT'] ?? null);
        }

        return false;
    }

    public static function persistChoice(?bool $on): void
    {
        if ($on === null) return;
        $cookie = self::cookieName();
        setcookie($cookie, $on ? '1' : '0', time() + 86400*365, '/');
    }
}
