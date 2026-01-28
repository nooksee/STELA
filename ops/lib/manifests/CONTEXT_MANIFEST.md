# Context Manifest

## Purpose
List required artifacts for session rehydration and context loading.

## Scope
Used by operators to ensure AI workers have a complete "Single Source of Truth" (SSOT).
Mandatory pre-session check: run `tools/context_lint.sh`.

## Canonical Context (The Core)
- `TRUTH.md` — Constitution and filing doctrine.
- `SoP.md` — History ledger and state of play.
- `TASK.md` — Active thread, DP contract, and work log.
- `AGENTS.md` — Staffing protocol and behavioral logic standards.
- `llms.txt` — Discovery entry point for AI agents.

## Supporting Surfaces
- `docs/library/LIBRARY_INDEX.md` — Curated operator surface index.
- `docs/library/OPERATOR_MANUAL.md` — Command mechanics and cheat sheet.
- `docs/library/CONTINUITY_MAP.md` — Context wayfinding map.
- `docs/GOVERNANCE.md` — Project governance and non-negotiables.

## Verification Tools
- `tools/context_lint.sh` — Validates presence of manifest artifacts.
- `tools/lint_truth.sh` — Verifies spelling and canon integrity.

## Verification
- Operator: Manually verify all "Canonical Context" files are provided in the dump.

## Risk + Rollback
- Risk: Missing artifacts lead to logic-drift or "hallucinated" repository structures.
- Rollback: Re-run `ops/bin/open` and verify against this manifest.

## Canon Links
- docs/library/OPERATOR_MANUAL.md
- docs/library/CONTINUITY_MAP.md
- AGENTS.md