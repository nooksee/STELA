<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/traverse.sh` exists to enforce PoT.md Section 1.1 filing doctrine and Section 1.2 drift prevention during file selection. Dump and synthesis tooling requires a deterministic topology walk so scope boundaries stay explicit as repository layout grows.

## Mechanics and Sequencing
1. Parse CLI arguments for `--scope`, `--project`, `--include-dir`, `--exclude-dir`, and `--ignore-file`, then reject illegal scope and target combinations.
2. Require `git` availability, resolve repo root via `git rev-parse --show-toplevel`, and fail if the caller is not running from repo root.
3. Build scope inclusion rules:
   - `full`: all tracked files.
   - `platform`: tracked files outside `projects/`.
   - `project`: tracked files inside `projects/<slug>/` plus non-project tracked files.
4. Apply optional include-dir, exclude-dir, and ignore-glob filters in sequence for each tracked path.
5. Skip binary files via `grep -Iq` heuristic, print accepted paths line-by-line, and count selections.
6. Emit a telemetry leaf (`traverse` / `selection-complete`) and fail hard when the resulting selection set is empty.

## Anecdotal Anchor
PoW entry `2026-02-20 03:15:44 UTC — DP-OPS-0078 Traverse Engine Extraction and Project Binary Split` documents the extraction and then verifies platform/full dump parity with six diff checks. The same entry records earlier matrix failures before parity corrections, which is direct evidence of why centralized topology traversal was required.

## Integrity Filter Warnings
- Only git-tracked files enter the stream; untracked files are invisible by design.
- Binary detection uses a heuristic and can misclassify some encoded text files.
- `project` scope includes non-project files intentionally, so callers that expect a project-only payload must add include filters.
- Tie-breaking and ordering follow `git ls-files`; callers must not assume filesystem traversal order.
