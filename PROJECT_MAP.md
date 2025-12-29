# Project Map — PHP-Nuke CE

This file is the stable blueprint. Update only when structure or core architecture changes.

## Repo layout
- public_html/  deployable webroot
- boot/         boot pack (canon, rules, schemas)
- tools/        build, verify, truth checks
- docs/         founder + admin philosophy + governance

## Key runtime entrypoints
- public_html/index.php  router entry
- public_html/modules.php  legacy entry (modules.php?name=...)
- public_html/mainfile.php  legacy compat include

## Naming rules
- Module directories are lowercase.
- Admin modules are prefixed admin_.
- No archive snapshots inside public_html.
