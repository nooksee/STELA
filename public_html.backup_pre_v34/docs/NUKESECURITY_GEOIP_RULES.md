# NukeSecurity Geo/IP Rules

This feature modernizes the classic NukeSentinel country/IP update workflow.

## Modes
- **Log-only** (default): logs matches, never blocks.
- **Enforce**: applies **block** rules with HTTP 403.

## Rules
Country rules are stored by ISO2 code:
- allow
- flag (log)
- block (log-only or enforce)

## Data feeds
Import GeoLite2 Country CSVs in NukeSecurity → Data Feeds, then configure rules.

Safety note:
Fail-open on DB/schema errors to prevent accidental site lockouts.
