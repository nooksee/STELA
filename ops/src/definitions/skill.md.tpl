---
template_type: definition
template_id: skill
template_version: 1
requires_slots:
  - TRACE_ID
  - PACKET_ID
  - CREATED_AT
  - PREVIOUS
  - SKILL_NAME
  - PROVENANCE_BLOCK
  - CONTEXT
  - SOLUTION
includes:
  - ops/lib/manifests/CONSTRAINTS.md#section-1
  - ops/lib/manifests/CONSTRAINTS.md#section-3
---
---
trace_id: {{TRACE_ID}}
packet_id: {{PACKET_ID}}
created_at: {{CREATED_AT}}
previous: {{PREVIOUS}}
---
# Skill Draft: {{SKILL_NAME}}

{{PROVENANCE_BLOCK}}

## Scope
Production payload work only. Not platform maintenance.

## Constraints
{{@include:ops/lib/manifests/CONSTRAINTS.md#section-1}}

{{@include:ops/lib/manifests/CONSTRAINTS.md#section-3}}

## Invocation guidance
Use this skill when {{CONTEXT}}. Apply the solution: {{SOLUTION}}.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Anti-hallucination: use repository files as SSOT and stop if required inputs are missing.
- Negative check: do not add Skills to ops/lib/manifests/CONTEXT.md.

## Procedure
1) Review the context and desired outcome.
2) Apply the solution steps captured in this skill.
3) Verify results and record required evidence in RESULTS.
