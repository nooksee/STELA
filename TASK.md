# STELA TASK DASHBOARD (LIVING SURFACE)
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-11

## 1. Session State (The Anchor)
Pointer: storage/handoff/OPEN-*.txt (The generated session context)
Active Branch: main (Must match OPEN artifact)
Base HEAD: d14969db (Must match OPEN artifact)
Context Manifest: ops/lib/manifests/CONTEXT.md (Checked by tools/lint/context.sh)

## 2. Logic Pointers (The Law)
Primary Constraint: PoT.md (Policy of Truth).

### 2.1 Governance Pointers
Jurisdiction: PoT.md Section 3.

Git Authority: PoT.md Section 4.1.

Behavioral Standard: PoT.md Section 4.2.

Staffing Protocol: PoT.md Section 4.1.

### 2.2 Execution Pointers (The Toolchain)
Linguistic Precision: tools/lint/style.sh.

Structure Verification: tools/verify.sh.

Context Hygiene: tools/lint/context.sh.

Truth Integrity: tools/lint/truth.sh.

DP Validation: tools/lint/dp.sh.

## 3. Current Dispatch Packet (DP)
### DP-OPS-0047: Harden TASK Closeout Cycle and Prune Logic

### 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0047-harden-task-prune
Base HEAD: d14969db

Gate Artifacts (Must Match):
- OPEN: storage/handoff/OPEN-main-d14969db.txt
- OPEN-PORCELAIN: storage/handoff/OPEN-PORCELAIN-main-d14969db.txt
- Dump: storage/dumps/dump-full-main-d14969db.txt
- Dump Manifest: storage/dumps/dump-full-main-d14969db.manifest.txt

Preconditions:
- No commits on main.
- Working tree must be clean before execution begins (OPEN shows: M TASK.md).
- If Base HEAD changes, regenerate OPEN and DUMP and update this gate before proceeding.

Gate Commands (Must Pass):
- bash tools/lint/context.sh

### 3.2 Required Context Load (Read Before Doing Anything)
Read these in order before making edits:
1. PoT.md
2. TASK.md
3. SoP.md
4. docs/MANUAL.md
5. .github/copilot-instructions.md
6. ops/bin/prune
7. ops/bin/llms
8. tools/verify.sh
9. tools/lint/truth.sh
10. tools/lint/style.sh
11. tools/lint/dp.sh
12. tools/lint/llms.sh

### 3.3 Scope and Safety
Objective: Convert the current manual closeout checklist into a hardened Closeout Cycle, extend ops/bin/prune to support targeted DP pruning, and resolve branch law drift by consolidating branch rules into PoT.md.

Safety and invariants:
- Follow PoT.md as sole authority across scopes.
- No contractions in operator-facing outputs, including ops/bin/prune messaging.
- Reuse-first: prefer existing patterns in ops/bin and tools/lint.
- Do not add new repository paths that are not already present in the dump.
- Any llms invocation requires allowlisting llms root outputs prior to running the command.

Target Files allowlist (hard gate):
- PoT.md
- TASK.md
- SoP.md
- docs/MANUAL.md
- .github/copilot-instructions.md
- ops/bin/prune
- llms.txt
- llms-small.txt
- llms-full.txt
- llms-ops.txt
- llms-governance.txt
- storage/handoff/DP-OPS-0047-RESULTS.md

### 3.4 Execution Plan (A-E Canon)
#### 3.4.1 State (What is true now)
- OPEN indicates Active Branch main and a dirty working tree (M TASK.md).
- TASK.md Base HEAD is d14969db, but its Gate Artifacts section references prior artifact names (46a04806). This is an anchor mismatch.
- llms.txt header shows HEAD: 46a04806 while Base HEAD is d14969db (metadata mismatch).
- ops/bin/prune archives SoP entries beyond a threshold, deletes storage/handoff files older than 7 days, attempts to keep current DP by extracting a legacy TASK.md marker, does not support DP targeted pruning, and does not cover storage/dumps or storage/_scratch.

