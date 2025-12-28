<?php
/**
 * PHP-Nuke CE (Community Edition)
 * Links DB helper compatible with classic $db.
 */

declare(strict_types=1);

namespace NukeCE\Links;

final class LinksDb
{
    private $db;
    private string $prefix;

    public function __construct($db, string $prefix)
    {
        $this->db = $db;
        $this->prefix = $prefix;
    }

    public function t(string $name): string
    {
        return $this->prefix . $name;
    }

    public function escape(string $s): string
    {
        if (is_object($this->db) && method_exists($this->db, 'sql_escape_string')) {
            return $this->db->sql_escape_string($s);
        }
        if (is_object($this->db) && method_exists($this->db, 'escape_string')) {
            return $this->db->escape_string($s);
        }
        return addslashes($s);
    }

    public function query(string $sql)
    {
        if (is_object($this->db) && method_exists($this->db, 'sql_query')) {
            return $this->db->sql_query($sql);
        }
        if (is_object($this->db) && method_exists($this->db, 'query')) {
            return $this->db->query($sql);
        }
        throw new \RuntimeException('No database adapter found.');
    }

    public function fetch($res): ?array
    {
        if (is_object($this->db) && method_exists($this->db, 'sql_fetchrow')) {
            $row = $this->db->sql_fetchrow($res);
            return $row ?: null;
        }
        if (is_object($res) && method_exists($res, 'fetch_assoc')) {
            $row = $res->fetch_assoc();
            return $row ?: null;
        }
        return null;
    }

    public function all(string $sql): array
    {
        $res = $this->query($sql);
        $out = [];
        while ($row = $this->fetch($res)) {
            $out[] = $row;
        }
        return $out;
    }

    public function one(string $sql): ?array
    {
        $res = $this->query($sql);
        return $this->fetch($res);
    }
}
