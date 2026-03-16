<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/verify.sh` enforces repository filing doctrine hygiene so required platform directories, runtime placeholder files, and factory head entry points stay valid at all times. The script protects PoT Section 1.1 physical laws by proving that the filesystem layout and factory reachability assumptions required for startup and closeout remain intact.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and enforce required top-level directory presence.
2. Verify required factory heads exist, then validate `candidate` and `promotion` pointers for each head:
   - Accept exact `-(origin)` sentinels.
   - Require non-origin pointers to resolve under `archives/definitions/`.
3. Enforce payload/runtime hygiene:
   - Require `storage/handoff`, `storage/dumps`, and `storage/dp`.
   - Fail tracked intake packets under `storage/dp/intake/DP-*.md`.
   - Require `var/tmp`, `logs`, archive subdirectories, and required `.gitkeep` placeholders.
4. Apply filing doctrine content checks:
   - Fail binary files in `docs/` and `opt/`.
   - Fail non-markdown files in `docs/` and `opt/`.
   - Fail loose markdown in `ops/` outside allowed subtrees.
5. Emit warnings (not hard failures) for unexpected `storage/` clutter and missing project `README.md` files.
6. Load lane policy from `ops/lib/manifests/VERIFY.md`. Each lane definition must declare:
   - `owner`
   - `registry_table`
   - `registry_path`
   - `reason_class`
   - `decision_leaf`
   - `match`
7. Resolve `Infra Importance` from the canonical registry row named by `registry_table` plus `registry_path`:
   - `docs/ops/registry/binaries.md`
   - `docs/ops/registry/lint.md`
   - `docs/ops/registry/test.md`
8. Select deterministic lanes by mode:
   - `--mode=full` runs every policy lane in order.
   - `--mode=certify-critical` runs `closeout-critical` lanes always.
   - `--mode=certify-critical --paths-file=PATH` additionally runs `packet-local` lanes when at least one changed path matches the lane `match` list.
   - `standalone-full-only` lanes are deferred in certify-critical mode.
9. Emit stable lane selection telemetry before execution:
   - `VERIFY-SELECTION: name=<lane> scope=<scope> reason_class=<reason_class> owner=<ID> infra_importance=<level> decision_leaf=<path|none> detail=<command>`
   - `VERIFY-DEFERRED: name=<lane> scope=<scope> reason_class=<reason_class> owner=<ID> infra_importance=<level> decision_leaf=<path|none> reason=<why> detail=<command>`
10. Emit stable lane execution telemetry to stdout for every executed smoke/lint lane:
   - `VERIFY-LANE: name=<lane> scope=<scope> reason_class=<reason_class> owner=<ID> infra_importance=<level> decision_leaf=<path|none> status=<pass|fail|missing> duration_seconds=<N> detail=<command-or-path>`
   - Final recap lines use the same data as `VERIFY-LANE-SUMMARY: ...`
11. Emit one stable lane-order line before lane execution:
   - `VERIFY-LANE-ORDER: mode=<mode> order=<comma-separated-lanes>`

## Invocation modes
- `bash tools/verify.sh`
- `bash tools/verify.sh --mode=full`
- `bash tools/verify.sh --mode=certify-critical`
- `bash tools/verify.sh --mode=certify-critical --paths-file=var/tmp/<file>.txt`

`certify-critical` is a bounded closeout-safety path for `ops/bin/certify`. It preserves closeout-critical lanes and, when a `--paths-file` is provided, packet-local lanes whose owned paths were touched by the active packet. Narrative scaffold validation already occurs in certify preflight, so editor smoke remains full-mode only. Full verify remains the SSOT hygiene pass outside certify. The lane order is part of the contract: cheap deterministic failures should surface before the expensive bundle matrix.

## Anecdotal Anchor
The gate formalizes a recurring startup-failure class where missing required runtime subdirectories or placeholders broke binary workflows before task execution began. Once `tools/verify.sh` became a required pre-work check, those structural defects were caught before dispatch.

## Integrity Filter Warnings
The script mixes hard failures and warnings by design; warning-only findings still indicate hygiene drift that can become blocking later. Intake packet enforcement inspects tracked files, so untracked staging artifacts are outside that specific guard. Factory reachability checks validate candidate and promotion pointers, not full semantic validity of downstream definition content. `--mode=certify-critical` is intentionally narrower than full verify and must not be treated as a substitute for the full hygiene pass outside certify. Packet-local lane selection is deterministic from `--paths-file`; the script does not infer change relevance heuristically.
Lane summaries report only executed smoke/lint lanes, not the earlier in-process structural checks.
