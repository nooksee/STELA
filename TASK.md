# STELA TASK DASHBOARD (LIVING SURFACE)
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-10

## 1. Session State (The Anchor)
Pointer: storage/handoff/OPEN-*.txt (The generated session context)
Active Branch: work/task-perfection-0045 (Must match OPEN artifact)
Base HEAD: 4b581538 (Must match OPEN artifact)
Context Manifest: ops/lib/manifests/CONTEXT.md (Checked by tools/lint/context.sh)

## 2. Logic Pointers (The Law)
Primary Constraint: PoT.md (Policy of Truth) wins in all conflicts.

### 2.1 Governance Pointers
Jurisdiction: PoT.md Section 3 (Ops, Docs, Projects, Tools).

Git Authority: PoT.md Section 4.1 (Operator owns main; Integrator owns TASK.md).

Behavioral Standard: PoT.md Section 4.2 (Linguistic Precision, Literalism).

Staffing Protocol: PoT.md Section 4.1 (Operator, Integrator, Contractor).

### 2.2 Execution Pointers (The Toolchain)
Linguistic Precision: tools/lint/style.sh (Enforces no contractions).

Structure Verification: tools/verify.sh (Enforces Filing Doctrine).

Context Hygiene: tools/lint/context.sh (Enforces manifest compliance).

Truth Integrity: tools/lint/truth.sh (Enforces canon spelling).

DP Validation: tools/lint/dp.sh (Enforces TASK schema).

## 3. Current Dispatch Packet (DP)
DP-OPS-0045: Reconstructing and Perfecting TASK.md

### 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/task-perfection-0045
Base HEAD: 4b581538

Gate Artifacts (Must Match):
- OPEN: storage/handoff/OPEN-work-task-perfection-0045-4b581538.txt
- OPEN-PORCELAIN: storage/handoff/OPEN-PORCELAIN-work-task-perfection-0045-4b581538.txt
- Dump: storage/dumps/dump-platform-work-task-perfection-0045-4b581538.txt
- Dump Manifest: storage/dumps/dump-platform-work-task-perfection-0045-4b581538.manifest.txt

Gate Commands (Must Pass):
- bash tools/lint/context.sh

### 3.2 Required Context Load (Read Before Doing Anything)
Loaded: PoT, SoP, TASK, CONTEXT, MAP

PoT.md (Jurisdiction, Git Authority, Behavioral Standard, Hard Constraints)

SoP.md (Recent DP patterns, verification expectations)

docs/MANUAL.md (Operator mechanics)

tools/lint/dp.sh (DP lint and TASK schema enforcement)

### 3.3 Scope and Safety
Objective: Reconstruct TASK.md to perfectly align with the "Pointer-First" constitution.
Constraints:

No scope expansion beyond the allowlist.

No new directories.

Stop on any lint failure until resolved within scope.

Target Files allowlist (hard gate):

TASK.md

SoP.md

storage/handoff/DP-OPS-0045-RESULTS.md

### 3.4 Execution Plan (A-E Canon)
#### 3.4.1 State
Current Status: TASK.md reconstructed.

Target State: Verified Template.

#### 3.4.2 Request
Apply the new TASK.md schema.

Validate against tools/lint/dp.sh.

#### 3.4.3 Changelog
Reconstructed TASK.md with Pointer-First architecture.

#### 3.4.4 Patch / Diff
(Applied directly).

#### 3.4.5 Receipt (Required)
Populate: storage/handoff/DP-OPS-0045-RESULTS.md with:

Status: Scope summary, Tracked change, Verification.

Changelog: Human-readable summary.

Freshness Gate: Raw output of git rev-parse and git status.

Platform Dump: Path and size check.

Verification: Raw output of all linter commands (style, library, context, truth, verify).

Diff Summary: git diff --stat output.

Mandatory Closing Block: (See Section 4).

## 4. Closeout (Mandatory)
Update TASK.md: Set Current Dispatch Packet to the next ID or placeholder.

Update SoP.md: Append a log entry describing the reconstruction.

Verify: No off-allowlist edits (validate via git diff and tools/verify.sh).

Mandatory Closing Block
Varied Wording provision: Each entry must use meaningfully distinct wording; copy or minor tense changes are not acceptable. Entry 4 must differ from Entry 1.

Primary Commit Header (plaintext)

Pull Request Title (plaintext)

Pull Request Description (markdown)

Final Squash Stub (plaintext) (Must differ from #1)

Extended Technical Manifest (plaintext)

Review Conversation Starter (markdown)

## 4.1 Thread Transition (Reset / Archive Rule)
Append a THREAD END entry to the TASK.md Work Log at completion.

Ensure the next session begins with a fresh OPEN artifact.

## 5. Work Log (Timestamped Continuity)
2026-02-10 19:00 - THREAD START: DP-OPS-0045. Seed: Reconstruction of TASK.md.
