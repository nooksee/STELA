# OCL Overview

## Purpose
Define the Operator Control Layer (OCL) as the session lifecycle superset of ICL.

ICL = initialization. OCL = session lifecycle control (init / execute / pause / close).

Dispatch Packet (DP) is the canonical ticket for OCL sessions. Snapshot is the sole durable memory across sessions.

Assistant posture: silent witness, not nanny.

## Scope
Applies to all operator-led sessions after initialization, including lifecycle control and ticket flow.

## Operational Ethos
Same rules. Same spine.
New session. New life.
No drift. No bullshit.

## Verification
- Not run (operator): validate OCL scope alignment and links.

## Risk+Rollback
- Risk: OCL framing drifts from ICL canon.
- Rollback: revert this overview and restate OCL boundaries.

## Canon Links
- ops/init/icl/ICL_OVERVIEW.md
- ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md
- ops/init/protocols/SNAPSHOT_PROTOCOL.md
- ops/init/protocols/HANDOFF_PROTOCOL.md
