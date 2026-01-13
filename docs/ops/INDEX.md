# Docs / ops - pointer index

Short index for operators. Ops canon lives in `ops/`; this index points to it.
If a doc is not linked here or captured in `docs/triage/INBOX.md`, it is drift.

## Docs library + help (curated surface)
Use `./ops/bin/help` as the operator front door for approved docs. It only opens
topics listed in `docs/library/LIBRARY_INDEX.md`. If it is not listed, it is not
approved for help.

Usage:
- `./ops/bin/help`
- `./ops/bin/help list`
- `./ops/bin/help manual`
- `./ops/bin/help <topic>`

Library location:
- Root: `docs/library/`
- Manifest: `docs/library/LIBRARY_INDEX.md` (format: `topic | title | path`)

Add a new library entry:
- Update `docs/library/LIBRARY_INDEX.md` with a new line; keep it curated (not every .md).

Color behavior:
- If `bat` is installed, help uses `bat` and pipes to `less -R`.
- If `bat` is not installed, help uses plain `less`.

## Start here
- [Daily Console](../../ops/init/icl/launch_pack/DAILY_CONSOLE.md)
- [Recovery](../../ops/init/icl/launch_pack/RECOVERY.md)
- [Context Pack](../../ops/init/icl/launch_pack/CONTEXT_PACK.md)
- [AI Context Sync](../../ops/init/icl/launch_pack/AI_CONTEXT_SYNC.md)

## Core canon
- [ICL Overview](../../ops/init/icl/ICL_OVERVIEW.md)
- [OCL Overview](../../ops/init/icl/OCL_OVERVIEW.md)

## Execute
- [Output Format Contract](../../ops/contracts/OUTPUT_FORMAT_CONTRACT.md)
- [Contractor Dispatch Contract](../../ops/contracts/CONTRACTOR_DISPATCH_CONTRACT.md)
- [Save This Protocol](../../ops/init/protocols/SAVE_THIS_PROTOCOL.md)
- [Output Format Protocol](../../ops/init/protocols/OUTPUT_FORMAT_PROTOCOL.md)
- [Dispatch Packet Protocol](../../ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md)

## Playbooks
- [Paste Surfaces Playbook](../../ops/init/icl/PASTE_SURFACES_PLAYBOOK.md)

## Planning
- [Banned Terms Map](../../ops/init/icl/BANNED_TERMS_MAP.md)
- [Rename Plan (ICL/OCL)](../../ops/init/icl/RENAME_PLAN_ICL_OCL.md)

## Templates
- [PR Description Template](../../ops/templates/PR_DESCRIPTION_TEMPLATE.md)
- [Contractor Brief Template](../../ops/templates/CONTRACTOR_BRIEF_TEMPLATE.md)
- [Contractor Report Template](../../ops/templates/CONTRACTOR_REPORT_TEMPLATE.md)

## Staff surfaces
- [Integrator Onboarding](../../ops/init/icl/launch_pack/INTEGRATOR_ONBOARDING.md)
- [Contractor Onboarding](../../ops/init/icl/launch_pack/CONTRACTOR_ONBOARDING.md)
- [Copilot Onboarding](../../ops/init/icl/launch_pack/COPILOT_ONBOARDING.md)
- [Gemini Onboarding](../../ops/init/icl/launch_pack/GEMINI_ONBOARDING.md)
- [IDE Migration](../../ops/init/icl/launch_pack/IDE_MIGRATION.md)

## Triage
- [../triage/INBOX.md](../triage/INBOX.md)

## Verification
- [../../STATE_OF_PLAY.md](../../STATE_OF_PLAY.md)
