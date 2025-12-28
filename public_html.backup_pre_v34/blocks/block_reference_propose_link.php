<?php
/**
 * nukeCE Propose to Reference block
 * For editors/reviewers: quick shortcut to propose a Link into Reference queue.
 *
 * This block intentionally does NOT auto-canonize anything.
 * It creates a proposal entry (type=link) in the Reference queue (ref_*) to be reviewed.
 *
 * Official name: PHP-Nuke CE
 */
if (!defined('NUKECE')) { define('NUKECE', true); }

global $db, $prefix, $user, $admin;

$canPropose = false;
if (function_exists('nukesecurity_can')) {
    $canPropose = nukesecurity_can($user ?? null, 'reference.submit');
} elseif (!empty($admin)) {
    $canPropose = true;
}

if (!$canPropose) {
    $content = '';
    return;
}

$content = '<div class="nukece-block">';
$content .= '<div class="nukece-block-title">Reference</div>';
$content .= '<div class="nukece-block-muted">Propose a link into the knowledge base queue for human review.</div>';
$content .= '<div class="nukece-block-actions">';
$content .= '<a class="nukece-btn nukece-btn-sm" href="admin.php?op=links_queue">From Links queue</a>';
$content .= '<a class="nukece-btn nukece-btn-sm" href="modules.php?name=Reference&op=submit&type=link">Submit link</a>';
$content .= '</div>';
$content .= '</div>';
