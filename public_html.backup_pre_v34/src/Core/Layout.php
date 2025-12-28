<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

use NukeCE\Blocks\BlockManager;

final class Layout
{
    public static function page(string $title, callable $renderMain, array $ctx = []): void
    {
        Theme::header($title);
        echo "<main class='main'>";
        echo "<div class='card'>";
        $renderMain();
        echo "</div>";
        echo "</main>";
        echo "<aside class='side'>";
        $bm = new BlockManager(defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2));
        echo $bm->renderPosition('right', $ctx);
        echo "</aside>";
        Theme::footer();
    }
}
