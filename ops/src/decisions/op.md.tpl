---
template_type: decision
template_id: op
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
requires_slots:
  - TRACE_ID
  - DECISION_ID
  - PACKET_ID
  - CREATED_AT
  - AUTHORIZED_BY
  - REQUEST_CONTEXT
  - SCOPE_BOUNDARY
  - APPROVAL_TEXT
  - STATUS
---
---
trace_id: {{TRACE_ID}}
decision_id: {{DECISION_ID}}
packet_id: {{PACKET_ID}}
decision_type: op
created_at: {{CREATED_AT}}
authorized_by: {{AUTHORIZED_BY}}
---

## Context

Operator authorization record for packet {{PACKET_ID}}.

{{REQUEST_CONTEXT}}

## Decision

Scope boundary: {{SCOPE_BOUNDARY}}

Authorization: {{APPROVAL_TEXT}}

## Consequence

This record provides the authorization trail for any operator-approved scope expansion,
exception, or out-of-band action taken during {{PACKET_ID}} execution.

## Pointer

- Authorized by: {{AUTHORIZED_BY}}

## Status

{{STATUS}}
