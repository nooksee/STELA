---
template_type: surface
template_id: closing
template_version: 4
ff_target: operator-technical
ff_band: "30-45"
requires_slots:
  - DP_ID
---
# Closing Block Sidecar — {{DP_ID}}

Write each field's content on the lines under its label in Section 1 below, then delete every guidance paragraph above Section 1, including this one. Certify rejects a sidecar that still carries guidance text, and the validator forbids braces, brackets, asterisks, backticks, and command substitution anywhere in this file. Field semantics are canonical in docs/ops/specs/surfaces/results.md.

Commit Message: identify the change, not the motivation. One imperative-mood line, ideally under 50 characters, that completes the sentence "If applied, this commit will ...". The how is visible in the diff and the why belongs in the commit body.

Create Pull Request (Title): headline what this pull request is and why it is being reviewed, parseable in under two seconds by an engineer scanning twenty open pull requests. Keep the verb and subject distinct from the commit header. A plain form such as "WORKSTREAM DP-OPS-XXXX TYPE: CHANGE" works; bracketed tags do not pass the validator.

Create Pull Request (Description): give the reviewer essential context in GitHub Flavored Markdown using at least one heading or list item; the style lint requires a markdown construct and the certify validator forbids asterisks and backticks, so headings and dash lists are the forms that pass both. Name what changed and why, identify technical risks or trade-offs, and give a clear "start here" instruction that points at the most critical files first.

Confirm Merge (Commit Message): frame what has landed on the main branch rather than describing the work done within the branch. The verb and subject must differ from individual commit headers so a branch merge reads differently from simple patches in trunk history. Imperative mood, consistent with Git's automated messages.

Confirm Merge (Extended Description): list file paths only, one per line, repo-relative, under an approved prefix (.github/, tools/, ops/, docs/, opt/, projects/, storage/, archives/, logs/). No prose, commentary, or headings. Root-level canonical surfaces (PoW.md, SoP.md, TASK.md, llms txt bundles) are accounted for in the RESULTS narrative, not here.

Confirm Merge (Add a Comment): surface the specific question, trade-off, or risk you want a reviewer to engage with, as one genuine question that ends with a question mark. Avoid generic approval-seeking stems; be explicit about the type of feedback needed.

Each of the six content blocks must open with a different word.
{{@include:ops/lib/manifests/CLOSING.md#section-1}}
