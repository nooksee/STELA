<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Surface Specification: ADDENDUM

## Constitutional Anchor
`storage/dp/intake/ADDENDUM.md` is the operator-issued addendum intake surface used to authorize bounded scope expansion against a base packet.

## Operator Contract
- Canonical template source: `ops/src/surfaces/addendum.md.tpl`.
- Rendering pipeline: `ops/bin/template render addendum`.
- Canonical issuance binary: `ops/bin/addendum`.
- Required sections and order:
  - `### Addendum <ID> to <BASE_DP_ID>`
  - `## A.1 Authorization`
  - `## A.2 Scope Delta`
  - `## A.3 Addendum Objective`
  - `## A.4 Context Load`
  - `## A.5 Addendum Receipt (Proofs to collect) - MUST RUN`
- Required slot-backed fields:
  - `Operator Authorization`
  - `Base Packet`
  - `Addendum ID`
  - non-empty `SCOPE_DELTA`
  - non-empty `ADDENDUM_OBJECTIVE`
  - non-empty `ADDENDUM_RECEIPT`

## Mechanics and Sequencing
1. Operator or supervisor authorizes addendum issuance for a base packet.
2. `ops/bin/addendum` resolves the canonical template and its hash from `tools/lint/dp.sh`.
3. The addendum surface is rendered from slots plus binary-supplied `BASE_DP_ID` and `ADDENDUM_ID`.
4. The rendered addendum is validated and written to `storage/dp/intake/ADDENDUM.md`.
5. Worker receives the finished addendum as a bounded execution extension; worker does not author the addendum.

## Failure States and Drift Triggers
- Missing required headings or reordered surface structure.
- Placeholder or blank slot-backed content.
- Non-exact paths in `## A.2 Scope Delta`.
- Drift between `tools/lint/dp.sh` canonical addendum template constants and `ops/src/surfaces/addendum.md.tpl`.
- Surface behavior documented only through binary prose instead of the first-class surface contract.

## Related Pointers
- `docs/ops/specs/binaries/addendum.md`
- `docs/ops/specs/tools/lint/dp.md`
