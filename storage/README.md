# storage

Runtime/meta storage for development and DP closeout artifacts.

- Not deployed
- Directory skeleton is tracked (`.gitkeep`) for deterministic topology.
- Payload files are ignored by default unless explicitly tracked by DP scope and allowlist.

Keep non-DP local scratch artifacts out of commits.

Canonical storage lanes:
- `storage/handoff/` for OPEN, OPEN-PORCELAIN, and DP results.
- `storage/dumps/` for dump bundles and manifests.
- `storage/dp/intake/` for pre-closeout DP packet staging.
- `storage/dp/processed/` for post-closeout DP packets.
- `ops/bin/certify` enforces intake -> processed routing after the final `tools/lint/results.sh` pass.
- Intake is staging-only and should not carry tracked `DP-*.md` packets in committed state.
