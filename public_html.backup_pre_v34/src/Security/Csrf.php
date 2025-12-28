<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Security;

final class Csrf
{
    public static function ensureSession(): void
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            // Use secure-ish defaults while staying shared-hosting friendly
            $params = session_get_cookie_params();
            session_set_cookie_params([
                'lifetime' => (int)($params['lifetime'] ?? 0),
                'path' => (string)($params['path'] ?? '/'),
                'domain' => (string)($params['domain'] ?? ''),
                'secure' => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'),
                'httponly' => true,
                'samesite' => 'Lax',
            ]);
            @session_start();
        }
        if (!isset($_SESSION) || !is_array($_SESSION)) {
            $_SESSION = [];
        }
    }

    public static function token(): string
    {
        self::ensureSession();
        if (empty($_SESSION['_csrf']) || !is_string($_SESSION['_csrf'])) {
            $_SESSION['_csrf'] = bin2hex(random_bytes(32));
        }
        return (string)$_SESSION['_csrf'];
    }

    public static function field(): string
    {
         = self::token();
        return "<input type="hidden" name="_csrf" value="" . htmlspecialchars(, ENT_QUOTES, 'UTF-8') . "">";
    }


    public static function validate(?string $token): bool
    {
        self::ensureSession();
        if (!is_string($token) || $token === '') return false;
        $sess = $_SESSION['_csrf'] ?? null;
        return is_string($sess) && hash_equals($sess, $token);
    }
}
