---
template_type: stance
template_id: addenda
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached bundle manifest `resolved_profile=addenda`; if not, **STOP** and request a correct addenda bundle.
* This stance is not used for audit PASS/FAIL verdicts.
* Require `ADDENDUM REQUIRED:` intent in bundle OPEN metadata carrying a canonical base DP ID (DP-OPS-NNNN) and one-line blocker description.
* Build the addendum case from visible evidence in the bundle dump: RESULTS narrative, OPEN metadata, and the boundary condition stated in the intent. No pre-existing decision leaf is required.

Steps:
0. **PRECONDITIONS**: Confirm intent carries `ADDENDUM REQUIRED` with a parseable base DP ID (DP-OPS-NNNN) and one-line blocker. If missing or malformed: **STOP** and request a correctly assembled addenda bundle.
1. **EXTRACT**: From the intent line, read base DP ID and one-line blocker description.
2. **BUILD CASE**: From visible evidence in the dump (RESULTS narrative, OPEN metadata, boundary condition in intent), identify the context, the impacted scope, and the proposed resolution. Summarize the case in A.3 Addendum Objective.
3. **AUTHORIZE**: Produce complete addendum per `ops/src/stances/addendum.md.tpl` (A.1 Authorization through A.5 Addendum Receipt).
4. **SCAN**: `storage/dp/intake/` for existing addenda matching `<BASE_DP_ID>-ADDENDUM-[A-Z].md` and select first available letter from `A` through `Z`.

Output Structure:
- `### Addendum ...`
- `## A.1 Authorization` through `## A.5 Addendum Receipt (Proofs to collect) - MUST RUN`

Output only: Complete addendum (A.1-A.5) in a markdown code block.
{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}
First non-empty line inside the code block must start with `### Addendum`.
For machine-ingest addenda mode: first non-empty line inside the fenced body must start with `### Addendum`.
For machine-ingest addenda mode: include addendum headings `## A.1 Authorization` through `## A.5 Addendum Receipt (Proofs to collect) - MUST RUN`.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
For machine-ingest addenda mode: if `Decision Required:` and `Decision Leaf:` lines are present, values must be coherent (`Yes` with `archives/decisions/RoR-*.md`, `No` with `None`).
