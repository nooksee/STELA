<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/factory.sh` preserves definition-promotion integrity by proving that factory head pointers, registries, and canonical files remain synchronized. This gate prevents broken head chains, dead registries, and ghost artifacts that would corrupt promotion routing and violate SSOT alignment across agent, task, and skill domains.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and require all factory heads plus all definition registries.
2. Validate each head file (`AGENTS.md`, `TASKS.md`, `SKILLS.md`) as an exact four-line key sequence (`candidate`, `promotion`, `spec`, `registry`) with non-empty values.
3. Enforce expected `spec:` and `registry:` path equality and filesystem reachability.
4. Validate `candidate:` and `promotion:` values as either exact `-(origin)` sentinels or reachable `archives/definitions/*` leaf paths.
5. Invoke delegated linters (`tools/lint/agent.sh`, `tools/lint/task.sh`) and fail factory lint when either delegated gate fails.
6. Parse registries and verify all referenced files exist, then detect ghost files under `opt/_factory/agents`, `opt/_factory/skills`, and `opt/_factory/tasks`.
7. Apply additional guardrails: skill-pointer token existence checks, numbered-list rejection in skill files, and duplicate verification-pattern checks inside task files that already invoke `S-LEARN-01`.

## Anecdotal Anchor
DP-OPS-0077 fission work exposed pointer-head inconsistency when head files were edited outside canonical promotion flow. That incident class produced dead-end promotion paths and registry/file divergence, which this script now catches before promotion state reaches closeout.

## Integrity Filter Warnings
The script depends on delegated outputs from `tools/lint/agent.sh` and `tools/lint/task.sh`; a failure in either script blocks factory lint even when head files are locally valid. Sentinel matching is strict: `-(origin)` values must equal exact expected strings. Pointer token checks are string-based and path-based, so semantic content quality outside enforced sections is out of scope.
