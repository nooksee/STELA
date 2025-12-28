<?php
/**
 * PHP-Nuke CE (Community Edition)
 * Links controller (public).
 */

declare(strict_types=1);

namespace NukeCE\Links;

use NukeCE\Ai\AiClient;

final class LinksController
{
    private LinksDb $db;
    private string $prefix;

    public function __construct()
    {
        global $db, $prefix;
        $this->prefix = is_string($prefix) ? $prefix . '_' : 'nuke_';
        $this->db = new LinksDb($db, $this->prefix);
        // AI shim (optional)
        $aiPath = dirname(__DIR__, 3) . '/includes/Ai/AiClient.php';
        if (is_file($aiPath)) {
            require_once $aiPath;
        }
    }

    public function dispatch(string $op): void
    {
        switch ($op) {
            case 'category':
                $this->category((int)($_GET['cid'] ?? 0));
                return;
            case 'visit':
                $this->visit((int)($_GET['lid'] ?? 0));
                return;
            case 'submit':
                $this->submit();
                return;
            default:
                $this->index();
        }
    }

    private function header(string $title): void
    {
        if (function_exists('include_once')) {
            // nothing
        }
        if (function_exists('include')) {
            // nothing
        }
        if (function_exists('OpenTable')) {
            include_once dirname(__DIR__, 3) . '/header.php';
            OpenTable();
            echo '<h1>' . htmlspecialchars($title) . '</h1>';
        }
    }

    private function footer(): void
    {
        if (function_exists('CloseTable')) {
            CloseTable();
            include_once dirname(__DIR__, 3) . '/footer.php';
        }
    }

    private function index(): void
    {
        $this->header('Links');
        $cats = $this->db->all('SELECT cid, title, description FROM ' . $this->db->t('links_categories') . ' ORDER BY title');
        echo '<div class="links-cats">';
        if (!$cats) {
            echo '<p>No categories yet.</p>';
        } else {
            echo '<ul>';
            foreach ($cats as $c) {
                $cid = (int)$c['cid'];
                echo '<li><a href="modules.php?name=Links&amp;op=category&amp;cid=' . $cid . '">' . htmlspecialchars($c['title']) . '</a></li>';
            }
            echo '</ul>';
        }
        echo '</div>';
        echo '<p><a href="modules.php?name=Links&amp;op=submit">Submit a link</a></p>';
        $this->footer();
    }

    private function category(int $cid): void
    {
        $cat = $this->db->one('SELECT cid, title, description FROM ' . $this->db->t('links_categories') . ' WHERE cid=' . $cid);
        $this->header($cat ? $cat['title'] : 'Links');
        if (!$cat) {
            echo '<p>Category not found.</p>';
            $this->footer();
            return;
        }
        if (!empty($cat['description'])) {
            echo '<p>' . nl2br(htmlspecialchars($cat['description'])) . '</p>';
        }
        $links = $this->db->all("SELECT lid, url, title, description, hits FROM " . $this->db->t('links') . " WHERE cid={$cid} AND status='approved' ORDER BY created_at DESC");
        if (!$links) {
            echo '<p>No links yet.</p>';
        } else {
            echo '<ul class="links-list">';
            foreach ($links as $l) {
                $lid = (int)$l['lid'];
                echo '<li>';
                echo '<a href="modules.php?name=Links&amp;op=visit&amp;lid=' . $lid . '">' . htmlspecialchars($l['title']) . '</a>';
                echo ' <small>(' . (int)$l['hits'] . ')</small>';
                if (!empty($l['description'])) {
                    echo '<div class="links-desc">' . nl2br(htmlspecialchars($l['description'])) . '</div>';
                }
                echo '</li>';
            }
            echo '</ul>';
        }
        echo '<p><a href="modules.php?name=Links&amp;op=submit&amp;cid=' . $cid . '">Submit to this category</a></p>';
        $this->footer();
    }

    private function visit(int $lid): void
    {
        $link = $this->db->one('SELECT lid, url FROM ' . $this->db->t('links') . ' WHERE lid=' . $lid . " AND status='approved'");
        if (!$link) {
            $this->header('Links');
            echo '<p>Link not found.</p>';
            $this->footer();
            return;
        }
        $this->db->query('UPDATE ' . $this->db->t('links') . ' SET hits = hits + 1 WHERE lid=' . $lid);
        header('Location: ' . $link['url'], true, 302);
        exit;
    }

    private function submit(): void
    {
        $this->header('Submit a Link');
        $cid = (int)($_GET['cid'] ?? 0);
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $cid = (int)($_POST['cid'] ?? 0);
            $url = trim((string)($_POST['url'] ?? ''));
            $title = trim((string)($_POST['title'] ?? ''));
            $desc = trim((string)($_POST['description'] ?? ''));
            if ($cid < 1 || $url === '' || $title === '') {
                echo '<p><strong>Missing required fields.</strong></p>';
            } else {
                global $user;
                $uid = 0;
                if (is_array($user) && isset($user[0])) {
                    $uid = (int)$user[0];
                }
                $sql = sprintf(
                    "INSERT INTO %s (cid,url,title,description,submitter_uid,status) VALUES (%d,'%s','%s','%s',%d,'pending')",
                    $this->db->t('links'),
                    $cid,
                    $this->db->escape($url),
                    $this->db->escape($title),
                    $this->db->escape($desc),
                    $uid
                );
                $this->db->query($sql);
                echo '<p>Thanks! Your link is awaiting approval.</p>';
                $this->footer();
                return;
            }
        }

        $cats = $this->db->all('SELECT cid, title FROM ' . $this->db->t('links_categories') . ' ORDER BY title');
        echo '<form method="post" action="modules.php?name=Links&amp;op=submit">';
        echo '<label>Category</label><br>';
        echo '<select name="cid">';
        echo '<option value="0">-- choose --</option>';
        foreach ($cats as $c) {
            $sel = ((int)$c['cid'] === $cid) ? ' selected' : '';
            echo '<option value="' . (int)$c['cid'] . '"' . $sel . '>' . htmlspecialchars($c['title']) . '</option>';
        }
        echo '</select><br><br>';
        echo '<label>URL *</label><br><input type="url" name="url" size="60" required><br><br>';
        echo '<label>Title *</label><br><input type="text" name="title" size="60" required><br><br>';
        echo '<label>Description</label><br><textarea name="description" cols="60" rows="5"></textarea><br><br>';
        echo '<button type="submit">Submit</button>';
        echo '</form>';

        $this->footer();
    }
}
