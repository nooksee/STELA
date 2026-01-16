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

Datasets (manifest-only):
- Root: `docs/library/datasets/`
- `./ops/bin/help db-dataset`
- `./ops/bin/help db-voice-0001`

Add a new library entry:
- Update `docs/library/LIBRARY_INDEX.md` with a new line; keep it curated (not every .md).

Operator Manual:
- `docs/library/OPERATOR_MANUAL.md`
- `./ops/bin/help manual`

Color behavior:
- If `bat` is installed, help uses `bat` and pipes to `less -R`.
- If `bat` is not installed, help uses plain `less`.

## Start here
- [ICL Continuity Core](../../ops/init/icl/ICL_CONTINUITY_CORE.md)
- [Daily Console](../../ops/init/icl/DAILY_CONSOLE.md)
- [Recovery](../../ops/init/icl/RECOVERY.md)
- [Context Pack](../../ops/init/icl/CONTEXT_PACK.md)
- [AI Context Sync](../../ops/init/icl/AI_CONTEXT_SYNC.md)

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

## Templates
- [PR Description Template](../../ops/templates/PR_DESCRIPTION_TEMPLATE.md)
- [Contractor Brief Template](../../ops/templates/CONTRACTOR_BRIEF_TEMPLATE.md)
- [Contractor Report Template](../../ops/templates/CONTRACTOR_REPORT_TEMPLATE.md)

## Legacy onboarding (deprecated)
- [Integrator Onboarding](../../ops/init/icl/deprecated/INTEGRATOR_ONBOARDING.md)
- [Contractor Onboarding](../../ops/init/icl/deprecated/CONTRACTOR_ONBOARDING.md)
- [Copilot Onboarding](../../ops/init/icl/deprecated/COPILOT_ONBOARDING.md)
- [Gemini Onboarding](../../ops/init/icl/deprecated/GEMINI_ONBOARDING.md)
- [IDE Migration](../../ops/init/icl/deprecated/IDE_MIGRATION.md)

## Triage
- [../triage/INBOX.md](../triage/INBOX.md)

## Verification
- [../../STATE_OF_PLAY.md](../../STATE_OF_PLAY.md)
