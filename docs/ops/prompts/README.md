<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# **Stela Operator Prompts**

**Purpose:**
Operator-facing prompt stances for DP generation and audit workflows.

**Reference-First Design:**
These prompts reference canonical locations rather than duplicating content:
* **Common constraints:** `ops/lib/manifests/CONSTRAINTS.md` (Sections 1 & 2)
* **DP structure:** `ops/src/surfaces/dp.md.tpl`
* **RESULTS surface:** `ops/src/surfaces/results.md.tpl`
* **Receipt baseline:** `ops/src/surfaces/dp.md.tpl` Section 3.4.5
* **Path rules:** `PoT.md` Section 1.2
* **Certify spec:** `docs/ops/specs/binaries/certify.md`
* **Results surface spec:** `docs/ops/specs/surfaces/results.md`

**Artifact Attachment Policy:**
* **For DP authoring (Integrator):** Attach OPEN, APD (Audit Platform Dump), and plan.md as authoring and audit context; state the CDD command in dispatch notes.
* **For Contractor execution context (Worker):** Use the CDD (Contractor Dispatch Dump) as the bounded Contractor-visible dump.
* **In DP content (Worker):** DP must be self-contained; no disposable artifact citations.
* **For closeout and audit review:** Use APD (Audit Platform Dump) for platform-scope evidence review.
* **For closeout (Worker):** Maintain `storage/handoff/CLOSING-<DP_ID>.md` as a human-authored
  sidecar during execution. This file is a required input to `ops/bin/certify` and is not
  disposable — certify will hard-stop if it is missing or empty.

**Stance Index:**
* **E-PROMPT-01:** Gatekeeper (audit before merge)
* **E-PROMPT-02:** Hygiene (conform rough draft to canonical structure)
* **E-PROMPT-03:** Architect (generate DP from plan)
* **E-PROMPT-04:** Analyst (read-only analysis)
* **E-PROMPT-05:** Auditor (authorize addendum to unblock certify)

**Immutable Workflow:**
* Use `ops/bin/draft` or Architect stance to generate DPs.
* Use `ops/bin/certify` to generate RESULTS receipts at closeout. RESULTS receipts are
  generated artifacts — manual authoring is prohibited.
* Never hand-edit TASK.md structural boilerplate or DP structure.
* `storage/dp/active/allowlist.txt` is the hard gate for permitted file touches.

**Governance:**
* Constitution: `PoT.md`
* Active Contract: `TASK.md`
* DP Template: `ops/src/surfaces/dp.md.tpl`
* RESULTS Template: `ops/src/surfaces/results.md.tpl`
* Validation: `tools/lint/dp.sh`, `tools/lint/task.sh`, `tools/lint/integrity.sh`,
  `tools/lint/results.sh`
