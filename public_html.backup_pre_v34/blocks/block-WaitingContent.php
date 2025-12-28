<?php
/**
 * Waiting Content Block (nukeCE Gold)
 */

declare(strict_types=1);

if (!defined('BLOCK_FILE')) {
    exit;
}

require_once __DIR__ . '/../includes/BlockGold.php';

if (!BlockGold::can('admin.content.review')) {
    $content = '';
    return;
}

$content = BlockGold::cached('coreblock:waitingcontent', 60, function () {
    global $db, $prefix;

    $items = [];

    try {
        if (isset($db) && isset($prefix)) {
            // News submissions
            $sub = $prefix . '_queue';
            $res = $db->sql_query("SELECT COUNT(*) AS c FROM $sub");
            $row = $res ? $db->sql_fetchrow($res) : null;
            $c = (int) ($row['c'] ?? 0);
            if ($c > 0) {
                $items[] = '<li><a href="admin.php?op=submissions">News submissions</a> <span class="nukece-badge">' . $c . '</span></li>';
            }

            // Links pending (new Links module)
            $links = $prefix . '_links_pending';
            $res2 = $db->sql_query("SELECT COUNT(*) AS c FROM $links");
            $row2 = $res2 ? $db->sql_fetchrow($res2) : null;
            $c2 = (int) ($row2['c'] ?? 0);
            if ($c2 > 0) {
                $items[] = '<li><a href="admin.php?op=links_queue">Links pending</a> <span class="nukece-badge">' . $c2 . '</span></li>';
            }
        }
    } catch (Throwable $e) {
        // ignore
    }

    if (!$items) {
        return '<div class="nukece-muted">Nothing waiting.</div>';
    }

    return '<ul class="nukece-block-list">' . implode('', $items) . '</ul>';
});
