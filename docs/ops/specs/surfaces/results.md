<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Surface Specification: RESULTS

## Constitutional Anchor
`storage/handoff/DP-OPS-XXXX-RESULTS.md` is a generated audit receipt, not a hand-authored narrative.
It records certification execution details, verification command output, contractor execution narrative, and git impact.

## Operator Contract
- Surface generator: `ops/bin/certify`.
- Rendering pipeline: `ops/bin/template render results` (strict mode).
- Canonical template: `ops/src/surfaces/results.md.tpl`.
- Required sections and order:
  - `## Certification Metadata`
  - `## Scope Verification`
  - `### Integrity Lint Output`
  - `## Verification Command Log`
  - `## Git State Impact`
  - `### git diff --name-only`
  - `### git diff --stat`
  - `## Contractor Execution Narrative`
- Mandatory fields:
  - DP ID, UTC certification timestamp, work branch, and git hash.
  - Scope Verification entries for Target Files allowlist pointer, authoritative delivered `dp_source`, and current `dump_manifest` pointer value.
  - Integrity-lint output.
  - Per-command verification logs with exit outcomes.
  - Contractor Execution Narrative collected interactively at certify time with required subsections.
  - Closing sidecar validation is certify-internal and remains a hard gate via `storage/handoff/CLOSING-DP-OPS-XXXX.md`.

## Contractor Execution Narrative
The `## Contractor Execution Narrative` section is populated at certify time by `ops/bin/certify`. Certify writes a scaffold to a temp file and delegates capture to `ops/lib/scripts/editor.sh`: interactive editor mode by default, or non-interactive ingest via `--narrative-file=PATH`. The narrative is validated for required subsections, absence of placeholder tokens, and rejection of untouched scaffold prose before being rendered into RESULTS.

Required subsections:
- `### Preflight State`
- `### Implemented Changes`
- `### Closeout Notes`
- `### Decision Leaf`

The `### Decision Leaf` subsection must contain both:
- `Decision Required: Yes|No`
- `Decision Leaf: archives/decisions/... or None`

## Failure States and Drift Triggers
- Manual edits to generated RESULTS artifacts.
- Missing required section headings or reordered schema.
- Template drift between `tools/lint/results.sh` hash constant and `ops/src/surfaces/results.md.tpl`.
- Git hash mismatch between receipt content and `git rev-parse HEAD`.
- Missing or placeholder Contractor Execution Narrative content.
- Missing required narrative subsections or Decision Leaf field lines.
- Untouched narrative scaffold prose accepted as final content.

Enforcement linkage:
- `tools/lint/results.sh` validates template hash, schema headings, narrative structure, and git hash parity.
- `ops/bin/certify` validates the closing sidecar as a hard gate before rendering and runs `tools/lint/results.sh` after rendering.

## Mechanics and Sequencing
1. Maintain a human-authored closing sidecar at `storage/handoff/CLOSING-DP-OPS-XXXX.md`.
2. Run `ops/bin/certify --dp=DP-OPS-XXXX --out=auto`.
3. Certifier captures contractor execution narrative via editor helper and validates subsection structure/content.
4. Certifier validates the closing sidecar, runs integrity and verification gates, captures outputs, then renders RESULTS from template slots.
   - Scope Verification must record the authoritative packet source path carried in the delivered closeout packet as `dp_source`.
   - When certify replays from intake fallback and then moves the packet to processed storage, `dp_source` must record the processed path so RESULTS matches the delivered audit bundle and dump evidence.
5. Certifier lints the generated RESULTS artifact and exits non-zero on any failure.

## Forensic Insight
RESULTS is the executable evidence receipt for DP closeout.
It keeps verification outputs deterministic and replayable while embedding the contractor's execution narrative directly in the receipt, eliminating the need for a separate handoff surface and preventing drift between narrative and receipt.
Think of RESULTS like a flight recorder that captures what actually ran, what the contractor observed, and what failed before a merge decision is made.

## Mandatory Closing Sidecar Field Specifications

### Field: Commit Message
Audience: Engineer running `git log --oneline`.

Job: Identify the change with maximum compression. No motivation, no scope narrative. One imperative-mood line.

What good looks like: `Define closing sidecar field semantics for certify closeout`.

What bad looks like: `Improve documentation quality across workflow surfaces.` Failure mode: motivation-heavy and non-specific wording that does not identify the concrete shipped change.

### Field: PR Title
Audience: Engineer scanning a list of twenty open PRs.

Job: Headline what this PR is and why it is being reviewed. Must be parseable in under two seconds without surrounding context.

What good looks like: `Specify closing sidecar field contracts for DP-OPS-0093 reviewer handoff quality`.

What bad looks like: `Update docs and template.` Failure mode: low-information title that does not explain why this PR exists now.

### Field: PR Description
Audience: Reviewer in the GitHub PR interface.

Job: Human-authored summary: what changed, why it matters, what to focus on, what risks exist. Markdown rendering is available use it.

What good looks like:
~~~markdown
## What changed
- Added per-field semantics to docs/ops/specs/surfaces/results.md.
- Added canonical framing template at ops/src/surfaces/closing.md.tpl.

## Why it matters
- Closing fields now declare audience and unique job, reducing semantic duplication.

## Reviewer focus
- Verify every bad example names an explicit failure mode.
- Verify framing sentences in the new template match canonical wording exactly.
~~~

What bad looks like: `Added doc updates for closing sidecars.` Failure mode: single-line restatement that omits risks and does not direct reviewer attention.

### Field: Confirm Merge (Commit Message)
Audience: Main branch history reader.

Job: Frame what landed on trunk, not what was worked on in the branch. Verb and subject must differ from the commit header.

What good looks like: `Main history now includes explicit six-field closing-sidecar semantics`.

What bad looks like: `Define closing sidecar field semantics for certify closeout.` Failure mode: commit-header echo that repeats verb and subject instead of framing trunk outcome.

### Field: Confirm Merge (Extended Description)
Audience: Automated tools and future archaeology.

Job: A newline-separated list of file paths. Zero prose. Deliberately boring. Machine-readable and complete.

What good looks like:
~~~text
docs/ops/specs/surfaces/results.md
ops/src/surfaces/closing.md.tpl
storage/dp/active/allowlist.txt
~~~

What bad looks like:
~~~text
docs/ops/specs/surfaces/results.md
Added this file to document field semantics.
ops/src/surfaces/closing.md.tpl
~~~
Failure mode: prose contamination breaks machine-oriented manifest semantics.

### Field: Confirm Merge (Add a Comment)
Audience: Reviewer receiving the PR.

Job: A genuine question specific to this DP's design decision, tradeoff, or risk. If a reviewer reads it and thinks "good question," it is working.

What good looks like: `Should the closing sidecar rollout keep legacy label compatibility in ops/bin/certify, or should schema migration happen in the same packet to avoid dual-format drift?`

What bad looks like: `Does this look correct?` Failure mode: generic approval-seeking stem with no DP-specific tradeoff or risk.
