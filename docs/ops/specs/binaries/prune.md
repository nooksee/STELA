<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/prune` exists to enforce retention hygiene without destroying proof artifacts required for audit reconstruction. It protects PoT closeout and truth invariants by placing guard checks in front of any deletion path.

## Mechanics and Sequencing
The binary parses target selection, dry-run mode, and optional `--scrub`, resolves pointer-first `SoP.md` and `PoW.md` heads to concrete surface leaves when needed, and executes `results_guard` before prune operations. The guard verifies that handoff RESULTS and CLOSING artifacts are tracked and clean before any deletion path executes. For PoW-prune targets it iterates candidate entries from ledger extraction, validates `RESULTS`, `OPEN`, and `DUMP` pointer presence, and verifies pointer targets are tracked. In dry-run mode it reports candidate activity and optional resume scrub actions without mutating surfaces. In normal mode it invokes ledger prune routines for selected targets with retention threshold thirty and runs optional `var/tmp` scrub that removes all entries except `.gitkeep`.

## Anecdotal Anchor
The DP-OPS-0074 prune incident exposed the risk of deleting evidence artifacts before certification and commit completion. `ops/bin/prune` now puts RESULTS and pointer guards ahead of ledger deletion so evidence removal requires passing proof checks first.

## Integrity Filter Warnings
`ops/bin/prune` exits on invalid target values, missing guard prerequisites, untracked or dirty RESULTS and CLOSING artifacts, missing or untracked pointer targets in PoW prune candidates, and ledger prune failures. The threshold value is fixed in script state and the command does not infer missing pointer classes or repair malformed ledger entries.
