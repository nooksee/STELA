<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/decision` provides a single deterministic path for decision-record leaves.
It prevents ad hoc filenames and schema drift by generating archive leaves from a
canonical template and a stable naming contract.

## Mechanics and Sequencing
Command form:
~~~bash
./ops/bin/decision create --dp=DP-OPS-XXXX --type=<type> --status=<status> --out=auto
~~~

Supported invocation aliases:
- `./ops/bin/decision create ...`
- `./ops/bin/decision decision create ...`

Create flow:
1. Validate required arguments (`--dp`, `--type`, `--status`, `--out`).
2. Resolve UTC date (`YYYY-MM-DD`) and scan `archives/decisions/` for files matching
   `DEC-YYYY-MM-DD-NNN-<slug>.md`.
3. Select `NNN` as the next available three-digit sequence for that date.
4. Build filename suffix as `slugify(<type>)-<dp_numeric_suffix>`.
5. Set `decision_id` to `DEC-YYYY-MM-DD-NNN` and render
   `ops/src/surfaces/decision.md.tpl` by stripping template metadata frontmatter,
   substituting required slots, and failing if unresolved slot tokens remain.
6. For `--out=auto`, write to
   `archives/decisions/DEC-YYYY-MM-DD-NNN-<slug>.md`.

Rendered decision leaf schema:
- YAML frontmatter fields:
  - `trace_id`
  - `decision_id`
  - `packet_id`
  - `decision_type`
  - `created_at`
  - `authorized_by`
- Required body section order:
  - `## Context`
  - `## Decision`
  - `## Consequence`
  - `## Pointer`
  - `## Status`

## Anecdotal Anchor
DP-OPS-0130 introduced this helper after recurring closeout friction where decision
records were authored manually with inconsistent filename ordering and section
content. The helper converts that manual step into a deterministic archive write.

## Integrity Filter Warnings
The binary fails on unknown flags, invalid `--dp` format, empty slug after
`--type` normalization, missing template, and unresolved slot markers after render.
`--out` must be `auto` or a repo-relative path.
