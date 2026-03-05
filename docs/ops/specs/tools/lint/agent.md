<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/agent.sh` exists to prevent unregistered or malformed agent definitions from entering the active execution surface. The script protects two constitutional invariants: SSOT alignment between `docs/ops/registry/agents.md` and `opt/_factory/agents/*.md`, and the Generation Mandate in `PoT.md` Section 4.2 that forbids fabricated execution context pointers. Without this gate, an agent file can advertise non-existent pointers or unauthorized toolchain paths and still appear valid to a worker.

## Mechanics and Sequencing
1. Resolve repository root, emit lifecycle telemetry, and require `docs/ops/registry/agents.md`.
2. Parse registry rows with `awk`, then enforce unique agent IDs and unique names.
3. Verify registry-to-file reachability by mapping each ID to `opt/_factory/agents/<id-lowercase>.md` and fail missing files.
4. Detect ghost files by walking `opt/_factory/agents/*.md` and failing files that have no registry row.
5. For each agent file, enforce required-section presence (`Provenance`, `Role`, `Specialization`, `Identity Contract`, `Capability Tags`, `Pointers`, `Skill Bindings`, `Scope Boundary`), duplicate-section rejection, and section non-emptiness.
6. Enforce required Provenance fields (`Captured`, `DP-ID`, `Branch`, `HEAD`, `Objective`).
7. Parse `## Identity Contract` and enforce:
   - ``agent_id`` exists, is backticked, matches filename-derived ID, and exists in registry.
   - ``stance_id`` exists, is backticked, and is in canonical allowed set.
8. Parse `## Capability Tags` and require at least one backticked tag bullet.
9. Parse `## Pointers`, enforce required pointer tokens (`PoT.md`, `docs/GOVERNANCE.md`, `TASK.md`), reject legacy `JIT skills` pointer blocks, validate all backticked paths, and reject absolute or home-path tokens.
10. Enforce authorized toolchain tokens by allowing only `ops/bin/*`, `tools/lint/*`, `tools/test/*`, and `tools/verify.sh`, while verifying target files exist.
11. Parse `## Skill Bindings` and enforce explicit labels (``required_skills``, ``optional_skills``) plus deterministic skill-path bullets under `opt/_factory/skills/`.
12. Reject stance-envelope directives, disposable artifact references, and recursive context-expansion patterns, then return non-zero when any failure accumulated.

## Anecdotal Anchor
The registry-first checks were introduced after sessions where unregistered or schema-defective agent files reached the factory surface before registry validation ran. Those incidents produced broken pointer chains and forced manual reconciliation of agent identity, file paths, and allowed executables before delivery gates could pass.

## Integrity Filter Warnings
The script hard-fails when required files are missing, when registry uniqueness breaks, when identity-contract fields drift from filename/registry alignment, or when pointer/toolchain reachability checks fail. Pointer validation inspects backticked tokens from the `## Pointers` section; non-backticked path strings outside that parsing path are not evaluated by the path-existence loop. Hazard detection is pattern-based, so new disposable-artifact naming conventions or new stance-envelope directive phrasings require script updates to remain covered.
