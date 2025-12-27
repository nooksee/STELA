<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Weblinks;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * Weblinks module displays a directory of external links.
 */
class WeblinksModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'weblinks';
    }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->query('SELECT id, title, url, description FROM weblinks ORDER BY id DESC');
        $links = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Web Links</title></head><body>';
        echo '<h1>Web Links</h1>';
        if ($links) {
            echo '<ul>';
            foreach ($links as $link) {
                $title = htmlspecialchars($link['title']);
                $url = htmlspecialchars($link['url']);
                $desc = htmlspecialchars($link['description']);
                echo '<li><a href="' . $url . '" target="_blank">' . $title . '</a><br><small>' . $desc . '</small></li>';
            }
            echo '</ul>';
        } else {
            echo '<p>No links available.</p>';
        }
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}