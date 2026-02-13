# Technical Specification: ops/lib/scripts/task.sh

## Purpose
Manage task draft harvest, promotion, and guardrail checks for task lifecycle workflows.

## Invocation
- Command forms:
  - `ops/lib/scripts/task.sh harvest --id B-TASK-XX --name "..." --objective "..." [--dp "DP-OPS-XXXX"]`
  - `ops/lib/scripts/task.sh promote <draft_path> [--delete-draft]`
  - `ops/lib/scripts/task.sh check`
- Required flags:
  - `harvest` requires `--id`, `--name`, and non-placeholder objective and DP values (direct or inferred).
- Expected exit behavior:
  - `0` on successful command completion.
  - Non-zero on missing inputs, invalid IDs, duplicates, or validation failures.

## Inputs
- Canon and registry files:
  - `docs/library/TASKS.md`
  - `docs/ops/registry/TASKS.md`
  - `TASK.md`
  - `ops/lib/manifests/CONTEXT.md`
- Task directories:
  - `docs/library/tasks/`
  - `storage/archives/tasks/`
- Optional sourced provenance helper from `ops/lib/scripts/heuristics.sh`.

## Outputs
- `harvest`: writes redacted task draft under `storage/archives/tasks/` and appends candidate log in `docs/library/TASKS.md`.
- `promote`: writes canon task file under `docs/library/tasks/`, upserts registry entry in `docs/ops/registry/TASKS.md`, and appends promotion log in `docs/library/TASKS.md`.
- `check`: enforces context hazard rule and runs `tools/lint/task.sh`.

## Invariants and failure modes
- Harvest task ID must match `B-TASK-[0-9]{2,}` and must not already exist in the registry.
- Promotion validation enforces required sections, required fields, and final Closeout pointer in execution logic.
- Context hazard rule forbids task references in `ops/lib/manifests/CONTEXT.md`.
- Draft path ambiguity (same timestamp) is a hard failure unless explicit path is supplied.

## Related pointers
- Registry entry: `docs/ops/registry/SCRIPTS.md` (`SCRIPT-05`).
- Task registry: `docs/ops/registry/TASKS.md`.
- TASK schema linter: `tools/lint/task.sh`.
