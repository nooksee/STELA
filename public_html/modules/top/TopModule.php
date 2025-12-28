<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Top;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * Top module displays the most recent news articles. In the future you
 * could rank by views or votes.
 */
class TopModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'top';
    }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->query('SELECT id, title, created_at FROM news ORDER BY created_at DESC LIMIT 10');
        $articles = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Top News</title></head><body>';
        echo '<h1>Top News</h1>';
        if ($articles) {
            echo '<ol>';
            foreach ($articles as $a) {
                $title = htmlspecialchars($a['title']);
                $date = htmlspecialchars($a['created_at']);
                echo '<li><a href="?module=news&params=' . $a['id'] . '">' . $title . '</a> (' . $date . ')</li>';
            }
            echo '</ol>';
        } else {
            echo '<p>No news articles found.</p>';
        }
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}