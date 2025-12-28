<?php
namespace NukeCE\Modules\News;

use NukeCE\Core\ModuleInterface;
use PDO;
use NukeCE\Core\Model;

/**
 * NewsModule allows publishing and viewing news articles. It demonstrates
 * how a module can interact with the database using the base Model
 * class and render output without exposing internal details.
 */
class NewsModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'news';
    }

    public function handle(array $params): void
    {
        // Determine action based on parameters
        if (!empty($params)) {
            $id = intval($params[0]);
            $this->viewArticle($id);
        } else {
            $this->listArticles();
        }
    }

    /**
     * Display a list of articles.
     */
    private function listArticles(): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->query('SELECT id, title, created_at FROM news ORDER BY created_at DESC');
        $articles = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">';
        echo '<title>News</title>'; 
        echo '<style>body{font-family:sans-serif;padding:2rem;}table{width:100%;border-collapse:collapse;}th,td{padding:0.5rem;border-bottom:1px solid #eee;}a{color:#0366d6;text-decoration:none;}a:hover{text-decoration:underline;}</style>';
        echo '</head><body>';
        echo '<h1>News Articles</h1>';
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '<table><thead><tr><th>Title</th><th>Date</th></tr></thead><tbody>';
        foreach ($articles as $article) {
            $title = htmlspecialchars($article['title']);
            $date = htmlspecialchars($article['created_at']);
            echo '<tr><td><a href="?module=news&params=' . $article['id'] . '">' . $title . '</a></td><td>' . $date . '</td></tr>';
        }
        echo '</tbody></table>';
        echo '</body></html>';
    }

    /**
     * Display a single article.
     *
     * @param int $id
     */
    private function viewArticle(int $id): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->prepare('SELECT title, content, created_at FROM news WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $article = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$article) {
            http_response_code(404);
            echo '<h1>Article not found</h1>';
            return;
        }
        $title = htmlspecialchars($article['title']);
        $content = nl2br(htmlspecialchars($article['content']));
        $date = htmlspecialchars($article['created_at']);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">';
        echo '<title>' . $title . '</title>';
        echo '<style>body{font-family:sans-serif;padding:2rem;}a{color:#0366d6;text-decoration:none;}a:hover{text-decoration:underline;}article{margin-top:1rem;}</style>';
        echo '</head><body>';
        echo '<a href="?module=news">&larr; Back to list</a>';
        echo '<article>';
        echo '<h1>' . $title . '</h1>';
        echo '<p><em>' . $date . '</em></p>';
        echo '<div>' . $content . '</div>';
        echo '</article>';
        echo '</body></html>';
    }
}