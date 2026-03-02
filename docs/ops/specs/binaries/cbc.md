<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/cbc` surfaces CbC decision registry entries that have remained at
B-score (detection-retained, structural fix queued) for longer than two
quarters without a follow-up DP closing the gap. It provides a deterministic,
reproducible report that an operator can run at any point to identify escalation
candidates. The binary does not block certify; it is an audit surface, not an
enforcement gate. This separation of concerns preserves the principle that
B-scores represent queued improvements, not failures, while still making
long-running queued items visible before they fade from operator awareness.

## Mechanics and Sequencing
Command form:
~~~bash
./ops/bin/cbc [--registry=PATH] [--threshold-months=N] [--as-of=YYYY-MM-DD]
~~~

Supported flags:
- `--registry=PATH` — Path to the decision registry markdown file.
  Default: `docs/ops/registry/decisions.md`.
- `--threshold-months=N` — Positive integer specifying the staleness threshold
  in months. Default: `6` (two quarters).
- `--as-of=STAMP` — Report date for deterministic, receipt-replayable output.
  Accepts YYYY-MM-DD or ISO-8601; only the YYYY-MM-DD prefix is used.
  Default: current UTC date.
- `-h|--help` — Print usage and exit.

Selection logic:
1. Parse the markdown table in the registry file.
2. Select rows whose Score column begins with the letter `B` (catches both
   `B` and compound scores such as `B/C`).
3. For each selected row, read the referenced leaf file under
   `archives/decisions/` and extract `created_at` from YAML frontmatter.
4. Compute the due date as `created_at` date plus `threshold-months`.
5. Compute `days_overdue` as `(as_of - due_date)` in calendar days.
6. Include the entry in the stale list only when `days_overdue > 0`.

Output contract:
- Always emits a markdown report to stdout.
- When stale entries are present, the report includes a summary block and a
  table with columns: Tool, Score, DP, Days Overdue, Leaf.
- When no stale entries are found, the report states the result and includes
  a zero-count summary.
- Exit code is always 0 regardless of stale-entry count.

Telemetry:
- Emits `emit_binary_leaf "cbc" "start"` on invocation.
- Emits `emit_binary_leaf "cbc" "finish"` on EXIT trap.

Temporary files:
- Uses `var/tmp/` for any scratch files required during execution.

## Anecdotal Anchor
DP-OPS-0141 introduced this binary after the CbC decision registry (added in
DP-OPS-0140) was observed to have no automated escalation path for long-lived
B-scored entries. Without a periodic operator-visible signal, B-scored items
risk becoming permanent registry fixtures rather than active improvement queues.
The two-quarter default threshold mirrors the registry's own stated escalation
policy: "B-scored entries sitting without a structural fix DP for more than two
quarters are escalated to Operator attention."

## Integrity Filter Warnings
The binary fails on unknown flags, non-positive `--threshold-months` values,
and missing registry files. Leaf files referenced in the registry that are
absent from the repository are silently skipped (the entry is excluded from
staleness computation). The binary never fails due to registry content issues
such as missing leaf files or malformed rows; it reports what it can and exits
0. Rows with a Score column that does not begin with `B` are silently excluded.
