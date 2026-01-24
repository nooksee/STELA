# Context Manifest

## Purpose
List required artifacts for context loading.

## Scope
Used by operators when providing context to AI workers.
Optional pre-session check: run `tools/context_lint.sh`.

## Canonical files
- `TRUTH.md`
- `SoP.md`
- `AGENTS.md`
- `llms.txt`
- `docs/library/LIBRARY_INDEX.md`
- `docs/library/OPERATOR_MANUAL.md`
- `docs/library/CONTINUITY_MAP.md`
- `ops/contracts/OUTPUT_FORMAT_CONTRACT.md`
- `ops/contracts/CONTRACTOR_DISPATCH_CONTRACT.md`
- `tools/context_lint.sh`

## Verification
- Not run (operator): confirm manifest completeness.

## Risk+Rollback
- Risk: missing critical context.
- Rollback: add or restore required artifacts.

## Canon Links
- docs/library/OPERATOR_MANUAL.md
- docs/library/CONTINUITY_MAP.md
