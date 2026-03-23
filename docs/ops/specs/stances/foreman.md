<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/foreman.md.tpl

## Purpose
Define the template-backed foreman stance body used for `foreman` profile bundle contract rendering.

## Invocation
- Canonical render path: `ops/bin/manifest render stance-foreman --out=-`
- Legacy alias: `ops/bin/manifest render stance-authority --out=-`
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/foreman.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- First non-empty line inside the fenced body must start with `### Addendum`.
- For machine-ingest foreman mode, output must include addendum headings `## A.1 Authorization` through `## A.5 Addendum Receipt (Proofs to collect) - MUST RUN`.
- For machine-ingest foreman mode, if `Decision Required:` and `Decision Leaf:` lines appear, values must be coherent (`Yes` with `archives/decisions/RoR-*.md`, `No` with `None`).

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.

## Shipping Spine Position
Foreman is a bounded secondary lane in the shipping spine. It is an intervention path only, not a PASS/FAIL verdict workflow. The foreman chain:
1. Contractor or auditor reports a boundary condition to the operator.
2. Operator runs: `./ops/bin/bundle --profile=foreman --intent="ADDENDUM REQUIRED: <BASE_DP_ID> - <BLOCKER>" --out=auto`
3. Foreman model receives `FOREMAN-*.txt` bundle and builds the addendum case from visible evidence in the dump (RESULTS narrative, OPEN metadata, boundary condition in intent). No pre-existing decision leaf is required.
4. Foreman outputs an authorized addendum fenced block. Operator provides `OPERATOR_AUTHORIZATION` and issues the addendum via `ops/bin/addendum`.
5. Contractor receives and executes the finished addendum document.

The foreman lane does not replace RESULTS, CLOSING, or audit truth. Addendum authority flows through operator/foreman issuance only; workers do not self-authorize addendum scope.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/foreman.md.tpl`
- `docs/ops/specs/binaries/addendum.md`
