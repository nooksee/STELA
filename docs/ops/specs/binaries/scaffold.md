<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
Scaffold enforces a repeatable project directory baseline so each project starts from the same known filesystem contract and avoids manual setup inconsistency.

## Mechanics and Sequencing
Validate repository root and project-name format, ensure project path does not exist, read optional directory list from ops/lib/project/SCAFFOLD.md, create directories, and copy the scaffold spec into the project root.

## Anecdotal Anchor
Ad hoc project bootstrapping historically produced missing or misnamed folders; scaffold exists to make provisioning deterministic and machine-auditable.

## Integrity Filter Warnings
The command exits on missing scaffold spec, invalid slug, non-root execution context, or preexisting project directory to prevent partial provisioning states.