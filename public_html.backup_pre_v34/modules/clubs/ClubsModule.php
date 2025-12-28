<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Clubs;

use NukeCE\Core\Layout;
use NukeCE\Core\Labels;
use NukeCE\Core\Model;
use PDO;

final class ClubsModule extends Model
{
    public function run(): void
    {
        $pdo = $this->getConnection();
        $this->ensureTables($pdo);

        $op = (string)($_GET['op'] ?? 'index');
        $id = (int)($_GET['id'] ?? 0);

        Layout::header(Labels::get('clubs','Clubs'));

        echo '<div class="nukece-clubs">';
        echo '<h1>Clubs</h1>';

        if ($op === 'view' && $id > 0) {
            $this->viewClub($pdo, $id);
        } elseif ($op === 'manage' && $id > 0) {
            $this->manageClub($pdo, $id);
        } elseif ($op === 'create') {
            $this->createClub($pdo);
        } elseif ($op === 'newtopic' && $id > 0) {
            $this->newTopic($pdo, $id);
        } elseif ($op === 'topic' && $id > 0) {
            $topicId = (int)($_GET['topic'] ?? 0);
            $this->viewTopic($pdo, $id, $topicId);
        } elseif ($op === 'download' && $id > 0) {
            $fileId = (int)($_GET['file'] ?? 0);
            $this->download($pdo, $id, $fileId);
        } else {
            $this->index($pdo);
        }

        echo '</div>';
        Layout::footer();
    }

