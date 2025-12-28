<?php
/**
 * PHP-Nuke CE / nukeCE
 * Core Blocks "Gold" helper.
 *
 * This file provides small compatibility helpers for blocks so they can:
 * - Avoid fatals when modules/subsystems are disabled
 * - Prefer nukeCE services (NukeSecurity, AdminUi) when present
 * - Provide safe HTML escaping
 */

declare(strict_types=1);

if (!defined('NUKE_CE')) {
    // Soft-guard: classic distros may not define this. Do not fatal.
}

final class BlockGold
{
    public static function esc(string $s): string
    {
        return htmlspecialchars($s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }

    /**
     * Returns true if current visitor is an admin.
     * Compatible with classic $admin patterns.
     */
    public static function isAdmin(): bool
    {
        if (function_exists('is_admin')) {
            global $admin;
            return (bool) is_admin($admin ?? '');
        }
        if (isset($_SESSION['admin']) && $_SESSION['admin']) {
            return true;
        }
        return false;
    }

    /**
     * Capability check via NukeSecurity when available; falls back to isAdmin.
     */
    public static function can(string $capability): bool
    {
        // Prefer NukeSecurity capability model if present.
        if (class_exists('NukeSecurity') && method_exists('NukeSecurity', 'can')) {
            $user = $GLOBALS['userinfo'] ?? null;
            try {
                return (bool) NukeSecurity::can($user, $capability);
            } catch (Throwable $e) {
                // Fail closed to admin-only in case of unexpected error.
                return self::isAdmin();
            }
        }
        return self::isAdmin();
    }

    /**
     * Emit an audit event if NukeSecurity is available.
     */
    public static function audit(string $event, array $context = []): void
    {
        if (class_exists('NukeSecurity') && method_exists('NukeSecurity', 'audit')) {
            try {
                NukeSecurity::audit($event, $context);
            } catch (Throwable $e) {
                // Never break rendering.
            }
        }
    }

    /**
     * Optional block cache wrapper.
     * If nukeCE exposes a block cache API, we use it; otherwise compute.
     */
    public static function cached(string $key, int $ttlSeconds, callable $compute): string
    {
        // If a cache function exists (project-specific), use it.
        if (function_exists('nukece_block_cache_get') && function_exists('nukece_block_cache_set')) {
            $hit = nukece_block_cache_get($key);
            if (is_string($hit) && $hit !== '') {
                return $hit;
            }
            $out = (string) $compute();
            nukece_block_cache_set($key, $out, $ttlSeconds);
            return $out;
        }

        // Fallback: no caching.
        return (string) $compute();
    }

    /**
     * Safe URL builder fallback.
     */
    public static function url(string $pathOrQuery): string
    {
        // If nukeCE has a URL helper, prefer it.
        if (function_exists('nukece_url')) {
            return (string) nukece_url($pathOrQuery);
        }
        return $pathOrQuery;
    }
}
