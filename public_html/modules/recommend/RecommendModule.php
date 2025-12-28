<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Recommend;

use NukeCE\Core\ModuleInterface;

/**
 * Recommend module provides a simple form for users to recommend your
 * site to their friends via email. This example does not send email.
 */
class RecommendModule implements ModuleInterface
{
    public function getName(): string
    {
        return 'recommend';
    }

    public function handle(array $params): void
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Recommend Us</title></head><body>';
            echo '<h1>Thank you!</h1>';
            echo '<p>Your recommendation has been recorded.</p>';
            echo '<p><a href="/index.php">Back to home</a></p>';
            echo '</body></html>';
        } else {
            echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Recommend Us</title></head><body>';
            echo '<h1>Recommend Our Site</h1>';
            echo '<form method="post">';
            echo '<label>Your Name<br><input type="text" name="name" required></label><br>';
            echo '<label>Friend\'s Email<br><input type="email" name="friend_email" required></label><br>';
            echo '<button type="submit">Send Recommendation</button>';
            echo '</form>';
            echo '<p><a href="/index.php">Back to home</a></p>';
            echo '</body></html>';
        }
    }
}