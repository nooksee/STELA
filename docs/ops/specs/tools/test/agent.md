# Technical Specification: tools/test/agent.sh

## Purpose
Run pointer-integrity tests for canon agent files, including authorized toolchain resolution and drift-injection guards.

## Invocation
- Command: `bash tools/test/agent.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when all agent pointer checks pass or no agents are present.
  - `1` when pointer or toolchain validation fails.

## Inputs
- `docs/library/agents/*.md`
- `ops/bin/*` paths referenced by agent authorized toolchain entries.
- Pointer tokens extracted from each agent `## Pointers` section.

## Outputs
- Writes no files.
- Stdout: pass lines including drift-injection sentinel confirmation.
- Stderr: `FAIL:` messages for missing sections, missing pointer targets, or invalid toolchain paths.

## Invariants and failure modes
- Each agent must include `## Pointers` and `## Scope Boundary` sections.
- Authorized toolchain entries must include backticked tokens that resolve to existing paths.
- Non-toolchain pointers must also resolve.
- Drift injection path `ops/bin/DRIFT-INJECTION` must not exist; existence is treated as failure.

## Related pointers
- Registry entry: `docs/ops/registry/TEST.md` (`TEST-01`).
- Agent lint companion: `tools/lint/agent.sh`.
- Agent registry: `docs/ops/registry/AGENTS.md`.
