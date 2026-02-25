<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/results.sh` protects certification receipt integrity so generated RESULTS artifacts cannot be accepted when structurally incomplete, placeholder-filled, or hash-inconsistent. This gate enforces the PoT Section 4.2 Generation Mandate by rejecting manual fabrication patterns and malformed closeout evidence.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and enforce canonical hash parity for `ops/src/surfaces/results.md.tpl`.
2. Resolve lint target mode: explicit path, `--all` scan, active-branch inferred path, or single discovered receipt fallback.
3. For each target file, distinguish certification format from legacy format and skip legacy only in non-explicit historical scan modes.
4. Enforce required heading set and reject unresolved artifact placeholders or forbidden disposable-artifact references.
5. Enforce `Git Hash` parity in explicit mode, and record historical parity skips in inferred/scan modes without blocking.
6. Parse Mandatory Closing Block fields using `ops/bin/certify` as the schema authority, accept either the legacy label schema or the v2 label schema, reject placeholder text, and require non-empty schema-appropriate fields.
7. Return non-zero when any certification-format receipt fails required checks.

## Anecdotal Anchor
During the DP-OPS-0069 certification cutover, the absence of a dedicated RESULTS lint path allowed structurally incomplete receipts to pass closeout and created an audit gap that required retroactive correction. This script formalizes that missing gate.

## Integrity Filter Warnings
Mode behavior is intentionally different: explicit path mode applies strict hash parity, while inferred and `--all` modes tolerate historical parity drift and only report skips. Legacy receipts are ignored in broad historical scans unless explicitly targeted. Template hash constants must be revised in lockstep with sanctioned template changes.

## Closing Block Schema Authority
`ops/bin/certify` is the sole authority for accepted Mandatory Closing Block label schemas in certification-format RESULTS receipts. `tools/lint/results.sh` must remain synchronized with certify's emitted closing block labels.

Supported RESULTS closing block schemas are:
- Legacy labels: `Primary Commit Header (plaintext)`, `Pull Request Title (plaintext)`, `Pull Request Description (markdown)`, `Final Squash Stub (plaintext) (Must differ from #1)`, `Extended Technical Manifest (plaintext)`, `Review Conversation Starter (markdown)`.
- v2 labels: `Primary Commit Header`, `Scope Summary`, `Key Files Touched`, `Notable Risks and Mitigations`, `Follow-ups and Deferred Work`, `Operator Routing Notes`.

Legacy-mode non-empty enforcement remains on the strict/plaintext fields (`Primary Commit Header`, `Pull Request Title`, `Final Squash Stub`, `Extended Technical Manifest`) while markdown fields remain placeholder-checked but not structure-validated by this linter. v2-mode enforcement requires all six v2 fields to be present and non-empty.
