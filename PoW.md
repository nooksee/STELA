Archive policy: keep most recent 30 entries; older entries moved to `storage/archives/root/PoW-archive-YYYY-MM.md`.

# Proof of Work Ledger (PoW)

## Purpose
- `PoW.md` is the root execution-proof ledger.
- Entries are append-only and must be machine-safe to parse.
- Each entry records the exact evidence pointers that justify state-changing work.

## Operator Guidance
- Use the exact field order and labels defined below.
- Do not embed raw OPEN or DUMP payloads in this file.
- Receipt pointers must reference committed artifacts before ledger pruning is allowed.
- Record both `OPEN` and `DUMP` pointers with each completed DP entry.

## Entry Header Pattern
- `## YYYY-MM-DD HH:MM:SS UTC — DP-OPS-XXXX <summary>`

## Required Entry Schema (Strict Order)
- `- Packet ID: DP-OPS-XXXX`
- `- Timestamp: YYYY-MM-DDTHH:MM:SSZ`
- `- Work Branch: work/<topic>-YYYY-MM-DD`
- `- Base HEAD: <short-hash>`
- `- Scope: platform|full|<explicit scope>`
- `- Target Files allowlist:`
- `  - <path>`
- `- Receipt pointers:`
- `  - RESULTS: storage/handoff/DP-OPS-XXXX-RESULTS.md`
- `  - OPEN: storage/handoff/OPEN-<branch>-<short-hash>.txt`
- `  - DUMP: storage/dumps/dump-<scope>-<branch>-<short-hash>.txt`
- `- Verification commands:`
- `  - <command>`
- `- Notes: <audit note>`

## 2026-02-13 19:41:30 UTC — DP-OPS-0060 TASK Template Archival and PoW Ledger
- Packet ID: DP-OPS-0060
- Timestamp: 2026-02-13T19:41:30Z
- Work Branch: work/dp-ops-0060-2026-02-13
- Base HEAD: ae8cc7b2
- Scope: platform
- Target Files allowlist:
  - PoT.md
  - SoP.md
  - PoW.md
  - TASK.md
  - docs/MAP.md
  - docs/MANUAL.md
  - ops/lib/manifests/CORE.md
  - docs/ops/specs/binaries/prune.md
  - docs/ops/specs/surfaces/task.md
  - ops/bin/open
  - ops/bin/prune
  - ops/bin/llms
  - tools/lint/dp.sh
  - tools/lint/truth.sh
  - llms.txt
  - llms-core.txt
  - llms-full.txt
- Receipt pointers:
  - RESULTS: storage/handoff/DP-OPS-0060-RESULTS.md
  - OPEN: storage/handoff/OPEN-work-dp-ops-0060-2026-02-13-ae8cc7b2.txt
  - DUMP: storage/dumps/dump-platform-work-dp-ops-0060-2026-02-13-ae8cc7b2.txt
- Verification commands:
  - bash tools/lint/context.sh
  - bash tools/lint/style.sh
  - bash tools/lint/truth.sh
  - bash tools/lint/dp.sh --test
  - bash tools/lint/dp.sh TASK.md
  - bash tools/lint/task.sh
  - bash tools/lint/llms.sh
  - ./tools/verify.sh
  - ./ops/bin/prune --dry-run
  - ./ops/bin/prune --target=pow --dry-run
  - bash tools/lint/dp.sh storage/handoff/DP-OPS-0060-RESULTS.md
- Notes: Root PoW surface introduced; prune now supports dual-ledger dry-run simulation and TASK template extraction contract.

## Template
Copy this block when appending a new entry.

```md
## YYYY-MM-DD HH:MM:SS UTC — DP-OPS-XXXX <summary>
- Packet ID: DP-OPS-XXXX
- Timestamp: YYYY-MM-DDTHH:MM:SSZ
- Work Branch: work/<topic>-YYYY-MM-DD
- Base HEAD: <short-hash>
- Scope: platform
- Target Files allowlist:
  - <path>
- Receipt pointers:
  - RESULTS: storage/handoff/DP-OPS-XXXX-RESULTS.md
  - OPEN: storage/handoff/OPEN-<branch>-<short-hash>.txt
  - DUMP: storage/dumps/dump-<scope>-<branch>-<short-hash>.txt
- Verification commands:
  - <command>
- Notes: <audit note>
```
