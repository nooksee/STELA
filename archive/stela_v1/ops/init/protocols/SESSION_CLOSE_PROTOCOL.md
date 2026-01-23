# Session Close Protocol

## Purpose
Define when the session snapshot artifact must be produced for pause or close.

## Scope
Applies to OCL sessions that pause or close, producing a canonical, operator-facing snapshot.

## Triggers (MUST produce a snapshot)
- Operator explicitly says: "pause", "close", "snapshot", or "save this".
- Operator fatigue or interruption is detected or stated.

## Conduct
- Explicitly forbidden: nagging.
- Explicitly forbidden: over-verbosity.
- Use calm terminal status language, e.g.: "Session safely paused. No drift. No loss."

## Operator Control Words
Control words are operator-issued commands; case/formatting is not the point, intent is.

Snapshot triggers (equivalent): "Save this:", "Snapshot". Behavior: produce a Session Snapshot artifact (PAUSE unless operator explicitly says CLOSE) and include next safe actions.

Session lifecycle controls (pause): "pause" / "pause session". Behavior: produce Session Snapshot with Session state = PAUSE and stop advancing work.

Session lifecycle controls (close): "close" / "close session". Behavior: produce Session Snapshot with Session state = CLOSE and stop advancing work.

Session lifecycle controls (resume/open/wake): "resume" / "resume session" / "open session" / "wake". Behavior: do NOT generate a Session Snapshot; do NOT advance repo work automatically; emit a short Resume block:
- Session state = RESUMED.
- Truth precedence reminder: STATE_OF_PLAY.md > Session Snapshot > DP.
- Request operator to paste/attach the latest Session Snapshot OR current DP to rehydrate safely.
- Next safe actions: verify branch, verify gates, confirm active DP/ticket.
- Terminal status: "Session resumed. Same rules. Same spine."

Opine-only control: "no action". Behavior: thoughts only, no DP, no plan, no worker dispatch.

No nanny behavior. Use calm terminal status language, e.g.: "Session safely paused. No drift. No loss."

## Verification
- Not run (operator): confirm trigger coverage and posture.

## Risk+Rollback
- Risk: missed pause/close snapshots reduce resumability.
- Rollback: reinforce triggers and regenerate the snapshot artifact.

## Canon Links
- ops/init/icl/SESSION_SNAPSHOT_OVERVIEW.md
- ops/init/protocols/SNAPSHOT_PROTOCOL.md
- ops/templates/SESSION_SNAPSHOT_TEMPLATE.md
