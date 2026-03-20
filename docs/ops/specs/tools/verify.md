<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/verify.sh` enforces repository filing doctrine hygiene so required directories, payload surfaces, runtime placeholders, and control-plane reachability remain valid. It also provides policy-driven lane execution for certify replay, PR gates, and full repo hygiene.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and enforce required top-level directory presence.
2. Verify factory heads and pointer reachability.
3. Enforce payload/runtime hygiene:
   - require `storage/handoff`, `storage/dumps`, and `storage/dp`
   - fail tracked intake DP surfaces under `storage/dp/intake/` (`DP.md`, `ADDENDUM.md`, and any legacy packet-scoped intake packets)
   - require `var/tmp`, `logs`, archive subdirectories, and required `.gitkeep` placeholders
4. Apply filing doctrine content checks.
5. Emit warnings for unexpected payload clutter and missing project `README.md` files.
6. Load lane policy from `ops/etc/verification.manifest`. Each lane definition must declare:
   - `owner`
   - `registry_table`
   - `registry_path`
   - `reason_class`
   - `decision_leaf`
   - `match`
7. Resolve `Infra Importance` from the canonical registry row named by `registry_table` plus `registry_path`.
8. Select deterministic lanes by mode:
   - `--mode=full`: run every lane in order.
   - `--mode=certify-critical`: run `closeout-critical` lanes always and `packet-local` lanes only when changed paths match.
   - `--mode=gates`: run `closeout-critical` lanes always, run `packet-local` lanes on path match, and run `standalone-full-only` lanes only on path match.
9. Emit stable lane selection telemetry before execution.
10. Emit stable lane execution telemetry for each executed lane.
11. Emit one stable lane-order line before lane execution.

## Invocation Modes
- `bash tools/verify.sh`
- `bash tools/verify.sh --mode=full`
- `bash tools/verify.sh --mode=certify-critical`
- `bash tools/verify.sh --mode=certify-critical --paths-file=var/tmp/<file>.txt`
- `bash tools/verify.sh --mode=gates --paths-file=var/tmp/<file>.txt`

`certify-critical` is the bounded closeout-safety path for `ops/bin/certify`.
`gates` is the bounded PR-gate path that consumes the same lane policy but routes broader lanes by changed paths instead of replaying the whole repo blindly.
`full` remains the standalone complete hygiene pass.

## Integrity Filter Warnings
The script mixes hard failures and warnings by design. `--mode=certify-critical` and `--mode=gates` are intentionally narrower than full verify and must not be treated as substitutes for the full hygiene pass. Packet-local and gates-mode lane selection is deterministic from `--paths-file`; the script does not infer change relevance heuristically.
