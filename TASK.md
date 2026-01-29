# STELA TASK DASHBOARD (LIVING SURFACE)
**Status:** ACTIVE  
**Owner (Integrator):** [Name/Handle]  
**Last Updated:** [YYYY-MM-DD]

> This file is the **single living surface** for the current work thread:
> - **Top:** current Dispatch Packet (DP) intent + constraints
> - **Bottom:** Work Log (timestamped continuity breadcrumbs + single next action)

Canon surface definitions live in `TRUTH.md`.

---

## 0) REQUIRED CONTEXT LOAD (PRE-FLIGHT)
**Rule:** No execution until the worker explicitly confirms these are loaded.

**Must read (always):**
- [ ] `OPEN` (orientation / posture)
- [ ] `TRUTH.md` (precedence + invariants)
- [ ] `AGENTS.md` (jurisdiction / stop-and-ask)
- [ ] `SoP.md` (merge-grade readiness ledger)
- [ ] `ops/lib/manifests/CONTEXT_MANIFEST.md` (required context set)
- [ ] `docs/library/CONTINUITY_MAP.md` (continuity terrain)

**Job-specific canon (fill in per DP):**
- [ ] [path/to/file]
- [ ] [path/to/file]

**Loading discipline (worker must echo):**
- “Loaded: OPEN, TRUTH, AGENTS, SoP, CONTEXT_MANIFEST, CONTINUITY_MAP (+ job-specific files).”

---

## 1) ACTIVE CONTEXT (THREAD HEADER)
- **Goal:** System Consolidation & Truth Enforcement.
- **Constraint:** “My Local is Truth.”
- **Current DP:** DP-OPS-[ID] — [TITLE]
- **Work Branch (Integrator-created):** [EXACT branch name]
- **Base HEAD (operator-provided):** [short-hash or “not provided”]
- **Single Next Action:** [One sentence. No lists.]
- **Blockers:** [None / describe]

---

## 2) CURRENT DISPATCH PACKET (DP) — STELA STANDARD (A–E)
# DP-OPS-[ID]: [TITLE]

## 0. FRESHNESS GATE (MUST PASS BEFORE WORK)
Base Branch: [branch]  
Required Work Branch: [branch]  
Base HEAD: [hash]

Required local re-check (worker runs; paste results in RESULTS):
- `git rev-parse --abbrev-ref HEAD`
- `git rev-parse HEAD`
- `git status --porcelain`

Worker must already be on the **Required Work Branch** listed above (no branch creation or switching).

STOP if any mismatch.  
STOP if the Required Work Branch is missing.  
STOP if told to create or switch branches.

---

## I) REQUIRED CONTEXT LOAD (READ BEFORE DOING ANYTHING)
**Worker must confirm loaded before acting:**
- OPEN, TRUTH, AGENTS, SoP, CONTEXT_MANIFEST, CONTINUITY_MAP
- Plus any DP-scoped files listed here:
  - [Exact path]
  - [Exact path]

Authoring-time artifacts are not worker prerequisites:
- Operator-attached OPEN or dump files used to author a DP must not be listed as required worker inputs.
- Worker generates run-time artifacts for RECEIPT by running `./ops/bin/open` and `./ops/bin/dump`.

---

## II) SCOPE & SAFETY
- **Objective:** [One sentence goal]

- **Non-Goals (optional, drift-killer):**
  - [What is explicitly NOT being done]
  - [What must NOT expand]

### Target Files allowlist (hard gate)
- [path/to/file1]
- [path/to/file2]

Allowlist rule: exact paths only; use `(new)` prefix only when the DP explicitly allows new files.

- **Stop Condition (scope):** If any required change falls outside the allowlist, **STOP** and report.

- **Forbidden (unless DP explicitly overrides):**
  - No edits to `.github/`
  - No edits to `projects/` unless explicitly authorized
  - No renames/moves/deletes unless explicitly authorized

- **Worker Git Authority (non-negotiable):**
  - Workers do not create/switch branches.
  - Workers do not stage/commit/merge/push.
  - Workers only return diffs/results/receipt.

- **Precedence:** If any conflict exists, **TRUTH.md wins**. If unclear, STOP and ask.

- **Strict Stop Conditions (generic):**
  - STOP if any placeholder text remains in final outputs (`[ ... ]`, `TODO`, `TBD`, `...`).
  - STOP if required DP inputs are missing (do not guess).
  - STOP if IDs / naming constraints in the DP are inconsistent (when applicable).

---

## III. EXECUTION PLAN (A–E CANON)

### A) STATE
- **Context:** [Why we are doing this]
- **Drift:** [What is currently wrong]
- **Desired State:** [What “correct” looks like]

### B) REQUEST
**Numbered tasks (concrete, no vibes):**
1) [Do X]
2) [Do Y]
3) [If blocked, STOP and use BLOCKED shape]

**Required Content (optional; use when doc/governance changes demand exact text/format):**
- [Specify required sections/format rules/quality bar as needed]

### C) CHANGELOG
- **Log (human-readable, 1–6 bullets):**
  - [What changed]

### D) PATCH / DIFF
- **Format:** Unified diff (preferred) or anchored snippets.

### E) RECEIPT (REQUIRED)

