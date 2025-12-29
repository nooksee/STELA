# nukeCE v13 (Track A: Hardening)
Build date (UTC): 2025-12-27T00:21:58.570569Z

## Changes
### Module coherence
- Normalized module directory casing:
  - `modules/Links/` → `modules/links/`
- Added legacy redirect mapping so `module=Links` routes to `module=links`.

### Webroot hardening
- Added baseline security headers in webroot `.htaccess` (CSP-lite, X-Frame-Options, etc.).
- Denied HTTP access via `.htaccess`: data, _meta
- Disabled PHP execution via `.htaccess` in upload-like directories: assets/images, themes/evolution/assets/images, themes/evolution/assets/images/originals/forums/images, themes/evolution/assets/images/originals/images, themes/evolution/images, themes/nukegold/assets/images, themes/nukegold/assets/images/originals/forums/images, themes/nukegold/assets/images/originals/images, themes/nukegold/images, themes/subSilver/assets/images, themes/subSilver/assets/images/originals/images, themes/subSilver/images, themes/x-halo/assets/images, themes/x-halo/assets/images/originals/forums/images, themes/x-halo/assets/images/originals/images, themes/x-halo/assets/images/originals/resources/setup/html/themes/XHalo/forums/images, themes/x-halo/assets/images/originals/resources/setup/html/themes/XHalo/images, themes/x-halo/images

### Installer lock
- Installer now requires explicit allow flag: create `public_html/config/ALLOW_INSTALL` to run. Remove after install.

## Notes
- `.htaccess` changes assume Apache with AllowOverride enabled. If using Nginx, replicate rules in server config.
