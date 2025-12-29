# nukeCE v11 (Track A: Admin coherence + Security boundaries)

Build date (UTC): 2025-12-26T22:59:09.259700Z

## Scope
- Admin module coherence (single pattern: modules/admin_*)
- Security boundary cleanup
- NukeSecurity wiring audit

## Changes

### Legacy module cleanup
- `modules/encyclopedia` removed from active modules and archived under `modules/_legacy/`.
- Added `includes/legacy_routes.php` and router-level redirect for `module=encyclopedia` -> `module=reference`.

### Admin coherence
- Normalized any `admin/modules/` path references to `modules/`.
- `public_html/admin/modules/` is now explicitly documented as legacy/empty.

### NukeSecurity
- Normalized legacy links `op=nukesecurity` to `op=security`.
- Ensured `admin.php` routes `security` to `admin_nukesecurity`.
