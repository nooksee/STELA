# STELA TASK DASHBOARD (LIVING SURFACE)
**Status:** ACTIVE  
**Owner (Integrator):** Not provided  
**Last Updated:** 2026-02-06

> This file is the **single living surface** for the current work thread:
> - **Top:** current Dispatch Packet (DP) intent + constraints
> - **Bottom:** Work Log (timestamped continuity breadcrumbs + single next action)

Canon surface definitions live in `PoT.md`.

---

## 1. Required Context Load (Pre-Flight)
**Rule:** No execution until the worker explicitly confirms these are loaded.

**Must read (always):**
- [ ] `PoT.md` (constitution + jurisdiction)
- [ ] `SoP.md` (merge-grade readiness ledger)
- [ ] `ops/lib/manifests/CONTEXT.md` (required context set)
- [ ] `docs/library/MAP.md` (continuity terrain)

(OPEN is for Integrator/DP Writer state refresh; Worker does not read OPEN).
DISPOSABLE ARTIFACTS (chat logs, etc.) MUST NOT BE REFERENCED OR INCLUDED.

**Job-specific canon (fill in per DP):**
- [ ] `tools/verify.sh`
- [ ] `ops/bin/llms`
- [ ] `ops/bin/prune`

**Loading discipline (worker must echo):**
- “Loaded: PoT, SoP, CONTEXT, MAP (+ job-specific files).”

---

## 2. Active Context (Thread Header)
- **Goal** : Finalize the pointer-first agent constitution by removing legacy metadata, automating llms.txt discovery, and hardening the agent lifecycle against drift.
- **Current DP** : DP-OPS-0031 — Pointer-First Agent Constitution & System Hardening
- **Work Branch (Integrator-assigned OR Integrator-proposed (Operator-created))**: work/agent-constitution-0031
- **Base HEAD (operator-provided)**: 343c3dc95
- **Single Next Action**: Finalize DP-OPS-0031 receipts and operator handoff.
- **Blockers**: None

**Drafting note:** Provisional Work Branch and Base HEAD values are allowed during drafting but must be finalized before worker execution. Workers still stop on any freshness mismatch and do not create or switch branches.

---

## 3. Current Dispatch Packet (DP) - Stela Standard (A-E)
**Formatting rule:** When emitted in chat, the entire DP must be enclosed in a single fenced code block (start to end).
# DP-OPS-[ID]: [TITLE]

## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: [branch]  
Required Work Branch: [branch]  
Base HEAD: [short-hash] (preferred) or `Not provided` / `Current (draft; lock at merge)`

Required local re-check (worker runs; paste results in RESULTS):
- `git rev-parse --abbrev-ref HEAD`
- `git rev-parse HEAD`
- `git status --porcelain`

Worker must already be on the **Required Work Branch** listed above (no branch creation or switching).

STOP if any mismatch.  
STOP if the Required Work Branch is missing.  
STOP if told to create or switch branches.

---

## 3.2 Required Context Load (Read Before Doing Anything)
**Worker must confirm loaded before acting:**
- PoT, SoP, CONTEXT, MAP
- Plus any DP-scoped files listed here:
  - [Exact path]
  - [Exact path]

(OPEN is for Integrator/DP Writer state refresh; Worker does not read OPEN).
DISPOSABLE ARTIFACTS (chat logs, etc.) MUST NOT BE REFERENCED OR INCLUDED.

---

## 3.3 Scope and Safety
- **Objective:** [One sentence goal]

- **Non-Goals (optional, drift-killer):**
  - [What is explicitly NOT being done]
  - [What must NOT expand]

### Target Files allowlist (hard gate)
- [path/to/file1]
- [path/to/file2]

Allowlist rule: exact paths only; use `(new)` prefix only when the DP explicitly allows new files.

- **Conditional Requirements:** If canon/governance surfaces (e.g., TASK.md) are modified, `SoP.md` MUST be included in the allowlist and updated.

- **Stop Condition (scope):** If any required change falls outside the allowlist, **STOP** and report.

- **Forbidden (unless DP explicitly overrides):**
  - No edits to `.github/`
  - No edits to `projects/` unless explicitly authorized
  - No renames/moves/deletes unless explicitly authorized

