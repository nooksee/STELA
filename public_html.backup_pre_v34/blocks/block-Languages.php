<?php
/**
 * Languages Block (nukeCE Gold)
 */

declare(strict_types=1);

if (!defined('BLOCK_FILE')) {
    exit;
}

require_once __DIR__ . '/../includes/BlockGold.php';

// Classic PHP-Nuke language handling usually uses $currentlang and a lang selector.
$available = [];
$langDir = __DIR__ . '/../language';
if (is_dir($langDir)) {
    foreach (glob($langDir . '/lang-*.php') ?: [] as $f) {
        $base = basename($f);
        if (preg_match('/^lang-([a-zA-Z_\-]+)\.php$/', $base, $m)) {
            $available[] = $m[1];
        }
    }
}
$available = array_values(array_unique($available));

global $currentlang;
$current = $currentlang ?: ($available[0] ?? 'english');

$options = '';
foreach ($available as $lang) {
    $sel = ($lang === $current) ? ' selected' : '';
    $options .= '<option value="' . BlockGold::esc($lang) . '"' . $sel . '>' . BlockGold::esc(ucfirst($lang)) . '</option>';
}

if ($options === '') {
    $content = '<div class="nukece-muted">No language packs found.</div>';
} else {
    $content = '<form class="nukece-languages" action="' . BlockGold::esc(BlockGold::url('index.php')) . '" method="get">'
        . '<div class="nukece-form-row">'
        . '<select class="nukece-input" name="newlang" onchange="this.form.submit()">'
        . $options
        . '</select>'
        . '</div>'
        . '<noscript><div class="nukece-form-actions"><input class="nukece-btn" type="submit" value="Set" /></div></noscript>'
        . '</form>';
}
