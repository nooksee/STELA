---
template_type: surface
template_id: addendum
template_version: 1
requires_slots:
  - BASE_DP_ID
  - ADDENDUM_ID
  - OPERATOR_AUTHORIZATION
  - SCOPE_DELTA
  - ADDENDUM_OBJECTIVE
  - ADDENDUM_RECEIPT
includes:
  - ops/lib/manifests/CONSTRAINTS.md#section-1
  - ops/lib/manifests/EXECUTION.md#rules
ff_target: operator-technical
ff_band: "30-40"
---
### Addendum {{ADDENDUM_ID}} to {{BASE_DP_ID}}

## A.1 Authorization
Operator Authorization:
{{OPERATOR_AUTHORIZATION}}

Base Packet: {{BASE_DP_ID}}
Addendum ID: {{ADDENDUM_ID}}

## A.2 Scope Delta
Exact paths added by this addendum (one per line; no globs; no brace expansion):
{{SCOPE_DELTA}}

## A.3 Addendum Objective
{{ADDENDUM_OBJECTIVE}}

## A.4 Context Load

{{@include:ops/lib/manifests/EXECUTION.md#rules}}

Worker Constraints (SSOT injected):
{{@include:ops/lib/manifests/CONSTRAINTS.md#section-1}}

## A.5 Addendum Receipt (Proofs to collect) - MUST RUN

**Mandatory receipt commands (always run; do not omit):**
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/integrity.sh
- bash tools/lint/style.sh
- git diff --name-only
- git diff --stat
- comm -23 <(git diff --name-only | sort) <(sort storage/dp/active/allowlist.txt) || true
- comm -23 <(git ls-files --others --exclude-standard | sort) <(sort storage/dp/active/allowlist.txt) || true
- ./ops/bin/open

**Addendum-specific receipt commands:**
{{ADDENDUM_RECEIPT}}
