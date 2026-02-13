# Technical Specification: ops/bin/prune

## Technical Specifications
- Dual-ledger pruning:
  - `--target=sop` prunes `SoP.md` only (default).
  - `--target=pow` prunes `PoW.md` only.
  - `--target=both` prunes both ledgers in deterministic order (`SoP.md`, then `PoW.md`).
- Entry delimiter: lines matching `^## YYYY-MM-DD HH:MM:SS UTC — DP-...`.
- Retention policy: keep the most recent 30 entries per ledger.
- Archive naming:
  - `SoP.md` overflow is written to `storage/archives/root/SoP-archive-YYYY-MM.md`.
  - `PoW.md` overflow is written to `storage/archives/root/PoW-archive-YYYY-MM.md`.
- Dry-run simulation:
  - `--dry-run` is a no-write simulation mode for destructive paths.
  - Emits deterministic intent lines with cut line, prune count, and archive destination(s).
  - Emits deletion candidates for handoff/dump cleanup and scrub targets without removing files.
- Evidence guards (fatal abort before destructive archive/delete paths):
  - Results guard checks candidate `storage/handoff/*-RESULTS.md` artifacts.
  - Abort conditions: artifact is untracked, unstaged-dirty, or staged-dirty.
  - Fatal message is exact: `SAFETY VIOLATION: Uncommitted Results artifact detected. Commit or stash before pruning.`
- PoW prune guard:
  - For prune-candidate `PoW.md` entries, required schema fields must exist.
  - `RESULTS`, `OPEN`, and `DUMP` pointers must resolve to committed, clean artifacts.
  - Prune aborts if any pointer is missing, malformed, untracked, or dirty.
- Handoff cleanup:
  - Without `--dp`, removes `storage/handoff/` files older than 7 days, except the active DP id.
  - With `--dp=DP-ID`, removes matching artifacts from `storage/handoff/` and `storage/dumps/`.
- TASK reset contract:
  - `--reset-task` extracts the embedded canonical template from `docs/ops/specs/surfaces/task.md`.
  - Extraction delimiters are exact:
    - `<!-- TASK-TEMPLATE-BEGIN -->`
    - `<!-- TASK-TEMPLATE-END -->`
  - Staged template must pass `bash tools/lint/task.sh <tmp_path>` before overwrite.
  - `--dry-run --reset-task` prints intended overwrite action without writing.
- Scrub mode:
  - `--scrub` cleans `storage/tmp/` (excluding `.gitignore`).
  - In `--dry-run`, scrub prints candidates and does not remove anything.

## Requirements
- Must run from a git worktree containing this repository.
- Requires writable `storage/archives/root/`, `storage/handoff/`, `storage/dumps/`, and `storage/tmp/`.
- Requires `SoP.md` and/or `PoW.md` according to `--target`.
- Requires `TASK.md` plus `docs/ops/specs/surfaces/task.md` when `--reset-task` is used.

## Usage
- `./ops/bin/prune`
- `./ops/bin/prune --dry-run`
- `./ops/bin/prune --target=pow --dry-run`
- `./ops/bin/prune --target=both`
- `./ops/bin/prune --dp=DP-OPS-XXXX`
- `./ops/bin/prune --dp=DP-OPS-XXXX --dry-run`
- `./ops/bin/prune --reset-task`
- `./ops/bin/prune --reset-task --dry-run`
- `./ops/bin/prune --dp=DP-OPS-XXXX --scrub`

## Forensic Insight
`ops/bin/prune` is the maintenance safety gate for root ledgers and handoff artifacts. It enforces evidence integrity before destructive actions, supports deterministic dry-run simulation, and keeps TASK reset behavior anchored to the canonical embedded template contract.
