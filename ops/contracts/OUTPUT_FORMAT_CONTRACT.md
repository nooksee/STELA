# Output Format Contract

## Purpose
Define required output structure for operators and workers.

## Scope
Applies to all deliverables that culminate in a PR.

## Requirements

### Metadata kit surfaces (always-on)
- IDE commit subject.
- PR title + PR description (markdown).
- Merge commit subject + plaintext body, then merge-note comment (markdown).

Each metadata surface must be delivered as a prose header followed by a fenced block for copy/paste.

### Two modes (always separate)
Any response that includes commands, diffs, or file content must be split into:
A) Explainer (read-only)
B) COPY/PASTE (verbatim payload)

### Copy/paste markers (required)
All pasteable payloads must be bounded with markers:
- Put these markers inside the code fence:
  - "COPY EVERYTHING BETWEEN THE LINES"
  - a line of dashes
  - payload
  - a line of dashes (or "END COPY BLOCK")
- Put "STOP COPYING" outside the code fence.

### Terminal safety protocol
- No mystery blobs: never provide huge chained shell scripts.
- Small slices: commands in 1-3 line blocks.
- Label each block: what it does ("Block 1 - status", "Block 2 - verify tree").
- Pause discipline: after each command block, Operator pastes output before proceeding.
- Syntax-highlighting honesty: do not label a block "yaml" unless it is real YAML.

### File editing standard
Preferred order:
1) Unified diff for small edits.
2) Full file replacement for new files or heavy refactors.
3) Never invent file paths; if unsure, point to canon truth docs (PROJECT_MAP.md / CANONICAL_TREE.md).

### Verification minimums
- Branch name correct (`work/<topic>-YYYY-MM-DD`).
- Only scoped files changed.
- Forbidden zones untouched (upstream/, .github/, public_html/ unless explicitly instructed).
- repo-gates are green.

### Worker delivery rules
- Output must include a brief summary + git diff.
- Never commit or push; operator handles commit/push after review.

## Verification
- Not run (operator): check format requirements.

## Risk+Rollback
- Risk: inconsistent output formatting slows review and merge hygiene.
- Rollback: revert this contract and follow prior canon.

## Canon Links
- ops/init/protocols/OUTPUT_FORMAT_PROTOCOL.md
- ops/templates/PR_DESCRIPTION_TEMPLATE.md
- ops/templates/MERGE_NOTE_TEMPLATE.md
