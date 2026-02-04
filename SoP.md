Archive policy: keep most recent 30 entries; older entries moved to `storage/archives/root/SoP-archive-YYYY-MM.md`.

## 2026-02-04 - DP-OPS-0021: Project Binary Interface & Dynamic Context

- Purpose: Establish the Project Binary interface and dynamic context bundles for Phase 3 specialization.
- What shipped:
  - Refactored ops/bin/llms to read Small and Full bundles from the manifest and added profile slicing.
  - Added `--agent` and `--include` handling in ops/bin/open for persona and project context injection.
  - Implemented ops/bin/project with updated registry helpers and manifest.
  - Updated ops/lib/project/STELA.md and added CONTRIBUTORY.md; tightened AGENTS and CONTEXT headings.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
  - `bash ops/bin/prune`
  - `./ops/bin/llms --out-dir=storage/handoff`
- Risk / rollback:
  - Risk: Low (tooling and templates only).
  - Rollback: revert `AGENTS.md`, `CONTRIBUTORY.md`, `ops/bin/llms`, `ops/bin/open`, `ops/bin/project`, `ops/lib/scripts/project.sh`, `ops/lib/manifests/CONTEXT.md`, `ops/lib/manifests/PROJECTS.md`, `ops/lib/project/STELA.md`, and `SoP.md`.

## 2026-02-04 - DP-OPS-0020: Phase Two Doctrine (Truth, Hygiene, Style)

- Purpose: Compress canon, add pruning and bundling automation, and enforce uniform style.
- What shipped:
  - Refactored TRUTH.md and AGENTS.md into axiomatic, compressed canon.
  - Updated TASK.md headings to decimal format and added closeout checks for prune and llms.
  - Added ops/bin/prune for SoP sliding window archiving and handoff cleanup.
  - Added ops/bin/llms and generated llms-small.txt and llms-full.txt bundles.
  - Added markdownlint configuration and style and llms lint scripts.
  - Updated llms.txt and recorded governance changes.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
  - `bash tools/lint/style.sh`
  - `bash tools/lint/llms.sh`
  - `bash ops/bin/prune`
- Risk / rollback:
  - Risk: Low (governance and automation updates only).
  - Rollback: revert `TRUTH.md`, `AGENTS.md`, `TASK.md`, `SoP.md`, `llms.txt`, `.markdownlint.json`, `ops/bin/prune`, `ops/bin/llms`, `tools/lint/llms.sh`, `tools/lint/style.sh`, `llms-small.txt`, and `llms-full.txt`.


## 2026-02-04 — DP-OPS-0019: Context Hazard Guardrails

- Purpose: Strengthen context doctrine and guardrails to keep library directories out of the global manifest.
- What shipped:
  - Defined Context Hazard in TRUTH and marked library directories as JIT-only.
  - Added Context Hygiene directive in AGENTS to enforce hazard exclusion from the manifest.
  - Added negative constraints to docs/CONTEXT and hardened context to fail on library hazards.
  - Updated TASK work log and recorded governance update in SoP.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
- Risk / rollback:
  - Risk: Low (governance and lint guard updates only).
  - Rollback: revert `TRUTH.md`, `AGENTS.md`, `docs/CONTEXT.md`, `tools/lint/context.sh`, and `SoP.md`.

## 2026-02-04 — DP-OPS-0018: Proposal Protocol and Drafting Friction Reduction

- Purpose: Reduce DP drafting deadlocks by allowing provisional branch and Base HEAD proposals while preserving worker git authority.
- What shipped:
  - Updated TASK template to allow Integrator-assigned or Integrator-proposed (Operator-created) work branch labeling and to allow Base HEAD to be `Not provided` or `Current (draft; lock at merge)` during drafting, with a drafting note on finalization and worker stop rules.
  - Added Drafting Proposal Protocol in AGENTS to permit Integrator proposals, require `PROPOSED:` prefixes during drafting, and reaffirm Operator-provided finalization and contractor branch limits.
  - Added zero-byte dump verification in TASK receipt and clarified Mandatory Closing Block checklist wording.
- Verification:
  - `bash tools/verify.sh`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
  - `bash tools/lint/dp.sh --test`
  - `./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle`
- Risk / rollback:
  - Risk: Low (governance text updates only).
  - Rollback: revert `TASK.md`, `AGENTS.md`, and `SoP.md`.

## 2026-02-03 — DP-OPS-0016: Hardened TASK.md (context hygiene + mandatory closing block)

- Purpose: Harden TASK worker context boundaries, receipt discipline, and closeout metadata structure.
- What shipped:
  - Removed OPEN from worker context load instructions and added the Integrator-only OPEN rule plus disposable artifact prohibition.
  - Expanded receipt checklist to require OPEN, OPEN-PORCELAIN, and dump artifacts with explicit failure conditions.
  - Added the Mandatory Closing Block with six distinct commit and PR metadata fields.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
- Risk / rollback:
  - Risk: Low (governance text updates only).
  - Rollback: revert `TASK.md` and `SoP.md`.

## 2026-02-02 — DP-OPS-0015: Skills System Final Hardening and Consolidation

