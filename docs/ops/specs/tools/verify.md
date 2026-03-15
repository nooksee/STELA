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
6. Run deterministic smoke and lint gates by mode in a fixed fail-fast order:
   - `--mode=full` (default): `tools/test/open.sh`, `tools/test/editor.sh`, `tools/lint/debt.sh`, `tools/test/factory.sh`, `tools/lint/response.sh --test`, then `tools/test/bundle.sh`.
   - `--mode=certify-critical`: `tools/test/open.sh`, then `tools/test/bundle.sh --mode=certify-critical`.
7. Emit stable lane telemetry to stdout for every executed smoke/lint lane:
   - `VERIFY-LANE: name=<lane> scope=<certify-critical|full-only> status=<pass|fail|missing> duration_seconds=<N> detail=<command-or-path>`
   - Final recap lines use the same data as `VERIFY-LANE-SUMMARY: ...`
8. Emit one stable lane-order line before lane execution:
   - `VERIFY-LANE-ORDER: mode=<mode> order=<comma-separated-lanes>`

## Invocation modes
- `bash tools/verify.sh`
- `bash tools/verify.sh --mode=full`
- `bash tools/verify.sh --mode=certify-critical`

`certify-critical` is a bounded closeout-safety path for `ops/bin/certify`. It preserves the cheap structural and closeout-critical smoke checks while avoiding the heaviest repo-wide bundle/factory/debt replay cost. Narrative scaffold validation already occurs in certify preflight, so editor smoke remains full-mode only. Full verify remains the SSOT hygiene pass outside certify. The lane order is part of the contract: cheap deterministic failures should surface before the expensive bundle matrix.

## Anecdotal Anchor
The gate formalizes a recurring startup-failure class where missing required runtime subdirectories or placeholders broke binary workflows before task execution began. Once `tools/verify.sh` became a required pre-work check, those structural defects were caught before dispatch.

## Integrity Filter Warnings
The script mixes hard failures and warnings by design; warning-only findings still indicate hygiene drift that can become blocking later. Intake packet enforcement inspects tracked files, so untracked staging artifacts are outside that specific guard. Factory reachability checks validate candidate and promotion pointers, not full semantic validity of downstream definition content. `--mode=certify-critical` is intentionally narrower than full verify and must not be treated as a substitute for the full hygiene pass outside certify.
Lane summaries report only executed smoke/lint lanes, not the earlier in-process structural checks.
