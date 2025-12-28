<?php
/**
 * PHP-Nuke CE (Community Edition)
 * Admin Links (moderation + health checks)
 */

define('ADMIN_FILE', true);

$root = dirname(__DIR__, 2);
if (is_file($root . '/admin.php')) {
    require_once $root . '/admin.php';
}

require_once dirname(__DIR__) . '/Links/lib/LinksDb.php';
$aiPath = $root . '/includes/Ai/AiClient.php';
if (is_file($aiPath)) {
    require_once $aiPath;
}

$op = $_GET['op'] ?? 'dashboard';

global $db, $prefix;
$pref = is_string($prefix) ? $prefix . '_' : 'nuke_';
$dbh = new \NukeCE\Links\LinksDb($db, $pref);

// AdminUi compatibility
if (!class_exists('AdminUi') && is_file($root . '/src/Core/AdminUi.php')) {
    require_once $root . '/src/Core/AdminUi.php';
}

function links_admin_head(string $title, string $subtitle = ''): void {
    if (class_exists('AdminUi')) {
        echo AdminUi::pageHead($title, $subtitle, 'links');
        return;
    }
    echo '<h1>' . htmlspecialchars($title) . '</h1>';
    if ($subtitle) echo '<p>' . htmlspecialchars($subtitle) . '</p>';
}

function links_notice(string $type, string $msg): void {
    if (class_exists('AdminUi')) {
        echo AdminUi::notice($type, $msg);
        return;
    }
    echo '<div class="' . htmlspecialchars($type) . '">' . htmlspecialchars($msg) . '</div>';
}

// Basic admin gate (best-effort)
if (function_exists('is_admin') && !is_admin()) {
    die('Access denied');
}

switch ($op) {
    case 'approve':
        $lid = (int)($_GET['lid'] ?? 0);
        if ($lid > 0) {
            $dbh->query('UPDATE ' . $dbh->t('links') . " SET status='approved', updated_at=NOW() WHERE lid={$lid}");
            links_notice('success', 'Approved.');
        }
        header('Location: ' . ($root ? 'admin.php?op=links_queue' : ''));
        exit;

    case 'reject':
        $lid = (int)($_GET['lid'] ?? 0);
        if ($lid > 0) {
            $dbh->query('UPDATE ' . $dbh->t('links') . " SET status='rejected', updated_at=NOW() WHERE lid={$lid}");
            links_notice('success', 'Rejected.');
        }
        header('Location: admin.php?op=links_queue');
        exit;

    case 'ai_preview':
        header('Content-Type: application/json; charset=utf-8');
        $lid = (int)($_GET['lid'] ?? 0);
        $row = $dbh->one('SELECT url FROM ' . $dbh->t('links') . ' WHERE lid=' . $lid);
        if (!$row || empty($row['url'])) {
            echo json_encode(['ok' => false, 'error' => 'Not found']);
            exit;
        }
        $res = \NukeCE\Ai\AiClient::previewUrl((string)$row['url']);
        echo json_encode(['ok' => (bool)$res, 'data' => $res]);
        exit;

    case 'check_links':
        links_admin_head('Links', 'Health check');
        $rows = $dbh->all("SELECT lid, url FROM " . $dbh->t('links') . " WHERE status='approved' ORDER BY last_checked_at IS NULL DESC, last_checked_at ASC LIMIT 50");
        $checked = 0;
        foreach ($rows as $r) {
            $lid = (int)$r['lid'];
            $url = (string)$r['url'];
            $health = 'unknown';
            $code = 0;
            $ctx = stream_context_create(['http' => ['method' => 'HEAD', 'timeout' => 6, 'ignore_errors' => true, 'follow_location' => 0]]);
            $headers = @get_headers($url, 1, $ctx);
            if (is_array($headers) && isset($headers[0])) {
                if (preg_match('/\s(\d{3})\s/', (string)$headers[0], $m)) {
                    $code = (int)$m[1];
                }
            }
            if ($code >= 200 && $code < 300) $health = 'ok';
            elseif ($code >= 300 && $code < 400) $health = 'redirect';
            elseif ($code >= 400) $health = 'broken';
            $dbh->query("UPDATE " . $dbh->t('links') . " SET health='{$health}', last_checked_at=NOW() WHERE lid={$lid}");
            $checked++;
        }
        links_notice('success', "Checked {$checked} links.");
        echo '<p><a href="admin.php?op=links_dashboard">Back</a></p>';
        break;

    case 'links_queue':
    case 'queue':
        links_admin_head('Links', 'Moderation queue');
        $pending = $dbh->all("SELECT lid, cid, url, title, description, created_at FROM " . $dbh->t('links') . " WHERE status='pending' ORDER BY created_at ASC");
        if (class_exists('AdminUi')) {
            echo AdminUi::group('Pending submissions', function () use ($pending) {
                if (!$pending) {
                    echo '<p>No pending submissions.</p>';
                    return;
                }
                echo '<table class="adminui-table"><thead><tr><th>Title</th><th>URL</th><th>Actions</th></tr></thead><tbody>';
                foreach ($pending as $p) {
                    $lid = (int)$p['lid'];
                    echo '<tr>';
                    echo '<td>' . htmlspecialchars($p['title']) . '</td>';
                    echo '<td><a href="' . htmlspecialchars($p['url']) . '" target="_blank" rel="noopener">' . htmlspecialchars($p['url']) . '</a></td>';
                    echo '<td>';
                    echo '<a class="adminui-btn" href="admin.php?op=approve&lid=' . $lid . '">Approve</a> ';
                    echo '<a class="adminui-btn" href="admin.php?op=reject&lid=' . $lid . '">Reject</a> ';
                    if (\NukeCE\Ai\AiClient::enabled()) {
                        echo '<button class="adminui-btn" type="button" onclick="linksAiPreview(' . $lid . ')">AI Preview</button>';
                    }
                    echo '</td>';
                    echo '</tr>';
                }
                echo '</tbody></table>';
                if (\NukeCE\Ai\AiClient::enabled()) {
                    echo '<div id="links-ai-preview" class="adminui-help" style="display:none;"></div>';
                    echo '<script>
                    async function linksAiPreview(lid){
                      const el=document.getElementById("links-ai-preview");
                      el.style.display="block";
                      el.textContent="Loading AI preview...";
                      const r=await fetch("admin.php?op=ai_preview&lid="+lid);
                      const j=await r.json();
                      if(!j.ok){ el.textContent=j.error||"No preview"; return; }
                      const s=j.data.summary||"";
                      const tags=(j.data.tags||[]).join(", ");
                      el.innerHTML="<strong>Summary:</strong> "+escapeHtml(s)+"<br><strong>Tags:</strong> "+escapeHtml(tags);
                    }
                    function escapeHtml(t){return (t||"").replace(/[&<>\"']/g, c=>({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c]));}
                    </script>';
                }
            });
        } else {
            echo '<p>AdminUi not found; please update admin UI.</p>';
        }
        break;

    case 'links_dashboard':
    case 'dashboard':
    default:
        links_admin_head('Links', 'Curated external resources (classic Web Links compatible)');
        if (class_exists('AdminUi')) {
            echo AdminUi::group('Actions', function () {
                echo '<p><a class="adminui-btn" href="admin.php?op=links_queue">Moderation queue</a> ';
                echo '<a class="adminui-btn" href="admin.php?op=check_links">Run health check</a></p>';
                echo '<div class="adminui-help">AI assist is <em>assist-only</em>: preview + suggested tags. Humans approve.</div>';
            });
        }
}

