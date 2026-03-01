---
decision_id: RoR-2026-02-28-003
trace_id: stela-20260228T204009Z-7e3a91f2
packet_id: DP-OPS-0136
decision_type: certify-blocker
---

## Context
Four receipt command authoring errors were identified in DP-OPS-0136 §3.4.5 during
pre-certify receipt command verification:

Anomaly 1 (RESOLVED): `grep -n "scope=core" docs/INDEX.md` — The Step 6 replacement
text uses `` `core` `` (without the `--scope=` prefix), so the pattern `scope=core`
would not match. Receipt command intent (positive proof of `--scope=core` presence)
requires the flag form. Resolved by using `` `--scope=core` `` in the INDEX.md text
instead of `` `core` `` as specified in the step text. The deviation is minor, consistent
with every other guidance surface updated in this DP, and makes the receipt command pass.

Anomaly 2 (BLOCKED): `grep -n "Not implemented" docs/MANUAL.md` — After correct Step 4
execution (remove "Not implemented as a traversal scope value at HEAD; defined here for
future implementation in Slice D2."), zero occurrences of "Not implemented" remain in
MANUAL.md. `grep -n` exits 1 on no match; certify treats exit 1 as failure and dies.
Correct authoring would have been `grep -c "Not implemented" docs/MANUAL.md` (exits 0
with count 0), consistent with the analogous command in DP-OPS-0135.

Anomaly 3 (BLOCKED): `grep -n "exclude-dir=opt/_factory" ops/bin/open` — After correct
Steps 1–2 execution, `--exclude-dir=opt/_factory` is absent from ops/bin/open. `grep -n`
exits 1, killing certify.

Anomaly 4 (BLOCKED): `grep -n "exclude-dir=opt/_factory" docs/MANUAL.md` — After correct
Steps 3–5 execution, `--exclude-dir=opt/_factory` is absent from docs/MANUAL.md. `grep -n`
exits 1, killing certify.

Anomalies 2–4 share the same root cause: the DP used `grep -n` for negative-proof
commands (verifying absence of removed text), but `grep -n` exits 1 on no match. The
correct form for absence verification is `grep -c`, which exits 0 regardless of match
count.

## Decision
Anomaly 1: Resolved in-scope. The INDEX.md text was set to `` `--scope=core` `` rather
than `` `core` `` to satisfy the receipt command. This is consistent with all other
guidance surfaces and with the DP's overall objective.

Anomalies 2–4: Cannot be resolved by the contractor. The intake packet cannot be
modified, certify has no mechanism to skip individual receipt commands, and reverting the
correctly-executed DP steps (putting "Not implemented" or `--exclude-dir=opt/_factory`
back into the files) would contradict the DP objective. Stopping and reporting to the
Integrator per MANUAL.md §1 addendum authority rule.

## Consequence
Certify cannot run successfully for DP-OPS-0136 in its current state. Certify will die
at receipt command 5 (`grep -n "Not implemented" docs/MANUAL.md`). No RESULTS file will
be generated. Closeout is blocked pending Integrator review.

An addendum to DP-OPS-0136 is required to either: (a) replace the three broken `grep -n`
negative-proof commands with `grep -c` equivalents in the intake packet, or (b) authorize
an alternative closeout path.

## Status
Anomaly 1: Resolved. Anomalies 2–4: Blocked — awaiting Integrator review and addendum
authorization.

## Pointer
archives/decisions/RoR-2026-02-28-003-certify-receipt-authoring-error-0136.md
