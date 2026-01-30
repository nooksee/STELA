# Quickstart (Stela)

This repo is governed. The fastest way to succeed here is to follow the rules *exactly*.

## 1. Onboarding (Read-in Order)
**Operators (Human):**
1. `TRUTH.md` — The Constitution (Filing Doctrine + Structure).
2. `SoP.md` — The History Ledger (State of Play).
3. `TASK.md` — The Active Work Surface (Current Objective).
4. `docs/library/MANUAL.md` — Command Reference.

**Agents (AI):**
- Follow the jurisdictional read-in sequence defined in `AGENTS.md`.

## 2. Workflow Doctrine (Non-Negotiables)
* **PR-Only:** No direct pushes to `main`. Ever.
* **Repo Gates:** All CI checks must pass before merge.
* **One Slice:** One topic per PR.

## 3. The SoP Rule (History Ledger)
**Rule:** You only write to `SoP.md` if you alter **Canon** or **Governance**.
* **Canon:** `TRUTH.md`, `TASK.md`, `ops/`, `docs/`, `.github/`.
* **Logic:** If you change the rules of the system, you must log the state change.
* **Routine Work:** Standard code changes in `projects/` do *not* require an SoP entry unless they fundamentally shift the platform.

## 4. Standard Workflow
1.  **Check State:** Ensure `main` is clean.
2.  **Branch:** `work/<topic>-YYYY-MM-DD`
3.  **Edit & Commit:** Small, descriptive commits.
4.  **Push & PR:** Open PR → Pass Gates → Merge.

## 5. Commit Taxonomy
* `docs:` Documentation changes.
* `ci:` Workflow / repo-gates / tooling.
* `chore:` Housekeeping / dependencies.
* `feat:` New capabilities.
* `fix:` Bug remediation.

## 6. Mental Model (Where things live)
* `main` — The locked production state.
* `work/*` — The active notebook (scratchpad).
* `ops/` — The operating system (binaries + registry).
* `docs/` — The manual (points into ops).
* `projects/` — The work payloads.