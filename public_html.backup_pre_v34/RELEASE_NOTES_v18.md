# nukeCE v18 (Track A: Hardening — Log Path Normalization)

Build date (UTC): 2025-12-27T01:54:22.818118Z

## Changes

### NukeSecurity logging
- Normalized NukeSecurity log file location to use config key `logs_dir`:
  - `nukesecurity.log` now lives at `<logs_dir>/nukesecurity.log`
- Updated:
  - `src/Security/NukeSecurity.php`
  - `blocks/nukesecurity_threats.php`

## Notes
- Legacy locations may still be referenced by Admin Maintenance compatibility checks; this is intentional.