- **Worker Git Authority (non-negotiable):**
  - Workers do not create/switch branches.
  - Workers do not stage/commit/merge/push.
  - Workers only return diffs/results/receipt.

- **Precedence:** If any conflict exists, **PoT.md wins**. If unclear, STOP and ask.

- **Strict Stop Conditions (generic):**
  - STOP if any placeholder text remains in final outputs (`[ ... ]`, `TODO`, `TBD`, `...`).
  - STOP if required DP inputs are missing (do not guess).
  - STOP if IDs / naming constraints in the DP are inconsistent (when applicable).

---

## 3.4 Execution Plan (A-E Canon)

### 3.4.1 State
- **Context:** [Why we are doing this]
- **Drift:** [What is currently wrong]
- **Desired State:** [What “correct” looks like]

### 3.4.2 Request
**Numbered tasks (concrete, no vibes):**
1) [Do X]
2) [Do Y]
3) [If blocked, STOP and use BLOCKED shape]

**Required Content (optional; use when doc/governance changes demand exact text/format):**
- [Specify required sections/format rules/quality bar as needed]

### 3.4.3 Changelog
- **Log (human-readable, 1–6 bullets):**
  - [What changed]

### 3.4.4 Patch / Diff
- **Format:** Unified diff (preferred) or anchored snippets.

### 3.4.5 Receipt (Required)

#### Verification (MUST RUN; or report NOT RUN + reason + risk)
- `./ops/bin/dump --scope=platform` (or repo-correct equivalent when scope differs)
- If dump refiners are used, include this fallback line in the DP:
  - `Fallback: ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle`
- **Zero-Byte Check:** Verify dump is not empty (`test -s <path>`).
- Context lint (use repo-canonical command):
  - Prefer: `bash tools/lint/context.sh`
  - If not found and required: **STOP** and ask (do not invent a substitute)
- Truth lint (when PoT or canon surfaces touched; use repo-canonical command):
  - Prefer: `bash tools/lint/truth.sh`
  - If not found and required: **STOP** and ask (do not invent a substitute)

#### Skill capture (required during normal DP processing)
- Workflow: run `ops/lib/scripts/skill.sh harvest` to auto-generate a draft with provenance and semantic collision checks.
- Review: inspect the draft in `storage/handoff/` for heuristic accuracy (Hot Zone and High Churn). Refine Invocation guidance and Solution. Do not edit the Provenance block.
- Promote: run `ops/lib/scripts/skill.sh promote <draft_path>` or log "no new skill promoted" with a rationale in RESULTS.
- Legacy capture is forbidden. Do not manually write skill files; the provenance block is required.
- If a DP requires skill capture, the DP Target Files allowlist must include `docs/library/SKILLS.md`.
- Proof required in RESULTS:
  - Harvest-only: command invoked plus draft path and `ls storage/handoff/` output.
  - Promotion: command invoked plus `grep -n "Promotion Packet:" docs/library/SKILLS.md` and `grep -n "docs/library/skills/S-LEARN-" docs/library/INDEX.md`.

#### Artifact bundle (required directory)
- `storage/handoff/`

#### Proof bundle checklist (required; naming pattern over exact names)
- `storage/handoff/DP-OPS--RESULTS.md` (required)
- `storage/handoff/OPEN-PORCELAIN-[work-branch]-[hash].txt` (required)
- `storage/handoff/OPEN-[work-branch]-[hash].txt` (required)
- `storage/dumps/dump-full-...` (or platform scope as applicable)
- `git diff --name-only` (include in RESULTS)
- `git diff --stat` (include in RESULTS)
- `NEXT:` one single action (include in RESULTS)

**MANDATE:** No receipt/proof bundle = **AUTOMATIC DISAPPROVAL**.
Closeout routine receipts not being produced CONSISTENTLY INCLUDING PORCELAIN, DUMP AND OPEN is a failure condition.
Partial receipts (e.g., missing OPEN artifacts when a session was started) are considered failures.

#### REQUIRED OUTPUT
**MUST include a "Status" block at the top of RESULTS:**
- `Scope summary:` (1 sentence validating the loop)
- `Tracked change:` (What was edited)
- `Verification:` (Output of proofs)

