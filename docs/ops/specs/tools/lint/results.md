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
6. Parse Mandatory Closing Block fields using `ops/bin/certify` as the schema authority, require the current six-label schema, reject placeholder text, and require all six fields to be non-empty.
7. Return non-zero when any certification-format receipt fails required checks.

## Anecdotal Anchor
During the DP-OPS-0069 certification cutover, the absence of a dedicated RESULTS lint path allowed structurally incomplete receipts to pass closeout and created an audit gap that required retroactive correction. This script formalizes that missing gate.

## Integrity Filter Warnings
Mode behavior is intentionally different: explicit path mode applies strict hash parity, while inferred and `--all` modes tolerate historical parity drift and only report skips. Legacy receipts are ignored in broad historical scans unless explicitly targeted. Template hash constants must be revised in lockstep with sanctioned template changes.

## Closing Block Schema Authority
`ops/bin/certify` is the sole authority for accepted Mandatory Closing Block label schemas in certification-format RESULTS receipts. The current closeout label set is SSOT in `ops/lib/manifests/CLOSING.md` (Section 1). `tools/lint/results.sh` must remain synchronized with certify's emitted closing block labels.

The accepted RESULTS closing block schema is the current six-label form defined in `ops/lib/manifests/CLOSING.md` (Section 1): `Primary Commit Header`, `Pull Request Title`, `Pull Request Description`, `Final Squash Stub`, `Commit Message (Extended Description)`, `Review Conversation Starter`.

`tools/lint/results.sh` derives the required label order and per-field non-empty checks from `ops/lib/manifests/CLOSING.md` (Section 1). All six schema fields are required and must be non-empty. Placeholder text is rejected.
