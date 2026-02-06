Archive policy: keep most recent 30 entries; older entries moved to `storage/archives/root/SoP-archive-YYYY-MM.md`.

## 2026-02-06 22:43:24 UTC — DP-OPS-0030 Governance Refactor & Hygiene
- Updated `tools/verify.sh` to allow `storage/archives` in drift checks.
- Added `storage/archives/.gitkeep` to ensure archive directory presence.
- Cleared `TASK.md` Work Log history and added an active DP notice.
- Ran `ops/bin/prune`; SoP remains within threshold with no archive move required.
- Refreshed `llms-small.txt` and `llms-full.txt`.

## 2026-02-06 21:24:55 UTC — DP-OPS-0029 Agent System Upgrade
- Added `ops/lib/scripts/agent.sh` for agent harvest + promote lifecycle.
- Created `docs/ops/registry/AGENTS.md` and registered it in `docs/library/INDEX.md`.
- Refactored `docs/library/agents/R-AGENT-01.md` through `R-AGENT-06.md` to pointer-first schema with provenance.
- Moved project registry to `docs/ops/registry/PROJECTS.md` and updated references.
