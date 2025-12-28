<?php
/**
 * PHP-Nuke CE
 */
require_once __DIR__ . '/../../mainfile.php';
include_once NUKECE_ROOT . '/includes/header.php';
$path = NUKECE_ROOT . '/docs/CREDITS.md';
echo '<h1>Credits</h1>';
if (is_file($path)) {
    echo '<pre style="white-space:pre-wrap">' . htmlspecialchars(file_get_contents($path), ENT_QUOTES, 'UTF-8') . '</pre>';
} else {
    echo '<p>Credits file not found.</p>';
}
include_once NUKECE_ROOT . '/includes/footer.php';
