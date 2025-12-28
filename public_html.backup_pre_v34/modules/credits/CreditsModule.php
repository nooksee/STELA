\
<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Public module: Credits
 */

namespace NukeCE\Modules\Credits;

use NukeCE\Core\Layout;

final class CreditsModule implements \NukeCE\Core\ModuleInterface
{
    public function getName(): string { return 'credits'; }

    public function handle(array $params): void
    {
        $base = dirname(__DIR__, 2);
        $creditsFile = $base . '/docs/CREDITS.md';
        $authorsFile = $base . '/docs/AUTHORS.md';

        $credits = is_readable($creditsFile) ? file_get_contents($creditsFile) : "# Credits\n\nMissing docs/CREDITS.md";
        $authors = is_readable($authorsFile) ? file_get_contents($authorsFile) : "# Authors\n\nMissing docs/AUTHORS.md";

        Layout::page('Credits', function () use ($credits, $authors) {
            echo "<div class='card' style='padding:16px;max-width:980px'>";
            echo "<h1>Credits</h1>";
            echo "<p class='muted'>Lineage, licensing, and acknowledgements.</p>";
            echo "<div style='display:grid;gap:16px'>";
            echo "<div class='card' style='padding:12px'>";
            echo "<h2 style='margin-top:0'>Project Credits</h2>";
            echo self::renderMarkdownLite($credits);
            echo "</div>";
            echo "<div class='card' style='padding:12px'>";
            echo "<h2 style='margin-top:0'>Authors & Attribution</h2>";
            echo self::renderMarkdownLite($authors);
            echo "</div>";
            echo "</div>";
            echo "</div>";
        }, ['module'=>'credits']);
    }

    private static function renderMarkdownLite(string $md): string
    {
        $md = str_replace(["\r\n","\r"], "\n", $md);
        $lines = explode("\n", $md);
        $out = [];
        foreach ($lines as $line) {
            $l = rtrim($line);
            if (preg_match('/^###\s+(.*)$/', $l, $m)) {
                $out[] = "<h3>" . htmlspecialchars($m[1], ENT_QUOTES, 'UTF-8') . "</h3>";
                continue;
            }
            if (preg_match('/^##\s+(.*)$/', $l, $m)) {
                $out[] = "<h2>" . htmlspecialchars($m[1], ENT_QUOTES, 'UTF-8') . "</h2>";
                continue;
            }
            if (preg_match('/^#\s+(.*)$/', $l, $m)) {
                $out[] = "<h2>" . htmlspecialchars($m[1], ENT_QUOTES, 'UTF-8') . "</h2>";
                continue;
            }
            if (preg_match('/^\-\s+(.*)$/', $l, $m)) {
                $out[] = "<li>" . htmlspecialchars($m[1], ENT_QUOTES, 'UTF-8') . "</li>";
                continue;
            }
            if ($l === '') {
                $out[] = "";
                continue;
            }
            $out[] = "<p>" . htmlspecialchars($l, ENT_QUOTES, 'UTF-8') . "</p>";
        }
        // wrap consecutive <li> into <ul>
        $html = "\n".implode("\n", $out)."\n";
        $html = preg_replace_callback('/(?:<li>.*?<\/li>\n?)+/s', function($m){
            return "<ul>\n".$m[0]."</ul>\n";
        }, $html) ?? $html;
        return $html;
    }
}
