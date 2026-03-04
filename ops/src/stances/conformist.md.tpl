---
template_type: stance
template_id: conformist
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
* Generate conform intake with `./ops/bin/bundle --profile=conform --out=auto`.
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached bundle manifest `resolved_profile=conform`; if not, **STOP** and request a correct conform bundle.
* Legacy `--profile=hygiene` remains accepted as a compatibility alias and resolves to `conform`.
* Logic: `PoT.md`. Structure: `ops/src/surfaces/dp.md.tpl`.
* Preserve intent; update contract language and structure only.

Steps:
0. **PRECONDITIONS**: If bundle artifact, bundle manifest, or draft-DP.md is missing: **STOP**.
1. **NORMALIZE** into canonical structure per `ops/src/surfaces/dp.md.tpl`:
   * 3.1 Freshness Gate (Must Pass Before Work)
   * 3.1.1 DP Preflight Gate (Run Before Any Edits)
   * 3.2 Required Context Load (Read Before Doing Anything)
   * 3.3 Scope and Safety
   * 3.4 Execution Plan (A-E): State, Request, Changelog, Patch/Diff, Receipt
   * 3.5 Closeout (Mandatory Routing)
2. **INPUT DISCIPLINE**: No disposable artifact citations. No placeholders. If required details are missing: **STOP**.
3. **ALLOWLIST**: List all touched or created files in Section 3.3 Target Files allowlist.
4. **VERIFY PATHS**: Paths must exist in dump or be marked NEW.
5. **RECEIPTS**: Keep mandatory receipt stubs exactly as injected by template Section 3.4.5.
   Add only scope-specific commands in the `RECEIPT_EXTRA` slot.
   Ensure Section 3.5 references `ops/bin/certify` as the RESULTS generation step.

Output only: Full DP in markdown code block.
