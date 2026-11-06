<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Research Corpus (Clusters and Outcomes)

## 0. Scope
This catalog covers the 156 research reports under `opt/_research/` (2208 pages). They were generated as research-model reports, exported from Google Docs, between 2025-11 and 2026-02, against repository dumps of that time, and they name packets DP-OPS-0001 to DP-OPS-0165. They describe plans; many plans landed in another form, and some did not land. Each cluster below ends with one paragraph on what current main does, with the surfaces that hold the outcome. Per-paper status is not recorded here; residents may add it by packet.

Records are binary and isolated: PoT 1.1 names `opt/` as JIT-only content excluded from global context, `ops/lib/scripts/traverse.sh` skips binary files, no lint reads PDF content, and `tools/verify.sh` admits the directory as a records class (`*.pdf`, `SHA256SUMS`, `README.md`; DP-OPS-0268). A record is `opt/_research/<slug>.pdf`, where the slug is the lowercase hyphenated title; `opt/_research/SHA256SUMS` carries one digest per record. Titles below are the reports' own titles. Two titles contain a term that `tools/lint/truth.sh` forbids in authored surfaces; the catalog shows `[forbidden term]` in its place, and the record and its file name keep the original.

| Cluster | Reports | Pages |
|---|---|---|
| 1. Origins and doctrine | 9 | 129 |
| 2. Skills and persistent mastery | 12 | 170 |
| 3. Tasks subsystem and task governance | 19 | 303 |
| 4. Context engine and session workflow | 8 | 102 |
| 5. Project factory and the projects lane | 16 | 264 |
| 6. Policy of Truth as constitution | 9 | 124 |
| 7. Flat truth and unitary jurisdiction | 8 | 124 |
| 8. Agents subsystem and operational stances | 10 | 152 |
| 9. TASK.md as the active work surface | 24 | 308 |
| 10. Ledgers and distributed leafing | 12 | 164 |
| 11. Filing doctrine, case normalization, and the ops kernel | 6 | 77 |
| 12. Certification and the System Locked Protocol | 14 | 175 |
| 13. Explainability and canonical density | 5 | 73 |
| 14. Outside comparisons and analyst instructions | 4 | 43 |
| Total | 156 | 2208 |

## 1. Origins and doctrine
These reports argued for a repository that governs its own agents: an anti-drift doctrine, a constitution above the code, a filing doctrine that separates run, explain, isolate, work, and payload, and finally a reset for a lifecycle that had grown heavier than the work it carried. Current main keeps the doctrine and dropped the early names. `PoT.md` is the single constitution (Preamble; 1.3 Axioms: SSOT, separation, durability, reuse-first, drift, routing); `TRUTH.md` and `AGENTS.md` no longer exist, and `docs/GOVERNANCE.md` is a pointer to PoT. The filing doctrine is PoT 1.1 with eight zones. The platform is its own repository: `projects/` holds a README and 0 projects, and the content-management payload the papers call the host is not here. `tools/lint/truth.sh` rejects six misspellings of the platform name and two legacy phrases for a mutable canon; `tools/lint/style.sh` rejects contractions and nine jargon terms. The reset proposal did not land as a reset; the lifecycle it attacked is now the Collab-Mode procedure in `docs/MANUAL.md`.

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `ai-drift-doctrine-for-repositories.pdf` | AI Drift Doctrine for Repositories | 15 | none |
| `stela-system-refactoring-plan.pdf` | Stela System Refactoring Plan | 10 | none |
| `stela-system-refactoring-plan-2.pdf` | Stela System Refactoring Plan 2 | 12 | none |
| `refactoring-stela-system-architecture.pdf` | Refactoring Stela System Architecture | 15 | none |
| `stela-agent-constitution-and-drift-prevention.pdf` | Stela Agent Constitution & Drift Prevention | 17 | 0000, 0019 |
| `doctrine-phase-two-truth-hygiene-style.pdf` | Doctrine Phase Two Truth, Hygiene, Style | 14 | 0001, 0009, 0018, 0020 |
| `stela-agent-constitution-and-doctrine-integration.pdf` | Stela Agent Constitution & Doctrine Integration | 17 | 0017, 0019, 0020 |
| `stela-agent-constitution-discussion-2.pdf` | Stela Agent Constitution Discussion 2 | 13 | 0017, 0020, 0021 |
| `stila-reset-simplification-and-strategy.pdf` | [forbidden term] Reset Simplification and Strategy | 16 | 0001, 0050 |

