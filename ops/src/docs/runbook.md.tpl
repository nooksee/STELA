---
template_type: docs
template_id: runbook
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
requires_slots:
  - RUNBOOK_TITLE
  - TRIGGER
  - PRECONDITIONS
  - STEPS
  - VERIFICATION
  - ROLLBACK
  - KNOWN_RISKS
---
# Runbook: {{RUNBOOK_TITLE}}

## Trigger
{{TRIGGER}}

## Preconditions
{{PRECONDITIONS}}

## Steps
{{STEPS}}

## Verification
{{VERIFICATION}}

## Rollback
{{ROLLBACK}}

## Known Risks
{{KNOWN_RISKS}}
