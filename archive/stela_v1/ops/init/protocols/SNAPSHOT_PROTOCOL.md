# Snapshot Protocol

## Purpose
Define when to take a session snapshot and how to capture it.

## Scope
Snapshot is the only durable memory across sessions.

Applies at the end of ICL sessions and before handoff. "Save this" and "snapshot" are equivalent operator triggers. Snapshot format is format-agnostic.

## Verification
- Not run (operator): confirm snapshot timing and artifacts.

## Risk+Rollback
- Risk: missing or partial snapshots.
- Rollback: re-run snapshot capture with full context.

## Canon Links
- ops/init/protocols/SAVE_THIS_PROTOCOL.md
- ops/init/protocols/HANDOFF_PROTOCOL.md
