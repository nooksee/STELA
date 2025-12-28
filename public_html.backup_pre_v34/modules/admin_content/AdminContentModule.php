\
<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Admin: Pages (Content)
 */

namespace NukeCE\Modules\AdminContent;

use NukeCE\Core\AdminLayout;
use NukeCE\Core\Model;
use NukeCE\Security\CapabilityGate;
use NukeCE\Security\CapabilityGate;
use NukeCE\Security\Csrf;
use PDO;

final class AdminContentModule extends Model implements \NukeCE\Core\ModuleInterface
{
    public function getName(): string { return 'admin_content'; }

    public function handle(array $params): void
    {
        CapabilityGate::require('content.edit');
        CapabilityGate::require('content.edit');
        $pdo = $this->getConnection();

        if (!$this->tableExists($pdo, self::tn('content_pages'))) {
            AdminLayout::page('Pages Admin', function () {
                echo "<p>Pages schema not installed.</p>";
                echo "<p><a class='btn' href='/install/setup_pages_reference.php' target='_blank'>Run Pages/Reference Setup</a></p>";
            });
            return;
        }

        $op = (string)($_GET['op'] ?? 'list');
        if ($op === 'new') { $this->edit($pdo, 0); return; }
        if ($op === 'edit') { $this->edit($pdo, (int)($_GET['id'] ?? 0)); return; }
        if ($op === 'save') { $this->save($pdo); return; }
        if ($op === 'delete') { $this->delete($pdo, (int)($_GET['id'] ?? 0)); return; }

        $this->listing($pdo);
    }

    private function listing(PDO $pdo): void
    {
        $t = self::tn('content_pages');
        $rows = $pdo->query("SELECT id,title,slug,status,updated_at,created_at FROM `$t` ORDER BY id DESC")->fetchAll(PDO::FETCH_ASSOC);

        AdminLayout::page('Pages Admin', function () use ($rows) {
            echo "<div style='display:flex;justify-content:space-between;align-items:center;gap:10px;flex-wrap:wrap'>";
            echo "<h1 style='margin:0'>Pages</h1>";
            echo "<a class='btn' href='/index.php?module=admin_content&op=new'>New Page</a>";
            echo "</div>";

            if (!$rows) { echo "<p>No pages yet.</p>"; return; }

            echo "<table class='table' style='width:100%;margin-top:12px'>";
            echo "<tr><th>ID</th><th>Title</th><th>Slug</th><th>Status</th><th>Updated</th><th></th></tr>";
            foreach ($rows as $r) {
                $id = (int)$r['id'];
                $title = htmlspecialchars((string)$r['title'], ENT_QUOTES, 'UTF-8');
                $slug = htmlspecialchars((string)$r['slug'], ENT_QUOTES, 'UTF-8');
                $status = htmlspecialchars((string)$r['status'], ENT_QUOTES, 'UTF-8');
                $upd = htmlspecialchars((string)($r['updated_at'] ?? $r['created_at'] ?? ''), ENT_QUOTES, 'UTF-8');
                $edit = "/index.php?module=admin_content&op=edit&id={$id}";
                $del = "/index.php?module=admin_content&op=delete&id={$id}&csrf=" . rawurlencode(Csrf::token());
                $view = "/index.php?module=content&op=view&slug=" . rawurlencode((string)$r['slug']);
                echo "<tr>";
                echo "<td>{$id}</td><td><a href='{$edit}'><b>{$title}</b></a></td><td>{$slug}</td><td>{$status}</td><td>{$upd}</td>";
                echo "<td style='white-space:nowrap'><a class='btn2' href='{$view}' target='_blank'>View</a> <a class='btn2' href='{$del}'>Delete</a></td>";
                echo "</tr>";
            }
            echo "</table>";
        });
    }

