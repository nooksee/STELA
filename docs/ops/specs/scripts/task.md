# Technical Specification: ops/lib/scripts/task.sh

## Purpose
Manage task candidate harvesting, promotion, and context hazard checks while advancing factory pointer heads.

## Invocation
- Command forms:
  - `ops/lib/scripts/task.sh harvest --id B-TASK-XX --name "..." --objective "..." [--dp "DP-OPS-XXXX"]`
  - `ops/lib/scripts/task.sh promote <draft_path> [--delete-draft]`
  - `ops/lib/scripts/task.sh check`
- Exit behavior:
  - `0` on success.
  - Non-zero on validation failures, pointer rewrite failures, or registry update failures.

## Inputs
- `opt/_factory/TASKS.md` pointer head.
- `docs/ops/registry/TASKS.md` registry table.
- `ops/src/definitions/task.md.tpl` definition template.
- `TASK.md` and `ops/lib/manifests/CONTEXT.md`.

## Outputs
- `harvest` emits candidate leaf at `archives/definitions/task-candidate-YYYY-MM-DD-<suffix>.md` and rewrites `candidate:` in `opt/_factory/TASKS.md`.
- `promote` writes canonical task file in `opt/_factory/tasks/`, upserts `docs/ops/registry/TASKS.md`, emits promotion leaf at `archives/definitions/task-promotion-YYYY-MM-DD-<suffix>.md`, and rewrites `promotion:` in `opt/_factory/TASKS.md`.
- `check` enforces task context hazard rule and delegates deep validation to `tools/lint/task.sh`.

## Invariants and failure modes
- Candidate and promotion leaves always include unified schema front-matter keys: `trace_id`, `packet_id`, `created_at`, `previous`.
- `previous` is `(none)` when prior head value ends with `-(origin)`; otherwise it is the prior head pointer path.
- `trace_id` uses `STELA_TRACE_ID` when provided and falls back to local generation.
- `packet_id` uses `STELA_PACKET_ID` when provided and falls back to DP input.
- Harvest requires unique task IDs matching `B-TASK-[0-9]{2,}`.
- Promote requires a candidate whose path contains the task ID token.
- Pointer-head rewrite is a hard gate; missing `candidate:` or `promotion:` lines fail the command.

## Related pointers
- Factory head spec: `docs/ops/specs/definitions/tasks.md`.
- Registry entry: `docs/ops/registry/SCRIPTS.md` (`SCRIPT-06`).
- Task registry: `docs/ops/registry/TASKS.md`.
