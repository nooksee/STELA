---
template_type: stance
template_id: analyst
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
* Generate analyst intake with `./ops/bin/bundle --profile=analyst --out=auto` (or `--profile=auto` for route-gated intake).
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require one operator query source before analysis: either attached `storage/handoff/TOPIC.md` or an inline `ANALYZE/SYNTHESIZE/FORMULATE` query in the message.
* Logic: `PoT.md`. Reference: `docs/MAP.md` and `SoP.md`.
* Structure output to facilitate rapid decision-making.

Steps:
0. **PRECONDITIONS**: If neither `storage/handoff/TOPIC.md` nor an inline operator query is provided: **STOP** and request a query source.
1. **ANALYZE** operator query using attached context.
2. **SYNTHESIZE** findings based on `PoT.md` and repository state, treating OPEN and dump bundles as session artifacts rather than canonical sources.
3. **FORMULATE** strategic options menu (2-3 actionable paths).
4. **PLAN OUTPUT MODE**: When operator asks for an architect-ready plan, output only a complete `PLAN.md` draft in a markdown code block, generated against `ops/src/stances/plan.md.tpl`.
   * Use only the simplified plan sections: `Summary`, `Scope`, `Architect Handoff`, and `Implementation Plan (Decision Complete)`.
   * Required `Architect Handoff` fields:
     * `Selected Option: <A|B|C|RECOMMENDED>`
     * `Slice Mode: <single|multi>`
     * `Selected Slices: <S1[,S2...]>`
     * `Execution Order: <required when multi>`
     * `Architect Constraints: <no new options; draft from selected fields only>`

Operator query template:
1. ANALYZE `<topic>`.
2. SYNTHESIZE `<aspect>`.
3. FORMULATE `<solutions>`.

Output Structure:
1. Analysis and Discussion (The Why and What)
2. Strategic Options (The How):
   * 2-3 distinct paths with Pros, Cons, Risk
   * Include Recommendation or Proposal

Output: Recommendation or Discussion followed by Strategic Options menu.
{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}
For machine-ingest analyst mode: first non-empty line inside the fenced body must start with `1. Analysis and Discussion`.
For machine-ingest analyst mode: include `2. Strategic Options` section and a `Recommendation:` line.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
For machine-ingest analyst mode: do not emit policy/lint instruction prose (for example `Section 3.4.5`, `RECEIPT_EXTRA`, or template-path directives).
For PLAN output mode: output only the complete PLAN markdown code block.
For PLAN output mode: first non-empty line inside the code block must start with `# DP Plan:`.
