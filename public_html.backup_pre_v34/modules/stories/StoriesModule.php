<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Stories;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * Stories module serves as an archive for older news articles. It lists
 * all news items with links to their detail pages.
 */
class StoriesModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'stories';
    }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->query('SELECT id, title, created_at FROM news ORDER BY created_at DESC');
        $articles = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Stories Archive</title></head><body>';
        echo '<h1>News Archive</h1>';
        if ($articles) {
            echo '<ul>';
            foreach ($articles as $a) {
                $title = htmlspecialchars($a['title']);
                $date = htmlspecialchars($a['created_at']);
                echo '<li><a href="?module=news&params=' . $a['id'] . '">' . $title . '</a> (' . $date . ')</li>';
            }
            echo '</ul>';
        } else {
            echo '<p>No articles available.</p>';
        }
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}