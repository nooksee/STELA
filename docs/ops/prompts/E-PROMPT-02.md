## **Hygiene (Refresh + Conform to DP Structure)**

Use when: Conforming an old DP or rough notes into the **canonical DP structure**.
Attach: OPEN, dump, Old-DP.md (or rough draft).

Rules:
* Refresh state using the attached OPEN and dump artifacts.
* Shared constraints are SSOT in `ops/lib/manifests/CONSTRAINTS.md`:
  * Section 1 (Universal Template Rules)
  * Section 2 (Stance and Operator Prompt Rules)
* Structure authority remains **`ops/src/surfaces/dp.md.tpl` rendered format**.
* Preserve intent; update contract language/structure only.
* Do not invent file paths; verify with dump.
* Output only the stance format.

Steps:
1. **NORMALIZE** the input into **canonical DP structure** with numbered sections:
   * `### 3.1 Freshness Gate (Must Pass Before Work)`
   * `### 3.1.1 DP Preflight Gate (Run Before Any Edits)`
   * `### 3.2 Required Context Load (Read Before Doing Anything)`
   * `### 3.3 Scope and Safety`
   * `### 3.4 Execution Plan (A-E)`
   * `### 3.5 Closeout (Mandatory Routing)`
2. **INPUT DISCIPLINE**:
   * No citations to disposable artifacts.
   * No pasted OPEN/DUMP/manifests.
   * No placeholders (no "TBD", "TODO", "populate during execution").
   * If required details are missing, output **STOP** and name missing inputs.
3. **ALLOWLIST AWARENESS**:
   * Ensure every intended touched/created file is listed explicitly in Target Files allowlist section under 3.3 Scope and Safety.
4. **VERIFY PATHS**:
   * Every referenced path is either present in dump or clearly marked NEW.
5. **RECEIPTS**:
   * Section 3.4.5 Receipt must include:
     - `bash tools/lint/truth.sh`
     - `bash tools/lint/dp.sh TASK.md`
     - `bash tools/lint/task.sh`
   * Add any additional repo/tool checks required by scope.

Output only: The full DP content with proper numbered section structure enclosed in a markdown code block.
