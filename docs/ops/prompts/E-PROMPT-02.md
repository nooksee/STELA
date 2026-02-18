## **Hygiene (Refresh + Conform to DP Structure)**

Use when: Normalizing rough draft into canonical DP structure.
Attach: OPEN, dump, draft-DP.md.

Rules:
* Refresh state using attached OPEN and dump artifacts.
* Follow constraints in `ops/lib/manifests/CONSTRAINTS.md` (Sections 1 & 2).
* Logic: `PoT.md`. Structure: `ops/src/surfaces/dp.md.tpl`.
* Preserve intent; update contract language/structure only.

Steps:
1. **NORMALIZE** into canonical structure per `ops/src/surfaces/dp.md.tpl`:
   * 3.1 Freshness Gate (Must Pass Before Work)
   * 3.1.1 DP Preflight Gate (Run Before Any Edits)
   * 3.2 Required Context Load (Read Before Doing Anything)
   * 3.3 Scope and Safety
   * 3.4 Execution Plan (A-E): State, Request, Changelog, Patch/Diff, Receipt
   * 3.5 Closeout (Mandatory Routing)
2. **INPUT DISCIPLINE**: No disposable artifact citations. No placeholders. If missing
   details: **STOP**.
3. **ALLOWLIST**: List all touched/created files in Section 3.3 Target Files allowlist.
4. **VERIFY PATHS**: Must exist in dump or marked NEW.
5. **RECEIPTS**: Include baseline per `dp.md.tpl` Section 3.4.5 + scope-specific verifications.
   Ensure Section 3.5 references `ops/bin/certify` as the RESULTS generation step.

Output only: Full DP in markdown code block.