# Upstreams (donor inputs)

Upstreams are **donor projects**, not identity.

They exist so we can:
- preserve original context,
- compare changes,
- and maintain provenance when we import/adapt code.

## Rules

- Keep donor snapshots **read-only** under `upstream/`.
- Stela-owned changes happen in **owned surfaces** (e.g., `public_html/`, and future `src/` / `packages/`).
- Any meaningful import/adaptation must include **provenance notes** (what came from where, and what changed).

## Recommended import workflow

1. Snapshot donor code into `upstream/<project>/` (read-only posture).
2. Copy/adapt into the owned surface.
3. Document the import decision:
   - what was imported,
   - why,
   - what was modified,
   - any risks/compat notes.

This keeps the repo auditable and makes modernization tractable.
