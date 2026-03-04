<!-- CCD: ff_target="operator-technical" ff_band="10-20" -->
# Debt Registry

## Schema
Format:
`guard_id|added_in|owner|remove_by_dp|reason|status`

Rules:
- `added_in` and `remove_by_dp` use `DP-OPS-####` form
- `status` values: `active` or `resolved`
- Expired active rows fail `tools/lint/debt.sh`

## Entries
NONE|DP-OPS-0149|system|DP-OPS-0149|registry initialized with no active temporary guards|resolved
