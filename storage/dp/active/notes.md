# Contractor Notes — DP-OPS-0137

## Scope Confirmation
All in-scope documentation targets updated per §3.4.4 patch specification:

- docs/ops/specs/binaries/dump.md: Factory-Only Audit Recipe and Guardrail Examples subsection
  inserted immediately before ## Anecdotal Anchor heading, within ## Scope Taxonomy section.
- docs/MANUAL.md: Factory-Only Audit Recipe and Guardrail Examples subsection inserted
  immediately after dp+allowlist scope entry and immediately before ### Map (Auto-Generated Index)
  heading, within ### Scope Taxonomy section.
- storage/dp/active/notes.md: Replaced with DP-OPS-0137 notes (this file).
- storage/dp/active/allowlist.txt: Added storage/handoff/CLOSING-DP-OPS-0137.md,
  archives/surfaces/TASK-DP-OPS-0137-*.md, and
  archives/decisions/DEC-2026-02-28-004-audit-deviations-0137.md entries.

Change set is documentation-only. No linters, scripts, guards, or validation binaries were
modified. ops/bin/dump, ops/lib/scripts/traverse.sh, and selection or scope resolution logic
were not touched.

Addendum ADD-OPS-0137-01 received and executed. Operator authorized Option 1: authorize
--scope=platform for DP-OPS-0137 closeout APD, correct SoP/PoW timestamps to match actual
execution timestamps, and make archive surface leaves reviewable via staging before dump.
Decision leaf: archives/decisions/DEC-2026-02-28-004-audit-deviations-0137.md.

## Anomalies Encountered
Three post-certify audit deviations identified by Integrator, resolved via addendum ADD-OPS-0137-01:

Deviation 1 (RESOLVED via addendum): Platform-scope APD dump used in initial closeout without
explicit Operator authorization on record. Operator authorized via ADD-OPS-0137-01 Option 1.

Deviation 2 (RESOLVED via addendum): Archive surface leaves (PoW, SoP, TASK-DP-OPS-0137)
were untracked at initial dump time, absent from content blocks. Resolved by staging surfaces
before rerun dump so dump reads content from disk.

Deviation 3 (RESOLVED via addendum): SoP/PoW ledger timestamps authored as 2026-02-28 01:00:00
UTC; actual execution timestamps from OPEN (stela-20260301T003653Z) and certify
(certify-dp-ops-0137-20260301T033511Z) are 2026-03-01 UTC. Corrected to 2026-03-01 03:35:11 UTC
and certify rerun to regenerate archive leaves with correct timestamps.

Controlled exception: OPEN "Intent for today:" is empty in RESULTS. Certify §3.4.5 replays
./ops/bin/open without --intent=; therefore intent-line gating is not applicable for this
packet. Authorization and controlled exception are carried by the decision leaf (see below).

Decision record (SSOT for authorization and controlled exception):
archives/decisions/DEC-2026-02-28-004-audit-deviations-0137.md

## Open Items / Residue
None.

## Execution Decision Record
Decision Required: Yes
Decision Pointer: archives/decisions/DEC-2026-02-28-004-audit-deviations-0137.md

## Closing Schema Baseline
Assumed the current six-label closing schema (post-0116+A baseline) for this active packet.
