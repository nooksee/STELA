# Core Blocks Gold Pass (nukeCE)

This patch updates the **core sidebar blocks** to match nukeCE "Gold" standards:

- Theme-aware markup (inherits theme block chrome)
- Permission-aware rendering (admins vs users)
- Disable-safe behavior (modules can be disabled without fatal errors)
- Optional lightweight caching hooks (respects nukeCE block cache if present)
- No inline CSS; minimal HTML

## Included blocks
- `block-Admin.php`
- `block-UserInfo.php`
- `block-Search.php`
- `block-Languages.php`
- `block-WhoIsOnline.php`
- `block-WaitingContent.php`
- `block-NukeSecurity.php`

## Install
1. Backup your site.
2. Overlay the `blocks/` and `includes/` folders into your nukeCE root.
3. In Admin → Blocks, enable/position the updated blocks.

## Notes
These blocks are written to be *backwards-tolerant* with classic PHP-Nuke patterns while preferring nukeCE helpers when available.
