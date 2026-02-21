<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/schema.sh` enforces archive-leaf provenance schema so reverse-link reconstruction remains possible across definitions, surfaces, and compile manifests. The gate protects the PoT Section 1.3 proof-ledger requirement by requiring parseable front matter and valid `previous` chain metadata on eligible archival leaves.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and require `archives/definitions`, `archives/surfaces`, and `archives/manifests`.
2. Enumerate candidate files by directory policy:
   - `archives/definitions/*.md` at depth 1.
   - `archives/surfaces/*.md` at depth 1 matching PoW, SoP, or TASK leaf filename policy.
   - `archives/manifests/*.md` at depth 1 matching compile-leaf filename policy.
3. Exclude `.gitkeep`, non-markdown files, and non-policy filenames.
4. For each candidate, parse the first YAML front-matter block and require keys `trace_id`, `packet_id`, `created_at`, and `previous`.
5. Validate `created_at` against UTC ISO-8601 with `Z` suffix and validate `previous` as `(none)` or a repository-relative `.md` path with safe characters.
6. Fail immediately on first malformed candidate and print file-scoped error text.

## Anecdotal Anchor
This gate addresses the incident class where malformed or missing `previous` values broke head-chain reconstruction during regression tracing across multiple DP sessions. Without schema enforcement, archive continuity had to be rebuilt manually from unrelated receipts.

## Integrity Filter Warnings
The script exits on first failure, so additional invalid leaves remain undiscovered until subsequent reruns. Candidate policies intentionally skip non-matching filenames, which means off-policy archival files are outside scan scope. Front-matter parsing evaluates the first YAML block only.
