<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/src/runbook/execution-decision.yaml` standardizes post-session operator prompts for execution-decision capture. The prompt exists to collect a reproducible model-side account of effective constraints, actions taken, and evidence used, without treating model self-report as constitutional proof of hidden runtime instructions.

## Mechanics and Sequencing
1. The prompt source lives in `ops/src/runbook/execution-decision.yaml`.
2. The prompt first requests a constrained self-report of active operational constraints using four exact labels:
   - `Active operational constraints understood:`
   - `Constraint source visibility:`
   - `Constraint confidence:`
   - `Constraint gaps or unknowns:`
3. The prompt then requests a per-step execution-decision log using exact labels:
   - `Trigger:`
   - `Decision:`
   - `Rationale:`
   - `Tools considered or used:`
   - `Actions taken:`
   - `Actions not taken:`
   - `Key evidence:`
4. Output may be stored as a disposable comparative copy in `storage/dp/intake/<MODEL>-EXECUTION-DECISION.md` or latest-wins disposable target `storage/dp/intake/EXECUTION-DECISION.md` when that ingest path is active.
5. Validation remains response-lint based through `bash tools/lint/response.sh --mode=execution-decision`.
6. Execution-decision output is advisory evidence; unsupported claims are scored as `log-claim-drift` or `log-schema-drift` under active testing policy.

## Anecdotal Anchor
Execution-decision logs became necessary once provider outputs diverged not only in payload quality but in the reasoning they later claimed to have followed. The prompt structure exists to make those mismatches inspectable without requiring hidden prompt disclosure.

## Integrity Filter Warnings
Execution-decision output is not proof of hidden platform/system instructions. Treat operator-visible settings and behavior probes as higher-confidence evidence. If a model cannot disclose exact hidden text, effective constraints and source visibility boundaries are the maximum reliable self-report.
