<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/scaffold` exists to create a repeatable project filesystem baseline from one canonical scaffold spec. It prevents initialization drift where manual project setup introduces missing or misnamed directories.

## Mechanics and Sequencing
The binary enforces repo-root execution, requires exactly one project name argument, validates slug format with lowercase alphanumeric and hyphen rules, blocks execution if the target project directory already exists, and requires `ops/lib/project/SCAFFOLD.md` to exist. It creates `projects/<name>`, reads scaffold spec lines, creates directories for each line that matches the list pattern `- <dirname>/`, copies `ops/lib/project/SCAFFOLD.md` into the new project as `SCAFFOLD.md`, and prints the created project path.

## Anecdotal Anchor
In the DP-OPS-0078 project tooling fission period, ad hoc bootstrapping repeatedly produced directory contract mismatches that later blocked automation and review. `ops/bin/scaffold` was introduced to make initial project shape deterministic from one source.

## Integrity Filter Warnings
`ops/bin/scaffold` exits on invalid project names, non-root invocation, preexisting project paths, or missing scaffold spec file. It creates directories only for lines that match its list parser, so malformed scaffold spec lines are ignored rather than auto-corrected.
