<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/editor.sh` centralizes editor resolution, narrative capture, and narrative validation so closeout author-input behavior is deterministic and reusable. This prevents binary-local drift in scaffold handling and placeholder rejection.

## Mechanics and Sequencing
The script provides helper functions for certify-class workflows:
1. `editor_write_narrative_scaffold <path>` writes canonical Contractor Execution Narrative scaffold text.
2. `editor_resolve_command [explicit]` resolves editor command in strict order: explicit argument, `STELA_EDITOR`, `EDITOR`, fallback command.
3. `editor_capture_narrative_interactive <scaffold_path> [explicit_editor]` prompts and launches editor command against scaffold.
4. `editor_load_narrative_from_file <source_path> <target_path>` copies non-interactive narrative input into the working scaffold path.
5. `editor_validate_narrative_file <path>` enforces required narrative headings, required Decision Leaf field lines, placeholder-token rejection, untouched-scaffold-line rejection, and repo-relative path policy.

The script is sourced by `ops/bin/certify`; it does not generate RESULTS directly.

## Anecdotal Anchor
DP-OPS-0153 exposed that narrative quality could pass structural checks while retaining low-signal scaffold text. A shared helper with strict content checks is the bounded fix that avoids rewriting certify behavior across multiple call sites.

## Integrity Filter Warnings
The helper assumes caller context provides `REPO_ROOT` and `die` from `ops/lib/scripts/common.sh`. Editor command execution uses shell invocation and must be treated as trusted operator input. Validation rejects unchanged scaffold lines by exact match, so future scaffold-text edits must remain synchronized between helper and lints.
