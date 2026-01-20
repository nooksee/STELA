# Dispatch Packet Protocol

## Purpose
Canonize the Dispatch Packet (DP) as the operator-facing Work Order for ICL and other workers. This protocol ensures every work order is governed, traceable, and merge-safe.

## Scope
Applies to all worker assignments that require a formal work order (e.g., ICL, contractors).

## Verification
- Not run (operator): confirm DP requirements and metadata surfaces.

## Risk+Rollback
- Risk: inconsistent work orders or missing metadata.
- Rollback: revert to the previous dispatch format.

## Canon Links
- ops/templates/DISPATCH_PACKET_TEMPLATE.md
- ops/init/manifests/OUTPUT_MANIFEST.md
- ops/contracts/OUTPUT_FORMAT_CONTRACT.md
- ops/init/protocols/OUTPUT_FORMAT_PROTOCOL.md

Reminder: Behavioral preferences are documented in `docs/library/MEMENTOS.md`.

---

## 1. Definition
A DP (Dispatch Packet) is the authoritative, operator-authored work order delivered to a Worker. It defines the objective, scope, constraints, and required outputs so the Worker can execute without guessing.

## 1.1 DISCUSS-ONLY (talk-only cue)
`DISCUSS-ONLY` is a non-gating cue for ideation and alignment. When present, discussion and clarifying questions are allowed, but execution is not requested. Do not run commands, change files, or emit approval-dependent artifacts. Begin work only after the operator removes `DISCUSS-ONLY` and issues a DP (and the approval phrase line when required).

## 2. Core Governance Rules (Non-Negotiable)
- **Branching:** All work must happen on `work/*` branches, created by the Operator.
- **Branch Creation Rule:** Operator creates the branch first. If it exists, the Worker must not recreate it. If the branch is missing, the Worker must STOP and report.
- **Branch Safety:** If the current branch is main, STOP and report. If the DP omits the required work branch name, STOP and report. If the current branch does not match the DP required work branch name, STOP and report.
- **Merge Process:** Merges to `main` happen via Pull Request (PR) only. No direct pushes to `main` are permitted.
- **Verification Gates:** `repo-gates` must be green before any merge.
- **State Ledger:** `STATE_OF_PLAY.md` must be updated within the same PR for any changes to doctrine, governance, or canonical repository structure.
- **PR Metadata:** PR titles and descriptions must be filled out completely.
- **Merge Commit Metadata:** Merge commit messages and extended descriptions must be filled out completely.
- **Post-Merge Note:** A post-merge “Merge note” comment on the PR is required.
- **Queue Rule (Operator-only):** STOP AFTER RESULTS applies only when multiple DPs are queued; workers deliver results and stop.
- **Reuse-first / duplication check:** Before creating anything, workers must check for existing or near-duplicate artifacts. If found, reuse or propose under Supersession / Deletion candidates.
- **SSOT declaration:** When touching an area, the worker must declare the SSOT file for that topic; if unclear, STOP and request input.
- **No new files unless listed:** New files are forbidden unless explicitly listed in the DP FILES block.
- **Output artifacts:** The no-new-files rule applies to tracked repo files only; output artifacts under `storage/handoff/` and `storage/snapshots/` are allowed untracked.
- **Repo-shape neutrality:** Workers must not assume repo layout; use `PROJECT_MAP.md` or `CANONICAL_TREE.md` as the layout SSOT.

## 3. Freshness Gate (Required)
Before any work starts, the Worker must echo:
- Active branch name
- Current HEAD short hash
- DP id + date

STOP if the current branch is main. STOP if the DP omits the required work branch name or if the current branch does not match the DP required work branch name.
If the branch or DP id/date mismatches operator-provided truth, the Worker must STOP and report the mismatch. If the operator supplied an expected hash and it mismatches, the Worker must STOP and report the mismatch. If no expected hash was supplied, the Worker notes "hash not verified" and proceeds. If all checks pass, the Worker proceeds immediately to tasks and does not wait for authorization.

