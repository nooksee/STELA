<!-- CCD: ff_target="governance-narrative" ff_band="38-55" -->
# ops/lib/project

Minimal shell helpers for the project registry and `ops/bin/project`.
Think of this folder like a thin adapter layer that keeps project registry operations consistent from one run to the next.

## What lives here
- `project.sh` provides parsing, validation, and safe registry updates.

## Conventions
- Run from repo root.
- Registry SSOT: `docs/ops/registry/projects.md`.
- Scaffold template: `ops/lib/project/SCAFFOLD.md`.
