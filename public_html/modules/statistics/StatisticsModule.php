<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Statistics;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * Statistics module provides simple site statistics. In a complete system
 * you might include page views, user activity and more.
 */
class StatisticsModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'statistics';
    }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();
        $counts = [];
        $tables = ['news', 'content', 'downloads', 'encyclopedia', 'faq', 'journal', 'users'];
        foreach ($tables as $table) {
            try {
                $stmt = $pdo->query('SELECT COUNT(*) AS c FROM ' . $table);
                $counts[$table] = (int)$stmt->fetchColumn();
            } catch (PDO\Exception $e) {
                $counts[$table] = 0;
            }
        }
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Statistics</title></head><body>';
        echo '<h1>Site Statistics</h1>';
        echo '<ul>';
        echo '<li>News articles: ' . $counts['news'] . '</li>';
        echo '<li>Content pages: ' . $counts['content'] . '</li>';
        echo '<li>Downloads: ' . $counts['downloads'] . '</li>';
        echo '<li>Encyclopedia entries: ' . $counts['encyclopedia'] . '</li>';
        echo '<li>FAQs: ' . $counts['faq'] . '</li>';
        echo '<li>Journal entries: ' . $counts['journal'] . '</li>';
        echo '<li>Members: ' . $counts['users'] . '</li>';
        echo '</ul>';
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}