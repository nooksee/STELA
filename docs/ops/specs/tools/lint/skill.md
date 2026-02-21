<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/skill.sh` enforces skill-definition integrity by proving that registry records, filesystem files, and minimum section schema stay synchronized. The script also guards context boundaries by rejecting any skill references inside global context manifest state, which prevents on-demand definitions from being promoted into always-loaded context.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and require `docs/ops/registry/skills.md` plus `ops/lib/manifests/CONTEXT.md`.
2. Scan the context manifest for skill path or skill ID tokens and fail when any match appears.
3. Parse registry rows (`ID` and file path), enforce unique IDs and unique file paths, and fail missing referenced files.
4. Require `opt/_factory/skills`, then detect ghost `S-LEARN-*.md` files that have no registry entry.
5. For each skill file, reject placeholder markers, enforce header shape, and enforce required sections (`Provenance`, `Scope`, `Pointers`, `Invocation Guidance`) including duplicate-section rejection and non-empty content checks.
6. Return non-zero when any contract violation is detected.

## Anecdotal Anchor
The gate targets the drift class where manual edits to skill definitions bypassed registry validation and introduced ghost files plus stale registry pointers. Those sessions required manual file/registry reconciliation before normal promotion flow could continue.

## Integrity Filter Warnings
Missing critical files, duplicate IDs, duplicate file paths, placeholder tokens, and missing required sections are all hard failures. Scope is limited to `opt/_factory/skills/S-LEARN-*.md` plus registry rows; archived candidate files outside that namespace are not scanned by this script.
