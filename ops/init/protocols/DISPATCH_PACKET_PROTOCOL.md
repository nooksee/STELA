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
- **Merge Process:** Merges to `main` happen via Pull Request (PR) only. No direct pushes to `main` are permitted.
- **Verification Gates:** `repo-gates` must be green before any merge.
- **State Ledger:** `STATE_OF_PLAY.md` must be updated within the same PR for any changes to doctrine, governance, or canonical repository structure.
- **PR Metadata:** PR titles and descriptions must be filled out completely.
- **Merge Commit Metadata:** Merge commit messages and extended descriptions must be filled out completely.
- **Post-Merge Note:** A post-merge “Merge note” comment on the PR is required.

## 3. Worker Delivery Protocol (No Commit/Push)
- The Worker must deliver all changes as a working tree diff only. The Worker does not commit, push, or merge.
- The Operator is responsible for reviewing changes, running verification gates, committing, pushing, creating the PR, and merging.

## 4. DP Structure (Required Sections)
A dispatch packet must contain the following sections to be considered valid:
- **Branch:** The exact branch the work will be performed on.
- **Role:** The persona the worker should adopt (e.g., "You are Gemini (Reviewer)").
- **Non-Negotiables:** Core rules the worker must follow.
- **Objective:** A clear, high-level description of what "done" looks like.
- **Scope / Forbidden Zones:** Explicitly allowed and disallowed file paths.
- **Tasks:** A concrete, numbered or bulleted list of tasks to perform.
- **Verification:** Specific commands the worker must run to prove the changes work as intended.
- **Required Output:** The exact format and order of deliverables for the operator (e.g., diff, verification logs).

## 5. DP Delivery Format
- The DP must be delivered inside a fenced code block for copy/paste safety.

## 6. Metadata Surface Requirements
Every work cycle that culminates in a PR must generate all required metadata surfaces. The DP must require these surfaces, but the final filled kit is delivered after work results.
- IDE commit subject line
- PR title
- PR description (markdown)
- Merge commit subject
- Merge commit plaintext body
- Merge-note comment (markdown)

Each metadata surface must be presented as a prose header followed by a fenced code block for copy/paste safety.
