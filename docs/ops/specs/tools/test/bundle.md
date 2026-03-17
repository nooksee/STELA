<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Technical Specification: tools/test/bundle.sh

## Purpose
Run deterministic transport smoke for `ops/bin/bundle`: profile routing, artifact naming, manifest invariants, audit delivery coherence, and rerun identity.

## Invocation
- `bash tools/test/bundle.sh`
- `bash tools/test/bundle.sh --mode=certify-critical`
- `bash tools/test/bundle.sh --slice=closeout-sanity|audit-coherence|route-contract|rerun-lineage`

## Slice Contract
- `closeout-sanity`: minimal audit delivery contract, current RESULTS/CLOSING presence, and dump/profile sanity.
- `audit-coherence`: current RESULTS, current CLOSING, active TASK leaf, and authoritative packet-source coherence.
- `route-contract`: analyst, architect, alias, ATS, and project/foreman route behavior.
- `rerun-lineage`: `AUDIT-*` initial delivery vs `AUDIT-R*` rerun lineage.

## Invariants and Failure Modes
- Valid profiles `analyst`, `architect`, `audit`, `conform`, and `auto` must succeed.
- Architect slice validation and ad hoc behavior remain deterministic.
- Analyst requires `storage/handoff/TOPIC.md` and must fail closed when it is missing.
- Analyst dump manifest must report `Persistence profile: analyst`.
- Analyst dump payload must contain explicit `[persistence metadata-only]` blocks for cold archive history.
- Architect dump manifest must report `Persistence profile: architect`.
- Audit requires current `RESULTS`, current `CLOSING`, and authoritative current packet source.
- Audit dump manifest must report `Persistence profile: audit`.
- Audit dump payload must contain direct file blocks for current `RESULTS`, current `CLOSING`, active TASK leaf, and packet source.
- Audit rerun smoke must prove distinct artifact identity:
  - first submission stays `AUDIT-*`
  - second submission becomes `AUDIT-R1-*`
  - rerun manifest records `submission.kind: audit_resubmission`
  - rerun manifest records `submission.resubmission_index: 1`
  - rerun manifest records `submission.supersedes_bundle_path`
- Smoke bundle invocations use explicit unique output paths under `var/tmp/_smoke/handoff/` with matching dump outputs under `var/tmp/_smoke/dumps/`.
- `--mode=certify-critical` runs only bounded closeout-safe slices and must not execute the full analyst/architect/ATS/meta matrix.

## Cleanup Contract
The test removes only paths created by the active run. Cleanup is confined to exact emitted paths under `var/tmp/_smoke/` and temporary runtime fixtures under `storage/` or `var/tmp/`.

## Related Pointers
- Registry entry: `docs/ops/registry/test.md` (`TEST-02`)
- Runtime implementation: `ops/lib/scripts/bundle.sh`
