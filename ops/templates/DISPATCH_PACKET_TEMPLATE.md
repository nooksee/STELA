# Dispatch Packet (DP) — Work Order Template
# This is the canonical template for creating a Dispatch Packet.

COPY/PASTE — Dispatch Packet
```
WORK ORDER (DP-XXXX) — Title

Branch (required):
<exact-branch-name>

Rules:
- This is not informational.
- Workers must refuse to proceed if Branch is missing or mismatched.
- Branch must match Freshness Gate branch.

PRESENTATION RULES
- Entire DP block is meant to be copied as a unit.
- Operator wraps this DP as ONE fenced block when dispatching to a worker.
- DP body stays inside one fence; no partial fences or nested triple-backtick fences.
- Any internal copy blocks must use triple-tilde fences (~~~), never triple backticks.
- The outer fence is the copy boundary.
- Operator MAY add a prose footer outside the fence after the DP block.

FRESHNESS GATE (REQUIRED)
- Active branch name:
- Current HEAD short hash:
- DP id + date:
- If operator supplied an expected hash, STOP on hash mismatch; if not supplied, note "hash not verified" and proceed.
- STOP if branch or DP id/date mismatches operator-provided truth. If all checks pass, proceed immediately to tasks; do not wait for authorization.

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

ACCEPTANCE (IN-LOOP)
Approval phrase (IN-LOOP): APPROVE <DP-ID> EMIT DB-PR-META
DB-PR-META is emitted only after approval (no exceptions).
Operator approval + paste contract (IN-LOOP):
- Approval line must be plain text, unquoted: APPROVE <DP-ID> EMIT DB-PR-META
- Approval line may appear before pasted worker results; canonical order is approval line first.
- Worker results must be pasted raw, unquoted, unedited.
- Snapshot file must be attached in the same message.
- Quoted blocks are commentary and invalid for approval.

REQUIRED OUTPUT BACK TO OPERATOR (in this exact order)
A) ...
B) ...
C) DB-PR-META (Canonical)
(1) IDE "Commit Message" (plain text, one line)
~~~text
[fill: one-line commit subject]
~~~

(2) GitHub PR "Add a title" (plain text, one line)
~~~text
[fill: PR title]
~~~

(3) GitHub PR "Add a description" (markdown)
~~~md
## Purpose
- [fill]

## What changed
- [fill]

## Verification
- [fill]

## Risk / rollback
- [fill]
~~~

(4) GitHub merge dialog "Commit message" (plain text, one line)
~~~text
[fill: merge commit subject]
~~~

(5) GitHub merge dialog "Extended description" (plain text)
~~~text
[fill: merge extended description]
~~~

(6) GitHub merge page "Add a comment" (Merge Comment Block) (markdown)
~~~md
## Merge note
- [fill]
~~~
D) ...
E) After-Action Bundle (append at end of result message; required)
Use the exact headings and order below. DPs missing this bundle are incomplete and must be rejected.
### After-Action Bundle
### A) OPEN Output
- Full, unmodified output of `./ops/bin/open`
- Must include branch name and HEAD short hash used during work
### B) SNAPSHOT Output (worker discretion)
- Choose one based on scope:
  - `./ops/bin/snapshot --scope=icl` (default for doc / ops changes)
  - `./ops/bin/snapshot --scope=full` (required for structural or wide refactors)
- Optional:
  - `--out=auto`
  - `--compress=tar.xz` for large operations
- Snapshot may be inline (truncated if necessary) or referenced by generated filename if archived
Do not claim "Freshness unknown" if you can run OPEN yourself.

Deliver results, then STOP (no commit/push).

```
