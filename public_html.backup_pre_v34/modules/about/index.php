<?php
/**
 * PHP-Nuke CE
 */
require_once __DIR__ . '/../../mainfile.php';
include_once NUKECE_ROOT . '/includes/header.php';
$path = NUKECE_ROOT . '/docs/MANIFESTO.md';
echo '<h1>About nukeCE</h1>';
if (is_file($path)) {
    echo '<pre style="white-space:pre-wrap">' . htmlspecialchars(file_get_contents($path), ENT_QUOTES, 'UTF-8') . '</pre>';
} else {
    echo '<p>Manifesto file not found.</p>';
}
include_once NUKECE_ROOT . '/includes/footer.php';
