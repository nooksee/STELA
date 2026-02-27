# Closing Block Sidecar — {{DP_ID}}

Identify the change, not the motivation. Write a concise summary (ideally under 50 characters) in the imperative mood (e.g., "Add," "Fix," "Refactor") that completes the sentence: "If applied, this commit will [your message]". Focus strictly on what changed, as the how is visible in the diff and the why belongs in the commit body.


Create a scannable summary for an engineer managing multiple open PRs. Ensure the title is distinct from the commit header in both verb and subject [OP]. Use a standard format like [WORKSTREAM][TASKID] TYPE: CHANGE to allow for quick parsing under two seconds. Maintain brevity while being precise enough to describe the software impact without vague phrasing like "Fix bug".


Provide essential context for the reviewer using GitHub Flavored Markdown. Explicitly name what changed and why (motivation), identify any technical risks or trade-offs, and provide a clear "start here" instruction to guide the reviewer to the most critical files first.


Frame what has landed on the main branch rather than describing the work done within the branch [OP]. The verb and subject must differ from individual commit headers to differentiate a large branch merge from simple patches in the trunk history. Use the imperative mood to remain consistent with Git’s automated messages.


List file paths only. This field must be machine-readable and deliberately boring, containing no prose, commentary, or Markdown headings [OP]. If additional context is required for humans, it should be placed in the commit body, but this specific field is reserved for a clean, parseable list of modified paths.


Surface the specific question, trade-off, or risk you want a reviewer to engage with [OP]. Avoid generic approval-seeking stems; instead, be explicit about the type of feedback needed (e.g., technical approach vs. design critique) and @mention specific individuals or teams if their expertise is required for the identified risk.
{{@include:ops/lib/manifests/CLOSING.md#section-1}}
