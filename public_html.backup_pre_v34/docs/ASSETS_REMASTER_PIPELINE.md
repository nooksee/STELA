# Assets: “originals (remastered)” pipeline

Goal: keep the classic identity while updating assets to modern sensibilities **without breaking paths**.

## Rules
- Keep original filenames and relative paths whenever possible.
- Store remastered copies under:
  - `themes/<slug>/assets/images/originals/<original-theme-path>/...`
- Themes may *optionally* reference these assets (logo, backgrounds) but should not hard-depend on any single file.

## How to remaster (future development)
1. Add new legacy/original assets into a theme folder under `assets/images/originals/`.
2. Run the remaster script (internal) to:
   - denoise
   - autocontrast (mild)
   - subtle saturation boost
   - unsharp mask
   - optimize output
3. Verify:
   - No filename changes
   - No dimension changes (unless explicitly desired)

## Notes
- Animated GIFs are preserved as-is.
- Vendor/forum assets should not be renamed; only wrap/skin via theme.
