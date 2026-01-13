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

---

## 1. Definition
A DP (Dispatch Packet) is the authoritative, operator-authored work order delivered to a Worker. It defines the objective, scope, constraints, and required outputs so the Worker can execute without guessing.

## 2. Core Governance Rules (Non-Negotiable)
- **Branching:** All work must happen on `work/*` branches, created by the Operator.
- **Branch Creation Rule:** Operator creates the branch first. If it exists, the Worker must not recreate it. If the branch is missing, the Worker must STOP and report.
- **Merge Process:** Merges to `main` happen via Pull Request (PR) only. No direct pushes to `main` are permitted.
- **Verification Gates:** `repo-gates` must be green before any merge.
- **State Ledger:** `STATE_OF_PLAY.md` must be updated within the same PR for any changes to doctrine, governance, or canonical repository structure.
- **PR Metadata:** PR titles and descriptions must be filled out completely.
- **Merge Commit Metadata:** Merge commit messages and extended descriptions must be filled out completely.
- **Post-Merge Note:** A post-merge “Merge note” comment on the PR is required.
- **Queue Rule (Operator-only):** STOP AFTER RESULTS applies only when multiple DPs are queued; workers deliver results and stop.

## 3. Freshness Gate (Required)
Before any work starts, the Worker must echo:
- Active branch name
- Current HEAD short hash
- DP id + date

If the branch or DP id/date mismatches operator-provided truth, the Worker must STOP and report the mismatch. If the operator supplied an expected hash and it mismatches, the Worker must STOP and report the mismatch. If no expected hash was supplied, the Worker notes "hash not verified" and proceeds. If all checks pass, the Worker proceeds immediately to tasks and does not wait for authorization.

## 4. Worker Delivery Protocol (No Commit/Push)
- The Worker must deliver all changes as a working tree diff only. The Worker does not commit, push, or merge.
- The Operator is responsible for reviewing changes, running verification gates, committing, pushing, creating the PR, and merging.
- The Worker stops after delivering results; no extra chatter and no next steps unless asked.
- The Worker must append an After-Action Bundle as the last section of the result message (delivery format, not IN-LOOP permission):
  - A) OPEN output (full block)
  - B) Repo status (`git status --porcelain`)
  - C) Last commit (`git log -1 --oneline`)
  - D) Optional: snapshot pointer used (scope+format+out)
  - The Worker may not claim "Freshness unknown" if they can run OPEN themselves.

## 5. Integrator Review Gate (Required)
Before any commit/push/PR/merge, the Integrator must review and sign off.
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
- **Objective:** A clear, high-level description of what "done" looks like.
- **Scope / Forbidden Zones:** Explicitly allowed and disallowed file paths.
- **Tasks:** A concrete, numbered or bulleted list of tasks to perform.
- **Verification:** Specific commands the worker must run to prove the changes work as intended.
- **Required Output:** The exact format and order of deliverables for the operator (e.g., diff, verification logs), ending with the After-Action Bundle (A/B/C headings required; optional D).

## 7. DP Presentation Rules
- The DP must be delivered as ONE single fenced code block (the DP block) using triple backticks (```).
- The operator must place a prose header outside the fence: "COPY/PASTE — Dispatch Packet".
- The operator may add a prose footer outside the fence after the DP block.
- No partial fences, no nested triple-backtick fences, no leaking content outside the DP block.
- Inside the DP block: do not embed additional triple-backtick fences; use triple-tilde fences (~~~) for internal copy blocks (e.g., markdown fields).
- Do not include copy-boundary marker phrases (e.g., stop-copying markers, copy-between-lines markers) or dashed rulers inside templates.

## 8. Metadata Surface Requirements
Every work cycle that culminates in a PR must generate all required metadata surfaces. The DP must require these surfaces, but the final filled kit is delivered after work results.

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
