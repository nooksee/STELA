<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Search;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * Search module allows users to search news and content pages.
 */
class SearchModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'search';
    }

    public function handle(array $params): void
    {
        $query = isset($_GET['q']) ? trim($_GET['q']) : '';
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Search</title></head><body>';
        echo '<h1>Search</h1>';
        echo '<form method="get">';
        echo '<input type="hidden" name="module" value="search">';
        echo '<input type="text" name="q" value="' . htmlspecialchars($query) . '" placeholder="Search..." size="30">';
        echo '<button type="submit">Search</button>';
        echo '</form>';
        if ($query !== '') {
            $pdo = $this->getConnection();
            $stmt = $pdo->prepare('SELECT id, title, content, created_at FROM news WHERE title LIKE :q OR content LIKE :q');
            $stmt->execute(['q' => '%' . $query . '%']);
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt2 = $pdo->prepare('SELECT id, title, body FROM content WHERE title LIKE :q OR body LIKE :q');
            $stmt2->execute(['q' => '%' . $query . '%']);
            $contentResults = $stmt2->fetchAll(PDO::FETCH_ASSOC);
            echo '<h2>News</h2>';
            if ($results) {
                echo '<ul>';
                foreach ($results as $row) {
                    $title = htmlspecialchars($row['title']);
                    echo '<li><a href="?module=news&params=' . $row['id'] . '">' . $title . '</a></li>';
                }
                echo '</ul>';
            } else {
                echo '<p>No news results.</p>';
            }
            echo '<h2>Content</h2>';
            if ($contentResults) {
                echo '<ul>';
                foreach ($contentResults as $row) {
                    $title = htmlspecialchars($row['title']);
                    echo '<li><a href="?module=content&params=' . $row['id'] . '">' . $title . '</a></li>';
                }
                echo '</ul>';
            } else {
                echo '<p>No content results.</p>';
            }
        }
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}