<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/prune` exists to enforce retention hygiene without destroying proof artifacts required for audit reconstruction. The binary is a safety-critical actor: it must fail closed on policy parse errors, keep critical evidence outside delete eligibility, and preserve deterministic behavior so the same inputs produce the same candidate decisions.

## Mechanics and Sequencing
The binary parses target selection, phase mode (`report` or `apply`), optional dry-run and scrub flags, then loads `ops/lib/manifests/PRUNE.md` before any candidate processing. Policy load is fail-closed: missing required keys or malformed values stop execution.

After policy load, `ops/bin/prune` resolves pointer-first `SoP.md` and `PoW.md` heads to concrete surface leaves and executes `results_guard` before prune operations. The guard inspects tracked handoff RESULTS and CLOSING artifacts and enforces clean staged and unstaged state for those paths before any deletion path executes; untracked runtime handoff files are ignored.

For PoW-prune targets the binary validates candidate pointer triples (`RESULTS`, `OPEN`, `DUMP`) and trackedness. Candidate rows are then tiered (`critical`, `operational`, `historical`) using policy mappings and denylist patterns. Eligible rows are scored deterministically using policy tier weights and age rank.

Execution is two-phase:
- `report` (default): non-mutating output only (`would_remove`, bytes estimate, tier, reason, score).
- `apply`: destructive path enabled only with explicit approval token and clean tracked state.

Budget control uses high and low watermarks (`high_watermark`, `low_watermark`) with hysteresis. Prune selection begins only when observed counts exceed high watermark and stops at low watermark. Optional quarantine mode moves candidates to a quarantine path before final removal. Optional `--scrub` still removes `var/tmp` entries except `.gitkeep`.

## Anecdotal Anchor
The DP-OPS-0074 prune incident exposed the risk of deleting evidence artifacts before certification and commit completion. The DP-OPS-0149 hardening extends this guard posture with policy fail-closed parsing, tiered protection classes, and deterministic two-phase execution.

## Integrity Filter Warnings
`ops/bin/prune` exits on invalid target values, invalid phase values, missing approval token in `apply` mode, policy parse errors, dirty tracked state in destructive mode, dirty tracked RESULTS and CLOSING artifacts, missing or untracked pointer targets in PoW prune candidates, denylist violations, and ledger prune failures. Untracked runtime handoff files do not satisfy evidence continuity by themselves and are ignored by `results_guard`. The command does not infer missing pointer classes or repair malformed ledger entries.
