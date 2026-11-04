<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/src/runbook/claude.yaml` defines the operator-deployed Claude adapter for Stela sessions. It exists so the one Claude-specific startup correction the Operator validated, attachment-first execution from current-turn files, is codified as a deployed asset without promoting provider quirks into repo canon.

## Mechanics and Sequencing
1. The adapter source lives in `ops/src/runbook/claude.yaml`; status is `active` as of version 1.1.0.
2. Deployment is manual: the operator pastes `instruction_text` into the active Claude Project instructions surface.
3. Source proof is operator-visible settings text or screenshot.
4. Functional proof is behavior-based:
   - attachment-first startup from current-turn files,
   - the task inferred from current-turn attachments and thread context,
   - no upload-summary chatter,
   - no follow-on prompt unless a required current-turn artifact is inaccessible.
5. Model self-report from execution-decision logs is supporting evidence only and is not part of adapter proof.
6. Repo canon remains authoritative over any adapter wording.

## Anecdotal Anchor
The adapter was filed as a reserve with no `instruction_text` in DP-OPS-0184 and stayed undeployed through DP-OPS-0266. The Operator activated it on 2026-11-04 (DP-OPS-0267) with a one-line priority directive already in use in the operator's Claude project.

## Integrity Filter Warnings
Presence of the YAML file does not prove deployment. Keep the text narrow and retire it when the startup failure mode no longer reproduces for two consecutive validation rounds.
