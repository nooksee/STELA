# nukeCE v21 (NukeSecurity integration — gate + guard + datafeeds + audit tool)

Build date (UTC): 2025-12-27T04:09:24.085513Z

## Changes

- Upgraded `src/Security/NukeSecurity.php` from the security-gate branch to include request guarding/policy plumbing.
- Preserved SafeFile + logs_dir logging (`logs/nukesecurity.log`).
- Added `includes/security_gate.php` and included it from `index.php` and `admin.php`.
- Rebased `modules/admin_nukesecurity/AdminNukesecurityModule.php` onto the richer GeoIP/country rules variant and re-added the v17 paths/permissions panel.
- Imported Data Feeds scaffold:
  - `modules/admin_nukesecurity/datafeeds.php`
  - `install/datafeeds.sql`
  - `boot/docs/DATA_FEEDS.md`
- Added repo utility: `tools/nukesecurity_audit.php`
- Added doc: `boot/docs/NUKESECURITY_VISION_TO_IMPLEMENTATION_MAP.md`
