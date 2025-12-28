<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Security;

/**
 * Minimal admin auth gate.
 *
 * Uses session flag $_SESSION['nukece_is_admin'] === true.
 * Login is handled by module=admin_login.
 */
final class AuthGate
{
    public static function ensureSession(): void
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            @session_start();
        }
    }

    public static function isAdmin(): bool
    {
        self::ensureSession();
        return isset($_SESSION['nukece_is_admin']) && $_SESSION['nukece_is_admin'] === true;
    }

    public static function requireAdminOrRedirect(): void
    {
        if (!self::isAdmin()) {
            header('Location: /index.php?module=admin_login');
            exit;
        }
    }

    public static function logout(): void
    {
        self::ensureSession();
        unset($_SESSION['nukece_is_admin']);
    }

    public static function loginAsAdmin(): void
    {
        self::ensureSession();
        $_SESSION['nukece_is_admin'] = true;
    }
}