- Purpose: Consolidate S-LEARN-08 into S-LEARN-06 and harden S-LEARN-06 and S-LEARN-07 with Trap and Solution patterns plus concrete commands.
- What shipped:
  - Moved Advanced Git Forensics to S-LEARN-06 and removed S-LEARN-08.
  - Rewrote S-LEARN-06 and S-LEARN-07 with mandated Trap and Solution guidance and concrete command checks.
  - Updated docs/library/INDEX.md to register S-LEARN-06 and refresh the S-LEARN-07 title.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
  - `bash tools/lint/library.sh`
  - `bash tools/verify.sh` (PASS with 3 warnings: storage/archives, storage/documentation, storage/ToDo)
- Risk / rollback:
  - Risk: Low (documentation and registry updates).
  - Rollback: revert `docs/library/skills/S-LEARN-06.md`, `docs/library/skills/S-LEARN-07.md`, `docs/library/INDEX.md`, and `SoP.md`.

## 2026-02-02 — DP-OPS-0014: Skills System Hardening and Polishing

- Purpose: Harden S-LEARN-01 through S-LEARN-05 with Stela stack concrete specs and enforce receipt bundle mandate in TASK.
- What shipped:
  - Rewrote S-LEARN-01 through S-LEARN-05 with stack-specific commands, traps, and isolation rules.
  - Defined Zenith envelope and hook contract plus coding and security standards for the Next.js/FastAPI/Supabase stack.
  - Updated TASK proof bundle checklist with automatic disapproval mandate.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
  - `bash tools/lint/library.sh`
  - `bash tools/verify.sh` (PASS with 3 warnings: storage/archives, storage/documentation, storage/ToDo)
- Risk / rollback:
  - Risk: Low (documentation-only skill and TASK updates).
  - Rollback: revert `docs/library/skills/S-LEARN-01.md` through `docs/library/skills/S-LEARN-05.md`, `TASK.md`, and `SoP.md`.

## 2026-02-02 — DP-OPS-0013: Legacy Skill Refactor (Museum Provenance)

- Purpose: Refactor legacy skills S-LEARN-01 through S-LEARN-05 to align with the S-LEARN-07 template and add Museum Provenance.
- What shipped:
  - Updated S-LEARN-01 through S-LEARN-05 with Museum Provenance and Friction Context.
  - Standardized headers and procedure structure to match S-LEARN-07 and rewrote guidance with Trap/Solution specificity.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
- Risk / rollback:
  - Risk: Low (documentation-only skill refactor).
  - Rollback: revert `docs/library/skills/S-LEARN-01.md` through `docs/library/skills/S-LEARN-05.md` and `SoP.md`.

## 2026-02-01 — DP-OPS-0012: Autonomous Skill Heuristics and Provenance Engine (Phase 2)

- Purpose: Upgrade the Skills Subsystem with heuristics-driven provenance, semantic drift guard, and the harvest lifecycle refinements.
- What shipped:
  - Added `ops/lib/scripts/heuristics.sh` to analyze git diff and churn for provenance.
  - Updated `ops/lib/scripts/skill.sh` to source heuristics, enforce semantic collision checks, and auto-generate provenance.
  - Updated `SKILL.md`, `TASK.md`, and `AGENTS.md` to document Phase 2 workflow and constraints.
  - Updated `docs/library/skills/S-LEARN-07.md` with heuristics-aware guidance.
  - Added `docs/library/skills/S-LEARN-08.md` and registered it in `docs/library/INDEX.md`.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
  - `bash tools/lint/library.sh`
  - `bash tools/verify.sh`
  - `bash ops/lib/scripts/skill.sh check`
- Risk / rollback:
  - Risk: Medium (new heuristics engine and workflow changes).
  - Rollback: revert `ops/lib/scripts/heuristics.sh`, `ops/lib/scripts/skill.sh`, `SKILL.md`, `TASK.md`, `AGENTS.md`, `docs/library/skills/S-LEARN-07.md`, `docs/library/skills/S-LEARN-08.md`, `docs/library/INDEX.md`, and `SoP.md`.

## 2026-02-01 — DP-OPS-0011: Autonomous Skill Harvesting Engine

- Purpose: Upgrade the skill harvesting workflow with provenance capture, draft promotion, and Skills Context Hazard enforcement.
- What shipped:
  - Refactored `ops/lib/scripts/skill.sh` with harvest/promote/check subcommands, provenance capture, draft handling, collision-safe ID allocation (including `SKILL.md`), and context hazard enforcement.
  - Documented the harvest workflow and promotion log in `SKILL.md`.
  - Updated `TASK.md`, `AGENTS.md`, and `docs/library/MANUAL.md` to document the workflow and closeout responsibilities.
  - Added `docs/library/skills/S-LEARN-07.md` and registered it in `docs/library/INDEX.md`.
