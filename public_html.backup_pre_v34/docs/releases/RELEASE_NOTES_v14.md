# nukeCE v14 (Track A: Hardening + Optional Module Gate)

Build date (UTC): 2025-12-27T00:30:56.842066Z

## Changes

### Installer lock
- Added an installer guard to all `install/*.php` scripts.
- To run installer, create: `public_html/config/ALLOW_INSTALL` (remove after install).

### Writable directory hardening
- Denied PHP execution via `.htaccess` in writable-like directories (excluding themes):
- (none detected)

### Optional module gating (default-off)
- Added `includes/modules_manifest.php` defining optional modules:
  - your_account, weblinks, stats, projects, polls, newsletter, members, faq
- Added `config/ENABLED_OPTIONAL_MODULES.example.php` template.
- `src/Core/ModuleManager.php` now blocks optional modules unless enabled via config.

## Notes
- `.htaccess` rules assume Apache with AllowOverride enabled.
- For Nginx, replicate deny/headers rules in server config.
