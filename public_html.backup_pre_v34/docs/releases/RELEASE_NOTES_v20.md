# nukeCE v20 (Track A: Hardening — SafeFile + Log IO)

Build date (UTC): 2025-12-27T02:21:42.861149Z

## Changes

### New helper
- Added `NukeCE\Core\SafeFile`:
  - `appendLocked(file, data)`
  - `writeAtomic(file, data)`

### Log IO hardening
- `src/Security/NukeSecurity.php` now uses `SafeFile::appendLocked()` for event logging.
- `src/Core/UpdateAI.php` now logs to `<logs_dir>/update.log` via `SafeFile` (no more writing logs under `src/`).

### State file hardening
- `modules/admin_forums/AdminForumsModule.php` now writes its JSON state atomically via `SafeFile::writeAtomic()`.

