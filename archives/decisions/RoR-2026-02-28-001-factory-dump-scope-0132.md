---
trace_id: stela-20260228T131805Z-6c5c0e91
decision_id: RoR-2026-02-28-001
packet_id: DP-OPS-0132
decision_type: audit-remediation
created_at: 2026-02-28T13:28:30Z
authorized_by: Integrator
---

## Context

Integrator post-work audit for DP-OPS-0132 reported one deviation: the platform
dump artifact used for contractor visibility included `opt/_factory/` entries.
The OPEN prompt guidance recommends `--exclude-dir=opt/_factory`, but closeout
commands in the active DP and certify replay used the literal command
`./ops/bin/dump --scope=platform --format=chatgpt --out=auto`.

## Decision

Record a retrospective authorization for this packet only: keep the produced
dump artifacts as-is, acknowledge the `opt/_factory/` inclusion as procedural
oversight, and proceed without addendum escalation because no factory files were
modified and no DP implementation edits targeted factory surfaces.

## Consequence

Audit traceability is restored with an explicit decision pointer tied to
DP-OPS-0132. Future packets should align DP closeout dump commands with OPEN
guidance when exclusion is required.

## Pointer

- storage/handoff/DP-OPS-0132-RESULTS.md
- storage/dumps/dump-platform-work-trace-health-checks-2026-02-28-dcb90a88b.txt
- storage/dumps/dump-platform-work-trace-health-checks-2026-02-28-dcb90a88b.manifest.txt
- storage/dp/active/notes.md

## Status

Accepted
