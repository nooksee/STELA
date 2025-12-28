<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */
declare(strict_types=1);

define('NUKECE_ROOT', __DIR__);
require_once NUKECE_ROOT . '/autoload.php';
require_once NUKECE_ROOT . '/includes/security_gate.php';

use NukeCE\Security\AuthGate;

// Require admin session; login handled by module=admin_login
AuthGate::requireAdminOrRedirect();

$op = isset($_GET['op']) ? (string)$_GET['op'] : '';

$map = [
    '' => 'admin_settings',
    'dashboard' => 'admin_settings',
    'settings' => 'admin_settings',
  'ai' => 'admin_ai',
  'reference' => 'admin_reference',
  'clubs' => 'admin_clubs',
    'moderation' => 'admin_moderation',
    'themes' => 'admin_themes',
    'blocks' => 'admin_blocks',
    'forums' => 'admin_forums',
    'security' => 'admin_nukesecurity',
    'mobile' => 'admin_mobile',
    'logout' => '__logout__',
];

if (!array_key_exists($op, $map)) {
    // Unknown op: show a safe dashboard with links
    header('Content-Type: text/html; charset=utf-8');
    echo "<!doctype html><html><head><meta charset=\"utf-8\"><title>Admin - nukeCE</title>";
    echo "<style>body{font-family:system-ui,Segoe UI,Arial,sans-serif;margin:24px;max-width:900px}          .card{border:1px solid #ddd;border-radius:12px;padding:16px;margin:12px 0}          a{color:#0645ad;text-decoration:none} a:hover{text-decoration:underline}          ul{margin:8px 0 0 18px}</style></head><body>";
    echo "<h1>Admin</h1><p>Unknown operation: <code>" . htmlspecialchars($op, ENT_QUOTES, 'UTF-8') . "</code></p>";
    echo "<div class='card'><strong>Go to:</strong><ul>";
    echo "<li><a href='/admin.php?op=settings'>Settings</a></li>";
    echo "<li><a href='/admin.php?op=moderation'>Moderation</a></li>";
    echo "<li><a href='/admin.php?op=themes'>Themes</a></li>";
    echo "<li><a href='/admin.php?op=blocks'>Blocks</a></li>";
    echo "<li><a href='/admin.php?op=forums'>Forums Admin</a></li>";
    echo "<li><a href='/admin.php?op=security'>NukeSecurity</a></li>";
    echo "<li><a href='/admin.php?op=mobile'>Mobile</a></li>";
    echo "<li><a href='/admin.php?op=logout'>Logout</a></li>";
    echo "</ul></div></body></html>";
    exit;
}

if ($map[$op] === '__logout__') {
    AuthGate::logout();
    header('Location: /');
    exit;
}

// Forward to modern module router while preserving other query params safely.
$params = $_GET;
unset($params['op']);
$params['module'] = $map[$op];

$qs = http_build_query($params);
header('Location: /index.php' . ($qs ? ('?' . $qs) : ''));
exit;
