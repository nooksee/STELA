<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Downloads;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Layout;
use NukeCE\Core\Model;
use NukeCE\Core\Entitlements;
use NukeCE\Core\Labels;
use NukeCE\Security\AuthGate;
use PDO;

final class DownloadsModule extends Model implements ModuleInterface
{
    public function getName(): string { return 'downloads'; }

    public function handle(array $params): void
    {
        $q = trim((string)($_GET['q'] ?? ''));
        $cat = trim((string)($_GET['cat'] ?? ''));

        Layout::header('Downloads');

        echo '<h1>Downloads</h1>';
        echo '<p class="muted">Files, resources, and first-party add-ons.</p>';

        $pdo = $this->getConnection();
        $this->ensureSchema($pdo);

        echo '<form method="get" class="nukece-card" style="margin:12px 0">';
        echo '<input type="hidden" name="module" value="downloads">';
        echo '<div style="display:flex;gap:10px;flex-wrap:wrap;align-items:end">';
        echo '<div><label>Search<br><input name="q" value="'.htmlspecialchars($q,ENT_QUOTES,'UTF-8').'" style="width:320px"></label></div>';
        echo '<div><label>Category<br><input name="cat" value="'.htmlspecialchars($cat,ENT_QUOTES,'UTF-8').'" placeholder="e.g. themes"></label></div>';
        echo '<div><button class="nukece-btn nukece-btn-primary" type="submit">Filter</button></div>';
        echo '</div>';
        echo '</form>';

        $this->renderFiles($pdo, $q, $cat);
        $this->renderAddons();

        Layout::footer();
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
            KEY idx_cat (category),
            KEY idx_title (title(40))
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    }

    private function renderFiles(PDO $pdo, string $q, string $cat): void
    {
        $where = [];
        $args = [];

        if ($q !== '') {
            $where[] = "(title LIKE ? OR description LIKE ? OR category LIKE ?)";
            $args[] = "%$q%"; $args[] = "%$q%"; $args[] = "%$q%";
        }
        if ($cat !== '') {
            $where[] = "category = ?";
            $args[] = $cat;
        }

        $sql = "SELECT id,title,slug,category,description,license,version,file_path,external_url,required_tier,updated_at
                FROM downloads_items";
        if ($where) $sql .= " WHERE " . implode(" AND ", $where);
        $sql .= " ORDER BY updated_at DESC, id DESC";

        $st = $pdo->prepare($sql);
        $st->execute($args);
        $items = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];

        echo '<h2>Files</h2>';
        if (!$items) {
            echo '<div class="nukece-card"><p>No downloads yet.</p></div>';
            return;
        }

        echo '<div class="nukece-cards">';
        foreach ($items as $it) {
            $title = htmlspecialchars((string)$it['title'], ENT_QUOTES, 'UTF-8');
            $desc  = htmlspecialchars((string)($it['description'] ?? ''), ENT_QUOTES, 'UTF-8');
            $cat   = htmlspecialchars((string)($it['category'] ?? ''), ENT_QUOTES, 'UTF-8');
            $lic   = htmlspecialchars((string)($it['license'] ?? ''), ENT_QUOTES, 'UTF-8');
            $ver   = htmlspecialchars((string)($it['version'] ?? ''), ENT_QUOTES, 'UTF-8');
            $tier  = (string)($it['required_tier'] ?? '');
            $href  = '/index.php?module=downloads&op=download&slug=' . rawurlencode((string)$it['slug']);

            echo '<div class="nukece-card">';
            echo '<h3><a href="'.$href.'">'.$title.'</a></h3>';
            if ($cat !== '') echo '<p><small class="nukece-pill">'.$cat.'</small></p>';
            if ($desc !== '') echo '<p>'.nl2br($desc).'</p>';
            $meta = [];
            if ($ver) $meta[] = "v$ver";
            if ($lic) $meta[] = $lic;
            if ($tier !== '') {
                $label = Labels::get('memberships','Members');
                $meta[] = "Requires $label: $tier";
            }
            if ($meta) echo '<p><small>'.htmlspecialchars(implode(' · ', $meta), ENT_QUOTES, 'UTF-8').'</small></p>';
            echo '</div>';
        }
        echo '</div>';

