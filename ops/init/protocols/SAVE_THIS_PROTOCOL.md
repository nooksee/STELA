# Save This Protocol

## Purpose
Define the save/retain procedure for critical artifacts.

## Scope
Applies to outputs required for ICL handoff and any session that produces durable process or canon changes.
Trigger: at end of any session resulting in a code change OR canon/process decision.

## What "Save this" is
"Save this" is a continuity capture technique:
- It compresses a lesson into one portable sentence.
- It prevents re-litigating decisions every session.
- It creates an audit trail of how the operating system evolves.

## When to use it
Use "Save this" when the statement is ARC compliant:
- **Atomic**: one rule only
- **Repeatable**: likely true across many sessions
- **Checkable**: you can tell if you complied (yes/no)

Typical frequency:
- Execution sessions: 0
- Ops/process sessions: 1-3
- Discovery sessions: 3-5 (then compress later)

## How to write a good "Save this"
A good canonical sentence:
- names the artifact (Daily Console, PR workflow, etc.)
- uses unambiguous language (must/never/only)
- avoids lore or long explanations
- stands alone without conversation context

Examples:
- Save this: Never push directly to `main`; all changes ship via PRs from `work/<topic>-YYYY-MM-DD` branches.
- Save this: NetBeans is the Truth Console; review diffs there before committing.
- Save this: Any canon change must include a same-PR update to `STATE_OF_PLAY.md`.

## End-of-session prompt
At the end of a session, answer:
1) What did we learn that would prevent a future mistake?
2) Is it still true in 30 days?
3) Can compliance be checked quickly?

If 2 of 3 are yes, write a single Save-this sentence.

## Where saved doctrine should live
Preferred: versioned repo docs (durable, reviewable):
- `ops/` for operating doctrine (protocols, contracts, templates)
- Truth-layer docs for change logging and structure (`STATE_OF_PLAY.md`, `PROJECT_MAP.md`, `CANONICAL_TREE.md`)

Optional: assistant memory as convenience (not the source of truth).

If a rule affects formatting or tooling, also add it to:
- `ops/contracts/OUTPUT_FORMAT_CONTRACT.md`
- ICL Continuity Core (`ops/init/icl/ICL_CONTINUITY_CORE.md`) or legacy onboarding docs in `ops/init/icl/deprecated/`

## Verification
- Not run (operator): confirm save targets.

## Risk+Rollback
- Risk: lost artifacts.
- Rollback: regenerate or re-export outputs.

## Canon Links
- ops/init/manifests/OUTPUT_MANIFEST.md
