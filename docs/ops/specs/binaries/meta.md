<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/meta` guarantees one-command project context capture while preserving its stable CLI (`ops/bin/meta <project-name>`). DP-OPS-0145 routes that capture through `ops/bin/bundle --profile=project` so project workflows receive the same deterministic transport contract as analyst/architect/audit flows.

## Mechanics and Sequencing
The binary enforces repo-root execution, requires exactly one project-name argument, validates that `projects/<name>` exists, then invokes `ops/bin/bundle --profile=project --project=<name> --out=auto`. Bundle internally executes OPEN and project-scoped dump capture, selects prompt stance, and emits both bundle text artifact and machine-readable sidecar manifest in `storage/handoff/`. Meta remains a thin orchestration wrapper and prints one completion line on success.

## Anecdotal Anchor
A recurring project-context failure class involved manual capture runs where one of the required artifacts was missing. The original meta wrapper solved this for OPEN + dump; bundle integration extends the same protection to prompt stance and routing metadata without changing operator-facing meta ergonomics.

## Integrity Filter Warnings
`ops/bin/meta` exits on non-root execution, missing project argument, extra arguments, missing project directory, or any non-zero exit from `ops/bin/bundle`. The binary does not emit partial success output when bundle generation fails.
