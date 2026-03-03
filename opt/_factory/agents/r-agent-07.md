# Agent: factory-chain-agent-test

## Provenance
- **Captured:** 2026-02-19 01:51:42 UTC
- **DP-ID:** DP-OPS-0074
- **Branch:** work/dp-ops-0074-2026-02-18
- **HEAD:** 45af651efaa13ad13c457c708b399b07497a3819
- **Objective:** Validate pointer-first factory head chain behavior.
- **Friction Context:**
  - Hot Zone: None
  - High Churn: None
- **Diff Stat:**
```text
(no changes)
```

## Role
Validates factory candidate and promotion pointer workflows.

## Specialization
Factory chain pointer remediation validation.

## Pointers
- Constitution: `PoT.md`
- Governance/Jurisdiction: `docs/GOVERNANCE.md`
- Output contract: `TASK.md`
- Authorized toolchain: `ops/bin/open`, `ops/bin/dump`, `ops/bin/llms`, `tools/lint/context.sh`, `tools/lint/truth.sh`, `tools/lint/factory.sh`, `tools/verify.sh`
- JIT skills:
- `opt/_factory/skills/s-learn-06.md`

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

## Scope Boundary
Operate only within the active DP and defer to canon surfaces for governance and behavioral rules.
