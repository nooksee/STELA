<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Advertising;

use NukeCE\Core\ModuleInterface;

/**
 * Advertising module placeholder. In a full implementation this module
 * would provide functionality for managing advertisements on your site.
 */
class AdvertisingModule implements ModuleInterface
{
    public function getName(): string
    {
        return 'advertising';
    }

    public function handle(array $params): void
    {
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Advertising</title></head><body>';
        echo '<h1>Advertising</h1>';
        echo '<p>This module is under construction. Here you would manage banner ads and sponsorships.</p>';
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}