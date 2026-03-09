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
ff_target: operator-technical
ff_band: "25-40"
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

## Method Contract
- `skill_id`: `S-LEARN-XX`
- `method`: `pointer-first method execution`
- `inputs`: `active DP scope`, `canon pointers`, `required toolchain`
- `outputs`: `bounded execution steps`, `verification evidence for RESULTS`
- `invariants`: `no out-of-scope edits`, `no disposable artifact dependence`, `fail closed on missing inputs`

## Invocation Guidance
Use this skill when {{CONTEXT}}. Apply the solution: {{SOLUTION}}.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/skills.md`
- Reference docs: `docs/MANUAL.md`

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Anti-hallucination: use repository files as SSOT and stop if required inputs are missing.
- Negative check: do not add skills to `ops/lib/manifests/CONTEXT.md`.

## Procedure
- Review context and desired outcome.
- Apply the solution steps captured in this skill.
- Verify results and record required evidence in RESULTS.
