---
template_type: surface
template_id: decision
template_version: 2
ff_target: operator-technical
ff_band: "25-40"
requires_slots:
  - TRACE_ID
  - DECISION_ID
  - PACKET_ID
  - DECISION_TYPE
  - CREATED_AT
  - AUTHORIZED_BY
  - CONTEXT
  - DECISION
  - CONSEQUENCE
  - POINTER
  - STATUS
note: >
  Legacy surface template retained for RoR-prefixed leaf compatibility.
  New decision leaves must use taxonomy-specific templates under ops/src/decisions/.
  Router: ops/bin/decision selects the taxonomy template by --type flag.
---
---
trace_id: {{TRACE_ID}}
decision_id: {{DECISION_ID}}
packet_id: {{PACKET_ID}}
decision_type: {{DECISION_TYPE}}
created_at: {{CREATED_AT}}
authorized_by: {{AUTHORIZED_BY}}
---

## Context

{{CONTEXT}}

## Decision

{{DECISION}}

## Consequence

{{CONSEQUENCE}}

## Pointer

{{POINTER}}

## Status

{{STATUS}}
