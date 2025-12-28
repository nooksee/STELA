<?php
// Safety lock: prevent installer scripts from running after setup.
$__nukece_lock = __DIR__ . '/LOCK';
if (is_file($__nukece_lock)) {
    header('HTTP/1.1 403 Forbidden');
    exit('Installer is locked. Remove install/LOCK to run installers.');
}

declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

define('NUKECE_ROOT', realpath(__DIR__ . '/..') ?: (__DIR__ . '/..'));

require_once NUKECE_ROOT . '/autoload.php';

use NukeCE\Security\NukeSecurityConfig;

$cfg = NukeSecurityConfig::load(NUKECE_ROOT);
NukeSecurityConfig::save(NUKECE_ROOT, $cfg);

echo "Wrote " . NukeSecurityConfig::FILE . "\n";
if (!empty($cfg['compat']['legacy_php_sources'])) echo "Legacy PHP sources: " . implode(', ', $cfg['compat']['legacy_php_sources']) . "\n";
if (!empty($cfg['compat']['legacy_db_sources'])) echo "Legacy DB sources: " . implode(', ', $cfg['compat']['legacy_db_sources']) . "\n";

if (!empty($cfg['compat']['migrated'])) {
    echo "Migrated from: " . implode(', ', (array)($cfg['compat']['migrated_from'] ?? [])) . "\n";
} else {
    echo "No legacy sources detected.\n";
}
