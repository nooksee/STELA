<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Feedback;

use NukeCE\Core\ModuleInterface;

/**
 * Feedback module provides a simple contact form. In a production
 * environment this would send an email to the site administrator.
 */
class FeedbackModule implements ModuleInterface
{
    public function getName(): string
    {
        return 'feedback';
    }

    public function handle(array $params): void
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            // In a real implementation, send email here
            echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Feedback</title></head><body>';
            echo '<h1>Thank you for your feedback!</h1>';
            echo '<p>We appreciate your message.</p>';
            echo '<p><a href="/index.php">Back to home</a></p>';
            echo '</body></html>';
        } else {
            echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Feedback</title></head><body>';
            echo '<h1>Send Us Feedback</h1>';
            echo '<form method="post">';
            echo '<label>Name<br><input type="text" name="name" required></label><br>';
            echo '<label>Email<br><input type="email" name="email" required></label><br>';
            echo '<label>Message<br><textarea name="message" rows="5" cols="40" required></textarea></label><br>';
            echo '<button type="submit">Send</button>';
            echo '</form>';
            echo '<p><a href="/index.php">Back to home</a></p>';
            echo '</body></html>';
        }
    }
}