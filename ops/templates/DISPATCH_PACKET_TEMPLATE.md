# Dispatch Packet (DP) — Work Order Template
# This is the canonical template for creating a Dispatch Packet.

```
WORK ORDER (DP-XXXX) — Title

BRANCH (operator creates first):
work/<topic>-YYYY-MM-DD

ROLE
You are a Worker (e.g., Junior Implementer, Gemini Reviewer).
You do NOT merge. You do NOT commit. You do NOT push to main.
You produce a working-tree diff only.

NON-NEGOTIABLES
- No direct pushes to `main`. Work only on `work/*` branches.
- No invention: if repo evidence for a path/file/claim is missing or ambiguous, flag it; do not guess.
- Touch only scoped paths listed below.
- Do not modify files inside `upstream/` (read-only donor bank).
- Do not modify files inside `.github/` unless explicitly instructed.
- Any move/rename/delete MUST be accompanied by updated references and a STATE_OF_PLAY entry.
- Add/update STATE_OF_PLAY.md in the SAME PR slice if canon/governance truth docs are impacted.

SCOPE (allowed paths)
- ...

FORBIDDEN ZONES
- ...

OBJECTIVE (what "done" looks like)
...

TASKS
1) ...

REQUIRED VERIFICATION (paste outputs)
- ...

REQUIRED OUTPUT BACK TO OPERATOR (in this exact order)
A) ...
B) ...
C) Metadata kit surfaces (header prose + fenced blocks): IDE commit subject, PR title + description (markdown), merge commit subject + plaintext body, merge-note comment (markdown).
D) ...

STOP COPYING
```
