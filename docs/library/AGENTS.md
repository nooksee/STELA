# Agent Promotion Ledger

> **CONTEXT HAZARD:** Agents are JIT-only. Do not add agent or skill libraries to `ops/lib/manifests/CONTEXT.md`. Logging to `docs/library/AGENTS.md` is operator-mediated and performed by worker capture during DP processing.

This file is the operator-facing promotion workflow for canon agents. Use `ops/lib/scripts/agent.sh` to append candidates and promotion entries.

## Harvest Engine Workflow
- `ops/lib/scripts/agent.sh harvest` creates a draft in `storage/handoff/` with provenance and a pointer-first skeleton.
- Review and refine the draft before promotion. Do not edit the Provenance block.
- `ops/lib/scripts/agent.sh promote` promotes a draft into `docs/library/agents/`, updates `docs/ops/registry/AGENTS.md`, and appends to this ledger.
- `ops/lib/scripts/agent.sh check` audits scope boundaries and context hazards.

## Promotion Packet Template
### Promotion Packet: Agent Promotion
- Required fields:
  - Agent name: canonical registry name used in `docs/ops/registry/AGENTS.md`.
  - Specialization: one sentence describing the agent focus.
  - DP provenance: DP ID, branch, HEAD, and objective.
  - Authorized toolchain: repo-relative executables under `ops/bin/` and approved helpers under `tools/`.
  - JIT skills: list `docs/library/skills/S-LEARN-01.md` style paths using existing skill IDs or explicitly state none.
  - Scope boundary: explicit statement limiting the agent to the DP scope and canon pointers.
  - Pointer set: `PoT.md`, `docs/GOVERNANCE.md`, `TASK.md`, and any required canon pointers.
- Drift preventers:
  - Stop conditions: stop if required inputs are missing or if scope exceeds the active DP.
  - Anti-scope-creep: do not expand responsibilities without a new DP.
  - Context hazard: do not add `docs/library/agents` or `docs/library/skills` to `ops/lib/manifests/CONTEXT.md`.
  - Registry alignment: refuse promotion if registry and file set diverge.
- Definition of Done:
  - Draft exists in `storage/handoff/` with a complete Provenance block.
  - `docs/library/agents/` contains the promoted agent file with required sections (`## Pointers`, `## Scope Boundary`).
  - `docs/ops/registry/AGENTS.md` updated with the new agent ID, name, DP provenance, and specialization.
  - `docs/library/AGENTS.md` updated with candidate and promotion log entries.
  - `bash tools/lint/agent.sh` and `bash tools/lint/library.sh` pass.
  - SoP is updated if any canon or governance surfaces changed.
  - Proof bundle updated in `storage/handoff/` with diff outputs.
- Verification (capture command output in RESULTS):
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh` (required when canon or governance surfaces change)
  - `bash tools/lint/library.sh`
  - `bash tools/lint/agent.sh`

## Candidate Log (append-only)
Append entries are added by `ops/lib/scripts/agent.sh harvest`. Each entry includes timestamp, candidate name, DP provenance, and draft path.
- No entries recorded yet.

## Promotion Log (append-only)
Append entries are added by `ops/lib/scripts/agent.sh promote`. Each entry includes timestamp, assigned agent ID, name, specialization, DP provenance, and promoted file path.
- No entries recorded yet.
