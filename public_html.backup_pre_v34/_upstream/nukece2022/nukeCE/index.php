<?php
/**
 * Front controller for NukeCE.
 * This script is the single entry point for all user‑facing
 * requests. It bootstraps the application, registers the autoloader,
 * and delegates control to the router.
 */

// Turn on strict error reporting in development environments
error_reporting(E_ALL);
ini_set('display_errors', 'On');

// Define project root for convenience
define('NUKECE_ROOT', __DIR__);

// Register autoloader
require_once NUKECE_ROOT . '/autoload.php';

use NukeCE\Core\ModuleManager;
use NukeCE\Core\Router;

// Instantiate the module manager pointing at the modules directory
$modulesPath = NUKECE_ROOT . '/modules';
$manager = new ModuleManager($modulesPath);

// Dispatch the current request
$router = new Router($manager);
$router->dispatch();