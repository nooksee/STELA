<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

/**
 * Interface that all modules must implement. Modules are self‑contained
 * packages of functionality that can register routes and output
 * content for the user. By adhering to this interface, third‑party
 * developers can extend nukeCE in a consistent way.
 */
interface ModuleInterface
{
    /**
     * Returns the unique identifier for the module. This identifier
     * should be lower‑case and free of spaces, and it is used for
     * routing and configuration.
     */
    public function getName(): string;

    /**
     * Handle a request for this module. The router passes the path
     * segments following the module name into this method. Modules
     * are responsible for rendering their own output or delegating
     * to controllers/views.
     *
     * @param array $params Path segments following the module name.
     * @return void
     */
    public function handle(array $params): void;
}