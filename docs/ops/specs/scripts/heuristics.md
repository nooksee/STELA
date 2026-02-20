<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/heuristics.sh` supplies deterministic scoring and collision checks for lifecycle scripts so provenance and routing decisions follow one measurable logic path. This aligns with PoT.md Section 4.2 quantitative-reporting discipline by replacing ad hoc judgment calls with reproducible git-derived signals and explicit keyword thresholds.

## Mechanics and Sequencing
1. `detect_hot_zone`:
   - Run `git diff --numstat base...head`.
   - Convert insertion/deletion counts to per-file change totals.
   - Return the file with maximum total changes, or `None` when no diff data exists.
2. `detect_high_churn`:
   - Run `git log --name-only base...head`.
   - Count per-file commit frequency.
   - Return top three files with count greater than one commit, or `None`.
3. `generate_provenance_block`:
   - Resolve branch, HEAD hash, UTC timestamp, diff stat, hot zone, and high-churn lines.
   - Emit a markdown `## Provenance` block for direct insertion into draft artifacts.
4. `check_semantic_collision`:
   - Normalize title text to lowercase alphanumeric tokens.
   - Drop stop words and short tokens.
   - Scan existing skill canon and draft leaves for keyword matches.
   - Fail with warning output when at least two keywords overlap in a target file.
5. `check_agent_collision` mirrors the semantic collision algorithm for agent canon and agent drafts, returning colliding filenames on failure.

## Anecdotal Anchor
SoP entries `2026-02-10 16:52:29 UTC — DP-OPS-0042` and `2026-02-10 18:03:22 UTC — DP-OPS-0043` both record subsystem hardening where emergence detection and collision prevention became mandatory gates. Those incidents represent the ambiguity class this library addresses: different workers applying different heuristic rules produced inconsistent candidate routing and promotion outcomes.

## Integrity Filter Warnings
- Git-history dependent functions return `None` for shallow history windows, detached references, or empty ranges; downstream scripts must treat `None` as unknown data, not negative evidence.
- Collision checks rely on substring matching and fixed thresholds, which can overflag broad titles and miss domain-specific synonyms.
- Stop-word lists are static and English-centric; multilingual titles and novel jargon reduce collision accuracy.
- `check_semantic_collision` and `check_agent_collision` do not compare semantic intent, only token overlap frequency.