        // download endpoint
        $op = (string)($_GET['op'] ?? '');
        if ($op === 'download') {
            $slug = preg_replace('/[^a-z0-9_-]/i','', (string)($_GET['slug'] ?? ''));
            $st = $pdo->prepare("SELECT title,file_path,external_url,required_tier FROM downloads_items WHERE slug=? LIMIT 1");
            $st->execute([$slug]);
            $row = $st->fetch(PDO::FETCH_ASSOC);
            if (!$row) return;

            $tier = (string)($row['required_tier'] ?? '');
            if ($tier !== '' && !Entitlements::currentUserHasTier($tier)) {
                Entitlements::renderRequires($tier, 'Ask an admin for access or install the Memberships add-on.');
                return;
            }

            $ext = (string)($row['external_url'] ?? '');
            if ($ext !== '') {
                header('Location: ' . $ext);
                exit;
            }
            $fp = (string)($row['file_path'] ?? '');
            $abs = NUKECE_ROOT . '/' . ltrim($fp, '/');
            if (!is_file($abs)) {
                echo '<div class="nukece-card"><p>File not found.</p></div>';
                return;
            }
            $name = basename($abs);
            header('Content-Type: application/octet-stream');
            header('Content-Disposition: attachment; filename="'.$name.'"');
            header('Content-Length: ' . filesize($abs));
            readfile($abs);
            exit;
        }
    }

    private function renderAddons(): void
    {
        $addonsDir = NUKECE_ROOT . '/addons/modules';
        if (!is_dir($addonsDir)) return;

        echo '<h2>Add-ons</h2>';
        echo '<p class="muted">Optional features you can install after core.</p>';

        $manifestPath = $addonsDir . '/manifest.json';
        $manifest = [];
        if (is_file($manifestPath)) {
            $raw = (string)@file_get_contents($manifestPath);
            $j = json_decode($raw, true);
            if (is_array($j)) $manifest = $j;
        }

        $zips = glob($addonsDir . '/*.zip') ?: [];
        if (!$zips) {
            echo '<div class="nukece-card"><p>No add-ons packaged.</p></div>';
            return;
        }

        $username = AuthGate::currentUsername() ?: '';
        echo '<div class="nukece-cards">';
        foreach ($zips as $path) {
            $base = basename($path);
            $meta = $manifest[$base] ?? [];
            $title = (string)($meta['title'] ?? $base);
            $desc  = (string)($meta['description'] ?? '');
            $tier  = (string)($meta['required_tier'] ?? '');

            $allowed = true;
            if ($tier !== '') {
                $allowed = Entitlements::currentUserHasTier($tier);
            }

            $sha = hash_file('sha256', $path);
            $size = (int)@filesize($path);
            $href = '/addons/modules/' . rawurlencode($base);

            echo '<div class="nukece-card">';
            echo '<h3>' . htmlspecialchars($title, ENT_QUOTES, 'UTF-8') . '</h3>';
            if ($desc) echo '<p>' . nl2br(htmlspecialchars($desc, ENT_QUOTES, 'UTF-8')) . '</p>';
            echo '<p><small>File: ' . htmlspecialchars($base, ENT_QUOTES, 'UTF-8') . ' · ' . number_format($size/1024, 1) . " KB · SHA-256: <code>$sha</code></small></p>";

            if ($allowed) {
                echo '<p><a class="nukece-btn nukece-btn-primary" href="'.$href.'">Download</a></p>';
            } else {
                $label = Labels::get('memberships', 'Members');
                echo '<p><span class="nukece-pill">Requires '.$label.'</span></p>';
            }
            echo '</div>';
        }
        echo '</div>';

        echo '<div class="nukece-card"><h3>Install</h3><ol>';
        echo '<li>Download the add-on zip</li>';
        echo '<li>Unzip locally</li>';
        echo '<li>Copy <code>modules/*</code> into your site <code>/modules</code></li>';
        echo '<li>Copy any included folders (like <code>/games</code>) into your site root</li>';
        echo '<li>Visit its Admin panel once to initialize tables</li>';
        echo '</ol></div>';
    }
}