    private function edit(PDO $pdo, int $id): void
    {
        $t = self::tn('content_pages');
        $row = null;
        if ($id > 0) {
            $stmt = $pdo->prepare("SELECT * FROM `$t` WHERE id=:id LIMIT 1");
            $stmt->execute([':id'=>$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        }

        $title = $row ? (string)$row['title'] : '';
        $slug = $row ? (string)$row['slug'] : '';
        $summary = $row ? (string)$row['summary'] : '';
        $body = $row ? (string)$row['body'] : '';
        $status = $row ? (string)$row['status'] : 'draft';

        AdminLayout::page($id ? "Edit Page" : "New Page", function () use ($id,$title,$slug,$summary,$body,$status) {
            $csrf = Csrf::token();
            echo "<h1>" . ($id ? "Edit Page" : "New Page") . "</h1>";
            echo "<form method='post' action='/index.php?module=admin_content&op=save' style='display:grid;gap:12px'>";
            echo "<input type='hidden' name='csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
            echo "<input type='hidden' name='id' value='{$id}'>";
            echo "<label><b>Title</b><br><input name='title' value='".htmlspecialchars($title,ENT_QUOTES,'UTF-8')."' style='width:100%' required></label>";
            echo "<label><b>Slug</b> <span class='muted'>(blank = auto)</span><br><input name='slug' value='".htmlspecialchars($slug,ENT_QUOTES,'UTF-8')."' style='width:100%'></label>";
            echo "<label><b>Summary</b><br><input name='summary' value='".htmlspecialchars($summary,ENT_QUOTES,'UTF-8')."' style='width:100%'></label>";
            echo "<label><b>Body</b> <span class='muted'>(BBCode supported)</span><br><textarea name='body' rows='16' style='width:100%'>".htmlspecialchars($body,ENT_QUOTES,'UTF-8')."</textarea></label>";
            echo "<label><b>Status</b><br><select name='status'>
                    <option value='draft'".($status==='draft'?' selected':'').">Draft</option>
                    <option value='published'".($status==='published'?' selected':'').">Published</option>
                  </select></label>";
            echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
            echo "<button class='btn' type='submit'>Save</button>";
            echo "<a class='btn2' href='/index.php?module=admin_content'>Back</a>";
            echo "</div>";
            echo "</form>";
        });
    }

    private function save(PDO $pdo): void
    {
        Csrf::validateOrDie($_POST['csrf'] ?? '');
        $id = (int)($_POST['id'] ?? 0);
        $title = trim((string)($_POST['title'] ?? ''));
        $slug = trim((string)($_POST['slug'] ?? ''));
        $summary = trim((string)($_POST['summary'] ?? ''));
        $body = (string)($_POST['body'] ?? '');
        $status = (string)($_POST['status'] ?? 'draft');
        if ($title === '') { header('Location: /index.php?module=admin_content'); exit; }

        if ($slug === '') $slug = $this->slugify($title);

        $t = self::tn('content_pages');
        $now = date('Y-m-d H:i:s');

        if ($id > 0) {
            $stmt = $pdo->prepare("UPDATE `$t` SET slug=:s,title=:t,summary=:sm,body=:b,status=:st,updated_at=:u WHERE id=:id");
            $stmt->execute([':s'=>$slug,':t'=>$title,':sm'=>$summary,':b'=>$body,':st'=>$status,':u'=>$now,':id'=>$id]);
        } else {
            $stmt = $pdo->prepare("INSERT INTO `$t` (slug,title,summary,body,status,created_at) VALUES (:s,:t,:sm,:b,:st,:c)");
            $stmt->execute([':s'=>$slug,':t'=>$title,':sm'=>$summary,':b'=>$body,':st'=>$status,':c'=>$now]);
        }
        header('Location: /index.php?module=admin_content');
        exit;
    }

    private function delete(PDO $pdo, int $id): void
    {
        Csrf::validateOrDie($_GET['csrf'] ?? '');
        if ($id <= 0) { header('Location: /index.php?module=admin_content'); exit; }
        $t = self::tn('content_pages');
        $stmt = $pdo->prepare("DELETE FROM `$t` WHERE id=:id");
        $stmt->execute([':id'=>$id]);
        header('Location: /index.php?module=admin_content');
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

    private function slugify(string $s): string
    {
        $s = trim(mb_strtolower($s));
        $s = preg_replace('/[^a-z0-9\s\-]/u', '', $s) ?? $s;
        $s = preg_replace('/\s+/', '-', $s) ?? $s;
        $s = preg_replace('/\-+/', '-', $s) ?? $s;
        return trim($s, '-');
    }
}