## 2. Skills and persistent mastery
The skills reports wanted a persistent-mastery layer: harvested skills crystallized at closeout, a provenance engine, a context-isolated library, and one evaluation of a stateful memory model against the stateless doctrine. Current main holds skills in the factory: `opt/_factory/SKILLS.md` is the pointer head, `ops/src/definitions/skill.md.tpl` the template, `ops/bin/factory` the draft-and-promote binary (`docs/MANUAL.md`, Skills: Harvest + Promote), `tools/lint/skill.sh` the content lint, `docs/ops/registry/skills.md` the registry, and `docs/ops/specs/definitions/skills.md` the head-chain spec. The registry reports 0 active skill definitions. Automatic harvesting at closeout did not land; promotion is an operator-run step that leaves evidence under `archives/definitions/`. Stateful memory was not adopted: `docs/CONTEXT.md` states that context is file-defined state, not memory.

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `architectural-refactoring-report-persistent-mastery-integration-and-project-registry-consolidation.pdf` | Architectural Refactoring Report Persistent Mastery Integration and Project Registry Consolidation | 9 | 0009, 0010, 0011 |
| `ai-agent-constitution-and-task-drafting.pdf` | AI Agent Constitution and Task Drafting | 15 | 0009, 0010, 0011, 0012 |
| `skill-and-project-initialization-plan.pdf` | Skill and Project Initialization Plan | 15 | 0010, 0011 |
| `skill-invocation-and-platform-drift-prevention.pdf` | Skill Invocation and Platform Drift Prevention | 14 | 0010 |
| `refactoring-project-and-skill-structures.pdf` | Refactoring Project and Skill Structures | 13 | 0010 |
| `enhancing-stela-skills-subsystem.pdf` | Enhancing Stela Skills Subsystem | 22 | 0011, 0012 |
| `skill-harvesting-automation-strategy.pdf` | Skill Harvesting Automation Strategy | 13 | none |
| `stela-skills-enhancement-dispatch-packet.pdf` | Stela Skills Enhancement Dispatch Packet | 17 | 0010, 0011, 0012 |
| `stela-dispatch-packet-generation.pdf` | Stela Dispatch Packet Generation | 14 | 0000, 0011, 0012 |
| `stela-skills-enhancement-analysis-and-reconciliation.pdf` | Stela Skills Enhancement Analysis and Reconciliation | 13 | 0010, 0011, 0012, 0013, 0014 |
| `stela-skills-system-overhaul.pdf` | Stela Skills System Overhaul | 13 | none |
| `stela-memory-integration-strategy.pdf` | Stela Memory Integration Strategy | 12 | none |

## 3. Tasks subsystem and task governance
These reports standardized tasks under uppercase identifiers, designed the task registry, ported a legacy task library, and then refactored task governance toward pointer-first definitions. Current main treats tasks as factory definitions with the same lifecycle as skills: `opt/_factory/TASKS.md`, `ops/src/definitions/task.md.tpl`, `ops/bin/factory`, `tools/lint/task.sh`, `docs/ops/registry/tasks.md`, and `docs/ops/specs/definitions/tasks.md`. The lint checks registry alignment, provenance fields, pointer existence, ambiguous language in execution steps, and closeout pointers (`docs/DESIGN.md` 4). The registry reports 0 active task definitions; the uppercase identifier scheme was retired by the lowercase migration (cluster 11); the import directory that the porting report describes does not exist.

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `stela-dp-ops-0016-task-standardization.pdf` | Stela DP-OPS-0016 Task Standardization | 18 | 0016, 0017, 0018 |
| `stela-dp-ops-0016-task-standardization-2.pdf` | Stela DP-OPS-0016 Task Standardization 2 | 18 | 0016, 0017, 0018 |
| `stela-platform-task-standardization-draft.pdf` | Stela Platform Task Standardization Draft | 19 | 0000, 0016, 0017, 0018 |
| `stela-task-standardization-dp-draft.pdf` | Stela Task Standardization DP Draft | 19 | 0000, 0016, 0017, 0018 |
| `task-registry-design-and-dp-ops-0016.pdf` | Task Registry Design and DP-OPS-0016 | 14 | 0016 |
| `task-md-update-for-dispatch-packets.pdf` | Task.md Update for Dispatch Packets | 14 | 0016 |
| `refine-tasks-and-plan-agents.pdf` | Refine Tasks and Plan Agents | 21 | 0016, 0017, 0018 |
| `stela-task-constitution-development.pdf` | Stela Task Constitution Development | 13 | 0031 |
| `stela-task-constitution-development-2.pdf` | Stela Task Constitution Development 2 | 16 | 0031 |
| `stela-task-import-and-porting-strategy.pdf` | Stela Task Import and Porting Strategy | 22 | 0036 |
| `stela-task-system-analysis-and-improvement.pdf` | Stela Task System Analysis and Improvement | 16 | 0029, 0036 |
| `stela-task-governance-refactor-discussion.pdf` | Stela Task Governance Refactor Discussion | 12 | 0037, 0038 |
| `stela-task-governance-refactoring-dp.pdf` | Stela Task Governance Refactoring DP | 16 | 0000, 0038 |
| `drafting-stela-dispatch-packet-dp-ops-0037.pdf` | Drafting Stela Dispatch Packet DP-OPS-0037 | 20 | 0000, 0037 |
| `agent-constitution-analysis-and-improvement.pdf` | Agent Constitution Analysis and Improvement | 14 | none |
| `agent-constitution-analysis-and-improvement-2.pdf` | Agent Constitution Analysis and Improvement 2 | 19 | none |
| `pointer-first-agent-constitution-for-stela-architectural-analysis-and-governance-report-v2.pdf` | Pointer-First Agent Constitution for Stela Architectural Analysis and Governance Report (v2) | 12 | 0038, 0039 |
| `ai-agent-constitution-and-task-refinement.pdf` | AI Agent Constitution and Task Refinement | 12 | 0038, 0039 |
| `prompt-file-and-dp-38-review.pdf` | Prompt File and DP 38 Review | 8 | 0038 |

