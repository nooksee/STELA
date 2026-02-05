# Governance (Coherence & Drift Control)

## 0. Philosophy
**Governance is not “process theater” — it is the product.**
This project is built to resist entropy. We value structure over memory and explicit contracts over implicit knowledge.

## 1. Non-Negotiables (Hard Rules)
* **No Direct Pushes:** `main` is read-only. Work happens on `work/*` branches → PRs → Merge.
* **Green Gates Only:** If `repo-gates` fail, the code is wrong, not the gate.
* **Canon Supremacy:** When in doubt, `PoT.md` wins.

## 2. Canon Surfaces (Source of Truth)
These files represent the immutable reality of the project.
* `PoT.md` — Constitution, staffing, jurisdiction, and logic standards.
* `SoP.md` — The historical ledger (State of Play).
* `TASK.md` — The active contract (DP) and work log.
* `docs/INDEX.md` — The system root.

## 3. Change Management (The SoP Rule)
**Rule:** You must write to `SoP.md` if (and only if) you alter **Canon** or **Governance** surfaces.
* **Why:** We track changes to the *rules* of the system, not just the code.
* **Routine Work:** Standard feature work in `projects/` does not require SoP entries unless it changes the platform itself.

## 4. Staffing Protocol (Jurisdiction)
Defined strictly in `PoT.md`:
* **Operator (Human):** Final authority. Owns approvals, commits, and secrets.
* **Integrator (AI Lead):** Guardian of governance. Detects drift and maintains structure.
* **Contractor (AI Guest):** Execution arm. Drafts logic but never commits.

## 5. AI Engagement Protocol
* **Logic First:** All agents must adhere to the Behavioral Logic Standards in `PoT.md`.
* **DP Required:** No logic changes shall be proposed without an active Dispatch Packet (DP) in `TASK.md`.
* **No Hallucinations:** Cite sources. Do not invent paths.

## 6. Tone Lanes
* **Ops Lane (`ops/`, `docs/ops/`):** Checklist-heavy, precise, dry, no-fluff.
* **Public Lane (`README.md`):** Human-centric, explanatory, welcoming.
