<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Surface Specification: RESULTS

## Constitutional Anchor
`storage/handoff/DP-OPS-XXXX-RESULTS.md` is a generated audit receipt, not a hand-authored narrative.
It records certification execution details, verification command output, git impact, and the Mandatory Closing Block.

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
  - `## Mandatory Closing Block`
- Mandatory fields:
  - DP ID, UTC certification timestamp, work branch, and git hash.
  - Target Files allowlist pointer and integrity-lint output.
  - Per-command verification logs with exit outcomes.
  - Closing Block content supplied from `storage/handoff/CLOSING-DP-OPS-XXXX.md`.

## Failure States and Drift Triggers
- Manual edits to generated RESULTS artifacts.
- Missing required section headings or reordered schema.
- Template drift between `tools/lint/results.sh` hash constant and `ops/src/surfaces/results.md.tpl`.
- Git hash mismatch between receipt content and `git rev-parse HEAD`.
- Missing or placeholder Closing Block values.

Enforcement linkage:
- `tools/lint/results.sh` validates template hash, schema headings, git hash parity, and Closing Block content.
- `ops/bin/certify` runs `tools/lint/results.sh` as a hard gate after rendering.

## Mechanics and Sequencing
1. Maintain a human-authored closing sidecar at `storage/handoff/CLOSING-DP-OPS-XXXX.md`.
2. Run `ops/bin/certify --dp=DP-OPS-XXXX --out=auto`.
3. Certifier runs integrity and verification gates, captures outputs, then renders RESULTS from template slots.
4. Certifier lints the generated RESULTS artifact and exits non-zero on any failure.

## Forensic Insight
RESULTS is the executable evidence receipt for DP closeout.
It keeps verification outputs deterministic and replayable while separating human narrative input to a single controlled sidecar.
Think of RESULTS like a flight recorder that captures what actually ran and what failed before a merge decision is made.

## Mandatory Closing Block Field Specifications

### Field: Primary Commit Header
Audience: Engineer running `git log --oneline`.

Job: Identify the change with maximum compression. No motivation, no scope narrative. One imperative-mood line.

What good looks like: `Define closing block field semantics in RESULTS surface spec`.

What bad looks like: `Improve documentation quality across workflow surfaces.` Failure mode: motivation-heavy and non-specific wording that does not identify the concrete shipped change.

### Field: PR Title
Audience: Engineer scanning a list of twenty open PRs.

Job: Headline what this PR is and why it is being reviewed. Must be parseable in under two seconds without surrounding context.

What good looks like: `Specify closing block field contracts for DP-OPS-0093 reviewer handoff quality`.

What bad looks like: `Update docs and template.` Failure mode: low-information title that does not explain why this PR exists now.

### Field: PR Description
Audience: Reviewer in the GitHub PR interface.

Job: Human-authored summary: what changed, why it matters, what to focus on, what risks exist. Markdown rendering is available — use it.

What good looks like:
```markdown
## What changed
- Added per-field semantics to `docs/ops/specs/surfaces/results.md`.
- Added canonical framing template at `ops/src/surfaces/closing.md`.

## Why it matters
- Closing fields now declare audience and unique job, reducing semantic duplication.

## Reviewer focus
- Verify every bad example names an explicit failure mode.
- Verify framing sentences in the new template match canonical wording exactly.
```

What bad looks like: `Added doc updates for closing blocks.` Failure mode: single-line restatement that omits risks and does not direct reviewer attention.

### Field: Final Squash Stub
Audience: Main branch history reader.

Job: Frame what landed on trunk, not what was worked on in the branch. Verb and subject must differ from the commit header.

What good looks like: `Main history now includes explicit six-field closing semantics for RESULTS authoring`.

What bad looks like: `Define closing block field semantics in RESULTS surface spec.` Failure mode: commit-header echo that repeats verb and subject instead of framing trunk outcome.

### Field: Extended Technical Manifest
Audience: Automated tools and future archaeology.

Job: A newline-separated list of file paths. Zero prose. Deliberately boring. Machine-readable and complete.

What good looks like:
```text
docs/ops/specs/surfaces/results.md
ops/src/surfaces/closing.md
storage/dp/active/allowlist.txt
```

What bad looks like:
```text
docs/ops/specs/surfaces/results.md
Added this file to document field semantics.
ops/src/surfaces/closing.md
```
Failure mode: prose contamination breaks machine-oriented manifest semantics.

### Field: Review Conversation Starter
Audience: Reviewer receiving the PR.

Job: A genuine question specific to this DP's design decision, tradeoff, or risk. If a reviewer reads it and thinks "good question," it is working.

What good looks like: `Should the closing sidecar rollout keep legacy label compatibility in ops/bin/certify, or should schema migration happen in the same packet to avoid dual-format drift?`

What bad looks like: `Does this look correct?` Failure mode: generic approval-seeking stem with no DP-specific tradeoff or risk.
