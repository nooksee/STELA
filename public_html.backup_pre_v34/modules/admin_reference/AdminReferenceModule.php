\
<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Admin: Knowledge Base (Reference)
 */

namespace NukeCE\Modules\AdminReference;

use NukeCE\Core\AdminLayout;
use NukeCE\Core\Model;
use NukeCE\Security\CapabilityGate;
use NukeCE\Security\CapabilityGate;
use NukeCE\Security\Csrf;
use PDO;

final class AdminReferenceModule extends Model implements \NukeCE\Core\ModuleInterface
{
    public function getName(): string { return 'admin_reference'; }

    public function handle(array $params): void
    {
        CapabilityGate::require('reference.queue.review');
        CapabilityGate::require('reference.queue.review');
        $pdo = $this->getConnection();

        if (!$this->tableExists($pdo, self::tn('ref_entries'))) {
            AdminLayout::page('Knowledge Base Admin', function () {
                echo "<p>Pages/Reference schema not installed.</p>";
                echo "<p><a class='btn' href='/install/setup_pages_reference.php' target='_blank'>Run Pages/Reference Setup</a></p>";
            });
            return;
        }

        $op = (string)($_GET['op'] ?? 'dashboard');

        if ($op === 'new') { $this->edit($pdo, 0); return; }
        if ($op === 'edit') { $this->edit($pdo, (int)($_GET['id'] ?? 0)); return; }
        if ($op === 'save') { $this->save($pdo); return; }
        if ($op === 'delete') { $this->delete($pdo, (int)($_GET['id'] ?? 0)); return; }

        if ($op === 'queue') { $this->queue($pdo); return; }
        if ($op === 'queue_view') { $this->queueView($pdo, (int)($_GET['id'] ?? 0)); return; }
        if ($op === 'queue_action') { $this->queueAction($pdo); return; }

        $this->dashboard($pdo);
    }

    private function dashboard(PDO $pdo): void
    {
        $entriesT = self::tn('ref_entries');
        $queueT = self::tn('ref_queue');

        $entries = $pdo->query("SELECT id,term,slug,status,updated_at,created_at FROM `$entriesT` ORDER BY id DESC LIMIT 15")->fetchAll(PDO::FETCH_ASSOC);
        $qcounts = $pdo->query("SELECT status, COUNT(*) c FROM `$queueT` GROUP BY status")->fetchAll(PDO::FETCH_KEY_PAIR);

        AdminLayout::page('Knowledge Base Admin', function () use ($entries, $qcounts) {
            echo "<div style='display:flex;justify-content:space-between;align-items:center;gap:10px;flex-wrap:wrap'>";
            echo "<div><h1 style='margin:0'>Knowledge Base</h1><div class='muted'>Reference entries + intake queue</div></div>";
            echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
            echo "<a class='btn2' href='/index.php?module=admin_reference&op=queue'>Queue</a>";
            echo "<a class='btn' href='/index.php?module=admin_reference&op=new'>New Entry</a>";
            echo "</div></div>";

            $new = (int)($qcounts['new'] ?? 0);
            $rev = (int)($qcounts['reviewing'] ?? 0);
            echo "<div class='card' style='padding:12px;margin-top:12px'>";
            echo "<b>Queue:</b> {$new} new · {$rev} reviewing";
            echo " · <a href='/index.php?module=admin_reference&op=queue'>Open queue</a>";
            echo "</div>";

            echo "<h2 style='margin-top:16px'>Recent entries</h2>";
            if (!$entries) { echo "<p>No entries yet.</p>"; return; }

            echo "<table class='table' style='width:100%'>";
            echo "<tr><th>ID</th><th>Term</th><th>Slug</th><th>Status</th><th>Updated</th><th></th></tr>";
            foreach ($entries as $r) {
                $id = (int)$r['id'];
                $term = htmlspecialchars((string)$r['term'], ENT_QUOTES, 'UTF-8');
                $slug = htmlspecialchars((string)$r['slug'], ENT_QUOTES, 'UTF-8');
                $status = htmlspecialchars((string)$r['status'], ENT_QUOTES, 'UTF-8');
                $upd = htmlspecialchars((string)($r['updated_at'] ?? $r['created_at'] ?? ''), ENT_QUOTES, 'UTF-8');
                $edit = "/index.php?module=admin_reference&op=edit&id={$id}";
                $del = "/index.php?module=admin_reference&op=delete&id={$id}&csrf=" . rawurlencode(Csrf::token());
                $view = "/index.php?module=reference&op=view&slug=" . rawurlencode((string)$r['slug']);
                echo "<tr>";
                echo "<td>{$id}</td><td><a href='{$edit}'><b>{$term}</b></a></td><td>{$slug}</td><td>{$status}</td><td>{$upd}</td>";
                echo "<td style='white-space:nowrap'><a class='btn2' href='{$view}' target='_blank'>View</a> <a class='btn2' href='{$del}'>Delete</a></td>";
                echo "</tr>";
            }
            echo "</table>";
        });
    }

