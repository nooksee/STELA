# Technical Specification: tools/lint/task.sh

## Purpose
Enforce TASK dashboard container schema and validate task-library registry contracts.

## Invocation
- Command forms:
  - `bash tools/lint/task.sh`
  - `bash tools/lint/task.sh <TASK_PATH>`
- Required flags: none.
- Positional arguments: zero or one.
- Expected exit behavior:
  - `0` when task checks pass.
  - `1` for lint failures or invalid argument count.
  - `2` when required files (for example `docs/ops/registry/TASKS.md`) are missing.

## Inputs
- `docs/ops/registry/TASKS.md`
- `docs/library/tasks/*.md`
- Default TASK dashboard target: `TASK.md`.
- Optional dashboard target path when one argument is passed.

## Outputs
- Writes no files.
- Stdout: final pass line (`OK: Task lint checks passed.`).
- Stderr: `FAIL:` diagnostics for dashboard schema violations, placeholder fields, registry drift, or pointer failures.

## Invariants and failure modes
- TASK dashboard heading sequence and canonical load order are strictly enforced.
- Session state must remain pointer-first and must not embed inline branch/hash mirrors.
- Receipt contract in TASK Section 3.4.5 must include OPEN, DUMP, diff proofs, pasted output clause, and mandatory closing block labels.
- Task library files must align with registry IDs/paths and required section structure.
- Final execution step in task files must include a Closeout pointer to `TASK.md` Section 4.

## Related pointers
- Registry entry: `docs/ops/registry/LINT.md` (`LINT-08`).
- DP companion linter: `tools/lint/dp.sh`.
- Registry contract: `docs/ops/registry/TASKS.md`.
