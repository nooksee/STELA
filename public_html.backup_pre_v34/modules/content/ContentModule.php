\
<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Public label: Pages
 * Internal module name: content
 */

namespace NukeCE\Modules\Content;

use NukeCE\Core\Layout;
use NukeCE\Core\Model;
use PDO;

final class ContentModule extends Model implements \NukeCE\Core\ModuleInterface
{
    public function getName(): string { return 'content'; }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();

        // Ensure schema exists (soft fail). Admin can run installer.
        if (!$this->tableExists($pdo, self::tn('content_pages'))) {
            Layout::page('Pages', function () {
                echo "<div class='card' style='padding:16px;max-width:980px'>";
                echo "<h1>Pages</h1>";
                echo "<p class='muted'>Pages/Reference schema not installed yet.</p>";
                echo "<p><a class='btn' href='/install/setup_pages_reference.php' target='_blank'>Run Pages/Reference Setup</a></p>";
                echo "</div>";
            }, ['module'=>'content']);
            return;
        }

        $op = (string)($_GET['op'] ?? 'list');

        if ($op === 'view') {
            $slug = (string)($_GET['slug'] ?? '');
            $id = (int)($_GET['id'] ?? 0);
            $this->view($pdo, $slug, $id);
            return;
        }

        if ($op === 'tag') {
            $tag = (string)($_GET['tag'] ?? '');
            $this->byTag($pdo, $tag);
            return;
        }

        if ($op === 'category') {
            $cat = (string)($_GET['cat'] ?? '');
            $this->byCategory($pdo, $cat);
            return;
        }

