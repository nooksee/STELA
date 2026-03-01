---
template_type: decision
template_id: exec
template_version: 1
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
