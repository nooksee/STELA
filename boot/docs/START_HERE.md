# START HERE — nukeCE Control Room

## The goal
A clean rebootable workflow where:
- **Transcripts** are evidence
- **Claims** make uncertainty explicit
- **Canon** is only ratified Decisions
- **Reference nodes** are published knowledge objects

## Recommended layout
- Serve only: `public_html/`
- Keep governance + evidence outside webroot: `_meta/`

## NetBeans
1. Create Project A (Web) → folder: `public_html/`
2. Create Project B (Support) → folder: `_meta/`

## Fresh chat reboot script (copy/paste)
1) Start new chat named: **nukeCE Control Room — Active Context Pack**
2) Upload: `boot_pack_v2/` (or the whole zip if you prefer)
3) Paste:

"""
Load this as the active Boot Pack.
Constraints:
- Assist-only AI. Never auto-enforce.
- Canon is ratified Decisions only.
- Provenance required; surface uncertainty.
Scope:
- We are building nukeCE continuity mechanisms + module work without drift.
Use: boot_pack_v2/context_pack.json as session contract.
"""

## Integrity
See: `_meta/docs/integrity/INTEGRITY_REPORT.md`


If you want everything under `public_html/` anyway, read `SECURE_WEBROOT_OPTION.md` and use the `_meta/` deny rules.
