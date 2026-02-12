# TASK Surface Contract (V2)

## Purpose
`TASK.md` is the canonical task-routing and DP contract surface.

## Surface Roles
- `TASK.md`: Dispatch contract template and active thread routing surface.
- DP body (`TASK.md` Section 3): Worker-facing executable assignment.
- `storage/handoff/DP-OPS-XXXX-RESULTS.md`: Execution receipt with pasted proofs.
- `OPEN` and `DUMP` artifacts: Generated state artifacts used for refresh and receipt pointers.

## Enforcement
- `tools/lint/task.sh`: Enforces TASK V2 schema and TASK-specific contract language.
- `tools/lint/dp.sh`: Enforces DP structure plus TASK template requirements when linting `TASK.md`.

## Prune Sequencing
- Run receipts and verification first.
- Update `SoP.md` and RESULTS artifacts.
- Run `./ops/bin/prune --dp=<id> --scrub` after receipt logging.
- Scrub is hygiene only and must not redefine canon policy.
