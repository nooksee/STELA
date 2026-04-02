---
trace_id: stela-20260402T194515Z-77586cdb
packet_id: DP-OPS-0244
created_at: 2026-04-02T19:47:55Z
previous: archives/surfaces/SoP-2026-04-02-e99404c8.md
---
## 2026-04-02 19:07:03 UTC - DP-OPS-0244 Decouple core DP spine naming from task and surface names

Packet ID: DP-OPS-0244
Timestamp: 2026-04-02 19:07:03 UTC
Work Branch: work/dp-ops-0244-2026-04-02
Base HEAD: 8affdafe
Objective Summary: decouple core DP spine naming by renaming the execution narrative contract, normalizing active role language, removing legacy stance-role aliases, and separating surface templates/specs from stance templates.
Functional Receipt Summary: bash tools/lint/dp.sh --test, bash tools/lint/dp.sh storage/dp/intake/DP.md, bash tools/lint/dp.sh TASK.md, bash tools/lint/task.sh, bash tools/lint/response.sh --test, bash tools/lint/style.sh, bash tools/lint/truth.sh, ./ops/bin/manifest render stance-planning --out=- >/dev/null, ./ops/bin/llms, ./ops/bin/open --out=auto, ./ops/bin/allowlist, and bash tools/lint/integrity.sh passed before certify.
Notes: TASK.md was mechanically rerendered through the authorized ops/bin/draft recovery path after the DP template changed. Factory identity cleanup remains intentionally deferred.
