# Task Promotion Ledger

> **CONTEXT HAZARD:** Tasks are JIT-only. Do not add task libraries to `ops/lib/manifests/CONTEXT.md`. Logging to `docs/library/TASKS.md` is operator-mediated and performed by worker capture during DP processing.

This file is the operator-facing promotion workflow for canon tasks. Use `ops/lib/scripts/task.sh` to append candidates and promotion entries.

## Doctrine
- Provenance is required for every task promotion.
- Reuse-first: if an existing workflow or script exists, use it and point to it.
- Orchestration only: tasks coordinate agents, skills, and tools. Tasks do not duplicate logic.

## Harvest Engine Workflow
- `ops/lib/scripts/task.sh harvest` creates a draft in `storage/handoff/` with provenance and a pointer-first skeleton.
- Review and refine the draft before promotion. Do not edit the Provenance block.
- `ops/lib/scripts/task.sh promote` promotes a draft into `docs/library/tasks/`, updates `docs/ops/registry/TASKS.md`, and appends to this ledger.
- `ops/lib/scripts/task.sh check` audits scope boundaries, context hazards, and pointer integrity.

## Promotion Packet Template
### Promotion Packet: Task Promotion
- Required fields:
  - Task name: canonical registry name used in `docs/ops/registry/TASKS.md`.
  - Task ID: `B-TASK-XX`.
  - DP provenance: DP ID, branch, HEAD, and objective.
  - Pointer set: authorized toolchain, required agents, JIT skills, and reference docs.
  - Drift preventers: scope boundary, stop conditions, and registry alignment.
  - Definition of Done: promotion artifacts, registry updates, lint passes, and SoP updates when required.
- Verification (capture command output in RESULTS):
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh` (required when canon or governance surfaces change)
  - `bash tools/lint/library.sh`
  - `bash tools/lint/task.sh`
  - `bash ops/lib/scripts/task.sh check`

## Candidate Log (append-only)
Append entries are added by `ops/lib/scripts/task.sh harvest`. Each entry includes timestamp, task ID, name, DP provenance, and draft path.
- No entries recorded yet.

## Promotion Log (append-only)
Append entries are added by `ops/lib/scripts/task.sh promote`. Each entry includes timestamp, task ID, name, DP provenance, and promoted file path.
- No entries recorded yet.
