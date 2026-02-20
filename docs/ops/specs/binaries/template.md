<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/template` exists as the single command router for template rendering domains so operators invoke one stable entrypoint while enforcement remains centralized in `ops/bin/manifest` and `ops/bin/factory`. It prevents render-path divergence that would occur if packet and definition templates used separate ad hoc front-end commands.

## Mechanics and Sequencing
The binary parses mode and template type arguments, supports both `template <type>` and `template render <type>` call forms, emits tool telemetry leaf boundaries, and dispatches target groups. It routes `agent`, `task`, and `skill` requests to `ops/bin/factory` with the original argument vector, and routes `dp`, `results`, `task-surface`, and `spec` requests to `ops/bin/manifest` with the same argument vector. Unknown or missing types terminate execution with explicit errors.

## Anecdotal Anchor
The DP-OPS-0067 template-system cutover established canonical metadata parsing, include resolution, and frontmatter stripping rules. `ops/bin/template` preserves that cutover by keeping one external command entrypoint while internal render engines enforce the mechanics.

## Integrity Filter Warnings
`ops/bin/template` exits on missing mode and type arguments or unknown template types. It contains no render fallback path and inherits failure behavior directly from `ops/bin/factory` and `ops/bin/manifest`, including strict unresolved-token and include-graph validation failures.
