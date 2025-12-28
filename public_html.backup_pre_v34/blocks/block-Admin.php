<?php
/**
 * Admin Block (nukeCE Gold)
 */

declare(strict_types=1);

if (!defined('BLOCK_FILE')) {
    exit;
}

require_once __DIR__ . '/../includes/BlockGold.php';

$content = '';
if (BlockGold::isAdmin()) {
    $items = [];
    $items[] = '<li><a href="' . BlockGold::esc(BlockGold::url('admin.php')) . '">Admin Panel</a></li>';

    // Fast links if modules exist
    $items[] = '<li><a href="' . BlockGold::esc(BlockGold::url('admin.php?op=blocks')) . '">Blocks</a></li>';
    $items[] = '<li><a href="' . BlockGold::esc(BlockGold::url('admin.php?op=settings')) . '">Settings</a></li>';
    $items[] = '<li><a href="' . BlockGold::esc(BlockGold::url('admin.php?op=themes')) . '">Themes</a></li>';

    if (file_exists(__DIR__ . '/../modules/admin_nukesecurity')) {
        $items[] = '<li><a href="' . BlockGold::esc(BlockGold::url('admin.php?op=nukesecurity')) . '">NukeSecurity</a></li>';
    }

    $content .= '<ul class="nukece-block-list">' . implode('', $items) . '</ul>';
}
