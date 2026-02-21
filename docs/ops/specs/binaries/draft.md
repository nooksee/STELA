<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/draft` exists to prevent manual DP structure drift and to enforce PoT Section 4.2 generation rules for packet structure. It protects TASK structural invariants by generating the packet body from canonical template slots, then replacing only the active DP block in Section 3.

## Mechanics and Sequencing
The binary parses required DP identity arguments and required slot content inputs, optionally loads slot blocks from a slots file, and enforces non-empty content for each required slot. It enforces clean-tree execution unless `DRAFT_ALLOW_DIRTY_TREE=1`, reads canonical template constants from `tools/lint/dp.sh`, validates canonical template hash parity, and verifies TASK contains exactly one Section 3 heading and exactly one active DP heading. It renders DP content through `ops/bin/template render dp`, writes the intake packet to `storage/dp/intake/<DP>.md`, and rewrites the active DP block in `TASK.md` while preserving surrounding TASK content.

## Anecdotal Anchor
During the DP-OPS-0065 immutable workflow cutover, hand-authored packet sections repeatedly diverged in ordering and required headings, which triggered packet lint failures and reruns. `ops/bin/draft` was introduced to remove packet-shape variance by forcing canonical generation before execution.

## Integrity Filter Warnings
`ops/bin/draft` exits on dirty trees, missing required arguments, malformed packet IDs, missing required slot content, missing slots file, template hash mismatch, malformed TASK Section 3 structure, or inability to locate the active DP heading for replacement. It does not continue after partial render or partial TASK rewrite conditions.
