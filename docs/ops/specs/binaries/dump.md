<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/dump` exists to produce deterministic repository evidence from tracked state so governance decisions cannot rely on hidden local artifacts. DP-scoped selection extends that role from scope traversal alone to policy-derived context loading: the binary can now assemble a bounded file set from canonical surfaces, active DP load-order declarations, and explicit allowlisted additions, then emit provenance showing exactly what was accepted or rejected and why.

## Mechanics and Sequencing
The binary parses selection, scope, output, compression, bundling, and traversal refiner arguments, validates combinations, enforces repo-root execution, validates required canon files and top-level directories, then resolves files with one of two selection modes:
The documented two-tier usage model is:
- Contractor Dispatch Dump (CDD): a DP-selection dump intended for Contractor visibility, typically `./ops/bin/dump --selection=dp+allowlist --from-dp=auto --format=chatgpt --out=auto`. The DP writer specifies the exact command and any added `--fail-on-forbidden-prefix=...` values.
- Audit Evidence Dump (APD legacy term): an operator/integrator audit dump from scope selection. Default audit baseline is `--scope=core`; use `--scope=platform` or `--scope=factory` only when expanded context is intentionally required.

## Scope Taxonomy

The following named scopes define traversal boundaries for audit clarity and operator guidance. These definitions are documentary; behavior is implemented in `ops/lib/scripts/traverse.sh` and `ops/bin/dump`.

- `core`: All tracked text content except `projects/` and `opt/_factory/`. Use for standard operator audit dumps where factory content is not under review.
- `platform`: All tracked text content except `projects/`. Keeps `opt/_factory/` visible. Use when factory surfaces are intentionally included in scope.
- `factory`: Only `opt/_factory/`. Use for targeted factory-only inspection. Implemented as a traversal scope value in `ops/lib/scripts/traverse.sh` and `ops/bin/dump`.
- `dp+allowlist` (contractor baseline): Not a traversal scope. Uses `--selection=dp+allowlist` mode. Assembles a bounded file set from canon baseline files, DP-scoped load-order files, and explicit allowlisted additions. Forbidden-prefix behavior (`opt/_factory/`, `storage/handoff/OPEN-`) remains in effect for all contractor-authorized sessions. This is the default contractor context path.

- `--selection=scope` (scalar, default `scope`): preserves traverse-based selection using `--scope`, `--project`, `--include-dir`, `--exclude-dir`, and `--ignore-file`, then applies any explicit `--include-file` / `--include-file-list` additions.
- `--selection=dp` (scalar): bypasses traversal and builds the file set from seven canon baseline files plus DP-scoped load-order files from section `3.2.2` when `--from-dp` is provided.
- `--selection=dp+allowlist` (scalar): same as `dp`, plus explicit additions from `--include-file` and `--include-file-list`.

New selection flags and interactions:
- `--from-dp=PATH|auto` (scalar, default unset): when set, parse DP-scoped load-order files from section `3.2.2`. `auto` resolves the active DP through `TASK.md` (pointer-aware) and uses that packet as the source.
- `--include-file=PATH` (accumulator): adds explicit candidate files; applied in `scope` after traversal and in `dp+allowlist`.
- `--include-file-list=FILE` (accumulator): reads candidate paths line-by-line from each file; blank lines and `#` comment lines are ignored; applied in `scope` after traversal and in `dp+allowlist`.
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

After selection, the binary emits a dump header with branch and hash metadata, writes index entries for selected files, records any explicit include-file / include-file-list refiners, and emits per-file content blocks from `HEAD` state through `git show`. When an explicitly included file exists in the working tree but is not tracked in `HEAD`, the current working-tree content is emitted. Optional truncation limits are applied per file when `--max-lines` is set. It writes payload and manifest artifacts under `storage/dumps`, optionally packs payload and manifest into a tarball, and prints artifact paths when `--out` is used.

### Factory-Only Audit Recipe and Guardrail Examples

Use factory scope only when factory inspection is intentional. Factory scope is never a contractor baseline.

Side-by-side scope examples:
- Contractor baseline (CDD): `./ops/bin/dump --selection=dp+allowlist --from-dp=auto --format=chatgpt --out=auto`
- Core audit (default operator audit baseline): `./ops/bin/dump --scope=core --format=chatgpt --out=auto`
- Factory audit (opt-in): `./ops/bin/dump --scope=factory --format=chatgpt --out=auto`

When to use:
- Use `--scope=factory` only when reviewing `opt/_factory/` content directly.
- Use `--scope=core` for standard operator audits when factory content is not under review.

Do not use:
- Do not use `--scope=platform` or `--scope=factory` for contractor baseline dumps.
- Contractor baseline dumps must use `--selection=dp+allowlist` with forbidden-prefix enforcement.

## Anecdotal Anchor
During immutable workflow adoption, one identified risk was that untracked local artifacts could reshape the narrative of what governed a packet execution, and another was oversharing platform context to Contractors when a bounded packet context was sufficient. The CDD/APD split addresses both concerns: CDD defaults toward bounded Contractor visibility, while APD preserves optional expanded audit evidence only when explicitly required by scope. `ops/bin/dump` reduces those risks by grounding dump payloads in tracked repository state and explicit selection or traversal rules.

## Integrity Filter Warnings
`ops/bin/dump` fails on invalid argument combinations, unknown `--selection` values, missing project target for project scope, non-root invocation, missing required canon surfaces, missing traversal output, missing `tar` when archive output is requested, `--include-file-list` values that point to missing files, and `--from-dp=auto` when no active DP can be resolved from `TASK.md`. By design, untracked local files are not serialized into payload content unless they are explicitly included by caller intent.
