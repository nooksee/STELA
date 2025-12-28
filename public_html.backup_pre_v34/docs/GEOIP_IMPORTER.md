# GeoIP Importer (Staged + Resumable)

Generated: 2025-12-27T05:54:14.888553Z

## What it does
Admin UI to upload and stage GeoLite2 CSV files and import them in chunks.

Supports:
- Country Locations: `GeoLite2-Country-Locations-en.csv`
- Country Blocks: IPv4/IPv6
- ASN Blocks: IPv4/IPv6

## Where it lives
- UI: Admin → NukeSecurity → GeoIP Import
- Implementation: `public_html/src/Security/GeoIpImporter.php`

## Staging location
- `<uploads_dir>/nukesecurity/geoip/`
  - `geoip_import_state.json`
  - `locations.csv`, `country_v4.csv`, `country_v6.csv`, `asn_v4.csv`, `asn_v6.csv`

## v26 polish
- Header validation on stage
- Run multiple chunks (auto-step)
- Optional cleanup of staged files after success
- Simple progress indicators
