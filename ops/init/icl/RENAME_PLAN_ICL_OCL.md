# ICL/OCL Rename Plan (Draft)

## Purpose
Plan a ban-term purge by renaming boot_pack/cockpit/resurrection terms and updating references. No renames executed in this slice.

## Proposed canonical renames (from -> to)
Directory
- `ops/init/icl/boot_pack/` -> `ops/init/icl/launch_pack/`

Files with banned terms in names
- `ops/init/icl/boot_pack/RESURRECTION.md` -> `ops/init/icl/launch_pack/RECOVERY.md`
- `ops/init/icl/boot_pack/DAILY_COCKPIT.md` -> `ops/init/icl/launch_pack/DAILY_CONSOLE.md`
- `docs/ops/RESURRECTION.md` -> `docs/ops/RECOVERY.md` (pointer stub rename)
- `docs/ops/DAILY_COCKPIT.md` -> `docs/ops/DAILY_CONSOLE.md` (pointer stub rename)

Files that keep their base names (dir rename only; content update for banned terms)
- `ops/init/icl/boot_pack/AI_CONTEXT_SYNC.md` -> `ops/init/icl/launch_pack/AI_CONTEXT_SYNC.md`
- `ops/init/icl/boot_pack/CONTEXT_PACK.md` -> `ops/init/icl/launch_pack/CONTEXT_PACK.md`
- `ops/init/icl/boot_pack/COPILOT_ONBOARDING.md` -> `ops/init/icl/launch_pack/COPILOT_ONBOARDING.md`
- `ops/init/icl/boot_pack/GEMINI_ONBOARDING.md` -> `ops/init/icl/launch_pack/GEMINI_ONBOARDING.md`
- `ops/init/icl/boot_pack/IDE_MIGRATION.md` -> `ops/init/icl/launch_pack/IDE_MIGRATION.md`

## Term replacements (content)
- `boot pack` / `bootpack` / `boot_pack` -> `launch pack` / `launchpack` / `launch_pack`
- `Daily Cockpit` / `Truth Cockpit` / `cockpit` -> `Daily Console` / `Truth Console` / `console`
- `Resurrection` / `resurrection` -> `Recovery` / `recovery`
- `Lazarus Pit` -> `Recovery Pit`
- `Preflight` -> `Precheck`
- `bootstrap` -> `initial setup`

## Link update checklist
Docs pointers and indexes
- `docs/00-INDEX.md`
- `docs/10-QUICKSTART.md`
- `docs/30-RELEASE_PROCESS.md`
- `docs/CONTRACTOR_PACKET.md`
- `docs/LESSONS_LEARNED.md`
- `docs/PROJECT_STRUCTURE.md`
- `docs/README_CONTEXT.md`
- `docs/REPO_LAYOUT.md`
- `docs/SOP_MULTICHAT.md`
- `docs/ops/INDEX.md`
- `docs/ops/AI_CONTEXT_SYNC.md`
- `docs/ops/CONTEXT_PACK.md`
- `docs/ops/COPILOT_ONBOARDING.md`
- `docs/ops/DAILY_COCKPIT.md` (rename)
- `docs/ops/GEMINI_ONBOARDING.md`
- `docs/ops/IDE_MIGRATION.md`
- `docs/ops/RESURRECTION.md` (rename)

Ops canon references
- `ops/init/icl/ACTIVE_CONTEXT.md`
- `ops/init/icl/context_pack.json`
- `ops/init/icl/boot_pack/AI_CONTEXT_SYNC.md`
- `ops/init/icl/boot_pack/CONTEXT_PACK.md`
- `ops/init/icl/boot_pack/COPILOT_ONBOARDING.md`
- `ops/init/icl/boot_pack/DAILY_COCKPIT.md` (rename)
- `ops/init/icl/boot_pack/GEMINI_ONBOARDING.md`
- `ops/init/icl/boot_pack/IDE_MIGRATION.md`
- `ops/init/icl/boot_pack/README.md`
- `ops/init/icl/boot_pack/RESURRECTION.md` (rename)
- `ops/init/icl/boot_pack/principles.md`
- `ops/init/protocols/SAVE_THIS_PROTOCOL.md`

Repo maps (update if rename executes)
- `PROJECT_MAP.md`
- `CANONICAL_TREE.md`
