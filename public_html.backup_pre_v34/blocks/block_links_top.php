<?php
/**
 * nukeCE Top Links block
 * Shows most-clicked links.
 *
 * Official name: PHP-Nuke CE
 */
if (!defined('NUKECE')) { define('NUKECE', true); }

global $db, $prefix;

$linksTable = $prefix . '_links_links';
$limit = 8;

try {
    $sql = "SELECT lid, title, hits FROM $linksTable WHERE status='approved' ORDER BY hits DESC, lid DESC";
    $res = $db->sql_query($sql);
    $rows = [];
    while ($row = $db->sql_fetchrow($res)) {
        $rows[] = $row;
        if (count($rows) >= $limit) break;
    }
} catch (Throwable $e) {
    $content = '<div class="nukece-block-muted">Top Links unavailable.</div>';
    return;
}

$content = '<div class="nukece-block">';
$content .= '<div class="nukece-block-title">Top Links</div>';
$content .= '<ol class="nukece-block-olist">';

if (!$rows) {
    $content .= '<li class="nukece-block-muted">No links yet.</li>';
} else {
    foreach ($rows as $r) {
        $lid = (int)$r['lid'];
        $title = htmlspecialchars($r['title'] ?? ('Link #' . $lid), ENT_QUOTES, 'UTF-8');
        $hits = (int)($r['hits'] ?? 0);
        $href = 'modules.php?name=Links&op=visit&lid=' . $lid;
        $content .= '<li class="nukece-block-item">';
        $content .= '<a href="' . $href . '">' . $title . '</a>';
        $content .= ' <span class="nukece-block-muted">(' . $hits . ')</span>';
        $content .= '</li>';
    }
}

$content .= '</ol>';
$content .= '<div class="nukece-block-actions">';
$content .= '<a class="nukece-btn nukece-btn-sm" href="modules.php?name=Links">Browse</a>';
$content .= '</div>';
$content .= '</div>';
