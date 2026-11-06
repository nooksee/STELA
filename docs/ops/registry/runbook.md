<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Runbook Registry

Authoritative registry for operator-deployed external adapters and diagnostic runbook assets. A bounded question put to any external runtime adapter lands as a consult artifact at `storage/handoff/CONSULT-<adapter>.md` under one schema, `docs/ops/specs/surfaces/consult.md`, validated by `bash tools/lint/response.sh --mode=consult`; the output is advisory, and its disposition is recorded in a RESULTS narrative or an `op` leaf (DP-OPS-0275).

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| RUNBOOK-01 | GPT External Adapter | ops/src/runbook/gpt.yaml | Spec: `docs/ops/specs/runbook/gpt.md`. Active ChatGPT project-instructions adapter for attachment-first, evidence-presenting Stela execution (version 1.1.0, DP-OPS-0267). |
| RUNBOOK-02 | Claude External Adapter | ops/src/runbook/claude.yaml | Spec: `docs/ops/specs/runbook/claude.md`. Active Claude project-instructions adapter for attachment-first Stela execution (activated DP-OPS-0267). |
| RUNBOOK-03 | Gemini Research Adapter | ops/src/runbook/gemini.yaml | Spec: `docs/ops/specs/runbook/gemini.md`. Active Gem-instructions adapter for research synthesis sessions without repository access; advisory output only (reintroduced DP-OPS-0267); consult landing `storage/handoff/CONSULT-gemini.md` (DP-OPS-0275). |
| RUNBOOK-04 | Execution-Decision Diagnostic Prompt | ops/src/runbook/execution-decision.yaml | Spec: `docs/ops/specs/runbook/execution-decision.md`. Operator-entered diagnostic prompt for effective-constraint and decision-log capture. |
