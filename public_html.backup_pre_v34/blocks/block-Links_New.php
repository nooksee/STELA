<?php
/**
 * PHP-Nuke CE (Community Edition)
 * Block: New Links
 */

if (!defined('BLOCK_FILE')) {
    define('BLOCK_FILE', true);
}

global $content, $db, $prefix;
$pref = is_string($prefix) ? $prefix . '_' : 'nuke_';

$limit = 5;
$content = '<ul class="nukece-block-list">';
$res = $db->sql_query("SELECT lid, title FROM {$pref}links WHERE status='approved' ORDER BY created_at DESC LIMIT {$limit}");
while ($row = $db->sql_fetchrow($res)) {
    $lid = (int)$row['lid'];
    $content .= '<li><a href="modules.php?name=Links&amp;op=visit&amp;lid=' . $lid . '">' . htmlspecialchars($row['title']) . '</a></li>';
}
$content .= '</ul>';
