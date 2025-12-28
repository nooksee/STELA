# Addons Strategy (v34)

nukeCE treats **core** and **addons** as separate concerns:

- **Core** ships enabled and supported.
- **Addons** are distributed separately (e.g., from the main nukeCE site) and are not emphasized in the admin UI.

## Why

- Keeps the CMS release clean and confidence-building.
- Avoids the "graveyard" feeling of dead folders.
- Makes security posture easier to reason about.

## How it works today

- Enabled modules are defined in `public_html/config/modules.php`.
- Legacy PHP-Nuke entry points are supported via:
  - `modules.php?name=...` → mapped to canonical slugs
  - small `index.php` stubs in legacy module folders (when present)

## Installing addons (current)

1. Download an addon package.
2. Place it under repo-root `addons/optional/<addon>/` (kept out of webroot).
3. If you decide to enable it for a site, install it by copying the module folder into `public_html/modules/<slug>/` and adding the slug to `enabled` in `config/modules.php`.

A future release will add:
- signed addon packages
- admin "Install from package" behind an Advanced toggle
- audit log of installs (Evidence Log)
