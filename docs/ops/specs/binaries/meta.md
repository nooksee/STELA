<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/meta` exists to guarantee that project context capture emits both freshness and payload artifacts in one command. It prevents evidence gaps where operators capture only OPEN or only project-scoped dump output.

## Mechanics and Sequencing
The binary enforces repo-root execution, requires exactly one project-name argument, validates that `projects/<name>` exists, then invokes `ops/bin/open` with a project-tagged intent and `--out=auto`. It then invokes `ops/bin/dump` with `--scope=project --project=<name> --format=chatgpt --out=auto`. After both commands succeed, it prints a single completion line for the project context run.

## Anecdotal Anchor
A recurring project-context failure class involved manual capture runs where one of the two required artifacts was missing, which blocked downstream review reproducibility. `ops/bin/meta` addresses that class by chaining both artifact commands under one success contract.

## Integrity Filter Warnings
`ops/bin/meta` exits on non-root execution, missing project argument, extra arguments, missing project directory, or any non-zero exit from upstream `open` or `dump`. The command does not emit partial success output when one upstream artifact command fails.
