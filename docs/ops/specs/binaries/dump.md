<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/dump` produces deterministic repository evidence from tracked state so closeout, audit, and operator review work from the same payload. It now separates traversal scope from archive persistence policy: scope decides what tree is traversed; persistence decides how much cold archive body content is carried.

## Mechanics and Sequencing
The binary parses selection, scope, output, compression, bundling, and traversal-refiner arguments, validates combinations, enforces repo-root execution, validates required canon files and top-level directories, and then resolves files with one of two selection families:
- `--selection=scope` (default): traverse by `--scope`, `--project`, `--include-dir`, `--exclude-dir`, and `--ignore-file`, then apply exact-file refiners.
- `--selection=dp` or `--selection=dp+allowlist`: bypass traversal and build the file set from canon baseline files, DP load-order entries, and explicit exact-file additions.

The documented two-tier usage model is:
- Contractor Dispatch Dump (CDD): bounded DP-selection dump, typically `./ops/bin/dump --selection=dp+allowlist --from-dp=auto --format=chatgpt --out=auto`.
- Audit Evidence Dump: scope-based operator dump, typically `./ops/bin/dump --scope=core --format=chatgpt --out=auto`.

## Scope Taxonomy
- `core`: tracked text content except `projects/` and `opt/_factory/`.
- `platform`: tracked text content except `projects/`, including `opt/_factory/`.
- `factory`: only `opt/_factory/`.
- `dp+allowlist`: not a traversal scope; bounded DP selection mode.

## Selection and Persistence Arguments
- `--selection=scope|dp|dp+allowlist`
- `--scope=full|core|platform|factory|project`
- `--from-dp=PATH|auto`
- `--include-file=PATH`
- `--include-file-list=FILE`
- `--fail-on-forbidden-prefix=PREFIX`
- `--persistence-profile=PROFILE`
- Compatibility alias: `--history-profile=PROFILE` remains accepted, but it maps to the same persistence profile machinery.

For DP-selection modes, forbidden prefixes remain additive and fail-closed. Default protected prefixes are `opt/_factory/` and `storage/handoff/OPEN-`.

For qualifying DP runs, the manifest appends selector provenance:
- `selector_mode`
- `source_dp`
- `files_included_count`
- `files_rejected_count`
- `files_rejected`

## Persistence Routing Contract
After selection, the binary resolves a persistence profile from `ops/etc/persistence.manifest`, writes index entries for the selected file set, records explicit include-file refiners, and emits one block per selected file.

Archive classes defined in `ops/etc/persistence.manifest` are serialized by tier:
- recent bodies: full body
- checkpoint bodies: full body
- cold bodies: explicit metadata-only blocks

Active pointer targets for `PoW.md`, `SoP.md`, and `TASK.md` are force-selected when their pointed leaf files exist, including untracked current leaves, so dumps can inspect the live active leaf body rather than only the one-line head pointer.

Metadata-only blocks are explicit. They must state that the full body was omitted, preserve the exact file path, disclose the persistence class and tier, emit a re-include instruction using `--include-file=<path>`, and surface available identity fields such as `trace_id`, `packet_id`, `created_at`, `previous`, or first heading text. Explicit `--include-file` and `--include-file-list` entries override cold-body omission for those exact paths.

Non-persistence-class files still emit full content from tracked state, or from the working tree when explicitly included and untracked.

## Output Contract
The binary writes payload and manifest artifacts under `storage/dumps`, optionally packs payload and manifest into a tarball, and prints artifact paths when `--out` is used. When `--out=<path>` is an explicit non-archive text path, that path becomes the canonical payload path for the run and the manifest is emitted alongside it instead of through shared branch/head names.

## Integrity Filter Warnings
`ops/bin/dump` fails on invalid argument combinations, unknown `--selection` values, unknown persistence profiles, missing project target for project scope, non-root invocation, missing required canon surfaces, missing traversal output, missing `tar` when archive output is requested, `--include-file-list` values that point to missing files, and `--from-dp=auto` when no active DP can be resolved from `TASK.md`. Untracked local files are not serialized unless explicitly included by caller intent.
