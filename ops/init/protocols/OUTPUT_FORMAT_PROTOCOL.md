# Output Format Protocol

## Purpose
Define how operators and workers structure outputs and metadata surfaces.

## Scope
Applies to all deliverables that culminate in a PR, including DP handoffs and merge metadata.

## Verification
- Not run (operator): confirm outputs match this protocol.

## Risk+Rollback
- Risk: inconsistent or uncopyable metadata slows review and merges.
- Rollback: revert to the prior protocol and follow the last known-good pattern.

## Canon Links
- ops/contracts/OUTPUT_FORMAT_CONTRACT.md
- ops/templates/PR_DESCRIPTION_TEMPLATE.md
- ops/templates/MERGE_NOTE_TEMPLATE.md
- ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md

---

## 1) Metadata kit surfaces (always-on)
Required surfaces, in order:
1) IDE commit subject.
2) PR title + PR description (markdown).
3) Merge commit subject + plaintext body, then merge-note comment (markdown).

PR description headings must be: Purpose / What shipped / Scope / Verification / Risk+Rollback / Canon updates.

## 2) Formatting rule (header + fenced payload)
For every metadata surface and any pasteable payload:
- Provide a short prose header that describes the content.
- Place the exact payload inside a fenced code block for copy/paste.
- Keep prose outside code fences.

## 3) Delivery sequence (DP-first, metadata kit later)
- Operator dispatches the DP first.
- Worker returns work results (summary, diff, verification).
- After results, the Worker provides the metadata kit surfaces in order.
- The DP must require metadata surfaces, but the final filled kit comes after work results.

## 4) Pasteable payloads (general)
- Commands, diffs, and file content must be fenced.
- Do not mix instructions or commentary inside fenced payloads.
