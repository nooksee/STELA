---
template_type: decision
template_id: cbc
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
requires_slots:
  - TRACE_ID
  - DECISION_ID
  - PACKET_ID
  - CREATED_AT
  - AUTHORIZED_BY
  - TOOL_PATH
  - Q1_ANSWER
  - Q2_ANSWER
  - Q3_ANSWER
  - Q4_SCORE
  - Q4_RATIONALE
  - Q5_ANSWER
  - VERDICT
  - STATUS
---
---
trace_id: {{TRACE_ID}}
decision_id: {{DECISION_ID}}
packet_id: {{PACKET_ID}}
decision_type: cbc
created_at: {{CREATED_AT}}
authorized_by: {{AUTHORIZED_BY}}
---

## Context

CbC Design Discipline Preflight record for packet {{PACKET_ID}}.
Tool or binary under review: {{TOOL_PATH}}

## CbC Preflight Questions

**Q1: Is structural prevention viable instead of detection?**
{{Q1_ANSWER}}

**Q2: Does the enforcement complexity exceed 100 lines without justification?**
{{Q2_ANSWER}}

**Q3: Was structural prevention identified as viable but deferred?**
{{Q3_ANSWER}}

**Q4: Complexity score (1–5) and rationale:**
Score: {{Q4_SCORE}}
{{Q4_RATIONALE}}

**Q5: Does a SoP note record any deferred structural prevention decision?**
{{Q5_ANSWER}}

## Decision

{{VERDICT}}

## Consequence

Allowlist enforcement requires this leaf to be present and allowlisted before certify runs
when the CbC preflight is applicable. Integrity lint will fail if a cbc leaf is absent from
the allowlist when the TASK.md CbC preflight slot does not begin with "Not applicable".

## Pointer

- Authorized by: {{AUTHORIZED_BY}}

## Status

{{STATUS}}
