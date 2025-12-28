<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Members;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use PDO;

/**
 * Members module lists all registered users. Authentication and user
 * management are not implemented in this example.
 */
class MembersModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'members';
    }

    public function handle(array $params): void
    {
        $pdo = $this->getConnection();
        $stmt = $pdo->query('SELECT id, username, registered_at FROM users ORDER BY username ASC');
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Members</title></head><body>';
        echo '<h1>Members</h1>';
        if ($users) {
            echo '<ul>';
            foreach ($users as $user) {
                $username = htmlspecialchars($user['username']);
                $registered = htmlspecialchars($user['registered_at']);
                echo '<li>' . $username . ' (registered ' . $registered . ')</li>';
            }
            echo '</ul>';
        } else {
            echo '<p>No members found.</p>';
        }
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}