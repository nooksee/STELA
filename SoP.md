Archive policy: keep most recent 30 entries; older entries moved to `storage/archives/root/SoP-archive-2026-01-27.md`.

## 2026-01-31 — DP-OPS-0010: Skills subsystem and skill capture

- Purpose: Establish a Skills subsystem for production payload work with explicit Context Hazard and a worker-run capture step.
- What shipped:
  - Added `SKILL.md` as the promotion template for creating new S-LEARN-XX skills, including Context Hazard rules, candidate log, and promotion packet template.
  - Added `docs/library/skills` with S-LEARN-01 through S-LEARN-05 for on-demand production payload guidance.
  - Added `ops/lib/skill/skill_lib.sh` to append candidate entries and matching Promotion Packets to `SKILL.md`.
  - Updated `TASK.md` to require worker-run skill capture during normal DP processing, including allowlist and RESULTS proof rules.
  - Updated `docs/library/INDEX.md` to register Skills artifacts for Library Guard.
  - Recorded the Context Hazard decision to keep Skills out of `ops/lib/manifests/CONTEXT.md`.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
  - `bash tools/lint_library.sh`
  - `bash tools/verify_tree.sh`
  - `bash tools/dp_lint.sh --test`
- Risk / rollback:
  - Risk: Medium (new workflow and capture utility).
  - Rollback: revert `SKILL.md`, `docs/library/skills/`, `ops/lib/skill/skill_lib.sh`, `docs/library/INDEX.md`, `TASK.md`, and `SoP.md`.

## 2026-01-31 — DP-OPS-0009: DP output code-fence rule

- Purpose: Require DP drafts to be fully fenced in chat to improve readability/discoverability and reduce formatting drift.
- What shipped:
  - Added a single formatting rule line in the TASK DP template requiring full fenced code block enclosure for DP emissions.
  - Logged the governance/template change in SoP per canon-change policy.
- Verification:
  - `./ops/bin/dump --scope=platform`
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
- Risk / rollback:
  - Risk: Low (TASK template line + SoP entry).
  - Rollback: revert `TASK.md` and `SoP.md`.

## 2026-01-29 — DP-OPS-FIX-01: TASK heading sync + authoring-time artifacts removal

- Purpose: Align TASK Section III heading format and remove the authoring-time artifacts block to reduce dp_lint friction.
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
  - Updated `tools/context_lint.sh` to skip SoP historical path enforcement.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
- Risk / rollback:
  - Risk: Low (log + lint alignment only).
  - Rollback: restore SoP from archive and revert lint edits.

## 2026-01-27 — DP-OPS-0005: TASK hardening (worker git authority + dump-as-command + real Work Log + task gate + DP lint sync)

- Purpose: Harden TASK + gates for worker git authority, dump-as-command, and real Work Log discipline.
- What shipped:
  - Updated `TASK.md` DP template (freshness gate wording, worker git authority block, dump-as-command phrasing, Work Log expectation + example).
  - Synced `tools/dp_lint.sh` to TASK headings and broadened lint field parsing for DP suffixes/parenthetical labels and in-scope format.
  - Added TASK policing in `.github` (`sop_policing.yml` update + new `task_policing.yml`).
- Verification:
  - `bash tools/dp_lint.sh storage/handoff/DP-OPS-0005_v2.md`
  - Result: `OK: DP lint passed`
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: warnings detected` (missing paths referenced in `SoP.md`).
- Risk / rollback:
  - Risk: Low (process/gate updates only).
  - Rollback: revert `TASK.md`, `tools/dp_lint.sh`, `.github/workflows/sop_policing.yml`, `.github/workflows/task_policing.yml`, and `SoP.md`.
