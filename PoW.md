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

## 2026-02-14 04:18:34 UTC — DP-OPS-0062 Documentation Fortification and Help Doctrine Routing
- Packet ID: DP-OPS-0062
- Timestamp: 2026-02-14T04:18:34Z
- Work Branch: work/dp-ops-0062-documentation-fortification-2026-02-13
- Base HEAD: 124b6cc8
- Scope: platform
- Target Files allowlist:
  - docs/ops/registry/SCRIPTS.md
  - docs/ops/specs/scripts/synthesize.md
  - docs/ops/specs/surfaces/pow.md
  - docs/ops/specs/surfaces/sop.md
  - docs/ops/specs/binaries/help.md
  - ops/bin/help
  - docs/ops/specs/binaries/open.md
  - docs/ops/specs/binaries/prune.md
  - docs/ops/specs/tools/verify.md
  - docs/ops/specs/tools/lint/task.md
  - docs/ops/specs/scripts/task.md
  - llms.txt
  - llms-core.txt
  - llms-full.txt
  - SoP.md
  - PoW.md
- Receipt pointers:
  - RESULTS: storage/handoff/DP-OPS-0062-RESULTS.md
  - OPEN: storage/handoff/OPEN-work-dp-ops-0062-documentation-fortification-2026-02-13-124b6cc8.txt
  - DUMP: storage/dumps/dump-platform-work-dp-ops-0062-documentation-fortification-2026-02-13-124b6cc8.txt
- Verification commands:
  - bash tools/lint/context.sh
  - bash tools/lint/style.sh
  - bash tools/lint/truth.sh
  - bash tools/lint/dp.sh --test
  - bash tools/lint/dp.sh TASK.md
  - bash tools/lint/task.sh
  - bash tools/lint/llms.sh
  - ./tools/verify.sh
  - ./ops/bin/map
  - ./ops/bin/llms
  - ./ops/bin/help
  - ./ops/bin/help specs
  - ./ops/bin/help doctrine
  - ./ops/bin/help curriculum
  - ./ops/bin/prune --dry-run
  - ./ops/bin/prune --target=pow --dry-run
  - bash tools/lint/dp.sh storage/handoff/DP-OPS-0062-RESULTS.md
  - git diff --name-only
  - git diff --stat
- Notes: Positive proof confirms documentation fortification and help doctrine routing for DP-OPS-0062 with reproducible receipts and parity refresh. Negative proof recorded that CI policing failed before this ledger update because code-bearing and canon surfaces were changed without corresponding PoW and SoP entries; this entry resolves that drift.

## 2026-02-13 22:53:10 UTC — DP-OPS-0061 TASK Structure Hardening and PoW Integrity
- Packet ID: DP-OPS-0061
- Timestamp: 2026-02-13T22:53:10Z
- Work Branch: work/dp-ops-0061-task-structure-hardening-2026-02-13
- Base HEAD: 69f7b684
- Scope: platform
- Target Files allowlist:
  - docs/ops/specs/surfaces/task.md
  - tools/lint/dp.sh
  - tools/lint/task.sh
  - ops/bin/prune
  - docs/MANUAL.md
  - .github/workflows/pow_policing.yml
  - TASK.md
  - SoP.md
  - PoW.md
  - storage/dp/intake/DP-OPS-0061.md
- Receipt pointers:
  - RESULTS: storage/handoff/DP-OPS-0061-RESULTS.md
  - OPEN: storage/handoff/OPEN-work-dp-ops-0061-task-structure-hardening-2026-02-13-69f7b684.txt
  - DUMP: storage/dumps/dump-platform-work-dp-ops-0061-task-structure-hardening-2026-02-13-69f7b684.txt
- Verification commands:
  - bash tools/lint/context.sh
  - bash tools/lint/style.sh
  - bash tools/lint/truth.sh
  - bash tools/lint/dp.sh --test
  - bash tools/lint/dp.sh TASK.md
  - bash tools/lint/task.sh
  - bash tools/lint/llms.sh
  - ./tools/verify.sh
  - git status --porcelain=v1
  - ./ops/bin/prune --dry-run --reset-task --dp=DP-OPS-0061
  - git diff -- tools/lint/dp.sh
  - git diff --cached -- tools/lint/dp.sh
  - git diff --name-only --cached
  - git diff --stat --cached
  - git ls-files --others --exclude-standard
  - git diff --name-only
  - git diff --stat
- Notes: Positive proof recorded for TASK schema hardening and PoW reset gate enforcement; negative proof was captured before PoW entry creation when reset-task correctly blocked on missing Packet ID, and a follow-up dry-run confirmed reset-task unblocks once `- Packet ID: DP-OPS-0061` exists. Canonical DP heading levels were normalized across TASK/spec surfaces, and RESULTS strict-field lint now allows exact path tokens needed for deterministic manifest enumeration. DP-OPS-0061 allowlist was amended to include `tools/lint/dp.sh`, with explicit file-diff and dump-manifest proof for that path. Dump manifest proof explicitly includes `.github/workflows/pow_policing.yml` after staging, and diff coverage includes working-tree, staged, and untracked views. Abandoned attempts to keep legacy Work Log continuity were intentionally rejected by contract and lint updates.

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
