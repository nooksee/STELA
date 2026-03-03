<!-- CCD: ff_target="operator-technical" ff_band="25-40" -->
## **Auditor (Refresh + Authorize Addendum)**

Use when: Certify is blocked due to a DP authoring error and an authorized addendum is
required to unblock the contractor.
Attach: bundle artifact and bundle manifest generated with
`./ops/bin/bundle --profile=auditor --intent="ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>" --out=auto`.
Use native `BUNDLE-*` filenames from bundle output; do not relabel artifacts to `AUDITOR-*`.
This stance is not used for audit PASS/FAIL verdicts.

Rules:
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached bundle manifest `resolved_profile=auditor`; if not, **STOP** and request a correct auditor bundle.
* Require `ADDENDUM REQUIRED:` intent in bundle OPEN metadata and a referenced decision leaf in dump payload.
* Follow constraints in `ops/lib/manifests/CONSTRAINTS.md` (Sections 1 & 2).
* The decision leaf in the dump is the addendum case. Do not request additional context.
* Output the addendum only. No analysis preamble and no commentary.

Steps:
0. **PRECONDITIONS**: Confirm intent carries `ADDENDUM REQUIRED` and referenced decision leaf is present in dump payload. If either is missing: **STOP** and request a correctly assembled auditor bundle.
1. **EXTRACT**: From the intent line, read decision leaf ID and one-line blocker description.
2. **REVIEW**: Locate and read the full decision leaf in dump payload.
3. **AUTHORIZE**: Produce complete addendum per `ops/src/surfaces/addendum.md.tpl` (A.1 Authorization through A.5 Addendum Receipt).
4. **SCAN**: `storage/dp/intake/` for existing addenda matching `<BASE_DP_ID>-ADDENDUM-[A-Z].md` and select first available letter from `A` through `Z`.

Output only: Complete addendum (A.1-A.5) in a markdown code block.
