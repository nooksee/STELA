# Definition Specification: Agents Chain

## Purpose
Define the canonical behavior for the agent definition chain rooted at `opt/_factory/AGENTS.md`.
This specification is authoritative for candidate and promotion pointer heads, emission flow, and registry linkage.

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
