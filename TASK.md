# STELA TASK DASHBOARD (LIVING SURFACE)
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-10

## 1. Session State (The Anchor)
Pointer: storage/handoff/OPEN-*.txt (The generated session context)
Active Branch: work/task-harvester-hardening-0043 (Must match OPEN artifact)
Base HEAD: 1b4325f9 (Must match OPEN artifact)
Context Manifest: ops/lib/manifests/CONTEXT.md (Checked by tools/lint/context.sh)

## 2. Logic Pointers (The Law)
Primary Constraint: PoT.md (Policy of Truth) wins in all conflicts.

### 2.1 Governance Pointers
- Jurisdiction: PoT.md Section 3.
- Git Authority: PoT.md Section 4.1.
- Behavioral Standard: PoT.md Section 4.2.

### 2.2 Execution Pointers (The Toolchain)
- Linguistic Precision: tools/lint/style.sh (Enforces no contractions).
- Structure Verification: tools/verify.sh (Enforces Filing Doctrine).
- Context Hygiene: tools/lint/context.sh (Enforces manifest compliance).
- Truth Integrity: tools/lint/truth.sh (Enforces canon spelling).

## 3. Current Dispatch Packet (DP)
DP-OPS-0043: Task Subsystem Hardening and Harvester Certification

### 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/task-harvester-hardening-0043
Base HEAD: 1b4325f9

Gate Artifacts (Must Match):
- OPEN: storage/handoff/OPEN-main-1b4325f9.txt
- Porcelain: storage/handoff/OPEN-PORCELAIN-main-1b4325f9.txt
- Dump: storage/handoff/dump-full-main-1b4325f9.txt
- Dump Manifest: storage/handoff/dump-full-main-1b4325f9.manifest.txt

Gate Commands (Must Pass):
- bash tools/lint/context.sh

### 3.2 Required Context Load (Read Before Doing Anything)
- Loaded: PoT, SoP, TASK, CONTEXT, MAP
- PoT.md (Governance, Git Authority, Behavioral Standard, Hard Constraints)
- TASK.md (DP decimal schema, scope boundary, closeout requirements)
- SoP.md (Recent DP patterns and verification expectations)
- docs/ops/registry/TASKS.md (Task registry SSOT)
- docs/library/TASKS.md (Task promotion ledger)
- ops/lib/scripts/task.sh (Task harvester and promoter)
- ops/lib/scripts/heuristics.sh (Provenance block generator)
- tools/lint/task.sh (Task linter and enforcement surface)
- tools/lint/dp.sh (DP structure validator)

### 3.3 Scope and Safety
Objective: Certify the Task subsystem as pointer-first and serviceable by aligning ops/lib/scripts/task.sh with tools/lint/task.sh requirements, enforcing registry ID collision locks, and hardening promotion and lint gates to prevent placeholder drift and missing Closeout pointers.

Constraints:
- No scope expansion beyond the allowlist.
- No new directories.
- No edits to ops/lib/manifests/CONTEXT.md that introduce docs/library/tasks or B-TASK references.
- No direct work on main. All changes occur on the required work branch.
- Stop on any lint failure (context, truth, style, verify, task, library) until resolved within scope.

Target Files allowlist (hard gate):
- ops/lib/scripts/task.sh
- ops/lib/scripts/heuristics.sh
- tools/lint/task.sh
- docs/library/TASKS.md
- docs/ops/registry/TASKS.md
- TASK.md
- SoP.md
- llms.txt
- llms-small.txt
- llms-full.txt
- llms-ops.txt
- llms-governance.txt

### 3.4 Execution Plan (A-E Canon)

#### 3.4.1 State
- Current state is anchored by OPEN and dump artifacts at Base HEAD 1b4325f9 on branch main, with a known working tree modification to TASK.md recorded in the OPEN porcelain snapshot.
- ops/lib/scripts/task.sh harvest currently emits an Execution Logic template that can omit the required final Closeout pointer expected by tools/lint/task.sh, creating a systemic drift vector for newly harvested tasks.
- ops/lib/scripts/task.sh does not currently enforce a registry collision lock for B-TASK IDs prior to draft generation, allowing duplicate ID drafts and ledger noise.
- tools/lint/task.sh enforces structural integrity and a Closeout pointer gate, but does not fully prevent placeholder drift in Orchestration and Scope Boundary fields for promoted tasks.
- Success criteria:
  - 0 task lint failures on existing library tasks.
  - 0 registry collision paths permitted by task harvester.
  - 100% of harvested templates include a final Closeout pointer line containing Closeout, TASK.md, and Section 4.
  - Placeholder drift prevention tightened so that promoted tasks cannot retain Not provided for key operational fields.

