# S-LEARN-07: Factory Chain Validation Skill
trace_id: stela-20260219T020105Z-a74a0005
packet_id: DP-OPS-0074
created_at: 2026-02-19T01:54:29Z
previous: (none)
---
# Skill Draft: Factory Chain Validation Skill

## Provenance
- **Captured:** 2026-02-19 01:54:29 UTC
- **DP-ID:** DP-OPS-0074
- **Branch:** work/dp-ops-0074-2026-02-18
- **HEAD:** 45af651efaa13ad13c457c708b399b07497a3819
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
- Templates are authored as `.tpl` files and may begin with YAML frontmatter.
- Frontmatter keys are canonical and machine-read:
  - `template_type`
  - `template_id`
  - `template_version`
  - `requires_slots`
  - `includes`
- Rendered output must strip YAML frontmatter before writing output.
- Slot tokens are `\{\{TOKEN\}\}` where `TOKEN` is uppercase alphanumeric with underscores.
- Include directives are supported in template body content:
  - `\{\{@include:path\}\}`
  - `\{\{@include:path#section\}\}`
- Include resolution is deterministic and strict:
  - Missing files fail render.
  - Missing section anchors fail render.
  - Circular include graphs fail render.
- Strict mode is default for worker-facing output:
  - Every `requires_slots` token must be provided.
  - Unresolved `\{\{TOKEN\}\}` placeholders fail render.
- Non-strict mode is allowed only for linting and normalization workflows.
- Generated worker-facing surfaces must remain pointer-first and must not embed disposable artifacts.

## Section 3: Definition-Specific Rules
- Definition templates (`agent`, `task`, `skill`) inherit Section 1 universal render rules.
- Definitions must keep canon references pointer-first (`PoT.md`, governance pointers, TASK contract pointers).
- Definitions must not duplicate constitutional prose; they reference canon instead.
- Definition drafts must remain compatible with existing harvester/promotion lint gates.
- Definitions must preserve closeout and verification routing expectations.

## Invocation Guidance
Use this skill when validating pointer-head candidate and promotion workflows in this repository. Apply the solution: run harvest and promote commands for each factory chain, then run factory, verify, schema, style, and context lints.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/SKILLS.md`

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Anti-hallucination: use repository files as SSOT and stop if required inputs are missing.
- Negative check: do not add Skills to ops/lib/manifests/CONTEXT.md.

## Procedure
1) Review the context and desired outcome.
2) Apply the solution steps captured in this skill.
3) Verify results and record required evidence in RESULTS.
