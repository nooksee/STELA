# Session Snapshot Overview

## Purpose
Define the session snapshot artifact as an OCL construct for pause and close.

## Scope
Applies to OCL sessions that pause or close, preserving durable memory without relying on chat history.

## Clarifications
- Pause: session is suspended; DP remains active; snapshot enables safe resumption.
- Close: session is terminated; DP lifecycle closes with a snapshot.
- Snapshot is durable memory, not a narrative log.
- Snapshot attaches to the DP ticket lifecycle as the canonical record at pause/close.

## Verification
- Not run (operator): confirm alignment with OCL lifecycle and DP ticket model.

## Risk+Rollback
- Risk: snapshot semantics drift from OCL lifecycle.
- Rollback: revert this overview and restate pause/close requirements.

## Canon Links
- ops/init/icl/OCL_OVERVIEW.md
- ops/init/protocols/SNAPSHOT_PROTOCOL.md
- ops/init/protocols/SESSION_CLOSE_PROTOCOL.md
- ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md
- ops/templates/SESSION_SNAPSHOT_TEMPLATE.md
