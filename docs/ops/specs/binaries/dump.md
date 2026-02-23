<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/dump` exists to produce deterministic repository evidence from tracked state so governance decisions cannot rely on hidden local artifacts. DP-scoped selection extends that role from scope traversal alone to policy-derived context loading: the binary can now assemble a bounded file set from canonical surfaces, active DP load-order declarations, and explicit allowlisted additions, then emit provenance showing exactly what was accepted or rejected and why.

## Mechanics and Sequencing
The binary parses selection, scope, output, compression, bundling, and traversal refiner arguments, validates combinations, enforces repo-root execution, validates required canon files and top-level directories, then resolves files with one of two selection modes:
The documented two-tier usage model is:
- Contractor Dispatch Dump (CDD): a DP-selection dump intended for Contractor visibility, typically `./ops/bin/dump --selection=dp+allowlist --from-dp=auto --format=chatgpt --out=auto`. The DP writer specifies the exact command and any added `--fail-on-forbidden-prefix=...` values.
- Audit Platform Dump (APD): a platform-scope dump used for Integrator and Operator review and for external audit support during closeout.

- `--selection=scope` (scalar, default `scope`): preserves existing behavior and builds files via `ops/lib/scripts/traverse.sh` using `--scope`, `--project`, `--include-dir`, `--exclude-dir`, and `--ignore-file`.
- `--selection=dp` (scalar): bypasses traversal and builds the file set from seven canon baseline files plus DP-scoped load-order files from section `3.2.2` when `--from-dp` is provided.
- `--selection=dp+allowlist` (scalar): same as `dp`, plus explicit additions from `--include-file` and `--include-file-list`.

New selection flags and interactions:
- `--from-dp=PATH|auto` (scalar, default unset): when set, parse DP-scoped load-order files from section `3.2.2`. `auto` resolves the active DP through `TASK.md` (pointer-aware) and uses that packet as the source.
- `--include-file=PATH` (accumulator): adds explicit candidate files; applied only in `dp+allowlist`.
- `--include-file-list=FILE` (accumulator): reads candidate paths line-by-line from each file; blank lines and `#` comment lines are ignored; applied only in `dp+allowlist`.
- `--fail-on-forbidden-prefix=PREFIX` (accumulator): adds extra forbidden candidate path prefixes for DP selection modes.

Forbidden-prefix behavior for `dp` and `dp+allowlist`:
- Default active prefixes are `opt/_factory/` and `storage/handoff/OPEN-`.
- User-provided `--fail-on-forbidden-prefix` values are additive.
- Every candidate path is checked before inclusion; rejected paths are omitted from the selected file set.
For CDD usage, the visibility and security boundary is the DP writer's command choice plus these forbidden-prefix gates; this specification documents the convention but does not change binary enforcement semantics.

For qualifying DP selection runs (`--selection=dp` or `--selection=dp+allowlist`), the manifest appends a machine-readable provenance block:
- `selector_mode`
- `source_dp`
- `files_included_count`
- `files_rejected_count`
- `files_rejected` (list entries with path and rejection reason)

After selection, the binary emits a dump header with branch and hash metadata, writes index entries for selected files, and emits per-file content blocks from `HEAD` state through `git show`. Optional truncation limits are applied per file when `--max-lines` is set. It writes payload and manifest artifacts under `storage/dumps`, optionally packs payload and manifest into a tarball, and prints artifact paths when `--out` is used.

## Anecdotal Anchor
During immutable workflow adoption, one identified risk was that untracked local artifacts could reshape the narrative of what governed a packet execution, and another was oversharing platform context to Contractors when a bounded packet context was sufficient. The CDD/APD split addresses both concerns: CDD defaults toward bounded Contractor visibility, while APD preserves full-platform evidence for closeout and audit support. `ops/bin/dump` reduces those risks by grounding dump payloads in tracked repository state and explicit selection or traversal rules.

## Integrity Filter Warnings
`ops/bin/dump` fails on invalid argument combinations, unknown `--selection` values, missing project target for project scope, non-root invocation, missing required canon surfaces, missing traversal output, missing `tar` when archive output is requested, `--include-file-list` values that point to missing files, and `--from-dp=auto` when no active DP can be resolved from `TASK.md`. By design, untracked local files are not serialized into payload content, so local-only artifacts remain outside the dump unless they are committed.
