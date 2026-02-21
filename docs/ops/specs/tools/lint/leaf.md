<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/leaf.sh` enforces telemetry wiring on execution-critical scripts so every in-scope binary or lint/test script emits lifecycle leaves. The gate exists because unlogged execution paths break proof reconstruction and violate the PoT proof discipline that requires generated evidence instead of inferred narratives.

## Mechanics and Sequencing
1. Resolve repository root and emit telemetry for the lint script itself.
2. Enumerate tracked `ops/bin/*` files, excluding deprecated `ops/bin/project`.
3. Enumerate tracked shell scripts in `tools/lint/`, `tools/test/`, and `tools/verify.sh`.
4. For each enumerated path, search for the `emit_binary_leaf` token.
5. Record each missing token as a failure and return non-zero when any in-scope executable lacks telemetry wiring.

## Anecdotal Anchor
This gate addresses the class of incidents where execution trace gaps forced operators to correlate logs across sessions by hand to rebuild a failure sequence. Missing leaf emissions extended root-cause timelines because no deterministic start/finish markers existed for the affected script.

## Integrity Filter Warnings
Coverage is path-based and string-match based. A script can evade detection when telemetry is injected indirectly or renamed without the literal `emit_binary_leaf` token. Files outside the enumerated path scope are not checked, so scope expansion requires explicit script updates.
