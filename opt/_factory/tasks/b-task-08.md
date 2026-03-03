# Task: Bundle Orchestration

## Provenance
- **Captured:** 2026-03-03 05:57:42 UTC
- **DP-ID:** DP-OPS-0145
- **Branch:** work/dp-ops-0145-bundle-primitive-2026-03-03
- **HEAD:** 8c0a088bf0bafaa429950eb7dfad9f9ab27d348a
- **Objective:** Govern bundle artifact contract and profile routing expectations.
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
- **Registry:** `docs/ops/registry/tasks.md`
- **Toolchain:** Not provided
- **JIT Skills:** (none)
- **Reference Docs:** Not provided

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
