# Context Manifest

## Purpose
List required artifacts for session rehydration and context loading.

## Scope
Used by operators to ensure AI workers have a complete "Single Source of Truth" (SSOT).
Mandatory pre-session check: run `tools/lint/context.sh`.

## Small Bundle (Canonical Context)
- `PoT.md` — Policy of Truth (constitution, staffing, jurisdiction, enforcement).
- `SoP.md` — History ledger and state of play.
- `TASK.md` — Active thread, DP contract, and work log.
- `llms.txt` — Discovery entry point for AI agents.

## Full Bundle (Supporting Surfaces)
Full bundle adds these supporting surfaces on top of the Small bundle.
- `docs/library/INDEX.md` — Curated operator surface index.
- `docs/library/MANUAL.md` — Command mechanics and cheat sheet.
- `docs/library/MAP.md` — Context wayfinding map.
- `docs/GOVERNANCE.md` — Project governance and non-negotiables.

## Verification Tools
- `tools/lint/context.sh` — Validates presence of manifest artifacts.
- `tools/lint/truth.sh` — Verifies spelling and canon integrity.

## Verification
- Operator: Manually verify all "Canonical Context" files are provided in the dump.

## Risk + Rollback
- Risk: Missing artifacts lead to logic-drift or "hallucinated" repository structures.
- Rollback: Re-run `ops/bin/open` and verify against this manifest.

## Canon Links
- docs/library/MANUAL.md
- docs/library/MAP.md
- PoT.md
