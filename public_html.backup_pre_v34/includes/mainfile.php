<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Legacy compatibility bootstrap.
 * Modern entrypoint: /index.php
 */
declare(strict_types=1);

define('NUKECE_ROOT', __DIR__);
require_once NUKECE_ROOT . '/autoload.php';

// Initialize config (no output).
\NukeCE\Core\AppConfig::all();
