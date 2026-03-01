---
trace_id: stela-20260223T125515Z-2cdc3fbf
decision_id: RoR-2026-02-23-001
packet_id: DP-OPS-0103
decision_type: certify-remediation
created_at: 2026-02-23T13:06:48Z
authorized_by: Operator
---

## Context
During DP-OPS-0103 closeout, `ops/bin/certify` rejected the intake packet twice in sequence: first because Section 3.4.5 contained a command substitution form (`--out-dir="$(pwd)"`), which certify does not replay; then because the Freshness Stamp was in trace form rather than the `YYYY-MM-DD` form the certify parser requires. Both constraints were previously undocumented in DP writer guidance.

## Decision
Operator authorized in-session normalization of the DP-OPS-0103 intake packet by (1) replacing `./ops/bin/llms --out-dir="$(pwd)"` with `./ops/bin/llms --out-dir=.` in Section 3.4.5, and (2) replacing the trace-style Freshness Stamp with the date-form value `2026-02-23`. The same authorization covered closeout continuation with `certify -> prune -> open --out=auto -> dump --scope=platform --format=chatgpt --out=auto` and allowlist expansion to include the current SoP and PoW source archive leaves required for pre-certify ledger authoring.

## Consequence
DP-OPS-0103 certify ran successfully after normalization. Two certify-compatibility constraints are now confirmed and documented: command substitution forms are rejected in Section 3.4.5 replay commands; the Freshness Stamp field must be in `YYYY-MM-DD` format. DP writers must use literal paths and date-form Freshness Stamps in all future DPs. These constraints are captured in the DP Writer Guidance appendix of the forward plan and will be enforced in future certify documentation updates.

## Pointer
- SoP narrative: archives/surfaces/SoP-2026-02-23-7ddb1beac.md (scope expansion authorization block, DP-OPS-0103 entry)
- RESULTS receipt: storage/handoff/DP-OPS-0103-RESULTS.md

## Status
open
