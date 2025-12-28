<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

use RuntimeException;

final class ModuleManager
{
    /** @var array<string, ModuleInterface> */
    private array $modules = [];

    public function __construct(private string $modulesPath)
    {
        $this->modulesPath = rtrim($this->modulesPath, '/\\');
    }

    public function getModule(string $name): ModuleInterface
    {
        $name = strtolower(preg_replace('/[^a-z0-9_\-]/i', '', $name) ?? $name);
        if ($name === '') $name = 'home';

        // Enforce module allowlist (prevents "ghost modules" + preserves clean installs).
        if (!ModulePolicy::isEnabled($name) && $name !== 'admin_login') {
            throw new RuntimeException("Module '$name' is disabled");
        }

        if (isset($this->modules[$name])) {
            return $this->modules[$name];
        }

        $className = $this->classNameFor($name);
        $classFile = $this->fileFor($name);

        if (!is_file($classFile)) {
            throw new RuntimeException("Module '$name' not found");
        }

        require_once $classFile;

        if (!class_exists($className)) {
            throw new RuntimeException("Module class '$className' does not exist");
        }

        $module = new $className();

        if (!$module instanceof ModuleInterface) {
            throw new RuntimeException("Module '$name' must implement ModuleInterface");
        }

        $this->modules[$name] = $module;
        return $module;
    }

    private function fileFor(string $name): string
    {
        $dir = $this->modulesPath . '/' . $name;
        $base = $this->studly($name) . 'Module.php';
        return $dir . '/' . $base;
    }

    private function classNameFor(string $name): string
    {
        $studly = $this->studly($name);
        return "NukeCE\\Modules\\{$studly}\\{$studly}Module";
    }

    private function studly(string $s): string
    {
        $s = str_replace(['-','_'], ' ', $s);
        $s = ucwords($s);
        return str_replace(' ', '', $s);
    }
}
