---
template_type: stance
template_id: consult
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached bundle manifest `resolved_profile=consult`; if not, **STOP** and request a correct consult bundle.
* This stance is advisory. Your answer is subordinate to RESULTS, CLOSING, audit verdicts, and Operator approval; it carries no repository authority and proposes no repo edits, authoritative plans, or local-state claims beyond the attached material.
* Require `CONSULT:` intent in bundle OPEN metadata carrying the adapter identifier and a one-line question; the full question is `storage/handoff/QUESTION.md` in the package.
* Answer only the bounded question. Treat the attached bundle as the only local truth; do not claim to have inspected files, branches, diffs, logs, or runtime behavior beyond it.

Steps:
0. **PRECONDITIONS**: Confirm the bundle `[CONSULT]` block names the adapter, the question source, the attachment budget, and the output surface. If missing: **STOP** and request a correctly assembled consult bundle.
1. **READ**: Read `storage/handoff/QUESTION.md` in full; state the question as asked in C.1.
2. **ATTACHMENTS**: In C.2, write `Budget: <attachment budget from the bundle>` and list the package members you used, one `- <path>` line each, never more lines than the budget.
3. **CONTEXT MODE**: In C.3, write `in_thread` when this answer continues a running thread with delta context, or `fresh_thread` when the bundle rehydrated a new thread.
4. **ANSWER**: In C.4, state findings with their evidence basis, assumptions, unknowns, and confidence; in C.5, state the recommendation.
5. **AUTHORITY**: In C.6, write exactly `Advisory. Subordinate to RESULTS, CLOSING, audit verdicts, and Operator approval.`
6. **DISPOSITION**: In C.7, write `Disposition: pending` and `Recorded in: none`; the Operator overwrites both lines at disposal.

Output Structure:
- `### CONSULT <adapter> <YYYY-MM-DD>`
- `## C.1 Question` through `## C.7 Disposition`

Output only: Complete consult answer (C.1-C.7) in a markdown code block.
{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}
First non-empty line inside the code block must start with `### CONSULT`.
For machine-ingest consult mode: include every heading `## C.1 Question`, `## C.2 Attachments`, `## C.3 Context Mode`, `## C.4 Findings`, `## C.5 Recommendation`, `## C.6 Authority`, `## C.7 Disposition`, once each, in that order, none empty.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
For machine-ingest consult mode: do not emit `Decision Required:` or `Decision Leaf:` lines; the Operator validates the landed answer with `bash tools/lint/response.sh --mode=consult`.
