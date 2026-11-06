<!-- CCD: ff_target="discovery" ff_band="30-50" -->
# Research Records (Isolate)

## Purpose
This directory holds the research reports that preceded the platform's packets, as PDF records. They are evidence of what was proposed; `PoT.md` and the surfaces it names are what the platform does.

## Structure
Each record is `<slug>.pdf`, where the slug is the lowercase hyphenated form of the report's title. `SHA256SUMS` carries one digest line per record. `tools/verify.sh` admits this directory as a records class whose members are `*.pdf`, `SHA256SUMS`, and `README.md` and nothing else.

## Entry Point
Read `docs/RESEARCH.md` first: it lists every record in fourteen topic clusters and states, per cluster, what current main does and where. Open a record only for the argument behind a surface.

## Constraints
- PoT 1.1 names `opt/` as JIT-only content excluded from global context: no binary reads these files, `ops/lib/scripts/traverse.sh` skips binary content, and no lint reads PDF content.
- Records are never edited in place; a revised report is a new record.
- A record enters through a packet: one `NEW` line per file in section 3.4.3, one digest line appended to `SHA256SUMS`, and one row in the catalog table of its cluster.

## Canonical Pointer
`SHA256SUMS` is the statement of what each record is. Verify from this directory with `sha256sum -c SHA256SUMS`; the gates run the same check through `tools/lint/records.sh` (the `records-digest` verify lane), which also fails on a record the list does not name and on a listed record that is missing.

## Where to Look Next
- `docs/RESEARCH.md` for the catalog and the outcome paragraphs.
- `docs/ops/specs/tools/lint/records.md` for the digest lint.
- `archives/decisions/RoR-2026-11-06-002-op-0268.md` for the decision that admitted the records class.