        $this->listing($pdo);
    }

    private function listing(PDO $pdo): void
    {
        $pagesT = self::tn('content_pages');
        $catsT = self::tn('content_categories');

        $stmt = $pdo->query("SELECT p.id,p.slug,p.title,p.summary,p.created_at,c.name AS category,c.slug AS cat_slug
                             FROM `$pagesT` p
                             LEFT JOIN `$catsT` c ON c.id = p.category_id
                             WHERE p.status='published'
                             ORDER BY p.created_at DESC");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        Layout::page('Pages', function () use ($rows) {
            echo "<div class='card' style='padding:16px;max-width:980px'>";
            echo "<h1>Pages</h1>";
            echo "<p class='muted'>Evergreen guides, essays, and handbooks.</p>";
            if (!$rows) {
                echo "<p>No pages published yet.</p>";
            } else {
                echo "<div style='display:grid;gap:12px'>";
                foreach ($rows as $r) {
                    $title = htmlspecialchars((string)$r['title'], ENT_QUOTES, 'UTF-8');
                    $summary = htmlspecialchars((string)$r['summary'], ENT_QUOTES, 'UTF-8');
                    $url = "/index.php?module=content&op=view&slug=" . rawurlencode((string)$r['slug']);
                    $meta = [];
                    if (!empty($r['category'])) {
                        $cname = htmlspecialchars((string)$r['category'], ENT_QUOTES, 'UTF-8');
                        $curl = "/index.php?module=content&op=category&cat=" . rawurlencode((string)$r['cat_slug']);
                        $meta[] = "Category: <a href='{$curl}'>{$cname}</a>";
                    }
                    if (!empty($r['created_at'])) {
                        $meta[] = "Published: " . htmlspecialchars((string)$r['created_at'], ENT_QUOTES, 'UTF-8');
                    }
                    $m = $meta ? "<div class='muted' style='font-size:12px'>" . implode(" · ", $meta) . "</div>" : "";
                    echo "<div class='card' style='padding:12px'>";
                    echo "<div style='display:grid;gap:6px'>";
                    echo "<a href='{$url}' style='font-size:18px;font-weight:900'>{$title}</a>";
                    if ($summary) echo "<div>{$summary}</div>";
                    echo $m;
                    echo "</div></div>";
                }
                echo "</div>";
            }
            echo "</div>";
        }, ['module'=>'content']);
    }

    private function view(PDO $pdo, string $slug, int $id): void
    {
        $pagesT = self::tn('content_pages');
        $catsT = self::tn('content_categories');

        if ($slug !== '') {
            $stmt = $pdo->prepare("SELECT p.*, c.name AS category, c.slug AS cat_slug
                                   FROM `$pagesT` p
                                   LEFT JOIN `$catsT` c ON c.id = p.category_id
                                   WHERE p.slug = :s AND p.status='published' LIMIT 1");
            $stmt->execute([':s'=>$slug]);
        } else {
            $stmt = $pdo->prepare("SELECT p.*, c.name AS category, c.slug AS cat_slug
                                   FROM `$pagesT` p
                                   LEFT JOIN `$catsT` c ON c.id = p.category_id
                                   WHERE p.id = :id AND p.status='published' LIMIT 1");
            $stmt->execute([':id'=>$id]);
        }
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) {
            Layout::page('Page not found', function () {
                echo "<div class='card' style='padding:16px;max-width:980px'><h1>Page not found</h1></div>";
            }, ['module'=>'content']);
            return;
        }

        $title = htmlspecialchars((string)$row['title'], ENT_QUOTES, 'UTF-8');
        $body = $this->renderBbcode((string)$row['body']);
        $meta = [];
        if (!empty($row['category'])) {
            $cname = htmlspecialchars((string)$row['category'], ENT_QUOTES, 'UTF-8');
            $curl = "/index.php?module=content&op=category&cat=" . rawurlencode((string)$row['cat_slug']);
            $meta[] = "Category: <a href='{$curl}'>{$cname}</a>";
        }
        if (!empty($row['created_at'])) {
            $meta[] = "Published: " . htmlspecialchars((string)$row['created_at'], ENT_QUOTES, 'UTF-8');
        }

        Layout::page($title, function () use ($title, $body, $meta) {
            echo "<div class='card' style='padding:16px;max-width:980px'>";
            echo "<h1>{$title}</h1>";
            if ($meta) echo "<div class='muted' style='font-size:12px;margin-bottom:10px'>" . implode(" · ", $meta) . "</div>";
            echo "<div style='line-height:1.6'>{$body}</div>";
            echo "<div style='margin-top:14px'><a class='btn2' href='/index.php?module=content'>Back to Pages</a></div>";
            echo "</div>";
        }, ['module'=>'content']);
    }

    private function byCategory(PDO $pdo, string $catSlug): void
    {
        $pagesT = self::tn('content_pages');
        $catsT = self::tn('content_categories');

        $stmt = $pdo->prepare("SELECT id,name FROM `$catsT` WHERE slug=:s LIMIT 1");
        $stmt->execute([':s'=>$catSlug]);
        $cat = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$cat) {
            $this->listing($pdo);
            return;
        }

        $stmt = $pdo->prepare("SELECT slug,title FROM `$pagesT`
                               WHERE status='published' AND category_id=:cid ORDER BY created_at DESC");
        $stmt->execute([':cid'=>(int)$cat['id']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $cname = htmlspecialchars((string)$cat['name'], ENT_QUOTES, 'UTF-8');

        Layout::page("Pages · {$cname}", function () use ($rows, $cname) {
            echo "<div class='card' style='padding:16px;max-width:980px'>";
            echo "<h1>Pages: {$cname}</h1>";
            if (!$rows) echo "<p>No pages in this category yet.</p>";
            else {
                echo "<ul>";
                foreach ($rows as $r) {
                    $t = htmlspecialchars((string)$r['title'], ENT_QUOTES, 'UTF-8');
                    $u = "/index.php?module=content&op=view&slug=" . rawurlencode((string)$r['slug']);
                    echo "<li><a href='{$u}'>{$t}</a></li>";
                }
                echo "</ul>";
            }
            echo "<div style='margin-top:14px'><a class='btn2' href='/index.php?module=content'>Back to Pages</a></div>";
            echo "</div>";
        }, ['module'=>'content']);
    }

    private function byTag(PDO $pdo, string $tagSlug): void
    {
        $tagsT = self::tn('content_tags');
        $mapT = self::tn('content_page_tags');
        $pagesT = self::tn('content_pages');

        $stmt = $pdo->prepare("SELECT id,name FROM `$tagsT` WHERE slug=:s LIMIT 1");
        $stmt->execute([':s'=>$tagSlug]);
        $tag = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$tag) { $this->listing($pdo); return; }

        $stmt = $pdo->prepare("SELECT p.slug,p.title FROM `$mapT` m
                               JOIN `$pagesT` p ON p.id=m.page_id
                               WHERE m.tag_id=:tid AND p.status='published'
                               ORDER BY p.created_at DESC");
        $stmt->execute([':tid'=>(int)$tag['id']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $tname = htmlspecialchars((string)$tag['name'], ENT_QUOTES, 'UTF-8');
        Layout::page("Pages · {$tname}", function () use ($rows, $tname) {
            echo "<div class='card' style='padding:16px;max-width:980px'>";
            echo "<h1>Pages tagged: {$tname}</h1>";
            if (!$rows) echo "<p>No pages tagged with this yet.</p>";
            else {
                echo "<ul>";
                foreach ($rows as $r) {
                    $t = htmlspecialchars((string)$r['title'], ENT_QUOTES, 'UTF-8');
                    $u = "/index.php?module=content&op=view&slug=" . rawurlencode((string)$r['slug']);
                    echo "<li><a href='{$u}'>{$t}</a></li>";
                }
                echo "</ul>";
            }
            echo "<div style='margin-top:14px'><a class='btn2' href='/index.php?module=content'>Back to Pages</a></div>";
            echo "</div>";
        }, ['module'=>'content']);
    }

    private function tableExists(PDO $pdo, string $table): bool
    {
        try {
            $stmt = $pdo->prepare("SHOW TABLES LIKE :t");
            $stmt->execute([':t'=>$table]);
            return (bool)$stmt->fetchColumn();
        } catch (\Throwable $e) {
            return false;
        }
    }

    private function renderBbcode(string $input): string
    {
        $s = htmlspecialchars($input, ENT_QUOTES, 'UTF-8');
        $s = str_replace(["\r\n","\n"], "<br>", $s);
        $s = preg_replace('/\[b\](.*?)\[\/b\]/is', '<b>$1</b>', $s) ?? $s;
        $s = preg_replace('/\[i\](.*?)\[\/i\]/is', '<i>$1</i>', $s) ?? $s;
        $s = preg_replace('/\[u\](.*?)\[\/u\]/is', '<u>$1</u>', $s) ?? $s;
        $s = preg_replace('/\[s\](.*?)\[\/s\]/is', '<s>$1</s>', $s) ?? $s;
        $s = preg_replace('/\[quote\](.*?)\[\/quote\]/is', '<blockquote>$1</blockquote>', $s) ?? $s;
        $s = preg_replace('/\[code\](.*?)\[\/code\]/is', '<pre><code>$1</code></pre>', $s) ?? $s;
        $s = preg_replace('/\[url=([^\]]+)\](.*?)\[\/url\]/is', '<a href="$1" target="_blank" rel="noopener">$2</a>', $s) ?? $s;
        $s = preg_replace('/\[url\](.*?)\[\/url\]/is', '<a href="$1" target="_blank" rel="noopener">$1</a>', $s) ?? $s;
        return $s;
    }
}
