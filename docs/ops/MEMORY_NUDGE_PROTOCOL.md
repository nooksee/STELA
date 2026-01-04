# Memory Nudge Protocol (“Save this”) — nukeCE

Purpose: convert fragile conversation learnings into durable, reusable operating doctrine.

This protocol is tool-agnostic: it works for ChatGPT, Gemini, Copilot, and human teams.

---

## What “Save this” is
“Save this” is a **continuity capture** technique:
- It compresses a lesson into one portable sentence.
- It prevents re-litigating decisions every session.
- It creates an audit trail of how the operating system evolves.

---

## When to use it
Use “Save this” when the statement is:

### A.R.C. compliant
- **Atomic**: one rule only
- **Repeatable**: likely true across many sessions
- **Checkable**: you can tell if you complied (yes/no)

Typical frequency:
- Execution sessions: 0
- Ops/process sessions: 1–3
- Discovery sessions: 3–5 (then compress later)

---

## How to write a good “Save this”
A good canonical sentence:
- names the artifact (Daily Cockpit, PR workflow, etc.)
- uses unambiguous language (“must/never/only”)
- avoids lore or long explanations
- stands alone without conversation context

Examples:
- Save this: Never push directly to `main`; all changes ship via PRs from `work/<topic>-YYYY-MM-DD` branches.
- Save this: NetBeans is the Truth Cockpit; review diffs there before committing.
- Save this: Any canon change must include a same-PR update to `STATE_OF_PLAY.md`.

---

## “Canon harvest” end-of-session prompt
At the end of a session, answer:
1) What did we learn that would prevent a future mistake?
2) Is it still true in 30 days?
3) Can compliance be checked quickly?

If 2 of 3 are “yes,” write a single Save-this sentence.

---

## Where saved doctrine should live
Preferred: versioned repo docs (durable, reviewable):
- `docs/ops/` for operating doctrine
- `STATE_OF_PLAY.md` for change logging when canon shifts

Optional: assistant memory as convenience (not the source of truth).

---

## NOTE: Copy/paste payload discipline
If a “Save this” rule affects formatting or tooling, also add it to:
- `docs/ops/OUTPUT_FORMAT_CONTRACT.md` (if applicable)
- relevant onboarding docs (Copilot/Gemini) so guests inherit the rule

