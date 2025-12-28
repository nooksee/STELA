<?php
/**
 * PHP-Nuke CE
 * Admin Clubs
 */
require_once __DIR__ . '/../../mainfile.php';
require_once NUKECE_ROOT . '/includes/admin_ui.php';

use NukeCE\Core\Model;

AdminUi::requireAdmin();
include_once NUKECE_ROOT . '/includes/header.php';

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
  PRIMARY KEY (id),
  UNIQUE KEY uq_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

AdminUi::header('Clubs', [
  '/admin' => 'Dashboard',
  '/admin.php?op=logout' => 'Logout',
]);

AdminUi::groupStart('Overview', 'Clubs are sub-communities inside the portal.');
$st = $pdo->query("SELECT id,name,is_private,requires_approval,owner_username FROM clubs ORDER BY id DESC LIMIT 200");
$rows = $st->fetchAll(PDO::FETCH_ASSOC) ?: [];
if (!$rows) echo '<p>No clubs yet.</p>';
else {
  echo '<table><thead><tr><th>ID</th><th>Name</th><th>Owner</th><th>Private</th><th>Approval</th><th>Link</th></tr></thead><tbody>';
  foreach ($rows as $r) {
    echo '<tr>';
    echo '<td>'.(int)$r['id'].'</td>';
    echo '<td>'.htmlspecialchars((string)$r['name'], ENT_QUOTES, 'UTF-8').'</td>';
    echo '<td>'.htmlspecialchars((string)$r['owner_username'], ENT_QUOTES, 'UTF-8').'</td>';
    echo '<td>'.(((int)$r['is_private']===1)?'yes':'no').'</td>';
    echo '<td>'.(((int)$r['requires_approval']===1)?'yes':'no').'</td>';
    echo '<td><a href="/index.php?module=clubs&op=view&id='.(int)$r['id'].'">View</a></td>';
    echo '</tr>';
  }
  echo '</tbody></table>';
}
AdminUi::groupEnd();

AdminUi::footer();
include_once NUKECE_ROOT . '/includes/footer.php';
