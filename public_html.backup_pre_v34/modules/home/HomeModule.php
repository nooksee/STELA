<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Home;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Layout;

/**
 * The Home module provides the default landing page for nukeCE.
 * It displays a welcome message along with links to available
 * modules. Additional modules can override this behaviour by
 * registering their own landing page in the future.
 */
class HomeModule implements ModuleInterface
{
    public function getName(): string
    {
        return 'home';
    }

    public function handle(array $params): void
    {
        Layout::page('Home', function () {
            echo '<h1 style="margin-top:0">Welcome to nukeCE</h1>';
            echo '<p class="muted">A modern rewrite of the classic PHP‑Nuke with familiar workflow.</p>';
            echo '<h2>Quick links</h2>';
            echo '<ul>';
            echo '<li><a href="/index.php?module=news">News</a></li>';
            echo '<li><a href="/index.php?module=forums">Forums</a></li>';
            echo '<li><a href="/index.php?module=admin_login">Admin</a></li>';
            echo '</ul>';
            echo '<h2>Modules</h2>';
            echo '<p class="muted"><small>This list reflects the classic module structure; some modules are placeholders until implemented.</small></p>';
            echo '<ul style="columns:2;max-width:820px">';
            $mods = ['advertising','mobile','content','downloads','encyclopedia','faq','feedback','forums','journal','members','news','reviews','sections','statistics','submit_news','surveys','top','user'];
            foreach ($mods as $m) {
                $label = htmlspecialchars(ucwords(str_replace('_',' ', $m)), ENT_QUOTES,'UTF-8');
                echo "<li><a href='/index.php?module={$m}'>{$label}</a></li>";
            }
            echo '</ul>';
        });
    }
}
