<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/src/runbook/gpt.yaml` defines the operator-deployed ChatGPT adapter for Stela sessions. The adapter exists because ChatGPT project instructions can materially affect startup behavior, attachment handling, and output discipline even when repo canon is already correct.

## Mechanics and Sequencing
1. The adapter source lives in `ops/src/runbook/gpt.yaml`.
2. Deployment is manual: the operator pastes `instruction_text` into the active ChatGPT Project instructions surface.
3. Source proof is operator-visible settings text or screenshot.
4. Functional proof is behavior-based:
   - attachment-first startup from current-turn files,
   - no upload-summary chatter,
   - no ask-back fallback when bundle intent is already sufficient,
   - re-upload mentioned only after verified current-turn file-access failure.
5. Model self-report from execution-decision logs is supporting evidence only and is not part of adapter proof.
6. The adapter does not redefine Stela correctness; repo canon, lints, manifests, and receipts remain authoritative.

## Integrity Filter Warnings
The adapter is external runtime code with manual deployment. Presence of the YAML file does not prove deployment. Treat operator-visible settings plus behavior probes as proof; treat execution-decision self-report as corroboration only.
