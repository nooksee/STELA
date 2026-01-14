# DB-PR-META - Post-Approval Metadata Surfaces

DB-PR-META is the approval-gated metadata output used after approval for commits, PRs, and merge notes.

## Surfaces (SSOT)
- Commit message
- PR title
- PR description (Markdown)
- Merge commit message
- Extended description
- Merge note (PR comment, Markdown)

## UI mapping (order + payload type)
1) Commit message -> IDE "Commit message" - plain text (one line)
2) PR title -> GitHub PR "Add a title" - plain text (one line)
3) PR description (Markdown) -> GitHub PR "Add a description" - Markdown
4) Merge commit message -> GitHub merge "Commit message" - plain text (one line)
5) Extended description -> GitHub merge "Extended description" - plain text (body)
6) Merge note (PR comment, Markdown) -> GitHub PR "Add a comment" - Markdown

## Approval gate (exact phrases)
- Acceptable approval phrases:
  - `I approve — DB-PR-META for <context>`
  - `I approve - DB-PR-META for <context>`
- `<context>` is required and may be any non-empty text.
- If approval is missing or malformed, refuse with:
  - `Approval not given. DB-PR-META withheld. Paste to approve: I approve — DB-PR-META for <context>.`

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
