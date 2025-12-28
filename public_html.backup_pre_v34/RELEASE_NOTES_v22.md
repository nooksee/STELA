# nukeCE v22 (GeoIP importer + ASN support)

Build date (UTC): 2025-12-27T04:32:06.651887Z

## Changes

### GeoIP importer upgraded to range tables (fast lookup)
- Admin importer now populates:
  - `nsec_geoip_country_v4` / `nsec_geoip_country_v6`
- Added helper CIDR → range conversion (IPv4/IPv6).

### ASN importer added (GeoLite2 ASN)
- Admin panel now supports upload/import of:
  - ASN IPv4 blocks
  - ASN IPv6 blocks
- Stores:
  - `asn` number
  - `org` (autonomous_system_organization)
  - ranges for v4/v6

### Runtime lookup implemented
- `src/Security/GeoIp.php` now implements:
  - `GeoIp::countryForIp($ip)`
  - `GeoIp::asnForIp($ip)`
- Uses MySQL `INET_ATON()` / `INET6_ATON()` for lookups.
- Fail-open by design.

### GuardRequest logs enriched
- `NukeSecurity::guardRequest()` now includes ASN/org in GeoIP log metadata (when available).

### Installer SQL reference
- Added `install/geoip_schema.sql` (reference schema; runtime still uses ensureGeoIpSchema()).
