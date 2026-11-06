<!-- CCD: ff_target="operator-technical" ff_band="35-50" -->
# Research Records (Isolate)

## 0. What This Directory Holds
This directory holds the research reports that preceded the platform's packets, as PDF records. PoT 1.1 names `opt/` as JIT-only content excluded from global context: no binary reads these files, `ops/lib/scripts/traverse.sh` skips binary content, no lint reads PDF content, and `tools/verify.sh` admits this directory as a records class whose members are `*.pdf`, `SHA256SUMS`, and `README.md` and nothing else. The records are evidence of what was proposed; `PoT.md` and the surfaces it names are what the platform does.

## 1. Naming and Integrity
Each record is `<slug>.pdf`, where the slug is the lowercase hyphenated form of the report's title. `SHA256SUMS` carries one digest line per record. Verify the set from this directory with `sha256sum -c SHA256SUMS`; the expected result is one `OK` line per record and an exit status of 0. The gates run the same check through `tools/lint/records.sh` (the `records-digest` verify lane), which also fails on a record that the list does not name and on a listed record that is missing.

## 2. Catalog
`docs/RESEARCH.md` lists every record in fourteen topic clusters and states, per cluster, what current main does and where. Read the catalog first and open a record only for the argument behind a surface.

## 3. Adding a Record
A record enters through a packet: one `NEW` line per file in section 3.4.3 of the packet, one digest line appended to `SHA256SUMS`, and one row in the catalog table of the cluster it belongs to. Records are never edited in place; a revised report is a new record.
