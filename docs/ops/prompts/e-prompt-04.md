<!-- CCD: ff_target="operator-technical" ff_band="25-40" -->
## **Analyst (Refresh + Discuss)**

Use when: Read-only analysis, no edits.
Attach: bundle artifact, bundle manifest, and operator query source (inline query or `storage/handoff/TOPIC.md`).

Rules:
* Generate analyst intake with `./ops/bin/bundle --profile=analyst --out=auto` (or `--profile=auto` for route-gated intake).
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require one operator query source before analysis: either attached `storage/handoff/TOPIC.md` or an inline `ANALYZE/SYNTHESIZE/FORMULATE` query in the message.
* Follow constraints in `ops/lib/manifests/CONSTRAINTS.md` (Sections 1 & 2).
* Contractor constraints: ops/lib/manifests/CONTRACTOR.md
* Logic: `PoT.md`. Reference: `docs/MAP.md` and `SoP.md`.
* Structure output to facilitate rapid decision-making.

Steps:
0. **PRECONDITIONS**: If neither `storage/handoff/TOPIC.md` nor an inline operator query is provided: **STOP** and request a query source.
1. **ANALYZE** operator query using attached context.
2. **SYNTHESIZE** findings based on `PoT.md` and repository state, treating OPEN and dump bundles as session artifacts rather than canonical sources.
3. **FORMULATE** strategic options menu (2-3 actionable paths).
4. **PLAN OUTPUT MODE**: When operator asks for an architect-ready plan, output only a complete `PLAN.md` draft in a markdown code block, generated against `ops/src/surfaces/plan.md.tpl`.
   * Required `Architect Handoff` fields:
     * `Selected Option: <A|B|C|RECOMMENDED>`
     * `Slice Mode: <single|multi>`
     * `Selected Slices: <S1[,S2...]>`
     * `Execution Order: <required when multi>`
     * `Architect Constraints: <no new options; draft from selected fields only>`
   * Required `DP Slot Source Map` fields:
     * `DP_ID`
     * `DP_TITLE`
     * `BASE_BRANCH`
     * `WORK_BRANCH`
     * `BASE_HEAD`
     * `FRESHNESS_STAMP`
     * `CBC_PREFLIGHT`
     * `DP_SCOPED_LOAD_ORDER`
     * `SAFETY_INVARIANTS`
     * `PLAN_STATE`

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
For PLAN output mode: output only the complete PLAN markdown code block.
