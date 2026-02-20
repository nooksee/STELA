# Definition Specification: Tasks Chain

## Purpose
Define the canonical behavior for the task definition chain rooted at `opt/_factory/TASKS.md`.
This specification governs candidate and promotion pointer heads, emission requirements, and task registry alignment.

## Head Contract
`opt/_factory/TASKS.md` is a four-line pointer head with this exact key order:
1. `candidate:` latest candidate leaf pointer, or origin sentinel.
2. `promotion:` latest promotion leaf pointer, or origin sentinel.
3. `spec:` this specification path.
4. `registry:` `docs/ops/registry/tasks.md`.

Allowed head values:
- Origin sentinel: `archives/definitions/task-candidate-(origin)` and `archives/definitions/task-promotion-(origin)`.
- Reachable leaf path: `archives/definitions/task-candidate-YYYY-MM-DD-<suffix>.md` or `archives/definitions/task-promotion-YYYY-MM-DD-<suffix>.md`.

## Doctrine
- Provenance is required for every task candidate and promotion leaf.
- Reuse-first: reference existing scripts and registries instead of duplicating logic.
- Orchestration-only: tasks coordinate agents, skills, and tools.
- Execution logic ends with explicit closeout routing to `TASK.md`.

## Lifecycle
- Candidate emission (`ops/lib/scripts/task.sh harvest`):
  - Render candidate content from `ops/src/definitions/task.md.tpl`.
  - Emit a schema-stamped leaf under `archives/definitions/`.
  - Rewrite `candidate:` to the new leaf path.
- Promotion emission (`ops/lib/scripts/task.sh promote`):
  - Promote canon task file under `opt/_factory/tasks/`.
  - Upsert `docs/ops/registry/tasks.md`.
  - Emit promotion leaf under `archives/definitions/`.
  - Rewrite `promotion:` to the new leaf path.

## Leaf Schema
Leaf front-matter keys are required:
- `trace_id`
- `packet_id`
- `created_at`
- `previous`

`previous` semantics:
- When prior head is an origin sentinel ending with `-(origin)`, emit `previous: (none)`.
- Otherwise emit the prior head pointer path.
