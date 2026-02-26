<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/style.sh` enforces linguistic precision and structural explainability for markdown governance surfaces. The gate exists because ambiguous writing, jargon-heavy prose, and malformed spec structure reduce machine-checkable clarity and increase operator interpretation drift, which conflicts with PoT Section 4.2 precision directives.

## Mechanics and Sequencing
1. Resolve repository root and enumerate tracked markdown files with `git ls-files '*.md'`, excluding `storage/`.
2. Search all tracked markdown for contraction tokens using regex patterns that cover ASCII and Unicode apostrophes.
3. Enforce anti-jargon policy by scanning case-insensitive fixed matches for every term in `JARGON_BLACKLIST`.
4. For each spec file under `docs/ops/specs/` that contains `<!-- SPEC-SURFACE:REQUIRED -->`, require the four canonical H2 headings.
5a. Scan `storage/handoff/CLOSING-*.md` and reject duplicate opening words across Mandatory Closing Block field entries.
5b. Check that the Review Conversation Starter field value ends with `?`; emit failure with filename when it does not.
5c. Check that every non-blank line in the Commit Message (Extended Description) field value matches a path pattern (two or more consecutive non-path tokens on a single line is a prose failure); emit failure with filename and line number for each detected prose line.
5d. Check that the PR Description field value contains at least one markdown construct — a heading beginning with `##`, a list item beginning with `-`, `*`, or a digit followed by `.`, or a bold span (`**`); emit failure with filename when none is found.
6. Aggregate failures and exit non-zero when any check reports an error.

## Anecdotal Anchor
DP-OPS-0082 introduced spec-surface enforcement and anti-jargon checks after repeated review churn on docs that passed operational gates but still carried ambiguous structure or promotional language. Later packets used this gate to block malformed spec edits before certification.

## Integrity Filter Warnings
The scan set includes tracked markdown only; untracked drafts are outside enforcement until tracked. Jargon checks are fixed-string matches and can flag quoted historical text that appears in explanatory context. Spec structure checks activate only when `<!-- SPEC-SURFACE:REQUIRED -->` is present, so files without that marker are not subject to four-slot heading validation. Closing block structural checks preserve the legacy `DP-OPS-0080+` threshold guard and additionally grandfather pre-`DP-OPS-0094` handoff receipts so historical audit artifacts are not rewritten.

## Closing Block Structural Checks

### Closing Block Schema Authority
`ops/bin/certify` is the sole authority defining accepted closing sidecar label schemas. The current closeout label set is SSOT in `ops/lib/manifests/CLOSING.md` (Section 1). `tools/lint/style.sh` implements certify's contract and must remain synchronized with certify's accepted label sets when certify's schema definitions change.

The accepted closing sidecar schema is the current six-label form defined in `ops/lib/manifests/CLOSING.md` (Section 1): `Primary Commit Header`, `Pull Request Title`, `Pull Request Description`, `Final Squash Stub`, `Commit Message (Extended Description)`, `Review Conversation Starter`.

Style.sh loads the closeout header-detection list from `ops/lib/manifests/CLOSING.md` (Section 1) and applies all three closing-block semantic checks (Conversation Starter question form, path-only `Commit Message (Extended Description)`, and markdown-bearing PR Description) to that current schema. Lead-word deduplication applies to recognized current-schema sidecars.

### Check 1: Conversation Starter must end in `?`
Detection logic: Extract the first non-blank line following `Review Conversation Starter` in each recognized current-schema `CLOSING-*.md` file. Trim trailing whitespace. Fail if the trimmed value does not end with `?`.
Failure message: `CLOSING BLOCK: Conversation Starter does not end in '?'. This field must be a genuine question.`
Rationale: A field value that does not end with `?` is a statement, not a question. The Conversation Starter field exists to prompt reviewer engagement on a specific tradeoff or risk. Statements do not fulfill that job.

### Check 2: Commit Message (Extended Description) must contain paths only
Detection logic: Extract the non-blank value lines of the `Commit Message (Extended Description)` field block in each recognized current-schema `CLOSING-*.md` file. For each line, tokenize on whitespace. Apply the prose heuristic: if two or more consecutive tokens are present that do not begin with a letter or digit and do not contain `/`, the line is classified as prose. Fail on the first prose line detected; emit the line number and text.
Failure message: `CLOSING BLOCK: <manifest field> contains prose on line N: "<line>". This field must contain file paths only.`
Rationale: The path-manifest field is consumed by automated tools and future archaeology. Prose in this field, even a single explanatory clause, breaks machine-readability and signals that the writer substituted explanation for path enumeration. Explanation belongs in the PR Description or equivalent narrative field.

### Check 3: PR Description must contain at least one markdown construct
Detection logic: Extract the value block of `Pull Request Description` in each recognized current-schema `CLOSING-*.md` file. Scan for: any heading line beginning with `##`, any list item beginning with `-` or `*` followed by a space, any ordered list item beginning with a digit followed by `.` and a space, or any occurrence of `**` (bold span). Fail if none of these constructs are present in the block.
Failure message: `CLOSING BLOCK: PR Description contains no markdown constructs. Use at least one heading (##), list item (- or 1.), or bold (**) to serve the reviewer interface.`
Rationale: The PR Description renders in the GitHub pull request interface, which supports full markdown. A plaintext paragraph in a markdown rendering surface indicates the writer used the field as a text box rather than a structured reviewer handoff. At minimum, one markdown construct is required to demonstrate intentional use of the rendering surface.
