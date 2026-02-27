<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Surface Specification: Contractor Notes

## Purpose
`storage/dp/active/notes.md` is the closeout-time handoff surface used for
operator pre-audit review before final closeout decisions.

## Surface Roles
- `ops/src/surfaces/notes.md.tpl`: SSOT schema template for the Contractor Notes
  surface.
- `storage/dp/active/notes.md`: Authored instance for the active packet.
- DP closeout routing consumes this surface as a handoff narrative input before
  operator pre-audit review.

## Enforcement
This slice adds no enforcement. Any enforcement for this contract belongs in a
future slice.

## Template Source of Truth
- SSOT: `ops/src/surfaces/notes.md.tpl`

## Required Fields
- `Scope Confirmation`: Declares what executed versus what was scoped and records
  intentional skips with reasons.
- `Anomalies Encountered`: Captures friction items, unexpected behavior, and
  workaround decisions; use `None.` when absent.
- `Open Items / Residue`: Captures unresolved residue or audit hazards; use `None.`
  when absent.
- `Closing Schema Baseline`: Declares the active closing-schema assumption for the
  packet and any explicit compatibility exception notes.

## Decision Record Contract
- Trigger rule: decision record required only when `Anomalies Encountered` or
  `Open Items / Residue` is not `None.`
- Minimum fields: `decision_id`, `trace_id`, `packet_id`, `decision_type`,
  `context`, `decision`, `consequence`, `status`, `pointer`
- Archive destination: `archives/decisions/`
- Routing rule: when required, the decision leaf pointer is recorded as
  repo-relative text within the relevant Contractor Notes section narrative.

## Non-Goals
- No schema changes to closeout labels.
- No enforcement changes.
- No historical archive retrofitting.
