<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/agent.sh` exists to prevent unregistered or malformed agent definitions from entering the active execution surface. The script protects two constitutional invariants: SSOT alignment between `docs/ops/registry/agents.md` and `opt/_factory/agents/*.md`, and the Generation Mandate in `PoT.md` Section 4.2 that forbids fabricated execution context pointers. Without this gate, an agent file can advertise non-existent pointers or unauthorized toolchain paths and still appear valid to a worker.

## Mechanics and Sequencing
1. Resolve repository root, emit lifecycle telemetry, and require `docs/ops/registry/agents.md`.
2. Parse registry rows with `awk`, then enforce unique agent IDs and unique names.
3. Verify registry-to-file reachability by mapping each ID to `opt/_factory/agents/<id-lowercase>.md` and fail missing files.
4. Detect ghost files by walking `opt/_factory/agents/*.md` and failing files that have no registry row.
5. For each agent file, enforce section presence, duplicate-section rejection, section non-emptiness, and required Provenance fields.
6. Parse the `## Pointers` section, enforce required tokens (`PoT.md`, `docs/GOVERNANCE.md`, `TASK.md`), validate each backticked pointer path, and reject absolute or home-path tokens.
7. Enforce authorized toolchain tokens by allowing only `ops/bin/*`, `tools/lint/*`, `tools/test/*`, and `tools/verify.sh`, while verifying target files exist.
8. Reject disposable artifact references and recursive context-expansion patterns, then return non-zero when any failure accumulated.

## Anecdotal Anchor
The registry-first checks were introduced after sessions where unregistered or schema-defective agent files reached the factory surface before registry validation ran. Those incidents produced broken pointer chains and forced manual reconciliation of agent identity, file paths, and allowed executables before delivery gates could pass.

## Integrity Filter Warnings
The script hard-fails when required files are missing, when registry uniqueness breaks, or when pointer/toolchain reachability checks fail. Pointer validation inspects backticked tokens from the `## Pointers` section; non-backticked path strings outside that parsing path are not evaluated by the path-existence loop. Hazard detection is pattern-based, so new disposable-artifact naming conventions require script updates to remain covered.
