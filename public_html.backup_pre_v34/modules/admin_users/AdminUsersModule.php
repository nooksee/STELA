\
<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Admin: Users &amp; Roles
 */

namespace NukeCE\Modules\AdminUsers;

use NukeCE\Core\AdminLayout;
use NukeCE\Core\Model;
use NukeCE\Security\AuthGate;
use NukeCE\Security\Csrf;
use NukeCE\Security\UserAuth;
use PDO;

final class AdminUsersModule extends Model implements \NukeCE\Core\ModuleInterface
{
    public function getName(): string { return 'admin_users'; }

    public function handle(array $params): void
    {
        // Only allow admin panel authenticated admins.
        AuthGate::requireAdminOrRedirect();

        $pdo = $this->getConnection();
        if (!$this->tableExists($pdo, self::tn('users'))) {
            AdminLayout::page('Users &amp; Roles', function () {
                echo "<p>Users schema not installed.</p>";
                echo "<p><a class='btn' href='/install/setup_users_roles.php' target='_blank'>Run Users/Roles Setup</a></p>";
            });
            return;
        }

        $op = (string)($_GET['op'] ?? 'list');
        if ($op === 'edit') { $this->edit($pdo, (int)($_GET['id'] ?? 0)); return; }
        if ($op === 'save') { $this->save($pdo); return; }
        if ($op === 'promote') { $this->promote($pdo, (int)($_GET['id'] ?? 0), (string)($_GET['to'] ?? 'editor')); return; }

        $this->listing($pdo);
    }

    private function listing(PDO $pdo): void
    {
        $t = self::tn('users');
        $rows = $pdo->query("SELECT id,username,email,role,created_at,last_login FROM `$t` ORDER BY id DESC LIMIT 500")->fetchAll(PDO::FETCH_ASSOC);

        AdminLayout::page('Users &amp; Roles', function () use ($rows) {
            echo "<div style='display:flex;justify-content:space-between;align-items:center;gap:10px;flex-wrap:wrap'>";
            echo "<div><h1 style='margin:0'>Users &amp; Roles</h1><div class='muted'>Promote/demote roles safely</div></div>";
            echo "<a class='btn2' href='/index.php?module=admin_users'>Refresh</a>";
            echo "</div>";

            if (!$rows) { echo "<p>No users found.</p>"; return; }

            echo "<table class='table' style='width:100%;margin-top:12px'>";
            echo "<tr><th>ID</th><th>Username</th><th>Email</th><th>Role</th><th>Created</th><th>Last login</th><th></th></tr>";
            foreach ($rows as $r) {
                $id = (int)$r['id'];
                $u = htmlspecialchars((string)$r['username'], ENT_QUOTES, 'UTF-8');
                $e = htmlspecialchars((string)$r['email'], ENT_QUOTES, 'UTF-8');
                $role = htmlspecialchars((string)$r['role'], ENT_QUOTES, 'UTF-8');
                $created = htmlspecialchars((string)($r['created_at'] ?? ''), ENT_QUOTES, 'UTF-8');
                $last = htmlspecialchars((string)($r['last_login'] ?? ''), ENT_QUOTES, 'UTF-8');
                $edit = "/index.php?module=admin_users&op=edit&id={$id}";
                $csrf = rawurlencode(Csrf::token());
                $promoteEditor = "/index.php?module=admin_users&op=promote&id={$id}&to=editor&csrf={$csrf}";
                $promoteAdmin = "/index.php?module=admin_users&op=promote&id={$id}&to=admin&csrf={$csrf}";
                echo "<tr>";
                echo "<td>{$id}</td><td><b>{$u}</b></td><td>{$e}</td><td>{$role}</td><td>{$created}</td><td>{$last}</td>";
                echo "<td style='white-space:nowrap'><a class='btn2' href='{$edit}'>Edit</a>";
                if ($role === 'member') { echo " <a class='btn2' href='{$promoteEditor}'>Promote → Editor</a>"; }
                if ($role !== 'admin') { echo " <a class='btn2' href='{$promoteAdmin}'>Promote → Admin</a>"; }
                echo "</td>";
                echo "</tr>";
            }
            echo "</table>";
        });
    }

