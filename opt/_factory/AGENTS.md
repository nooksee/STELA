# Agent Promotion Ledger

This file is the operator-facing promotion workflow for canon agents. Use `ops/lib/scripts/agent.sh` to append candidates and promotion entries.

## Harvest Engine Workflow
- `ops/lib/scripts/agent.sh harvest-check` prints Pattern Density candidate clusters without creating drafts.
- `ops/lib/scripts/agent.sh harvest` creates a draft in `archives/definitions/` with provenance and a pointer-first skeleton.
- Review and refine the draft before promotion. Do not edit the Provenance block.
- `ops/lib/scripts/agent.sh promote` promotes a draft into `opt/_factory/agents/`, updates `docs/ops/registry/AGENTS.md`, and appends to this ledger.
- `ops/lib/scripts/agent.sh check` audits scope boundaries and context hazards.
- Run `ops/lib/scripts/agent.sh harvest-check` at DP closeout when the DP classification is System Overhaul, Architecture Refactor, or Certification.

## Promotion Packet Template
- SSOT template: `ops/src/definitions/agent.md.tpl`
- Rendered by: `ops/lib/scripts/agent.sh harvest`
- This ledger is pointer-only; executable template bodies live under `ops/src/definitions/`.

## Candidate Log (append-only)
Append entries are added by `ops/lib/scripts/agent.sh harvest`. Each entry includes timestamp, candidate name, DP provenance, and draft path.
- No entries recorded yet.
## Promotion Log (append-only)
Append entries are added by `ops/lib/scripts/agent.sh promote`. Each entry includes timestamp, assigned agent ID, name, specialization, DP provenance, and promoted file path.
- No entries recorded yet.
