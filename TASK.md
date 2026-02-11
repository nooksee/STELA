# STELA TASK DASHBOARD (LIVING SURFACE)
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-11

## 1. Session State (The Anchor)
Pointer: storage/handoff/OPEN-*.txt (The generated session context)
Active Branch: main (Must match OPEN artifact)
Base HEAD: 46a04806 (Must match OPEN artifact)
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
DP-OPS-0047: Pending dispatch packet.

### 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/pending-dp-0047
Base HEAD: 46a04806

Gate Artifacts (Must Match):
- OPEN: storage/handoff/OPEN-main-46a04806.txt
- OPEN-PORCELAIN: storage/handoff/OPEN-PORCELAIN-main-46a04806.txt
- Dump: storage/dumps/dump-full-main-46a04806.txt
- Dump Manifest: storage/dumps/dump-full-main-46a04806.manifest.txt

Gate Commands (Must Pass):
- bash tools/lint/context.sh

### 3.2 Required Context Load (Read Before Doing Anything)
Loaded: PoT, SoP, TASK, CONTEXT, MAP

PoT.md (Jurisdiction, Git Authority, Behavioral Standard, Hard Constraints)

SoP.md (Recent DP patterns, verification expectations)

docs/MANUAL.md (Operator mechanics)

tools/lint/dp.sh (DP lint and TASK schema enforcement)

### 3.3 Scope and Safety
Objective: Await next Dispatch Packet assignment and refresh session anchors before execution.

Constraints:
- Scope is on hold until a new DP is drafted in TASK.md.
- Governance and branch rules: PoT.md Sections 4.1 and 5.1.
- Context and truth validation: tools/lint/context.sh and tools/lint/truth.sh.

Target Files allowlist (hard gate):
- TASK.md

### 3.4 Execution Plan (A-E Canon)
#### 3.4.1 State
Current Status: DP-OPS-0046 closeout completed; awaiting next assignment.

Target State: New DP drafted with fresh OPEN and dump artifacts, then executed.

#### 3.4.2 Request
1. Generate a new OPEN artifact for the next DP.
2. Update Base HEAD and gate artifacts to match the new OPEN.
3. Populate scope, allowlist, and verification steps.

#### 3.4.3 Changelog
- Placeholder DP staged to await next assignment.

#### 3.4.4 Patch / Diff
- None until the next DP is issued.

#### 3.4.5 Receipt (Required)
Requirement: Populate storage/handoff/DP-OPS-0047-RESULTS.md when the next DP runs.

## 4. Closeout (Mandatory)
- Update TASK.md with the next DP and matching gate artifacts before execution begins.
- Append a SoP.md log entry for the next DP at completion.
- Verify allowlist compliance and run required linters before closeout.

Mandatory Closing Block
Varied Wording provision: Each entry must use meaningfully distinct wording; copy or minor tense changes are not acceptable. Entry 4 must differ from Entry 1.

Primary Commit Header (plaintext)

Pull Request Title (plaintext)

Pull Request Description (markdown)

Final Squash Stub (plaintext) (Must differ from #1)

Extended Technical Manifest (plaintext)

Review Conversation Starter (markdown)

## 4.1 Thread Transition (Reset / Archive Rule)
- Append a THREAD END entry to the TASK.md Work Log at completion.
- Ensure the next session begins with a fresh OPEN artifact and matching dump artifacts.

## 5. Work Log (Timestamped Continuity)
2026-02-10 19:00 - THREAD START: DP-OPS-0046. Seed: Pointer-first agent constitution refinement. Base HEAD: 46a04806. Verification: NOT RUN. Blockers: none. NEXT: Execute 3.4 and capture RESULTS.
2026-02-11 03:41 - THREAD END: DP-OPS-0046. Outcome: Pointer-first constitution refined; llms bundles refreshed. Verification: COMPLETE. Blockers: none. NEXT: Await new DP.