## 4. Worker Delivery Protocol (No Commit/Push)
- The Worker must deliver all changes as a working tree diff only. The Worker does not commit, push, or merge.
- The Operator is responsible for reviewing changes, running verification gates, committing, pushing, creating the PR, and merging.
- The Worker stops after delivering results; no extra chatter and no next steps unless asked.
- Worker results must include a "Supersession / Deletion candidates" callout (proposal-only; no removals).
- If duplicates / near-duplicates / out-of-place artifacts are found, list them only under Supersession / Deletion candidates with a crisp plan (what is replaced, what replaces it, where the SSOT lives).
- Do not delete or move anything unless explicitly authorized by the DP.
- Attachment-mode delivery: Worker results may be delivered as one attached text file; attachment contents must match the paste-mode results exactly, including the RECEIPT (OPEN + SNAPSHOT).
- Handoff artifacts must be repo-local: use `storage/handoff/` (never `/tmp` or user temp dirs).
- REQUIRED results filename (all deliveries): `storage/handoff/<DP-ID>-RESULTS.md` (basename UPPERCASE; `.md` lowercase).
- Receipt package (minimum handoff artifacts; attachment-mode friendly):
  - `storage/handoff/<DP-ID>-RESULTS.md` (required)
  - Snapshot tarball when required by DP
  - Snapshot manifest (bundled inside the tarball when `--bundle` is used, or attached alongside when not bundled)
  - OPEN + OPEN-PORCELAIN artifacts are already captured under `storage/handoff/` by OPEN tooling; do not regress this.
- Worker must write the full results message (A/B/C/D + RECEIPT) to the RESULTS file; contents must match the paste-mode results exactly.
- Minimal proof bundle (required; paste outputs):
  - `git status --porcelain` (must be empty OR explicitly explain why not)
  - `git diff --name-only`
  - `git diff --stat`
  - Verification command outputs required by the DP (paste outputs or NOT RUN + reason)
- The RESULTS file must NOT include the operator approval line; approval remains its own message.
- If `storage/handoff/<DP-ID>-RESULTS.md` is missing, reject the DP results as incomplete.
  - Implementation hint:
    - `cat > storage/handoff/<DP-ID>-RESULTS.md <<'EOF'`
    - `<paste the exact worker results here, including RECEIPT>`
    - `EOF`
- Canonical OPEN capture filenames (repo-local):
  - `storage/handoff/OPEN-<tag>-<branch>-<HEAD>.txt`
  - `storage/handoff/OPEN-PORCELAIN-<tag>-<branch>-<HEAD>.txt`
  - If no tag is provided, omit the `<tag>-` segment.
- The RECEIPT is mandatory and must be appended as the last section of the result message (delivery format, not IN-LOOP permission), using the exact headings and order below:
  - `### RECEIPT`
  - `### A) OPEN Output` (full, unmodified output of `./ops/bin/open`; must include branch name and HEAD short hash used during work)
  - `### B) SNAPSHOT Output` (paths or archived filenames; choose `--scope=icl` for doc/ops changes or `--scope=full` for structural or wide refactors; optional `--out=auto` and `--bundle` (tarball includes payload + manifest); for large `--scope=full` snapshots, prefer `--compress=tar.xz` to keep artifacts attachable; snapshot may be inline, truncated if necessary, or referenced by generated filename if archived)
  - Include the manifest path when present (the manifest points to the chat payload file to paste).
  - If a tarball is produced, include BOTH: the tarball path and the manifest path.
  - DPs missing the RECEIPT are incomplete and must be rejected.
  - The Worker may not claim "Freshness unknown" if they can run OPEN themselves.
  - For attachment-mode: if OPEN exceeds message/file limits, attach the OPEN file from `storage/handoff/` and in `A) OPEN Output` include the exact path plus the one-line note: "OPEN attached; see path above."
- Worker final chat message must be minimal and mechanical:
  - "Wrote RESULTS file: storage/handoff/<DP-ID>-RESULTS.md"
  - "OPEN captured: storage/handoff/OPEN-...txt"
  - "Porcelain captured: storage/handoff/OPEN-PORCELAIN-...txt"
  - "Snapshot: <payload/tarball> + manifest: <manifest>"
- Then STOP.

## 5. Integrator Review Gate (Required)
Before any commit/push/PR/merge, the Integrator must review and sign off.
- Proof-first rule: Approval MUST NOT be granted unless RESULTS include the minimal proof bundle; missing proof is an automatic reject.
- Worker delivers: diff + verification notes + captured HEAD short hash.
- Worker MUST include a `STATE_OF_PLAY.md` update in scope for any PR (including doc-only).
- Integrator checks:
  - scope matches the DP
  - forbidden zones untouched
  - required metadata surfaces present (when applicable)
  - `STATE_OF_PLAY.md` entry exists and is correct
