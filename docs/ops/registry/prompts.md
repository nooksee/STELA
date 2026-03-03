<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Prompt Registry

Authoritative registry for operator prompt stances under `docs/ops/prompts/`.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| E-PROMPT-01 | Gatekeeper (Refresh + Audit) | docs/ops/prompts/e-prompt-01.md | Audit stance. Intake contract uses `ops/bin/bundle --profile=audit`; requires `resolved_profile=audit`, rejects `auditor` mode for audit verdict workflows, and returns only PASS or FAIL with deviations. |
| E-PROMPT-02 | Hygiene (Refresh + Conform DP) | docs/ops/prompts/e-prompt-02.md | Bundle-first conformance stance. Intake contract uses `ops/bin/bundle --profile=hygiene`; requires `resolved_profile=hygiene` and normalizes rough drafts to canonical DP schema without altering intent. |
| E-PROMPT-03 | Architect (Refresh + Draft DP) | docs/ops/prompts/e-prompt-03.md | Attach-only drafting stance. Requires `resolved_profile=architect`, drafts immediately from PLAN `Architect Handoff` selections only, and forbids introducing new option/phase/slice menus. |
| E-PROMPT-04 | Analyst (Refresh + Discuss) | docs/ops/prompts/e-prompt-04.md | Read-only analysis stance. Intake contract uses `ops/bin/bundle --profile=analyst` plus required query source (`storage/handoff/TOPIC.md` or inline query). Includes PLAN output mode for architect-ready handoff using `ops/src/surfaces/plan.md.tpl`. |
| E-PROMPT-05 | Auditor (Refresh + Authorize Addendum) | docs/ops/prompts/e-prompt-05.md | Addendum authorization stance. Intake contract uses `ops/bin/bundle --profile=auditor --intent="ADDENDUM REQUIRED: ..."`; requires `resolved_profile=auditor` and outputs addendum only (A.1-A.5). Not used for audit verdict workflows. |
| E-PROMPT-06 | Contractor (OPEN + DUMP + ADDENDUM REQUIRED) | docs/ops/prompts/e-prompt-06.md | Addendum artifact-generation stance. Creates and stages decision leaf first, then OPEN intent + core dump + auditor bundle, and returns all proof artifact paths. |
