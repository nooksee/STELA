<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/template` exists as the single command router for template rendering domains so operators invoke one stable entrypoint while enforcement remains centralized in `ops/bin/manifest` and `ops/bin/factory`. It prevents render-path divergence that would occur if packet and definition templates used separate ad hoc front-end commands.

## Mechanics and Sequencing
The binary parses mode and template type arguments, supports both `template <type>` and `template render <type>` call forms, emits tool telemetry leaf boundaries, and dispatches target groups. It routes `agent`, `task`, and `skill` requests to `ops/bin/factory` with the original argument vector, and routes `dp`, `results`, `task-surface`, and `spec` requests to `ops/bin/manifest` with the same argument vector. Unknown or missing types terminate execution with explicit errors.
Every template file in `ops/src/` must carry `ff_target` and `ff_band` YAML front matter fields. These fields are the CCD density contract for files rendered from the template: `ff.sh` reads the declared fields from rendered output and fails the gate if measured density falls outside the declared band. Files rendered from templates without these fields will emit a WARNING from `ff.sh` in Phase 1 and a FAILURE in Phase 2 and beyond. The `ops/src/docs/` template group (Template IDs TPL-12 through TPL-17) is routed to `ops/bin/manifest` with the `--type=docs` argument vector. These templates are registered in `docs/ops/registry/templates.md`.

## Anecdotal Anchor
The DP-OPS-0067 template-system cutover established canonical metadata parsing, include resolution, and frontmatter stripping rules. `ops/bin/template` preserves that cutover by keeping one external command entrypoint while internal render engines enforce the mechanics.

## Integrity Filter Warnings
`ops/bin/template` exits on missing mode and type arguments or unknown template types. It contains no render fallback path and inherits failure behavior directly from `ops/bin/factory` and `ops/bin/manifest`, including strict unresolved-token and include-graph validation failures.
