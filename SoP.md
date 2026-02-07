Archive policy: keep most recent 30 entries; older entries moved to `storage/archives/root/SoP-archive-YYYY-MM.md`.

## 2026-02-07 13:07:38 UTC — DP-OPS-0032 Harden TASK DP Boilerplate and Align DP Lint
- Hardened TASK.md DP boilerplate with explicit DP scope markers and sanitized placeholders.
- Updated tools/lint/dp.sh to accept decimal DP headings alongside the legacy format and expanded tests for both formats.
- Ran verification: ./ops/bin/dump --scope=platform (non-zero), bash tools/verify.sh, bash tools/lint/context.sh, bash tools/lint/truth.sh, bash tools/lint/library.sh, bash tools/lint/dp.sh --test.

## 2026-02-07 02:08:45 UTC — DP-OPS-0031 Pointer-First Agent Constitution & System Hardening
- Refactored R-AGENT-01 through R-AGENT-06 into pointer-first Markdown, removing legacy YAML metadata and embedding role details in prose.
- Automated llms.txt generation in ops/bin/llms to keep the discovery map synchronized with repository state.
- Added a guardrail audit command to ops/lib/scripts/agent.sh to enforce scope boundaries and detect context hazards.
- Updated TASK.md active context to DP-OPS-0031 and recorded the DP-OPS-0031 work log entry.

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
