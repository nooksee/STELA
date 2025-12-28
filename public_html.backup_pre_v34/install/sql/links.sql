-- nukeCE Links module schema
-- Prefix handling: replace `nuke_` with your configured table prefix if different.

CREATE TABLE IF NOT EXISTS nuke_links_categories (
  cid INT UNSIGNED NOT NULL AUTO_INCREMENT,
  parent_cid INT UNSIGNED NOT NULL DEFAULT 0,
  title VARCHAR(150) NOT NULL,
  description TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  PRIMARY KEY (cid),
  KEY idx_parent (parent_cid),
  KEY idx_title (title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS nuke_links (
  lid INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cid INT UNSIGNED NOT NULL,
  url VARCHAR(2048) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  submitter_uid INT UNSIGNED NOT NULL DEFAULT 0,
  status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  health ENUM('unknown','ok','redirect','broken') NOT NULL DEFAULT 'unknown',
  last_checked_at DATETIME NULL,
  hits INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  PRIMARY KEY (lid),
  KEY idx_cid_status (cid, status),
  KEY idx_status (status),
  KEY idx_health (health)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS nuke_links_tags (
  lid INT UNSIGNED NOT NULL,
  tag VARCHAR(80) NOT NULL,
  PRIMARY KEY (lid, tag),
  KEY idx_tag (tag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
