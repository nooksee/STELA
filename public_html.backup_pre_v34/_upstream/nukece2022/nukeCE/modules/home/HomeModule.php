<?php
namespace NukeCE\Modules\Home;

use NukeCE\Core\ModuleInterface;

/**
 * The Home module provides the default landing page for NukeCE.
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
        // Basic welcome page with navigation to sample modules
        echo '<!DOCTYPE html>';
        echo '<html lang="en">';
        echo '<head><meta charset="UTF-8"><title>NukeCE Home</title>';
        echo '<style>body{font-family:sans-serif;padding:2rem;}nav ul{list-style:none;padding:0;}nav li{margin:0.5rem 0;}nav a{color:#0366d6;text-decoration:none;}nav a:hover{text-decoration:underline;}</style>';
        echo '</head><body>';
        echo '<h1>Welcome to NukeCE</h1>';
        echo '<p>This is your brand new content management system built with modern PHP standards.</p>';
        echo '<nav><h2>Available Modules</h2><ul>';
        echo '<li><a href="?module=news">News</a> - publish and read articles</li>';
        echo '</ul></nav>';
        echo '</body></html>';
    }
}