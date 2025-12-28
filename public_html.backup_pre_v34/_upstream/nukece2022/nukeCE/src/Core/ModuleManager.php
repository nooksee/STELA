<?php
namespace NukeCE\Core;

use RuntimeException;

/**
 * The ModuleManager loads and manages modules from the modules directory.
 * It is responsible for discovering module classes and instantiating
 * them on demand. Modules are loaded lazily to reduce overhead.
 */
class ModuleManager
{
    /**
     * @var string Absolute path to the modules directory
     */
    private $modulesPath;

    /**
     * @var ModuleInterface[] Loaded module instances keyed by name
     */
    private $modules = [];

    /**
     * Constructor.
     *
     * @param string $modulesPath Absolute path to the modules directory
     */
    public function __construct(string $modulesPath)
    {
        $this->modulesPath = rtrim($modulesPath, '/');
    }

    /**
     * Returns an instance of the requested module. If the module has not
     * been loaded previously it will be discovered and instantiated.
     *
     * @param string $name Name of the module (e.g. "news")
     * @return ModuleInterface
     * @throws RuntimeException If the module cannot be loaded
     */
    public function getModule(string $name): ModuleInterface
    {
        $name = strtolower($name);
        if (isset($this->modules[$name])) {
            return $this->modules[$name];
        }
        $moduleDir = $this->modulesPath . '/' . $name;
        $classFile = $moduleDir . '/' . ucfirst($name) . 'Module.php';
        $className = 'NukeCE\\Modules\\' . ucfirst($name) . '\\' . ucfirst($name) . 'Module';
        if (!file_exists($classFile)) {
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
}