#### 3.4.2 Request (What we are changing)
1. Hardened Closeout Cycle: define the five-stage cycle of Verify, Harvest, Refresh, Log, and Prune, encode it in docs/MANUAL.md, and require it in TASK.md closeout.
2. Branching Doctrine consolidation: add PoT.md Section 5.5 and refactor .github/copilot-instructions.md to point to it.
3. ops/bin/prune targeted DP pruning: add --dp support, target storage/handoff, storage/dumps, and storage/_scratch, exclude .gitkeep files, preserve existing SoP archiving and age-based cleanup, and fix current DP detection to parse the TASK.md DP header.
4. llms refresh: run ops/bin/llms with an absolute out-dir to refresh llms.txt and bundle files and eliminate the HEAD mismatch.

#### 3.4.3 Changelog (Planned edits)
- PoT.md: add Section 5.5 Branching Doctrine (SSoT).
- .github/copilot-instructions.md: replace duplicated branch rules with PoT.md pointer.
- docs/MANUAL.md: add Closeout Cycle section with required commands and allowlist note.
- TASK.md: fix gate artifacts, point closeout to docs/MANUAL.md Closeout Cycle, and require RESULTS receipts.
- ops/bin/prune: add --dp support, fix DP detection, and preserve archiving and age cleanup.
- llms.txt, llms-small.txt, llms-full.txt, llms-ops.txt, llms-governance.txt: regenerate via ops/bin/llms.

#### 3.4.4 Patch / Diff (Implementation details)
1. Branch setup and hygiene (Operator-run).
Ensure no local edits remain on main. If needed, restore or stash before proceeding, then create the work branch.
~~~bash
git status

git restore --staged --worktree TASK.md

git checkout -b work/dp-ops-0047-harden-task-prune
~~~

2. PoT.md amendment.
Add Section 5.5 Branching Doctrine (SSoT) with immutable trunk, work namespace, naming schema, and drift prevention rules.

3. .github/copilot-instructions.md refactor.
Replace duplicated branch rules with a pointer to PoT.md Section 5.5.

4. docs/MANUAL.md Closeout Cycle.
Add a Closeout Cycle section (Verify, Harvest, Refresh, Log, Prune) with the exact command sequence and the llms allowlist requirement.

5. TASK.md updates.
Update gate artifacts to match Base HEAD, replace generic closeout guidance with a pointer to docs/MANUAL.md, and require RESULTS receipts.

6. ops/bin/prune implementation.
Add usage and argument parsing for --dp. When --dp is provided, prune matching artifacts in storage/handoff, storage/dumps, and storage/_scratch, excluding .gitkeep files. When --dp is not provided, keep existing SoP archiving and age-based handoff cleanup, but fix current DP inference by parsing the TASK.md header line beginning with "### DP-" under "## 3. Current Dispatch Packet (DP)".

7. llms regeneration.
Run ops/bin/llms with an absolute out-dir and validate that llms.txt HEAD matches git HEAD.
~~~bash
./ops/bin/llms --out-dir="$(pwd)"
~~~

#### 3.4.5 Receipt (Proofs to collect)
Create storage/handoff/DP-OPS-0047-RESULTS.md with the following sections and receipts.
- Base State: OPEN summary (branch, head, and dirty state) and DUMP identifiers.
- Verification receipts: output from ./tools/verify.sh and ./tools/lint/truth.sh ./tools/lint/style.sh ./tools/lint/dp.sh TASK.md ./tools/lint/llms.sh.
- Functional receipts: output from ./ops/bin/prune --dp=DP-OPS-0047 and ./ops/bin/llms --out-dir="$(pwd)". Confirm llms.txt HEAD matches git HEAD.
- Change summary: bullet list of files changed and why.
- Drift closure: confirm branch law resides in PoT.md Section 5.5 and copilot instructions point to PoT.

## 4. Closeout (Mandatory)
- Execute docs/MANUAL.md Closeout Cycle in order.
- Update TASK.md with the next DP and matching gate artifacts before execution begins.
- Append a SoP.md log entry for DP-OPS-0047 at completion with verification and functional receipts.
- Verify allowlist compliance and run required linters before closeout.
- Run ops/bin/prune --dp=DP-OPS-0047 after receipts are captured.

