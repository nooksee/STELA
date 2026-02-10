# STELA TASK DASHBOARD (LIVING SURFACE)
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-10

## 1. Session State (The Anchor)
Pointer: storage/handoff/OPEN-*.txt (The generated session context)
Active Branch: work/agent-system-certification-0042 (Must match OPEN artifact)
Base HEAD: 5b51900d (Must match OPEN artifact)
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
DP-OPS-0042: Agent System Certification and Harvester Hardening

### 3.1 Scope Boundary
Objective: Certify the Agent subsystem as pointer-first and serviceable by aligning R-AGENT-01 through R-AGENT-06, synchronizing the agent registry and promotion ledger, and hardening enforcement tooling and the agent harvester logic so that low-frequency role emergence can be detected via Pattern Density (tool-and-pointer cluster recurrence).
Allowlist (Hard Gate):
- ops/lib/scripts/agent.sh
- ops/lib/scripts/heuristics.sh
- tools/lint/agent.sh
- docs/library/AGENTS.md
- docs/ops/registry/AGENTS.md
- docs/library/agents/R-AGENT-01.md
- docs/library/agents/R-AGENT-02.md
- docs/library/agents/R-AGENT-03.md
- docs/library/agents/R-AGENT-04.md
- docs/library/agents/R-AGENT-05.md
- docs/library/agents/R-AGENT-06.md
- ops/bin/llms
- llms.txt
- llms-small.txt
- llms-full.txt
- llms-ops.txt
- llms-governance.txt
- TASK.md
- SoP.md

Stop Condition: Any edit outside the Allowlist is a system failure. STOP immediately.

### 3.2 Execution Plan
1. Preflight and branch discipline: run ops/bin/open, confirm work branch on base head, and avoid main edits.
2. Harvester hardening: implement Pattern Density, deterministic harvest-check output, collision avoidance, and archives alignment in ops/lib/scripts/agent.sh and ops/lib/scripts/heuristics.sh.
3. Linter hardening: enforce agent schema, provenance fields, pointer validation, and context hazard rejection in tools/lint/agent.sh.
4. Recertification and registry sync: update R-AGENT-01 through R-AGENT-06, docs/library/AGENTS.md, and docs/ops/registry/AGENTS.md for DP-OPS-0042.
5. Verification and receipt: run required gates, generate dump bundle, refresh llms bundles, and record RESULTS, SoP, and Work Log entries.

### 3.3 Skill Integration
Use ops/lib/scripts/skill.sh only when a new skill candidate is required; do not edit docs/library/SKILLS.md manually.

## 4. Closeout (Mandatory)
Requirement: Populate storage/handoff/DP-OPS-0042-RESULTS.md and append the following block.

### Mandatory Closing Block
Constraint: Final Squash Stub must differ significantly from Primary Commit Header.
1. Primary Commit Header: DP-OPS-0042 agent system certification and harvester hardening
2. Pull Request Title: DP-OPS-0042 Agent System Certification and Harvester Hardening
3. Pull Request Description:

### Summary
- Hardened `ops/lib/scripts/agent.sh` with Pattern Density heuristics for low-frequency agent candidacy detection.
- Tightened `tools/lint/agent.sh` to enforce strict agent schema and context hazard rejection.
- Recertified `R-AGENT-01` through `R-AGENT-06` and synchronized `docs/ops/registry/AGENTS.md`.
- Refreshed llms bundles via `ops/bin/llms` after enforcement and canon surface updates.

### Testing
- bash tools/lint/style.sh
- bash tools/lint/agent.sh
- bash tools/lint/library.sh
- bash tools/lint/context.sh
- bash tools/lint/truth.sh
- bash tools/verify.sh
- ops/lib/scripts/agent.sh check
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- ./ops/bin/llms

4. Final Squash Stub: Enforce agent certification gates and harden role emergence harvesting logic
5. Extended Technical Manifest:
- ops/lib/scripts/agent.sh
- ops/lib/scripts/heuristics.sh
- tools/lint/agent.sh
- docs/library/AGENTS.md
- docs/ops/registry/AGENTS.md
- docs/library/agents/R-AGENT-01.md
- docs/library/agents/R-AGENT-02.md
- docs/library/agents/R-AGENT-03.md
- docs/library/agents/R-AGENT-04.md
- docs/library/agents/R-AGENT-05.md
- docs/library/agents/R-AGENT-06.md
- llms.txt
- llms-small.txt
- llms-full.txt
- llms-ops.txt
- llms-governance.txt
- TASK.md
- SoP.md
6. Review Conversation Starter:
Does the Pattern Density heuristic in the agent harvester correctly balance low emergence frequency with rigorous capture, while avoiding semantic collisions with existing canon agents?

## 5. Work Log (Timestamped Continuity)
2026-02-08 16:30 - THREAD START: DP-OPS-0038. Seed: Pointer-First Constitution Refactor (Ghost Canon elimination, TASK schema replacement, Toolchain hardening).
2026-02-08 16:35 - DP-OPS-0038: Defined work branch work/constitution-refactor-0038 and Base HEAD eccc11128. Prepared for dispatch. NEXT: Execute DP-OPS-0038.
2026-02-09 00:20 - DP-OPS-0038: Replaced ghost canon references, refactored TASK.md to the pointer-first dashboard, and hardened toolchain enforcement. Verification: RUN (style lint, verify, context lint, truth lint, dp lint test, dump). Blockers: ops/bin/llms not run due to allowlist scope. NEXT: Operator review DP-OPS-0038 results.
2026-02-09 15:07 - DP-OPS-0038B: Added PoT read-in order and system failure states, exempted TASK.md dirty-state, updated dp lint to decimal-only, and logged SoP entry. Verification: RUN (tools/lint/context.sh, tools/lint/truth.sh, tools/verify.sh, ops/bin/dump, tools/lint/dp.sh --test). NOT RUN: ops/bin/llms (allowlist excludes llms bundles). Blockers: ops/bin/llms deferred pending scope approval. NEXT: Operator review RESULTS and decide on llms refresh scope.
2026-02-09 15:13 - DP-OPS-0038B: Expanded scope to refresh llms bundles via ops/bin/llms. Verification: RUN (ops/bin/llms). Blockers: none. NEXT: Operator review updated RESULTS.
2026-02-10 16:36 - THREAD START: DP-OPS-0042. Seed: Agent System Certification and Harvester Hardening (Pattern Density emergence, linter tightening, recertification, registry sync, llms refresh). Base HEAD: 5b51900d.
2026-02-10 16:52 - THREAD END: DP-OPS-0042. Verification: RUN (bash tools/lint/style.sh, bash tools/lint/agent.sh, bash tools/lint/library.sh, bash tools/lint/context.sh, bash tools/lint/truth.sh, bash tools/verify.sh, ops/lib/scripts/agent.sh check, ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle, ./ops/bin/llms).
