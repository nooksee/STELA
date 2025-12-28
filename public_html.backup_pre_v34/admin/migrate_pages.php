<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/auth.php';

nukece_require_admin();
$pdo = nukece_db();

$pdo->exec("
CREATE TABLE IF NOT EXISTS nukece_pages (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(128) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  body MEDIUMTEXT NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
");

echo "<pre>OK: nukece_pages ready.\nThen: rename/delete admin/migrate_pages.php</pre>";
