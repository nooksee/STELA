<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/leaf.sh` enforces telemetry wiring on execution-critical scripts so every in-scope binary or lint/test script emits lifecycle leaves. The gate exists because unlogged execution paths break proof reconstruction and violate the PoT proof discipline that requires generated evidence instead of inferred narratives.

## Mechanics and Sequencing
1. Resolve repository root and emit telemetry for the lint script itself.
2. Enumerate tracked `ops/bin/*` files.
3. Enumerate tracked shell scripts in `tools/lint/`, `tools/test/`, and `tools/verify.sh`.
4. For each enumerated path, search for the `emit_binary_leaf` token.
5. Record each missing token as a failure and return non-zero when any in-scope executable lacks telemetry wiring.
6. When invoked with `--health`, after token-presence checks pass, run
   `./ops/bin/trace health` and reuse its gap-detection output across
   `logs/`. Print findings in `GAP: <condition-type>: <detail>` format. Exit
   non-zero and print `FAIL: health gaps detected` when any finding exists.
   Exit zero and print `OK: health check passed` when no findings exist.
   Unclosed-run detection inherits the `trace health` in-flight grace window so
   active callers are not flagged mid-execution.

## Anecdotal Anchor
This gate addresses the class of incidents where execution trace gaps forced operators to correlate logs across sessions by hand to rebuild a failure sequence. Missing leaf emissions extended root-cause timelines because no deterministic start/finish markers existed for the affected script.

## Integrity Filter Warnings
Coverage is path-based and string-match based. A script can evade detection when telemetry is injected indirectly or renamed without the literal `emit_binary_leaf` token. Files outside the enumerated path scope are not checked, so scope expansion requires explicit script updates.
The `--health` flag does not affect the mandatory default gate. Omitting the
flag leaves existing behavior fully intact. The health checks do not produce
false positives for retro-leaves that have no head file and whose filename
matches the canonical pattern.
