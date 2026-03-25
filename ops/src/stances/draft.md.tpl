---
template_type: stance
template_id: draft
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
{{@include:ops/src/shared/stances.json#stance_hard_truth_rules}}
{{@include:ops/src/shared/stances.json#stance_output_guidance_rules}}
{{@include:ops/src/shared/stances.json#stance_continuity_rules}}
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached bundle manifest `resolved_profile=draft`; if not, **STOP** and request a correct draft bundle.
* Logic: `PoT.md`. Structure: `ops/src/surfaces/dp.md.tpl`.
* Treat the attached `PLAN.md` body as the governing scope.
* Treat the attached `[DP AUTHORING SCAFFOLD]` block as the canonical DP structure to preserve.
* Use `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` when present to build a usable DP.
* Do not expand or replace the settled plan scope in draft mode.
* You may make the smallest bridge decision needed to realize the settled plan when attached artifacts settle intent and authority.
* Preserve canon-owned text from the authoring scaffold unless directly visible attached artifacts require a bounded correction inside settled scope.

Steps:
0. **PRECONDITIONS**: If bundle artifact, bundle manifest, PLAN.md, or the embedded DP authoring scaffold is missing: **STOP** and request the missing artifact.
1. **VALIDATE PLAN FORM**:
   * Use `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` when present to orient DP construction.
   * **STOP** only if the plan leaves objective or authority genuinely unclear — not merely because standard section label names are absent. A plan with clear intent and visible authority is sufficient to proceed.
2. **VALIDATE AUTHORING SCAFFOLD**:
   * Confirm the bundle includes a `DP AUTHORING SCAFFOLD` block bounded by explicit begin/end markers.
   * Confirm the scaffold body itself begins at `### DP-`.
   * Treat bundle `[REQUEST]` metadata (`packet_id`, `dp_draft_path`, `closing_sidecar`) as authoritative routing metadata outside the authored DP body.
3. **AUTHOR THE DP FROM THE SCAFFOLD**:
   * Use the attached authoring scaffold as the base document.
   * Preserve the scaffold's canon-owned section order, headings, injected rules, and closeout boilerplate.
   * Replace only the authoring markers and packet-specific section content using `PLAN.md` plus directly visible attached artifacts.
4. **CONTENT REQUIREMENTS**:
   * Title line: replace the title marker with a concise worker-facing packet title while preserving the packet id from the scaffold.
   * `Work Branch`: author the work branch following PoT.md §6.2.1 form `work/<DP-ID>-YYYY-MM-DD`; fill in the current packet id and freshness stamp date.
   * `3.2.2 DP-scoped load order`: fill with the minimal canon docs/specs/lints the worker must load.
   * `Objective`: 1-3 lines.
   * `In scope`: explicit boundaries plus context hazard exclusions.
   * `Out of scope`: explicit exclusions.
   * `Safety and invariants`: include no-manual-generated-output, no structural TASK/DP edits, allowlist hard gate.
   * `3.4.1 State`: repo state from bundle metadata (high-level; no pasted payloads).
   * `3.4.2 Request`: translate PLAN into worker requirements using the settled plan body as governing scope and use directly visible attached artifacts to correct stale or self-contradictory request details and make bounded continuity decisions needed for a usable DP inside that scope.
   * `3.4.3 Changelog`: explicit file list (UPDATE/NEW) per file.
   * `3.4.4 Patch / Diff`: linear implementation steps, exact files, no invented paths.
   * `3.4.5 Receipt`: add scope-specific commands only.
   * `CbC Design Discipline Preflight`: state applicability and bounded rationale.
5. **CONSTRAINTS**:
   * Stay in plan scope. Paths exist in dump or are marked NEW.
   * No pattern-paths, globs, or brace expansions.
   * Do not emit the raw scaffold, scaffold labels, or slot-block markers as output.
   * Do not emit template include directives, unresolved slot tokens, or unresolved authoring markers.
   * Output only the completed worker-ready DP body.
   * Do not output audit verdict markers or audit verdict sections in draft mode.
   * Do not output Contractor Execution Narrative sections or receipt narrative subheadings in draft mode.
   * Do not author or populate any §3.5.1 Mandatory Closing Sidecar field at draft time.
   * Do not infer objective or authority beyond attached artifacts. For continuity details inside settled scope, make the smallest repo-local decision needed for a usable DP and state it plainly as continuity rather than direct inspection.
   * When directly visible attached artifacts show repo/runtime contract drift inside the settled plan, name the defect plainly and encode the corrective work in the DP instead of flattening the output into read-only summary.
   * Once preconditions and plan scope are settled, emit a complete usable DP instead of collapsing to read-only summary.

Output only: Full DP (starting at `### DP-...`) in one markdown code block.
{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}
First non-empty line inside the code block must start with `### DP-`.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
Do not emit Contractor Execution Narrative sections or receipt narrative subheadings.
