<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\AdminLogin;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\AdminLayout;
use NukeCE\Security\Csrf;
use NukeCE\Security\AuthGate;

final class AdminLoginModule implements ModuleInterface
{
    public function getName(): string { return 'admin_login'; }

    public function handle(array $params): void
    {
        Csrf::ensureSession();

        if (isset($_GET['logout'])) {
            AuthGate::logout();
            header('Location: /index.php?module=admin_login');
            return;
        }

        $cfg = $this->loadAppConfig();
        $adminUser = (string)($cfg['admin_user'] ?? 'admin');
        $adminPassHash = (string)($cfg['admin_pass_hash'] ?? '');

        // If no password hash is set, we create a temporary one and show it once.
        $tempPassword = null;
        if ($adminPassHash === '') {
            $tempPassword = bin2hex(random_bytes(6));
            $adminPassHash = password_hash($tempPassword, PASSWORD_BCRYPT);
            $this->writeAdminHash($adminPassHash, $adminUser);
        }

        $err = null;

        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
            $token = $_POST['_csrf'] ?? null;
            if (!Csrf::validate(is_string($token) ? $token : null)) {
                $err = "CSRF validation failed.";
            } else {
                $u = (string)($_POST['username'] ?? '');
                $p = (string)($_POST['password'] ?? '');
                if ($u === $adminUser && $adminPassHash !== '' && password_verify($p, $adminPassHash)) {
                    AuthGate::loginAsAdmin();
                    header('Location: /index.php?module=admin_settings');
                    return;
                }
                $err = "Invalid credentials.";
            }
        }

        AdminLayout::header('Admin Login');
        echo "<div class='card' style='max-width:520px;margin:0 auto;'>";
        echo "<h1 style='margin:0 0 10px 0;'>Admin login</h1>";
        if ($tempPassword !== null) {
            echo "<div class='ok' style='margin-bottom:10px;'><b>Temporary password created:</b> <code>".htmlspecialchars($tempPassword,ENT_QUOTES,'UTF-8')."</code><br><small>Set <code>admin_user</code> and <code>admin_pass_hash</code> in <code>config/config.php</code> ASAP.</small></div>";
        }
        if ($err) echo "<div class='err' style='margin-bottom:10px;'>".htmlspecialchars($err,ENT_QUOTES,'UTF-8')."</div>";

        $csrf = htmlspecialchars(Csrf::token(), ENT_QUOTES, 'UTF-8');
        echo "<form method='post' action='/index.php?module=admin_login' style='display:grid;gap:10px;'>";
        echo "<input type='hidden' name='_csrf' value='{$csrf}'>";
        echo "<label>Username<br><input name='username' value='' style='width:100%;padding:10px;border:1px solid #ccc;border-radius:10px;'></label>";
        echo "<label>Password<br><input type='password' name='password' value='' style='width:100%;padding:10px;border:1px solid #ccc;border-radius:10px;'></label>";
        echo "<button class='btn' type='submit'>Sign in</button>";
        echo "</form></div>";
        AdminLayout::footer();
    }

    private function loadAppConfig(): array
    {
        $cfgFile = realpath(__DIR__ . '/../../config/config.php');
        if ($cfgFile && is_file($cfgFile)) {
            $cfg = include $cfgFile;
            return is_array($cfg) ? $cfg : [];
        }
        return [];
    }

    private function writeAdminHash(string $hash, string $user): void
    {
        $cfgFile = __DIR__ . '/../../config/config.php';
        if (!is_file($cfgFile)) return;
        $raw = file_get_contents($cfgFile);
        if (!is_string($raw)) return;
        if (strpos($raw, 'admin_pass_hash') !== false) return;

        // Insert before final return if possible, else append.
        $insert = "\n    'admin_user' => '".addslashes($user)."',\n    'admin_pass_hash' => '".addslashes($hash)."',\n";
        $raw2 = preg_replace("/return\s+\[/", "return [".$insert, $raw, 1);
        if (!is_string($raw2)) $raw2 = $raw . "\n// Added by admin_login\n" . $insert;
        file_put_contents($cfgFile, $raw2);
    }
}
