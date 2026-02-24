---
trace_id: stela-20260224T004504Z-402e7c92
decision_id: DEC-2026-02-23-002
packet_id: DP-OPS-0108
decision_type: cbc-verdict
created_at: 2026-02-23
authorized_by: Operator
---

## Context

`tools/lint/context.sh` Section 1.1 hazard guard was introduced as part of the linter
and scored B in the DP-OPS-0101 CbC Phase 1 audit. The B score indicated that a
structural alternative was available: if `ops/lib/manifests/CONTEXT.md` became a fully
generated surface, the generator could structurally exclude `opt/_factory/` paths at
generation time and the guard would become redundant. The entry was marked
"Improvement queued" pending pre-scope analysis.

## Decision

Pre-scope analysis for DP-OPS-0108 confirmed that `ops/lib/manifests/CONTEXT.md` is
already a fully generated surface. Its header states `<!-- GENERATED FILE. DO NOT EDIT. -->`
with generator `ops/bin/compile` and source template `ops/src/manifests/context.md.tpl`.
The template is a static member list containing no `opt/_factory/` paths. Structural
prevention of CONTEXT.md contamination is in effect at the generation layer. The Section
1.1 hazard guard is structurally redundant and has been removed.

## Consequence

Section 1.1 of `tools/lint/context.sh` is deleted. The linter retains its membership
verification loop (Section 2) and canonical surfaces contamination scan (Section 4),
both of which remain non-redundant. The Decision Registry row for
`tools/lint/context.sh (hazard guard)` is updated to A-scored and deprecated by
DP-OPS-0108.

## Pointer

SoP.md entry for DP-OPS-0108 (Structural Elimination notation); DP-OPS-0108 RESULTS
receipt at `storage/handoff/DP-OPS-0108-RESULTS.md`.

## Status

open
