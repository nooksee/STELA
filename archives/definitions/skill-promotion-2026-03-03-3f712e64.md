---
trace_id: stela-20260303T045355Z-3f712e64
packet_id: Not provided
created_at: 2026-03-03T05:57:48Z
previous: archives/definitions/skill-promotion-2026-02-19-a74a0006.md
---
# S-LEARN-08: Bundle Profile Governance
trace_id: stela-20260303T045355Z-3f712e64
packet_id: Not provided
created_at: 2026-03-03T05:57:42Z
previous: archives/definitions/skill-candidate-2026-02-19-a74a0005.md
---
# Skill Draft: Bundle Profile Governance

## Provenance
- **Captured:** 2026-03-03 05:57:42 UTC
- **DP-ID:** Not provided
- **Branch:** work/dp-ops-0145-bundle-primitive-2026-03-03
- **HEAD:** 8c0a088bf0bafaa429950eb7dfad9f9ab27d348a
- **Objective:** Not provided
- **Friction Context:**
  - Hot Zone: None
  - High Churn: None
- **Diff Stat:**
```text
(no changes)
```

## Scope
Production payload work only. Not platform maintenance.

## Constraints
## Section 1: Universal Template Rules
- Template source uses `tpl` files with optional YAML frontmatter
- Canon frontmatter keys: `template_type` `template_id` `template_version` `requires_slots` `includes`
- Renderer strips frontmatter before output write
- Slot token form `\{\{TOKEN\}\}` with uppercase alphanumeric underscore
- Include forms `\{\{@include:path\}\}` and `\{\{@include:path#section\}\}`
- Include resolution is strict: missing file fail missing section fail circular graph fail
- Strict mode default: every required slot value present and no unresolved token
- Non strict mode allowed only for lint and normalization workflows
- Worker facing generated surfaces remain pointer first and exclude disposable artifacts

## Section 3: Definition-Specific Rules
- `agent` `task` and `skill` templates inherit Section 1 rules
- Definitions keep canonical pointers and avoid constitutional prose duplication
- Definition drafts remain compatible with harvest and promotion lint gates
- Definitions preserve closeout and verification routing requirements

## Invocation Guidance
Use this skill when Use when validating bundle routing rules, PLAN lint gating, and artifact contract compliance.. Apply the solution: Apply the bundle contract, keep runtime deterministic, and treat factory markdown definitions as governance surfaces only..

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/skills.md`

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Anti-hallucination: use repository files as SSOT and stop if required inputs are missing.
- Negative check: do not add Skills to ops/lib/manifests/CONTEXT.md.

## Procedure
1) Review the context and desired outcome.
2) Apply the solution steps captured in this skill.
3) Verify results and record required evidence in RESULTS.
