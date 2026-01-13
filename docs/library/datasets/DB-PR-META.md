# DB-PR-META - Post-Approval Metadata Surfaces

DB-PR-META is the approval-gated metadata output used after approval for commits, PRs, and merge notes.

## Surfaces (SSOT)
- Commit message
- Extended description
- PR title
- PR description (Markdown)
- Merge commit message
- Merge note (PR comment, Markdown)

## Output format
- Each surface is emitted as a header line above a single fence.
- Each fence contains only the payload for that surface; no extra prose inside fences.
- Six blocks only; no alternate labels are permitted.

## Micro-style (anti-slop)
- Prefer verbs + concrete nouns ("Require worker after-action bundle...", "Update DP template...").
- Avoid self-referential AI phrasing ("as an AI...", "I think...").
- Avoid hype words ("awesome", "fantastic", "super") in metadata surfaces.
- Prefer repo nouns (paths, scripts, rules) over vibes.
- Declarative, minimal, operator-written; no filler.