## 4. Context engine and session workflow
These reports designed the context bundle generator, tiered `llms` artifacts, prompt customization in `ops/bin/open`, a unified context engine, and the Context-by-Construction workflow that replaced prompt engineering with generated packets. Current main: `ops/bin/llms` compiles `llms-core.txt` from `ops/lib/manifests/CORE.md` and `llms-full.txt` from `ops/lib/manifests/DISCOVERY.md` and refreshes `llms.txt`; `ops/bin/context` streams `ops/lib/manifests/OPS.md` with OPEN state; `ops/lib/scripts/synthesize.sh` is the single engine for manifest parsing, hazard enforcement, and emission (`docs/CONTEXT.md`). `tools/lint/context.sh` keeps factory paths out of the manifest and `tools/lint/llms.sh` enforces bundle parity at the commit boundary. `ops/bin/open` takes `--intent`, `--dp`, `--tag`, and `--format=chatgpt`. The CbC workflow is `ops/bin/draft` with slot sidecars (`docs/MANUAL.md`, DP Draft), governed by `docs/DESIGN.md`.

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `agent-constitution-and-dispatch-packet-2.pdf` | Agent Constitution and Dispatch Packet 2 | 7 | 0000, 0005, 0017 |
| `stela-context-analysis-and-recommendations.pdf` | Stela Context Analysis and Recommendations | 13 | 0035 |
| `unifying-llm-context-and-operations.pdf` | Unifying LLM Context and Operations | 11 | 0035, 0057 |
| `drafting-dp-ops-0059-unifying-llm-context.pdf` | Drafting DP-OPS-0059 Unifying LLM Context | 16 | 0051, 0054, 0057, 0059 |
| `stelas-llms-full-txt-integration-analysis.pdf` | Stela's llms-full.txt Integration Analysis | 13 | none |
| `prompt-customization-for-operator-workflow.pdf` | Prompt Customization for Operator Workflow | 14 | 0038, 0039, 0040 |
| `clarifying-dp-production-workflow.pdf` | Clarifying DP Production Workflow | 15 | none |
| `prompt-workflow-and-output-enhancements.pdf` | Prompt Workflow and Output Enhancements | 13 | none |

## 5. Project factory and the projects lane
The Phase 3 and Phase 4 reports described an autopoietic project factory: a project binary that manufactures and verifies payloads, a library trinity, and a projects namespace with a workflow of its own. Current main keeps the lane and not the factory. `projects/README.md` and `ops/lib/project/README.md` give the lifecycle (scaffold, `STELA.md`, registry row, `./ops/bin/map`, `./ops/bin/bundle --profile=project`); `ops/bin/project` was retired in DP-OPS-0145 and `ops/bin/scaffold` provisions trees from `ops/lib/project/SCAFFOLD.md`; `docs/ops/registry/projects.md` lists 0 projects and `docs/MAP.md` reports none discovered. PoT 1.1 names `projects/` as Work, and `docs/MAP.md` 5 (Unified Jurisdiction) states that projects are payloads under PoT and not a separate tier, which closes the question the last report in this cluster raised.

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `ai-agent-constitution-review.pdf` | AI Agent Constitution Review | 13 | 0022, 0023 |
| `ai-agent-constitution-and-dp-drafting.pdf` | AI Agent Constitution and DP Drafting | 20 | 0021, 0022 |
| `agent-constitution-refinement-and-dp-drafting.pdf` | Agent Constitution Refinement and DP Drafting | 20 | 0000, 0021, 0022 |
| `agent-constitution-refinement-and-dp-drafting-2.pdf` | Agent Constitution Refinement and DP Drafting 2 | 19 | 0000, 0021, 0022 |
| `refining-agent-constitution-and-dp-ops-0022.pdf` | Refining Agent Constitution and DP-OPS-0022 | 16 | 0000, 0021, 0022 |
| `reverting-drift-and-refining-agent-constitution.pdf` | Reverting Drift and Refining Agent Constitution | 15 | 0000, 0021, 0022 |
| `stela-agent-constitution-refinement-3.pdf` | Stela Agent Constitution Refinement 3 | 15 | 0000, 0021, 0022, 0023 |
| `stela-agent-constitution-refinement-4.pdf` | Stela Agent Constitution Refinement 4 | 15 | 0000, 0020, 0021, 0022 |
| `stela-agent-constitution-refinement-5.pdf` | Stela Agent Constitution Refinement 5 | 14 | 0000, 0020, 0021, 0022 |
| `stela-agent-constitution-refinement-discussion.pdf` | Stela Agent Constitution Refinement Discussion | 15 | 0021, 0022 |
| `drafting-dispatch-packet-dp-ops-0023.pdf` | Drafting Dispatch Packet DP-OPS-0023 | 14 | 0010, 0019, 0020, 0022, 0023 |
| `ai-agent-constitution-review-and-dp-drafting.pdf` | AI Agent Constitution Review and DP Drafting | 17 | 0000, 0022, 0023, 0024 |
| `drafting-stela-ai-dispatch-packet.pdf` | Drafting Stela AI Dispatch Packet | 18 | 0000, 0005, 0013, 0026, 0027 |
| `stela-ai-constitution-dp-ops-0026-analysis.pdf` | Stela AI Constitution DP-OPS-0026 Analysis | 18 | 0013, 0026, 0027 |
| `stela-ai-constitution-dispatch-packet-generation.pdf` | Stela AI Constitution Dispatch Packet Generation | 20 | 0000, 0024, 0025, 0026 |
| `unifying-project-and-crown-workflows.pdf` | Unifying Project and [forbidden term] Workflows | 15 | none |

