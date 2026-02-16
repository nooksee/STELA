# **Stela Operator Prompts (Phase 3: DP Generation)**

Context:
* These prompts are for the Operator/Integrator running a session.
* Attach OPEN + dump to refresh repo state and confirm file paths.

**Artifact Glossary:**
* **DP (Dispatch Packet)**: Canonical execution document with numbered sections (3.1, 3.2, 3.3, etc.) following `ops/src/surfaces/dp.md.tpl` structure. This is what workers execute.
* **RESULTS**: Execution receipts artifact (pointer-first, with pasted proofs/outputs).

**Reference-First Constraints Pattern (SSOT):**
* Shared prompt/template constraints live in `ops/lib/manifests/CONSTRAINTS.md`.
* Stances reference constraints sections instead of duplicating large rule payloads.
  * Section 1: Universal Template Rules
  * Section 2: Stance and Operator Prompt Rules
* Definition templates inject Section 1 + Section 3 during render.

**Immutable Workflow Mandate:**
* **Do not hand-edit TASK.md structural boilerplate or DP structure.**
* Use the **Architect** stance to generate a **DP** with proper numbered section structure.
* `storage/dp/active/allowlist.txt` is the **hard gate** for permitted file touches (DP points to it).

Governance:
* Logic: `PoT.md`.
* Structure: `TASK.md` + canonical DP template (`ops/src/surfaces/dp.md.tpl` - enforced by `tools/lint/dp.sh` + `tools/lint/task.sh`).

Global Rules (apply to all stances):
* Output **only** what the stance requests (no preamble, no commentary, no extra sections).
* Treat **repo canon** + attached OPEN/dump as authoritative; **disposable artifacts are non-authoritative**.
* **Do not paste** OPEN/DUMP payloads, manifests, or bundles into DP bodies.
* **Do not invent file paths**: every referenced path must exist in dump OR be explicitly marked as a planned NEW file.
* **Ambiguity = STOP** (per PoT): if instructions or required inputs are missing/unclear, output STOP + what is missing.
* All file paths must be enclosed in backticks.
* Avoid non-literal paths (no brace-expansions like `{a,b}`, no globs like `*.md` unless explicitly allowed by plan).
