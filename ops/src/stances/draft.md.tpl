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
* Use `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` when present to build a usable DP.
* Do not expand or replace the settled plan scope in draft mode.
* You may make the smallest bridge decision needed to realize the settled plan when attached artifacts settle intent and authority.

Steps:
0. **PRECONDITIONS**: If bundle artifact, bundle manifest, or PLAN.md is missing: **STOP** and request missing artifacts.
1. **VALIDATE PLAN FORM**:
   * Use `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` when present to orient DP construction.
   * **STOP** only if the plan leaves objective or authority genuinely unclear — not merely because standard section label names are absent. A plan with clear intent and visible authority is sufficient to proceed.
2. **POPULATE DP SLOTS SCAFFOLD**:
   * Emit a populated scaffold in the exact `./ops/bin/draft --emit-dp-slots-scaffold` format.
   * Populate these required scaffold blocks only:
     * `[DP_SCOPED_LOAD_ORDER]`
     * `[OBJECTIVE]`
     * `[IN_SCOPE]`
     * `[OUT_OF_SCOPE]`
     * `[SAFETY_INVARIANTS]`
     * `[PLAN_STATE]`
     * `[PLAN_REQUEST]`
     * `[PLAN_CHANGELOG]`
     * `[PLAN_PATCH]`
     * `[RECEIPT_EXTRA]`
     * `[CBC_PREFLIGHT]`
   * Treat bundle `[REQUEST]` metadata (`packet_id`, `dp_draft_path`, `closing_sidecar`) as authoritative routing metadata outside the scaffold body.
3. **CONTENT REQUIREMENTS**:
   * `[DP_SCOPED_LOAD_ORDER]`: Minimal canon docs/specs/lints worker must load.
   * `[OBJECTIVE]`: 1-3 lines.
   * `[IN_SCOPE]`: Explicit boundaries plus context hazard exclusions.
   * `[OUT_OF_SCOPE]`: Explicit exclusions.
   * `[SAFETY_INVARIANTS]`: include no-manual-generated-output, no structural TASK/DP edits, allowlist hard gate.
   * `[PLAN_STATE]`: Repo state from bundle metadata (high-level; no pasted payloads).
   * `[PLAN_REQUEST]`: Translate PLAN into worker requirements using the settled plan body as governing scope and use directly visible attached artifacts to correct stale or self-contradictory request details and make bounded continuity decisions needed for a usable DP inside that scope.
   * `[PLAN_CHANGELOG]`: Explicit file list (UPDATE/NEW) per file.
   * `[PLAN_PATCH]`: Linear implementation steps, exact files, no invented paths.
   * `[RECEIPT_EXTRA]`: Add scope-specific commands only.
   * `[CBC_PREFLIGHT]`: State applicability and bounded rationale.
4. **CONSTRAINTS**:
   * Stay in plan scope. Paths exist in dump or are marked NEW.
   * No pattern-paths, globs, or brace expansions.
   * Do not emit the full rendered DP body.
   * Do not emit template include directives or unresolved slot tokens.
   * Do not output audit verdict markers or audit verdict sections in draft mode.
   * Do not output Contractor Execution Narrative sections or receipt narrative subheadings in draft mode.
   * Do not author or populate any §3.5.1 Mandatory Closing Sidecar field at draft time.
   * Do not infer objective or authority beyond attached artifacts. For continuity details inside settled scope, make the smallest repo-local decision needed for a usable scaffold and state it plainly as continuity rather than direct inspection.
   * When directly visible attached artifacts show repo/runtime contract drift inside the settled plan, name the defect plainly and encode the corrective work in the scaffold instead of flattening the output into read-only summary.
   * Once preconditions and plan scope are settled, emit a complete usable scaffold instead of collapsing to read-only summary.

Legacy style-lint compatibility markers only; do not follow these retired rendered-body lines for the current scaffold contract:
Output only: Full DP (starting at `### DP-...`) in one markdown code block.
First non-empty line inside the code block must start with `### DP-`.
Output only: Populated DP slots scaffold in one markdown code block.
{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}
First non-empty line inside the code block must start with `[DP_SCOPED_LOAD_ORDER]`.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
Do not emit Contractor Execution Narrative sections or receipt narrative subheadings.
