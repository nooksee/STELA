# Asset policy: “originals (remastered)”

## What we do
- Keep classic theme/system assets, but remaster them for clarity and modern sensibilities.
- Preserve filenames and subpaths to avoid breaking templates.

## Where remastered originals live
- Theme-specific:
  - `themes/<slug>/assets/images/originals/...`
- System-wide (admin/module icons):
  - `assets/images/originals/system/src_images/...`
  - `assets/images/originals/system/legacy_images/...`

## What we avoid
- We do **not** modify vendor/forum internals in-place.
- We skin via wrapper/theme, and store remastered copies separately.

## Future development
- New modules should reference icons from `assets/images/originals/system/src_images/` (or provide their own under the module/theme).
