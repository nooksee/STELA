<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Privmsg;

use NukeCE\Core\ModuleInterface;

/**
 * Private Messages module placeholder. A full implementation would allow
 * members to send private messages to one another.
 */
class PrivmsgModule implements ModuleInterface
{
    public function getName(): string
    {
        return 'privmsg';
    }

    public function handle(array $params): void
    {
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Private Messages</title></head><body>';
        echo '<h1>Private Messages</h1>';
        echo '<p>This module is not implemented. In a full system you could compose, send and read private messages.</p>';
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}