<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# **Stela Operator Prompts**

**Purpose:**
Operator-facing prompt stances for DP generation and audit workflows.

**Reference-First Design:**
These prompts reference canonical locations rather than duplicating content:
* **Common constraints:** `ops/lib/manifests/CONSTRAINTS.md` (Sections 1 & 2)
* **DP structure:** `ops/src/surfaces/dp.md.tpl`
* **PLAN structure:** `ops/src/surfaces/plan.md.tpl`
* **RESULTS surface:** `ops/src/surfaces/results.md.tpl`
* **Receipt baseline:** `ops/src/surfaces/dp.md.tpl` Section 3.4.5
* **Path rules:** `PoT.md` Section 1.2
* **Certify spec:** `docs/ops/specs/binaries/certify.md`
* **Results surface spec:** `docs/ops/specs/surfaces/results.md`

**Artifact Attachment Policy:**
* **For prompt intake (all stances):** Generate and attach bundle artifacts from `ops/bin/bundle` (`bundle .txt` + `.manifest.json`).
* **For DP authoring (Integrator):** Use `./ops/bin/bundle --profile=architect --out=auto` and attach `PLAN.md`.
* **For read-only analysis (Integrator or Operator):** Use `./ops/bin/bundle --profile=analyst --out=auto` and provide an operator query source (`storage/handoff/TOPIC.md` or inline `ANALYZE/SYNTHESIZE/FORMULATE` query).
* **For audit review (Integrator or Operator):** Use `./ops/bin/bundle --profile=audit --out=auto` only, and attach native `BUNDLE-*` outputs (do not relabel as `AUDIT-*`).
* **For addendum authorization intake (Integrator/Auditor):** Use `./ops/bin/bundle --profile=auditor --intent="ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>" --out=auto` only.
* **For addendum artifact generation (Contractor):** Follow `docs/ops/prompts/e-prompt-06.md` decision-first flow (decision leaf, OPEN intent, core dump, auditor bundle).
* **For project-scoped context capture:** Use `./ops/bin/bundle --profile=project --project=<name> --out=auto`.
* **For hygiene normalization intake:** Use `./ops/bin/bundle --profile=hygiene --out=auto`.
* **In DP content (Worker):** DP must be self-contained. No disposable artifact citations.
* **For closeout (Worker):** Maintain `storage/handoff/CLOSING-<DP_ID>.md` as a human-authored sidecar during execution.

**Attachment Contract Table:**

| Profile | Bundle Command | Required Attachments | Notes |
| --- | --- | --- | --- |
| `analyst` | `./ops/bin/bundle --profile=analyst --out=auto` | `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, query source (`storage/handoff/TOPIC.md` or inline `ANALYZE/SYNTHESIZE/FORMULATE`) | Attach `BUNDLE-*.tar` when the model session reliably ingests tar artifacts. |
| `architect` | `./ops/bin/bundle --profile=architect --out=auto` | `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, `storage/handoff/PLAN.md` | PLAN must include Architect Handoff fields for deterministic DP drafting. |
| `audit` | `./ops/bin/bundle --profile=audit --out=auto` | `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, DP RESULTS receipt | PASS/FAIL audit verdict only. |
| `auditor` | `./ops/bin/bundle --profile=auditor --intent="ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>" --out=auto` | `BUNDLE-*.txt`, `BUNDLE-*.manifest.json` | Addendum authorization only. |
| `project` | `./ops/bin/bundle --profile=project --project=<name> --out=auto` | `BUNDLE-*.txt`, `BUNDLE-*.manifest.json` | Project-scoped context bundle. |
| `hygiene` | `./ops/bin/bundle --profile=hygiene --out=auto` | `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, draft DP input | Structure-conformance normalization flow. |

> **Model-compat fallback:** If tar ingestion is unreliable in a web model context, attach the dump payload (`dump-*.txt`) and dump manifest (`dump-*.manifest.txt`) directly in place of the bundle tar.

**Stance Index:**
* **E-PROMPT-01:** Gatekeeper (audit before merge)
* **E-PROMPT-02:** Hygiene (bundle-first DP conformance)
* **E-PROMPT-03:** Architect (generate DP from plan handoff)
* **E-PROMPT-04:** Analyst (read-only analysis + architect-ready PLAN mode)
* **E-PROMPT-05:** Auditor (authorize addendum from auditor bundle)
* **E-PROMPT-06:** Contractor (generate addendum authorization artifacts)

**Mode Split (Hard Rule):**
* `audit` profile is for PASS/FAIL audit verdicts only.
* `auditor` profile is for addendum authorization only.

**Immutable Workflow:**
* Use `ops/bin/draft` or Architect stance to generate DPs.
* Use `ops/bin/certify` to generate RESULTS receipts at closeout.
* Never hand-edit TASK.md structural boilerplate or DP structure.
* `storage/dp/active/allowlist.txt` is the hard gate for permitted file touches.

**Governance:**
* Constitution: `PoT.md`
* Active Contract: `TASK.md`
* DP Template: `ops/src/surfaces/dp.md.tpl`
* PLAN Template: `ops/src/surfaces/plan.md.tpl`
* RESULTS Template: `ops/src/surfaces/results.md.tpl`
* Validation: `tools/lint/dp.sh`, `tools/lint/task.sh`, `tools/lint/integrity.sh`,
  `tools/lint/results.sh`, `tools/lint/plan.sh`
