---
trace_id: stela-20260219T020107Z-a74a0007
packet_id: DP-OPS-0074
created_at: 2026-02-19T01:55:40Z
previous: archives/definitions/task-promotion-2026-02-19-a74a0004-B-TASK-07.md
---
# Task: Task: Factory Chain Validation

## Provenance
- **Captured:** 2026-02-19 01:53:08 UTC
- **DP-ID:** DP-OPS-0074
- **Branch:** work/dp-ops-0074-2026-02-18
- **HEAD:** 45af651efaa13ad13c457c708b399b07497a3819
- **Objective:** Validate factory candidate and promotion chain workflows.
- **Friction Context:**
  - Hot Zone: None
  - High Churn: None
- **Diff Stat:**
```text
(no changes)
```

## Orchestration
- **Primary Agent:** R-AGENT-01
- **Supporting Agents:** (none)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** Not provided
- **JIT Skills:** (none)
- **Reference Docs:** Not provided

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

## Execution Logic
1. Pre-flight: Not provided.
2. Execution: Not provided.
3. Verification: Not provided.
4. Correction: Not provided.
5. Closeout: Complete Closeout per `TASK.md` Section 3.5.

## Scope Boundary
- **Allowed:** Execute only allowlisted DP changes and complete Closeout per `TASK.md` Section 3.5.
- **Forbidden:** Do not modify out-of-scope files or skip required verification.
- **Stop Conditions:** Stop on missing required inputs, lint failures, or scope expansion.
