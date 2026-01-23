# Output Manifest

## Purpose
Define required outputs for an ICL session.

## Scope
Applies to session outputs and required artifacts.

## Required output types
- DP (Dispatch Packet) is the operator-facing work order format for Workers.
- Session Snapshot is the operator-facing, canonical pause/close state carrier for a session.
- Session Snapshot is required when control words trigger pause/close/snapshot.
- STATE_OF_PLAY.md is the canonical ledger of shipped slices and verification.

## Verification
- Not run (operator): validate output list.

## Risk+Rollback
- Risk: missing outputs.
- Rollback: update output requirements.

## Canon Links
- ops/contracts/OUTPUT_FORMAT_CONTRACT.md
