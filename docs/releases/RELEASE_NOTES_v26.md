# nukeCE v26 (GeoIP importer UI + polish)

Build date (UTC): 2025-12-27T05:54:14.889095Z

## Changes
- Added staged, resumable GeoIP importer:
  - `src/Security/GeoIpImporter.php`
- Added Admin UI page: **Admin → NukeSecurity → GeoIP Import**
  - Upload & stage CSVs (header-validated)
  - Start/Resume import (chunked)
  - Run multiple chunks (auto-step)
  - Optional cleanup of staged files after success
  - Simple progress indicators

## Notes
- This importer assumes your GeoIP/ASN schema tables exist from the earlier GeoIP work (v22).
