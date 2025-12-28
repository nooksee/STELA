<?php
/**
 * PHP-Nuke CE
 * Block: Top Clubs
 */
if (!defined('NUKECE_ROOT')) { return; }
use NukeCE\Core\Model;

$pdo = Model::pdo();
$pdo->exec("CREATE TABLE IF NOT EXISTS clubs (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  created_at DATETIME NOT NULL,
  owner_username VARCHAR(64) NOT NULL,
  name VARCHAR(120) NOT NULL,
  slug VARCHAR(140) NOT NULL,
  description MEDIUMTEXT NULL,
  is_private TINYINT(1) NOT NULL DEFAULT 0,
  requires_approval TINYINT(1) NOT NULL DEFAULT 0,
  logo_path VARCHAR(255) NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

$st = $pdo->query("SELECT id,name FROM clubs WHERE is_private=0 ORDER BY id DESC LIMIT 10");
$rows = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];

$content = '<div class="block"><strong>Clubs</strong><ul>';
if (!$rows) {
  $content .= '<li>No clubs yet</li>';
} else {
  foreach ($rows as $r) {
    $content .= '<li><a href="/index.php?module=clubs&op=view&id='.(int)$r['id'].'">'.
      htmlspecialchars((string)$r['name'], ENT_QUOTES, 'UTF-8').'</a></li>';
  }
}
$content .= '</ul></div>';
