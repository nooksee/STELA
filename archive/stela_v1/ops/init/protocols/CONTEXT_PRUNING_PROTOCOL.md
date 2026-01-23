# Context Pruning Protocol

## Purpose
Prevent lost-in-the-middle decay during long sessions by pruning safely.

## Scope
Applies when sessions are long, context pressure is high, or the thread feels unfocused.

## Verification
- Not run (operator): confirm pruning rules align with current ICL doctrine.

## Risk+Rollback
- Risk: accidental removal of required context.
- Rollback: re-run ICL with full canon artifacts.

## Canon Links
- ops/init/protocols/SAVE_THIS_PROTOCOL.md
- ops/init/manifests/CONTEXT_MANIFEST.md

## Triggers (when to prune)
- Long sessions with multiple context shifts.
- Approaching token limits or reduced model performance.
- When the operator reports confusion or context drift.

## Never prune
- Contracts and manifests.
- Active scope and explicit operator instructions.
- The most recent STATE_OF_PLAY updates referenced in this session.

## Compression Summary (required format)
- Purpose (1 line)
- Decisions (bullets)
- Files/paths touched (bullets)
- Verification status (bullets)
- Open risks or follow-ups (bullets)

## Where summaries live
- Prefer a Save This snapshot.
- If inline, place the summary block at the end of the session transcript.
