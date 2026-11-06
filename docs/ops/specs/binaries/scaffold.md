<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/scaffold` exists to create a repeatable project filesystem baseline from one canonical scaffold spec. It prevents initialization drift where manual project setup introduces missing or misnamed directories.

## Mechanics and Sequencing
The binary enforces repo-root execution, requires exactly one project name argument, validates slug format with lowercase alphanumeric and hyphen rules, blocks execution if the target project directory already exists or the name already has a registry row, and requires `ops/lib/project/SCAFFOLD.md`, `ops/lib/project/STELA.md`, and `docs/ops/registry/projects.md` (with a `Current:` line) to exist. It then does three jobs (DP-OPS-0273): it creates `projects/<name>` and one directory for each scaffold spec line that matches `- <dirname>/`, writes `SCAFFOLD.md` and `STELA.md` into the project from the two source files with `{{PROJECT_ID}}` and `{{DISPLAY_NAME}}` resolved to the name and `{{CREATED_AT}}` to the UTC date, and appends one row to the project registry while moving the `Current:` line from `none` to the name (or appending the name to the list). It prints the project path, the contract path, and a reminder to run `./ops/bin/map`. Allowlist rows, packet drafting, and the map regeneration stay outside the binary.

## Anecdotal Anchor
In the DP-OPS-0078 project tooling fission period, ad hoc bootstrapping repeatedly produced directory contract mismatches that later blocked automation and review. `ops/bin/scaffold` was introduced to make initial project shape deterministic from one source.

## Integrity Filter Warnings
`ops/bin/scaffold` exits on invalid project names, non-root invocation, preexisting project paths, an existing registry row for the name, or a missing scaffold spec, contract template, or registry. It creates directories only for lines that match its list parser, so malformed scaffold spec lines are ignored rather than auto-corrected. Every refusal happens before the first write. `tools/test/scaffold.sh` proves the three jobs and the refusals in a copy of the working tree.
