---
template_type: surface
template_id: results
template_version: 1
requires_slots:
  - DP_ID
  - CERTIFIED_AT
  - BRANCH
  - GIT_HASH
  - ALLOWLIST_POINTER
  - INTEGRITY_OUTPUT
  - COMMAND_LOG
  - DIFF_NAME_ONLY
  - DIFF_STAT
  - CONTRACTOR_NARRATIVE
  - CLOSING_BLOCK
ff_target: machine-dense
ff_band: "15-25"
---
# {{DP_ID}} RESULTS

## Certification Metadata
- DP ID: {{DP_ID}}
- Certified At (UTC): {{CERTIFIED_AT}}
- Branch: {{BRANCH}}
- Git Hash: {{GIT_HASH}}

## Scope Verification
- Target Files allowlist pointer: {{ALLOWLIST_POINTER}}

### Integrity Lint Output
~~~text
{{INTEGRITY_OUTPUT}}
~~~

## Verification Command Log
{{COMMAND_LOG}}

## Git State Impact
### git diff --name-only
~~~text
{{DIFF_NAME_ONLY}}
~~~

### git diff --stat
~~~text
{{DIFF_STAT}}
~~~

## Contractor Execution Narrative
{{CONTRACTOR_NARRATIVE}}

## Mandatory Closing Block
{{CLOSING_BLOCK}}
