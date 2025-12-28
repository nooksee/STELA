<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

return function(array $ctx): string {
    $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : (__DIR__ . '/..');
    $log = $root . '/data/nukesecurity.log';
    if (!is_file($log)) {
        return "<div class='muted'><small>No events logged.</small></div><div style='margin-top:8px'><a href='/index.php?module=admin_login'><small>Admin</small></a></div>";
    }
    $lines = @file($log, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
    $recent = array_slice($lines, -5);
    $out = "<div class='muted'><small>Recent events</small></div><ul style='margin:6px 0 0 0;padding-left:18px'>";
    foreach ($recent as $ln) {
        $out .= "<li><small>" . htmlspecialchars($ln, ENT_QUOTES, 'UTF-8') . "</small></li>";
    }
    $out .= "</ul>";
    $out .= "<div style='margin-top:8px'><a href='/index.php?module=admin_nukesecurity'><small>Open NukeSecurity</small></a></div>";
    return $out;
};
