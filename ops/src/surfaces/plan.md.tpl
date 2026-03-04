---
template_type: surface
template_id: plan
template_version: 1
requires_slots:
  - PLAN_TITLE
  - SUMMARY
  - SCOPE
  - ARCHITECT_HANDOFF
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
