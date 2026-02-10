# STELA TASK DASHBOARD (LIVING SURFACE)
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-10

## 1. Session State (The Anchor)
Pointer: storage/handoff/OPEN-*.txt (The generated session context)
Active Branch: work/task-hardening-0044 (Must match OPEN artifact)
Base HEAD: 5fa75cb2 (Must match OPEN artifact)
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
DP-OPS-0044: Optimizing TASK.md for LLM Instruction Following

### 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/task-hardening-0044
Base HEAD: 5fa75cb2

Gate Artifacts (Must Match):
- OPEN: storage/handoff/OPEN-work-task-hardening-0044-5fa75cb2.txt
- OPEN-PORCELAIN: storage/handoff/OPEN-PORCELAIN-work-task-hardening-0044-5fa75cb2.txt
- Dump: storage/dumps/dump-platform-work-task-hardening-0044-5fa75cb2.txt
- Dump Manifest: storage/dumps/dump-platform-work-task-hardening-0044-5fa75cb2.manifest.txt

Gate Commands (Must Pass):
- bash tools/lint/context.sh

### 3.2 Required Context Load (Read Before Doing Anything)
- Loaded: PoT, SoP, TASK, CONTEXT, MAP
- PoT.md (Jurisdiction, Git Authority, Behavioral Standard, Hard Constraints)
- TASK.md (Task dashboard schema, active DP schema, closeout and thread rules)
- SoP.md (Recent DP patterns, verification expectations, drift history)
- docs/MANUAL.md (Operator mechanics and hygiene doctrine)
- tools/lint/dp.sh (DP lint and TASK schema enforcement)
- docs/ops/prompts/E-PROMPT-02.md (Conform stance)
- docs/ops/prompts/E-PROMPT-03.md (Draft stance)
- docs/ops/prompts/E-PROMPT-04.md (Read-only stance)
- ops/bin/llms (Context bundle generator behavior and outputs)

### 3.3 Scope and Safety
Objective: Harden TASK.md instruction-following reliability by eliminating session-anchor mismatch vectors (Base HEAD vs. gate artifacts), codifying the required OPEN-PORCELAIN and dump manifest contract in prompts, and enforcing the contract via tools/lint/dp.sh TASK lint. Refresh llms bundles after the contract change.

Constraints:
- No scope expansion beyond the allowlist.
- No new directories.
- No edits to ops/lib/manifests/CONTEXT.md.
- No direct work on main. All changes occur on the required work branch.
- Stop on any lint failure until resolved within scope.
- Success targets:
  - 0 failures from: bash tools/lint/context.sh, bash tools/lint/style.sh, bash tools/lint/truth.sh, bash tools/lint/dp.sh, bash tools/verify.sh
  - 0 TASK lint mismatches for Base HEAD versus gate artifact filenames.
  - 100% of E-PROMPT-02/03/04 attachments include OPEN-PORCELAIN and dump manifest (in addition to OPEN and dump).

### Target Files allowlist (hard gate)
- TASK.md
- tools/lint/dp.sh
- docs/MANUAL.md
- docs/ops/prompts/E-PROMPT-02.md
- docs/ops/prompts/E-PROMPT-03.md
- docs/ops/prompts/E-PROMPT-04.md
- SoP.md
- ops/lib/manifests/LLMS.md
- llms.txt
- llms-small.txt
- llms-full.txt
- llms-ops.txt
- llms-governance.txt

### 3.4 Execution Plan (A-E Canon)

#### 3.4.1 State
- Active session anchors show Base HEAD 5fa75cb2 and a working-tree modification to TASK.md (per OPEN porcelain).
- TASK.md currently contains a Base HEAD value that does not match the gate artifact filenames listed under the active DP, creating a silent drift vector (session anchor mismatch).
- tools/lint/dp.sh TASK lint currently validates presence and order of TASK headings and required fields, but does not enforce that TASK.md gate artifact filenames embed the current Base HEAD.
- docs/ops/prompts/E-PROMPT-02.md, E-PROMPT-03.md, and E-PROMPT-04.md attachments do not require OPEN-PORCELAIN and dump manifest, despite TASK.md treating them as required gate artifacts.
- llms bundle refresh is required after TASK.md and prompt-contract changes, and it touches repository root llms outputs (must be allowlisted).

#### 3.4.2 Request
1) Pre-flight and branch hygiene
   1. Run `bash tools/lint/context.sh`.
   2. Create work branch: `git switch -c work/task-hardening-0044`.
   3. Re-run session capture on the work branch (to bind filenames and Base HEAD):
      - `./ops/bin/open --intent="DP-OPS-0044 TASK contract hardening" --dp=DP-OPS-0044 --out=auto`
      - `./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle`
   4. Update TASK.md gate artifacts under DP-OPS-0044 so filenames embed the current Base HEAD and match the newly generated OPEN, OPEN-PORCELAIN, dump, and dump manifest artifacts.

2) TASK.md contract hardening (instruction-following stability)
   1. Update TASK.md Current Dispatch Packet to DP-OPS-0044 with a title that matches this DP.
   2. Ensure the DP section uses the existing decimal schema and contains no placeholder tokens and no standalone ellipses.
   3. Ensure the Freshness Gate explicitly lists all four gate artifacts (OPEN, OPEN-PORCELAIN, Dump, Dump Manifest) and that each filename includes the Base HEAD string.
   4. Ensure the Thread Transition section remains explicit and mandates a THREAD END entry on closeout.

3) Enforce the contract in tools/lint/dp.sh (TASK lint)
   1. Extend lint_task to parse TASK.md Base HEAD and fail if any required gate artifact filename does not contain that Base HEAD value.
   2. Extend lint_task to fail if any of the required gate artifact lines are missing (OPEN, OPEN-PORCELAIN, Dump, Dump Manifest).
   3. Keep existing placeholder token and ellipsis detection intact.

