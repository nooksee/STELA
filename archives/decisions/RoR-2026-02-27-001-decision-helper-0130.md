---
trace_id: stela-20260227T223228Z-c8f870c7
decision_id: RoR-2026-02-27-001
packet_id: DP-OPS-0130
decision_type: decision-helper
created_at: 2026-02-27T22:32:28Z
authorized_by: Operator
---

## Context

DP-OPS-0130 requires a structural decision-record authoring path so that every
decision leaf uses deterministic archive naming and a canonical schema.
Prior leaves show valid structure, but the repository lacked a helper binary and
template to generate those leaves consistently.

## Decision

Adopt `ops/bin/decision create` as the deterministic authoring interface for
decision leaves. The helper now renders `ops/src/decisions/dec.md.tpl`,
assigns `decision_id` as `RoR-YYYY-MM-DD-NNN`, and writes
`archives/decisions/RoR-YYYY-MM-DD-NNN-<type-slug>-<dp-suffix>.md` when
`--out=auto` is used.

## Consequence

Decision records for active packets can now be generated with stable naming and
schema by construction. Manual filename selection and ad hoc header assembly are
removed from the normal operator and contractor path.

## Pointer

- ops/bin/decision
- ops/src/decisions/dec.md.tpl
- docs/ops/specs/binaries/decision.md
- storage/handoff/DP-OPS-0130-RESULTS.md

## Status

Accepted
