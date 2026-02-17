# Technical Specification: tools/lint/integrity.sh

## Purpose
Enforce allowlist integrity by rejecting changed or untracked paths that are not explicitly listed in the active Target Files allowlist pointer.

## Invocation
- Command: `bash tools/lint/integrity.sh`
- Required flags: none.
- Positional arguments: none.
- Exit behavior:
  - `0` when all changed/untracked paths are allowlisted.
  - `1` for usage errors or integrity violations.

## Inputs
- `TASK.md` for Target Files allowlist pointer extraction from Section 3.3.
- Allowlist file (pointer target, usually `storage/dp/active/allowlist.txt`).
- Git state:
  - `git diff --name-only --cached`
  - `git diff --name-only`
  - `git ls-files --others --exclude-standard`

## Outputs
- No file writes.
- Stdout on success:
  - `OK: integrity lint passed (<count> observed paths).`
- Stderr on failure:
  - pointer extraction/read errors.
  - list of unauthorized changed/untracked paths.

## Enforcement Model
1. Locate allowlist pointer entry in `TASK.md`.
2. Load allowlist entries into normalized path set.
3. Build observed-path set from staged, unstaged, and untracked files.
4. Compare observed set against allowlist set.
5. Fail if any observed path is not allowlisted.

## Related pointers
- Scope pointer contract: `TASK.md` Section 3.3.
- Certifier hard gate caller: `ops/bin/certify`.
