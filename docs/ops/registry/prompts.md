<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Prompt Registry

Authoritative registry for operator prompt stances under `docs/ops/prompts/`.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| E-PROMPT-01 | Gatekeeper (Refresh + Audit) | docs/ops/prompts/e-prompt-01.md | Audit stance. Intake contract uses `ops/bin/bundle --profile=audit`; requires receipt and allowlist verification and returns only PASS or FAIL with deviations. |
| E-PROMPT-02 | Hygiene (Refresh + Conform DP) | docs/ops/prompts/e-prompt-02.md | Conformance stance. Rewrites legacy or broken DPs to current TASK schema while preserving original intent and output format constraints. |
| E-PROMPT-03 | Architect (Refresh + Draft DP) | docs/ops/prompts/e-prompt-03.md | Drafting stance. Intake contract uses `ops/bin/bundle --profile=architect` (or auto route); produces new DPs from plan inputs, forbids invented paths, and enforces llms allowlist rule when llms refresh is requested. |
| E-PROMPT-04 | Analyst (Refresh + Discuss) | docs/ops/prompts/e-prompt-04.md | Read-only analysis stance. Intake contract uses `ops/bin/bundle --profile=analyst` (or auto route) plus required query source (`storage/handoff/TOPIC.md` or inline `ANALYZE/SYNTHESIZE/FORMULATE`). Discussion output only, with explicit no-edit and no-command constraints. |
| E-PROMPT-05 | Auditor (Refresh + Authorize Addendum) | docs/ops/prompts/e-prompt-05.md | Addendum authorization stance. Requires OPEN intent with `ADDENDUM REQUIRED`, plus dump payload + manifest; outputs addendum only (A.1-A.5). |
| E-PROMPT-06 | Contractor (OPEN + DUMP + ADDENDUM REQUIRED) | docs/ops/prompts/e-prompt-06.md | Addendum authorization artifact-generation stance. Creates and stages decision leaf first, then OPEN intent + core dump, verifies referenced decision leaf is present in dump payload, and returns artifact paths. |
