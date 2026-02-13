# TASK Surface Contract

## Purpose
`TASK.md` is the canonical task-routing and DP contract surface.

## Surface Roles
- `TASK.md`: Dispatch contract template and active thread routing surface.
- DP body (`TASK.md` Section 3): Worker-facing executable assignment.
- `storage/handoff/DP-OPS-XXXX-RESULTS.md`: Pointer-first execution receipt with pasted proofs and verification outputs.
- `OPEN` and `DUMP` artifacts: Generated state artifacts used for refresh and receipt pointers.

## Enforcement
- `tools/lint/task.sh`: Enforces TASK surface schema and TASK-only container rules.
- `tools/lint/dp.sh`: Enforces DP transaction rules in Section 3 only (including TASK Section 3 extraction when linting `TASK.md`).
- Separation of concerns is strict: DP lint does not duplicate TASK container validation.

## Prune Sequencing
- Run verification gates first.
- Author RESULTS after verification gates pass.
- Operator commits before any prune step.
- Run prune last:
  - `./ops/bin/prune --dp=<id> --scrub` for hygiene-only cleanup (must not rewrite `TASK.md`).
  - `./ops/bin/prune --reset-task` only for explicit TASK baseline reset after Work Log clear.
  - Prune aborts with a fatal safety violation if matching RESULTS artifacts are uncommitted.
