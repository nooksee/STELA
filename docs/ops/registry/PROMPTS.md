# Prompt Registry

Authoritative registry for operator prompt stances under `docs/ops/prompts/`.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| E-PROMPT-01 | Gatekeeper (Refresh + Audit) | docs/ops/prompts/E-PROMPT-01.md | Audit stance. Requires receipt and allowlist verification and returns only PASS or FAIL with deviations. |
| E-PROMPT-02 | Hygiene (Refresh + Conform DP) | docs/ops/prompts/E-PROMPT-02.md | Conformance stance. Rewrites legacy or broken DPs to current TASK schema while preserving original intent and output format constraints. |
| E-PROMPT-03 | Architect (Refresh + Draft DP) | docs/ops/prompts/E-PROMPT-03.md | Drafting stance. Produces new DPs from plan inputs, forbids invented paths, and enforces llms allowlist rule when llms refresh is requested. |
| E-PROMPT-04 | Analyst (Refresh + Discuss) | docs/ops/prompts/E-PROMPT-04.md | Read-only analysis stance. Discussion output only, with explicit no-edit and no-command constraints. |
