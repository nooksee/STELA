<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/ff.sh` enforces Calibrated Canonical Density declarations on tracked markdown surfaces so density expectations move from implicit review judgment to explicit contract enforcement. The gate exists to preserve context-window efficiency and to prevent low-signal prose from displacing operational truth in canonical loading paths. This aligns with PoT Section 4.2 linguistic precision and relatability mandates: writing must remain exact, testable, and readable to intended operators. CCD resolves the expert-versus-consumer conflict with a domain-includes-consumer rule: domain correctness remains mandatory, but shared governance writing must stay legible for its declared audience.

## Mechanics and Sequencing
1. Enumerate tracked markdown scope with `git ls-files '*.md'` from repository root.
2. Apply Wave 0 exemptions for exact filenames and exempt path prefixes before any scoring.
3. Detect generated-file markers in the first five lines and skip matching files silently.
4. Detect CCD declarations with YAML front matter `ff_target` and `ff_band` keys, or an HTML comment header in the first ten lines. YAML values take precedence when both are present.
5. For declared files, compute Phase 1 proxies: stopword percentage (SW%), average sentence length (ASL), and analogy anchor density (AAD), with ASL and AAD excluding fenced code blocks.
6. Compute composite `FF_score`, compare against declared band bounds with ±10 tolerance, emit `FAIL` for out-of-band declared files, and emit `WARNING` for undeclared non-exempt files.
7. Emit a completion summary with scored, warning, and failure counts; exit non-zero only when failures are present.

## Anecdotal Anchor
DP-OPS-0087 is the originating implementation event for CCD Foundation Phase 0 and introduces `tools/lint/ff.sh` as the first enforceable density gate. Before this packet, governance surfaces had an implicit expectation for explanatory density but no declared contract field and no reproducible lint output. Review outcomes therefore depended on reviewer interpretation and could not be audited as a stable rule. This specification closes that gap by defining declaration parsing, heuristic scoring behavior, and deterministic pass-fail semantics for declared files.

## Integrity Filter Warnings
Phase 1 scoring is heuristic and proxy-based rather than entropy-derived, so false positives remain possible, especially on short files with unusual sentence distributions. Fenced-code exclusion for ASL and AAD is line-oriented and may miss nested or non-standard fence patterns. The entropy-informed Phase 2 option described in CCD-MASTER-PLAN.md Section 6.4 (Option C) is deferred indefinitely; Phase 1 is the production enforcement model until a later governance decision supersedes it. Generated-file exemption relies on matching marker comments in the first five lines, so generated files without those markers may be scored.
