<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\AdminWebLinks;

use NukeCE\Core\AdminLayout;
use NukeCE\Core\Model;
use NukeCE\Security\AuthGate;
use NukeCE\Security\Csrf;
use NukeCE\Security\NukeSecurity;
use PDO;

final class AdminWebLinksModule extends Model
{
    public function getName(): string { return 'admin_weblinks'; }

    public function handle(array $params): void
    {
        AuthGate::requireAdmin();
        $pdo = $this->getConnection();
        $this->ensureSchema($pdo);

        $ok=''; $err='';
        if ($_SERVER['REQUEST_METHOD']==='POST') {
            $token = $_POST['_csrf'] ?? null;
            if (!Csrf::validate(is_string($token)?$token:null)) $err='CSRF failed.';
            else {
                $id = (int)($_POST['id'] ?? 0);
                $action = (string)($_POST['action'] ?? '');
                if ($id>0 && $action==='approve') {
                    $st = $pdo->prepare("UPDATE weblinks_items SET status='approved', approved_by=?, approved_at=? WHERE id=?");
                    $st->execute([AuthGate::adminUsername(), gmdate('Y-m-d H:i:s'), $id]);
                    $ok='Approved.';
                    NukeSecurity::log('weblinks.approve', ['id'=>$id,'actor'=>AuthGate::adminUsername()]);
                } elseif ($id>0 && $action==='reject') {
                    $st = $pdo->prepare("DELETE FROM weblinks_items WHERE id=?");
                    $st->execute([$id]);
                    $ok='Removed.';
                    NukeSecurity::log('weblinks.reject', ['id'=>$id,'actor'=>AuthGate::adminUsername()]);
                }
            }
        }

        AdminLayout::header('Links');

        if ($ok) echo "<div class='ok'>".htmlspecialchars($ok,ENT_QUOTES,'UTF-8')."</div>";
        if ($err) echo "<div class='err'>".htmlspecialchars($err,ENT_QUOTES,'UTF-8')."</div>";

        AdminLayout::cardStart('Pending', 'Approve curated links (context-first).');
        $pending = $pdo->query("SELECT id,url,title,tags,submitted_by,created_at FROM weblinks_items WHERE status='pending' ORDER BY id DESC LIMIT 50")
                       ->fetchAll(PDO::FETCH_ASSOC) ?: [];
        if (!$pending) {
            echo '<p>No pending links.</p>';
        } else {
            echo '<table><tr><th>ID</th><th>Title</th><th>URL</th><th>Tags</th><th>By</th><th>At</th><th>Actions</th></tr>';
            foreach ($pending as $p) {
                $id=(int)$p['id'];
                echo '<tr>';
                echo '<td>'.$id.'</td>';
                echo '<td>'.htmlspecialchars((string)$p['title'],ENT_QUOTES,'UTF-8').'</td>';
                echo '<td><small>'.htmlspecialchars((string)$p['url'],ENT_QUOTES,'UTF-8').'</small></td>';
                echo '<td><small>'.htmlspecialchars((string)$p['tags'],ENT_QUOTES,'UTF-8').'</small></td>';
                echo '<td><small>'.htmlspecialchars((string)$p['submitted_by'],ENT_QUOTES,'UTF-8').'</small></td>';
                echo '<td><small>'.htmlspecialchars((string)$p['created_at'],ENT_QUOTES,'UTF-8').'</small></td>';
                echo '<td>';
                echo "<form method='post' style='display:inline'>".Csrf::field()."<input type='hidden' name='id' value='$id'><input type='hidden' name='action' value='approve'><button class='nukece-btn nukece-btn-primary' type='submit'>Approve</button></form> ";
                echo "<form method='post' style='display:inline'>".Csrf::field()."<input type='hidden' name='id' value='$id'><input type='hidden' name='action' value='reject'><button class='nukece-btn' type='submit'>Remove</button></form>";
                echo '</td>';
                echo '</tr>';
            }
            echo '</table>';
        }
        AdminLayout::cardEnd();

        AdminLayout::footer();
    }

    private function ensureSchema(PDO $pdo): void
    {
        $pdo->exec("CREATE TABLE IF NOT EXISTS weblinks_items (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            url VARCHAR(700) NOT NULL,
            title VARCHAR(255) NOT NULL,
            description MEDIUMTEXT NULL,
            tags VARCHAR(255) NOT NULL DEFAULT '',
            status ENUM('pending','approved') NOT NULL DEFAULT 'pending',
            submitted_by VARCHAR(64) NOT NULL DEFAULT 'guest',
            created_at DATETIME NOT NULL,
            approved_by VARCHAR(64) NULL,
            approved_at DATETIME NULL,
            PRIMARY KEY (id),
            KEY idx_status (status)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    }
}
