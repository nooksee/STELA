# nukeCE Module Development

This document is the beginning of module-development documentation.

## Core rules
1. **Coherence over cleverness.**
2. **One module system** for user + admin pages.
3. **Admin UI uniformity**: use `AdminUi` helper for grouped panels, tiles, and buttons.
4. **Security first**: CSRF, permission gates, and audit logging for any change.
5. **Disable-safe**: modules can be disabled without breaking the system.
6. **Attribution preserved**: keep upstream credits; do not erase provenance.

## Settings
- Global policy: `admin_settings`
- Module-specific settings: namespaced keys in DB:
  - `module.<name>.*`
- Secrets: config/env only.

## UI
- Theme-first admin icons:
  - `themes/<theme>/images/admin/*.svg|png`
  - fallback: `assets/originals/admin/*.svg|png`
- Themes may override styling, not structure.

## Logging
All admin mutations should emit NukeSecurity events (e.g., `settings.changed`, `moderation.resolved`).

