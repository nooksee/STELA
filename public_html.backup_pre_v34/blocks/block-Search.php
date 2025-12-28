<?php
/**
 * Search Block (nukeCE Gold)
 */

declare(strict_types=1);

if (!defined('BLOCK_FILE')) {
    exit;
}

require_once __DIR__ . '/../includes/BlockGold.php';

$action = 'modules.php?name=Search';
$content = '<form class="nukece-search" action="' . BlockGold::esc(BlockGold::url($action)) . '" method="get">'
    . '<input type="hidden" name="name" value="Search" />'
    . '<div class="nukece-form-row">'
    . '<input class="nukece-input" type="search" name="query" placeholder="Search…" />'
    . '</div>'
    . '<div class="nukece-form-actions">'
    . '<input class="nukece-btn" type="submit" value="Search" />'
    . '</div>'
    . '</form>';
