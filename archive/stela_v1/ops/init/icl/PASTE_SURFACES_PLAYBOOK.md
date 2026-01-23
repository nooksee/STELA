# Paste Surfaces Playbook

## Purpose
Ensure operator-facing commands and metadata are delivered safely and consistently.

## Golden Rule
For operator commands: TYPE LINE BY LINE. For metadata: provide the exact payload; no COPY/STOP prose markers required.

## Paste Surfaces (what goes where)
- IDE commit subject: single line.
- PR title: single line.
- PR description: one markdown body block.
- Merge commit subject: single line.
- Merge commit body: one plaintext body block.
- Merge-note PR comment: one markdown body block.

## Operator Command Delivery
- Label command blocks: "TYPE LINE BY LINE" (or "ENTER LINE BY LINE").
- Keep each command block to 1-3 lines; do not chain long scripts.
- Provide a short description of what each block does.

## Do NOT
- Do not mix subject and body in one block.
- Do not include STOP COPYING inside templates.
- Do not use dashed rulers or "BETWEEN THE LINES" markers.
- Do not output long chained scripts or mystery blobs.

## Notes
- Code fences are the copy boundary for metadata payloads.
- The UI copy button is sufficient for DB-PR-META payloads.
