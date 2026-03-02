<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Surface Specification: SoP.md

## Constitutional Anchor
`SoP.md` is the State of Play history ledger defined by PoT.
It records what changed and why, but it does not carry executable proof payloads.
Proof pointers belong in `PoW.md`.

## Operator Contract
- Surface: `SoP.md`.
- Entry model: append-only, newest entry first.
- Entry header pattern:
  - `## YYYY-MM-DD HH:MM:SS UTC — DP-OPS-XXXX <summary>`
- Entry body contract:
  - Objective summary.
  - Optional functional receipt summary.
- Separation rule:
  - Keep historical narrative in `SoP.md`.
  - Keep strict proof pointers in `PoW.md`.
- The pre-certify single-entry-head authoring rule and a worked example are documented in `docs/MANUAL.md` in the Log step section of the Closeout Cycle.
- The closing sidecar authorship rule and the pre-certify allowlist declaration
  requirement are documented in `docs/MANUAL.md` in the Closeout Cycle section.

## Failure States and Drift Triggers
- Canon changes without a matching SoP update.
- SoP entries that try to serve as PoW by embedding raw payloads instead of concise history.
- SoP entries that include a verification commands list.
- Deletions or edits of prior SoP history entries outside governed archival paths.

Enforcement linkage:
- `.github/workflows/sop_policing.yml` fails pull requests when canon surfaces change without a `SoP.md` update.
- The workflow contains a museum-log carve-out for `docs/ops/log/`-only changes.

## Mechanics and Sequencing
1. Finish implementation and verification.
2. Append a concise SoP entry that explains scope and rationale.
3. Do not reproduce the command list; RESULTS carries the full command log with outputs. SoP records what changed and why, not how it was verified.
4. Keep receipt path detail in PoW and RESULTS, not in long pasted blocks inside SoP.

Archive and retention behavior:
- Keep the most recent `30` SoP entries in `SoP.md`.
- Archive overflow to `archives/surfaces/SoP-archive-YYYY-MM.md` via `ops/bin/prune`.
- Archive files are continuation ledgers, not replacements for active SoP.

## Forensic Insight
SoP is the narrative memory of the system.
By separating historical explanation (SoP) from strict proof pointers (PoW), incident review can answer both questions quickly: what changed and where the exact evidence lives.
