<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/src/runbook/execution-decision.yaml` standardizes post-session operator prompts for execution-decision capture. The prompt exists to collect a reproducible model-side account of effective constraints, actions taken, and evidence used, without treating model self-report as constitutional proof of hidden runtime instructions.

## Mechanics and Sequencing
1. The prompt source lives in `ops/src/runbook/execution-decision.yaml`.
2. The prompt first requests a constrained self-report of active operational constraints using four exact labels:
   - `Active task constraints used:`
   - `Observable evidence used:`
   - `Evidence gaps or unknowns:`
   - `Confidence level:`
3. The prompt then requests a per-step execution-decision log using exact labels:
   - `Trigger:`
   - `Decision:`
   - `Rationale:`
   - `Tools considered or used:`
   - `Actions taken:`
   - `Actions not taken:`
   - `Key evidence:`
4. Validation: `bash tools/lint/response.sh --mode=execution-decision`. The check verifies required constraint-section labels and at least one complete step block are present.
5. Execution-decision output is advisory evidence, subordinate to RESULTS and audit truth.

## Interim Placement Contract
`execution-decision` is disposable/manual-placement evidence for now: useful and explicit, but subordinate to `RESULTS`, `CLOSING`, and audit truth. No execution-decision bundle profile exists yet.

Placement paths (manual; operator places the received fenced markdown):
- `storage/handoff/EXECUTION-DECISION.md`: received fenced markdown from auditor/analyst/draft/other secondary lanes.
- `storage/dp/intake/EXECUTION-DECISION.md`: draft-generated intake variant.

These are latest-wins disposable files. They are not certify inputs and are not audit bundle artifacts. Prune may remove them.

## Anecdotal Anchor
Execution-decision logs became necessary once provider outputs diverged not only in payload quality but in the reasoning they later claimed to have followed. The prompt structure exists to make those mismatches inspectable without requiring hidden prompt disclosure.

## Integrity Filter Warnings
Execution-decision output is not proof of hidden platform/system instructions. Treat operator-visible settings and behavior probes as higher-confidence evidence. If a model cannot disclose exact hidden text, effective constraints and source visibility boundaries are the maximum reliable self-report.
