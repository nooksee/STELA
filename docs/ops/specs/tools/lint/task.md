# Technical Specification: tools/lint/task.sh

## Constitutional Anchor
`tools/lint/task.sh` is the sole TASK surface container enforcer.
It protects both the root TASK dashboard schema and the task-library registry contract used by the task subsystem.

## Operator Contract
- Invocation:
  - `bash tools/lint/task.sh`
  - `bash tools/lint/task.sh <TASK_PATH>`
- Exit behavior:
  - `0` when checks pass.
  - `1` when lint failures are found or arguments are invalid.
  - `2` when required dependency files are missing.
- Inputs:
  - `TASK.md` by default or provided TASK path.
  - `opt/_library/tasks/*.md`.
  - `docs/ops/registry/TASKS.md`.

Coverage domains:
- TASK dashboard schema and heading order.
- DP section load-order and receipt contract requirements.
- Closeout block label requirements.
- Pointer-first Session State and anti-inline-state rules.
- Task registry uniqueness and ghost-file detection.
- Task file section/field schema, pointer validity, and reference integrity.

## Failure States and Drift Triggers
TASK dashboard failures:
- Missing required headings or out-of-order heading sequence.
- Legacy forbidden sections (`Thread Transition`, `Work Log`).
- Session State embeds branch/hash mirror data.
- Missing exact Session State pointer-first contract lines.
- Missing canon load-order six-item contract or bloated canon block.
- Missing receipt command requirements in DP Section 3.4.5.
- Missing Mandatory Closing Block labels.

Task library failures:
- Duplicate IDs or duplicate file paths in registry.
- Registry entry references missing files.
- Task files that are not registered.
- Missing required sections or duplicate section headings.
- Placeholder values in required fields.
- Missing required pointers (`PoT.md`, `docs/GOVERNANCE.md`, `TASK.md`).
- Pointer tokens that resolve to missing files or forbidden path classes.
- Missing referenced agent or skill files.
- Execution steps with ambiguous narrative verbs and no explicit pointer evidence.
- Final execution step missing Closeout pointer to `TASK.md` Section 3.5.

## Mechanics and Sequencing
1. Resolve repo root and required registry/task directories.
2. Lint task library and registry contract:
- Contraction checks.
- Legacy inline-state language checks.
- Registry parse and uniqueness checks.
- File-to-registry parity checks.
- Per-task schema, field, pointer, and dependency checks.
3. Lint TASK dashboard contract for container-level invariants.
4. Report all failures and exit non-zero when any failure exists.

Core invariants:
- TASK lint owns container schema; DP lint owns Section 3 transaction content.
- TASK canonical load order is exactly six numbered items.
- TASK Section 3.4.5 must include executable OPEN and DUMP commands plus diff proofs.
- Task execution logic must terminate in explicit closeout routing.

## Forensic Insight
This lint gate prevents silent process drift in the two highest-risk planning surfaces: `TASK.md` and reusable task blueprints.
Because it validates both structure and pointer integrity, it catches failures before they become workflow folklore or broken automation.
