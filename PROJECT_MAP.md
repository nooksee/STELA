# Project Map — PHP-Nuke CE

This file is the stable blueprint. Update only when structure or core architecture changes.

## Repo layout (what lives where)
- public_html/      deployable webroot (what the server serves)
- docs/             public operating docs (start at docs/00-INDEX.md)
- docs/ops/ — Operating Cockpit Zone
- boot/             boot packs (canon snapshots, rules, schemas)
- tools/            verification + truth checks (support for repo-gates)
- scripts/          helper scripts (build/sync/release tooling when used)
- upstream/ — Read-Only Donor Bank
- patches/          optional patch queue (use only when needed; keep small)
-.github/workflows/ — repo-gates / CI enforcement location
- .github/          Copilot instructions + PR templates, etc.
- addons/           optional legacy/extra modules (not required for core)

## Key runtime entrypoints
- public_html/index.php       router entry
- public_html/modules.php     legacy entry (modules.php?name=...)
- public_html/mainfile.php    legacy compat include

## Naming rules
- Module directories are lowercase.
- Admin modules are prefixed admin_.
- No archive snapshots inside public_html.