4) Update operator doctrine in docs/MANUAL.md
   1. Codify a "refresh anchors" rule: when Base HEAD changes (or when a new OPEN is generated), the TASK.md gate artifacts must be updated to match, or work must stop.
   2. Codify the "clean after use" rule: THREAD END is mandatory at closeout, and the next session begins from a fresh OPEN artifact.

5) Update prompts to reflect TASK.md contract changes (E-PROMPT-XX)
   1. Update docs/ops/prompts/E-PROMPT-02.md attachments to require: OPEN, OPEN-PORCELAIN, dump, dump manifest, and Old-DP.md where applicable.
   2. Update docs/ops/prompts/E-PROMPT-03.md attachments to require: OPEN, OPEN-PORCELAIN, dump, dump manifest, and plan.md.
   3. Update docs/ops/prompts/E-PROMPT-04.md attachments to require: OPEN, OPEN-PORCELAIN, dump, dump manifest.
   4. Update the shared "Refresh state" instruction lines in those prompts to reference all required artifacts, not OPEN and dump only.

6) Context refresh (Authorized by allowlist)
   1. Run `./ops/bin/llms --out-dir=.` to refresh:
      - llms.txt, llms-small.txt, llms-full.txt, llms-ops.txt, llms-governance.txt
      - ops/lib/manifests/LLMS.md

7) Verification (stop on first failure)
   - bash tools/lint/context.sh
   - bash tools/lint/style.sh
   - bash tools/lint/truth.sh
   - bash tools/lint/dp.sh --test
   - bash tools/lint/dp.sh TASK.md
   - bash tools/verify.sh

#### 3.4.3 Changelog
- TASK.md: Update current DP to DP-OPS-0044; repair Base HEAD to gate artifact filename alignment; retain explicit thread transition rules.
- tools/lint/dp.sh: Harden TASK lint to enforce Base HEAD to gate artifact filename match and require all four gate artifacts.
- docs/MANUAL.md: Add explicit operational hygiene rules for anchor refresh and thread closeout.
- docs/ops/prompts/E-PROMPT-02.md: Require OPEN-PORCELAIN and dump manifest in attachments and refresh instructions.
- docs/ops/prompts/E-PROMPT-03.md: Require OPEN-PORCELAIN and dump manifest in attachments and refresh instructions.
- docs/ops/prompts/E-PROMPT-04.md: Require OPEN-PORCELAIN and dump manifest in attachments and refresh instructions.
- ops/lib/manifests/LLMS.md and llms*.txt: Refreshed via ops/bin/llms (allowed and expected).

#### 3.4.4 Patch / Diff
~~~bash
# Pre-flight
bash tools/lint/context.sh

# Branch
git switch -c work/task-hardening-0044

# Refresh anchors (produce matching filenames for Base HEAD)
./ops/bin/open --intent="DP-OPS-0044 TASK contract hardening" --dp=DP-OPS-0044 --out=auto
./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle

# Edit contract + enforcement + prompts
$EDITOR TASK.md
$EDITOR tools/lint/dp.sh
$EDITOR docs/MANUAL.md
$EDITOR docs/ops/prompts/E-PROMPT-02.md
$EDITOR docs/ops/prompts/E-PROMPT-03.md
$EDITOR docs/ops/prompts/E-PROMPT-04.md

# Context refresh (Authorized by allowlist)
./ops/bin/llms --out-dir=.

# Verification
bash tools/lint/context.sh
bash tools/lint/style.sh
bash tools/lint/truth.sh
bash tools/lint/dp.sh --test
bash tools/lint/dp.sh TASK.md
bash tools/verify.sh
~~~

#### 3.4.5 Receipt (Required)
- Populate: storage/handoff/DP-OPS-0044-RESULTS.md with:
  - Raw outputs (unredacted) for all verification commands listed in 3.4.4.
  - `git status --porcelain` output.
  - `git diff --stat` output, and an explicit statement that all changed files are within the allowlist.
  - A short excerpt from TASK.md showing:
    - Base HEAD value.
    - Gate Artifacts lines whose filenames embed the same Base HEAD.
  - Confirmation that llms.txt and the other llms outputs reflect the refreshed state after the TASK.md contract update.

## 4. Closeout (Mandatory)
- Update TASK.md: Set Current Dispatch Packet to DP-OPS-0044 and ensure the DP section is internally consistent (Base HEAD, gate artifacts, branch, allowlist, and thread rules).
- Update SoP.md: Append a log entry describing the TASK contract hardening, prompt updates, lint enforcement changes, and llms refresh.
- Verify: No off-allowlist edits (validate via git diff and tools/verify.sh).

## 4.1 Thread Transition (Reset / Archive Rule)
- Append a THREAD END entry to the TASK.md Work Log for DP-OPS-0044 at completion.
- Ensure the next session begins with a fresh OPEN artifact and matching dump artifacts.

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
- 2026-02-10 19:00 — THREAD START: DP-OPS-0044. Seed: TASK.md instruction-following hardening (anchor match enforcement) and prompt contract alignment. Base HEAD: 5fa75cb2. Verification: NOT RUN. Blockers: none. NEXT: Execute 3.4 and capture RESULTS.
- 2026-02-10 21:19:42 UTC — THREAD END: DP-OPS-0044. Verification: RUN (bash tools/lint/context.sh, bash tools/lint/style.sh, bash tools/lint/truth.sh, bash tools/lint/dp.sh --test, bash tools/lint/dp.sh TASK.md, bash tools/verify.sh, ./ops/bin/llms --out-dir=/home/nos4r2/dev/nukece). Blockers: none. NEXT: Operator review DP-OPS-0044 RESULTS.
