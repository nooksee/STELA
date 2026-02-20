<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/project.sh` supplies hard preconditions for repo-root execution and project identifier validity so project-scoped binaries cannot run against ambiguous working directories. This enforces PoT.md Section 1.1 filing doctrine and Section 1.2 drift constraints by guaranteeing that scaffold and context tooling resolve paths from one canonical root.

## Mechanics and Sequencing
1. `project_require_realpath` verifies `realpath` exists and returns the canonical absolute path for a given input.
2. `project_require_repo_root` verifies `git` exists, resolves top-level repo path, canonicalizes it through `project_require_realpath`, and fails when `pwd -P` is not that root.
3. `project_require_file` and `project_require_executable` enforce file/executable preconditions for caller binaries.
4. `project_is_valid_id` applies regex `^[a-z0-9]([a-z0-9-]*[a-z0-9])?$`.
5. `project_require_valid_id` rejects empty or invalid project identifiers and emits `ERROR:` through `project_die`.
6. On successful repo-root check, `PROJECT_REPO_ROOT` is set in the current shell context for downstream script use.

## Anecdotal Anchor
PoW entry `2026-02-20 03:15:44 UTC — DP-OPS-0078 Traverse Engine Extraction and Project Binary Split` documents the split of traversal and project responsibilities, followed by parity checks for dump output. That split reflects the failure class this file addresses: monolithic path logic blurred project boundaries and required a dedicated guardrail library for deterministic execution roots.

## Integrity Filter Warnings
- The library intentionally retains no backward-compatibility shim for non-root invocation; callers outside repo root fail immediately.
- The library assumes `git` and `realpath` are available on `PATH`; missing binaries are hard failures.
- `PROJECT_REPO_ROOT` is a shell variable, not an exported environment contract, so subshell callers must pass it explicitly if needed.
- Project ID regex rejects uppercase letters, underscores, and trailing hyphens; callers migrating legacy IDs must normalize before invocation.