    private function edit(PDO $pdo, int $id): void
    {
        $t = self::tn('ref_entries');
        $row = null;
        if ($id > 0) {
            $stmt = $pdo->prepare("SELECT * FROM `$t` WHERE id=:id LIMIT 1");
            $stmt->execute([':id'=>$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        }

        $term = $row ? (string)$row['term'] : '';
        $slug = $row ? (string)$row['slug'] : '';
        $def = $row ? (string)$row['definition'] : '';
        $status = $row ? (string)$row['status'] : 'draft';
        $note = $row ? (string)$row['curator_note'] : '';

        AdminLayout::page($id ? "Edit Reference Entry" : "New Reference Entry", function () use ($id,$term,$slug,$def,$status,$note) {
            $csrf = Csrf::token();
            echo "<h1>" . ($id ? "Edit Reference Entry" : "New Reference Entry") . "</h1>";
            echo "<form method='post' action='/index.php?module=admin_reference&op=save' style='display:grid;gap:12px'>";
            echo "<input type='hidden' name='csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
            echo "<input type='hidden' name='id' value='{$id}'>";
            echo "<label><b>Term</b><br><input name='term' value='".htmlspecialchars($term,ENT_QUOTES,'UTF-8')."' style='width:100%' required></label>";
            echo "<label><b>Slug</b> <span class='muted'>(blank = auto)</span><br><input name='slug' value='".htmlspecialchars($slug,ENT_QUOTES,'UTF-8')."' style='width:100%'></label>";
            echo "<label><b>Definition</b> <span class='muted'>(BBCode supported)</span><br><textarea name='definition' rows='16' style='width:100%'>".htmlspecialchars($def,ENT_QUOTES,'UTF-8')."</textarea></label>";
            echo "<label><b>Curator note</b><br><input name='curator_note' value='".htmlspecialchars($note,ENT_QUOTES,'UTF-8')."' style='width:100%'></label>";
            echo "<label><b>Status</b><br><select name='status'>
                    <option value='draft'".($status==='draft'?' selected':'').">Draft</option>
                    <option value='published'".($status==='published'?' selected':'').">Published</option>
                  </select></label>";
            echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
            echo "<button class='btn' type='submit'>Save</button>";
            echo "<a class='btn2' href='/index.php?module=admin_reference'>Back</a>";
            echo "</div>";
            echo "</form>";
        });
    }

    private function save(PDO $pdo): void
    {
        Csrf::validateOrDie($_POST['csrf'] ?? '');
        $id = (int)($_POST['id'] ?? 0);
        $term = trim((string)($_POST['term'] ?? ''));
        $slug = trim((string)($_POST['slug'] ?? ''));
        $def = (string)($_POST['definition'] ?? '');
        $status = (string)($_POST['status'] ?? 'draft');
        $note = trim((string)($_POST['curator_note'] ?? ''));
        if ($term === '') { header('Location: /index.php?module=admin_reference'); exit; }

        if ($slug === '') $slug = $this->slugify($term);

        $t = self::tn('ref_entries');
        $now = date('Y-m-d H:i:s');

        if ($id > 0) {
            $stmt = $pdo->prepare("UPDATE `$t` SET slug=:s,term=:t,definition=:d,status=:st,curator_note=:n,updated_at=:u WHERE id=:id");
            $stmt->execute([':s'=>$slug,':t'=>$term,':d'=>$def,':st'=>$status,':n'=>$note,':u'=>$now,':id'=>$id]);
        } else {
            $stmt = $pdo->prepare("INSERT INTO `$t` (slug,term,definition,status,curator_note,created_at) VALUES (:s,:t,:d,:st,:n,:c)");
            $stmt->execute([':s'=>$slug,':t'=>$term,':d'=>$def,':st'=>$status,':n'=>$note,':c'=>$now]);
        }
        header('Location: /index.php?module=admin_reference');
        exit;
    }

    private function delete(PDO $pdo, int $id): void
    {
        Csrf::validateOrDie($_GET['csrf'] ?? '');
        if ($id <= 0) { header('Location: /index.php?module=admin_reference'); exit; }
        $t = self::tn('ref_entries');
        $stmt = $pdo->prepare("DELETE FROM `$t` WHERE id=:id");
        $stmt->execute([':id'=>$id]);
        header('Location: /index.php?module=admin_reference');
        exit;
    }

    private function queue(PDO $pdo): void
    {
        $t = self::tn('ref_queue');
        $rows = $pdo->query("SELECT id,proposed_term,status,created_at,reviewer,reviewed_at FROM `$t` ORDER BY created_at DESC LIMIT 200")->fetchAll(PDO::FETCH_ASSOC);

        AdminLayout::page('Knowledge Base · Queue', function () use ($rows) {
            echo "<div style='display:flex;justify-content:space-between;align-items:center;gap:10px;flex-wrap:wrap'>";
            echo "<h1 style='margin:0'>Intake Queue</h1>";
            echo "<a class='btn2' href='/index.php?module=admin_reference'>Back</a>";
            echo "</div>";
            if (!$rows) { echo "<p>No queue items.</p>"; return; }

            echo "<table class='table' style='width:100%;margin-top:12px'>";
            echo "<tr><th>ID</th><th>Term</th><th>Status</th><th>Created</th><th>Reviewer</th><th>Reviewed</th><th></th></tr>";
            foreach ($rows as $r) {
                $id = (int)$r['id'];
                $term = htmlspecialchars((string)$r['proposed_term'], ENT_QUOTES, 'UTF-8');
                $status = htmlspecialchars((string)$r['status'], ENT_QUOTES, 'UTF-8');
                $created = htmlspecialchars((string)$r['created_at'], ENT_QUOTES, 'UTF-8');
                $reviewer = htmlspecialchars((string)($r['reviewer'] ?? ''), ENT_QUOTES, 'UTF-8');
                $reviewed = htmlspecialchars((string)($r['reviewed_at'] ?? ''), ENT_QUOTES, 'UTF-8');
                $u = "/index.php?module=admin_reference&op=queue_view&id={$id}";
                echo "<tr><td>{$id}</td><td><a href='{$u}'><b>{$term}</b></a></td><td>{$status}</td><td>{$created}</td><td>{$reviewer}</td><td>{$reviewed}</td><td><a class='btn2' href='{$u}'>Review</a></td></tr>";
            }
            echo "</table>";
        });
    }

    private function queueView(PDO $pdo, int $id): void
    {
        $t = self::tn('ref_queue');
        $stmt = $pdo->prepare("SELECT * FROM `$t` WHERE id=:id LIMIT 1");
        $stmt->execute([':id'=>$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) { header('Location: /index.php?module=admin_reference&op=queue'); exit; }

        $term = htmlspecialchars((string)$row['proposed_term'], ENT_QUOTES, 'UTF-8');
        $status = htmlspecialchars((string)$row['status'], ENT_QUOTES, 'UTF-8');
        $def = htmlspecialchars((string)$row['proposed_definition'], ENT_QUOTES, 'UTF-8');
        $src = (string)$row['source_json'];

        AdminLayout::page("Queue Item #{$id}", function () use ($id,$term,$status,$def,$src) {
            $csrf = Csrf::token();
            echo "<h1>Queue Item #{$id}</h1>";
            echo "<div class='card' style='padding:12px;margin:12px 0'>";
            echo "<b>Term:</b> {$term}<br>";
            echo "<b>Status:</b> {$status}<br>";
            echo "</div>";

            echo "<h3>Proposed definition</h3>";
            echo "<div class='card' style='padding:12px;white-space:pre-wrap'>{$def}</div>";

            echo "<h3 style='margin-top:12px'>Source</h3>";
            echo "<div class='card' style='padding:12px;white-space:pre-wrap'>".htmlspecialchars($src,ENT_QUOTES,'UTF-8')."</div>";

            echo "<form method='post' action='/index.php?module=admin_reference&op=queue_action' style='display:grid;gap:10px;margin-top:12px'>";
            echo "<input type='hidden' name='csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
            echo "<input type='hidden' name='id' value='{$id}'>";
            echo "<label><b>Reviewer notes</b><br><input name='notes' style='width:100%'></label>";
            echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
            echo "<button class='btn' name='action' value='approve' type='submit'>Approve → Draft Entry</button>";
            echo "<button class='btn2' name='action' value='reject' type='submit'>Reject</button>";
            echo "<button class='btn2' name='action' value='reviewing' type='submit'>Mark Reviewing</button>";
            echo "<a class='btn2' href='/index.php?module=admin_reference&op=queue'>Back</a>";
            echo "</div>";
            echo "</form>";
        });
    }

    private function queueAction(PDO $pdo): void
    {
        Csrf::validateOrDie($_POST['csrf'] ?? '');
        $id = (int)($_POST['id'] ?? 0);
        $action = (string)($_POST['action'] ?? '');
        $notes = trim((string)($_POST['notes'] ?? ''));
        if ($id <= 0) { header('Location: /index.php?module=admin_reference&op=queue'); exit; }

        $qT = self::tn('ref_queue');

        if ($action === 'approve') {
            // Create a draft entry from proposal (human can edit/publish)
            $stmt = $pdo->prepare("SELECT proposed_term, proposed_definition FROM `$qT` WHERE id=:id LIMIT 1");
            $stmt->execute([':id'=>$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($row) {
                $term = (string)$row['proposed_term'];
                $def = (string)$row['proposed_definition'];
                $slug = $this->slugify($term);

                $eT = self::tn('ref_entries');
                $now = date('Y-m-d H:i:s');
                $pdo->prepare("INSERT INTO `$eT` (slug,term,definition,status,curator_note,created_at) VALUES (:s,:t,:d,'draft',:n,:c)")
                    ->execute([':s'=>$slug,':t'=>$term,':d'=>$def,':n'=>$notes,':c'=>$now]);
            }
            $pdo->prepare("UPDATE `$qT` SET status='approved', reviewed_at=NOW(), reviewer=:r, reviewer_notes=:n WHERE id=:id")
                ->execute([':r'=>'admin', ':n'=>$notes, ':id'=>$id]);
            header('Location: /index.php?module=admin_reference');
            exit;
        }

        if ($action === 'reject') {
            $pdo->prepare("UPDATE `$qT` SET status='rejected', reviewed_at=NOW(), reviewer=:r, reviewer_notes=:n WHERE id=:id")
                ->execute([':r'=>'admin', ':n'=>$notes, ':id'=>$id]);
            header('Location: /index.php?module=admin_reference&op=queue');
            exit;
        }

        if ($action === 'reviewing') {
            $pdo->prepare("UPDATE `$qT` SET status='reviewing', reviewer_notes=:n WHERE id=:id")
                ->execute([':n'=>$notes, ':id'=>$id]);
            \NukeCE\Security\NukeSecurity::log('reference.queue.reviewing', ['queue_id'=>$id, 'by'=>$reviewer]);
            header('Location: /index.php?module=admin_reference&op=queue_view&id=' . $id);
            exit;
        }

        header('Location: /index.php?module=admin_reference&op=queue');
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