#### 3.4.2 Request
1) Pre-flight and branch hygiene
   1. Run `bash tools/lint/context.sh` to validate ops/lib/manifests/CONTEXT.md alignment.
   2. Capture session anchors:
      - `./ops/bin/open --intent="DP-OPS-0043 Task subsystem hardening" --dp=DP-OPS-0043 --out=auto`
      - `./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle`
   3. Create the work branch from Base HEAD and ensure all work occurs there:
      - `git switch -c work/task-harvester-hardening-0043`
   4. Reconcile the pre-existing TASK.md working tree modification:
      - Either retain it as the session-state update for DP-OPS-0043, or revert and regenerate via ops/bin/open on the work branch.
      - Ensure the final committed TASK.md state matches the OPEN artifact generated during this DP execution.

2) Harden ops/lib/scripts/task.sh (harvest, promote, validation)
   1. Add a registry collision lock for harvest:
      - Parse docs/ops/registry/TASKS.md and fail-fast if the provided B-TASK ID already exists.
      - Emit a deterministic error message referencing docs/ops/registry/TASKS.md and the list or check workflow.
   2. Align harvested draft template with lint expectations:
      - Ensure Execution Logic final step is a Closeout pointer: "Closeout: Complete Closeout per `TASK.md` Section 4."
      - Ensure the final step contains Closeout, TASK.md, and Section 4 for compatibility with tools/lint/task.sh.
      - Remove or demote any template step that could become the last step without the Closeout pointer.
   3. Strengthen candidate validation in task.sh promote path:
      - Require that Execution Logic includes a final Closeout pointer line before promotion.
      - Require non-placeholder values for Orchestration and Scope Boundary key fields prior to promotion:
        - Primary Agent, Supporting Agents
        - Allowed, Forbidden, Stop Conditions
   4. Correct messaging drift and path accuracy:
      - Fix select_latest_draft error strings to reference storage/archives/tasks (not storage/handoff) when no drafts exist.

3) Harden tools/lint/task.sh (repository enforcement)
   1. Extend placeholder drift checks beyond the current minimum:
      - Fail if Orchestration fields contain placeholder values (Not provided, TODO, TBD, ENTER_, REPLACE_, bracket markers).
      - Fail if Scope Boundary fields contain placeholder values (Allowed, Forbidden, Stop Conditions).
   2. Preserve existing closeout enforcement:
      - Maintain the final-step Closeout pointer gate (Closeout + TASK.md + Section 4).
   3. Maintain pointer-first constraints:
      - Do not relax existing required pointers (PoT.md, docs/GOVERNANCE.md, TASK.md) checks.

4) Certification tests (behavioral, collision, drift)
   1. Collision test (must fail):
      - Attempt harvest with an existing ID (example: B-TASK-01) and confirm the registry lock aborts before file creation and before ledger modification.
   2. Template test (must pass):
      - Harvest a draft with a new ID and confirm the draft contains the Closeout final step pointer.
      - If harvest writes a candidate log entry, record the behavior and either retain it (if acceptable) or revert it before final commit, depending on whether the DP intends to record the probe in docs/library/TASKS.md.
   3. Lint pass (must pass):
      - `bash tools/lint/task.sh`
      - `bash tools/lint/library.sh`

5) Full verification and context outputs
   - bash tools/lint/style.sh
   - bash tools/lint/context.sh
   - bash tools/lint/truth.sh
   - bash tools/lint/task.sh
   - bash tools/lint/library.sh
   - bash tools/verify.sh
   - ops/lib/scripts/task.sh check
   - ./ops/bin/context --dp=DP-OPS-0043
   - ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
   - ./ops/bin/llms --out-dir=.

#### 3.4.3 Changelog
- ops/lib/scripts/task.sh
  - Add registry collision lock for harvest against docs/ops/registry/TASKS.md.
  - Ensure harvested template always ends with a Closeout pointer line referencing TASK.md Section 4.
  - Tighten promotion validation to reject drafts with placeholder Orchestration and Scope Boundary fields.
  - Correct draft selection messaging to match storage/archives/tasks location.
