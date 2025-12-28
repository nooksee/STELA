<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

use PDO;
use PDOException;

/**
 * Base model providing database connectivity. All models can
 * extend this class to access a shared PDO instance configured
 * using values defined in the config file. The PDO instance
 * utilises prepared statements by default for security.
 */
abstract class Model
{
    /**
     * @var PDO|null Shared PDO instance
     */
    protected static $pdo;

    /**
     * Get or create the shared PDO instance using the configuration
     * defined in config/config.php. If connection fails, an exception
     * will be thrown.
     *
     * @return PDO
     */
    protected function getConnection(): PDO
    {
        if (self::$pdo === null) {
            // load configuration
            $config = include __DIR__ . '/../../config/config.php';
            $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $config['db_host'], $config['db_name']);
            try {
                self::$pdo = new PDO($dsn, $config['db_user'], $config['db_pass']);
                self::$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            } catch (PDOException $e) {
                throw new PDOException('Database connection failed: ' . $e->getMessage());
            }
        }
        return self::$pdo;
    }
}