# Technical Specification: ops/bin/prune

## Technical Specifications
- SoP Truncation: keeps the most recent 30 SoP entries and archives older entries to `storage/archives/root/`.
- Archive Naming: writes archive files as `SoP-archive-YYYY-MM.md` based on entry month.
- Handoff Cleanup: removes files in `storage/handoff/` older than 7 days unless they match the current DP ID.
- DP Detection: derives the active DP ID from `TASK.md` when `DP_ID` is not set.
- DP Target Prune: when `--dp=DP-ID` is set, removes matching artifacts from `storage/handoff/` and `storage/dumps/` only.
- Uncommitted Results Guard (fatal abort, runs before destructive prune operations):
  - With `--dp=DP-ID`: checks `storage/handoff/DP-ID-RESULTS.md` when it exists.
  - Without `--dp`: checks every `storage/handoff/*-RESULTS.md` that exists.
  - For each candidate, prune aborts if the file is untracked, has unstaged changes, or has staged changes.
  - Fatal message is exact: `SAFETY VIOLATION: Uncommitted Results artifact detected. Commit or stash before pruning.`
- Scrub Mode (`--scrub`): hygiene-only mode that does not rewrite `TASK.md`.
- Reset Task Mode (`--reset-task`): resets `TASK.md` to template baseline.
  - Requires `TASK.md` Work Log to be clear via `ensure_task_work_log_clear`.
  - Stages output in temp, runs `bash tools/lint/task.sh <tmp_task_path>`, and atomically replaces `TASK.md` only if lint passes.
- storage/tmp Hygiene: when `--scrub` is set, removes all files under `storage/tmp` except `.gitignore`.
- Temp Files: uses `storage/tmp` for scrub staging files.

## Requirements
- Must run from the repository root.
- Requires `SoP.md` and `TASK.md` to exist.
- Requires `storage/archives/root/`, `storage/handoff/`, and `storage/tmp/` to be writable.

## Usage
- `./ops/bin/prune`
- `./ops/bin/prune --dp=DP-OPS-XXXX`
- `./ops/bin/prune --scrub`
- `./ops/bin/prune --reset-task`
- `./ops/bin/prune --dp=DP-OPS-XXXX --scrub`
- `./ops/bin/prune --dp=DP-OPS-XXXX --scrub --reset-task`

## Forensic Insight
`ops/bin/prune` is the Hygiene Engine. It prevents context saturation and preserves auditability by managing SoP archive rotation, handoff retention, safety gating for RESULTS artifacts, and explicit TASK baseline reset.
