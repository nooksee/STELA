# DB-PR-META - Post-Approval Metadata Surfaces

DB-PR-META is the approval-gated metadata output used after approval for commits, PRs, and merge notes.

## Surfaces (SSOT; order is canonical)
1) Commit message
2) PR title
3) PR description (Markdown)
4) Merge commit message
5) Extended description
6) Merge note (PR comment, Markdown)

## UI mapping (order + payload type)
1) Commit message -> IDE "Commit message" - plain text (one line)
2) PR title -> GitHub PR "Add a title" - plain text (one line)
3) PR description (Markdown) -> GitHub PR "Add a description" - Markdown
4) Merge commit message -> GitHub merge "Commit message" - plain text (one line)
5) Extended description -> GitHub merge "Extended description" - plain text (body)
6) Merge note (PR comment, Markdown) -> GitHub PR "Add a comment" - Markdown

## Approval gate (IN-LOOP, required pattern)
- Required approval pattern (case-insensitive; extra whitespace allowed):
  - MUST contain: `APPROVE` + `<DP-ID>` + `EMIT` + `DB-PR-META`
  - Example: `APPROVE DP-OPS-0025 EMIT DB-PR-META`
- Approval must be a standalone line outside OPEN prompt text, OPEN intent, and outside quoted/fenced blocks.
- Ambiguous variants are invalid (missing DP-ID, missing EMIT, "i approve db-pr-meta" without DP-ID).
- If approval is missing, buried, or malformed, refuse with this single paste-ready line:
  - `APPROVE <DP-ID> EMIT DB-PR-META`

## Output format
- Each surface is emitted as a header line above a single fence.
- Each fence contains only the payload for that surface; no extra prose inside fences.
- Six blocks only; no alternate labels are permitted.
- Payload type must match the UI mapping (plain text vs Markdown).

## Micro-style (anti-slop)
- Prefer verbs + concrete nouns ("Require worker after-action bundle...", "Update DP template...").
- Avoid self-referential AI phrasing ("as an AI...", "I think...").
- Avoid hype words ("awesome", "fantastic", "super") in metadata surfaces.
- Prefer repo nouns (paths, scripts, rules) over vibes.
- Declarative, minimal, operator-written; no filler.
