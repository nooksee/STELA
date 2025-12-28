# nukeCE Admin UI Template

Design target: classic PHP-Nuke familiarity with Evolution-style grouped panels.

## Rules
- Admin is themed by the active site theme (no separate admin theme system).
- Admin pages may add an admin skin stylesheet: `includes/css/admin.css` (themes may override/extend).
- Icons are resolved theme-first:
  - `themes/<theme>/images/admin/<name>.svg|png`
  - fallback: `assets/originals/admin/<name>.svg|png`

## Layout
- Admin Dashboard groups tiles into 3–5 panels max.
- Each panel has:
  - Title
  - Subtitle (what mental model this panel represents)
  - 2–4 tiles

## Tiles
Each tile:
- icon + label + one-line description
- links to `/admin.php?op=<op>` (façade) to keep classic workflows intact.

## “Commanding but coherent”
Some legacy admin UIs (e.g., security modules) can feel powerful but alien.
nukeCE standard:
- Provide short inline help text for every setting.
- Provide safe defaults.
- Log every change via NukeSecurity.
- Avoid “ego UI” that breaks continuity.


## Enforcement
Use `includes/admin_ui.php` (`AdminUi`) for headers, grouped panels, tiles, and buttons.
