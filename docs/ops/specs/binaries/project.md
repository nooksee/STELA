<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/project` remains as a deprecated compatibility wrapper for historical project workflows. It exists to preserve backward-compatible orchestration while PoT-guided workflow responsibilities are split into `ops/bin/scaffold` and `ops/bin/meta`.

## Mechanics and Sequencing
The binary accepts `work <id>`, validates the project identifier and required project files through `ops/lib/scripts/project.sh`, derives branch and hash naming tokens, invokes `ops/bin/open` with a project tag, invokes `ops/bin/dump --scope=platform --out=auto`, verifies expected artifact file names, concatenates OPEN artifact content, dump payload content, and project `STELA.md` content into `storage/handoff/PROJECT-<id>-<branch>-<hash>.txt`, and prints the artifact path.

## Anecdotal Anchor
During DP-OPS-0078 project binary fission, project lifecycle responsibilities were split to reduce scope coupling. `ops/bin/project` was left as transitional glue so existing invocation patterns did not break during that migration.

## Integrity Filter Warnings
`ops/bin/project` exits on unknown commands, invalid project IDs, missing project directory, missing `STELA.md`, open or dump invocation failure, or missing expected artifact files. The wrapper depends on naming conventions from `open` and `dump`, so naming-contract changes in upstream binaries can break this deprecated path.
