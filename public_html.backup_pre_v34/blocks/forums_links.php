<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

return function(array $ctx): string {
    $installed = is_dir((defined('NUKECE_ROOT') ? NUKECE_ROOT : __DIR__ . '/..') . '/legacy/modules/Forums');
    $hint = $installed ? "<div class='muted'><small>Wrapped in nukeCE.</small></div>" : "<div class='muted'><small>Not installed yet.</small></div>";
    return "<div><a href='/index.php?module=forums'><b>Go to Forums</b></a></div>{$hint}";
};
