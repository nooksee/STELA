<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Definition Specification: Agents Chain

## Purpose
Define canonical behavior for the agent definition chain rooted at `opt/_factory/AGENTS.md`.
This specification is authoritative for head pointers, registry linkage, and identity/boundary contract requirements.

## Head Contract
`opt/_factory/AGENTS.md` is a four-line pointer head in exact order:
1. `candidate:` latest candidate leaf pointer, or origin sentinel.
2. `promotion:` latest promotion leaf pointer, or origin sentinel.
3. `spec:` this specification path.
4. `registry:` `docs/ops/registry/agents.md`.

Allowed head values:
- Origin sentinel: `archives/definitions/agent-candidate-(origin)` and `archives/definitions/agent-promotion-(origin)`.
- Reachable leaf path: `archives/definitions/agent-candidate-YYYY-MM-DD-<suffix>.md` or `archives/definitions/agent-promotion-YYYY-MM-DD-<suffix>.md`.

## Lifecycle
- Candidate emission (`ops/lib/scripts/agent.sh harvest`):
  - Render candidate content from `ops/src/definitions/agent.md.tpl`.
  - Emit a schema-stamped leaf under `archives/definitions/`.
  - Rewrite `candidate:` to the new leaf path.
- Promotion emission (`ops/lib/scripts/agent.sh promote`):
  - Promote canon agent file under `opt/_factory/agents/`.
  - Update `docs/ops/registry/agents.md`.
  - Emit promotion leaf under `archives/definitions/`.
  - Rewrite `promotion:` to the new leaf path.

## Canon Agent Body Contract Baseline
Canon agent files under `opt/_factory/agents/` must contain:
- `## Provenance`
- `## Role`
- `## Specialization`
- `## Identity Contract` with required backticked fields:
  - `agent_id` (must match filename form `r-agent-XX` -> `R-AGENT-XX`)
  - `runtime_role` (must be one of `foreman`, `auditor`, `conformist`)
  - `stance_id` (must be one of `addenda`, `audit`, `conformist`)
- `## Capability Tags` with at least one backticked capability token bullet.
- `## Pointers`
- `## Skill Bindings` with explicit `required_skills` and `optional_skills` lists.
- `## Scope Boundary`

Role-boundary split is strict:
- agent files define identity, authority boundary, pointers, and skill binding.
- `runtime_role` keeps the actor noun (`auditor`) while `stance_id` carries the task/stance noun (`audit`) when those differ.
- skill files define method contract.
- task files define objective contract.
- stance templates define output-envelope behavior.
- stance prose must not be duplicated in agent leaves.

## Leaf Schema
Leaf frontmatter keys are required:
- `trace_id`
- `packet_id`
- `created_at`
- `previous`

`previous` semantics:
- When prior head is an origin sentinel ending with `-(origin)`, emit `previous: (none)`.
- Otherwise emit the prior head pointer path.
