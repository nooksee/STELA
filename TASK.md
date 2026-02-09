# STELA TASK DASHBOARD (LIVING SURFACE)
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-09

## 1. Session State (The Anchor)
Pointer: storage/handoff/OPEN-*.txt (The generated session context)
Active Branch: work/governance-hardening-0038b (Must match OPEN artifact)
Base HEAD: a80d295e9 (Must match OPEN artifact)
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
DP-OPS-0038: Pointer-First Agent Constitution and Task Governance Refactor

### 3.1 Scope Boundary
Objective: Transition Stela to a pointer-first agent constitution by removing ghost canon, refactoring TASK.md into a deterministic dashboard, and hardening the ops toolchain to enforce the Filing Doctrine.
Allowlist (Hard Gate):
- .github/workflows/sop_policing.yml
- .github/copilot-instructions.md
- docs/GOVERNANCE.md
- ops/bin/open
- tools/lint/style.sh
- tools/lint/dp.sh
- tools/verify.sh
- TASK.md
- SoP.md

Stop Condition: Any edit outside the Allowlist is a system failure. STOP immediately.

### 3.2 Execution Plan
1. Context Load: Verify OPEN artifact matches git branch and HEAD.
2. Registry Cleanse: Replace TRUTH.md with PoT.md and align read-in order to docs/MAP.md.
3. Task Refactor: Replace TASK.md with the pointer-first schema and update session state automation.
4. Toolchain Alignment: Enforce contraction checks, filing doctrine checks, and DP structure checks.
5. Verification and Receipt: Run required gates, generate dump, and capture RESULTS.

### 3.3 Skill Integration
Harvest and promote via ops/lib/scripts/skill.sh.
Constraint: Do not edit docs/library/SKILLS.md manually.

## 4. Closeout (Mandatory)
Requirement: Populate storage/handoff/DP-OPS-0038-RESULTS.md and append the following block.

### Mandatory Closing Block
Constraint: Final Squash Stub must differ significantly from Primary Commit Header.
1. Primary Commit Header: DP-OPS-0038 pointer-first task dashboard and toolchain enforcement
2. Pull Request Title: DP-OPS-0038 pointer-first task governance refactor
3. Pull Request Description:
### Summary
- Replaced TRUTH.md references with PoT.md in CI and Copilot guidance.
- Refactored TASK.md to a pointer-first dashboard with session state automation.
- Tightened style, verify, and DP lint gates.
- Simplified docs/GOVERNANCE.md into PoT pointers.

### Testing
- bash tools/lint/style.sh
- bash tools/verify.sh
- bash tools/lint/context.sh
- bash tools/lint/truth.sh
- bash tools/lint/dp.sh --test
4. Final Squash Stub: Refactor TASK governance and enforcement tooling for pointer-first ops
5. Extended Technical Manifest:
.github/workflows/sop_policing.yml
.github/copilot-instructions.md
docs/GOVERNANCE.md
ops/bin/open
tools/lint/style.sh
tools/verify.sh
tools/lint/dp.sh
TASK.md
SoP.md
6. Review Conversation Starter:
Does the pointer-first TASK dashboard and toolchain enforcement match the Refactoring Strategy Section 5.1 expectations?

## 5. Work Log (Timestamped Continuity)
2026-02-08 16:30 - THREAD START: DP-OPS-0038. Seed: Pointer-First Constitution Refactor (Ghost Canon elimination, TASK schema replacement, Toolchain hardening).
2026-02-08 16:35 - DP-OPS-0038: Defined work branch work/constitution-refactor-0038 and Base HEAD eccc11128. Prepared for dispatch. NEXT: Execute DP-OPS-0038.
2026-02-09 00:20 - DP-OPS-0038: Replaced ghost canon references, refactored TASK.md to the pointer-first dashboard, and hardened toolchain enforcement. Verification: RUN (style lint, verify, context lint, truth lint, dp lint test, dump). Blockers: ops/bin/llms not run due to allowlist scope. NEXT: Operator review DP-OPS-0038 results.
2026-02-09 15:07 - DP-OPS-0038B: Added PoT read-in order and system failure states, exempted TASK.md dirty-state, updated dp lint to decimal-only, and logged SoP entry. Verification: RUN (tools/lint/context.sh, tools/lint/truth.sh, tools/verify.sh, ops/bin/dump, tools/lint/dp.sh --test). NOT RUN: ops/bin/llms (allowlist excludes llms bundles). Blockers: ops/bin/llms deferred pending scope approval. NEXT: Operator review RESULTS and decide on llms refresh scope.
2026-02-09 15:13 - DP-OPS-0038B: Expanded scope to refresh llms bundles via ops/bin/llms. Verification: RUN (ops/bin/llms). Blockers: none. NEXT: Operator review updated RESULTS.
