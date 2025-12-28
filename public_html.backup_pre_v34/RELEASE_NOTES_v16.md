# nukeCE v16 (Track A: Hardening — Writable Dirs Wiring)

Build date (UTC): 2025-12-27T00:57:54.230433Z

## Changes

### Admin → Maintenance: runtime writability check
- Added a "Writable directories" panel to `modules/admin_maintenance`.
- Reads canonical paths from `NukeCE\Core\AppConfig`:
  - `uploads_dir`, `cache_dir`, `tmp_dir`, `logs_dir`
- Added an action to create/verify these directories (mkdir 0755).

### Config-driven paths
- Admin Maintenance now uses config keys instead of hard-coded `$ROOT` paths for tmp/log/cache.

## Notes
- `.htaccess` enforcement is Apache-only; replicate rules for Nginx.
