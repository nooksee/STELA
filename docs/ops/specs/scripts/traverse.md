<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
traverse.sh provides a deterministic, scope-aware file selection stream so downstream dump and synthesis workflows operate on explicit repository subsets.

## Mechanics and Sequencing
Parse scope and filter arguments, validate repo-root execution and project constraints, iterate git-tracked files, apply include/exclude/glob filters, skip binary files, print selected paths, and fail if the selection is empty.

## Anecdotal Anchor
Context captures became inconsistent when path selection logic was duplicated across scripts; traverse standardized this into a single reusable stream generator.

## Integrity Filter Warnings
The script exits on invalid scope combinations, non-root invocation, missing project directories, absent git context, or zero-file selection to prevent silent partial dumps.