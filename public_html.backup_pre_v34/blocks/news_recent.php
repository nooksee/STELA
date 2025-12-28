<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

use NukeCE\Core\Model;

return function(array $ctx): string {
    try {
        $m = new Model();
        $pdo = $m->getConnection();
        $stmt = $pdo->query("SELECT id, title, created_at FROM news ORDER BY id DESC LIMIT 5");
        $rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
    } catch (Throwable $e) {
        $rows = [];
    }

    if (!$rows) {
        return "<div class='muted'><small>No news yet.</small></div>";
    }

    $out = "<ul style='margin:0;padding-left:18px'>";
    foreach ($rows as $r) {
        $id = (int)($r['id'] ?? 0);
        $t = htmlspecialchars((string)($r['title'] ?? 'Untitled'), ENT_QUOTES, 'UTF-8');
        $out .= "<li><a href='/index.php?module=news&params={$id}'>{$t}</a></li>";
    }
    $out .= "</ul><div style='margin-top:8px'><a href='/index.php?module=news'><small>More…</small></a></div>";
    return $out;
};
