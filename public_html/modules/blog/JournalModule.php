<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Journal;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * Journal module allows users to maintain personal notes. Here we
 * implement a simple public journal listing all entries.
 */
class JournalModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'journal';
    }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->query('SELECT id, title, entry, created_at FROM journal ORDER BY created_at DESC');
        $entries = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Journal</title></head><body>';
        echo '<h1>Journal</h1>';
        if ($entries) {
            foreach ($entries as $entry) {
                $title = htmlspecialchars($entry['title']);
                $body = nl2br(htmlspecialchars($entry['entry']));
                $date = htmlspecialchars($entry['created_at']);
                echo '<article><h2>' . $title . '</h2><p><em>' . $date . '</em></p><div>' . $body . '</div></article><hr>';
            }
        } else {
            echo '<p>No journal entries yet.</p>';
        }
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}