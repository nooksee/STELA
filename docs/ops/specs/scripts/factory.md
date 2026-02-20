<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
factory.sh centralizes lifecycle helper logic for definition workflows so rendering, head-pointer updates, and safety checks are consistent across agent/task/skill operations.

## Mechanics and Sequencing
Provide redaction, trace-id resolution, leaf-path derivation, head read/write utilities, frontmatter stripping, template rendering wrappers, slugification, placeholder detection, and task-field extraction helpers.

## Anecdotal Anchor
Lifecycle scripts diverged when each carried bespoke pointer and rendering logic; this shared library reduces divergence by making one implementation path reusable.

## Integrity Filter Warnings
Helpers assume required environment variables and head files are valid; missing pointers, duplicate leaf targets, or failed rendering steps trigger hard exits to prevent registry corruption.