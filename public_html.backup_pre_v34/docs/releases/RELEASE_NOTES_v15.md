# nukeCE v15 (Track A: Writable Dirs Canon + Hardening)

Build date (UTC): 2025-12-27T00:36:03.553096Z

## Changes

### Canonical writable dirs
Created/standardized (and HTTP-hardened):

- `public_html/uploads/` (PHP execution denied)
- `public_html/cache/` (HTTP denied)
- `public_html/tmp/` (HTTP denied)
- `public_html/logs/` (HTTP denied)

### Config
Added config keys to `config/config.php`:

- `uploads_dir`, `cache_dir`, `tmp_dir`, `logs_dir`

with env overrides:
- `NUKECE_UPLOADS_DIR`, `NUKECE_CACHE_DIR`, `NUKECE_TMP_DIR`, `NUKECE_LOGS_DIR`

### Docs
- Added `boot/docs/v15_WRITABLE_DIRS.md`

## Notes
- If you host behind Nginx, copy the deny rules into the Nginx config.
