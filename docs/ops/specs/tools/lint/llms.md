<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/llms.sh` enforces parity between committed llms bundles and fresh generator output so discovery entry points stay synchronized with runtime manifest state. This gate protects the PoT Section 1.2 SSOT axiom: one authoritative representation per domain, with no stale parallel bundle state.

## Mechanics and Sequencing
1. Resolve repository root and require executable generator `ops/bin/llms`.
2. Require root bundle files `llms.txt`, `llms-core.txt`, and `llms-full.txt`.
3. Fail immediately when deprecated slice files (`llms-small.txt`, `llms-ops.txt`, `llms-governance.txt`) exist.
4. Create temporary output directory, run generator with `--out-dir`, and print generator output.
5. Reject deprecated slice references inside both committed and generated `llms.txt`.
6. Run unified diffs between committed and generated bundle files (`llms-core.txt`, `llms-full.txt`, `llms.txt`).
7. Remove temporary directory in trap cleanup and return non-zero on any mismatch.

## Anecdotal Anchor
The script targets the recurring SSOT-drift class where committed llms bundles lagged manifest changes. In that state, contractor sessions consumed outdated capability and pointer data even though canonical manifests had already changed.
Think of this gate like a checksum handshake that confirms the committed bundles and generated bundles still describe the same system state.

## Integrity Filter Warnings
Generator location is hard-coded to `ops/bin/llms`; relocation without script updates will fail lint. The diff step is byte-sensitive and can fail on ordering or formatting divergence even when semantic content appears equivalent. Temporary directory cleanup depends on trap execution, so forced process termination can leave residual scratch output.
