<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

use RuntimeException;
use NukeCE\Security\AuthGate;

final class Router
{
    public function __construct(private ModuleManager $moduleManager) {}

    public function dispatch(): void
    {
        [$module, $params] = $this->resolve();

        try {
            if (strpos($module, 'admin_') === 0 && $module !== 'admin_login') {
                AuthGate::requireAdminOrRedirect();
            }
            $this->moduleManager->getModule($module)->handle($params);
        } catch (RuntimeException $e) {
            http_response_code(404);
            echo "<h1>404 Not Found</h1><p>" . htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8') . "</p>";
        }
    }

    /** @return array{0:string,1:array} */
    private function resolve(): array
    {
        if (!empty($_GET['module'])) {
            $m = (string)$_GET['module'];
            return [$this->sanitize($m), $_GET];
        }

        $uri = (string)($_SERVER['REQUEST_URI'] ?? '/');
        $path = parse_url($uri, PHP_URL_PATH);
        $path = is_string($path) ? $path : '/';
        $path = preg_replace('#^/index\.php#', '', $path) ?? $path;
        $path = trim($path, '/');

        if ($path === '') {
            return ['home', []];
        }

        $parts = array_values(array_filter(explode('/', $path), fn($p) => $p !== ''));
        $module = $this->sanitize((string)($parts[0] ?? 'home'));
        $tail = array_slice($parts, 1);

        $params = ['_path' => $path];
        if (!empty($tail)) {
            $params['action'] = (string)$tail[0];
            $params['segments'] = $tail;
        }

        return [$module, $params];
    }

    private function sanitize(string $m): string
    {
        $m = strtolower($m);
        $m = preg_replace('/[^a-z0-9_\-]/', '', $m) ?? $m;
        return $m ?: 'home';
    }
}
