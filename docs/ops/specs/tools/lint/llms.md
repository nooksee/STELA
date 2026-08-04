<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/llms.sh` enforces read-only parity between committed llms bundles and fresh generator output so discovery entry points stay synchronized with runtime manifest state. It was reactivated after audit proved that pre-commit generation alone cannot describe the future commit or detect merge-time staleness.

## Mechanics and Sequencing
1. Resolve repository root and require executable generator `ops/bin/llms`.
2. Invoke `ops/bin/llms --check`, which verifies compiled-manifest parity before regenerating the three root bundle expectations in temporary storage.
3. Require byte parity for `llms-core.txt`, `llms-full.txt`, and `llms.txt`.
4. Forward `--test` to the generator contract test and reject every other argument.
5. Emit normal linter telemetry without changing tracked files.

## Anecdotal Anchor
The original parity linter called a generator mode that also rewrote root outputs before comparison, making its apparent proof non-probative. The repaired linter delegates to pure check modes, and GitHub runs it against both the pull-request candidate and merged main.

## Integrity Filter Warnings
Generator location is fixed at `ops/bin/llms`; relocation without synchronized updates fails lint. Comparison is byte-sensitive by design. Forced process termination can leave ignored temporary or telemetry output, but successful and ordinary failed checks remove temporary render storage and change tracked files `0` times.
