# nukeCE v19 (Track A: Hardening — StoragePaths)

Build date (UTC): 2025-12-27T01:58:49.427965Z

## Changes

### New helper
- Added `NukeCE\Core\StoragePaths` to centralize AppConfig-derived filesystem paths and safe joining.

### Path adoption
- Updated NukeSecurity logging and threats block to use StoragePaths.
- Updated Admin Downloads destination to use StoragePaths.
- Updated Admin Maintenance writable-dir panel to use StoragePaths.

## Notes
- This is a structural cleanup to prevent future drift and reduce hard-coded paths.
