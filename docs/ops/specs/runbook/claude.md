<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/src/runbook/claude.yaml` defines the reserve Claude adapter for Stela sessions. It exists so Claude-specific runtime corrections can be codified as operator-deployed assets without promoting provider quirks into repo canon.

## Mechanics and Sequencing
1. The adapter source lives in `ops/src/runbook/claude.yaml`.
2. Reserve status means the adapter remains undeployed by default and carries no `instruction_text` while inactive.
3. Activation is manual and conditional: add `instruction_text` only when operator validation shows a Claude-specific platform need.
4. Source proof is operator-visible settings text or screenshot after activation.
5. Functional proof is behavior-based:
   - attachment-first startup from current-turn files,
   - no upload-summary chatter,
   - no follow-on prompt unless a required current-turn artifact is inaccessible.
6. Repo canon remains authoritative over any adapter wording.

## Integrity Filter Warnings
Reserve adapter status is not authorization to treat Claude behavior as permanently provider-specific. Validate before deployment, keep the text narrow, and retire it when the failure mode no longer reproduces.
