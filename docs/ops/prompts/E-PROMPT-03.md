## **Architect (Refresh + Generate DP)**

Use when: Drafting a new DP for worker execution.
Attach: OPEN, OPEN-PORCELAIN, dump, dump manifest, plan.md (or equivalent canon plan doc).

Rules:
* Refresh state using the attached OPEN and dump artifacts.
* Logic: `PoT.md`. Structure: **ops/src/surfaces/dp.md.tpl rendered format** (numbered sections).
* Do not invent file paths; verify with dump.
* Output must be a valid DP with proper numbered section structure matching the canonical template.
* Output only the stance format.

Steps:
0. **PRECONDITIONS**:
   * If `plan.md` (or equivalent canon plan doc) is missing/empty/ambiguous: **STOP** and request it.
   * If OPEN/dump are missing: **STOP** and request them.
1. ANALYZE `<plan.md>` to determine Objective, Scope, and Execution Plan.
2. CONSTRUCT the DP using the **canonical numbered section structure**:
   * `### 3.1 Freshness Gate (Must Pass Before Work)` - Base Branch, Required Work Branch, Base HEAD, Freshness Stamp, Required local re-check commands, Preconditions, STOP conditions
   * `### 3.1.1 DP Preflight Gate (Run Before Any Edits)` - Purpose, Worker runs commands, STOP if any preflight check fails
   * `### 3.2 Required Context Load (Read Before Doing Anything)` - Canon load order (always) and DP-scoped load order (per DP)
   * `### 3.3 Scope and Safety` - Objective, In scope, Out of scope, Safety and invariants, Target Files allowlist (hard gate)
   * `### 3.4 Execution Plan (A-E)` with subsections:
     - `### 3.4.1 State` - Base branch and HEAD, current repo state
     - `### 3.4.2 Request` - High-level deliverables
     - `### 3.4.3 Changelog` - Explicit file list (UPDATE/NEW) with short rationale
     - `### 3.4.4 Patch / Diff` - Implementation steps (A, B, C, etc.)
     - `### 3.4.5 Receipt (Proofs to collect) - MUST RUN` - All verification commands including lints, tool outputs, diffs
   * `### 3.5 Closeout (Mandatory Routing)` - Closeout sequence, routing protocol, prune commands, Mandatory Closing Block section
3. CONTENT REQUIREMENTS:
   * **3.2 DP-scoped load order**: Minimal set of canon docs/specs/lints the worker must load
   * **3.3 Objective**: Goal in 1–3 lines
   * **3.3 In scope / Out of scope**: Explicit boundaries + context hazard exclusions
   * **3.3 Safety and invariants**: Include "no manual edits to generated outputs", "no structural edits to TASK/DP", "allowlist hard gate", etc.
   * **3.4.1 State**: Repo state derived from OPEN (high-level; no pasted payloads)
   * **3.4.2 Request**: Translate plan into worker requirements
   * **3.4.3 Changelog**: Explicit file list (UPDATE/NEW) per file
   * **3.4.4 Patch**: Implementation approach; reference exact files; no invented paths
   * **3.4.5 Receipt**: Must include `bash tools/lint/truth.sh`, `bash tools/lint/dp.sh TASK.md`, `bash tools/lint/task.sh`, plus scope-specific verifications
   * **3.5 Closeout**: Include closeout protocol and mandatory Closing Block subsection
4. CONSTRAINTS:
   * Stay strictly within plan scope.
   * Paths must exist in dump or be explicitly marked NEW.
   * Avoid pattern-paths/globs/brace-expansions; be literal.
   * Use the exact section numbering and heading format shown above.

Output only: The full DP content with proper numbered section structure (starting with `### 3.1 Freshness Gate`) enclosed in a markdown code block.