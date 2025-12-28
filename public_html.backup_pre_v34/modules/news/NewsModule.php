<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\News;

use NukeCE\Core\ModuleInterface;
use PDO;
use NukeCE\Core\Model;
use NukeCE\Core\Layout;

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
        $articles = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];

        Layout::page('News', function () use ($articles) {
            echo "<h1 style='margin-top:0'>News</h1>";
            if (!$articles) {
                echo "<p class='muted'>No articles yet.</p>";
                return;
            }
            echo "<table width='100%' cellpadding='6' cellspacing='0' style='border-collapse:collapse'>";
            echo "<thead><tr style='background:#f4f4f4'><th align='left'>Title</th><th align='left' width='180'>Date</th></tr></thead><tbody>";
            foreach ($articles as $article) {
                $id = (int)($article['id'] ?? 0);
                $title = htmlspecialchars((string)($article['title'] ?? ''), ENT_QUOTES, 'UTF-8');
                $date = htmlspecialchars((string)($article['created_at'] ?? ''), ENT_QUOTES, 'UTF-8');
                echo "<tr style='border-top:1px solid #eee'><td><a href='/index.php?module=news&params={$id}'>{$title}</a></td><td>{$date}</td></tr>";
            }
            echo "</tbody></table>";
        }, ['module' => 'news']);
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
        $stmt->execute([':id' => $id]);
        $article = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$article) {
            http_response_code(404);
            Layout::page('News', function () {
                echo "<h1 style='margin-top:0'>News</h1><p>Article not found.</p>";
            });
            return;
        }

        $title = (string)($article['title'] ?? 'Untitled');
        $content = (string)($article['content'] ?? '');
        $date = (string)($article['created_at'] ?? '');

        Layout::page($title, function () use ($title, $content, $date) {
            echo "<div class='muted'><small>" . htmlspecialchars($date, ENT_QUOTES, 'UTF-8') . "</small></div>";
            echo "<h1 style='margin-top:6px'>" . htmlspecialchars($title, ENT_QUOTES, 'UTF-8') . "</h1>";
            echo "<div>" . nl2br(htmlspecialchars($content, ENT_QUOTES, 'UTF-8')) . "</div>";
            echo "<div style='margin-top:14px'><a href='/index.php?module=news'>&larr; Back to News</a></div>";
        }, ['module' => 'news']);
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