Mandatory Closing Block
Varied Wording provision: Each entry must use meaningfully distinct wording; copy or minor tense changes are not acceptable. Entry 4 must differ from Entry 1.

Primary Commit Header (plaintext)
DP-OPS-0047: Harden closeout cycle, consolidate branching doctrine, and add targeted prune

Pull Request Title (plaintext)
DP-OPS-0047 Harden TASK closeout, PoT branching SSoT, and DP-scoped prune

Pull Request Description (markdown)
### What changed
- Hardened the closeout workflow into a five-stage cycle (Verify, Harvest, Refresh, Log, Prune) with docs/MANUAL.md as the pointer target.
- Consolidated branching rules into PoT.md (SSoT) and reduced drift by pointing copilot instructions to PoT.
- Extended ops/bin/prune with DP-scoped pruning and repaired current DP detection against TASK.md header format.
- Refreshed llms bundles to match current HEAD.

### Why
- Closeout steps were previously checklists without an enforced cycle, enabling drift.
- Branching doctrine existed in parallel documents, creating ambiguous authority.
- Prune could not reliably preserve or target DP artifacts due to legacy TASK parsing.
- llms metadata did not match HEAD, undermining pointer accuracy.

### Verification
- tools/verify.sh
- tools/lint/truth.sh
- tools/lint/style.sh
- tools/lint/dp.sh TASK.md
- tools/lint/llms.sh
- ops/bin/prune --dp=DP-OPS-0047 (receipt attached)

Final Squash Stub (plaintext) (Must differ from #1)
Harden operational metabolism: closeout cycle pointers, branch law in PoT, DP-target prune, and llms refresh

Extended Technical Manifest (plaintext)
Files:
- PoT.md: add Section 5.5 Branching Doctrine (SSoT)
- docs/MANUAL.md: define Closeout Cycle and required commands
- TASK.md: fix gate artifacts and require Closeout Cycle compliance
- .github/copilot-instructions.md: replace duplicated branch rules with PoT pointer
- ops/bin/prune: add --dp support, fix DP detection, keep archival behavior
- llms.txt
- llms-small.txt
- llms-full.txt
- llms-ops.txt
- llms-governance.txt

Operational notes:
- ops/bin/llms executed with --out-dir="$(pwd)" and allowlisted root outputs.

Review Conversation Starter (markdown)
Please review for:
1. PoT.md Section 5.5 wording and scope (SSoT consolidation correctness).
2. TASK.md closeout pointer accuracy and whether it is sufficiently strict without duplicating MANUAL content.
3. ops/bin/prune behavior: DP-scoped deletion safety (directory scope, .gitkeep exclusions) and default-mode retention rules.
4. llms refresh correctness (HEAD parity and lint pass).

## 4.1 Thread Transition (Reset / Archive Rule)
- Append a THREAD END entry to the TASK.md Work Log at completion.
- Ensure the next session begins with a fresh OPEN artifact and matching dump artifacts.

## 5. Work Log (Timestamped Continuity)
2026-02-10 19:00 - THREAD START: DP-OPS-0046. Seed: Pointer-first agent constitution refinement. Base HEAD: 46a04806. Verification: NOT RUN. Blockers: none. NEXT: Execute 3.4 and capture RESULTS.
2026-02-11 03:41 - THREAD END: DP-OPS-0046. Outcome: Pointer-first constitution refined; llms bundles refreshed. Verification: COMPLETE. Blockers: none. NEXT: Await new DP.
2026-02-10 00:00 - THREAD START: DP-OPS-0047. Seed: Harden TASK closeout cycle and prune logic. Base HEAD: d14969db. Verification: NOT RUN. Blockers: main is dirty (M TASK.md). NEXT: Create work branch, clear dirty state, then execute 3.4 and capture RESULTS.
2026-02-11 05:12 - THREAD END: DP-OPS-0047. Outcome: Closeout Cycle codified, branching doctrine consolidated in PoT, ops/bin/prune extended with DP targeting, llms bundles refreshed. Verification: COMPLETE. Blockers: none. NEXT: Generate a fresh OPEN and dump artifacts for the next DP and update the TASK.md gate artifacts.
