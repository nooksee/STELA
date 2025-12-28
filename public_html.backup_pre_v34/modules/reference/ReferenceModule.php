\
<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Public label: Reference
 * Admin label: Knowledge Base
 */

namespace NukeCE\Modules\Reference;

use NukeCE\Core\Layout;
use NukeCE\Core\Model;
use NukeCE\Security\Csrf;
use NukeCE\Security\NukeSecurity;
use NukeCE\Security\CapabilityGate;
use PDO;

final class ReferenceModule extends Model implements \NukeCE\Core\ModuleInterface
{
    public function getName(): string { return 'reference'; }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();

        if (!$this->tableExists($pdo, self::tn('ref_entries'))) {
            Layout::page('Reference', function () {
                echo "<div class='card' style='padding:16px;max-width:980px'>";
                echo "<h1>Reference</h1>";
                echo "<p class='muted'>Pages/Reference schema not installed yet.</p>";
                echo "<p><a class='btn' href='/install/setup_pages_reference.php' target='_blank'>Run Pages/Reference Setup</a></p>";
                echo "</div>";
            }, ['module'=>'reference']);
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

        if ($op === 'propose') {
            $this->propose($pdo);
            return;
        }

        $this->listing($pdo);
    }

    private function listing(PDO $pdo): void
    {
        $entriesT = self::tn('ref_entries');

        $stmt = $pdo->query("SELECT id,slug,term,curator_note,created_at
                             FROM `$entriesT`
                             WHERE status='published'
                             ORDER BY term ASC");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        Layout::page('Reference', function () use ($rows) {
            echo "<div class='card' style='padding:16px;max-width:980px'>";
            echo "<div style='display:flex;justify-content:space-between;gap:12px;flex-wrap:wrap;align-items:flex-end'>";
            echo "<div><h1 style='margin:0'>Reference</h1><div class='muted'>Canonical definitions and concepts (human-curated).</div></div>";
            echo "<div><a class='btn' href='/index.php?module=reference&op=propose'>Propose an entry</a></div>";
            echo "</div>";

            if (!$rows) {
                echo "<p style='margin-top:12px'>No reference entries published yet.</p>";
            } else {
                echo "<div style='margin-top:12px'>";
                echo "<ul>";
                foreach ($rows as $r) {
                    $term = htmlspecialchars((string)$r['term'], ENT_QUOTES, 'UTF-8');
                    $u = "/index.php?module=reference&op=view&slug=" . rawurlencode((string)$r['slug']);
                    echo "<li><a href='{$u}'><b>{$term}</b></a></li>";
                }
                echo "</ul>";
                echo "</div>";
            }
            echo "</div>";
        }, ['module'=>'reference']);
    }

    private function view(PDO $pdo, string $slug, int $id): void
    {
        $entriesT = self::tn('ref_entries');

        if ($slug !== '') {
            $stmt = $pdo->prepare("SELECT * FROM `$entriesT` WHERE slug=:s AND status='published' LIMIT 1");
            $stmt->execute([':s'=>$slug]);
        } else {
            $stmt = $pdo->prepare("SELECT * FROM `$entriesT` WHERE id=:id AND status='published' LIMIT 1");
            $stmt->execute([':id'=>$id]);
        }
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) {
            Layout::page('Not found', function () {
                echo "<div class='card' style='padding:16px;max-width:980px'><h1>Reference entry not found</h1></div>";
            }, ['module'=>'reference']);
            return;
        }

        $term = htmlspecialchars((string)$row['term'], ENT_QUOTES, 'UTF-8');
        $def = $this->renderBbcode((string)$row['definition']);
        $note = trim((string)$row['curator_note']);
        $noteHtml = $note ? "<div class='muted' style='font-size:12px;margin-top:10px'><b>Curator note:</b> " . htmlspecialchars($note, ENT_QUOTES, 'UTF-8') . "</div>" : "";

        Layout::page($term, function () use ($term, $def, $noteHtml) {
            echo "<div class='card' style='padding:16px;max-width:980px'>";
            echo "<h1>{$term}</h1>";
            echo "<div style='line-height:1.6'>{$def}</div>";
            echo $noteHtml;
            echo "<div style='margin-top:14px'><a class='btn2' href='/index.php?module=reference'>Back to Reference</a></div>";
            echo "</div>";
        }, ['module'=>'reference']);
    }

    private function propose(PDO $pdo): void
    {
        CapabilityGate::require('reference.propose');
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            Csrf::validateOrDie($_POST['csrf'] ?? '');

            $term = trim((string)($_POST['term'] ?? ''));
            $definition = trim((string)($_POST['definition'] ?? ''));
            $hp = trim((string)($_POST['company'] ?? '')); // honeypot
            if ($hp !== '') {
                // Likely bot
                NukeSecurity::log('reference.propose.bot', ['ip'=>($_SERVER['REMOTE_ADDR'] ?? ''), 'ua'=>($_SERVER['HTTP_USER_AGENT'] ?? '')]);
                header('Location: /index.php?module=reference&op=propose&ok=1');
                exit;
            }
            $ip = (string)($_SERVER['REMOTE_ADDR'] ?? '');
            if (!$this->rateLimit('ref_propose_' . $ip, 20)) {
                NukeSecurity::log('reference.propose.ratelimited', ['ip'=>$ip]);
                header('Location: /index.php?module=reference&op=propose&err=1');
                exit;
            }
            if (mb_strlen($term) < 2 || mb_strlen($definition) < 10) {
                header('Location: /index.php?module=reference&op=propose&err=1');
                exit;
            }

            $queueT = self::tn('ref_queue');
            $src = [
                'referrer' => (string)($_SERVER['HTTP_REFERER'] ?? ''),
                'ip' => (string)($_SERVER['REMOTE_ADDR'] ?? ''),
                'ua' => (string)($_SERVER['HTTP_USER_AGENT'] ?? ''),
                'note' => trim((string)($_POST['source_note'] ?? '')),
            ];
            $stmt = $pdo->prepare("INSERT INTO `$queueT` (kind, proposed_term, proposed_definition, source_json, status)
                                   VALUES ('term', :t, :d, :s, 'new')");
            $stmt->execute([
                ':t'=>$term,
                ':d'=>$definition,
                ':s'=>json_encode($src, JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE),
            ]);

            NukeSecurity::log('reference.propose.submitted', ['term'=>$term, 'ip'=>$src['ip']]);
            header('Location: /index.php?module=reference&op=propose&ok=1');
            exit;
        }

        $ok = isset($_GET['ok']);
        $err = isset($_GET['err']);

        Layout::page('Propose · Reference', function () use ($ok, $err) {
            echo "<div class='card' style='padding:16px;max-width:980px'>";
            echo "<h1>Propose a Reference Entry</h1>";
            echo "<p class='muted'>AI can propose; humans canonize. Your submission goes into a review queue.</p>";
            if ($ok) echo "<div class='card' style='padding:10px;margin:10px 0'><b>Thanks!</b> Proposal submitted for review.</div>";
            if ($err) echo "<div class='card' style='padding:10px;margin:10px 0'><b>Fix:</b> Please provide a term and a longer definition.</div>";

            $csrf = Csrf::token();
            echo "<form method='post' style='display:grid;gap:12px'>";
            echo "<input type='hidden' name='csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
            // honeypot
            echo "<div style='display:none'><label>Company<input name='company' value=''></label></div>";

            echo "<label><b>Term</b><br><input name='term' required maxlength='255' style='width:100%'></label>";
            echo "<label><b>Definition</b><br><textarea name='definition' rows='10' required style='width:100%'></textarea></label>";
            echo "<label class='muted'>Optional: where did this come from? (link, post id, context)</label>";
            echo "<input name='source_note' maxlength='280' style='width:100%'>";

            echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
            echo "<button class='btn' type='submit'>Submit for review</button>";
            echo "<a class='btn2' href='/index.php?module=reference'>Cancel</a>";
            echo "</div>";
            echo "</form>";
            echo "</div>";
        }, ['module'=>'reference']);
    }

    private function byTag(PDO $pdo, string $tagSlug): void
    {
        $tagsT = self::tn('ref_tags');
        $mapT = self::tn('ref_entry_tags');
        $entriesT = self::tn('ref_entries');

        $stmt = $pdo->prepare("SELECT id,name FROM `$tagsT` WHERE slug=:s LIMIT 1");
        $stmt->execute([':s'=>$tagSlug]);
        $tag = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$tag) { $this->listing($pdo); return; }

        $stmt = $pdo->prepare("SELECT e.slug,e.term FROM `$mapT` m
                               JOIN `$entriesT` e ON e.id=m.entry_id
                               WHERE m.tag_id=:tid AND e.status='published'
                               ORDER BY e.term ASC");
        $stmt->execute([':tid'=>(int)$tag['id']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $tname = htmlspecialchars((string)$tag['name'], ENT_QUOTES, 'UTF-8');
        Layout::page("Reference · {$tname}", function () use ($rows, $tname) {
            echo "<div class='card' style='padding:16px;max-width:980px'>";
            echo "<h1>Reference tagged: {$tname}</h1>";
            if (!$rows) echo "<p>No entries tagged with this yet.</p>";
            else {
                echo "<ul>";
                foreach ($rows as $r) {
                    $term = htmlspecialchars((string)$r['term'], ENT_QUOTES, 'UTF-8');
                    $u = "/index.php?module=reference&op=view&slug=" . rawurlencode((string)$r['slug']);
                    echo "<li><a href='{$u}'>{$term}</a></li>";
                }
                echo "</ul>";
            }
            echo "<div style='margin-top:14px'><a class='btn2' href='/index.php?module=reference'>Back to Reference</a></div>";
            echo "</div>";
        }, ['module'=>'reference']);
    }


private function rateLimit(string $key, int $maxPerHour = 30): bool
{
    $dir = sys_get_temp_dir() . '/nukece_rl';
    if (!is_dir($dir)) @mkdir($dir, 0777, true);
    $file = $dir . '/' . preg_replace('/[^a-zA-Z0-9_\-]/', '_', $key) . '.json';
    $now = time();
    $windowStart = $now - 3600;

    $data = ['hits'=>[]];
    if (is_file($file)) {
        $raw = @file_get_contents($file);
        $tmp = json_decode((string)$raw, true);
        if (is_array($tmp)) $data = $tmp;
    }

    $hits = array_values(array_filter($data['hits'] ?? [], fn($ts) => is_int($ts) && $ts >= $windowStart));
    if (count($hits) >= $maxPerHour) return false;
    $hits[] = $now;
    @file_put_contents($file, json_encode(['hits'=>$hits]));
    return true;
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
