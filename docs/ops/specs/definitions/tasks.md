<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Definition Specification: Tasks Chain

## Purpose
Define canonical behavior for the task definition chain rooted at `opt/_factory/TASKS.md`.
This specification governs pointer heads, promotion/candidate lifecycle, and objective-contract normalization.

## Head Contract
`opt/_factory/TASKS.md` is a four-line pointer head in exact key order:
1. `candidate:` latest candidate leaf pointer, or origin sentinel.
2. `promotion:` latest promotion leaf pointer, or origin sentinel.
3. `spec:` this specification path.
4. `registry:` `docs/ops/registry/tasks.md`.

Allowed head values:
- Origin sentinel: `archives/definitions/task-candidate-(origin)` and `archives/definitions/task-promotion-(origin)`.
- Reachable leaf path: `archives/definitions/task-candidate-YYYY-MM-DD-<suffix>.md` or `archives/definitions/task-promotion-YYYY-MM-DD-<suffix>.md`.

## Lifecycle
- Candidate emission (`ops/lib/scripts/task.sh harvest`): render template, emit leaf, advance `candidate:`.
- Promotion emission (`ops/lib/scripts/task.sh promote`): promote canon task, update registry, emit leaf, advance `promotion:`.

## Canon Task Body Contract Baseline
Canon task files under `opt/_factory/tasks/` must contain:
- `## Provenance`
- `## Orchestration`
- `## Objective Contract` with required backticked fields:
  - `task_id`
  - `objective`
  - `inputs`
  - `outputs`
  - `invariants`
- `## Pointers`
- `## Execution Logic`
- `## Scope Boundary`

Task contract intent:
- task files define objective contract and deterministic execution routing.
- closeout routing references `TASK.md` Section 3.5.
- task files do not define stance-envelope behavior.

## Leaf Schema
Leaf frontmatter keys are required:
- `trace_id`
- `packet_id`
- `created_at`
- `previous`

`previous` semantics:
- origin sentinel -> `previous: (none)`
- otherwise prior head pointer path.
