# Technical Specification: ops/lib/scripts/project.sh

## Purpose
Provide shared guardrail functions for repo-root tooling, including project-id validation and executable/file checks used by wrapper binaries.

## Invocation
- This file is a sourced helper library, typically consumed by `ops/bin/project`, `ops/bin/context`, and `ops/bin/llms`.
- Source form:
  - `source ops/lib/scripts/project.sh`
- Function forms:
  - `project_require_realpath <path>`
  - `project_require_repo_root`
  - `project_require_file <absolute_path>`
  - `project_require_executable <absolute_path>`
  - `project_is_valid_id <project_id>`
  - `project_require_valid_id <project_id>`
- Expected exit behavior:
  - On validation failure, `project_die` prints `ERROR:` and exits with code `1`.

## Inputs
- Shell environment and current working directory.
- `git` and `realpath` binaries.
- Absolute file paths for presence/executable checks.
- Project identifier strings for validation.

## Outputs
- Writes no files.
- `project_require_realpath` prints resolved path on stdout.
- `project_require_repo_root` exports `PROJECT_REPO_ROOT` in the current shell context.

## Invariants and failure modes
- Commands must run from repository root after canonical path resolution.
- Project IDs must match `^[a-z0-9]([a-z0-9-]*[a-z0-9])?$`.
- Missing dependencies (`git`, `realpath`) are hard failures.

## Related pointers
- Registry entry: `docs/ops/registry/SCRIPTS.md` (`SCRIPT-03`).
- Central synthesis engine: `ops/lib/scripts/synthesize.sh` (`SCRIPT-04`).
- Binary consumers: `ops/bin/project`, `ops/bin/context`, `ops/bin/llms`.
