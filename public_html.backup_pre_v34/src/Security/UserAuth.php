\
<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Security;

use NukeCE\Core\Model;
use PDO;

final class UserAuth extends Model
{
    public static function ensureSession(): void
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            @session_start();
        }
    }

    /**
     * Current logged-in user array or null.
     * @return array<string,mixed>|null
     */
    public static function user(): ?array
    {
        self::ensureSession();
        if (!isset($_SESSION['nukece_user_id'])) return null;
        $id = (int)$_SESSION['nukece_user_id'];
        if ($id <= 0) return null;

        $pdo = self::db();
        $t = self::tn('users');
        try {
            $stmt = $pdo->prepare("SELECT id, username, email, role, created_at, last_login FROM `$t` WHERE id=:id LIMIT 1");
            $stmt->execute([':id'=>$id]);
            $u = $stmt->fetch(PDO::FETCH_ASSOC);
            return $u ?: null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    public static function role(): string
    {
        $u = self::user();
        return $u ? (string)($u['role'] ?? 'member') : 'guest';
    }

    public static function isLoggedIn(): bool
    {
        return self::user() !== null;
    }

    public static function login(string $usernameOrEmail, string $password): bool
    {
        self::ensureSession();
        $pdo = self::db();
        $t = self::tn('users');

        $stmt = $pdo->prepare("SELECT * FROM `$t` WHERE username=:u OR email=:u LIMIT 1");
        $stmt->execute([':u'=>$usernameOrEmail]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) return false;

        $hash = (string)($row['pass_hash'] ?? '');
        if ($hash === '' || !password_verify($password, $hash)) return false;

        $_SESSION['nukece_user_id'] = (int)$row['id'];
        $pdo->prepare("UPDATE `$t` SET last_login=NOW() WHERE id=:id")->execute([':id'=>(int)$row['id']]);
        NukeSecurity::log('user.login', ['user'=>(string)$row['username']]);
        return true;
    }

    public static function logout(): void
    {
        self::ensureSession();
        unset($_SESSION['nukece_user_id']);
        NukeSecurity::log('user.logout', []);
    }

    public static function register(string $username, string $email, string $password): array
    {
        $pdo = self::db();
        $t = self::tn('users');

        $username = trim($username);
        $email = trim($email);
        if (mb_strlen($username) < 3) return ['ok'=>false,'err'=>'Username too short'];
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) return ['ok'=>false,'err'=>'Invalid email'];
        if (mb_strlen($password) < 8) return ['ok'=>false,'err'=>'Password too short'];

        $stmt = $pdo->prepare("SELECT COUNT(*) FROM `$t` WHERE username=:u OR email=:e");
        $stmt->execute([':u'=>$username, ':e'=>$email]);
        if ((int)$stmt->fetchColumn() > 0) return ['ok'=>false,'err'=>'Username or email already in use'];

        $hash = password_hash($password, PASSWORD_BCRYPT);
        $stmt = $pdo->prepare("INSERT INTO `$t` (username,email,pass_hash,role,created_at) VALUES (:u,:e,:h,'member',NOW())");
        $stmt->execute([':u'=>$username, ':e'=>$email, ':h'=>$hash]);
        NukeSecurity::log('user.register', ['user'=>$username]);
        return ['ok'=>true];
    }
}
