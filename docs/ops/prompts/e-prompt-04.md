## **Analyst (Refresh + Discuss)**

Use when: Read-only analysis, no edits.
Attach: OPEN, dump.

Rules:
* Refresh state using attached OPEN and dump artifacts.
* Follow constraints in `ops/lib/manifests/CONSTRAINTS.md` (Sections 1 & 2).
* Contractor constraints: ops/lib/manifests/CONTRACTOR.md
* Logic: `PoT.md`. Reference: `docs/MAP.md` and `SoP.md`.
* Structure output to facilitate rapid decision-making.

Steps:
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
