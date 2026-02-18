# storage

Local runtime/meta storage for development.

- Not deployed
- Usually ignored by git

Keep this empty in the repo; use it locally.

Local artifact retention (untracked, local-only):
- `storage/handoff/` for OPEN, OPEN-PORCELAIN, and DP results.
- `storage/dumps/` for dump bundles and manifests.
- `storage/dp/intake/` for pre-closeout DP packet staging.
- `storage/dp/processed/` for post-closeout DP packets.
- `ops/bin/certify` enforces intake -> processed routing after the final `tools/lint/results.sh` pass.
- These paths are not worker prerequisites unless a DP explicitly requires them.
