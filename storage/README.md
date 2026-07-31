# storage

Runtime/meta storage for development and DP closeout artifacts.

- Not deployed
- Directory skeleton is tracked (`.gitkeep`) for deterministic topology.
- Payload files are ignored by default unless explicitly tracked by DP scope and allowlist.
- Payload surfaces are disposable or latest-wins unless a defined closeout route promotes their evidence.

Keep non-DP local scratch artifacts out of commits.
Keep source code, executable programs, laboratories, and durable documentation out of `storage/`.

Canonical storage lanes:
- `storage/handoff/` for OPEN, OPEN-PORCELAIN, and DP results.
- `storage/dumps/` for dump bundles and manifests.
- `storage/dp/intake/` for pre-closeout DP packet staging.
- `storage/dp/active/` durable allowlist.txt lives here.
- `ops/bin/certify` enforces intake -> processed routing after the final `tools/lint/results.sh` pass.
- Intake is staging-only and should not carry tracked `DP.md` packets in committed state.
- Handoff is a flat payload lane. Subdirectories and executable programs are filing-doctrine failures.
