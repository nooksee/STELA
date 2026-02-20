<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/compile` exists to keep manifest truth deterministic under PoT Section 1.2 SSOT. It prevents state drift where runtime manifests differ from template intent or where synthesis tools read stale membership sets. It guarantees that every compile event produces both runtime manifest outputs and an immutable archive leaf for audit reconstruction.

## Mechanics and Sequencing
The binary enforces repo-root execution, validates template presence in `ops/src/manifests`, loads tracked files through `git ls-files`, and resolves template membership recursively. During resolution it expands `@manifest:` includes, validates literal file entries, and expands globs only against tracked paths. It renders compiled manifests into a `var/tmp/compile.*` workspace first, then emits an archive leaf under `archives/manifests/` with schema frontmatter fields `trace_id`, `packet_id`, `created_at`, and `previous`, plus embedded snapshots of compiled manifest bodies. Only after successful leaf emission does it promote temporary compiled manifests into `ops/lib/manifests/`. On success it prints a single parseable `MANIFEST_LEAF:` line.

## Anecdotal Anchor
Before compile adopted the temporary workspace and archive-first promotion contract, `context` and `llms` flows could consume mismatched manifest state during local edits. The current sequence closes that reliability gap by binding runtime promotion to successful immutable leaf emission.

## Integrity Filter Warnings
`ops/bin/compile` exits non-zero on unknown arguments, missing template files, missing tracked file entries, globs with zero tracked matches, empty resolution sets, leaf name collisions that persist after retry, temporary render failures, or missing compiled manifests during snapshot assembly. The command does not accept partial template resolution and does not promote runtime manifests when snapshot assembly fails.
