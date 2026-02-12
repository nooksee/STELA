# Technical Specification: ops/bin/prune

## Technical Specifications
- SoP Truncation: keeps the most recent 30 SoP entries and archives older entries to `storage/archives/root/`.
- Archive Naming: writes archive files as `SoP-archive-YYYY-MM.md` based on entry month.
- Handoff Cleanup: removes files in `storage/handoff/` older than 7 days unless they match the current DP ID.
- DP Detection: derives the active DP ID from `TASK.md` when `DP_ID` is not set.
- DP Target Prune: when `--dp=DP-ID` is set, removes matching artifacts from `storage/handoff/` and `storage/dumps/` only.
- Scrub Mode (`--scrub`): resets `TASK.md` to the template baseline by:
  - Resetting the DP header, session anchors, and Freshness Gate anchors.
  - Clearing Scope and Safety and Execution Plan payloads back to template prompts.
  - Preserving Closeout scaffolding and instruction placeholders.
  - Truncating the Work Log to `(No active thread)`.
- Scrub Guardrail: scrub writes staged TASK output to a temp file, runs `bash tools/lint/task.sh <tmp_task_path>`, and only atomically replaces `TASK.md` when lint passes.
- Scrub Idempotency: repeated `--scrub` runs produce byte-identical `TASK.md` output.
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
- `./ops/bin/prune --dp=DP-OPS-XXXX --scrub`

## Forensic Insight
`ops/bin/prune` is the Hygiene Engine. It prevents context window saturation and preserves auditability by managing the SoP archive, handoff retention, and the TASK.md template baseline.
