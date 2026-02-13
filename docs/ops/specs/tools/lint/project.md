# Technical Specification: tools/lint/project.sh

## Purpose
Validate project `STELA.md` pointers so project surfaces reference only registered agents, tasks, and skills.

## Invocation
- Command: `bash tools/lint/project.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when checks pass or no project `STELA.md` files are present.
  - `1` when dead pointers are detected.

## Inputs
- `git` for repository root detection.
- `rg` for token extraction.
- Registries:
  - `docs/ops/registry/AGENTS.md`
  - `docs/ops/registry/SKILLS.md`
  - `docs/ops/registry/TASKS.md`
- Project contracts discovered at `projects/*/STELA.md` (search depth 2).

## Outputs
- Writes no files.
- Stdout:
  - `No projects found.` when no `STELA.md` files exist.
  - `OK: Project STELA references verified for agents, tasks, and skills.` on success.
- Stderr: `FAIL:` entries for unknown `R-AGENT-*`, `B-TASK-*`, or `S-LEARN-*` references.

## Invariants and failure modes
- Registry files must exist before scanning project surfaces.
- Only registered IDs are valid in `STELA.md` references.
- Missing `git` or `rg` dependencies are hard failures.

## Related pointers
- Registry entry: `docs/ops/registry/LINT.md` (`LINT-06`).
- Project contract surface: `projects/*/STELA.md`.
- Project helper library: `ops/lib/scripts/project.sh`.
