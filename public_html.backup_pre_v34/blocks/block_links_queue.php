<?php
/**
 * nukeCE Links Queue block
 * Admin-only: shows pending Links submissions and quick actions.
 *
 * Uses standard $db + $prefix globals (PHP-Nuke style) and NukeSecurity when available.
 *
 * Official name: PHP-Nuke CE
 */
if (!defined('NUKECE')) { define('NUKECE', true); } // non-fatal for legacy include patterns

global $db, $prefix, $admin, $user;

$module_name = 'Links';

// Permission gate: admin only
$canAdmin = false;
if (function_exists('nukesecurity_can')) {
    $canAdmin = nukesecurity_can($user ?? null, 'links.admin');
} elseif (!empty($admin)) {
    $canAdmin = true;
}

if (!$canAdmin) {
    $content = '';
    return;
}

$linksTable = $prefix . '_links_links';
$limit = 5;

try {
    $sql = "SELECT lid, title, url, submitter, date FROM $linksTable WHERE status='pending' ORDER BY date DESC";
    $res = $db->sql_query($sql);
    $rows = [];
    while ($row = $db->sql_fetchrow($res)) {
        $rows[] = $row;
        if (count($rows) >= $limit) break;
    }
} catch (Throwable $e) {
    $content = '<div class="nukece-block-muted">Links Queue unavailable.</div>';
    return;
}

$countRes = $db->sql_query("SELECT COUNT(*) AS c FROM $linksTable WHERE status='pending'");
$countRow = $db->sql_fetchrow($countRes);
$pendingCount = (int)($countRow['c'] ?? 0);

$queueUrl = 'admin.php?op=links_queue';
$content = '<div class="nukece-block">';
$content .= '<div class="nukece-block-title">Links Queue</div>';
$content .= '<div class="nukece-block-subtitle"><strong>' . $pendingCount . '</strong> pending</div>';
$content .= '<ul class="nukece-block-list">';

if (!$rows) {
    $content .= '<li class="nukece-block-muted">No pending links.</li>';
} else {
    foreach ($rows as $r) {
        $lid = (int)$r['lid'];
        $title = htmlspecialchars($r['title'] ?? ('Link #' . $lid), ENT_QUOTES, 'UTF-8');
        $url = htmlspecialchars($r['url'] ?? '', ENT_QUOTES, 'UTF-8');
        $content .= '<li class="nukece-block-item">';
        $content .= '<div class="nukece-block-row"><a href="' . $queueUrl . '#lid-' . $lid . '">' . $title . '</a></div>';
        if ($url) $content .= '<div class="nukece-block-muted"><span class="nukece-block-url">' . $url . '</span></div>';
        $content .= '</li>';
    }
}

$content .= '</ul>';
$content .= '<div class="nukece-block-actions">';
$content .= '<a class="nukece-btn nukece-btn-sm" href="' . $queueUrl . '">Open queue</a>';
$content .= '</div>';
$content .= '</div>';
