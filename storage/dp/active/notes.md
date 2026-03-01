# Contractor Notes — DP-OPS-0136

## Scope Confirmation
All four in-scope guidance surfaces were updated per Steps 1 through 7 of the DP
patch specification:

- ops/bin/open: DUMP heredoc block (Steps 1) and NEXT OPERATOR MOVES block (Step 2)
  updated; --scope=platform --exclude-dir=opt/_factory replaced with --scope=core;
  --scope=platform and --scope=factory opt-in lines added.
- docs/MANUAL.md: State Capture (Dump) section (Step 3), Scope Taxonomy factory
  entry (Step 4), and Section 3 Scope Definition rule (Step 5) updated.
- docs/INDEX.md: dump.md bullet extended with default scope note (Step 6).
- docs/ops/prompts/e-prompt-01.md: DRIFT point updated (Step 7).
- storage/dp/active/allowlist.txt: ops/bin/open, docs/ops/prompts/e-prompt-01.md,
  storage/handoff/CLOSING-DP-OPS-0136.md, and archives/surfaces/TASK-DP-OPS-0136-*.md
  entries added (Step 8).

All files listed as out of scope were not touched: ops/lib/scripts/traverse.sh,
ops/bin/dump, docs/ops/specs/binaries/dump.md, opt/_factory/.

Receipt commands run through pre-certify verification phase. Certify NOT run (blocked; see Anomalies Encountered).

## Anomalies Encountered
Four receipt command authoring errors found in DP-OPS-0136 §3.4.5 during pre-certify
verification. Three are unresolvable by the contractor and block certify.

Anomaly 1 (RESOLVED): `grep -n "scope=core" docs/INDEX.md` — Step 6 spec used `core`
in replacement text but receipt command pattern requires `scope=core`. Resolved by setting
INDEX.md text to `--scope=core` (consistent with all other surfaces and receipt command
intent).

Anomaly 2 (BLOCKED): `grep -n "Not implemented" docs/MANUAL.md` — exits 1 after correct
Step 4 execution; certify dies. Should have been `grep -c`.

Anomaly 3 (BLOCKED): `grep -n "exclude-dir=opt/_factory" ops/bin/open` — exits 1 after
correct Steps 1–2 execution; certify dies. Should have been `grep -c`.

Anomaly 4 (BLOCKED): `grep -n "exclude-dir=opt/_factory" docs/MANUAL.md` — exits 1
after correct Steps 3–5 execution; certify dies. Should have been `grep -c`.

Decision record: archives/decisions/DEC-2026-02-28-003-certify-receipt-authoring-error-0136.md

## Open Items / Residue
Certify cannot run. Closeout blocked. Integrator review and addendum authorization
required to resolve Anomalies 2–4 (replace broken `grep -n` negative-proof receipt
commands with `grep -c` equivalents or authorize an alternative closeout path).

## Execution Decision Record
Decision Required: Yes
Decision Pointer: archives/decisions/DEC-2026-02-28-003-certify-receipt-authoring-error-0136.md

## Closing Schema Baseline
Assumed the current six-label closing schema (post-0116+A baseline) for this active packet.
