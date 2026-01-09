# Dispatch Packet (DP) — Work Order Template
# This is the canonical template for creating a Dispatch Packet.

COPY/PASTE — Dispatch Packet
```
WORK ORDER (DP-XXXX) — Title

PRESENTATION RULES
- Entire DP block is meant to be copied as a unit.
- DP body stays inside one fence; no partial or nested fences.
- Do not use "COPY EVERYTHING BETWEEN THE LINES" or dashed rulers; the fence is the copy boundary.
- Optional but recommended: add a footer outside the fence after the DP block.

FRESHNESS GATE (REQUIRED)
- Active branch name:
- Current HEAD short hash:
- DP id + date:
- STOP if any mismatch vs operator-provided truth. If all match, proceed immediately to tasks; do not wait for authorization.

BRANCH (operator creates first):
work/<topic>-YYYY-MM-DD

ROLE
You are a Worker (e.g., Junior Implementer, Gemini Reviewer).
You do NOT merge. You do NOT commit. You do NOT push to main.
You produce a working-tree diff only.

NON-NEGOTIABLES
- No direct pushes to `main`. Work only on `work/*` branches.
- Operator creates the branch first. If it exists, do NOT recreate it. If missing, STOP and report.
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

STOP AFTER RESULTS applies only when multiple DPs are queued; it does not gate starting work inside a DP.

```
