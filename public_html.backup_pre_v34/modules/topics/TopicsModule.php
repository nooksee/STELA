<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Topics;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * Topics module displays news by topic. Topics can be associated
 * with news articles in the news_topics table.
 */
class TopicsModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'topics';
    }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();
        if (!empty($params)) {
            $topicId = intval($params[0]);
            // show news for this topic
            $stmt = $pdo->prepare('SELECT n.id, n.title, n.created_at FROM news n JOIN news_topics nt ON n.id = nt.news_id WHERE nt.topic_id = :tid ORDER BY n.created_at DESC');
            $stmt->execute(['tid' => $topicId]);
            $articles = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $topicStmt = $pdo->prepare('SELECT name FROM topics WHERE id = :tid');
            $topicStmt->execute(['tid' => $topicId]);
            $topic = $topicStmt->fetchColumn();
            echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Topic: ' . htmlspecialchars($topic) . '</title></head><body>';
            echo '<h1>Topic: ' . htmlspecialchars($topic) . '</h1>';
            if ($articles) {
                echo '<ul>';
                foreach ($articles as $a) {
                    $title = htmlspecialchars($a['title']);
                    $date = htmlspecialchars($a['created_at']);
                    echo '<li><a href="?module=news&params=' . $a['id'] . '">' . $title . '</a> (' . $date . ')</li>';
                }
                echo '</ul>';
            } else {
                echo '<p>No news in this topic.</p>';
            }
            echo '<p><a href="?module=topics">Back to topics</a></p>';
            echo '<p><a href="/index.php">Back to home</a></p>';
            echo '</body></html>';
        } else {
            // list topics
            $stmt = $pdo->query('SELECT id, name FROM topics ORDER BY name ASC');
            $topics = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Topics</title></head><body>';
            echo '<h1>Topics</h1>';
            if ($topics) {
                echo '<ul>';
                foreach ($topics as $t) {
                    $name = htmlspecialchars($t['name']);
                    echo '<li><a href="?module=topics&params=' . $t['id'] . '">' . $name . '</a></li>';
                }
                echo '</ul>';
            } else {
                echo '<p>No topics defined.</p>';
            }
            echo '<p><a href="/index.php">Back to home</a></p>';
            echo '</body></html>';
        }
    }
}