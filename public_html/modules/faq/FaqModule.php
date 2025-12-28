<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Faq;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * FAQ module displays frequently asked questions.
 */
class FaqModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'faq';
    }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->query('SELECT id, question, answer FROM faq ORDER BY id ASC');
        $faqs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>FAQ</title></head><body>';
        echo '<h1>Frequently Asked Questions</h1>';
        if ($faqs) {
            echo '<ul>';
            foreach ($faqs as $faq) {
                $q = htmlspecialchars($faq['question']);
                $a = nl2br(htmlspecialchars($faq['answer']));
                echo '<li><strong>' . $q . '</strong><br><span>' . $a . '</span></li>';
            }
            echo '</ul>';
        } else {
            echo '<p>No FAQs available.</p>';
        }
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}