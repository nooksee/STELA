<?php
/**
 * PHP-Nuke CE
 * Block: Latest Club News
 */
if (!defined('NUKECE_ROOT')) { return; }
use NukeCE\Core\Model;

$pdo = Model::pdo();
$pdo->exec("CREATE TABLE IF NOT EXISTS club_news (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  club_id INT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL,
  created_by VARCHAR(64) NOT NULL,
  title VARCHAR(190) NOT NULL,
  body MEDIUMTEXT NULL,
  PRIMARY KEY (id),
  KEY idx_club (club_id),
  KEY idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

$st = $pdo->query("SELECT club_id,title FROM club_news ORDER BY id DESC LIMIT 10");
$rows = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];

$content = '<div class="block"><strong>Club News</strong><ul>';
if (!$rows) $content .= '<li>No club news yet</li>';
else {
  foreach ($rows as $r) {
    $content .= '<li><a href="/index.php?module=clubs&op=view&id='.(int)$r['club_id'].'">'.
      htmlspecialchars((string)$r['title'], ENT_QUOTES, 'UTF-8').'</a></li>';
  }
}
$content .= '</ul></div>';
