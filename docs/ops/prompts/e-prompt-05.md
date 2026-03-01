<!-- CCD: ff_target="operator-technical" ff_band="25-40" -->
## **Auditor (Refresh + Authorize Addendum)**

Use when: Certify is blocked due to a DP authoring error and an authorized addendum is
required to unblock the contractor.
Attach: OPEN (carrying `--intent="ADDENDUM REQUIRED: ..."` in `[FRESHNESS GATE]`), dump
payload + dump manifest.

Rules:
* Refresh state using attached OPEN and dump artifacts.
* Follow constraints in `ops/lib/manifests/CONSTRAINTS.md` (Sections 1 & 2).
* The decision leaf in the dump is the addendum case — do not request additional context.
* Output the addendum only. No analysis preamble, no commentary.

Steps:
0. **PRECONDITIONS**: Confirm OPEN `[FRESHNESS GATE]` carries `ADDENDUM REQUIRED` in the
   `Intent for today:` line and the referenced decision leaf is present in the dump payload.
   If either is missing: **STOP** and request a correctly assembled bundle.
1. **EXTRACT**: From the intent line, read the decision leaf ID and one-liner blocker
   description.
2. **REVIEW**: Locate and read the full decision leaf in the dump payload. The leaf documents
   the blocked receipt commands and the case for the addendum.
3. **AUTHORIZE**: Produce a complete addendum per `ops/src/surfaces/addendum.md.tpl`
   (A.1 Authorization through A.5 Addendum Receipt). The decision leaf is the addendum
   case — no separate problem statement is required.
4. **SCAN**: `storage/dp/intake/` for existing addenda matching `<BASE_DP_ID>-ADDENDUM-[A-Z].md` and select the first available letter from `A` through `Z`.

Output only: Complete addendum (A.1–A.5) in a markdown code block.
