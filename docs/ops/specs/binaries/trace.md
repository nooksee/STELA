<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/trace` is the canonical read-only telemetry explorer for `logs/`.
It replaces repeated ad hoc shell pipelines with stable subcommands so operators
can inspect telemetry consistently and with lower drift risk.

## Mechanics and Sequencing
`ops/bin/trace` command form:
- `ops/bin/trace <subcommand> [args] [--limit=N] [--format=json|md]`

Defaults and options:
- Default output mode is table (tab-separated, single header row).
- `--format=json|md` switches the renderer.
- `--limit=30` is the default for `recent` and `by-caller`.
- `-h` and `--help` are supported at top level and per subcommand.

Subcommands:
- `recent --limit=N`: scans `logs/*.md` for telemetry leaves matching
  `logs/<caller>-<label>-<stamp>-<trace-digest>.md`, sorts by stamp descending,
  and returns the latest N rows. When a leaf body provides `total_duration_seconds`
  or when a `finish` leaf has a matching `start` leaf for the same caller and trace
  digest, the row includes `duration_seconds`.
- `callers`: discovers callers from `logs/*.telemetry.head` and leaf filenames,
  and reports caller plus current head pointer value when present.
- `by-caller <name> --limit=N`: normalizes `<name>` with telemetry slug rules
  (lowercase alphanumeric with hyphens) and returns the latest N rows for that caller
  with the same `duration_seconds` behavior as `recent`.
- `by-trace <trace_id>`: computes the digest with telemetry `short_hash(trace_id)`,
  filters leaves by digest suffix, and validates candidates with YAML
  frontmatter `trace_id` when present.
- `heads`: enumerates `logs/*.telemetry.head` and reports caller plus pointed leaf
  path; empty, missing, or non-existent pointers render as `(unresolved)`.
- `health`: scans `logs/` and reports three classes of gap: unclosed runs (a
  caller whose latest leaf is labeled `start` with no subsequent `finish` leaf
  for the same caller and trace digest, after a short in-flight grace window),
  unresolved heads (a
  `logs/*.telemetry.head` pointer that targets a non-existent leaf), and
  malformed filenames (leaf files whose names do not match the canonical
  `<caller>-<label>-<stamp>-<trace-digest>.md` shape). Prints
  `OK: no health gaps detected` when no gaps are found. Prints one
  `GAP: <condition-type>: <detail>` line per finding when gaps exist. Exits
  zero in all cases; gating is the responsibility of the opt-in `--health`
  mode in `tools/lint/leaf.sh`.

Frontmatter handling:
- The binary reads YAML frontmatter fields (`trace_id`, `caller`, `label`,
  `created_at`, `previous`) when needed.
- Missing or malformed frontmatter is treated as unknown metadata and does not
  fail listing operations.

Output columns:
- `caller`, `label`, `stamp`, `trace_digest`, `duration_seconds`, `path`

CLI examples:
~~~bash
./ops/bin/trace heads
./ops/bin/trace callers
./ops/bin/trace recent --limit=10
./ops/bin/trace by-caller verify --limit=10
./ops/bin/trace by-caller open --limit=10
./ops/bin/trace by-trace stela-20260227T202038Z-6dd41793
./ops/bin/trace health
./ops/bin/trace recent --limit=5 --format=md
./ops/bin/trace recent --limit=5 --format=json
~~~

## Integrity Filter Warnings
`ops/bin/trace` is read-only by contract. It does not write to `logs/`,
`storage/`, or `archives/`, and it does not mutate git state.
The binary fails on unknown subcommands, invalid flags, unsupported formats,
and invalid non-positive limits.
Head-pointer corruption (empty pointer, absolute pointer, missing target) is
handled gracefully with the stable `(unresolved)` placeholder in `heads` output.
`trace health` exits zero regardless of findings. Operators who require a
non-zero exit on gap detection must use `bash tools/lint/leaf.sh --health`.
Best-effort single-leaf writes such as retro-leaves with no corresponding head
file do not produce false positives; a finding is raised only when a head file
exists and its target is missing, or when the latest leaf for a caller remains
`start` after the in-flight grace window.
