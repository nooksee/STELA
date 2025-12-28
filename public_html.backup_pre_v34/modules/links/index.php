<?php
/**
 * PHP-Nuke CE (Community Edition)
 * Links module (modernized Web Links)
 */

define('MODULE_FILE', true);

// Typical nuke entry include (best-effort compatibility)
$root = dirname(__DIR__, 2);
if (is_file($root . '/mainfile.php')) {
    require_once $root . '/mainfile.php';
} elseif (is_file($root . '/includes/mainfile.php')) {
    require_once $root . '/includes/mainfile.php';
}

require_once __DIR__ . '/lib/LinksController.php';

$op = $_GET['op'] ?? 'index';
$controller = new \NukeCE\Links\LinksController();
$controller->dispatch($op);
