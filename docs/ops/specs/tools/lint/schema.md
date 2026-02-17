# Technical Specification: tools/lint/schema.sh

## Constitutional Anchor
`tools/lint/schema.sh` enforces unified provenance schema integrity for archived definition leaves.
It validates that `archives/definitions` leaf drafts carry parseable front-matter needed for reverse-link graph continuity.

## Scope
- Scan target:
  - `archives/definitions/` markdown leaves (`*.md`) at depth 1.
- Explicit ignore:
  - `archives/definitions/.gitkeep`
  - Non-markdown files in the same directory.
- Out of scope:
  - Runtime telemetry leaves in `logs/`
  - Runtime artifacts in `storage/`
  - Canon definition files under `opt/_factory/`

## Schema Requirements
The first YAML front-matter block in each candidate file must contain:
- `trace_id`
- `packet_id`
- `created_at`
- `previous`

Validation rules:
- `created_at` must match ISO-8601 UTC with `Z` suffix (`YYYY-MM-DDTHH:MM:SSZ`).
- `previous` must be either:
  - `(none)`, or
  - Repository-relative `.md` path (not absolute, no parent traversal).

## Failure Modes
- Missing initial front-matter delimiter.
- Unclosed front-matter block.
- Missing or empty required schema keys.
- Invalid `created_at` format.
- Invalid `previous` format.

The linter exits non-zero on the first failure and prints an actionable file-scoped message.

## Operator Actions
- Fix schema values in the offending leaf generator path (template slots or harvest logic).
- Re-run `bash tools/lint/schema.sh`.
- Do not bypass the gate.
