<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/project` is retired. DP-OPS-0145 removes the deprecated compatibility wrapper and consolidates context transport through `ops/bin/bundle` (profile routing and artifact contract) plus `ops/bin/meta` (stable project CLI wrapper).

## Mechanics and Sequencing
No runtime behavior remains for `ops/bin/project`; the executable is deleted from `ops/bin/`. Project workflows now use one of two canonical entrypoints:
1. `ops/bin/meta <project-name>` for one-command project capture.
2. `ops/bin/bundle --profile=project --project=<name> --out=auto` for direct bundle generation.

## Anecdotal Anchor
DP-OPS-0078 split project responsibilities across scaffold and meta but left `ops/bin/project` as transitional glue. DP-OPS-0145 completes that retirement after bundle routing became the canonical transport primitive.

## Integrity Filter Warnings
Any automation that still invokes `ops/bin/project` now fails immediately because the path no longer exists. Operators and scripts must migrate to meta or direct bundle invocation.