- Verification:
  - `./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
  - `bash tools/lint/library.sh`
  - `bash tools/verify.sh`
  - `bash tools/lint/dp.sh --test`
- Risk / rollback:
  - Risk: Medium (new skill workflow automation and canon updates).
  - Rollback: revert `ops/lib/scripts/skill.sh`, `SKILL.md`, `TASK.md`, `AGENTS.md`, `docs/library/MANUAL.md`, `docs/library/INDEX.md`, `docs/library/skills/S-LEARN-07.md`, and `SoP.md`.

## 2026-01-31 — DP-OPS-0010: Skills subsystem and skill capture

- Purpose: Establish a Skills subsystem for production payload work with explicit Context Hazard and a worker-run capture step.
- What shipped:
  - Added `SKILL.md` as the promotion template for creating new S-LEARN-XX skills, including Context Hazard rules, candidate log, and promotion packet template.
  - Added `docs/library/skills` with S-LEARN-01 through S-LEARN-05 for on-demand production payload guidance.
  - Added `ops/lib/scripts/skill.sh` to append candidate entries and matching Promotion Packets to `SKILL.md`.
  - Updated `TASK.md` to require worker-run skill capture during normal DP processing, including allowlist and RESULTS proof rules.
  - Updated `docs/library/INDEX.md` to register Skills artifacts for Library Guard.
  - Recorded the Context Hazard decision to keep Skills out of `ops/lib/manifests/CONTEXT.md`.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
  - `bash tools/lint/library.sh`
  - `bash tools/verify.sh`
  - `bash tools/lint/dp.sh --test`
- Risk / rollback:
  - Risk: Medium (new workflow and capture utility).
  - Rollback: revert `SKILL.md`, `docs/library/skills/`, `ops/lib/scripts/skill.sh`, `docs/library/INDEX.md`, `TASK.md`, and `SoP.md`.

## 2026-01-31 — DP-OPS-0009: DP output code-fence rule

- Purpose: Require DP drafts to be fully fenced in chat to improve readability/discoverability and reduce formatting drift.
- What shipped:
  - Added a single formatting rule line in the TASK DP template requiring full fenced code block enclosure for DP emissions.
  - Logged the governance/template change in SoP per canon-change policy.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/lint/context.sh`
  - `bash tools/lint/truth.sh`
- Risk / rollback:
  - Risk: Low (TASK template line + SoP entry).
  - Rollback: revert `TASK.md` and `SoP.md`.

## 2026-01-29 — DP-OPS-FIX-01: TASK heading sync + authoring-time artifacts removal

- Purpose: Align TASK Section III heading format and remove the authoring-time artifacts block to reduce dp friction.
- What shipped:
  - Confirmed Section III heading is a single line (`## III. EXECUTION PLAN (A–E CANON)`).
  - Removed the authoring-time artifacts block from Section I required context.
  - Added a scope lock: when canon/governance surfaces change, `SoP.md` must be in the allowlist and updated.
  - Required a RESULTS Status block with Scope summary, Tracked change, and Verification bullets.
  - Added DP-OPS-FIX-01 receipt and refreshed OPEN and dump artifacts.
- Verification:
  - `grep -n "## III. EXECUTION PLAN" TASK.md`
  - `git status --porcelain`
  - `git diff --name-only`
  - `git diff --stat`
  - `git diff`
- Risk / rollback:
  - Risk: Low (TASK-only adjustment plus receipt artifacts).
  - Rollback: revert `TASK.md`, `storage/handoff/DP-OPS-FIX-01-RESULTS.md`, and updated OPEN and dump artifacts.

## 2026-01-27 — DP-OPS-0004: SoP prune + archives museum + context lint alignment

- Purpose: Prune SoP to a recent window, preserve history in an untracked museum, and align lint behavior for historical references.
- What shipped:
  - Moved older SoP entries into `storage/archives/root/SoP-archive-2026-01-27.md` (untracked museum).
  - Trimmed SoP to the most recent 30 entries and added an archive policy pointer.
  - Updated `tools/lint/context.sh` to skip SoP historical path enforcement.
- Verification:
  - `bash tools/lint/context.sh`
  - Result: `[context] Result: clean`
- Risk / rollback:
  - Risk: Low (log + lint alignment only).
  - Rollback: restore SoP from archive and revert lint edits.

## 2026-01-27 — DP-OPS-0005: TASK hardening (worker git authority + dump-as-command + real Work Log + task gate + DP lint sync)

- Purpose: Harden TASK + gates for worker git authority, dump-as-command, and real Work Log discipline.
- What shipped:
  - Updated `TASK.md` DP template (freshness gate wording, worker git authority block, dump-as-command phrasing, Work Log expectation + example).
  - Synced `tools/lint/dp.sh` to TASK headings and broadened lint field parsing for DP suffixes/parenthetical labels and in-scope format.
  - Added TASK policing in `.github` (`sop_policing.yml` update + new `task_policing.yml`).
- Verification:
  - `bash tools/lint/dp.sh storage/handoff/DP-OPS-0005_v2.md`
  - Result: `OK: DP lint passed`
  - `bash tools/lint/context.sh`
  - Result: `[context] Result: warnings detected` (missing paths referenced in `SoP.md`).
- Risk / rollback:
  - Risk: Low (process/gate updates only).
  - Rollback: revert `TASK.md`, `tools/lint/dp.sh`, `.github/workflows/sop_policing.yml`, `.github/workflows/task_policing.yml`, and `SoP.md`.
