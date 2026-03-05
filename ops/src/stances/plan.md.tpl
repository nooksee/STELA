---
template_type: surface
template_id: plan
template_version: 1
requires_slots:
  - PLAN_TITLE
  - SUMMARY
  - SCOPE
  - ARCHITECT_HANDOFF
  - IMPLEMENTATION_PLAN
ff_target: operator-technical
ff_band: "30-45"
---
# DP Plan: {{PLAN_TITLE}}

## Summary
{{SUMMARY}}

## Scope
{{SCOPE}}

## Architect Handoff
{{ARCHITECT_HANDOFF}}

## Implementation Plan (Decision Complete)
{{IMPLEMENTATION_PLAN}}
