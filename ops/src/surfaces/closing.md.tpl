# Closing Block Sidecar — {{DP_ID}}

Write for an engineer running git log --oneline who has no surrounding context — identify the change, not the motivation.


Write for an engineer scanning twenty open PRs — make this parseable in under two seconds and distinct from the commit header in both verb and subject.


Write for a reviewer in the GitHub interface — use markdown, name what changed and why, identify risks, and tell the reviewer what to look at first.


Write for the trunk history reader — frame what landed on main, not what was worked on in the branch; verb and subject must differ from the commit header.


List file paths only — no prose, no commentary, no headings; this field is machine-readable and must be deliberately boring.


Ask the question you actually want a reviewer to engage with — name the specific tradeoff or risk this DP surfaces; do not use generic approval-seeking stems.
{{@include:ops/lib/manifests/CLOSING.md#section-1}}
