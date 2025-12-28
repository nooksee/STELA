<?php
/**
 * NukeSecurity Status Block (nukeCE Gold)
 */

declare(strict_types=1);

if (!defined('BLOCK_FILE')) {
    exit;
}

require_once __DIR__ . '/../includes/BlockGold.php';

// Show a small, non-alarming status summary for admins; minimal info for users.

$admin = BlockGold::isAdmin();

$content = BlockGold::cached('coreblock:nukesecurity', 30, function () use ($admin) {
    $mode = 'unknown';
    $recent = null;

    if (class_exists('NukeSecurity')) {
        try {
            if (method_exists('NukeSecurity', 'mode')) {
                $mode = (string) NukeSecurity::mode();
            }
            if ($admin && method_exists('NukeSecurity', 'recentThreatSummary')) {
                $recent = NukeSecurity::recentThreatSummary(10);
            }
        } catch (Throwable $e) {
            // ignore
        }
    }

    $out = '<div class="nukece-security">'
        . '<div class="nukece-security__line">Security: <strong>' . BlockGold::esc(ucfirst($mode)) . '</strong></div>';

    if ($admin) {
        $out .= '<div class="nukece-security__actions">'
            . '<a href="admin.php?op=nukesecurity">Open NukeSecurity</a>'
            . '</div>';

        if (is_array($recent) && $recent) {
            $out .= '<ul class="nukece-block-list">';
            foreach (array_slice($recent, 0, 5) as $r) {
                $label = BlockGold::esc((string) ($r['label'] ?? 'Event'));
                $count = (int) ($r['count'] ?? 0);
                $out .= '<li>' . $label . ' <span class="nukece-badge">' . $count . '</span></li>';
            }
            $out .= '</ul>';
        }
    }

    $out .= '</div>';
    return $out;
});
