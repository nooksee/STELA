-- nukeCE NukeSecurity GeoIP/ASN schema (v22)
CREATE TABLE IF NOT EXISTS nsec_geoip_locations (
  geoname_id INT UNSIGNED NOT NULL PRIMARY KEY,
  country_iso_code CHAR(2) NULL,
  country_name VARCHAR(128) NULL,
  updated_at DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS nsec_geoip_country_v4 (
  start_int INT UNSIGNED NOT NULL,
  end_int INT UNSIGNED NOT NULL,
  iso2 CHAR(2) NULL,
  network VARCHAR(64) NOT NULL,
  updated_at DATETIME NOT NULL,
  PRIMARY KEY (start_int, end_int),
  KEY idx_iso2 (iso2),
  KEY idx_range (start_int, end_int)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS nsec_geoip_country_v6 (
  start_bin VARBINARY(16) NOT NULL,
  end_bin VARBINARY(16) NOT NULL,
  iso2 CHAR(2) NULL,
  network VARCHAR(64) NOT NULL,
  updated_at DATETIME NOT NULL,
  PRIMARY KEY (start_bin, end_bin),
  KEY idx_iso2 (iso2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS nsec_geoip_asn_v4 (
  start_int INT UNSIGNED NOT NULL,
  end_int INT UNSIGNED NOT NULL,
  asn INT UNSIGNED NULL,
  org VARCHAR(255) NULL,
  network VARCHAR(64) NOT NULL,
  updated_at DATETIME NOT NULL,
  PRIMARY KEY (start_int, end_int),
  KEY idx_asn (asn),
  KEY idx_range (start_int, end_int)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS nsec_geoip_asn_v6 (
  start_bin VARBINARY(16) NOT NULL,
  end_bin VARBINARY(16) NOT NULL,
  asn INT UNSIGNED NULL,
  org VARCHAR(255) NULL,
  network VARCHAR(64) NOT NULL,
  updated_at DATETIME NOT NULL,
  PRIMARY KEY (start_bin, end_bin),
  KEY idx_asn (asn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS nsec_country_rules (
  iso2 CHAR(2) NOT NULL,
  action ENUM('allow','flag','block') NOT NULL DEFAULT 'allow',
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  note VARCHAR(255) NULL,
  updated_at DATETIME NOT NULL,
  PRIMARY KEY (iso2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