#### RESULTS file must include (minimum)
- Verification results (RUN/NOT RUN + reason + risk)
- Patch/diff proof bundle (status/diff list or direct diff)
- Receipt pointers (OPEN + PORCELAIN + DUMP outputs/paths)
- `git diff --name-only` output
- `git diff --stat` output
- `NEXT:` one single action

**Storage artifact flow (local-only, untracked):**
- OPEN and OPEN-PORCELAIN outputs land in `storage/handoff/`.
- Dump bundles land in `storage/dumps/`.
- Results receipts land in `storage/handoff/DP-OPS-0000-RESULTS.md` (pattern).
- Operator stores DP drafts under `storage/dp/intake/` and moves or copies to `storage/dp/processed/` after completion (or when reusing a previously executed DP).
- These are retention paths only; they are not worker prerequisites unless the DP explicitly says so.

---

## 4. Closeout (Mandatory)

### Worker closeout duties (end of session)
- [ ] Produce/Update: `storage/handoff/DP-OPS-[ID]-RESULTS.md`
- [ ] If canon/governance surfaces were changed, include **SoP.md** in scope and update it in the same PR slice.
- [ ] Run `ops/bin/prune` (hygiene).
- [ ] Run `ops/bin/llms` (refresh context bundles).
- [ ] Ensure proof bundle checklist is satisfied (above). (No bundle = DISAPPROVE.)
- [ ] Fill out the Mandatory Closing Block (see below).
- [ ] Append a **TASK Work Log** entry (below) capturing:
  - what changed (high level)
  - gates/verification outcome (pass/fail or not run + reason)
  - blockers (if any)
  - **NEXT:** one single action

### Mandatory Closing Block (Varied Wording Required)
Varied Wording provision: Each entry must use meaningfully distinct wording; copy or minor tense changes are not acceptable. Entry 4 must differ from Entry 1.
1. Primary Commit Header (plaintext)
2. Pull Request Title (plaintext)
3. Pull Request Description (markdown)
4. Final Squash Stub (plaintext) (Must differ from #1)
5. Extended Technical Manifest (plaintext)
6. Review Conversation Starter (markdown)

### Integrator/operator closeout duties
- [ ] Review diff vs DP scope/forbidden zones
- [ ] Run repo-gates / required checks
- [ ] Commit/push/open PR/merge (operator-controlled)

---

## 4.1 Thread Transition (Reset / Archive Rule)
**Purpose:** Prevent TASK from becoming a museum while preserving continuity.

When a DP is **complete** (merged) or **ended** (canceled/superseded):
1) Add a final Work Log entry that starts with: `THREAD END:` and includes:
   - outcome (merged/canceled/superseded)
   - pointer to the DP RESULTS file
   - `NEXT:` the single action (often “start new DP” or “await operator”)
2) Reset sections **2. Active Context** and **3. Current Dispatch Packet** to the next DP.
3) Keep the Work Log, but separate threads with a visible divider line:
   - `---`
   - `THREAD START: DP-OPS-[NEWID]`

(If the Work Log gets too long, it’s acceptable to keep only the most recent thread’s entries here and move older thread logs into the DP RESULTS file—only when explicitly directed.)

---

## 5. Work Log (Timestamped Continuity)
> **NOTICE:** This log is for the *active* DP only. Historical logs are archived in 'storage/archives/'. Do not rely on this log for long-term history.

**Rule:** This is not a transcript. It is the durable breadcrumb trail.  
**Expectation:** Append a new timestamped entry on every DP closeout (no exceptions).  
**Each entry ends with:** `NEXT: <one single action>`.

- *2026-02-06 22:45* — DP-OPS-0030: Governance refactor and context hygiene completed. Verification: RUN (context lint, truth lint, dump, open). Blockers: none. NEXT: deliver RESULTS bundle.
- *2026-02-07 02:24* — DP-OPS-0031: Pointer-first agent constitution, llms discovery automation, and guardrail audit completed. Verification: RUN (context lint, truth lint, dump, llms, agent check). Blockers: none. NEXT: operator review DP-OPS-0031 results.
