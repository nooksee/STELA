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
- Run receipts and verification first.
- Update `SoP.md` and RESULTS artifacts.
- Run `./ops/bin/prune --dp=<id> --scrub` after receipt logging.
- Scrub is hygiene only and must not redefine canon policy.
