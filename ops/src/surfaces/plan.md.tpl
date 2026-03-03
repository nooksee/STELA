---
template_type: surface
template_id: plan
template_version: 1
requires_slots:
  - PLAN_TITLE
  - SUMMARY
  - SCOPE
  - ARCHITECT_HANDOFF
  - DP_SLOT_SOURCE_MAP
  - INTERFACES
  - IMPLEMENTATION_PLAN
  - FILE_CHANGE_MAP
  - TEST_CASES
  - VERIFICATION_COMMANDS
  - ASSUMPTIONS
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

## DP Slot Source Map
{{DP_SLOT_SOURCE_MAP}}

Required keys:
- DP_ID:
- DP_TITLE:
- BASE_BRANCH:
- WORK_BRANCH:
- BASE_HEAD:
- FRESHNESS_STAMP:
- CBC_PREFLIGHT:
- DP_SCOPED_LOAD_ORDER:
- SAFETY_INVARIANTS:
- PLAN_STATE:

## Public Interfaces and Contract Changes
{{INTERFACES}}

## Implementation Plan (Decision Complete)
{{IMPLEMENTATION_PLAN}}

## File-level change map
{{FILE_CHANGE_MAP}}

## Test Cases and Scenarios
{{TEST_CASES}}

## Verification and Receipt Commands
{{VERIFICATION_COMMANDS}}

## Assumptions and Defaults
{{ASSUMPTIONS}}
