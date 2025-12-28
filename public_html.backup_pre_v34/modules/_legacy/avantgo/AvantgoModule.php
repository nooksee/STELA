<?php
namespace NukeCE\Modules\Avantgo;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * Avantgo module displays a mobile friendly list of recent news articles.
 */
class AvantgoModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'avantgo';
    }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->query('SELECT id, title, created_at FROM news ORDER BY created_at DESC LIMIT 10');
        $articles = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>AvantGo News</title>';
        echo '<style>body{font-family:sans-serif;padding:1rem;}a{display:block;color:#0366d6;margin-bottom:0.5rem;}</style>';
        echo '</head><body><h1>Latest News (Mobile)</h1>';
        foreach ($articles as $article) {
            $title = htmlspecialchars($article['title']);
            echo '<a href="?module=news&params=' . $article['id'] . '">' . $title . '</a>';
        }
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}