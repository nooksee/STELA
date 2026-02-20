# Definition Specification: Skills Chain

## Purpose
Define the canonical behavior for the skill definition chain rooted at `opt/_factory/SKILLS.md`.
This specification governs candidate and promotion pointer heads, leaf schema requirements, and skill registry linkage.

## Head Contract
`opt/_factory/SKILLS.md` is a four-line pointer head with this exact key order:
1. `candidate:` latest candidate leaf pointer, or origin sentinel.
2. `promotion:` latest promotion leaf pointer, or origin sentinel.
3. `spec:` this specification path.
4. `registry:` `docs/ops/registry/skills.md`.

Allowed head values:
- Origin sentinel: `archives/definitions/skill-candidate-(origin)` and `archives/definitions/skill-promotion-(origin)`.
- Reachable leaf path: `archives/definitions/skill-candidate-YYYY-MM-DD-<suffix>.md` or `archives/definitions/skill-promotion-YYYY-MM-DD-<suffix>.md`.

## Lifecycle
- Candidate emission (`ops/lib/scripts/skill.sh harvest`):
  - Render candidate content from `ops/src/definitions/skill.md.tpl`.
  - Emit a schema-stamped leaf under `archives/definitions/`.
  - Rewrite `candidate:` to the new leaf path.
- Promotion emission (`ops/lib/scripts/skill.sh promote`):
  - Promote canon skill file under `opt/_factory/skills/`.
  - Update `docs/ops/registry/skills.md`.
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

## Guardrails
- Skills remain on-demand and must not be added to `ops/lib/manifests/CONTEXT.md`.
- Candidate and promotion emissions retain template-rendered body content below schema front-matter.
