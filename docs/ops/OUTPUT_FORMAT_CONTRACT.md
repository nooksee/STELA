# Output Formatting Contract

Objective: Make every AI→Human handoff safe, verifiable, and free of “mystery blobs.”

This contract applies to ChatGPT, Gemini, Copilot, contractors, and humans writing instructions.

## 1) The Two Modes (always separate them)
Any response that includes commands, diffs, or file content must be split into:

### A) Explainer (read-only)
- Purpose: context, reasoning, risk, and scope.
- Format: short bullets or short paragraphs.
- Rule: the Operator reads this; it is not meant to be pasted.

### B) COPY/PASTE (verbatim payload)
- Purpose: exact execution or exact file content.
- Format: fenced code blocks labeled as plain text (preferred) or diff blocks.
- Rule: must be bounded and copy-safe.

## 2) Copy/Paste Markers (required)
All pasteable payloads must be bounded with these markers:

- Put these markers INSIDE the code fence:
  - “COPY EVERYTHING BETWEEN THE LINES”
  - a line of dashes
  - payload
  - a line of dashes (or “END COPY BLOCK”)

- Put “STOP COPYING” OUTSIDE the code fence.

## 3) Terminal Safety Protocol (operator protection)
- No mystery blobs: never provide huge chained shell scripts.
- Small slices: commands in 1–3 line blocks.
- Label each block: what it does (“Block 1 — status”, “Block 2 — verify tree”).
- Pause discipline: after each command block, Operator pastes output before proceeding.
- Syntax-highlighting honesty: do not label a block “yaml” unless it is real YAML.

## 4) File Editing Standard (how to ship patches)
Preferred order:
1) Unified diff for small edits.
2) Full file replacement for new files or heavy refactors.
3) Never invent file paths; if unsure, point to canon truth docs (PROJECT_MAP.md / CANONICAL_TREE.md).

## 5) Verification checklist (minimum)
- Branch name correct (work/<topic>-YYYY-MM-DD).
- Only scoped files changed.
- Forbidden zones untouched (upstream/, .github/, public_html/ unless explicitly instructed).
- repo-gates are green.
