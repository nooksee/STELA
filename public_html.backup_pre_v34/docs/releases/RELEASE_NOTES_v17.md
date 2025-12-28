# nukeCE v17 (Track A: Hardening — Config Paths Adoption + NukeSecurity Health)

Build date (UTC): 2025-12-27T01:50:25.294077Z

## Changes

### Downloads uploads path normalization
- `admin_downloads` now uses `uploads_dir` (config key) instead of hard-coded `files/downloads`.
- Files go to: `<uploads_dir>/downloads/`

### NukeSecurity health view
- Added a "Paths & permissions" panel in `admin_nukesecurity`:
  - shows existence/writability for `uploads_dir`, `cache_dir`, `tmp_dir`, `logs_dir`, `data_dir`
  - shows installer lock flag presence (`config/ALLOW_INSTALL`)

## Notes
- This release does not attempt to migrate existing files from `files/downloads` automatically.
