<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Surface Specification: SoP.md

## Constitutional Anchor
`SoP.md` is the durable State of Play surface defined by PoT.
It answers what matters now and preserves the latest shipment in one immutable chain.
It does not carry executable proof payloads. Proof pointers belong in `PoW.md`.

## Operator Contract
- Root form: one repository-relative pointer to the current immutable `archives/surfaces/SoP-*.md` leaf.
- Current leaf model: one present-state block followed by one latest-shipment entry.
- Current pointer target frontmatter: `state_model: present-v1` in addition to the shared surface-leaf provenance keys.
- Required present-state fields:
  - `Current objective`
  - `Accepted baseline`
  - `Provisional work`
  - `Unresolved tensions`
  - `Rejected directions`
  - `Exact next action`
- Latest-shipment header pattern:
  - `## YYYY-MM-DD HH:MM:SS UTC — DP-OPS-XXXX <summary>`
- Latest-shipment body contract:
  - Objective summary.
  - Optional functional receipt summary.
- Separation rule:
  - Keep present orientation and concise shipment narrative in `SoP.md`.
  - Keep strict proof pointers in `PoW.md`.
- The pre-certify current-state authoring rule and a worked example are documented in `docs/MANUAL.md` in the Log step section of the Closeout Cycle.
- The closing sidecar authorship rule and the pre-certify allowlist declaration
  requirement are documented in `docs/MANUAL.md` in the Closeout Cycle section.

The present-state promise is deliberately durable rather than volatile. `SoP.md` states the accepted baseline and the next intended move. `TASK.md` states whether packet work is active. OPEN reports live Git and working-tree state. A work branch may propose a replacement State of Play, but that proposal becomes the accepted baseline only after merge.

## Failure States and Drift Triggers
- A current leaf missing any required present-state field.
- A blank, placeholder, or multi-line value where one concise field value is required.
- More than one latest-shipment entry in the current leaf.
- SoP entries that try to serve as PoW by embedding raw payloads instead of concise history.
- SoP entries that include a verification commands list.
- Edits to prior immutable SoP leaves.

Enforcement linkage:
- `tools/lint/schema.sh` resolves the current root pointer and validates the six required present-state fields and one latest-shipment entry.
- `ops/bin/certify` rejects a current-packet SoP authoring body that lacks the present-state contract.
- `.github/workflows/gates.yml` verifies pointer reachability and runs schema lint.

## Mechanics and Sequencing
1. Finish implementation and verification.
2. Author the six present-state fields for the post-merge baseline.
3. Add one concise latest-shipment entry for the current packet.
4. Do not reproduce the command list; RESULTS carries the full command log with outputs.
5. Keep receipt path detail in PoW and RESULTS, not in long pasted blocks inside SoP.

Archive and retention behavior:
- `ops/bin/certify` snapshots the authored current state and latest shipment into a new immutable leaf.
- The leaf frontmatter `previous` pointer preserves the complete shipment and state-transition chain.
- `SoP.md` then points to that newest leaf. Prior leaves remain unchanged.

## Forensic Insight
SoP is both the durable orientation surface and the narrative memory of the system.
Its current leaf answers where a successor should begin. Its immutable ancestry answers how the accepted baseline developed. PoW remains the independent proof index.
