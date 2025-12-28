<?php
/**
 * PHP-Nuke CE (Community Edition)
 * Block: Links Categories
 */

if (!defined('BLOCK_FILE')) {
    define('BLOCK_FILE', true);
}

global $content, $db, $prefix, $current_theme;
$pref = is_string($prefix) ? $prefix . '_' : 'nuke_';

$content = '';
$res = $db->sql_query('SELECT cid, title FROM ' . $pref . "links_categories ORDER BY title");
$content .= '<ul class="nukece-block-list">';
while ($row = $db->sql_fetchrow($res)) {
    $cid = (int)$row['cid'];
    $content .= '<li><a href="modules.php?name=Links&amp;op=category&amp;cid=' . $cid . '">' . htmlspecialchars($row['title']) . '</a></li>';
}
$content .= '</ul>';
