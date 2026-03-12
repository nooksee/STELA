<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/src/runbook/gemini.yaml` defines the experimental Gemini adapter for Stela sessions. It exists to constrain repeated Gemini-specific startup and output contamination failures without hardcoding those provider quirks into repo enforcement.

## Mechanics and Sequencing
1. The adapter source lives in `ops/src/runbook/gemini.yaml`.
2. Experimental status means the adapter remains undeployed by default and carries no `instruction_text` while inactive.
3. Activation is manual: add `instruction_text` only when operator testing decides Gemini needs external adapter control.
4. Source proof is operator-visible settings text or screenshot after activation.
5. Functional proof is behavior-based:
   - attachment-first startup from current-turn files,
   - no citation-token contamination,
   - no trailing follow-on question,
   - no upload-summary chatter.
6. Experimental status means the adapter is expected to narrow or retire as the provider improves.
7. Repo canon, not adapter text, defines correct architect and audit output.

## Integrity Filter Warnings
Experimental adapter text should target named failure modes only. Do not widen it into general doctrine, and do not treat a clean self-report as proof unless the emitted output and behavior probes also pass.
