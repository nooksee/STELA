<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Definition Specification: Agents Chain

## Purpose
Define the canonical behavior for the agent definition chain rooted at `opt/_factory/AGENTS.md`.
This specification is authoritative for candidate and promotion pointer heads, emission flow, and registry linkage.
Think of the pointer head like a route card that tells every operator which candidate and promotion leaves are current.

## Head Contract
`opt/_factory/AGENTS.md` is a four-line pointer head with this exact key order:
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

## Canon Agent Body Contract
Canon agent files under `opt/_factory/agents/` must contain:
- `## Provenance`
- `## Role`
- `## Specialization`
- `## Identity Contract` with:
  - ``agent_id`` backticked and aligned to filename (`r-agent-XX` -> `R-AGENT-XX`)
  - ``stance_id`` backticked and in canonical stance set (`analyst`, `architect`, `auditor`, `conformist`, `contractor`, `foreman`)
- `## Capability Tags` with at least one backticked capability token bullet
- `## Pointers` without legacy `JIT skills` sub-block
- `## Skill Bindings` with explicit ``required_skills`` and ``optional_skills`` lists
- `## Scope Boundary`

Role-boundary split is strict:
- agent files define identity, authority boundary, pointers, and skill binding
- stance templates define output-envelope behavior and response formatting
- agent files must not embed stance-envelope directives

## Leaf Schema
Leaf front-matter keys are required:
- `trace_id`
- `packet_id`
- `created_at`
- `previous`

`previous` semantics:
- When prior head is an origin sentinel ending with `-(origin)`, emit `previous: (none)`.
- Otherwise emit the prior head pointer path.

## Operator Workflow
- Use `ops/lib/scripts/agent.sh harvest-check` for Pattern Density signal review.
- Use `ops/lib/scripts/agent.sh harvest` for candidate emission.
- Review candidate content before promotion.
- Use `ops/lib/scripts/agent.sh promote` to finalize canonical agent and advance promotion head.
- Use `ops/lib/scripts/agent.sh check` for boundary and context hazard checks.
