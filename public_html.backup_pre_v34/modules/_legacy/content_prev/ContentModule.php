<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Content;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * Content module displays static pages defined by the administrator.
 */
class ContentModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'content';
    }

    public function handle(array $params): void
    {
        if (!empty($params)) {
            $id = intval($params[0]);
            $this->viewPage($id);
        } else {
            $this->listPages();
        }
    }

    private function listPages(): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->query('SELECT id, title FROM content ORDER BY id DESC');
        $pages = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Content</title></head><body>';
        echo '<h1>Content Pages</h1>';
        if ($pages) {
            echo '<ul>';
            foreach ($pages as $page) {
                $title = htmlspecialchars($page['title']);
                echo '<li><a href="?module=content&params=' . $page['id'] . '">' . $title . '</a></li>';
            }
            echo '</ul>';
        } else {
            echo '<p>No content pages available.</p>';
        }
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }

    private function viewPage(int $id): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->prepare('SELECT title, body FROM content WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $page = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$page) {
            http_response_code(404);
            echo '<h1>Page not found</h1>';
            return;
        }
        $title = htmlspecialchars($page['title']);
        $body = nl2br(htmlspecialchars($page['body']));
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>' . $title . '</title></head><body>';
        echo '<a href="?module=content">&larr; Back to list</a>';
        echo '<h1>' . $title . '</h1>';
        echo '<div>' . $body . '</div>';
        echo '</body></html>';
    }
}