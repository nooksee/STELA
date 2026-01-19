# Dispatch Packet (DP) — Work Order Template
# This is the canonical template for creating a Dispatch Packet.

DISCUSS-ONLY (optional talk-only cue; paste at top of a message when you want discussion only):
`DISCUSS-ONLY` — discuss/clarify only; no execution or artifacts until a DP (and approval phrase when required).

COPY/PASTE — Dispatch Packet
```
WORK ORDER (DP-XXXX) — Title

Branch (required):
<exact-branch-name>

Rules:
- This is not informational.
- Workers must refuse to proceed if Branch is missing or mismatched.
- Branch must match Freshness Gate branch.
- STOP if current branch is main.
- STOP if current branch does not match the DP required work branch name.
- STOP if the DP omits the required work branch name.
- If any literal `...` appears anywhere in the DP you receive, STOP and request operator fill-in.
- Required blocks must be present: SCOPE (allowed paths), FILES (must edit only these), FORBIDDEN. If missing, STOP.

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
- Reuse-first: before creating anything, check for existing or near-duplicate artifacts; if found, reuse or propose under Supersession / Deletion candidates.
- Duplication check is required before creating new artifacts (near-duplicates included).
- Declare the SSOT file for each touched topic; if unclear, STOP and use the BLOCKED shape.
- No new files unless listed in FILES (must edit only these). If a new file is required, STOP and use the BLOCKED shape.
- "No new files unless listed" applies to tracked repo files only; output artifacts under `storage/handoff/` and `storage/snapshots/` are allowed untracked.
- Do not assume repo layout; follow existing canon (PROJECT_MAP.md, CANONICAL_TREE.md).
- Touch only scoped paths and files listed below.
- Do not modify files inside `upstream/` (read-only donor bank).
- Do not modify files inside `.github/` unless explicitly instructed.
- Any move/rename/delete MUST be accompanied by updated references and a STATE_OF_PLAY entry.
- Add/update STATE_OF_PLAY.md in the SAME PR slice if canon/governance truth docs are impacted.
- Handoff artifacts must be repo-local: use `storage/handoff/` (never `/tmp` or user temp dirs).
- REQUIRED results filename: `storage/handoff/<DP-ID>-RESULTS.md` (basename UPPERCASE; `.md` lowercase).
- Receipt package (minimum handoff artifacts; attachment-mode friendly):
  - `storage/handoff/<DP-ID>-RESULTS.md` (required)
  - Snapshot tarball when required by the DP
  - Snapshot manifest (bundled inside the tarball when `--bundle` is used, or attached alongside when not bundled)
  - OPEN + OPEN-PORCELAIN artifacts are already captured under `storage/handoff/` by OPEN tooling; do not regress this.
- Worker must write the full results message (A/B/C/D + RECEIPT) to the RESULTS file; contents must match the paste-mode results exactly.
- If `storage/handoff/<DP-ID>-RESULTS.md` is not produced, STOP; delivery is incomplete.
- The RESULTS file must NOT include the operator approval line; approval remains its own message.

STOP CONDITIONS — BLOCKED RETURN SHAPE (use when STOP)
Use this exact mini-receipt, then STOP:
~~~text
BLOCKED: yes
MISSING: (file/path/input)
TRIED: (1-3 bullets)
OPTIONS: (A/B with tradeoff)
ASK: (one crisp question)
~~~

SCOPE (allowed paths)
- ...

FILES (must edit only these)
- ...

FORBIDDEN
- ...

OBJECTIVE (what "done" looks like)
...

TASKS
1) ...

REQUIRED VERIFICATION (paste outputs)
- Provide either:
  - RUN: <commands> + results
  - NOT RUN: <reason> + risk
- Include `bash ops/init/tools/context_lint.sh` when ops/docs/canon files are touched.

Risk / Rollback
- Risk: ...
- Rollback: ...

MEMENTO: M-COMMIT-01 (docs/library/MEMENTOS.md)

ACCEPTANCE (IN-LOOP)
Approval phrase (IN-LOOP): APPROVE <DP-ID> EMIT DB-PR-META
DB-PR-META is emitted only after approval (no exceptions).
Operator Handoff Paste Order (IN-LOOP):
1) Approval line (start-of-message, plain text, unquoted): APPROVE <DP-ID> EMIT DB-PR-META
2) Worker results pasted raw (not quoted), after a delimiter (a single blank line or a line containing only `---`)
3) Snapshot file attached (if DP required it)
Operator Handoff Attachment-mode Order (IN-LOOP):
1) Approval line (start-of-message, plain text, unquoted); message contains only the approval line
2) Attach the worker-results text file from `storage/handoff/<DP-ID>-RESULTS.md`; attachment contents must match the paste-mode results exactly, including the RECEIPT (OPEN + SNAPSHOT)
3) Attach the snapshot file (if DP required it)
If the chat UI cannot insert blank lines safely, use the `---` delimiter line before pasting results.
Approval must be the first tokens in the message (start-of-message) and outside OPEN prompt text, OPEN intent, and outside quoted/fenced blocks.
Quoted blocks are commentary and invalid for approval.

REQUIRED OUTPUT BACK TO OPERATOR (in this exact order)
A) SUMMARY + SCOPE CONFIRMATION
- What changed (1-3 bullets)
- Exact paths touched
- SSOT declaration for each touched topic (file path)
- What was NOT changed (if relevant)
B) Supersession / Deletion candidates (proposal-only; no removals)
- If duplicates / near-duplicates / out-of-place artifacts are found, list them here only.
- Include a crisp plan: what is replaced, what replaces it, and where the SSOT lives.
- Do not delete or move anything unless explicitly authorized by the DP.
~~~md
## Supersession / Deletion candidates (proposal-only)
- None.
~~~
C) DB-PR-META (Canonical; DRAFT surfaces only — do not emit)
- Avoid exact-duplicate strings across: Commit message, PR title, Merge commit message. Similar is OK; do not make them identical clones.
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
D) PATCH / DIFF
- Provide a unified diff OR precise file snippets with anchors
- Must be directly review/applyable by operator
E) RECEIPT (mandatory; must be the last section of the result message)
Use the exact headings and order below. DPs missing the RECEIPT are incomplete and must be rejected.
### RECEIPT
### A) OPEN Output
- Full, unmodified output of `./ops/bin/open`
- Must include branch name and HEAD short hash used during work
- If OPEN exceeds message/file limits (edge case), attach the OPEN file from `storage/handoff/` and in this section include the exact path plus the one-line note: "OPEN attached; see path above."
### B) SNAPSHOT Output (paths or archived filenames)
- Choose one based on scope:
  - `./ops/bin/snapshot --scope=icl` (default for doc / ops changes)
  - `./ops/bin/snapshot --scope=full` (required for structural or wide refactors)
- Optional:
  - `--out=auto`
  - `--bundle` (tarball includes payload + manifest)
  - For large `--scope=full` snapshots, prefer `--compress=tar.xz`
- Snapshot may be inline (truncated if necessary) or referenced by generated filename if archived
- Include the manifest path when present (the manifest points to the chat payload file to paste).
- If a tarball is produced, include BOTH: the tarball path and the manifest path.
Do not claim "Freshness unknown" if you can run OPEN yourself.

Deliver results, then STOP (no commit/push).

Final message (mechanical; no extra prose):
- "Wrote RESULTS file: storage/handoff/<DP-ID>-RESULTS.md"
- "OPEN captured: storage/handoff/OPEN-...txt"
- "Porcelain captured: storage/handoff/OPEN-PORCELAIN-...txt"
- "Snapshot: <payload/tarball> + manifest: <manifest>"

```
