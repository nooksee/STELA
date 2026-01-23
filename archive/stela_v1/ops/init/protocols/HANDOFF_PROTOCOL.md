# Handoff Protocol

## Purpose
Define the handoff process from operator to worker or vice versa.

## Scope
Applies to transitions between roles.

## Canonical Handoff Artifacts
- Handoff directory (canonical): `storage/handoff/`
- Results file (canonical): `storage/handoff/<DP-ID>-RESULTS.md`
  - Basename must be UPPERCASE; extension must be `.md` (lowercase).
  - Example: `storage/handoff/DP-OPS-0040-RESULTS.md`
- OPEN capture (repo-local):
  - `storage/handoff/OPEN-<branch>-<YYYY-MM-DD>-<HEAD>.txt`
  - `storage/handoff/OPEN-PORCELAIN-<branch>-<YYYY-MM-DD>-<HEAD>.txt`
- Snapshot artifacts remain under `storage/snapshots/` (payload + manifest; tarball when compressed).

## Ticket Model
A Dispatch Packet (DP) is born at dispatch.

The ticket accretes summaries, decisions, and verification as the session state evolves.

The ticket terminates with a snapshot on close-session.

STATE_OF_PLAY is a parallel canonical ledger, not a projection of tickets.

## Verification
- Not run (operator): confirm handoff steps.

## Risk+Rollback
- Risk: missing handoff context.
- Rollback: re-run handoff with full context.

## Canon Links
- ops/init/icl/INIT_CHECKLIST.md
