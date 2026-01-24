# Output Format Contract

## Purpose
Define required output structure for operators and workers.

## Scope
Applies to all deliverables that culminate in a PR.

## Requirements

### Phase Lock (precedence)
Phase Lock rules override other output formatting requirements.

  - No DP edits.
  - No DP reprint.
  - No commentary.
- If the operator message contains "SEE ATTACHED" + "REFRESH STATE" and requests revise/update of a DP:
  - Output MUST be the DP only.
  - Exactly one code block containing the DP.
  - No extra text.
- If the operator message contains "DISCUSS-ONLY":
  - No artifacts.
  - No copy/paste blocks.
- If the operator uses a Phase Error Recovery command (contains "PHASE ERROR" / "BLOCKED ACKNOWLEDGED" / "RE-EMIT CLEAN"):
  - Obey it literally (only the requested re-emit/revision).
  - Do not expand scope.

### Metadata kit surfaces (always-on)
- IDE commit subject.
- PR title + PR description (markdown).
- Merge commit subject + plaintext body, then merge-note comment (markdown).

Each metadata surface must be delivered as a prose header followed by a fenced block.
- Single-line surfaces: IDE commit subject, PR title, merge commit subject (one line only).
- Multi-line surfaces: PR description (markdown), merge commit body (plaintext), merge-note comment (markdown) as one block each.
- Never mix subject and body in one block.
- Metadata kits do NOT use COPY/STOP prose markers; the code fence is the copy boundary and the UI copy button is sufficient.

### Two modes (always separate)
Any response that includes commands, diffs, or file content must be split into:
A) Explainer (read-only)
B) Payload (verbatim)
Use "TYPE LINE BY LINE" for operator command payloads; use "COPY/PASTE" for diffs and file content.

### Copy/paste markers (non-command payloads)
All pasteable diffs and file payloads must be bounded with markers:
- Put these markers inside the code fence:
  - "COPY EVERYTHING BETWEEN THE LINES"
  - a line of dashes
  - payload
  - a line of dashes (or "END COPY BLOCK")
- Put "STOP COPYING" outside the code fence.
Metadata kits and operator command blocks do NOT use these markers.

### Operator Command Delivery: TYPE LINE BY LINE
- When giving terminal commands to the operator, label the block "TYPE LINE BY LINE" (or "ENTER LINE BY LINE").
- Keep each command block to 1-3 lines; do not chain long scripts or send mystery blobs.

### Terminal safety protocol
- No mystery blobs: never provide huge chained shell scripts.
- Small slices: commands in 1-3 line blocks.
- Label each block as "TYPE LINE BY LINE" with a short description of what it does.
- Pause discipline: after each command block, Operator pastes output before proceeding.
- Syntax-highlighting honesty: do not label a block "yaml" unless it is real YAML.

### File editing standard
Preferred order:
1) Unified diff for small edits.
2) Full file replacement for new files or heavy refactors.
3) Never invent file paths; if unsure, point to canon truth docs (TRUTH.md Section 3 / TRUTH.md Section 4).

### Verification minimums
- Branch name correct (`work/<topic>-YYYY-MM-DD`).
- Only scoped files changed.
- Forbidden zones untouched (upstream/, .github/, public_html/ unless explicitly instructed).
- repo-gates are green.

### Worker delivery rules
- Output must include a brief summary + git diff.
- Never commit or push; operator handles commit/push after review.

### Handoff artifacts (repo-local)
- Handoff directory (canonical): `storage/handoff/`
- Results file (required for DP handoff): `storage/handoff/<DP-ID>-RESULTS.md`
  - Basename must be UPPERCASE; extension must be `.md` (lowercase).
  - Contents must match the full worker results, including the RECEIPT.
- OPEN capture filenames (repo-local):
  - `storage/handoff/OPEN-<branch>-<YYYY-MM-DD>-<HEAD>.txt`
  - `storage/handoff/OPEN-PORCELAIN-<branch>-<YYYY-MM-DD>-<HEAD>.txt`
- When OPEN porcelain is large, the OPEN output must show entry count + a preview capped at 50 lines; full porcelain lives in the OPEN-PORCELAIN file.
- Dump artifacts remain under `storage/dumps/` (payload + manifest; tarball when compressed).

## Verification
- Not run (operator): check format requirements.

## Risk+Rollback
- Risk: inconsistent output formatting slows review and merge hygiene.
- Rollback: revert this contract and follow prior canon.

## Canon Links
