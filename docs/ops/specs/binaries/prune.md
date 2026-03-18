<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/prune` enforces retention hygiene without destroying proof artifacts required for audit reconstruction. It is safety-critical: policy parse errors fail closed, critical evidence stays outside delete eligibility, and candidate selection remains deterministic.

## Mechanics and Sequencing
The binary parses target selection (`sop`, `pow`, `both`, `storage`, `dump`, or `repo-context`), phase mode (`report` or `apply`), and optional dry-run and scrub flags, then loads:
- `ops/etc/retention.manifest`
- shared dump and repo-pressure classes from `ops/etc/persistence.manifest`

Policy load is fail-closed: missing required keys or malformed values stop execution.

After policy load, `ops/bin/prune` resolves pointer-first `SoP.md` and `PoW.md` heads to concrete surface leaves and executes `results_guard` before destructive operations. The guard inspects tracked current receipt surfaces (`storage/handoff/RESULTS.md`, `storage/handoff/CLOSING.md`) and enforces clean staged and unstaged state for those paths before any deletion path executes.

## Targets
For `--target=storage`, the binary is report-only. It emits weighted rows for exact-pattern runtime artifact classes defined in `ops/etc/retention.manifest` under `## Storage Report Classes`.

For `--target=dump`, the binary emits dump-visible pressure rows using `ops/etc/persistence.manifest` `## Dump Report Classes`.
Each row reports:
- class name
- pattern
- tier
- tier weight
- class weight
- retention class
- matched count
- protected count
- total bytes
- weighted bytes
- top contributing path and bytes

For `--target=repo-context`, the binary emits broader working-tree pressure rows using `ops/etc/persistence.manifest` `## Repo Pressure Classes`.

`--target=dump --phase=apply` remains intentionally narrow. It may act only on classes marked `retention=disposable` and `apply=1` in `ops/etc/persistence.manifest`, and it must still skip anything covered by critical or denylist protections. Canonical dump-visible bulk remains report-only.

## Retention and Budget Control
Execution remains two-phase for ledger targets:
- `report`: non-mutating output only.
- `apply`: destructive path enabled only with explicit approval token and clean tracked state.

Budget control uses high and low watermarks with hysteresis. Selection begins only when observed counts exceed the high watermark and stops at the low watermark. Optional quarantine mode moves candidates to a quarantine path before final removal. Optional `--scrub` still removes `var/tmp` entries except `.gitkeep`.

## Integrity Filter Warnings
`ops/bin/prune` exits on invalid target values, invalid phase values, missing approval token in apply mode, policy parse errors, dirty tracked state in destructive mode, dirty tracked RESULTS and CLOSING artifacts, missing or untracked pointer targets in PoW prune candidates, denylist violations, and prune failures. Storage reporting is observational only. Dump-target apply remains bounded to disposable classes explicitly marked apply-eligible by persistence policy.
