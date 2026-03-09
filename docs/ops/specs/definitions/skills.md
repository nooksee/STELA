<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Definition Specification: Skills Chain

## Purpose
Define canonical behavior for the skill definition chain rooted at `opt/_factory/SKILLS.md`.
This specification governs pointer heads, leaf schema requirements, and method-contract normalization.

## Head Contract
`opt/_factory/SKILLS.md` is a four-line pointer head with exact key order:
1. `candidate:` latest candidate leaf pointer, or origin sentinel.
2. `promotion:` latest promotion leaf pointer, or origin sentinel.
3. `spec:` this specification path.
4. `registry:` `docs/ops/registry/skills.md`.

Allowed head values:
- Origin sentinel: `archives/definitions/skill-candidate-(origin)` and `archives/definitions/skill-promotion-(origin)`.
- Reachable leaf path: `archives/definitions/skill-candidate-YYYY-MM-DD-<suffix>.md` or `archives/definitions/skill-promotion-YYYY-MM-DD-<suffix>.md`.

## Lifecycle
- Candidate emission (`ops/lib/scripts/skill.sh harvest`): render template, emit leaf, advance `candidate:`.
- Promotion emission (`ops/lib/scripts/skill.sh promote`): promote canon skill, update registry, emit leaf, advance `promotion:`.

## Canon Skill Body Contract Baseline
Canon skill files under `opt/_factory/skills/` must contain:
- `## Provenance`
- `## Scope`
- `## Method Contract` with required backticked fields:
  - `skill_id`
  - `method`
  - `inputs`
  - `outputs`
  - `invariants`
- `## Invocation Guidance`
- `## Pointers`
- `## Guardrails` or `## Drift preventers`

Skill contract intent:
- skill files define method and execution constraints.
- skill files must not embed stance-envelope directives.
- skill files remain pointer-first and deterministic.

## Leaf Schema
Leaf frontmatter keys are required:
- `trace_id`
- `packet_id`
- `created_at`
- `previous`

`previous` semantics:
- origin sentinel -> `previous: (none)`
- otherwise prior head pointer path.
