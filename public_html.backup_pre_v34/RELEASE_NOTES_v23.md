# nukeCE v23 (Tor Exit Node Feed + Enforcement)

Build date (UTC): 2025-12-27T04:40:23.869873Z

## Changes

### Tor feed
- Added `src/Security/TorExit.php`:
  - Fetch + parse Tor exit list from a configured URL
  - Store list in DB table `nsec_tor_exit_nodes`
  - Fast membership check via `INET6_ATON()`

### Admin UI
- Added **Tor Exit Nodes** panel to `modules/admin_nukesecurity/AdminNukesecurityModule.php`:
  - enable toggle
  - mode: allow / flag / block
  - feed URL
  - refresh now + last refresh metadata

### Enforcement
- `src/Security/NukeSecurity.php` now enforces Tor policy during `guardRequest()` (via `includes/security_gate.php`).

### Installer schema helper
- Added `install/tor_exit_schema.sql` (reference schema).
- Added `boot/docs/TOR_FEED.md`.

## Notes
- Tor enforcement is fail-open if feed/DB errors occur.
