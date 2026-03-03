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
1. **ANALYZE** Operator query using attached context.
2. **SYNTHESIZE** findings based on `PoT.md` and repository state, treating OPEN and dump
   bundles as session artifacts rather than canonical sources.
3. **FORMULATE** Strategic Options menu (2-3 actionable paths).

Operator query template:
1. ANALYZE `<topic>`.
2. SYNTHESIZE `<aspect>`.
3. FORMULATE `<solutions>`.

Output Structure:
1. Analysis/Discussion (The "Why" and "What")
2. Strategic Options (The "How"):
   * 2-3 distinct paths with Pros, Cons, Risk
   * Include Recommendation/Proposal

Output: Recommendation/Discussion followed by Strategic Options menu.
