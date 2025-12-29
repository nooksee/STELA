# nukeCE v24 (Tor feed freshness warning)

Build date (UTC): 2025-12-27T04:46:39.003100Z

## Changes
- Added `TorExit::getStats()` to report node count and last refresh timestamp.
- Admin NukeSecurity Tor panel now shows:
  - current node count
  - last refresh timestamp
  - stale warning when older than configurable threshold
- New config key: `tor_max_age_days` (default 7)

## Notes
- Staleness is advisory only (no automatic blocking/allow changes).
