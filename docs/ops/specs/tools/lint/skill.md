<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
skill lint protects definition integrity by enforcing registry/file synchronization, required section content, and context-manifest hazard exclusions for skill surfaces.

## Mechanics and Sequencing
Validate repository and required files, parse registry table rows, detect duplicate IDs/paths, ensure referenced files exist, enforce no skill references in context manifest, and validate each skill file header/sections/placeholders.

## Anecdotal Anchor
Skill definitions drifted from registry truth when manual edits bypassed validation; this lint exists to catch ghost files, stale registry pointers, and schema erosion early.

## Integrity Filter Warnings
The lint hard-fails on missing critical files, duplicate registry identifiers, placeholder tokens, or missing mandatory sections; output should be treated as blocking for release gates.