#### Verification (MUST RUN; or report NOT RUN + reason + risk)
- `./ops/bin/dump --scope=platform` (or repo-correct equivalent when scope differs)
- If dump refiners are used, include this fallback line in the DP:
  - `Fallback: ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle`
- Context lint (use repo-canonical command):
  - Prefer: `bash tools/context_lint.sh`
  - If not found and required: **STOP** and ask (do not invent a substitute)
- Truth lint (when TRUTH/canon surfaces touched; use repo-canonical command):
  - Prefer: `bash tools/lint_truth.sh`
  - If not found and required: **STOP** and ask (do not invent a substitute)

#### Artifact bundle (required directory)
- `storage/handoff/`

#### Proof bundle checklist (required; naming pattern over exact names)
- `storage/handoff/DP-OPS-[ID]-RESULTS.md` (required)
- `storage/handoff/OPEN-[work-branch]-[hash].txt` (when produced)
- `storage/handoff/OPEN-PORCELAIN-[work-branch]-[hash].txt` (when produced)
- `git diff --name-only` (include in RESULTS)
- `git diff --stat` (include in RESULTS)
- `NEXT:` one single action (include in RESULTS)

**No receipt/proof bundle = DISAPPROVE.**

#### RESULTS file must include (minimum)
- Summary + scope confirmation (exact paths touched)
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
- Optional DP drafts may live in `storage/dp/intake/` and move to `storage/dp/processed/`.
- These are retention paths only; they are not worker prerequisites unless the DP explicitly says so.

---

## 3) CLOSEOUT (MANDATORY)

### Worker closeout duties (end of session)
- [ ] Produce/Update: `storage/handoff/DP-OPS-[ID]-RESULTS.md`
- [ ] If canon/governance surfaces were changed, include **SoP.md** in scope and update it in the same PR slice.
- [ ] Ensure proof bundle checklist is satisfied (above). (No bundle = DISAPPROVE.)
- [ ] Append a **TASK Work Log** entry (below) capturing:
  - what changed (high level)
  - gates/verification outcome (pass/fail or not run + reason)
  - blockers (if any)
  - **NEXT:** one single action

### Integrator/operator closeout duties
- [ ] Review diff vs DP scope/forbidden zones
- [ ] Run repo-gates / required checks
- [ ] Commit/push/open PR/merge (operator-controlled)

---

## 3.1) THREAD TRANSITION (RESET / ARCHIVE RULE)
**Purpose:** Prevent TASK from becoming a museum while preserving continuity.

When a DP is **complete** (merged) or **ended** (canceled/superseded):
1) Add a final Work Log entry that starts with: `THREAD END:` and includes:
   - outcome (merged/canceled/superseded)
   - pointer to the DP RESULTS file
   - `NEXT:` the single action (often “start new DP” or “await operator”)
2) Reset sections **1) ACTIVE CONTEXT** and **2) CURRENT DISPATCH PACKET** to the next DP.
3) Keep the Work Log, but separate threads with a visible divider line:
   - `---`
   - `THREAD START: DP-OPS-[NEWID]`

(If the Work Log gets too long, it’s acceptable to keep only the most recent thread’s entries here and move older thread logs into the DP RESULTS file—only when explicitly directed.)

---

## 4) WORK LOG (TIMESTAMPED CONTINUITY)
**Rule:** This is not a transcript. It’s the durable breadcrumb trail.  
**Expectation:** Append a new timestamped entry on every DP closeout (no exceptions).  
**Each entry ends with:** `NEXT: <one single action>`.

- **Example format:** `2026-01-27 14:05 — DP-OPS-0005: Example entry only. Verification: NOT RUN. Blockers: none. NEXT: follow-up.`
- *[YYYY-MM-DD HH:MM]* — DP-OPS-[ID]: [short note]. Verification: [RUN/NOT RUN]. Blockers: [none/...]. NEXT: [single action]
- *[YYYY-MM-DD HH:MM]* — [short note]. Verification: [..]. Blockers: [..]. NEXT: [single action]
- *2026-01-27 14:26* — DP-OPS-0005: Hardened TASK (worker git authority + dump-as-command + Work Log expectation); synced DP lint to TASK headings; added TASK gating in .github; updated SoP. Verification: RUN (dp_lint OK; context_lint warnings). Blockers: none. NEXT: validate end-to-end DP flow with a small "toy DP" and ensure gates behave as intended.

- *2026-01-27 17:20* — DP-OPS-0004: pruned SoP into untracked museum; adjusted context_lint to ignore historical SoP refs. Verification: RUN (context_lint clean; verify_tree 4 issues; lint_truth OK). Blockers: none. NEXT: review DP-OPS-0004 results and confirm closeout.
- *2026-01-29 10:16* — DP-OPS-0006: Added DP sanity check command and dump refiners examples in OPERATOR_MANUAL; tightened AI branch authority in CONTRIBUTING. Verification: RUN (verify_tree 4 warnings; context_lint clean). Blockers: none. NEXT: operator review + commit.
- *2026-01-29 12:05* — DP-OPS-0007: Aligned dp_lint with TASK + removed operator-artifact prerequisite pattern + clarified storage artifact handling. Verification: RUN (tools/dp_lint.sh --test). Blockers: none. NEXT: operator review + commit.
