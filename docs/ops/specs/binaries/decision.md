<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/decision` provides a single deterministic path for decision-record leaves.
It prevents ad hoc filenames and schema drift by generating archive leaves from
canonical taxonomy templates and a stable naming contract. New leaves receive
`RoR-` prefixed IDs and filenames. On every successful write, `RoR.md` is updated
to point at the newly written leaf so the Record of Record pointer head is always
current.

## Mechanics and Sequencing
Command form:
~~~bash
./ops/bin/decision create --dp=DP-OPS-XXXX --type=exec|cbc|op --status=<status> --out=auto
~~~

Supported invocation aliases:
- `./ops/bin/decision create ...`
- `./ops/bin/decision decision create ...`

Decision types (taxonomy):
- `exec` — Execution decision. Default type. General-purpose record for execution choices
  and rationale. Template: `ops/src/decisions/exec.md.tpl`.
- `cbc` — CbC Design Discipline Preflight record. Required when the CbC preflight is
  applicable and `tools/lint/integrity.sh` would otherwise fail. Template:
  `ops/src/decisions/cbc.md.tpl`.
- `op` — Operator authorization record. Used for scope expansions, exceptions, and
  out-of-band operator approvals. Template: `ops/src/decisions/op.md.tpl`.

Legacy compatibility:
- Non-taxonomy `--type` values (values other than `exec`, `cbc`, `op`) are accepted and
  routed to the `exec` template. The type value is slugified and used in the output
  filename suffix. This preserves backward compatibility with older invocations.

Create flow:
1. Validate required arguments (`--dp`, `--type`, `--status`, `--out`).
2. Resolve UTC date (`YYYY-MM-DD`) and scan `archives/decisions/` for files matching
   `RoR-YYYY-MM-DD-NNN-<slug>.md`
   (new) to compute the next available three-digit sequence for that date.
3. Set `decision_id` to `RoR-YYYY-MM-DD-NNN`.
4. For taxonomy types, build filename suffix as `<type>-<dp_numeric_suffix>`.
   For legacy types, build filename suffix as `slugify(<type>)-<dp_numeric_suffix>`.
5. Select the template from `ops/src/decisions/<type>.md.tpl` for taxonomy types,
   or fall back to `ops/src/decisions/dec.md.tpl` for legacy types.
6. Strip template metadata frontmatter, substitute required slots, and fail hard
   if unresolved slot tokens remain.
7. For `--out=auto`, write to
   `archives/decisions/RoR-YYYY-MM-DD-NNN-<slug>.md`.
8. For explicit `--out` paths, reject any path outside `archives/decisions/`.
9. Write `RoR.md` to contain the repo-relative path of the newly written leaf.

Leaf naming contract:
- New leaves: `archives/decisions/RoR-YYYY-MM-DD-NNN-<type>-<dp_suffix>.md`
- Decision ID in frontmatter: `RoR-YYYY-MM-DD-NNN`
- Example: `archives/decisions/RoR-2026-03-01-001-exec-0139.md`

RoR.md update:
After each successful `create` invocation, `RoR.md` is overwritten with a single line
containing the repo-relative path of the written leaf. This keeps the Record of Record
pointer head current without requiring manual edits.

Rendered decision leaf schema (exec type):
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

Rendered decision leaf schema (cbc type):
- YAML frontmatter fields: same as exec type.
- Required body sections:
  - `## Context` (includes tool path under review)
  - `## CbC Preflight Questions` (Q1-Q5 with placeholder answers on initial write)
  - `## Decision` (verdict)
  - `## Consequence`
  - `## Pointer`
  - `## Status`

Rendered decision leaf schema (op type):
- YAML frontmatter fields: same as exec type.
- Required body sections:
  - `## Context` (includes request context)
  - `## Decision` (scope boundary and approval text)
  - `## Consequence`
  - `## Pointer`
  - `## Status`

## Anecdotal Anchor
DP-OPS-0130 introduced this helper after recurring closeout friction where decision
records were authored manually with inconsistent filename ordering and section
content. DP-OPS-0139 extended the helper to support the RoR-D2 decision taxonomy
(`exec`, `cbc`, `op`), RoR-prefixed leaf naming, and automatic RoR.md pointer
updates on every successful leaf write.

## Integrity Filter Warnings
The binary fails on unknown flags, invalid `--dp` format, empty slug after
`--type` normalization, missing template, unresolved slot markers after render, and
`--out` paths outside `archives/decisions/`. `--out` must be `auto` or a repo-relative
path under `archives/decisions/`. Legacy non-taxonomy types are silently routed to
the `exec` template; no warning is emitted.
