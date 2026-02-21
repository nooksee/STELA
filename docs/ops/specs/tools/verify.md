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

## Anecdotal Anchor
The gate formalizes a recurring startup-failure class where missing required runtime subdirectories or placeholders broke binary workflows before task execution began. Once `tools/verify.sh` became a required pre-work check, those structural defects were caught before dispatch.

## Integrity Filter Warnings
The script mixes hard failures and warnings by design; warning-only findings still indicate hygiene drift that can become blocking later. Intake packet enforcement inspects tracked files, so untracked staging artifacts are outside that specific guard. Factory reachability checks validate candidate and promotion pointers, not full semantic validity of downstream definition content.
