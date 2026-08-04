<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/compile` exists to keep manifest truth deterministic under PoT Section 1.2 SSOT. It prevents state drift where runtime manifests differ from template intent or where synthesis tools read stale membership sets. Normal compilation produces runtime manifest outputs and an immutable archive leaf for audit reconstruction. Read-only checking proves the same render contract without publishing either surface.

## Mechanics and Sequencing
The binary enforces repo-root execution, validates template presence in `ops/src/manifests`, loads tracked files through `git ls-files`, and resolves template membership recursively. During resolution it expands `@manifest:` includes, validates literal file entries, and expands globs only against tracked paths. It renders compiled manifests into a `var/tmp/compile.*` workspace first. Normal mode then emits an archive leaf under `archives/manifests/` with schema frontmatter fields `trace_id`, `packet_id`, `created_at`, and `previous`, plus embedded snapshots of compiled manifest bodies. Only after successful leaf emission does normal mode promote temporary compiled manifests into `ops/lib/manifests/` and print one parseable `MANIFEST_LEAF:` line. `--check` compares every temporary render byte-for-byte with its runtime manifest, emits no archive leaf, promotes no file, and reports the exact passing count.

## Anecdotal Anchor
Before compile adopted the temporary workspace and archive-first promotion contract, `context` and `llms` flows could consume mismatched manifest state during local edits. The current sequence closes that reliability gap by binding runtime promotion to successful immutable leaf emission.

## Integrity Filter Warnings
`ops/bin/compile` exits non-zero on unknown or duplicate arguments, missing template files, missing tracked file entries, globs with zero tracked matches, empty resolution sets, leaf name collisions that persist after retry, temporary render failures, missing compiled manifests during snapshot assembly, missing runtime manifests during `--check`, or any byte mismatch. The command does not accept partial template resolution. Check mode changes tracked files `0` times.