- tools/lint/task.sh
  - Add enforcement for non-placeholder Orchestration and Scope Boundary fields in promoted tasks.
  - Preserve existing pointer-first and Closeout final-step checks.
- TASK.md
  - Update Current DP pointer to DP-OPS-0043 and session anchors consistent with OPEN artifact generated during execution.
- SoP.md
  - Append DP-OPS-0043 entry with exact verification commands run and outputs captured.
- llms*.txt
  - Refresh scope bundles after toolchain changes to ensure discovery outputs remain synchronized.

#### 3.4.4 Patch / Diff
~~~bash
# Preconditions
bash tools/lint/context.sh
git switch -c work/task-harvester-hardening-0043

# Edit within allowlist only
$EDITOR ops/lib/scripts/task.sh
$EDITOR tools/lint/task.sh

# Collision test (expected failure)
ops/lib/scripts/task.sh harvest --id B-TASK-01 --name "Collision Probe" --objective "Validate registry lock" --dp DP-OPS-0043 || true

# Template test (expected success)
ops/lib/scripts/task.sh harvest --id B-TASK-99 --name "Harvester Closeout Probe" --objective "Validate Closeout template emission" --dp DP-OPS-0043

# Lints and verification
bash tools/lint/style.sh
bash tools/lint/context.sh
bash tools/lint/truth.sh
bash tools/lint/task.sh
bash tools/lint/library.sh
bash tools/verify.sh
ops/lib/scripts/task.sh check

# Context and dump outputs
./ops/bin/context --dp=DP-OPS-0043
./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle

# llms refresh (allowed by allowlist)
./ops/bin/llms --out-dir=.

# Diff review
git diff --stat
git diff
~~~

#### 3.4.5 Receipt (Required)
- storage/handoff/DP-OPS-0043-RESULTS.md populated with:
  - OPEN and Porcelain artifact paths generated during execution.
  - Dump bundle path and manifest path generated during execution.
  - Context snapshot archive name produced by ops/bin/context --dp=DP-OPS-0043.
  - Command transcript list (exact commands executed) and pass/fail outcomes.
  - Collision test result (expected failure) including the exact error message.
  - Template test evidence showing the harvested draft contains the final Closeout pointer line.
  - Lint outputs (style, context, truth, task, library) and verify output (pass/fail).
  - llms generation note: which llms files changed and why.
  - git diff summary (file list and line counts) constrained to the allowlist.

## 4. Closeout (Mandatory)
- Update TASK.md:
  - Current DP set to DP-OPS-0043 and session state matches the OPEN artifact generated during DP execution.
- Update SoP.md:
  - Append DP-OPS-0043 entry with a concise change summary and verification commands run.
- Populate storage/handoff/DP-OPS-0043-RESULTS.md with the Receipt items.
- Confirm no off-allowlist edits are present in the final git diff.

### 4.1 Thread Transition (Reset / Archive Rule)
- Close the DP thread in TASK.md Work Log with a THREAD END line after execution completes.
- Ensure the next thread begins with a fresh OPEN artifact and a clean scope boundary.
- If any temporary probe artifacts were created for certification, ensure repository-tracked surfaces remain consistent and lint-clean at thread end.

### Mandatory Closing Block
Constraint: Final Squash Stub must differ significantly from Primary Commit Header.
1. Primary Commit Header: DP-OPS-0043 task subsystem hardening and harvester certification
2. Pull Request Title: DP-OPS-0043 Task Subsystem Hardening and Harvester Certification
3. Pull Request Description:

### Summary
- Added registry collision locking, Closeout template enforcement, and promotion validation gates in `ops/lib/scripts/task.sh`.
- Hardened `tools/lint/task.sh` placeholder drift enforcement for Scope Boundary fields.
- Refreshed llms bundles after task harvester and lint gate updates.
- Updated TASK.md and SoP.md for DP-OPS-0043 closeout.

### Testing
- bash tools/lint/style.sh
- bash tools/lint/context.sh
- bash tools/lint/truth.sh
- bash tools/lint/task.sh
- bash tools/lint/library.sh
- bash tools/verify.sh
- ops/lib/scripts/task.sh check
- ./ops/bin/context --dp=DP-OPS-0043
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- ./ops/bin/llms --out-dir=.

