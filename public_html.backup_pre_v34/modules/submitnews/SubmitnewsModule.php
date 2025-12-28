<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Submitnews;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use NukeCE\Core\Layout;
use NukeCE\Editor\EditorService;
use PDO;

/**
 * SubmitNews module allows users to submit news articles for review.
 * Submissions are stored in a separate table for administrators to
 * review and publish.
 */
class SubmitnewsModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'submitnews';
    }

    public function handle(array $params): void
{
    $pdo = $this->getConnection();

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $title = trim((string)($_POST['title'] ?? ''));
        $content = trim((string)($_POST['content'] ?? ''));
        if ($title !== '' && $content !== '') {
            $stmt = $pdo->prepare('INSERT INTO news_submissions (title, content, created_at) VALUES (:title, :content, NOW())');
            $stmt->execute(['title' => $title, 'content' => $content]);

            Layout::page('Submit News', function () {
                echo '<h1>Thank you!</h1>';
                echo '<p>Your submission has been recorded and will be reviewed.</p>';
                echo '<p><a href="/index.php">Back to home</a></p>';
            }, ['module' => 'submitnews']);
            return;
        }
    }

    Layout::page('Submit News', function () {
        echo '<h1>Submit News</h1>';
        echo "<form method='post' style='display:grid;gap:12px;max-width:900px'>";
        echo "<label>Title<br><input type='text' name='title' required style='width:100%'></label>";
        echo "<label>Content</label>";
        EditorService::render('content', '', ['scope' => 'news', 'rows' => 10]);
        echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
        echo "<button class='btn' type='submit'>Submit</button>";
        echo "<a class='btn2' href='/index.php'>Cancel</a>";
        echo "</div>";
        echo "</form>";
    }, ['module' => 'submitnews']);
}
}
