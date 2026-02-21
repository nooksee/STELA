<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/map` exists to keep repository wayfinding synchronized with current topology while preserving human-authored narrative sections. It prevents drift where the auto-generated block in `docs/MAP.md` is overwritten manually or diverges from real directory and project state.

## Mechanics and Sequencing
The binary parses optional `--check`, enforces repo-root execution, validates that `docs/MAP.md` exists and contains exactly one begin and one end sentinel marker, generates a fresh block containing a fixed directory index plus discovered project `STELA.md` entries, and splices that block into `docs/MAP.md` between sentinel lines by using an `awk` rewrite pass to temporary files in `var/tmp`. It compares generated output with current file content. If no change is required it prints up-to-date status. In check mode it exits non-zero when a rewrite would be required. In write mode it replaces `docs/MAP.md` when content differs.

## Anecdotal Anchor
One drift class in MAP maintenance was accidental overwrite or desynchronization of the generated block relative to current repo topology. Sentinel-bounded generation in `ops/bin/map` addresses that class by constraining write scope to the marker block.

## Integrity Filter Warnings
`ops/bin/map` exits on unknown arguments, missing `git`, non-root invocation, missing map file, or invalid sentinel counts. It rewrites only the generated block and does not repair narrative sections outside the marker window.
