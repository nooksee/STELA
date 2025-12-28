<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Encyclopedia;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Layout;
use NukeCE\Core\Model;
use PDO;

/**
 * Public Reference / Knowledge Base (formerly Encyclopedia).
 * - Browse and search
 * - Citation rendering
 */
final class EncyclopediaModule extends Model implements ModuleInterface
{
    public function run(): void
    {
        $pdo = $this->getConnection();
        $q = trim((string)($_GET['q'] ?? ''));
        $id = (int)($_GET['id'] ?? 0);

        Layout::header('Reference');

        echo '<div class="nukece-ref">';
        echo '<h1>Reference</h1>';
        echo '<form method="get" action="/index.php">';
        echo '<input type="hidden" name="module" value="encyclopedia" />';
        echo '<input type="text" name="q" value="'.htmlspecialchars($q, ENT_QUOTES, 'UTF-8').'" placeholder="Search terms…" />';
        echo ' <button type="submit">Search</button>';
        echo '</form>';

        if ($id > 0) {
            $st = $pdo->prepare('SELECT id, term, definition FROM encyclopedia WHERE id=:id');
            $st->execute([':id'=>$id]);
            $row = $st->fetch(PDO::FETCH_ASSOC);
            if ($row) {
                $this->renderEntry($row);
            } else {
                echo '<p>Entry not found.</p>';
            }
            echo '<p><a href="/index.php?module=encyclopedia">Back to Reference</a></p>';
            echo '</div>';
            Layout::footer();
            return;
        }

        // Search or browse
        if ($q !== '') {
            $st = $pdo->prepare('SELECT id, term, definition FROM encyclopedia WHERE term LIKE :q ORDER BY term ASC LIMIT 200');
            $st->execute([':q'=>'%'.$q.'%']);
            $items = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
            echo '<h2>Search results</h2>';
            if (!$items) {
                echo '<p>No matches.</p>';
            } else {
                echo '<ul>';
                foreach ($items as $it) {
                    $term = htmlspecialchars((string)$it['term'], ENT_QUOTES, 'UTF-8');
                    echo '<li><a href="/index.php?module=encyclopedia&id='.(int)$it['id'].'">'.$term.'</a></li>';
                }
                echo '</ul>';
            }
        } else {
            // Browse A-Z
            $letter = strtoupper(substr((string)($_GET['letter'] ?? ''), 0, 1));
            if ($letter !== '' && !preg_match('/^[A-Z]$/', $letter)) $letter = '';

            echo '<div class="nukece-ref-az">';
            foreach (range('A','Z') as $L) {
                $href = '/index.php?module=encyclopedia&letter='.$L;
                $cls = ($letter === $L) ? 'style="font-weight:800"' : '';
                echo '<a '.$cls.' href="'.$href.'">'.$L.'</a> ';
            }
            echo '</div>';

            if ($letter !== '') {
                $st = $pdo->prepare('SELECT id, term FROM encyclopedia WHERE term LIKE :q ORDER BY term ASC LIMIT 500');
                $st->execute([':q'=>$letter.'%']);
            } else {
                $st = $pdo->query('SELECT id, term FROM encyclopedia ORDER BY term ASC LIMIT 200');
            }
            $rows = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
            echo '<h2>Browse</h2>';
            if (!$rows) {
                echo '<p>No entries yet.</p>';
            } else {
                echo '<ul>';
                foreach ($rows as $r) {
                    $term = htmlspecialchars((string)$r['term'], ENT_QUOTES, 'UTF-8');
                    echo '<li><a href="/index.php?module=encyclopedia&id='.(int)$r['id'].'">'.$term.'</a></li>';
                }
                echo '</ul>';
            }
        }

        echo '</div>';
        Layout::footer();
    }

    /** @param array<string,mixed> $row */
    private function renderEntry(array $row): void
    {
        $term = htmlspecialchars((string)$row['term'], ENT_QUOTES, 'UTF-8');
        $def = (string)$row['definition'];

        echo '<h2>'.$term.'</h2>';

        $rendered = $this->renderWithCitations($def, $citations);
        echo '<div class="nukece-ref-body">'.$rendered.'</div>';

        if (!empty($citations)) {
            echo '<h3>Citations</h3><ol class="nukece-ref-cites">';
            foreach ($citations as $i => $c) {
                $n = $i + 1;
                $title = htmlspecialchars($c['title'], ENT_QUOTES, 'UTF-8');
                $url = htmlspecialchars($c['url'], ENT_QUOTES, 'UTF-8');
                echo '<li><a href="'.$url.'" target="_blank" rel="noopener noreferrer">'.$title.'</a></li>';
            }
            echo '</ol>';
        }
    }

    /**
     * Citation format supported:
     * - [cite:URL|Title]
     * Returns HTML and fills $citations with ordered list.
     * @param string $text
     * @param array<int, array{url:string,title:string}> $citations
     */
    private function renderWithCitations(string $text, array &$citations): string
    {
        $citations = [];
        $out = htmlspecialchars($text, ENT_QUOTES, 'UTF-8');

        // Convert newlines
        $out = nl2br($out);

        // Detect citations on the *raw* text to preserve URLs/titles
        if (preg_match_all('/\[cite:([^\|\]]+)\|([^\]]+)\]/i', $text, $m, PREG_SET_ORDER)) {
            foreach ($m as $match) {
                $url = trim($match[1]);
                $title = trim($match[2]);
                $citations[] = ['url'=>$url, 'title'=>$title];
            }
            // Replace tokens with [n] markers in escaped output
            foreach ($m as $idx => $match) {
                $n = $idx + 1;
                $tokenEsc = htmlspecialchars($match[0], ENT_QUOTES, 'UTF-8');
                $out = str_replace($tokenEsc, '<sup>['.$n.']</sup>', $out);
            }
        }

        return $out;
    }
}
