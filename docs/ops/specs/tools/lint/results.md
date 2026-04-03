<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/results.sh` protects certification receipt integrity so generated RESULTS artifacts cannot be accepted when structurally incomplete, placeholder-filled, or hash-inconsistent. This gate enforces the PoT Section 4.2 Generation Mandate by rejecting manual fabrication patterns and malformed closeout evidence.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and enforce canonical hash parity for `ops/src/surfaces/results.md.tpl`.
2. Resolve lint target mode: explicit path, `--all` scan, active-branch inferred path, or single discovered receipt fallback.
3. For each target file, distinguish certification format from legacy format and skip legacy only in non-explicit historical scan modes.
4. Enforce required heading set and reject unresolved artifact placeholders or forbidden disposable-artifact references.
5. Enforce command-log fence integrity within `## Verification Command Log`: explicit-path and inferred-active-target modes fail if a heading is fused onto a closing fence boundary (for example `~~~### Command 26`); `--all` historical scans report the finding as a skip note.
6. Enforce presence of required Worker Execution Narrative subsections (`### Preflight State`, `### Implemented Changes`, `### Closeout Notes`, `### Decision Leaf`) and require both `Decision Required:` and `Decision Leaf:` field lines in the narrative section.
7. Enforce that `### Preflight State` contains the verbatim outputs of the three §3.1 freshness-gate commands (`git rev-parse --abbrev-ref HEAD`, `git rev-parse --short HEAD`, `git status --porcelain`) captured before edits began. Explicit-path and inferred-active-target modes fail when any command output is missing; `--all` historical scans report the gap as a skip note.
8. Enforce Decision Leaf coherence in explicit-path and inferred-active-target modes:
   - `Decision Required: Yes` requires `Decision Leaf: archives/decisions/RoR-*.md`.
   - `Decision Required: No` requires `Decision Leaf: None`.
9. Reject untouched narrative scaffold prose in explicit-path mode; historical scan modes report scaffold findings without blocking.
10. Enforce `Git Hash` parity in explicit mode, and record historical parity skips in inferred/scan modes without blocking.
11. Return non-zero when any certification-format receipt fails required checks.

## Anecdotal Anchor
During the DP-OPS-0069 certification cutover, the absence of a dedicated RESULTS lint path allowed structurally incomplete receipts to pass closeout and created an audit gap that required retroactive correction. This script formalizes that missing gate.

## Integrity Filter Warnings
Mode behavior is intentionally different: explicit path and inferred active-target modes apply strict hash parity, strict scaffold-prose rejection, strict command-log fence-integrity enforcement, strict Preflight State freshness-proof enforcement, and strict Decision Leaf coherence enforcement. `--all` broad historical scans tolerate parity drift, scaffold residue, fused fence/heading findings, missing freshness proof, and Decision Leaf coherence drift as report-only skips. Legacy receipts are ignored in broad historical scans unless explicitly targeted. Template hash constants must be revised in lockstep with sanctioned template changes. Narrative subheading and Decision Leaf field checks apply to the Worker Execution Narrative section from `## Worker Execution Narrative` through EOF; legacy trailing sections are tolerated.

## Closing Sidecar Authority
`ops/bin/certify` is the sole authority for closing sidecar validation in closeout. Closing sidecar schema remains SSOT in `ops/lib/manifests/CLOSING.md` (Section 1), but `tools/lint/results.sh` no longer parses or enforces sidecar labels inside RESULTS.

RESULTS schema ends at `## Worker Execution Narrative`. Any closing sidecar validation evidence remains certify-internal and is not embedded in RESULTS.

## Verification Command Log Validation
The lint requires machine-frame command-log integrity:
- `## Verification Command Log` must not contain a heading fused onto a closing fence boundary.
- A line such as `~~~### Command 26` is a hard failure in explicit-path and inferred-active-target modes because it proves the receipt frame was malformed before acceptance.

## Worker Execution Narrative Validation
The lint requires the following within the RESULTS artifact:
- `## Worker Execution Narrative` heading present in required position.
- Required subsections: `### Preflight State`, `### Implemented Changes`, `### Closeout Notes`, `### Decision Leaf`.
- `### Preflight State` must contain the verbatim outputs of the three §3.1 freshness-gate commands (`git rev-parse --abbrev-ref HEAD`, `git rev-parse --short HEAD`, `git status --porcelain`). The command log is not a substitute for this proof.
- The Decision Leaf subsection must contain both `Decision Required:` and `Decision Leaf:` field lines.
- Decision Leaf coherence rules:
  - `Decision Required: Yes` requires `Decision Leaf: archives/decisions/RoR-*.md`.
  - `Decision Required: No` requires `Decision Leaf: None`.
- Untouched scaffold prose lines are rejected in explicit mode:
  - `Paste the verbatim outputs of git rev-parse --abbrev-ref HEAD, git rev-parse --short HEAD, and git status --porcelain captured before any edits began, then add a short preflight lint status summary.`
  - `Describe each change made: what was modified, created, or removed, and why.`
  - `Describe any anomalies, open items, or residue. State None. if all items are resolved.`
  - `Decision Required: Yes|No`
  - `Decision Leaf: archives/decisions/... or None`
