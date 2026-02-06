# Technical Specification: ops/bin/project

## Technical Specifications
- Entry Point: accepts `work <id>` as the primary command.
- Validation: enforces project ID validation via `ops/lib/scripts/project.sh`.
- OPEN and Dump: calls `ops/bin/open` and `ops/bin/dump` to generate session artifacts.
- Assembly: concatenates the OPEN artifact, the platform dump, and the project `STELA.md` into a single handoff file.
- Output: writes `storage/handoff/PROJECT-<id>-<branch>-<hash>.txt` and prints the relative path.

## Requirements
- Must run from the repository root.
- Requires `projects/<id>/STELA.md` to exist.
- Requires `ops/bin/open`, `ops/bin/dump`, and `ops/lib/scripts/project.sh` to be executable.
- Requires `storage/handoff/` and `storage/dumps/` to be writable.

## Usage
- `./ops/bin/project work example-project`

## Forensic Insight
`ops/bin/project` is the Workflow Orchestrator. Its deterministic assembly path prevents project files from overriding platform law and keeps the governance wrapper intact.
