\
<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Users;

use NukeCE\Core\Layout;
use NukeCE\Security\Csrf;
use NukeCE\Security\UserAuth;
use NukeCE\Security\NukeSecurity;

final class UsersModule implements \NukeCE\Core\ModuleInterface
{
    public function getName(): string { return 'users'; }

    public function handle(array $params): void
    {
        $op = (string)($_GET['op'] ?? 'home');

        if ($op === 'login') { $this->login(); return; }
        if ($op === 'register') { $this->register(); return; }
        if ($op === 'logout') { $this->logout(); return; }

        $this->home();
    }

    private function home(): void
    {
        $u = UserAuth::user();

        Layout::page('Users', function () use ($u) {
            echo "<div class='card' style='padding:16px;max-width:980px'>";
            echo "<h1>Users</h1>";
            if (!$u) {
                echo "<p class='muted'>You are browsing as a guest.</p>";
                echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
                echo "<a class='btn' href='/index.php?module=users&op=login'>Login</a>";
                echo "<a class='btn2' href='/index.php?module=users&op=register'>Register</a>";
                echo "</div>";
            } else {
                $name = htmlspecialchars((string)$u['username'], ENT_QUOTES, 'UTF-8');
                $role = htmlspecialchars((string)$u['role'], ENT_QUOTES, 'UTF-8');
                echo "<p>Logged in as <b>{$name}</b> <span class='muted'>(role: {$role})</span></p>";
                echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
                echo "<a class='btn2' href='/index.php?module=users&op=logout&csrf=" . rawurlencode(Csrf::token()) . "'>Logout</a>";
                echo "</div>";
            }
            echo "</div>";
        }, ['module'=>'users']);
    }

    private function login(): void
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            Csrf::validateOrDie($_POST['csrf'] ?? '');
            $u = trim((string)($_POST['user'] ?? ''));
            $p = (string)($_POST['pass'] ?? '');
            if (UserAuth::login($u, $p)) {
                header('Location: /index.php?module=users');
                exit;
            }
            NukeSecurity::log('user.login.fail', ['user'=>$u]);
            header('Location: /index.php?module=users&op=login&err=1');
            exit;
        }

        $err = isset($_GET['err']);
        Layout::page('Login', function () use ($err) {
            echo "<div class='card' style='padding:16px;max-width:560px'>";
            echo "<h1>Login</h1>";
            if ($err) echo "<div class='card' style='padding:10px;margin:10px 0'><b>Login failed.</b></div>";
            $csrf = Csrf::token();
            echo "<form method='post' style='display:grid;gap:12px'>";
            echo "<input type='hidden' name='csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
            echo "<label><b>Username or email</b><br><input name='user' required style='width:100%'></label>";
            echo "<label><b>Password</b><br><input type='password' name='pass' required style='width:100%'></label>";
            echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
            echo "<button class='btn' type='submit'>Login</button>";
            echo "<a class='btn2' href='/index.php?module=users'>Cancel</a>";
            echo "</div>";
            echo "</form>";
            echo "</div>";
        }, ['module'=>'users']);
    }

    private function register(): void
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            Csrf::validateOrDie($_POST['csrf'] ?? '');
            $username = trim((string)($_POST['username'] ?? ''));
            $email = trim((string)($_POST['email'] ?? ''));
            $pass = (string)($_POST['pass'] ?? '');
            $pass2 = (string)($_POST['pass2'] ?? '');
            if ($pass !== $pass2) {
                header('Location: /index.php?module=users&op=register&err=nomatch');
                exit;
            }
            $res = UserAuth::register($username, $email, $pass);
            if (!($res['ok'] ?? false)) {
                $e = rawurlencode((string)($res['err'] ?? 'error'));
                header("Location: /index.php?module=users&op=register&err={$e}");
                exit;
            }
            // auto-login
            UserAuth::login($username, $pass);
            header('Location: /index.php?module=users');
            exit;
        }

        $err = (string)($_GET['err'] ?? '');
        Layout::page('Register', function () use ($err) {
            echo "<div class='card' style='padding:16px;max-width:560px'>";
            echo "<h1>Register</h1>";
            if ($err) echo "<div class='card' style='padding:10px;margin:10px 0'><b>Fix:</b> " . htmlspecialchars($err,ENT_QUOTES,'UTF-8') . "</div>";
            $csrf = Csrf::token();
            echo "<form method='post' style='display:grid;gap:12px'>";
            echo "<input type='hidden' name='csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
            echo "<label><b>Username</b><br><input name='username' required minlength='3' maxlength='60' style='width:100%'></label>";
            echo "<label><b>Email</b><br><input name='email' required maxlength='190' style='width:100%'></label>";
            echo "<label><b>Password</b><br><input type='password' name='pass' required minlength='8' style='width:100%'></label>";
            echo "<label><b>Confirm password</b><br><input type='password' name='pass2' required minlength='8' style='width:100%'></label>";
            echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
            echo "<button class='btn' type='submit'>Create account</button>";
            echo "<a class='btn2' href='/index.php?module=users'>Cancel</a>";
            echo "</div>";
            echo "</form>";
            echo "</div>";
        }, ['module'=>'users']);
    }

    private function logout(): void
    {
        Csrf::validateOrDie($_GET['csrf'] ?? '');
        UserAuth::logout();
        header('Location: /index.php?module=users');
        exit;
    }
}
