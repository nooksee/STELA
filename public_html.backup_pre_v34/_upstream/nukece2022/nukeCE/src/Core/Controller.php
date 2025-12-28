<?php
namespace NukeCE\Core;

/**
 * Base controller class providing utility methods for rendering
 * templates and redirecting. Controllers can extend this class
 * to access common functionality.
 */
abstract class Controller
{
    /**
     * Render a PHP template located in the views directory. Templates
     * should not execute business logic; instead they receive data via
     * the $data parameter and output HTML.
     *
     * @param string $template Template filename relative to the module's
     *                         views directory, without the .php extension.
     * @param array $data Associative array of variables to extract into
     *                    the template's scope.
     */
    protected function render(string $template, array $data = []): void
    {
        extract($data);
        include $template;
    }

    /**
     * Redirect to another URL.
     *
     * @param string $url
     */
    protected function redirect(string $url): void
    {
        header('Location: ' . $url);
        exit;
    }
}