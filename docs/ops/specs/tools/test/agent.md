<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
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
- `opt/_factory/agents/*.md`
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

## Anecdotal Anchor
Think of this test like a circuit check that proves each pointer path is still wired before operators trust an agent definition.

## Related pointers
- Registry entry: `docs/ops/registry/test.md` (`TEST-01`).
- Agent lint companion: `tools/lint/agent.sh`.
- Agent registry: `docs/ops/registry/agents.md`.
