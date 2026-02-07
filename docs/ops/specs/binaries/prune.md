# Technical Specification: ops/bin/prune

## Technical Specifications
- SoP Truncation: keeps the most recent 30 SoP entries and archives older entries to `storage/archives/root/`.
- Archive Naming: writes archive files as `SoP-archive-YYYY-MM.md` based on entry month.
- Handoff Cleanup: removes files in `storage/handoff/` older than 7 days unless they match the current DP ID.
- DP Detection: derives the active DP ID from `TASK.md` when `DP_ID` is not set.

## Requirements
- Must run from the repository root.
- Requires `SoP.md` and `TASK.md` to exist.
- Requires `storage/archives/root/` and `storage/handoff/` to be writable.

## Usage
- `./ops/bin/prune`

## Forensic Insight
`ops/bin/prune` is the Hygiene Engine. It prevents context window saturation and preserves auditability by managing the SoP archive and handoff retention.
