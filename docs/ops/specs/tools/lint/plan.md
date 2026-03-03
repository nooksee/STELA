<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/plan.sh` is a minimal deterministic safety-floor gate for PLAN-based routing. Structural prevention cannot guarantee operator-authored `storage/handoff/PLAN.md` quality at runtime, so bundle auto-routing requires a binary PASS/FAIL guard before selecting Architect mode.

## Mechanics and Sequencing
The lint supports two modes:
1. `bash tools/lint/plan.sh [path]` (default path `storage/handoff/PLAN.md`).
2. `bash tools/lint/plan.sh --test` fixture self-check mode.

Validation scope is intentionally minimal and deterministic:
1. Target file exists.
2. File is non-empty.
3. File has at least one markdown heading.
4. File has at least one non-heading content line.
5. File has no unresolved `{{TOKEN}}` placeholders.

On pass, the lint prints `PLAN lint: PASS (<path>)` and exits 0. On failure, it prints `FAIL: ...` and exits non-zero. `--test` runs positive/negative fixtures and prints `OK: --test passed` on success.

## Anecdotal Anchor
DP-OPS-0145 introduced bundle auto-routing and required a deterministic route gate that avoids subjective style checks. PLAN lint is the minimal bridge between missing-plan fallback (`analyst`) and valid-plan route-up (`architect`).

## Integrity Filter Warnings
This lint is a routing gate, not a plan quality rubric. It must not enforce style, preference, or prose quality. Expanding it beyond deterministic structural validity increases false positives and violates the CbC minimization constraint documented in DP-OPS-0145.