    private function ensureTables(PDO $pdo): void
    {
        $pdo->exec("CREATE TABLE IF NOT EXISTS clubs (
          id INT UNSIGNED NOT NULL AUTO_INCREMENT,
          created_at DATETIME NOT NULL,
          owner_username VARCHAR(64) NOT NULL,
          name VARCHAR(120) NOT NULL,
          slug VARCHAR(140) NOT NULL,
          description MEDIUMTEXT NULL,
          is_private TINYINT(1) NOT NULL DEFAULT 0,
          requires_approval TINYINT(1) NOT NULL DEFAULT 0,
          logo_path VARCHAR(255) NULL,
          PRIMARY KEY (id),
          UNIQUE KEY uq_slug (slug),
          KEY idx_owner (owner_username)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

        $pdo->exec("CREATE TABLE IF NOT EXISTS club_members (
          club_id INT UNSIGNED NOT NULL,
          username VARCHAR(64) NOT NULL,
          role VARCHAR(16) NOT NULL DEFAULT 'member',
          status VARCHAR(16) NOT NULL DEFAULT 'active',
          joined_at DATETIME NOT NULL,
          PRIMARY KEY (club_id, username),
          KEY idx_status (status),
          KEY idx_role (role)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

        $pdo->exec("CREATE TABLE IF NOT EXISTS club_news (
          id INT UNSIGNED NOT NULL AUTO_INCREMENT,
          club_id INT UNSIGNED NOT NULL,
          created_at DATETIME NOT NULL,
          created_by VARCHAR(64) NOT NULL,
          title VARCHAR(190) NOT NULL,
          body MEDIUMTEXT NULL,
          PRIMARY KEY (id),
          KEY idx_club (club_id),
          KEY idx_created (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

        $pdo->exec("CREATE TABLE IF NOT EXISTS club_events (
          id INT UNSIGNED NOT NULL AUTO_INCREMENT,
          club_id INT UNSIGNED NOT NULL,
          starts_at DATETIME NOT NULL,
          title VARCHAR(190) NOT NULL,
          details MEDIUMTEXT NULL,
          PRIMARY KEY (id),
          KEY idx_club (club_id),
          KEY idx_start (starts_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

        $pdo->exec("CREATE TABLE IF NOT EXISTS club_downloads (
          id INT UNSIGNED NOT NULL AUTO_INCREMENT,
          club_id INT UNSIGNED NOT NULL,
          created_at DATETIME NOT NULL,
          created_by VARCHAR(64) NOT NULL,
          title VARCHAR(190) NOT NULL,
          filename VARCHAR(190) NOT NULL,
          stored_path VARCHAR(255) NOT NULL,
          mime VARCHAR(64) NULL,
          size_bytes INT UNSIGNED NOT NULL DEFAULT 0,
          PRIMARY KEY (id),
          KEY idx_club (club_id),
          KEY idx_created (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

        $pdo->exec("CREATE TABLE IF NOT EXISTS club_forum_topics (
          id INT UNSIGNED NOT NULL AUTO_INCREMENT,
          club_id INT UNSIGNED NOT NULL,
          created_at DATETIME NOT NULL,
          created_by VARCHAR(64) NOT NULL,
          title VARCHAR(190) NOT NULL,
          PRIMARY KEY (id),
          KEY idx_club (club_id),
          KEY idx_created (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

        $pdo->exec("CREATE TABLE IF NOT EXISTS club_forum_posts (
          id INT UNSIGNED NOT NULL AUTO_INCREMENT,
          topic_id INT UNSIGNED NOT NULL,
          created_at DATETIME NOT NULL,
          created_by VARCHAR(64) NOT NULL,
          body MEDIUMTEXT NULL,
          PRIMARY KEY (id),
          KEY idx_topic (topic_id),
          KEY idx_created (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    }

    private function currentUser(): string
    {
        if (class_exists('AuthGate')) {
            $u = AuthGate::currentUsername();
            if (is_string($u) && $u !== '') return $u;
        }
        return 'guest';
    }

    private function membership(PDO $pdo, int $clubId, string $user): ?array
    {
        $st = $pdo->prepare("SELECT * FROM club_members WHERE club_id=? AND username=?");
        $st->execute([$clubId, $user]);
        $r = $st->fetch(PDO::FETCH_ASSOC);
        return $r ?: null;
    }

    private function canView(PDO $pdo, array $club): bool
    {
        if ((int)$club['is_private'] === 0) return true;
        $m = $this->membership($pdo, (int)$club['id'], $this->currentUser());
        return $m && $m['status'] === 'active';
    }

    
private function memberCount(PDO $pdo, int $clubId): int
{
    $st = $pdo->prepare("SELECT COUNT(*) FROM club_members WHERE club_id=? AND status='active'");
    $st->execute([$clubId]);
    return (int)$st->fetchColumn();
}

    private function canManage(PDO $pdo, int $clubId): bool
    {
        $m = $this->membership($pdo, $clubId, $this->currentUser());
        return $m && $m['status']==='active' && in_array($m['role'], ['admin','moderator'], true);
    }

    private function index(PDO $pdo): void
    {
        echo '<p>Clubs are miniature communities: membership + localized tools.</p>';
        echo '<p><a href="/index.php?module=clubs&op=create">Create a club</a></p>';

        $st = $pdo->query("SELECT id,name,is_private FROM clubs ORDER BY id DESC LIMIT 100");
        $rows = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
        if (!$rows) { echo '<p>No clubs yet.</p>'; return; }

        echo '<ul>';
        foreach ($rows as $c) {
            $name = htmlspecialchars((string)$c['name'], ENT_QUOTES, 'UTF-8');
            $priv = ((int)$c['is_private']===1) ? ' (private)' : '';
            echo '<li><a href="/index.php?module=clubs&op=view&id='.(int)$c['id'].'">'.$name.'</a>'.$priv.'</li>';
        }
        echo '</ul>';
    }

    private function createClub(PDO $pdo): void
    {
        $user = $this->currentUser();
        if ($user === 'guest') { echo '<p>You must be logged in to create a club.</p>'; return; }

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $name = trim((string)($_POST['name'] ?? ''));
            $desc = trim((string)($_POST['description'] ?? ''));
            $priv = !empty($_POST['is_private']) ? 1 : 0;
            $appr = !empty($_POST['requires_approval']) ? 1 : 0;
            $slug = strtolower(preg_replace('/[^a-z0-9]+/i','-', $name));
            $slug = trim($slug, '-');

            if ($name !== '' && $slug !== '') {
                $st = $pdo->prepare("INSERT INTO clubs (created_at, owner_username, name, slug, description, is_private, requires_approval)
                                     VALUES (?,?,?,?,?,?,?)");
                $st->execute([gmdate('Y-m-d H:i:s'), $user, $name, $slug, $desc, $priv, $appr]);
                $id = (int)$pdo->lastInsertId();

                $st2 = $pdo->prepare("INSERT INTO club_members (club_id, username, role, status, joined_at) VALUES (?,?,?,?,?)");
                $st2->execute([$id, $user, 'admin', 'active', gmdate('Y-m-d H:i:s')]);

                echo '<p>Club created. <a href="/index.php?module=clubs&op=view&id='.$id.'">Go to club</a></p>';
                return;
            }
            echo '<p>Please provide a name.</p>';
        }

        echo '<h2>Create a Club</h2>';
        echo '<form method="post">';
        echo '<p><label>Name<br><input type="text" name="name" /></label></p>';
        echo '<p><label>Description<br><textarea name="description" rows="6" style="width:100%"></textarea></label></p>';
        echo '<p><label><input type="checkbox" name="is_private" value="1"> Private</label></p>';
        echo '<p><label><input type="checkbox" name="requires_approval" value="1"> Requires approval</label></p>';
        echo '<p><button type="submit">Create</button></p>';
        echo '</form>';
    }

    private function viewClub(PDO $pdo, int $id): void
    {
        $st = $pdo->prepare("SELECT * FROM clubs WHERE id=?");
        $st->execute([$id]);
        $club = $st->fetch(PDO::FETCH_ASSOC);
        if (!$club) { echo '<p>Club not found.</p>'; return; }

        if (!$this->canView($pdo, $club)) {
            echo '<p>This club is private. Join to view.</p>';
            $this->joinUI($pdo, $club);
            return;
        }

        $name = htmlspecialchars((string)$club['name'], ENT_QUOTES, 'UTF-8');
        echo '<h2>'.$name.'</h2>'; 
        $logo = (string)($club['logo_path'] ?? '');
        if ($logo !== '') {
            $src = htmlspecialchars($logo, ENT_QUOTES, 'UTF-8');
            echo '<p><img src="/'.$src.'" alt="Club logo" style="max-width:160px;max-height:160px;border-radius:10px;" /></p>';
        }
        echo '<p><small>Members: '.$this->memberCount($pdo, $id).'</small></p>';
        echo '<p>'.nl2br(htmlspecialchars((string)($club['description'] ?? ''), ENT_QUOTES, 'UTF-8')).'</p>';

        $this->joinUI($pdo, $club);

        if ($this->canManage($pdo, $id)) {
            echo '<p><a href="/index.php?module=clubs&op=manage&id='.$id.'">Club Control Panel</a></p>';
        }

        echo '<h3>Club News</h3>';
        $st = $pdo->prepare("SELECT title,created_at FROM club_news WHERE club_id=? ORDER BY id DESC LIMIT 10");
        $st->execute([$id]);
        $news = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
        if (!$news) echo '<p>No news yet.</p>';
        else {
            echo '<ul>';
            foreach ($news as $n) {
                echo '<li>'.htmlspecialchars((string)$n['created_at']).' — '.htmlspecialchars((string)$n['title'], ENT_QUOTES, 'UTF-8').'</li>';
            }
            echo '</ul>';
        }

        echo '<h3>Events</h3>';
        $st = $pdo->prepare("SELECT starts_at,title FROM club_events WHERE club_id=? ORDER BY starts_at ASC LIMIT 10");
        $st->execute([$id]);
        $ev = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
        if (!$ev) echo '<p>No upcoming events.</p>';
        else {
            echo '<ul>';
            foreach ($ev as $e) {
                echo '<li>'.htmlspecialchars((string)$e['starts_at']).' — '.htmlspecialchars((string)$e['title'], ENT_QUOTES, 'UTF-8').'</li>';
            }
            echo '</ul>';
        }

        echo '<h3>Downloads</h3>';
        $st = $pdo->prepare("SELECT id,title,size_bytes FROM club_downloads WHERE club_id=? ORDER BY id DESC LIMIT 20");
        $st->execute([$id]);
        $dl = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
        if (!$dl) echo '<p>No files yet.</p>';
        else {
            echo '<ul>';
            foreach ($dl as $d) {
                $href = '/index.php?module=clubs&op=download&id='.(int)$id.'&file='.(int)$d['id'];
                echo '<li><a href="'.$href.'">'.htmlspecialchars((string)$d['title'], ENT_QUOTES, 'UTF-8').'</a> ('.(int)$d['size_bytes'].' bytes)</li>';
            }
            echo '</ul>';
        }

        echo '<h3>Discussion</h3>';
        $st = $pdo->prepare("SELECT id,title FROM club_forum_topics WHERE club_id=? ORDER BY id DESC LIMIT 20");
        $st->execute([$id]);
        $topics = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
        echo '<p><a href="/index.php?module=clubs&op=newtopic&id='.$id.'">New topic</a></p>';
        if (!$topics) echo '<p>No topics yet.</p>';
        else {
            echo '<ul>';
            foreach ($topics as $t) {
                echo '<li><a href="/index.php?module=clubs&op=topic&id='.(int)$id.'&topic='.(int)$t['id'].'">'.
                    htmlspecialchars((string)$t['title'], ENT_QUOTES, 'UTF-8').'</a></li>';
            }
            echo '</ul>';
        }
    }

    private function joinUI(PDO $pdo, array $club): void
    {
        $user = $this->currentUser();
        if ($user === 'guest') { echo '<p><em>Log in to join this club.</em></p>'; return; }

        $m = $this->membership($pdo, (int)$club['id'], $user);
        if ($m) {
            echo '<p><strong>Membership:</strong> '.htmlspecialchars((string)$m['status']).' ('.htmlspecialchars((string)$m['role']).')</p>';
            return;
        }

        $requires = ((int)$club['requires_approval']===1);
        $status = $requires ? 'pending' : 'active';

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && (string)($_POST['join_club'] ?? '') === '1') {
            $st = $pdo->prepare("INSERT INTO club_members (club_id, username, role, status, joined_at) VALUES (?,?,?,?,?)");
            $st->execute([(int)$club['id'], $user, 'member', $status, gmdate('Y-m-d H:i:s')]);
            echo '<p>'.($requires ? 'Request submitted.' : 'Joined!').'</p>';
            return;
        }

        echo '<form method="post">';
        echo '<input type="hidden" name="join_club" value="1" />';
        echo '<button type="submit">'.($requires ? 'Request membership' : 'Join club').'</button>';
        echo '</form>';
    }

    private function manageClub(PDO $pdo, int $id): void
    {
        $st = $pdo->prepare("SELECT * FROM clubs WHERE id=?");
        $st->execute([$id]);
        $club = $st->fetch(PDO::FETCH_ASSOC);
        if (!$club) { echo '<p>Club not found.</p>'; return; }
        if (!$this->canManage($pdo, $id)) { echo '<p>No permission.</p>'; return; }

        echo '<h2>Club Control Panel</h2>';
        echo '<p><a href="/index.php?module=clubs&op=view&id='.$id.'">Back</a></p>';

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $act = (string)($_POST['act'] ?? '');
            $u = (string)($_POST['user'] ?? '');
            if ($act === 'approve' && $u !== '') {
                $st = $pdo->prepare("UPDATE club_members SET status='active' WHERE club_id=? AND username=? AND status='pending'");
                $st->execute([$id, $u]);
            } elseif ($act === 'promote_mod' && $u !== '') {
                $st = $pdo->prepare("UPDATE club_members SET role='moderator' WHERE club_id=? AND username=? AND status='active'");
                $st->execute([$id, $u]);
            } elseif ($act === 'post_news') {
                $title = trim((string)($_POST['title'] ?? ''));
                $body  = trim((string)($_POST['body'] ?? ''));
                if ($title !== '') {
                    $st = $pdo->prepare("INSERT INTO club_news (club_id, created_at, created_by, title, body) VALUES (?,?,?,?,?)");
                    $st->execute([$id, gmdate('Y-m-d H:i:s'), $this->currentUser(), $title, $body]);
                }
            } elseif ($act === 'add_event') {
                $title = trim((string)($_POST['title'] ?? ''));
                $when  = trim((string)($_POST['starts_at'] ?? ''));
                $details = trim((string)($_POST['details'] ?? ''));
                if ($title !== '' && $when !== '') {
                    $st = $pdo->prepare("INSERT INTO club_events (club_id, starts_at, title, details) VALUES (?,?,?,?)");
                    $st->execute([$id, $when, $title, $details]);
                }
            }
        }

        echo '<h3>Pending requests</h3>';
        $st = $pdo->prepare("SELECT username FROM club_members WHERE club_id=? AND status='pending' ORDER BY joined_at ASC");
        $st->execute([$id]);
        $pend = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
        if (!$pend) echo '<p>None.</p>';
        else {
            foreach ($pend as $p) {
                $u = htmlspecialchars((string)$p['username'], ENT_QUOTES, 'UTF-8');
                echo '<form method="post" style="margin:6px 0">';
                echo '<input type="hidden" name="act" value="approve" />';
                echo '<input type="hidden" name="user" value="'.$u.'" />';
                echo $u.' <button type="submit">Approve</button>';
                echo '</form>';
            }
        }

        echo '<h3>Members</h3>';
        $st = $pdo->prepare("SELECT username, role, status FROM club_members WHERE club_id=? ORDER BY role DESC, username ASC");
        $st->execute([$id]);
        $mem = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
        if ($mem) {
            echo '<table><tr><th>User</th><th>Role</th><th>Status</th><th>Actions</th></tr>';
            foreach ($mem as $m) {
                $u = htmlspecialchars((string)$m['username'], ENT_QUOTES, 'UTF-8');
                echo '<tr><td>'.$u.'</td><td>'.htmlspecialchars((string)$m['role']).'</td><td>'.htmlspecialchars((string)$m['status']).'</td><td>';
                echo '<form method="post" style="display:inline">';
                echo '<input type="hidden" name="act" value="promote_mod" />';
                echo '<input type="hidden" name="user" value="'.$u.'" />';
                echo '<button type="submit">Make moderator</button>';
                echo '</form>';
                echo '</td></tr>';
            }
            echo '</table>';
        }

        echo '<h3>Post Club News</h3>';
        echo '<form method="post">';
        echo '<input type="hidden" name="act" value="post_news" />';
        echo '<p><input type="text" name="title" placeholder="Title" style="width:100%"></p>';
        echo '<p><textarea name="body" rows="6" style="width:100%"></textarea></p>';
        echo '<p><button type="submit">Publish</button></p>';
        echo '</form>';

        echo '<h3>Add Event</h3>';
        echo '<form method="post">';
        echo '<input type="hidden" name="act" value="add_event" />';
        echo '<p><input type="text" name="title" placeholder="Event title" style="width:100%"></p>';
        echo '<p><input type="datetime-local" name="starts_at" /></p>';
        echo '<p><textarea name="details" rows="4" style="width:100%"></textarea></p>';
        echo '<p><button type="submit">Add</button></p>';
        echo '</form>';

        echo '<h3>Uploads</h3>';

echo '<h3>Upload Club Logo</h3>';
echo '<form method="post" enctype="multipart/form-data" style="margin-bottom:18px">';
echo '<input type="hidden" name="act" value="upload_logo" />';
echo '<p><input type="file" name="logo" accept="image/*"></p>';
echo '<p><button type="submit">Upload Logo</button></p>';
echo '</form>';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && (string)($_POST['act'] ?? '') === 'upload_logo' && !empty($_FILES['logo']['tmp_name'])) {
    $tmp = (string)$_FILES['logo']['tmp_name'];
    $orig = (string)$_FILES['logo']['name'];
    $safe = preg_replace('/[^a-zA-Z0-9._-]/', '_', $orig);
    $dir = NUKECE_ROOT . '/uploads/clubs/' . $id;
    if (!is_dir($dir)) @mkdir($dir, 0775, true);
    $dest = $dir . '/logo_' . time() . '_' . $safe;
    if (@move_uploaded_file($tmp, $dest)) {
        $rel = ltrim(str_replace(NUKECE_ROOT . '/', '', $dest), '/');
        $st = $pdo->prepare("UPDATE clubs SET logo_path=? WHERE id=?");
        $st->execute([$rel, $id]);
        echo '<p>Logo updated.</p>';
    } else {
        echo '<p>Logo upload failed.</p>';
    }
}

        echo '<p><small>Upload UI will be styled in the next polish pass.</small></p>';
    }

    private function newTopic(PDO $pdo, int $clubId): void
    {
        $user = $this->currentUser();
        if ($user === 'guest') { echo '<p>Log in to post.</p>'; return; }
        $st = $pdo->prepare("SELECT * FROM clubs WHERE id=?");
        $st->execute([$clubId]);
        $club = $st->fetch(PDO::FETCH_ASSOC);
        if (!$club || !$this->canView($pdo, $club)) { echo '<p>Not allowed.</p>'; return; }

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $title = trim((string)($_POST['title'] ?? ''));
            if ($title !== '') {
                $st = $pdo->prepare("INSERT INTO club_forum_topics (club_id, created_at, created_by, title) VALUES (?,?,?,?)");
                $st->execute([$clubId, gmdate('Y-m-d H:i:s'), $user, $title]);
                $tid = (int)$pdo->lastInsertId();
                header('Location: /index.php?module=clubs&op=topic&id='.$clubId.'&topic='.$tid);
                return;
            }
        }

        echo '<h2>New Topic</h2>';
        echo '<form method="post">';
        echo '<p><input type="text" name="title" style="width:100%" placeholder="Title"></p>';
        echo '<p><button type="submit">Create</button></p>';
        echo '</form>';
    }

    private function viewTopic(PDO $pdo, int $clubId, int $topicId): void
    {
        $user = $this->currentUser();
        $st = $pdo->prepare("SELECT * FROM clubs WHERE id=?");
        $st->execute([$clubId]);
        $club = $st->fetch(PDO::FETCH_ASSOC);
        if (!$club || !$this->canView($pdo, $club)) { echo '<p>Not allowed.</p>'; return; }

        $st = $pdo->prepare("SELECT * FROM club_forum_topics WHERE id=? AND club_id=?");
        $st->execute([$topicId, $clubId]);
        $topic = $st->fetch(PDO::FETCH_ASSOC);
        if (!$topic) { echo '<p>Topic not found.</p>'; return; }

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && $user !== 'guest') {
            $body = trim((string)($_POST['body'] ?? ''));
            if ($body !== '') {
                $st = $pdo->prepare("INSERT INTO club_forum_posts (topic_id, created_at, created_by, body) VALUES (?,?,?,?)");
                $st->execute([$topicId, gmdate('Y-m-d H:i:s'), $user, $body]);
            }
        }

        echo '<h2>'.htmlspecialchars((string)$topic['title'], ENT_QUOTES, 'UTF-8').'</h2>';
        echo '<p><a href="/index.php?module=clubs&op=view&id='.$clubId.'">Back to club</a></p>';

        $st = $pdo->prepare("SELECT created_at, created_by, body FROM club_forum_posts WHERE topic_id=? ORDER BY id ASC");
        $st->execute([$topicId]);
        $posts = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
        if (!$posts) echo '<p>No posts yet.</p>';
        else {
            foreach ($posts as $p) {
                echo '<div class="nukece-post">';
                echo '<div><strong>'.htmlspecialchars((string)$p['created_by'], ENT_QUOTES, 'UTF-8').'</strong> — '.htmlspecialchars((string)$p['created_at']).'</div>';
                echo '<div>'.nl2br(htmlspecialchars((string)$p['body'], ENT_QUOTES, 'UTF-8')).'</div>';
                echo '</div><hr>';
            }
        }

        if ($user !== 'guest') {
            echo '<form method="post">';
            echo '<p><textarea name="body" rows="5" style="width:100%"></textarea></p>';
            echo '<p><button type="submit">Post</button></p>';
            echo '</form>';
        }
    }

    private function download(PDO $pdo, int $clubId, int $fileId): void
    {
        $st = $pdo->prepare("SELECT * FROM clubs WHERE id=?");
        $st->execute([$clubId]);
        $club = $st->fetch(PDO::FETCH_ASSOC);
        if (!$club || !$this->canView($pdo, $club)) { echo '<p>Not allowed.</p>'; return; }

        $st = $pdo->prepare("SELECT * FROM club_downloads WHERE id=? AND club_id=?");
        $st->execute([$fileId, $clubId]);
        $f = $st->fetch(PDO::FETCH_ASSOC);
        if (!$f) { echo '<p>File not found.</p>'; return; }

        $path = (string)$f['stored_path'];
        $full = NUKECE_ROOT . '/' . $path;
        if (!is_file($full)) { echo '<p>Missing file on disk.</p>'; return; }

        header('Content-Type: ' . ((string)($f['mime'] ?? 'application/octet-stream')));
        header('Content-Disposition: attachment; filename="' . basename((string)$f['filename']) . '"');
        readfile($full);
        exit;
    }
}
