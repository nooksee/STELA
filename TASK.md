# STELA TASK DASHBOARD
**Status:** ACTIVE
**Operator:** Kevin Atwood (nooksee)

## 1. ACTIVE CONTEXT
* **Goal:** System Consolidation & Truth Enforcement.
* **Constraint:** "My Local is Truth."

## 2. GENERATOR: DISPATCH PACKET (STELA STANDARD)
# DP-OPS-[ID]: [TITLE]

## 0. FRESHNESS GATE (STOP IF FAILED)
* **Base Branch:** main
* **Required Work Branch:** work/dp-ops-[id]-[slug]-[date]-[hash]
* **Constraint:** If current branch != work branch -> **STOP**.
* **Constraint:** If Base HEAD != `git rev-parse HEAD` -> **STOP**.

## I. SCOPE & SAFETY
* **Objective:** [One sentence goal]
* **Target Files (Allowlist):**
    * [List exact files to touch]
* **Forbidden:**
    * NO edits to `projects/` (Source Code) unless explicitly authorized.
    * NO edits to `.github/` workflows.

## II. EXECUTION PLAN (A-E CANON)

### A) STATE
* **Context:** [Why we are doing this]
* **Drift:** [What is currently wrong]

### B) REQUEST
* **Action 1:** [Command / Edit]
* **Action 2:** [Command / Edit]

### C) CHANGELOG
* **Log:** [Human readable summary of changes]

### D) PATCH / DIFF
* **Format:** Universal diff or distinct code blocks.

### E) RECEIPT (REQUIRED)
* **Verification:**
    * Run: `./ops/bin/dump --scope=platform` (Verify clean scope)
    * Run: `./tools/context_lint.sh` (if available)
* **Artifact Bundle:**
    * **Target Directory:** `storage/handoff/`
    * `DP-OPS-[ID]-RESULTS.md` (Create this in handoff)
    * `OPEN-[branch].txt` (Already in handoff)
    * `OPEN-PORCELAIN-[branch].txt` (Already in handoff)
