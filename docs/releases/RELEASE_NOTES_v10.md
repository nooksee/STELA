# nukeCE v10 (Sprint A: Cleanliness + Security Structure)

Build date (UTC): 2025-12-26T20:32:51.121412Z

## Scope
- Cleanliness & coherence pass (reduce 'mess room' feeling)
- Security structure sanity checks; ensure NukeSecurity wired via admin op map to admin_nukesecurity module

## Changes applied in this build

### Modules
- modules/reference: removed stray leading backslash artifact at file start.
- modules/encyclopedia: removed stray leading backslash; converted to legacy shim that redirects to Reference.

### Security wiring
- Confirmed admin.php maps op=security -> module=admin_nukesecurity.
- Confirmed module loader expects AdminNukesecurityModule.php and it exists.

## Notes
- This is a *coherence* batch, not a final RC. Next pass will target duplicate/legacy strings and folder consolidation across modules/admin modules.
