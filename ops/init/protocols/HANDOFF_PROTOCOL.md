# Handoff Protocol

## Purpose
Define the handoff process from operator to worker or vice versa.

## Scope
Applies to transitions between roles.

## Ticket Model
A Dispatch Packet (DP) is born at dispatch.

The ticket accretes summaries, decisions, and verification.

The ticket terminates with a snapshot on close-session.

## Verification
- Not run (operator): confirm handoff steps.

## Risk+Rollback
- Risk: missing handoff context.
- Rollback: re-run handoff with full context.

## Canon Links
- ops/init/icl/INIT_CHECKLIST.md
