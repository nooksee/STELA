<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/meta` is a project-only compatibility shim that preserves the stable CLI (`ops/bin/meta <project-name>`) while delegating all routing and artifact generation to `ops/bin/bundle`. Front-door authority remains in bundle so profile routing logic is not duplicated.

## Mechanics and Sequencing
The binary enforces repo-root execution, requires exactly one project-name argument, accepts optional `--out=auto|PATH`, validates project slug shape, validates that `projects/<name>` exists, checks front-door policy keys in `ops/lib/manifests/BUNDLE.md`, then invokes `ops/bin/bundle --profile=project --project=<name> --out=<resolved-value>`. Bundle internally executes OPEN and project-scoped dump capture, selects stance contract text, and emits both bundle text artifact and machine-readable sidecar manifest in `storage/handoff/`. Meta remains a thin wrapper and prints one completion line on success.

Required policy keys:
- `frontdoor_canonical_binary=ops/bin/bundle`
- `frontdoor_meta_mode=project_shim`
- `frontdoor_meta_deprecation_status` (non-empty)
- `frontdoor_meta_remove_after_dp` (non-empty)

## Anecdotal Anchor
A recurring project-context failure class involved manual capture runs where one of the required artifacts was missing. The original meta wrapper solved this for OPEN + dump; bundle integration extends the same protection to prompt stance and routing metadata without changing operator-facing meta ergonomics.

## Integrity Filter Warnings
`ops/bin/meta` exits on non-root execution, missing project argument, invalid project slug, extra arguments beyond optional `--out=...`, missing project directory, missing or mismatched front-door policy keys, or any non-zero exit from `ops/bin/bundle`. The binary does not emit partial success output when bundle generation fails.