4. Final Squash Stub: Lock task harvesting against registry collisions and enforce Closeout-ready promotion and lint gates
5. Extended Technical Manifest:
- ops/lib/scripts/task.sh
- tools/lint/task.sh
- TASK.md
- SoP.md
- llms.txt
- llms-small.txt
- llms-full.txt
- llms-ops.txt
- llms-governance.txt
6. Review Conversation Starter:
Does the task harvester and linter hardening fully prevent registry collisions and placeholder drift while preserving Closeout pointer compliance?

## 5. Work Log (Timestamped Continuity)
2026-02-08 16:30 - THREAD START: DP-OPS-0038. Seed: Pointer-First Constitution Refactor (Ghost Canon elimination, TASK schema replacement, Toolchain hardening).
2026-02-08 16:35 - DP-OPS-0038: Defined work branch work/constitution-refactor-0038 and Base HEAD eccc11128. Prepared for dispatch. NEXT: Execute DP-OPS-0038.
2026-02-09 00:20 - DP-OPS-0038: Replaced ghost canon references, refactored TASK.md to the pointer-first dashboard, and hardened toolchain enforcement. Verification: RUN (style lint, verify, context lint, truth lint, dp lint test, dump). Blockers: ops/bin/llms not run due to allowlist scope. NEXT: Operator review DP-OPS-0038 results.
2026-02-09 15:07 - DP-OPS-0038B: Added PoT read-in order and system failure states, exempted TASK.md dirty-state, updated dp lint to decimal-only, and logged SoP entry. Verification: RUN (tools/lint/context.sh, tools/lint/truth.sh, tools/verify.sh, ops/bin/dump, tools/lint/dp.sh --test). NOT RUN: ops/bin/llms (allowlist excludes llms bundles). Blockers: ops/bin/llms deferred pending scope approval. NEXT: Operator review RESULTS and decide on llms refresh scope.
2026-02-09 15:13 - DP-OPS-0038B: Expanded scope to refresh llms bundles via ops/bin/llms. Verification: RUN (ops/bin/llms). Blockers: none. NEXT: Operator review updated RESULTS.
2026-02-10 00:00 - DP-OPS-0043: Drafted dispatch packet for Task subsystem hardening and harvester certification. Verification: NOT RUN. Blockers: none. NEXT: Execute DP-OPS-0043.
2026-02-10 16:36 - THREAD START: DP-OPS-0042. Seed: Agent System Certification and Harvester Hardening (Pattern Density emergence, linter tightening, recertification, registry sync, llms refresh). Base HEAD: 5b51900d.
2026-02-10 16:52 - THREAD END: DP-OPS-0042. Verification: RUN (bash tools/lint/style.sh, bash tools/lint/agent.sh, bash tools/lint/library.sh, bash tools/lint/context.sh, bash tools/lint/truth.sh, bash tools/verify.sh, ops/lib/scripts/agent.sh check, ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle, ./ops/bin/llms).
2026-02-10 17:45 - THREAD START: DP-OPS-0043. Seed: Task Subsystem Hardening and Harvester Certification. Base HEAD: 1b4325f9.
2026-02-10 18:00 - DP-OPS-0043: Hardened task harvester and lint gates, enforced Closeout pointer and placeholder drift checks, refreshed llms bundles, and captured results. Verification: RUN (bash tools/lint/style.sh, bash tools/lint/context.sh, bash tools/lint/truth.sh, bash tools/lint/task.sh, bash tools/lint/library.sh, bash tools/verify.sh, ops/lib/scripts/task.sh check, ./ops/bin/context --dp=DP-OPS-0043, ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle, ./ops/bin/llms --out-dir=.). Blockers: none. NEXT: Operator review DP-OPS-0043 results.
2026-02-10 18:02 - THREAD END: DP-OPS-0043. Verification: RUN (bash tools/lint/style.sh, bash tools/lint/context.sh, bash tools/lint/truth.sh, bash tools/lint/task.sh, bash tools/lint/library.sh, bash tools/verify.sh, ops/lib/scripts/task.sh check, ./ops/bin/context --dp=DP-OPS-0043, ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle, ./ops/bin/llms --out-dir=.).
