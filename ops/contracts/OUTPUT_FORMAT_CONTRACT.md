# Output Format Contract

## Purpose
Define required output structure for operators and workers.

## Scope
Applies to all deliverables that culminate in a PR.

## Requirements
- Metadata kit surfaces are always-on: IDE commit subject, PR title + markdown description, merge commit subject + plaintext body, merge-note comment (markdown).
- Each metadata surface must be delivered as a prose header followed by a fenced block for copy/paste.
- Pasteable payloads (commands, diffs, file content) must be fenced; explanations stay in prose.
- Follow canon protocols/templates; do not invent paths.

## Verification
- Not run (operator): check format requirements.

## Risk+Rollback
- Risk: inconsistent output formatting slows review and merge hygiene.
- Rollback: revert this contract and follow prior canon.

## Canon Links
- ops/init/protocols/OUTPUT_FORMAT_PROTOCOL.md
- ops/templates/PR_DESCRIPTION_TEMPLATE.md
- ops/templates/MERGE_NOTE_TEMPLATE.md
