---
template_type: stance
template_id: architect
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached bundle manifest `resolved_profile=architect`; if not, **STOP** and request a correct architect bundle.
* Logic: `PoT.md`. Structure: `ops/src/surfaces/dp.md.tpl`.
* Draft from `PLAN.md` `Architect Handoff` selections only: `Selected Option`, `Slice Mode`, `Selected Slices`, and `Execution Order` (required when `Slice Mode=multi`).
* Do not add, rewrite, or propose new options, phases, or slices in architect mode.

Steps:
0. **PRECONDITIONS**: If bundle artifact, bundle manifest, or PLAN.md is missing: **STOP** and request missing artifacts.
1. **VALIDATE PLAN HANDOFF**:
   * Require `Architect Handoff` section in PLAN.md.
   * Require `Selected Option`, `Slice Mode`, and `Selected Slices`.
   * Require `Execution Order` when `Slice Mode=multi`.
   * If any required handoff field is missing or ambiguous: **STOP**.
2. **CONSTRUCT** DP using canonical structure from `ops/src/surfaces/dp.md.tpl`:
   * 3.1 Freshness Gate (Must Pass Before Work)
   * 3.1.1 DP Preflight Gate (Run Before Any Edits)
   * 3.2 Required Context Load (Read Before Doing Anything)
   * 3.3 Scope and Safety
   * 3.4 Execution Plan (A-E): State, Request, Changelog, Patch/Diff, Receipt
   * 3.5 Closeout (Mandatory Routing)
3. **CONTENT REQUIREMENTS**:
   * 3.2 DP-scoped load order: Minimal canon docs/specs/lints worker must load.
   * 3.3 Objective: 1-3 lines.
   * 3.3 Scope: Explicit boundaries plus context hazard exclusions.
   * 3.3 Safety: include no-manual-generated-output, no structural TASK/DP edits, allowlist hard gate.
   * 3.4.1 State: Repo state from bundle metadata (high-level; no pasted payloads).
   * 3.4.2 Request: Translate PLAN into worker requirements using handoff selections only.
   * 3.4.3 Changelog: Explicit file list (UPDATE/NEW) per file.
   * 3.4.4 Patch: Linear implementation steps, exact files, no invented paths.
   * 3.4.5 Receipt: Add scope-specific commands in the `RECEIPT_EXTRA` slot only.
4. **CONSTRAINTS**:
   * Stay in plan scope. Paths exist in dump or are marked NEW.
   * No pattern-paths, globs, or brace expansions.
   * Use exact section numbering per template.
   * Do not output audit verdict markers or audit verdict sections in architect mode.
   * Do not output Contractor Execution Narrative sections or receipt narrative subheadings in architect mode.
   * Do not author or populate any §3.5.1 Mandatory Closing Sidecar field at draft time.
   * Do not infer missing handoff intent. Use explicit selections only or **STOP**.
   * Once preconditions and handoff validation pass, emit the full DP immediately.

Output only: Full DP (starting at `### DP-...`) in one markdown code block.
{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}
First non-empty line inside the code block must start with `### DP-`.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
Do not emit Contractor Execution Narrative sections or receipt narrative subheadings.
