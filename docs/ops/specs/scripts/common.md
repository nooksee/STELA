<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/common.sh` exists to enforce PoT.md Section 1.2 SSOT and Drift axioms for shared shell primitives. Without one canonical utility layer, each caller drifts toward local variants for path normalization, fatal-exit text, and telemetry leaf writing, which breaks proof parity and weakens cross-script behavior guarantees.

## Mechanics and Sequencing
1. `die` prints `ERROR:` to stderr and exits with code `1`, which gives every caller one fatal path contract.
2. `trim` strips leading and trailing whitespace with shell parameter expansion and returns a normalized token.
3. `normalize_path_token` trims, removes wrapping quotes or backticks, strips leading `./`, and strips `${REPO_ROOT}/` when present so callers can compare relative paths deterministically.
4. `packet_scope_validate_literal_path` accepts one repository-relative literal path and rejects whitespace, traversal, absolute paths, globs, brace expansion, duplicate separators, trailing separators, and unsupported characters.
5. `packet_scope_parse_declared_path` accepts a bare or backtick-wrapped path plus an optional parenthetical annotation. Free-form trailing prose is rejected.
6. `packet_scope_extract_changelog_paths` reads `3.4.3 Changelog`, accepts canonical inline or grouped mutation declarations, excludes `NO-CHANGE`, rejects duplicates, and emits the exact mutation set.
7. `packet_scope_extract_addendum_paths` verifies `Base Packet`, reads the canonical exact-path block, rejects duplicates, and emits the exact addendum delta.
8. `path_matches_policy_set` evaluates one path against a caller-owned exact set and wildcard list.
9. `packet_scope_path_is_authorized` enforces exact membership in packet mode and permits transparent persistent-policy-only evaluation in maintenance mode.
10. `persistent_policy_path_is_authorized` requires current policy coverage, except that a visible tracked deletion may use committed `HEAD` policy coverage.
11. `rewrite_task_lifecycle_fields` accepts only `ACTIVE/ACTIVE` or `IDLE/COMPLETED`, rewrites the TASK lifecycle header and packet identity atomically into a caller-owned temporary file, and verifies exact field cardinality before returning.
12. Timestamp helpers (`timestamp_token_utc`, `utc_now`) emit UTC stamps for leaf filenames and YAML fields.
13. Hash and slug helpers (`short_hash`, `slugify_token`) derive stable short digests and lowercase filename-safe caller labels.
14. `emit_binary_leaf` resolves repo root, reads the prior head pointer from `logs/<caller>.telemetry.head`, emits a schema-stamped leaf under `logs/`, then rewrites the head pointer to the new leaf path.
15. `emit_binary_leaf` returns success even when `logs/` write steps fail, so telemetry I/O problems do not abort governance commands that invoked the helper.

## Anecdotal Anchor
PoW entry `2026-02-20 04:52:27 UTC — DP-OPS-0079 Distributed Leaf Wiring Completion` records a platform-wide telemetry unification pass that touched shared script plumbing and reran full lint gates. That event reflects the same failure class this file guards against: duplicated helper logic across scripts produced inconsistent evidence leaves and required a central primitive library to restore deterministic behavior.

## Integrity Filter Warnings
- `normalize_path_token` assumes callers define `REPO_ROOT`; if that variable is absent, absolute-prefix stripping does not occur and path comparisons can diverge.
- Packet scope parsers require the canonical `3.4.3` and addendum headings. Historical prose that is not an exact mutation declaration is not accepted as current authority.
- `rewrite_task_lifecycle_fields` rewrites lifecycle headers only. The caller remains responsible for installing or snapshotting the matching DP body.
- `emit_binary_leaf` is explicitly best-effort; leaf write failures are silent by design and must not be treated as transactional durability.
- Head pointer rewrites in `logs/*.telemetry.head` have no file lock, so concurrent writers can race and last-writer wins.
- `short_hash` falls back from `sha256sum` to `shasum` to `cksum`; mixed environments can emit different digests for identical trace input.
