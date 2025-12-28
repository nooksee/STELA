<?php
namespace NukeCE\Core;

use RuntimeException;

/**
 * Basic front controller routing. The router parses the request URI,
 * determines which module should handle the request, and delegates
 * execution to that module. Routes take the form /index.php?module=foo
 * or /index.php/foo/bar.
 */
class Router
{
    /**
     * @var ModuleManager
     */
    private $moduleManager;

    /**
     * Constructor.
     *
     * @param ModuleManager $manager
     */
    public function __construct(ModuleManager $manager)
    {
        $this->moduleManager = $manager;
    }

    /**
     * Dispatch the current request. If the requested module is not
     * provided, the 'home' module is used. Additional path segments
     * are passed to the module's handle() method.
     *
     * @return void
     */
    public function dispatch(): void
    {
        // Determine module and parameters from the query string or path info
        $module = 'home';
        $params = [];

        if (isset($_GET['module'])) {
            $module = preg_replace('/[^a-zA-Z0-9_]/', '', $_GET['module']);
            $params = isset($_GET['params']) ? explode('/', trim($_GET['params'], '/')) : [];
        } elseif (!empty($_SERVER['PATH_INFO'])) {
            $segments = array_values(array_filter(explode('/', $_SERVER['PATH_INFO']), 'strlen'));
            if (!empty($segments)) {
                $module = array_shift($segments);
                $params = $segments;
            }
        }

        try {
            $moduleInstance = $this->moduleManager->getModule($module);
            $moduleInstance->handle($params);
        } catch (RuntimeException $e) {
            http_response_code(404);
            echo "<h1>404 Not Found</h1><p>" . htmlspecialchars($e->getMessage()) . "</p>";
        }
    }
}