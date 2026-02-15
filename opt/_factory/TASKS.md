# Task Promotion Ledger

This file is the operator-facing promotion workflow for canon tasks. Use `ops/lib/scripts/task.sh` to append candidates and promotion entries.

## Doctrine
- Provenance is required for every task promotion.
- Reuse-first: if an existing workflow or script exists, use it and point to it.
- Orchestration only: tasks coordinate agents, skills, and tools. Tasks do not duplicate logic.
- Execution Logic must end with an explicit Closeout step that points to `TASK.md` Section 3.5.
- Quantitative reporting: when tools return counts or pass or fail summaries, paste the outputs into RESULTS.

## Harvest Engine Workflow
- `ops/lib/scripts/task.sh harvest` creates a draft in `storage/archives/tasks/` with provenance and a pointer-first skeleton.
- Review and refine the draft before promotion. Do not edit the Provenance block.
- `ops/lib/scripts/task.sh promote` promotes a draft into `opt/_factory/tasks/`, updates `docs/ops/registry/TASKS.md`, and appends to this ledger.
- `ops/lib/scripts/task.sh check` audits scope boundaries, context hazards, and pointer integrity.

## Promotion Packet Template
- SSOT template: `ops/src/definitions/task.md.tpl`
- Rendered by: `ops/lib/scripts/task.sh harvest`
- This ledger is pointer-only; executable template bodies live under `ops/src/definitions/`.

## Candidate Log (append-only)
Append entries are added by `ops/lib/scripts/task.sh harvest`. Each entry includes timestamp, task ID, name, DP provenance, and draft path.
- No entries recorded yet.
## Promotion Log (append-only)
Append entries are added by `ops/lib/scripts/task.sh promote`. Each entry includes timestamp, task ID, name, DP provenance, and promoted file path.
- No entries recorded yet.
