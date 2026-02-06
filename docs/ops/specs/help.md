# Technical Specification: ops/bin/help

## Technical Specifications
- Menu Mode: displays the command index and quick start when no term is provided.
- Search Mode: greps `docs/` with line numbers when a term is provided.
- Specs Priority: searches `docs/ops/specs/` first and reports matches before scanning the rest of `docs/`.
- Specs Listing: supports `./ops/bin/help specs` to list specification documents.
- Output Clarity: uses consistent Stela System prefixes and optional ANSI formatting.

## Requirements
- Must run from the repository root with git available on PATH.
- Requires `docs/` and `docs/ops/specs/` to exist.
- Requires `grep` and standard shell utilities on PATH.

## Usage
- `./ops/bin/help`
- `./ops/bin/help dump`
- `./ops/bin/help specs`

## Forensic Insight
`ops/bin/help` is the Explanation System. Prioritizing spec documents ensures the Operator reaches the authoritative behavior definition before relying on narrative documentation.
