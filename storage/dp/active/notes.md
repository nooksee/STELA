# Contractor Notes — DP-OPS-0130

## Scope Confirmation
Executed scoped work for DP-OPS-0130 by adding `ops/src/surfaces/decision.md.tpl`,
`ops/bin/decision`, `docs/ops/specs/binaries/decision.md`, and authored
`archives/decisions/DEC-2026-02-27-001-decision-helper-0130.md`.
Updated `storage/dp/active/allowlist.txt`, maintained
`storage/handoff/CLOSING-DP-OPS-0130.md`, and prepared pre-certify single-entry
heads for `SoP.md` and `PoW.md`.
Applied remediation updates to `ops/bin/dump` (working-tree selected content
precedence) and `ops/lib/manifests/CONTRACTOR.md` (CCD band aligned for strict
`./tools/lint/ff.sh` replay).
Updated `ops/bin/allowlist` to honor wildcard allowlist entries during
tracked/untracked checks, which makes compile-leaf wildcard coverage effective in
receipt replay.

## Anomalies Encountered
`ops/bin/dump` previously streamed selected file content from `HEAD`, which caused
dump payload pointer surfaces (`SoP.md`, `PoW.md`, `TASK.md`) to lag working-tree
state on dirty DP branches. The dump binary now prefers working-tree content for
selected files and falls back to `HEAD` only when no working-tree file exists.

## Open Items / Residue
No open anomalies after remediation. Residual untracked compile and surface leaves
remain expected until post-certify prune completes.

## Execution Decision Record
Decision Required: Yes
Decision Pointer: archives/decisions/DEC-2026-02-27-001-decision-helper-0130.md

## Closing Schema Baseline
Current six-label schema baseline assumed (post-0116+A).
