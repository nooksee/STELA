<?php
/**
 * PHP-Nuke CE
 * Admin Reference (Knowledge Base)
 */
require_once __DIR__ . '/../../mainfile.php';
require_once NUKECE_ROOT . '/includes/admin_ui.php';

use NukeCE\Core\Model;
use NukeCE\AI\AiService;

AdminUi::requireAdmin();
include_once NUKECE_ROOT . '/includes/header.php';

$pdo = Model::pdo();
$pdo->exec("CREATE TABLE IF NOT EXISTS reference_proposals (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  created_at DATETIME NOT NULL,
  created_by VARCHAR(64) NOT NULL DEFAULT 'admin',
  status VARCHAR(16) NOT NULL DEFAULT 'open',
  reviewer VARCHAR(64) NULL,
  reviewed_at DATETIME NULL,
  title VARCHAR(190) NOT NULL DEFAULT '',
  body MEDIUMTEXT NULL,
  citations_json MEDIUMTEXT NULL,
  source_module VARCHAR(64) NOT NULL DEFAULT '',
  source_id VARCHAR(64) NOT NULL DEFAULT '',
  ai_meta_json MEDIUMTEXT NULL,
  rejection_note VARCHAR(255) NULL,
  PRIMARY KEY (id),
  KEY idx_status (status),
  KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

$tab = (string)($_GET['tab'] ?? 'queue');
$msg = '';
$csrf = class_exists('NukeCE\\Security\\Csrf') ? \NukeCE\Security\Csrf::token() : '';

function h(string $s): string { return htmlspecialchars($s, ENT_QUOTES, 'UTF-8'); }

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (class_exists('NukeCE\\Security\\Csrf') && !\NukeCE\Security\Csrf::validate($_POST['_csrf'] ?? null)) {
        $msg = 'Invalid CSRF token.';
    } else {
        $action = (string)($_POST['action'] ?? '');
        if ($tab === 'tools' && $action === 'propose') {
            $src = trim((string)($_POST['src'] ?? ''));
            if ($src === '') {
                $msg = 'Please paste source text.';
            } else {
                $system = "You are a careful curator. Produce a neutral reference entry proposal. Output JSON with keys: title, body (plain text), citations (array of {title,url}). No invention. If unsure, say so in body.";
                $res = AiService::run('reference_proposals', $system, $src, ['actor'=>'admin','source_module'=>'reference','source_id'=>'tools']);
                $title = 'Untitled';
                $body  = $res['text'];
                $cites = [];
                $meta  = json_encode($res['meta'] ?? [], JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES);

                $j = json_decode($res['text'], true);
                if (is_array($j)) {
                    $title = (string)($j['title'] ?? $title);
                    $body  = (string)($j['body'] ?? $body);
                    $cites = (array)($j['citations'] ?? []);
                }

                $st = $pdo->prepare("INSERT INTO reference_proposals (created_at, created_by, status, title, body, citations_json, source_module, source_id, ai_meta_json)
                                     VALUES (?,?,?,?,?,?,?,?,?)");
                $st->execute([gmdate('Y-m-d H:i:s'),'admin','open',$title,$body,json_encode($cites, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES),'manual','', $meta]);

                $msg = 'Proposal created.';
                $tab = 'queue';
            }
        } elseif ($tab === 'queue') {
            $id = (int)($_POST['id'] ?? 0);
            if ($id > 0) {
                if ($action === 'claim') {
                    $st = $pdo->prepare("UPDATE reference_proposals SET status='reviewing', reviewer=? WHERE id=? AND status IN ('open','reviewing')");
                    $st->execute(['admin', $id]);
                    $msg = 'Claimed.';
                } elseif ($action === 'approve') {
                    $st = $pdo->prepare("SELECT * FROM reference_proposals WHERE id=?");
                    $st->execute([$id]);
                    $p = $st->fetch(PDO::FETCH_ASSOC);

                    if ($p) {
                        $pdo->exec("CREATE TABLE IF NOT EXISTS encyclopedia (
                          id INT UNSIGNED NOT NULL AUTO_INCREMENT,
                          term VARCHAR(190) NOT NULL,
                          definition MEDIUMTEXT NULL,
                          PRIMARY KEY (id),
                          UNIQUE KEY uq_term (term)
                        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                        $term = (string)$p['title'];
                        $body = (string)$p['body'];

                        $cites = json_decode((string)($p['citations_json'] ?? '[]'), true);
                        if (is_array($cites) && $cites) {
                            foreach ($cites as $c) {
                                $u = trim((string)($c['url'] ?? ''));
                                $t = trim((string)($c['title'] ?? $u));
                                if ($u !== '') {
                                    $body .= "\n\n[cite:$u|$t]";
                                }
                            }
                        }

                        $st2 = $pdo->prepare("INSERT INTO encyclopedia (term, definition) VALUES (?,?) ON DUPLICATE KEY UPDATE definition=VALUES(definition)");
                        $st2->execute([$term, $body]);

                        $st3 = $pdo->prepare("UPDATE reference_proposals SET status='approved', reviewer=?, reviewed_at=? WHERE id=?");
                        $st3->execute(['admin', gmdate('Y-m-d H:i:s'), $id]);

                        $msg = 'Approved and published.';
                    }
                } elseif ($action === 'reject') {
                    $note = trim((string)($_POST['note'] ?? ''));
                    $st = $pdo->prepare("UPDATE reference_proposals SET status='rejected', reviewer=?, reviewed_at=?, rejection_note=? WHERE id=?");
                    $st->execute(['admin', gmdate('Y-m-d H:i:s'), $note, $id]);
                    $msg = 'Rejected.';
                }
            }
        }
    }
}

AdminUi::header('Reference', [
  '/admin' => 'Dashboard',
  '/admin.php?op=logout' => 'Logout',
]);

AdminUi::groupStart('Reference', 'AI proposes → humans canonize.');
echo AdminUi::button('/index.php?module=admin_reference&tab=queue', 'Proposal Queue', $tab==='queue'?'primary':'secondary') . ' ';
echo AdminUi::button('/index.php?module=admin_reference&tab=tools', 'Generate Proposal', $tab==='tools'?'primary':'secondary');
AdminUi::groupEnd();

if ($msg !== '') {
    AdminUi::groupStart('Message'); echo '<p>'.h($msg).'</p>'; AdminUi::groupEnd();
}

if ($tab === 'tools') {
    AdminUi::groupStart('AI Proposal Tool', 'Paste source text. AI drafts. Humans approve.');
    echo '<p><small>Requires Admin → AI: enable AI + enable “Reference proposals”.</small></p>';
    echo '<form method="post" action="/index.php?module=admin_reference&tab=tools">';
    if ($csrf) echo '<input type="hidden" name="_csrf" value="'.h($csrf).'" />';
    echo '<input type="hidden" name="action" value="propose" />';
    echo '<p><textarea name="src" rows="10" style="width:100%"></textarea></p>';
    echo '<button class="nukece-btn nukece-btn-primary" type="submit">Generate</button>';
    echo '</form>';
    AdminUi::groupEnd();
} else {
    AdminUi::groupStart('Queue', 'Claim → review → approve/reject.');
    $st = $pdo->prepare("SELECT * FROM reference_proposals WHERE status IN ('open','reviewing') ORDER BY id DESC LIMIT 200");
    $st->execute();
    $rows = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
    if (!$rows) {
        echo '<p>No open proposals.</p>';
    } else {
        echo '<table><thead><tr><th>ID</th><th>When</th><th>Title</th><th>Status</th><th>Reviewer</th><th>Actions</th></tr></thead><tbody>';
        foreach ($rows as $r) {
            echo '<tr>';
            echo '<td>'.(int)$r['id'].'</td>';
            echo '<td>'.h((string)$r['created_at']).'</td>';
            echo '<td>'.h((string)$r['title']).'</td>';
            echo '<td>'.h((string)$r['status']).'</td>';
            echo '<td>'.h((string)($r['reviewer'] ?? '')).'</td>';
            echo '<td>';
            echo '<form method="post" action="/index.php?module=admin_reference&tab=queue" style="display:inline">';
            if ($csrf) echo '<input type="hidden" name="_csrf" value="'.h($csrf).'" />';
            echo '<input type="hidden" name="id" value="'.(int)$r['id'].'" />';
            echo '<button class="nukece-btn nukece-btn-secondary" type="submit" name="action" value="claim">Claim</button> ';
            echo '<button class="nukece-btn nukece-btn-primary" type="submit" name="action" value="approve">Approve</button> ';
            echo '<input type="text" name="note" placeholder="Reject note…" />';
            echo '<button class="nukece-btn nukece-btn-danger" type="submit" name="action" value="reject">Reject</button>';
            echo '</form>';
            echo '</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';
    }
    AdminUi::groupEnd();
}

AdminUi::footer();
include_once NUKECE_ROOT . '/includes/footer.php';
