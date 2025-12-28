<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

require_once __DIR__ . '/../src/Core/Model.php';

use NukeCE\Core\Model;

$pdo = Model::db();
$tn = fn(string $t) => Model::tn($t);

$queries = [];

// Content (Pages)
$queries[] = "CREATE TABLE IF NOT EXISTS `{$tn('content_categories')}` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  slug VARCHAR(140) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_slug (slug),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

$queries[] = "CREATE TABLE IF NOT EXISTS `{$tn('content_tags')}` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL,
  slug VARCHAR(100) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_slug (slug),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

$queries[] = "CREATE TABLE IF NOT EXISTS `{$tn('content_pages')}` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(180) NOT NULL,
  title VARCHAR(255) NOT NULL,
  summary VARCHAR(500) NOT NULL DEFAULT '',
  body MEDIUMTEXT NOT NULL,
  status ENUM('draft','published') NOT NULL DEFAULT 'draft',
  category_id INT UNSIGNED NULL,
  author VARCHAR(120) NOT NULL DEFAULT '',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  UNIQUE KEY uq_slug (slug),
  KEY idx_status (status),
  KEY idx_cat (category_id),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

$queries[] = "CREATE TABLE IF NOT EXISTS `{$tn('content_page_tags')}` (
  page_id INT UNSIGNED NOT NULL,
  tag_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (page_id, tag_id),
  KEY idx_tag (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

// Reference (Knowledge Base)
$queries[] = "CREATE TABLE IF NOT EXISTS `{$tn('ref_tags')}` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL,
  slug VARCHAR(100) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_slug (slug),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

$queries[] = "CREATE TABLE IF NOT EXISTS `{$tn('ref_entries')}` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(180) NOT NULL,
  term VARCHAR(255) NOT NULL,
  definition MEDIUMTEXT NOT NULL,
  status ENUM('draft','published') NOT NULL DEFAULT 'draft',
  curator_note VARCHAR(500) NOT NULL DEFAULT '',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  UNIQUE KEY uq_slug (slug),
  KEY idx_status (status),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

$queries[] = "CREATE TABLE IF NOT EXISTS `{$tn('ref_entry_tags')}` (
  entry_id INT UNSIGNED NOT NULL,
  tag_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (entry_id, tag_id),
  KEY idx_tag (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

$queries[] = "CREATE TABLE IF NOT EXISTS `{$tn('ref_queue')}` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kind ENUM('term','definition','link') NOT NULL DEFAULT 'term',
  proposed_term VARCHAR(255) NOT NULL,
  proposed_definition MEDIUMTEXT NOT NULL,
  source_json MEDIUMTEXT NOT NULL,
  status ENUM('new','reviewing','approved','rejected') NOT NULL DEFAULT 'new',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reviewed_at DATETIME NULL,
  reviewer VARCHAR(120) NOT NULL DEFAULT '',
  reviewer_notes VARCHAR(500) NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  KEY idx_status (status),
  KEY idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

$ok = 0;
$errs = [];
foreach ($queries as $sql) {
  try {
    $pdo->exec($sql);
    $ok++;
  } catch (Throwable $e) {
    $errs[] = $e->getMessage();
  }
}

header('Content-Type: text/plain; charset=utf-8');
echo "Setup complete. OK statements: {$ok}/" . count($queries) . "\n";
if ($errs) {
  echo "\nErrors:\n- " . implode("\n- ", $errs) . "\n";
}