    private function edit(PDO $pdo, int $id): void
    {
        if ($id <= 0) { header('Location: /index.php?module=admin_users'); exit; }

        $t = self::tn('users');
        $stmt = $pdo->prepare("SELECT id,username,email,role FROM `$t` WHERE id=:id LIMIT 1");
        $stmt->execute([':id'=>$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) { header('Location: /index.php?module=admin_users'); exit; }

        $username = htmlspecialchars((string)$row['username'], ENT_QUOTES, 'UTF-8');
        $email = htmlspecialchars((string)$row['email'], ENT_QUOTES, 'UTF-8');
        $role = (string)$row['role'];

        AdminLayout::page("Edit User #{$id}", function () use ($id, $username, $email, $role) {
            $csrf = Csrf::token();
            echo "<h1>Edit User Role</h1>";
            echo "<div class='card' style='padding:12px;margin:12px 0'>";
            echo "<b>User:</b> {$username}<br>";
            echo "<b>Email:</b> {$email}<br>";
            echo "</div>";

            echo "<form method='post' action='/index.php?module=admin_users&op=save' style='display:grid;gap:12px;max-width:520px'>";
            echo "<input type='hidden' name='csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
            echo "<input type='hidden' name='id' value='{$id}'>";

            echo "<label><b>Role</b><br><select name='role'>";
            foreach (['member'=>'Member','editor'=>'Editor','admin'=>'Admin'] as $k=>$label) {
                $sel = ($role === $k) ? " selected" : "";
                echo "<option value='{$k}'{$sel}>{$label}</option>";
            }
            echo "</select></label>";

            echo "<div class='muted' style='font-size:12px'>";
            echo "Admins can access all admin panels. Editors can manage Pages/Reference but not core admin login.";
            echo "</div>";

            echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
            echo "<button class='btn' type='submit'>Save</button>";
            echo "<a class='btn2' href='/index.php?module=admin_users'>Cancel</a>";
            echo "</div>";
            echo "</form>";
        });
    }

    private function save(PDO $pdo): void
    {
        Csrf::validateOrDie($_POST['csrf'] ?? '');
        $id = (int)($_POST['id'] ?? 0);
        $role = (string)($_POST['role'] ?? 'member');

        if ($id <= 0) { header('Location: /index.php?module=admin_users'); exit; }
        if (!in_array($role, ['member','editor','admin'], true)) $role = 'member';

        $t = self::tn('users');
        $st = $pdo->prepare("SELECT role FROM `$t` WHERE id=:id LIMIT 1");
        $st->execute([':id'=>$id]);
        $oldRole = (string)($st->fetchColumn() ?: '');

        $stmt = $pdo->prepare("UPDATE `$t` SET role=:r WHERE id=:id");
        $stmt->execute([':r'=>$role, ':id'=>$id]);

        if ($oldRole !== '' && $oldRole !== $role) {
            \NukeCE\Security\NukeSecurity::log('users.role.changed', [
                'user_id' => $id,
                'old_role' => $oldRole,
                'new_role' => $role,
                'by' => (\NukeCE\Security\UserAuth::user()['username'] ?? \NukeCE\Security\AuthGate::adminName() ?? 'admin'),
            ]);
        }

        // If the user changed their own role and is logged in via user auth, refresh session role next request.
        header('Location: /index.php?module=admin_users');
        exit;
    }

    private function promote(PDO $pdo, int $id, string $to): void
{
    Csrf::validateOrDie($_GET['csrf'] ?? '');
    if ($id <= 0) { header('Location: /index.php?module=admin_users'); exit; }
    if (!in_array($to, ['member','editor','admin'], true)) $to = 'editor';

    $t = self::tn('users');
    $pdo->prepare("UPDATE `$t` SET role=:r WHERE id=:id")->execute([':r'=>$to, ':id'=>$id]);

    // Audit
    \NukeCE\Security\NukeSecurity::log('users.role.changed', [
        'user_id' => $id,
        'new_role' => $to,
        'by' => (\NukeCE\Security\UserAuth::user()['username'] ?? \NukeCE\Security\AuthGate::adminName() ?? 'admin'),
    ]);

    header('Location: /index.php?module=admin_users');
    exit;
}

private function tableExists(PDO $pdo, string $table): bool
    {
        try {
            $stmt = $pdo->prepare("SHOW TABLES LIKE :t");
            $stmt->execute([':t'=>$table]);
            return (bool)$stmt->fetchColumn();
        } catch (\Throwable $e) { return false; }
    }
}
