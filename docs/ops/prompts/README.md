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
* **For prompt intake (all stances):** Generate and attach bundle artifacts from `ops/bin/bundle` (`bundle .txt` + `.manifest.json`) so OPEN freshness metadata, dump pointers, and prompt stance text travel together.
* **For DP authoring (Integrator):** Use `./ops/bin/bundle --profile=architect --out=auto` (or `--profile=auto`) and attach `PLAN.md` when drafting from plan input.
* **For read-only analysis (Integrator/Operator):** Use `./ops/bin/bundle --profile=analyst --out=auto`, and provide an operator query source (`storage/handoff/TOPIC.md` or inline `ANALYZE/SYNTHESIZE/FORMULATE` query). For bundle-only dispatch, `storage/handoff/TOPIC.md` is required.
* **For audit review (Integrator/Operator):** Use `./ops/bin/bundle --profile=audit --out=auto`.
* **For addendum-required authorization intake (Contractor):** Generate decision leaf + OPEN intent + core dump artifacts per `docs/ops/prompts/e-prompt-06.md` (bundle is optional convenience and does not replace OPEN intent proof).
* **For project-scoped context capture:** Use `./ops/bin/bundle --profile=project --project=<name> --out=auto`.
* **In DP content (Worker):** DP must be self-contained; no disposable artifact citations.
* **For closeout (Worker):** Maintain `storage/handoff/CLOSING-<DP_ID>.md` as a human-authored
  sidecar during execution. This file is a required input to `ops/bin/certify` and is not
  disposable — certify will hard-stop if it is missing or empty.

**Stance Index:**
* **E-PROMPT-01:** Gatekeeper (audit before merge)
* **E-PROMPT-02:** Hygiene (conform rough draft to canonical structure)
* **E-PROMPT-03:** Architect (generate DP from plan)
* **E-PROMPT-04:** Analyst (read-only analysis)
* **E-PROMPT-05:** Auditor (authorize addendum to unblock certify)
* **E-PROMPT-06:** Contractor (generate addendum authorization artifacts)

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
