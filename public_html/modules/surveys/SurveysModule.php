<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Surveys;

use NukeCE\Core\ModuleInterface;

/**
 * Surveys module placeholder for polls. A full implementation would
 * allow creating polls and recording votes.
 */
class SurveysModule implements ModuleInterface
{
    public function getName(): string
    {
        return 'surveys';
    }

    public function handle(array $params): void
    {
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Surveys</title></head><body>';
        echo '<h1>Surveys</h1>';
        echo '<p>The surveys module is not yet implemented.</p>';
        echo '<p><a href="/index.php">Back to home</a></p>';
        echo '</body></html>';
    }
}