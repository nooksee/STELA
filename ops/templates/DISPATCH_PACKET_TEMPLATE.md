# Dispatch Packet (DP) — Work Order

```
WORK ORDER (DP-XXXX) — Title

BRANCH (operator creates first):
work/<topic>-YYYY-MM-DD

ROLE
You are a Worker (Junior Implementer). You do NOT merge. You do NOT commit. You do NOT push.
You produce a working-tree diff only.

NON-NEGOTIABLES
- No commit / no push.
- No invention: if a path/file is missing or ambiguous, report it; do not guess.
- Touch only scoped paths listed below.
- Add/update STATE_OF_PLAY.md in the SAME PR slice.

SCOPE (allowed paths)
- ...

FORBIDDEN ZONES
- ...

OBJECTIVE
...

TASKS
1) ...

REQUIRED VERIFICATION (paste outputs)
- ...

REQUIRED OUTPUT BACK TO OPERATOR
A) Summary of changes (bullets)
B) Unified diff (git diff)
C) Draft PR Title
D) Draft PR Description (markdown): Purpose / What shipped / Scope / Verification / Risk+Rollback / Canon updates
E) Draft Merge-note comment (markdown, same structure)
F) Confirm: NO COMMIT, NO PUSH performed

REQUIRED METADATA SURFACES
- IDE commit subject line
- PR title
- PR markdown description
- Merge commit subject
- Merge commit extended description
- Merge-note comment

STOP COPYING
```