## 6. Policy of Truth as constitution
These reports proposed the Policy of Truth as the successor to the first constitution, audited its implementation sequence (DP-OPS-0061 to DP-OPS-0066), and argued for prevention over policing. Current main: `PoT.md` is 122 lines in five sections: physical laws, enforcement with STOP WORK triggers and actions, staffing (Operator, Integrator, Contractor, Auditor, with repository access in 3.2), security policy, and workflow (`agent/*` branches, dispatch packets, packet hash failure). Correct-by-Construction is doctrine in `docs/DESIGN.md` (five checkpoint questions, a complexity budget, a retrospective audit of sixteen tools) and record in `docs/ops/registry/decisions.md`, with leaves under `archives/decisions/` written by `ops/bin/decision`. The epistemic standard these reports cite as section 4.5 is PoT 3.4.

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `ai-constitution-and-truth-policy-consolidation.pdf` | AI Constitution and Truth Policy Consolidation | 15 | 0022, 0023, 0024, 0025 |
| `ai-constitution-and-dispatch-packet-draft.pdf` | AI Constitution and Dispatch Packet Draft | 20 | 0000, 0022, 0023, 0024, 0025 |
| `stela-ai-constitution-review.pdf` | Stela AI Constitution Review | 13 | 0024, 0025, 0026 |
| `policy-of-truth-analysis-and-strategy.pdf` | Policy of Truth Analysis and Strategy | 13 | 0059, 0074, 0087 |
| `policy-of-truth-governance-and-documentation.pdf` | Policy of Truth Governance and Documentation | 13 | 0061, 0062 |
| `policy-of-truth-implementation-plan.pdf` | Policy of Truth Implementation Plan | 15 | 0063, 0064 |
| `policy-of-truth-rollout-review.pdf` | Policy of Truth Rollout Review | 12 | 0063, 0064, 0065 |
| `architectural-audit-policy-of-truth-implementation-dp-ops-0063-dp-ops-0065.pdf` | Architectural Audit Policy of Truth Implementation (DP-OPS-0063 #U2013 DP-OPS-0065) | 9 | 0063, 0064, 0065, 0066 |
| `system-hardening-and-self-awareness-proposal.pdf` | System Hardening and Self-Awareness Proposal | 14 | 0063, 0064, 0065, 0066 |

## 7. Flat truth and unitary jurisdiction
After an integrity failure that the reports call a malicious model infection, these papers replaced a two-tier jurisdiction with one flat authority and drafted the packets that re-established it (DP-OPS-0027 to DP-OPS-0032). Current main: the PoT Preamble states that PoT is the final authority across every scope and that no parallel jurisdiction exists; `docs/MAP.md` 5 restates it for `ops/`, `docs/`, `opt/`, and `projects/`. The vocabulary of the two-tier model is on the forbidden list in `tools/lint/truth.sh`, so it cannot re-enter an authored surface. The role set is the four roles of PoT 3.1, and `llms.txt` is the discovery entry point that the DP-OPS-0030 audit checked.

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `stela-agent-constitution-discussion.pdf` | Stela Agent Constitution Discussion | 12 | 0027 |
| `stela-agent-constitution-dp-draft.pdf` | Stela Agent Constitution DP Draft | 14 | 0000, 0025, 0027, 0028 |
| `stela-agent-constitution-update.pdf` | Stela Agent Constitution Update | 19 | 0000, 0025, 0027, 0028 |
| `stela-agent-constitution-and-dp-draft.pdf` | Stela Agent Constitution and DP Draft | 18 | 0025, 0026, 0027 |
| `stela-agent-constitution-audit.pdf` | Stela Agent Constitution Audit | 10 | 0029, 0030 |
| `stela-dp-ops-000030-drafting.pdf` | Stela DP-OPS-000030 Drafting | 15 | 000030, 0020, 0030 |
| `agent-constitution-and-dispatch-packet.pdf` | Agent Constitution and Dispatch Packet | 21 | 0000, 0029, 0031 |
| `analyzing-dp-drafting-and-governance.pdf` | Analyzing DP Drafting and Governance | 15 | 0031, 0032 |

## 8. Agents subsystem and operational stances
These reports built the agent subsystem (agent cards, registry federation, an immunological hardening protocol, certification of the harvester) and defined operational stances for prompts. Current main: four agent cards live in `opt/_factory/agents/` (`r-agent-10` to `r-agent-13`) under the `opt/_factory/AGENTS.md` head with a promotion leaf in `archives/definitions/`; `tools/lint/agent.sh` validates registry alignment, provenance, pointers, and hazard patterns, `tools/test/agent.sh` exercises promotion, and `docs/ops/registry/agents.md` with `docs/ops/specs/definitions/agents.md` records them. Stances are templates: `ops/src/stances/planning.md.tpl`, `draft.md.tpl`, `audit.md.tpl`, and `addenda.md.tpl` with `ops/src/shared/stances.json`, rendered by `ops/bin/bundle` profiles and specified under `docs/ops/specs/stances/`. The instruction texts the Operator deploys to external models are runbook adapters under `ops/src/runbook/` (DP-OPS-0267).

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `agent-system-upgrade-plan.pdf` | Agent System Upgrade Plan | 24 | 0010, 0012, 0015, 0029 |
| `agent-system-upgrade-dispatch-packet.pdf` | Agent System Upgrade Dispatch Packet | 13 | 0010, 0012, 0029 |
| `agents-subsystem-validation-discussion.pdf` | Agents Subsystem Validation Discussion | 20 | 0029 |
| `agent-registry-refactor-and-testing.pdf` | Agent Registry Refactor and Testing | 16 | 0014, 0033 |
| `agent-system-hardening-dispatch-packet.pdf` | Agent System Hardening Dispatch Packet | 14 | 0010, 0031, 0034 |
| `agent-system-update-strategy-discussion.pdf` | Agent System Update Strategy Discussion | 14 | none |
| `prompt-management-in-stela-system.pdf` | Prompt Management in Stela System | 14 | 0029 |
| `agent-system-certification-and-harvester-hardening.pdf` | Agent System Certification and Harvester Hardening | 12 | 0038, 0039, 0041, 0042 |
| `ai-agent-constitution-and-task-dispatch.pdf` | AI Agent Constitution and Task Dispatch | 10 | 0036, 0039, 0041, 0043 |
| `ai-agent-constitution-and-task-execution.pdf` | AI Agent Constitution and Task Execution | 15 | 0041, 0042, 0043, 0044 |

## 9. TASK.md as the active work surface
The largest cluster. These reports reconstructed a lost `TASK.md`, hardened it against session sediment, defined statelessness as a constraint, named ghost canon, and moved the surface from narrative to pointers (DP-OPS-0039 to DP-OPS-0061). Current main: `TASK.md` is a one-line pointer to the current leaf under `archives/surfaces/`; the leaf carries Routing State and Packet State, and PoT 1.4 defines what it holds while routing is active and while it is idle. The body is generated: `ops/bin/draft` renders `ops/src/surfaces/dp.md.tpl` from a slots sidecar, `tools/lint/dp.sh` verifies the template SHA-256 and the normalized structure hash, and PoT 5.3 forbids hand-authored structural boilerplate. Scope is a contract: section 3.4.3 lists exact paths, `ops/bin/allowlist` and `tools/lint/integrity.sh` compare them with the tree, and `ops/bin/certify` returns routing to idle. `ops/bin/prune` scrubs session residue. Total explainability landed as a spec per executable under `docs/ops/specs/`: 24 binary specs, 18 lint specs, 12 script specs, and 7 test specs for 9 test executables (the runtime inventory report in `tools/test/inventory.sh` records the two without rows).

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `reconstructing-lost-task-md-sections.pdf` | Reconstructing Lost TASK.md Sections | 12 | 0039, 0044 |
| `task-md-analysis-and-refinement.pdf` | TASK.md Analysis and Refinement | 14 | 0039, 0042 |
| `optimizing-task-md-for-llm-instruction-following.pdf` | Optimizing TASK.md for LLM Instruction Following | 17 | 0043, 0044 |
| `task-md-enforcement-proposal.pdf` | TASK.md Enforcement Proposal | 12 | 0044 |
| `reconstructing-task-md-dispatch-packet.pdf` | Reconstructing TASK.md Dispatch Packet | 19 | 0040, 0041, 0042, 0043, 0044, 0045 |
| `dp-ops-0045-reconstructing-and-perfecting-task-md.pdf` | DP-OPS-0045 Reconstructing and Perfecting TASK.md | 7 | 0045, 0046 |
| `drafting-dispatch-packet-dp-ops-0046.pdf` | Drafting Dispatch Packet DP-OPS-0046 | 14 | 0043, 0044, 0045, 0046 |
| `harden-task-md-and-prune-logic.pdf` | Harden Task.md and Prune Logic | 15 | 0046 |
| `restore-task-md-enforce-worker-exploitation.pdf` | Restore Task.md, Enforce Worker Exploitation | 12 | 0045, 0047, 0048 |
| `structuring-and-locking-down-task-md.pdf` | Structuring and Locking Down TASK.md | 18 | 0048 |
| `task-md-reform-for-ai-compatibility.pdf` | TASK.md Reform for AI Compatibility | 17 | 0048 |
| `architectural-reformation-of-task-md-stateless-governance-surface-hardened.pdf` | Architectural Reformation of TASK.md Stateless Governance Surface (Hardened) | 7 | 0048 |
| `system-metabolism-fixes-implementation.pdf` | System Metabolism Fixes Implementation | 14 | 0048 |
| `task-and-documentation-updates.pdf` | Task and Documentation Updates | 13 | 0048 |
| `remediation-proposal-for-task-md.pdf` | Remediation Proposal for TASK.md | 15 | 0033, 0037, 0038, 0039, 0042, 0046, 0051 |
| `stela-agent-constitution-refinement.pdf` | Stela Agent Constitution Refinement | 13 | 0050, 0051 |
| `task-md-remediation-verification.pdf` | TASK.md Remediation Verification | 12 | 0047, 0050, 0051, 0052 |
| `task-md-entropy-and-policing-solutions.pdf` | TASK.md Entropy and Policing Solutions | 14 | 0050, 0051, 0054, 0055, 0056, 0058 |
| `proposal-for-system-hardening-pointer-first-constitution-and-operational-equilibrium-v2.pdf` | Proposal for System Hardening Pointer-First Constitution and Operational Equilibrium (v2) | 11 | none |
| `stela-agent-constitution-refinement-2.pdf` | Stela Agent Constitution Refinement 2 | 12 | none |
| `refining-task-subsystem-and-documentation.pdf` | Refining Task Subsystem and Documentation | 13 | 0056 |
| `pointer-first-agent-constitution-and-operational-certification-of-the-stela-repository.pdf` | Pointer-First Agent Constitution and Operational Certification of the Stela Repository | 6 | 0056 |
| `pointer-first-agent-constitution-and-operational-certification-of-the-stela-repository-2.pdf` | Pointer-First Agent Constitution and Operational Certification of the Stela Repository 2 | 8 | 0035, 0047, 0051, 0054, 0055, 0056 |
| `debugging-task-md-dp-template-issue.pdf` | Debugging TASK.md DP Template Issue | 13 | 0061 |

## 10. Ledgers and distributed leafing
These reports moved the ledgers from monolithic `SoP.md` and `PoW.md` files to a distributed index-leaf model with immutable leaves, a unified logging plan, a proof-first PoW, and the four-cycle failure of the first leafing deployment (DP-OPS-0074). Current main runs on that model. `SoP.md`, `PoW.md`, `TASK.md`, and `RoR.md` are one-line heads; leaves live under `archives/surfaces/` (SoP, PoW, TASK, RESULTS; 660 tracked) and `archives/decisions/` (RoR; 48 tracked) with YAML frontmatter and a `previous` chain, written by `ops/lib/scripts/ledger.sh` and `ops/bin/certify` and validated by `tools/lint/schema.sh`. Factory ledgers are leaves too (`archives/definitions/`, 16 tracked). Telemetry is `emit_binary_leaf` from `ops/lib/scripts/common.sh` into `logs/`, read by `ops/bin/trace` (`docs/MANUAL.md`, Trace Cookbook); `tools/lint/leaf.sh` checks that every binary and tool is wired. Compile snapshots are leaves under `archives/manifests/` (489 tracked).

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `task-template-archival-and-pow-ledger.pdf` | TASK Template Archival and PoW Ledger | 14 | none |
| `task-structure-hardening-and-pow-integrity.pdf` | TASK Structure Hardening and PoW Integrity | 13 | 0060, 0061 |
| `unified-logging-system-integration-plan.pdf` | Unified Logging System Integration Plan | 12 | none |
| `refactoring-ops-kernel-for-new-architecture.pdf` | Refactoring Ops Kernel For New Architecture | 14 | none |
| `policy-of-truth-refactoring.pdf` | Policy of Truth Refactoring | 13 | none |
| `integrating-reporting-in-distributed-filing.pdf` | Integrating Reporting in Distributed Filing | 15 | 0069 |
| `phase-3-planning-distributed-filing-paradigm.pdf` | Phase 3 Planning Distributed Filing Paradigm | 11 | 0068, 0069, 0070, 0071, 0072 |
| `phase-3-deployment-plan-formulation.pdf` | Phase 3 Deployment Plan Formulation | 15 | 0072, 0073 |
| `factory-ledger-leafing-remediation-plan.pdf` | Factory Ledger Leafing Remediation Plan | 12 | 0072, 0073, 0074 |
| `system-failure-and-recovery-plan.pdf` | System Failure and Recovery Plan | 13 | 0068, 0070, 0073, 0074 |
| `ai-protocol-remediation-strategy.pdf` | AI Protocol Remediation Strategy | 16 | 0036, 0037, 0038, 0039, 0040, 0042, 0045, 0047, 0051, 0055, 0059, 0060, 0061, 0065, 0067, 0068, 0069, 0070, 0071, 0073, 0074, 0075 |
| `ai-protocol-and-remediation-strategy.pdf` | AI Protocol and Remediation Strategy | 16 | 0036, 0038, 0042, 0047, 0058, 0060, 0064, 0068, 0069, 0071, 0073, 0074, 0075 |

## 11. Filing doctrine, case normalization, and the ops kernel
These reports introduced the four-zone split of runtime state (payload, scratch, telemetry, cold archives), the rule that root canon is uppercase and operational files are lowercase, the one-off lowercase migration of registry surfaces and identifiers (DP-OPS-0069), and a 12 percent code-reduction target for an overloaded `ops/` directory. Current main: PoT 1.1 lists `storage/`, `var/tmp/`, `logs/`, and `archives/` as zones with distinct roles; registries are lowercase under `docs/ops/registry/` and `tools/lint/truth.sh` fails on the ten legacy uppercase registry paths; agent identifiers are lowercase; root canon stays uppercase (`PoT.md`, `SoP.md`, `PoW.md`, `TASK.md`, `RoR.md`). `ops/bin/` holds 23 binaries, `ops/lib/scripts/` 12 shared scripts, `tools/lint/` 18 lints, and `tools/test/` 9 tests, each with a registry row or an inventory line. `tools/verify.sh` enforces the directory layout. No current tool measures the code-reduction target.

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `repository-structure-and-doctrine-update.pdf` | Repository Structure and Doctrine Update | 17 | 0068 |
| `ops-code-refactoring-strategy.pdf` | Ops Code Refactoring Strategy | 11 | 0068 |
| `lowercase-migration-and-manifest-update.pdf` | Lowercase Migration and Manifest Update | 18 | 0069 |
| `file-renaming-and-id-migration.pdf` | File Renaming and ID Migration | 14 | 0068, 0069 |
| `strategic-assessment-constitutional-filing-doctrine-and-lower-case-standardization.pdf` | Strategic Assessment Constitutional Filing Doctrine & Lower Case Standardization | 5 | none |
| `stela-tool-ecosystem-refactoring-strategy.pdf` | Stela Tool Ecosystem Refactoring Strategy | 12 | none |

## 12. Certification and the System Locked Protocol
These reports designed template-based certification (the System Locked Protocol), analyzed malformed packets from two models, proposed certified-state generation to stop drafting against a stale base, and asked for a chain-of-thought ledger as a root surface. Current main: certification is `ops/bin/certify`, which replays the receipt commands of section 3.4.5, writes the RESULTS leaf, snapshots SoP and PoW, completes the TASK leaf, and returns routing to idle (`docs/MAP.md` 5; `docs/MANUAL.md`, Closeout Cycle); `tools/lint/results.sh` validates the receipt and `ops/bin/bundle --profile=audit` packages it. Drafting is template-locked through `ops/src/surfaces/dp.md.tpl` with hash coupling, and `docs/MANUAL.md` gives the recovery. Certified-state generation landed as the rule that `ops/bin/draft` allocates the next packet id from the current certified TASK packet id plus one, with PoT 5.3 requiring a state refresh before execution. Addenda are a bounded lane through `ops/bin/addendum`. The gates workflow (`.github/workflows/gates.yml`, specified in `docs/ops/specs/workflows/gates.md`) runs on every pull request and on every push to main. A root chain-of-thought ledger did not land; the execution-decision runbook lane (`ops/src/runbook/execution-decision.yaml`) is the disposable placement for that output.

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `debugging-malformed-dispatch-packets.pdf` | Debugging Malformed Dispatch Packets | 11 | 0065, 0066 |
| `system-locked-protocol-technical-specification-for-template-based-certification.pdf` | System Locked Protocol Technical Specification for Template-Based Certification | 7 | 0067 |
| `process-integrity-and-contractor-execution.pdf` | Process Integrity and Contractor Execution | 18 | 0068 |
| `system-locked-protocol-certification-and-dispatch-packet-process-analysis-dp-ops-0069.pdf` | System Locked Protocol Certification and Dispatch Packet Process Analysis DP-OPS-0069 | 8 | 0068, 0069 |
| `system-locked-protocol-certification-and-dispatch-packet-process-analysis-dp-ops-0069-2.pdf` | System Locked Protocol Certification and Dispatch Packet Process Analysis DP-OPS-0069 2 | 11 | 0068, 0069 |
| `dp-certification-system-improvement-strategy.pdf` | DP Certification System Improvement Strategy | 17 | 0068, 0069 |
| `ai-deployment-protocol-and-strategy.pdf` | AI Deployment Protocol and Strategy | 15 | 0069, 0082, 0083, 0084 |
| `policy-of-truth-governance-framework.pdf` | Policy of Truth Governance Framework | 13 | 0074, 0075, 0082, 0088, 0097, 0101, 0105 |
| `policy-of-truth-governance-protocol.pdf` | Policy of Truth Governance Protocol | 13 | 0082, 0088, 0101 |
| `policy-of-truth-governance-protocol-2.pdf` | Policy of Truth Governance Protocol 2 | 11 | 0038, 0039, 0040, 0043, 0044, 0069, 0075, 0081, 0082, 0083, 0088, 0107 |
| `stela-governance-policy-of-truth.pdf` | Stela Governance Policy of Truth | 15 | 0107, 0108 |
| `ai-dp-drafting-malformation-analysis.pdf` | AI DP Drafting Malformation Analysis | 11 | 0107, 0108, 0109, 0110 |
| `dispatch-packet-execution-plan-formulation.pdf` | Dispatch Packet Execution Plan Formulation | 14 | 0111, 0121 |
| `ai-workflow-protocol-refinement.pdf` | AI Workflow Protocol Refinement | 11 | 0118 |

## 13. Explainability and canonical density
These reports asked for Feynman-grade explanation, mathematical text compression, their synthesis as Calibrated Canonical Density, and complete specification coverage. Current main: `docs/CCD.md` defines CCD as a declared density contract; every tracked markdown file outside the exempt classes opens with a CCD header that names a target and a band, and `tools/lint/ff.sh` scores the file and fails when the score leaves the band by more than ten points. The fifth-grader rewrite did not land as prose; the density contract and the specification coverage did (cluster 9).

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `feynman-inspired-stela-documentation-refactor.pdf` | Feynman-Inspired Stela Documentation Refactor | 18 | 0074 |
| `stela-documentation-refactor-strategy.pdf` | Stela Documentation Refactor Strategy | 15 | 0087 |
| `stela-policy-and-deployment-strategy.pdf` | Stela Policy and Deployment Strategy | 15 | none |
| `stela-policy-and-deployment-strategy-synthesis.pdf` | Stela Policy and Deployment Strategy Synthesis | 13 | 0065, 0074, 0087 |
| `stela-pot-documentation-enhancement-plan.pdf` | Stela PoT Documentation Enhancement Plan | 12 | 0074, 0077, 0078, 0079, 0082, 0083, 0084, 0085, 0086 |

## 14. Outside comparisons and analyst instructions
Two comparisons set the platform against other agentic systems, and two define the analyst role that produced most of this corpus. Current main: the Contractor holds end-to-end git and GitHub access and the Integrator and Auditor are read-only (PoT 3.2, DP-OPS-0263); the analyst stance is `ops/src/stances/planning.md.tpl`, rendered by `ops/bin/bundle --profile=planning`; the research adapter the Operator runs outside the repository is `ops/src/runbook/gemini.yaml` (RUNBOOK-03, `docs/ops/specs/runbook/gemini.md`). The current State of Play lists handing research output repository authority among the rejected directions; this corpus is filed under that rule, as records and not as canon.

| Record | Title | Pages | DP-OPS packets named |
|---|---|---|---|
| `refining-ai-research-artifact-grounding.pdf` | Refining AI Research Artifact Grounding | 14 | none |
| `worker-git-action-authority-conflict.pdf` | Worker Git Action Authority Conflict | 12 | none |
| `refined-stela-analyst-instructions.pdf` | Refined STELA Analyst Instructions | 1 | none |
| `stela-analyst-artifact-analysis.pdf` | STELA Analyst Artifact Analysis | 16 | 0069, 0074, 0080, 0083, 0088, 0107, 0115, 0118, 0130, 0146, 0151, 0156, 0165 |

## 15. Not landed
The Operator's upload held 159 files. Three were not platform research and were excluded; 0 bytes of them are in the repository. Extracted text is not landed: text under `opt/` would be scanned by `tools/lint/truth.sh`, `tools/lint/style.sh`, and `tools/lint/ff.sh`, and exemptions there are a separate decision.
