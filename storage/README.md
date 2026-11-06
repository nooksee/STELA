<!-- CCD: ff_target="discovery" ff_band="30-50" -->
# storage

## Purpose
Runtime storage for development and dispatch-packet closeout artifacts. Nothing here is deployed, and nothing here is canon: the leaves that certify emits go to `archives/`, not here.

## Structure
- `storage/handoff/` for OPEN and OPEN-PORCELAIN artifacts, the closing sidecar, the RESULTS working copy, and bundles.
- `storage/dumps/` for dump bundles and manifests.
- `storage/dp/intake/` for pre-closeout packet staging (`DP.md`, `ADDENDUM.md`, slots sidecars).
- `storage/dp/active/` for `allowlist.txt`, the persistent path policy, which is the one tracked payload file here.

## Entry Point
`./ops/bin/open --out=auto` writes the OPEN artifact here at session start; `./ops/bin/certify` reads the closing sidecar and the intake packet from here at closeout; `./ops/bin/bundle` writes its packages here.

## Constraints
- The directory skeleton is tracked (`.gitkeep`) for deterministic topology; payload files are ignored unless a packet scope and the allowlist track them.
- Intake is staging only and never carries a tracked `DP.md` in committed state; keep local scratch out of commits.
- `storage/handoff/CLOSING.md` is a latest-wins disposable surface; do not add per-packet closing paths to the allowlist.

## Canonical Pointer
`storage/dp/active/allowlist.txt` is the persistent path policy that `tools/lint/integrity.sh` and `ops/bin/certify` enforce; `storage/.gitignore` is the tracking rule.

## Where to Look Next
- `docs/MANUAL.md` for the closeout cycle that moves through these lanes.
- `docs/ops/specs/binaries/certify.md` for what certify reads and writes here.
- PoT 1.1 for the Filing Doctrine that names `storage/` as Payload.
