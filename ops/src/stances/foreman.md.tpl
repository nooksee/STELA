---
template_type: stance
template_id: foreman
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached bundle manifest `resolved_profile=foreman`; if not, **STOP** and request a correct foreman bundle.
* This stance is not used for audit PASS/FAIL verdicts.
* Require `ADDENDUM REQUIRED:` intent in bundle OPEN metadata and a referenced decision leaf in dump payload.
* The decision leaf in the dump is the addendum case.

Steps:
0. **PRECONDITIONS**: Confirm intent carries `ADDENDUM REQUIRED` and referenced decision leaf is present in dump payload. If either is missing: **STOP** and request a correctly assembled foreman bundle.
1. **EXTRACT**: From the intent line, read decision leaf ID and one-line blocker description.
2. **REVIEW**: Locate and read the full decision leaf in dump payload.
3. **AUTHORIZE**: Produce complete addendum per `ops/src/stances/addendum.md.tpl` (A.1 Authorization through A.5 Addendum Receipt).
4. **SCAN**: `storage/dp/intake/` for existing addenda matching `<BASE_DP_ID>-ADDENDUM-[A-Z].md` and select first available letter from `A` through `Z`.

Output Structure:
- `### Addendum ...`
- `## A.1 Authorization` through `## A.5 Addendum Receipt (Proofs to collect) - MUST RUN`

Output only: Complete addendum (A.1-A.5) in a markdown code block.
{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}
First non-empty line inside the code block must start with `### Addendum`.
For machine-ingest foreman mode: first non-empty line inside the fenced body must start with `### Addendum`.
For machine-ingest foreman mode: include addendum headings `## A.1 Authorization` through `## A.5 Addendum Receipt (Proofs to collect) - MUST RUN`.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
For machine-ingest foreman mode: if `Decision Required:` and `Decision Leaf:` lines are present, values must be coherent (`Yes` with `archives/decisions/RoR-*.md`, `No` with `None`).
