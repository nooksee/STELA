<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\WebLinks;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Layout;
use NukeCE\Core\Model;
use NukeCE\Security\AuthGate;
use PDO;

final class WebLinksModule extends Model implements ModuleInterface
{
    public function getName(): string { return 'weblinks'; }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();
        $this->ensureSchema($pdo);

        $op = (string)($_GET['op'] ?? 'index');
        $q  = trim((string)($_GET['q'] ?? ''));

        Layout::header('Links');

        echo '<h1>Links</h1>';
        echo '<p class="muted">Curated links with context. Built for 2026 attention economy: fewer links, more meaning.</p>';

        echo '<form method="get" class="nukece-card" style="margin:12px 0">';
        echo '<input type="hidden" name="module" value="weblinks">';
        echo '<div style="display:flex;gap:10px;flex-wrap:wrap;align-items:end">';
        echo '<div><label>Search<br><input name="q" value="'.htmlspecialchars($q,ENT_QUOTES,'UTF-8').'" style="width:320px"></label></div>';
        echo '<div><button class="nukece-btn nukece-btn-primary" type="submit">Search</button></div>';
        echo '</div></form>';

        if ($op === 'submit' && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->submit($pdo);
        }

        $this->renderSubmitBox();
        $this->renderList($pdo, $q);

        Layout::footer();
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
            KEY idx_status (status),
            KEY idx_title (title(40))
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    }

    private function renderSubmitBox(): void
    {
        echo '<div class="nukece-card">';
        echo '<h2>Submit a link</h2>';
        echo '<form method="post" action="/index.php?module=weblinks&op=submit">';
        echo '<p><label>URL<br><input name="url" style="width:100%" placeholder="https://..."></label></p>';
        echo '<p><label>Title<br><input name="title" style="width:100%"></label></p>';
        echo '<p><label>Tags (comma-separated)<br><input name="tags" style="width:100%" placeholder="ai, php, community"></label></p>';
        echo '<p><label>Description (why it matters)<br><textarea name="description" rows="5" style="width:100%"></textarea></label></p>';
        echo '<p><button class="nukece-btn nukece-btn-primary" type="submit">Submit</button></p>';
        echo '<p class="muted">Tip: This module is meant to reduce noise. Add context, not just links.</p>';
        echo '</form></div>';
    }

    private function submit(PDO $pdo): void
    {
        $url = trim((string)($_POST['url'] ?? ''));
        $title = trim((string)($_POST['title'] ?? ''));
        $tags = trim((string)($_POST['tags'] ?? ''));
        $desc = trim((string)($_POST['description'] ?? ''));

        if ($url === '' || $title === '') {
            echo '<div class="nukece-card"><p>URL and title required.</p></div>';
            return;
        }

        $user = AuthGate::currentUsername() ?: 'guest';
        $st = $pdo->prepare("INSERT INTO weblinks_items (url,title,description,tags,status,submitted_by,created_at)
                             VALUES (?,?,?,?, 'pending', ?, ?)");
        $st->execute([$url,$title,$desc,$tags,$user,gmdate('Y-m-d H:i:s')]);

        echo '<div class="nukece-card"><p>Submitted. Awaiting approval.</p></div>';
    }

    private function renderList(PDO $pdo, string $q): void
    {
        $where = "status='approved'";
        $args = [];
        if ($q !== '') {
            $where .= " AND (title LIKE ? OR description LIKE ? OR tags LIKE ?)";
            $args = ["%$q%","%$q%","%$q%"];
        }
        $st = $pdo->prepare("SELECT url,title,description,tags,approved_at FROM weblinks_items WHERE $where ORDER BY approved_at DESC, id DESC LIMIT 60");
        $st->execute($args);
        $rows = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];

        echo '<h2>Curated</h2>';
        if (!$rows) {
            echo '<div class="nukece-card"><p>No approved links yet.</p></div>';
            return;
        }

        echo '<div class="nukece-cards">';
        foreach ($rows as $r) {
            $url = htmlspecialchars((string)$r['url'],ENT_QUOTES,'UTF-8');
            $title = htmlspecialchars((string)$r['title'],ENT_QUOTES,'UTF-8');
            $desc = htmlspecialchars((string)($r['description'] ?? ''),ENT_QUOTES,'UTF-8');
            $tags = htmlspecialchars((string)($r['tags'] ?? ''),ENT_QUOTES,'UTF-8');

            echo '<div class="nukece-card">';
            echo '<h3><a href="'.$url.'" target="_blank" rel="noreferrer">'.$title.'</a></h3>';
            if ($tags) echo '<p><small class="nukece-pill">'.$tags.'</small></p>';
            if ($desc) echo '<p>'.nl2br($desc).'</p>';
            echo '</div>';
        }
        echo '</div>';

        echo '<div class="nukece-card"><h3>Why this module exists</h3>';
        echo '<p>Classic Web Links became a graveyard because it collected URLs without context. nukeCE Links requires meaning: tags, description, and curation.</p>';
        echo '</div>';
    }
}
