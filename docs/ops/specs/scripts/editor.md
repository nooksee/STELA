<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/editor.sh` centralizes editor resolution, scaffold capture, and scaffold validation so author-input behavior is deterministic and reusable across binaries. This prevents binary-local drift in scaffold handling and untouched-instruction rejection.

## Mechanics and Sequencing
The script provides helper functions for certify and draft scaffold workflows:
1. `editor_write_narrative_scaffold <path>` writes canonical Worker Execution Narrative scaffold text. The `### Preflight State` instruction requires verbatim pre-edit freshness proof for `git rev-parse --abbrev-ref HEAD`, `git rev-parse --short HEAD`, and `git status --porcelain`, plus a short preflight lint status summary.
2. `editor_resolve_command [explicit]` resolves editor command in strict order: explicit argument, `STELA_EDITOR`, `EDITOR`, fallback command.
3. `editor_capture_narrative_interactive <scaffold_path> [explicit_editor]` prompts and launches editor command against scaffold.
4. `editor_load_narrative_from_file <source_path> <target_path>` copies non-interactive narrative input into the working scaffold path.
5. `editor_validate_narrative_file <path>` enforces required narrative headings, required Decision Leaf field lines, placeholder-token rejection, untouched-scaffold-line rejection, required freshness-command presence inside `### Preflight State`, and repo-relative path policy.
6. `editor_write_plan_scaffold <path>` writes canonical plan scaffold headings and instruction lines.
7. `editor_write_draft_slots_scaffold <path>` writes canonical draft slot scaffold blocks and instruction lines.
8. `editor_capture_scaffold_interactive <label> <path> [explicit_editor]` is the generic interactive scaffold capture helper shared by narrative and draft-assist pathways.
9. `editor_load_scaffold_from_file <source_path> <target_path>` is the generic non-interactive scaffold ingest helper.
10. `editor_validate_plan_scaffold_file <path>` enforces required plan headings and untouched-instruction rejection.
11. `editor_validate_draft_slots_scaffold_file <path>` enforces required slot blocks and untouched-instruction rejection.

The script is sourced by `ops/bin/certify` and `ops/bin/draft`; it does not generate RESULTS directly.

## Anecdotal Anchor
DP-OPS-0153 exposed that narrative quality could pass structural checks while retaining low-signal scaffold text. A shared helper with strict content checks is the bounded fix that avoids rewriting certify behavior across multiple call sites.

## Integrity Filter Warnings
The helper assumes caller context provides `REPO_ROOT` and `die` from `ops/lib/scripts/common.sh`. Editor command execution uses shell invocation and must be treated as trusted operator input. Validation rejects unchanged scaffold lines by exact match and now also requires the three freshness-gate command strings inside `### Preflight State`, so future scaffold-text edits must remain synchronized between scaffold writers and validators.
