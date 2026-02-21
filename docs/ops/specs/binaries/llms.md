<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/llms` exists to keep machine discovery entry points synchronized with current manifest truth. It prevents SSOT drift where root `llms` bundles reference outdated manifest memberships or stale synthesis output.

## Mechanics and Sequencing
The binary parses optional out directory and manifest override arguments, enforces repo-root execution, validates dependencies, and runs `ops/bin/compile` before synthesis. It synthesizes `llms-core.txt` from the core manifest and `llms-full.txt` from the discovery manifest into a temporary workspace, verifies both generated files are non-empty, constructs a fresh root `llms.txt` index with current HEAD metadata and bundle pointers, and copies all three outputs to repository root. When `--out-dir` points outside root, it also writes mirrored copies to that destination. It prints the written path set on success.

## Anecdotal Anchor
A recurring risk in AI-driven intake was that discovery pointers could remain static while manifest state changed underneath them. `ops/bin/llms` reduces that drift by forcing compile-first synthesis and root bundle refresh on every invocation.

## Integrity Filter Warnings
`ops/bin/llms` exits on unknown arguments, missing dependencies, missing manifest files, compile failures, empty synthesized output files, and write failures. It always rewrites root bundle files and does not provide a no-write preview mode.
