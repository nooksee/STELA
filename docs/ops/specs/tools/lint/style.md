<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification: tools/lint/style.sh

## First Principles Rationale
`tools/lint/style.sh` enforces writing discipline on markdown surfaces so policy text
stays direct, explicit, and machine-checkable. The linter now protects two additional
integrity boundaries: anti-jargon language and canonical spec-surface structure.

## Mechanics and Sequencing
1. Resolve the repository root from git state and run inside that root.
2. Enumerate tracked markdown files with `git ls-files '*.md'`, excluding `storage/`.
3. Fail on contraction tokens (ASCII and Unicode apostrophes).
4. Enforce the Jargon Blacklist:
   - Terms are defined in a centralized `JARGON_BLACKLIST` array in `tools/lint/style.sh`.
   - Matching is case-insensitive fixed-string search against tracked markdown files.
   - Every match reports both the matched term and file:line location.
5. Enforce spec-surface compliance in `docs/ops/specs/`:
   - A file is compliance-bound when it contains `<!-- SPEC-SURFACE:REQUIRED -->`.
   - Compliance-bound files must contain all required H2 sections:
     - `## First Principles Rationale`
     - `## Mechanics and Sequencing`
     - `## Anecdotal Anchor`
     - `## Integrity Filter Warnings`
   - Missing sections fail lint with file path plus missing section name.
6. Run closing-block lead-word duplication checks for `storage/handoff/CLOSING-*.md`.

## Anecdotal Anchor
If a spec file is marked with `<!-- SPEC-SURFACE:REQUIRED -->` but omits
`## Integrity Filter Warnings`, CI fails immediately and reports the exact file and
missing section label. The author can repair one heading and rerun lint without a
repo-wide documentation rewrite.

## Integrity Filter Warnings
`tools/lint/style.sh` returns non-zero when any of the following occurs:
- A required dependency is missing (`git`, plus either `rg` or `grep -E`).
- Any contraction token is found in markdown.
- Any Jargon Blacklist term is found in markdown.
- Any compliance-bound spec file in `docs/ops/specs/` is missing a required section.
- Any closing sidecar repeats opening lead words in the mandatory closing block.

## Related Pointers
- Registry entry: `docs/ops/registry/lint.md` (`LINT-07`).
- Behavioral policy source: `PoT.md` Section 4.2.
- Adjacent policy lint: `tools/lint/truth.sh`.
