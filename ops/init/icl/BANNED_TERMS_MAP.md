# Banned Terms Map

## Scope
- Source: `rg -ni "resurrection|resurrect|bootpack|boot_pack|boot-pack|boot|cockpit|flight|aviation|zombie|rebirth|lazarus" -g "*.md" ops docs`
- Scope: ops/** and docs/** markdown files (non-runtime), plus context_pack.json and STATE_OF_PLAY.md entries where terms are referenced.

## Legend
- Action values: rename word (text/link update), rename file (file/directory rename), delete file (remove doc).

## No hits in initial scan (excluding this inventory/plan docs)
- aviation
- zombie
- rebirth
- resurrect (standalone)
- boot-pack

| Term | File path |  Line excerpt  | Proposed replacement | Action |
| --- | --- |  ---  | --- | --- |
| boot_pack | docs/00-INDEX.md | - [../ops/init/icl/boot_pack/DAILY_COCKPIT.md](../ops/init/icl/boot_pack/DAILY_COCKPIT.md) | `../ops/init/icl/launch_pack/DAILY_CONSOLE.md` | rename word |
| resurrection | docs/00-INDEX.md | - [../ops/init/icl/boot_pack/RESURRECTION.md](../ops/init/icl/boot_pack/RESURRECTION.md) | `../ops/init/icl/launch_pack/RECOVERY.md` | rename word |
| boot_pack | docs/10-QUICKSTART.md | 5) `ops/init/icl/boot_pack/DAILY_COCKPIT.md` | `ops/init/icl/launch_pack/DAILY_CONSOLE.md` | rename word |
| boot | docs/10-QUICKSTART.md | - `ops/` = ICL/OCL canon (protocols, contracts, templates, boot pack) | replace `boot pack` -> `launch pack` | rename word |
| boot_pack | docs/10-QUICKSTART.md | - `ops/init/icl/boot_pack/` = rehydration + bootpacks (portable context bundles) | update path to `ops/init/icl/launch_pack/` | rename word |
| bootpack | docs/10-QUICKSTART.md | - `ops/init/icl/boot_pack/` = rehydration + bootpacks (portable context bundles) | replace `bootpacks` -> `launch packs` | rename word |
| boot_pack | docs/30-RELEASE_PROCESS.md | - `ops/init/icl/boot_pack/` — bootpack / context pack needed to operate the repo safely | update path to `ops/init/icl/launch_pack/` | rename word |
| bootpack | docs/30-RELEASE_PROCESS.md | - `ops/init/icl/boot_pack/` — bootpack / context pack needed to operate the repo safely | replace `bootpack` -> `launchpack` | rename word |
| boot_pack | docs/CONTRACTOR_PACKET.md | - `ops/init/icl/boot_pack/DAILY_COCKPIT.md` | `ops/init/icl/launch_pack/DAILY_CONSOLE.md` | rename word |
| boot | docs/LESSONS_LEARNED.md | - **Structure beats memory:** docs + boot pack are the source of continuity, not the chat. | replace `boot pack` -> `launch pack` | rename word |
| boot_pack | docs/ops/AI_CONTEXT_SYNC.md | Canonical version: `ops/init/icl/boot_pack/AI_CONTEXT_SYNC.md`. | `ops/init/icl/launch_pack/AI_CONTEXT_SYNC.md` | rename word |
| boot_pack | docs/ops/CONTEXT_PACK.md | Canonical version: `ops/init/icl/boot_pack/CONTEXT_PACK.md`. | `ops/init/icl/launch_pack/CONTEXT_PACK.md` | rename word |
| boot_pack | docs/ops/COPILOT_ONBOARDING.md | Canonical version: `ops/init/icl/boot_pack/COPILOT_ONBOARDING.md`. | `ops/init/icl/launch_pack/COPILOT_ONBOARDING.md` | rename word |
| cockpit | docs/ops/DAILY_COCKPIT.md | # Daily Cockpit (moved) | `# Daily Console (moved)` | rename file |
| boot_pack | docs/ops/DAILY_COCKPIT.md | Canonical version: `ops/init/icl/boot_pack/DAILY_COCKPIT.md`. | `ops/init/icl/launch_pack/DAILY_CONSOLE.md` | rename word |
| boot_pack | docs/ops/GEMINI_ONBOARDING.md | Canonical version: `ops/init/icl/boot_pack/GEMINI_ONBOARDING.md`. | `ops/init/icl/launch_pack/GEMINI_ONBOARDING.md` | rename word |
| boot_pack | docs/ops/IDE_MIGRATION.md | Canonical version: `ops/init/icl/boot_pack/IDE_MIGRATION.md`. | `ops/init/icl/launch_pack/IDE_MIGRATION.md` | rename word |
| cockpit | docs/ops/INDEX.md | - [Daily Cockpit](../../ops/init/icl/boot_pack/DAILY_COCKPIT.md) | `Daily Console` + `../../ops/init/icl/launch_pack/DAILY_CONSOLE.md` | rename word |
| resurrection | docs/ops/INDEX.md | - [Resurrection](../../ops/init/icl/boot_pack/RESURRECTION.md) | `Recovery` + `../../ops/init/icl/launch_pack/RECOVERY.md` | rename word |
| boot_pack | docs/ops/INDEX.md | - [Context Pack](../../ops/init/icl/boot_pack/CONTEXT_PACK.md) | update all `boot_pack` links to `launch_pack` | rename word |
| resurrection | docs/ops/RESURRECTION.md | # Resurrection kit (moved) | `# Recovery kit (moved)` | rename file |
| boot_pack | docs/ops/RESURRECTION.md | Canonical version: `ops/init/icl/boot_pack/RESURRECTION.md`. | `ops/init/icl/launch_pack/RECOVERY.md` | rename word |
| boot | docs/PROJECT_STRUCTURE.md | - `ops/` - ICL/OCL canon (protocols, contracts, templates, boot pack); non-runtime. | replace `boot pack` -> `launch pack` | rename word |
| boot_pack | docs/README_CONTEXT.md | The rest of the pack lives alongside it in `ops/init/icl/boot_pack/`. | update path to `ops/init/icl/launch_pack/` | rename word |
| resurrection | docs/README_CONTEXT.md | Keep `ops/init/icl/boot_pack/RESURRECTION.md` aligned with current workflow and repo-gates. | `ops/init/icl/launch_pack/RECOVERY.md` | rename word |
| boot | docs/REPO_LAYOUT.md | - Ops canon: `ops/` (ICL/OCL doctrine, protocols, contracts, templates, boot pack under `ops/init/icl/boot_pack/`). | replace `boot pack` -> `launch pack` | rename word |
| boot_pack | docs/REPO_LAYOUT.md | - Ops canon: `ops/` (ICL/OCL doctrine, protocols, contracts, templates, boot pack under `ops/init/icl/boot_pack/`). | update path to `ops/init/icl/launch_pack/` | rename word |
| boot | docs/REPO_LAYOUT.md | - `ops/` - ICL/OCL canon (protocols, contracts, templates, boot pack); non-runtime. | replace `boot pack` -> `launch pack` | rename word |
| boot_pack | docs/SOP_MULTICHAT.md | 2) `upstream/` and `ops/init/icl/boot_pack/` are read-only. | update path to `ops/init/icl/launch_pack/` | rename word |
| boot | docs/triage/_archive/SECURITY_SURFACE_SWEEP_v11.md | - `config/` (except safe bootstrap if needed) | replace `bootstrap` -> `initial setup` | rename word |
| boot_pack | ops/init/icl/context_pack.json | "principles_file": "ops/init/icl/boot_pack/principles.md", | update path to `ops/init/icl/launch_pack/principles.md` | rename word |
| boot_pack | STATE_OF_PLAY.md | - Moved `boot/active/boot_pack/RESURRECTION.md` to `ops/init/icl/boot_pack/RESURRECTION.md`. | update to `boot/active/launch_pack/RECOVERY.md` and `ops/init/icl/launch_pack/RECOVERY.md` (archival note) | rename word |
| cockpit | STATE_OF_PLAY.md | ## 2026-01-07 - ICL-001J: remove deprecated Daily Cockpit template | replace `Daily Cockpit` -> `Daily Console` (archival note) | rename word |
| boot | ops/init/icl/ACTIVE_CONTEXT.md | # Active Boot Pack | `# Active Launch Pack` | rename word |
| boot_pack | ops/init/icl/ACTIVE_CONTEXT.md | - ops/init/icl/boot_pack/ | `- ops/init/icl/launch_pack/` | rename word |
| cockpit | ops/init/icl/boot_pack/AI_CONTEXT_SYNC.md | ## Daily cockpit (not the truth ledger) | `## Daily console (not the truth ledger)` | rename word |
| boot_pack | ops/init/icl/boot_pack/AI_CONTEXT_SYNC.md | `ops/init/icl/boot_pack/DAILY_COCKPIT.md` is the operating rhythm checklist. | `ops/init/icl/launch_pack/DAILY_CONSOLE.md` | rename word |
| cockpit | ops/init/icl/boot_pack/AI_CONTEXT_SYNC.md | No project truth should live only in a cockpit. | replace `cockpit` -> `console` | rename word |
| lazarus | ops/init/icl/boot_pack/CONTEXT_PACK.md | # nukeCE Context Pack (Lazarus Pit Card) | `# nukeCE Context Pack (Recovery Card)` | rename word |
| boot_pack | ops/init/icl/boot_pack/CONTEXT_PACK.md | - If anything is unclear: stop and open `ops/init/icl/boot_pack/DAILY_COCKPIT.md` | `ops/init/icl/launch_pack/DAILY_CONSOLE.md` | rename word |
| resurrection | ops/init/icl/boot_pack/CONTEXT_PACK.md | ## "Resurrection prompt" (paste into any new chat) | `## "Recovery prompt" (paste into any new chat)` | rename word |
| boot_pack | ops/init/icl/boot_pack/CONTEXT_PACK.md | Read `ops/init/icl/boot_pack/CONTEXT_PACK.md` first, then ask me: | `ops/init/icl/launch_pack/CONTEXT_PACK.md` | rename word |
| boot_pack | ops/init/icl/boot_pack/COPILOT_ONBOARDING.md | 5) `ops/init/icl/boot_pack/AI_CONTEXT_SYNC.md` | `ops/init/icl/launch_pack/AI_CONTEXT_SYNC.md` | rename word |
| cockpit | ops/init/icl/boot_pack/DAILY_COCKPIT.md | # Daily Cockpit - YYYY-MM-DD | `# Daily Console - YYYY-MM-DD` | rename file |
| boot_pack | ops/init/icl/boot_pack/DAILY_COCKPIT.md | - **Rehydration** = onboarding an AI/contractor back into canon using `ops/init/icl/boot_pack/AI_CONTEXT_SYNC.md` + `ops/init/icl/boot_pack/CONTEXT_PACK.md` (optional but powerful). | update paths to `ops/init/icl/launch_pack/` | rename word |
| cockpit | ops/init/icl/boot_pack/DAILY_COCKPIT.md | - **Daily Cockpit** = your daily runbook + notes (always allowed; never the single source of truth). | replace `Daily Cockpit` -> `Daily Console` | rename word |
| flight | ops/init/icl/boot_pack/DAILY_COCKPIT.md | ## Preflight checklist (never empty) | `## Precheck checklist (never empty)` | rename word |
| boot_pack | ops/init/icl/boot_pack/GEMINI_ONBOARDING.md | 5) `ops/init/icl/boot_pack/AI_CONTEXT_SYNC.md` | `ops/init/icl/launch_pack/AI_CONTEXT_SYNC.md` | rename word |
| cockpit | ops/init/icl/boot_pack/IDE_MIGRATION.md | NetBeans is the Truth Cockpit for review + integration. | replace `Cockpit` -> `Console` (also lines 10, 16) | rename word |
| boot | ops/init/icl/boot_pack/principles.md | Continuity comes from Boot Packs + Context Packs + retrieval, not assumed memory. | replace `Boot Packs` -> `Launch Packs` | rename word |
| boot | ops/init/icl/boot_pack/README.md | # nukeCE Boot Pack | `# nukeCE Launch Pack` | rename file |
| lazarus | ops/init/icl/boot_pack/README.md | This folder is the **Lazarus Pit**: it lets nukeCE survive chat resets and contractor rotation. | replace `Lazarus Pit` -> `Recovery Pit` | rename word |
| resurrection | ops/init/icl/boot_pack/README.md | - `RESURRECTION.md` — copy/paste prompts for a new chat or contractor | `RECOVERY.md` | rename file |
| cockpit | ops/init/icl/boot_pack/README.md | - `DAILY_COCKPIT.md` — daily operating rhythm + checklist | `DAILY_CONSOLE.md` | rename file |
| cockpit | ops/init/icl/boot_pack/README.md | - `IDE_MIGRATION.md` — cockpit migration guardrails | replace `cockpit` -> `console` | rename word |
| resurrection | ops/init/icl/boot_pack/RESURRECTION.md | # Resurrection kit (copy/paste prompts) | `# Recovery kit (copy/paste prompts)` | rename file |
| resurrection | ops/init/icl/boot_pack/RESURRECTION.md | ## 1) Integrator resurrection prompt (new ChatGPT chat) | replace `resurrection` -> `recovery` | rename word |
| boot_pack | ops/init/icl/boot_pack/RESURRECTION.md | - `ops/init/icl/boot_pack/DAILY_COCKPIT.md` | `ops/init/icl/launch_pack/DAILY_CONSOLE.md` | rename word |
| boot_pack | ops/init/icl/boot_pack/RESURRECTION.md | - Copilot: `ops/init/icl/boot_pack/COPILOT_ONBOARDING.md` | `ops/init/icl/launch_pack/COPILOT_ONBOARDING.md` | rename word |
| boot_pack | ops/init/icl/boot_pack/RESURRECTION.md | - Gemini: `ops/init/icl/boot_pack/GEMINI_ONBOARDING.md` | `ops/init/icl/launch_pack/GEMINI_ONBOARDING.md` | rename word |
| cockpit | ops/init/protocols/SAVE_THIS_PROTOCOL.md | - names the artifact (Daily Cockpit, PR workflow, etc.) | replace `Daily Cockpit` -> `Daily Console` | rename word |
| cockpit | ops/init/protocols/SAVE_THIS_PROTOCOL.md | - Save this: NetBeans is the Truth Cockpit; review diffs there before committing. | replace `Truth Cockpit` -> `Truth Console` | rename word |
| boot_pack | ops/init/protocols/SAVE_THIS_PROTOCOL.md | - relevant onboarding docs in `ops/init/icl/boot_pack/` | update path to `ops/init/icl/launch_pack/` | rename word |
