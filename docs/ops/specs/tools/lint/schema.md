# Technical Specification: tools/lint/schema.sh

## Constitutional Anchor
`tools/lint/schema.sh` enforces unified provenance schema integrity for archived leaves.
It validates that eligible leaves across definitions, surfaces, and compile manifest snapshots carry parseable front-matter required for reverse-link continuity.

## Scope
- Scan targets:
  - `archives/definitions/` markdown leaves (`*.md`) at depth 1.
  - `archives/surfaces/` markdown leaves (`*.md`) at depth 1 when filename matches one of:
    - `PoW-YYYY-MM-DD-<git_short_hash>.md`
    - `SoP-YYYY-MM-DD-<git_short_hash>.md`
    - `TASK-DP-<ID>-<git_short_hash>.md`
  - `archives/manifests/` markdown leaves (`*.md`) at depth 1 when filename matches:
    - `compile-YYYY-MM-DDTHHMMSS-<git_short_hash>.md`
- Explicit ignore:
  - `.gitkeep` files in scanned directories.
  - Non-markdown files.
  - Markdown files that do not match candidate filename policy for surfaces/manifests.
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
  - Repository-relative `.md` path (not absolute, no parent traversal, only repository-safe path characters).

## Failure Modes
- Missing initial front-matter delimiter.
- Unclosed front-matter block.
- Missing or empty required schema keys.
- Invalid `created_at` format.
- Invalid `previous` format.

The linter exits non-zero on the first failure and prints an actionable file-scoped message.

## Output Contract
On success, the script prints a single summary line containing:
- total checked file count
- per-surface counts for definitions, surfaces, and manifests

## Operator Actions
- Fix schema values in the offending leaf generator path (template slots or emit logic).
- Re-run `bash tools/lint/schema.sh`.
- Do not bypass the gate.
