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

Operator Manual:
- `docs/library/OPERATOR_MANUAL.md`
- `./ops/bin/help manual`

Color behavior:
- If `bat` is installed, help uses `bat` and pipes to `less -R`.
- If `bat` is not installed, help uses plain `less`.

## Start here
- [Stela System Constitution](../../TRUTH.md)
- [SoP](../../SoP.md)
- [Operator Manual](../../docs/library/OPERATOR_MANUAL.md)
- [Continuity Map](../../docs/library/CONTINUITY_MAP.md)

## Execute
- [Output Format Contract](../../ops/contracts/OUTPUT_FORMAT_CONTRACT.md)
- [Contractor Dispatch Contract](../../ops/contracts/CONTRACTOR_DISPATCH_CONTRACT.md)

## Triage
- [../triage/INBOX.md](../triage/INBOX.md)

## Verification
- [../../SoP.md](../../SoP.md)
