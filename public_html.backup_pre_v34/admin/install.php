<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/db.php';

$pdo = nukece_db();

$pdo->exec("
CREATE TABLE IF NOT EXISTS nukece_users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL UNIQUE,
  pass_hash VARCHAR(255) NOT NULL,
  role VARCHAR(32) NOT NULL DEFAULT 'admin',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
");

$pdo->exec("
CREATE TABLE IF NOT EXISTS nukece_sessions (
  id CHAR(64) NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  PRIMARY KEY (id),
  INDEX (user_id),
  CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES nukece_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
");

$adminUser = 'admin';
$adminPass = 'admin123'; // change after first login

$stmt = $pdo->prepare("SELECT id FROM nukece_users WHERE username=?");
$stmt->execute([$adminUser]);
if (!$stmt->fetch()) {
    $hash = password_hash($adminPass, PASSWORD_DEFAULT);
    $ins = $pdo->prepare("INSERT INTO nukece_users (username, pass_hash, role) VALUES (?, ?, 'admin')");
    $ins->execute([$adminUser, $hash]);
}

echo "<pre>Install OK.\nAdmin: admin\nPass: admin123\nNext: /admin/login.php\nThen: rename/delete admin/install.php</pre>";
