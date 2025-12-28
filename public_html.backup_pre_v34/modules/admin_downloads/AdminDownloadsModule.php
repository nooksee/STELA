<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\AdminDownloads;

use NukeCE\Core\AdminLayout;
use NukeCE\Core\Model;
use NukeCE\Security\AuthGate;
use NukeCE\Security\Csrf;
use NukeCE\Security\NukeSecurity;
use NukeCE\AI\AiService;
use NukeCE\Security\PackageScanner;
use PDO;

final class AdminDownloadsModule extends Model
{
    public function getName(): string { return 'admin_downloads'; }

    public function handle(array $params): void
    {
        AuthGate::requireAdmin();
        $pdo = $this->getConnection();
        $this->ensureSchema($pdo);

        $ok = '';
        $err = '';

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $token = $_POST['_csrf'] ?? null;
            if (!Csrf::validate(is_string($token) ? $token : null)) {
                $err = 'CSRF validation failed.';
            } else {
                $action = (string)($_POST['action'] ?? '');
                if ($action === 'save_item') {
                    $id = (int)($_POST['id'] ?? 0);
                    $title = trim((string)($_POST['title'] ?? ''));
                    $slug  = trim((string)($_POST['slug'] ?? ''));
                    $cat   = trim((string)($_POST['category'] ?? ''));
                    $desc  = trim((string)($_POST['description'] ?? ''));
                    $lic   = trim((string)($_POST['license'] ?? ''));
                    $ver   = trim((string)($_POST['version'] ?? ''));
                    $req   = trim((string)($_POST['required_tier'] ?? ''));
                    $ext   = trim((string)($_POST['external_url'] ?? ''));

                    if ($title === '' || $slug === '') {
                        $err = 'Title and slug are required.';
                    } else {
                        $now = gmdate('Y-m-d H:i:s');
                        if ($id > 0) {
                            $st = $pdo->prepare("UPDATE downloads_items
                                SET title=?, slug=?, category=?, description=?, license=?, version=?, external_url=?, required_tier=?, updated_at=?
                                WHERE id=?");
                            $st->execute([$title,$slug,$cat,$desc,$lic,$ver,$ext,$req,$now,$id]);
                            $ok = 'Saved.';
                            NukeSecurity::log('downloads.item_updated', ['id'=>$id,'slug'=>$slug,'actor'=>AuthGate::adminUsername()]);
                        } else {
                            $st = $pdo->prepare("INSERT INTO downloads_items
                                (title,slug,category,description,license,version,external_url,required_tier,file_path,created_at,updated_at)
                                VALUES (?,?,?,?,?,?,?,?,NULL,?,?)");
                            $st->execute([$title,$slug,$cat,$desc,$lic,$ver,$ext,$req,$now,$now]);
                            $ok = 'Created.';
                            NukeSecurity::log('downloads.item_created', ['slug'=>$slug,'actor'=>AuthGate::adminUsername()]);
                        }
                    }
                } elseif ($action === 'upload_file') {
                    $id = (int)($_POST['id'] ?? 0);
                    if ($id <= 0) {
                        $err = 'Pick an item first.';
                    } elseif (empty($_FILES['file']['tmp_name'])) {
                        $err = 'No file uploaded.';
                    } else {
                        $tmp = (string)$_FILES['file']['tmp_name'];
                        $orig = (string)$_FILES['file']['name'];
                        $safe = preg_replace('/[^a-zA-Z0-9._-]/', '_', $orig);
                        $dir = NUKECE_ROOT . '/files/downloads';
                        if (!is_dir($dir)) @mkdir($dir, 0775, true);
                        $dest = $dir . '/' . $id . '_' . time() . '_' . $safe;
                        if (@move_uploaded_file($tmp, $dest)) {
                            $rel = ltrim(str_replace(NUKECE_ROOT . '/', '', $dest), '/');
                            $st = $pdo->prepare("UPDATE downloads_items SET file_path=?, updated_at=? WHERE id=?");
                            $st->execute([$rel, gmdate('Y-m-d H:i:s'), $id]);
                            $ok = 'Uploaded.';
                            NukeSecurity::log('downloads.file_uploaded', ['id'=>$id,'file'=>$rel,'actor'=>AuthGate::adminUsername()]);
                        } else {
                            $err = 'Upload failed.';
                        }
                    }
} elseif ($action === 'ai_draft') {
    $id = (int)($_POST['id'] ?? 0);
    $ok = $this->runAiDraft($pdo, $id, $err);
} elseif ($action === 'safety_scan') {
    $id = (int)($_POST['id'] ?? 0);
    $ok = $this->runSafetyScan($pdo, $id, $err);
} elseif ($action === 'check_url') {
    $id = (int)($_POST['id'] ?? 0);
    $ok = $this->runLinkCheck($pdo, $id, $err);
}

                } elseif ($action === 'save_manifest') {
                    $addonsDir = NUKECE_ROOT . '/addons/modules';
                    $manifestPath = $addonsDir . '/manifest.json';
                    $text = (string)($_POST['manifest'] ?? '');
                    $j = json_decode($text, true);
                    if (!is_array($j)) {
                        $err = 'Invalid JSON.';
                    } else {
                        if (!is_dir($addonsDir)) @mkdir($addonsDir, 0775, true);
                        file_put_contents($manifestPath, json_encode($j, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE));
                        $ok = 'Manifest saved.';
                        NukeSecurity::log('downloads.manifest_saved', ['actor'=>AuthGate::adminUsername()]);
                    }
                }
            }
        }

        AdminLayout::header('Downloads');

        if ($ok) echo "<div class='ok'>".htmlspecialchars($ok,ENT_QUOTES,'UTF-8')."</div>";
        if ($err) echo "<div class='err'>".htmlspecialchars($err,ENT_QUOTES,'UTF-8')."</div>";

        AdminLayout::cardStart('Create / Edit', 'Modern Downloads manager (files + external links + optional tier gating).');
        echo "<form method='post'>";
        echo Csrf::field();
        echo "<input type='hidden' name='action' value='save_item'>";
        echo "<p><label>ID (blank for new)<br><input name='id' value='' placeholder='0'></label></p>";
        echo "<p><label>Title<br><input name='title' style='width:520px'></label></p>";
        echo "<p><label>Slug<br><input name='slug' style='width:320px' placeholder='e.g. nukegold-remaster'></label></p>";
        echo "<p><label>Category<br><input name='category' placeholder='themes'></label></p>";
        echo "<p><label>Version<br><input name='version' placeholder='1.0.0'></label></p>";
        echo "<p><label>License<br><input name='license' placeholder='GPL-2.0-or-later'></label></p>";
        echo "<p><label>Required tier (optional)<br><input name='required_tier' placeholder='supporter'></label></p>";
        echo "<p><label>External URL (optional)<br><input name='external_url' style='width:520px' placeholder='https://...'></label></p>";
        echo "<p><label>Description<br><textarea name='description' rows='6' style='width:100%'></textarea></label></p>";
        echo "<p><button class='nukece-btn nukece-btn-primary' type='submit'>Save</button></p>";
        echo "</form>";
        AdminLayout::cardEnd();

        $items = $pdo->query("SELECT id,title,slug,category,version,file_path,external_url,required_tier,updated_at
                              FROM downloads_items ORDER BY updated_at DESC, id DESC LIMIT 50")
                     ->fetchAll(PDO::FETCH_ASSOC) ?: [];

        AdminLayout::cardStart('Recent Items', 'Use the ID above to update an existing item.');
        if (!$items) {
            echo '<p>No items yet.</p>';
        } else {
            echo '<table><tr><th>ID</th><th>Title</th><th>Slug</th><th>Cat</th><th>v</th><th>Tier</th><th>File/URL</th><th>Updated</th></tr>';
            foreach ($items as $it) {
                $src = $it['file_path'] ? $it['file_path'] : $it['external_url'];
                echo '<tr>';
                echo '<td>'.(int)$it['id'].'</td>';
                echo '<td>'.htmlspecialchars((string)$it['title'],ENT_QUOTES,'UTF-8').'</td>';
                echo '<td>'.htmlspecialchars((string)$it['slug'],ENT_QUOTES,'UTF-8').'</td>';
                echo '<td>'.htmlspecialchars((string)$it['category'],ENT_QUOTES,'UTF-8').'</td>';
                echo '<td>'.htmlspecialchars((string)$it['version'],ENT_QUOTES,'UTF-8').'</td>';
                echo '<td>'.htmlspecialchars((string)$it['required_tier'],ENT_QUOTES,'UTF-8').'</td>';
                echo '<td><small>'.htmlspecialchars((string)$src,ENT_QUOTES,'UTF-8').'</small></td>';
                echo '<td><small>'.htmlspecialchars((string)$it['updated_at'],ENT_QUOTES,'UTF-8').'</small></td>';
                echo '</tr>';
            }
            echo '</table>';
        }
AdminLayout::cardEnd();

AdminLayout::cardStart('AI Assist', 'Draft metadata, run safety scan, and check external URLs. (Nothing auto-publishes.)');
echo "<p class='muted'>Enable features in Admin → AI → Features: downloads_metadata, downloads_safety_scan, downloads_link_check.</p>";

echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
echo "<form method='post' style='margin:0;display:inline-block'>";
echo Csrf::field();
echo "<input type='hidden' name='action' value='ai_draft'>";
echo "<label>Item ID<br><input name='id' placeholder='e.g. 12' style='width:120px'></label> ";
echo "<button class='nukece-btn nukece-btn-primary' type='submit'>AI Draft</button>";
echo "</form>";

echo "<form method='post' style='margin:0;display:inline-block'>";
echo Csrf::field();
echo "<input type='hidden' name='action' value='safety_scan'>";
echo "<label>Item ID<br><input name='id' placeholder='e.g. 12' style='width:120px'></label> ";
echo "<button class='nukece-btn' type='submit'>Safety Scan</button>";
echo "</form>";

echo "<form method='post' style='margin:0;display:inline-block'>";
echo Csrf::field();
echo "<input type='hidden' name='action' value='check_url'>";
echo "<label>Item ID<br><input name='id' placeholder='e.g. 12' style='width:120px'></label> ";
echo "<button class='nukece-btn' type='submit'>Check URL</button>";
echo "</form>";
echo "</div>";

// display last AI output if present
$last = $this->getLastAiOutput();
if ($last) {
    echo "<hr>";
    echo "<h4>Last AI Output</h4>";
    echo "<pre style='white-space:pre-wrap'>".htmlspecialchars($last,ENT_QUOTES,'UTF-8')."</pre>";
}

AdminLayout::cardEnd();

AdminLayout::cardStart('Upload file'
, 'Attach a file to an existing Download item.');
        echo "<form method='post' enctype='multipart/form-data'>";
        echo Csrf::field();
        echo "<input type='hidden' name='action' value='upload_file'>";
        echo "<p><label>Item ID<br><input name='id' placeholder='e.g. 12'></label></p>";
        echo "<p><input type='file' name='file'></p>";
        echo "<p><button class='nukece-btn nukece-btn-primary' type='submit'>Upload</button></p>";
        echo "</form>";
        AdminLayout::cardEnd();

        // Add-on manifest
        $addonsDir = NUKECE_ROOT . '/addons/modules';
        $manifestPath = $addonsDir . '/manifest.json';
        $raw = is_file($manifestPath) ? (string)file_get_contents($manifestPath) : '{}';

        AdminLayout::cardStart('Add-on manifest', 'Filename → {title, description, required_tier}');
        echo "<form method='post'>";
        echo Csrf::field();
        echo "<input type='hidden' name='action' value='save_manifest'>";
        echo "<textarea name='manifest' rows='16' style='width:100%;font-family:ui-monospace, SFMono-Regular, Menlo, monospace'>"
            . htmlspecialchars($raw, ENT_QUOTES, 'UTF-8')
            . "</textarea>";
        echo "<p><button class='nukece-btn nukece-btn-primary' type='submit'>Save manifest</button></p>";
        echo "</form>";
        AdminLayout::cardEnd();

        AdminLayout::footer();
    }

    private function ensureSchema(PDO $pdo): void
    {
        $pdo->exec("CREATE TABLE IF NOT EXISTS downloads_items (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            title VARCHAR(255) NOT NULL,
            slug VARCHAR(120) NOT NULL,
            category VARCHAR(80) NOT NULL DEFAULT '',
            description MEDIUMTEXT NULL,
            license VARCHAR(120) NOT NULL DEFAULT '',
            version VARCHAR(80) NOT NULL DEFAULT '',
            file_path VARCHAR(512) NULL,
            external_url VARCHAR(512) NULL,
            required_tier VARCHAR(80) NOT NULL DEFAULT '',
            created_at DATETIME NOT NULL,
            updated_at DATETIME NOT NULL,
            PRIMARY KEY (id),
            UNIQUE KEY uq_slug (slug),
            KEY idx_cat (category)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    }
}
