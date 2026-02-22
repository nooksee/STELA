<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/dp.sh` enforces DP transaction immutability so a packet cannot drift from canonical structure, allowlist contract, or closing-block requirements. The gate protects PoT Section 1.2 axioms, especially Drift and SSOT, by proving that a packet is structurally equivalent to the canonical DP template and that declared scope pointers are valid before certification.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and enforce canonical template hash parity for `ops/src/surfaces/dp.md.tpl`.
2. Resolve input mode (`--test`, explicit path, stdin, or default `TASK.md`), including TASK pointer-head resolution and DP block extraction when the source is a TASK surface.
3. Render canonical DP in non-strict mode, normalize both canonical and payload structures, hash both normalized forms, and fail on mismatch.
4. Validate required fields and section blocks, including heading ID/title shape, base branch metadata, scoped load-order content, plan slots, and receipt slot non-placeholder content.
5. Enforce receipt dump-selection scoping in Section 3.4.5: packets `DP-OPS-0095` and newer fail if any `ops/bin/dump` command omits `--selection=dp` or `--selection=dp+allowlist`; older packets emit a grandfathered warning only.
6. Enforce allowlist pointer integrity: exactly one pointer entry, canonical pointer path match, allowlist file existence, entry normalization, runtime-prefix restrictions, wildcard policy constraints, and repository reachability checks.
7. For RESULTS paths, enforce Mandatory Closing Block labels and field constraints, reject placeholders, and require Final Squash Stub divergence from Primary Commit Header.
8. In `--test` mode, execute fixture-driven negative and positive checks that exercise template-hash drift, structure mismatch, allowlist-pointer mismatch, allowlist-file invalidity, and RESULTS closing-block validation.

## Anecdotal Anchor
DP-OPS-0074 exposed an enforcement-model gap where no-argument receipt scanning and explicit certification mode did not share identical hash-parity behavior. That gap allowed a RESULTS artifact to pass without full parity enforcement, and the repair cycle introduced explicit mode-sensitive parity logic plus stricter closing-block checks.

## Integrity Filter Warnings
Template hash constants are hard-coded; any legitimate template change requires synchronized constant updates or lint will fail every packet. Results lint behavior is mode-sensitive by design: explicit path mode enforces strict `Git Hash` parity, while historical scan modes report parity skips without blocking. Dump-selection scope enforcement is grandfathered for packets before `DP-OPS-0095`, so warning-only output on older archived packets is expected until a separate migration rewrites legacy receipt commands. Allowlist validation accepts selected generated-surface wildcard families and closing-sidecar patterns, so policy expansion mistakes in that branch can widen scope unintentionally.
