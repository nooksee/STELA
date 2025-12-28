<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Classic-style admin menu (façade). Safe, static links.
 */
declare(strict_types=1);

use NukeCE\Security\AuthGate;

define('NUKECE_ROOT', dirname(__DIR__));
require_once NUKECE_ROOT . '/autoload.php';
AuthGate::requireAdminOrRedirect();

header('Content-Type: text/html; charset=utf-8');
?>
<ul class="nukece-admin-menu">
  <li><a href="/admin.php?op=settings">Settings</a></li>
  <li><a href="/admin.php?op=moderation">Moderation</a></li>
  <li><a href="/admin.php?op=themes">Themes</a></li>
  <li><a href="/admin.php?op=blocks">Blocks</a></li>
  <li><a href="/admin.php?op=forums">Forums Admin</a></li>
  <li><a href="/admin.php?op=security">NukeSecurity</a></li>
  <li><a href="/admin.php?op=mobile">Mobile</a></li>
  <li><a href="/admin.php?op=logout">Logout</a></li>
</ul>