- Only after Integrator signoff does the Operator commit, push, open the PR, or merge.

## 6. DP Structure (Required Sections)
A dispatch packet must contain the following sections to be considered valid:
- **Freshness Gate:** Required echo fields (branch, HEAD short hash, DP id/date) and stop-if-stale instruction.
- **Presentation Rules:** Single fenced DP block with copy-safe header/footer; outer fence uses triple backticks as the single copy boundary; no nested triple-backtick fences; use triple-tilde fences (~~~) for internal copy blocks; no copy-boundary marker phrases inside templates.
- **Queue Rule (Operator-only):** STOP AFTER RESULTS applies only when multiple DPs are queued; workers deliver results and stop.
- **Branch:** The exact branch the work will be performed on.
- **Role:** The persona the worker should adopt (e.g., "You are Gemini (Reviewer)").
- **Non-Negotiables:** Core rules the worker must follow.
- **STOP behavior:** If blocked or missing required inputs, return the BLOCKED mini-receipt shape and stop.
- **Objective:** A clear, high-level description of what "done" looks like.
- **SCOPE (allowed paths):** Explicitly allowed file paths.
- **FILES (must edit only these):** Exact files permitted for edits (no new files unless listed).
- **FORBIDDEN:** Explicitly disallowed file paths.
- **Tasks:** A concrete, numbered or bulleted list of tasks to perform.
- **Verification:** Specific commands the worker must run to prove the changes work as intended.
- **Risk / Rollback:** A concise statement of risk and rollback plan for this DP.
- **Acceptance (IN-LOOP):** Must include the standard approval phrase line: `Approval phrase (IN-LOOP): APPROVE <DP-ID> EMIT DB-PR-META`.
- **Required Output:** The exact format and order of deliverables for the operator (e.g., diff, verification logs), ending with the RECEIPT (A/B headings required).

## 7. DP Presentation Rules
- The DP must be delivered as ONE single fenced code block (the DP block) using triple backticks (```).
- The operator must place a prose header outside the fence: "COPY/PASTE — Dispatch Packet".
- The operator may add a prose footer outside the fence after the DP block.
- No partial fences, no nested triple-backtick fences, no leaking content outside the DP block.
- Inside the DP block: do not embed additional triple-backtick fences; use triple-tilde fences (~~~) for internal copy blocks (e.g., markdown fields).
- Do not include copy-boundary marker phrases (e.g., stop-copying markers, copy-between-lines markers) or dashed rulers inside templates.

## 8. Metadata Surface Requirements
Every work cycle that culminates in a PR must generate all required metadata surfaces. The DP must require these surfaces, but the final filled kit is delivered after work results.
DB-PR-META is emitted only after IN-LOOP approval (no exceptions).

Required surfaces (in this order):
1) IDE "Commit Message" - plain text (single line) in a ~~~text block
2) GitHub PR "Add a title" - plain text (single line) in a ~~~text block
3) GitHub PR "Add a description" - markdown in a ~~~md block
4) GitHub merge dialog "Commit message" - plain text (single line) in a ~~~text block
5) GitHub merge dialog "Extended description" - plain text (multi-line allowed) in a ~~~text block
6) GitHub merge page "Add a comment" (Merge Comment Block) - markdown in a ~~~md block

Formatting rules:
- All metadata surfaces must be delivered as individual fenced sub-blocks using triple-tilde fences.
- Use ~~~text for plain text fields; ~~~md for markdown fields.
- Do not use triple-backticks inside DP content; triple-backticks are reserved for the single outer DP fence.

## 9. Operator Approval + Paste Contract (IN-LOOP)
- Operator approval is an IN-LOOP act.
- Approval phrase must be plain text, unquoted: `APPROVE <DP-ID> EMIT DB-PR-META`.
- Approval must be the first tokens in the message (start-of-message) on a standalone line outside OPEN prompt text, OPEN intent, and outside quoted/fenced blocks.
- If approval and worker results are in the same message, approval must be followed by exactly one delimiter: either a single blank line or a line containing only `---`.
- If the chat UI cannot insert blank lines safely, use the `---` delimiter line before pasting results.
- Operator Handoff Paste Order:
  1) Approval line (start-of-message, standalone; include delimiter if results are in the same message)
  2) Worker results pasted raw (not quoted), immediately after the delimiter
  3) Snapshot file attached (if DP required it)
- Quoted blocks are commentary and invalid for approval. If approval is buried, DB-PR-META is withheld.
