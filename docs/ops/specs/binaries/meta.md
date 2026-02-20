<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
Meta formalizes project-context artifact generation so OPEN and project-scoped DUMP artifacts are emitted consistently for downstream review and handoff workflows.

## Mechanics and Sequencing
Validate repository context and project existence, then invoke ops/bin/open with a project intent tag and ops/bin/dump in project scope for the same project slug.

## Anecdotal Anchor
Manual project context capture often missed one of OPEN or DUMP artifacts; meta packages both operations to keep evidence generation complete and reproducible.

## Integrity Filter Warnings
Execution stops on missing project directory, non-root execution, or upstream open/dump failure; the binary intentionally does not degrade to partial artifact output.