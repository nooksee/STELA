<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/common.sh` exists to enforce PoT.md Section 1.2 SSOT and Drift axioms for shared shell primitives. Without one canonical utility layer, each caller drifts toward local variants for path normalization, fatal-exit text, and telemetry leaf writing, which breaks proof parity and weakens cross-script behavior guarantees.

## Mechanics and Sequencing
1. `die` prints `ERROR:` to stderr and exits with code `1`, which gives every caller one fatal path contract.
2. `trim` strips leading and trailing whitespace with shell parameter expansion and returns a normalized token.
3. `normalize_path_token` trims, removes wrapping quotes or backticks, strips leading `./`, and strips `${REPO_ROOT}/` when present so callers can compare relative paths deterministically.
4. Timestamp helpers (`timestamp_token_utc`, `utc_now`) emit UTC stamps for leaf filenames and YAML fields.
5. Hash and slug helpers (`short_hash`, `slugify_token`) derive stable short digests and lowercase filename-safe caller labels.
6. `emit_binary_leaf` resolves repo root, reads the prior head pointer from `logs/<caller>.telemetry.head`, emits a schema-stamped leaf under `logs/`, then rewrites the head pointer to the new leaf path.
7. `emit_binary_leaf` returns success even when `logs/` write steps fail, so telemetry I/O problems do not abort governance commands that invoked the helper.

## Anecdotal Anchor
PoW entry `2026-02-20 04:52:27 UTC — DP-OPS-0079 Distributed Leaf Wiring Completion` records a platform-wide telemetry unification pass that touched shared script plumbing and reran full lint gates. That event reflects the same failure class this file guards against: duplicated helper logic across scripts produced inconsistent evidence leaves and required a central primitive library to restore deterministic behavior.

## Integrity Filter Warnings
- `normalize_path_token` assumes callers define `REPO_ROOT`; if that variable is absent, absolute-prefix stripping does not occur and path comparisons can diverge.
- `emit_binary_leaf` is explicitly best-effort; leaf write failures are silent by design and must not be treated as transactional durability.
- Head pointer rewrites in `logs/*.telemetry.head` have no file lock, so concurrent writers can race and last-writer wins.
- `short_hash` falls back from `sha256sum` to `shasum` to `cksum`; mixed environments can emit different digests for identical trace input.
