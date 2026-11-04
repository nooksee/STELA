# DP-OPS-0267 RESULTS

## Certification Metadata
- DP ID: DP-OPS-0267
- Certified At (UTC): 2026-11-04T19:48:10Z
- Branch: agent/dp-ops-0267-2026-11-04
- Git Hash: d68c49c5e9b03abfcc3cfa3d0e796cacc5e1ae70

## Scope Verification
- Target Files allowlist pointer: storage/dp/active/allowlist.txt
- dp_source: archives/surfaces/TASK-DP-OPS-0267-d68c49c5.md
- dump_manifest: none

### Integrity Lint Output
~~~text
Integrity scope mode: packet-exact
Packet scope paths: 14
Addendum scope paths: 0
Current-run compile leaves: 1
OK: integrity lint passed (12 observed paths).

Artifact Path Consistency: PASS
- Intake DP path: storage/dp/intake/DP.md
- Closing sidecar path: storage/handoff/CLOSING.md
- Active RESULTS path: storage/handoff/RESULTS.md
- Authoritative packet lineage class: archives/surfaces/TASK-DP-OPS-0267-<git-short-hash>.md
- Root-level lookalike variants absent: yes

Generated surface ownership policy:
- PoW.md
- SoP.md
- TASK.md
- archives/surfaces/PoW-2026-11-04-d68c49c5.md
- archives/surfaces/SoP-2026-11-04-d68c49c5.md
- archives/surfaces/TASK-DP-OPS-0267-d68c49c5.md
- archives/surfaces/RESULTS-DP-OPS-0267-d68c49c5.md

Post-command integrity recheck:
Integrity scope mode: maintenance-idle
Packet scope paths: 0
Addendum scope paths: 0
Current-run compile leaves: 0
OK: integrity lint passed (20 observed paths).

Active TASK packet-consistency recheck:
TASK packet-consistency check: PASS
- task_pointer: archives/surfaces/TASK-DP-OPS-0267-d68c49c5.md
- frontmatter_packet_id: DP-OPS-0267
- body_packet_id: DP-OPS-0267
- work_branch: agent/dp-ops-0267-2026-11-04

Dump-visible prune pressure report:
REPORT: target=dump class=archive-pow tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/PoW-*.md count=213 protected=0 bytes_total=1975007 weighted_bytes=17775063 top_path=archives/surfaces/PoW-2026-02-23-eaf0cd925.md top_bytes=96506
REPORT: target=dump class=archive-sop tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/SoP-*.md count=234 protected=0 bytes_total=1259205 weighted_bytes=11332845 top_path=archives/surfaces/SoP-2026-02-24-ccd451873.md top_bytes=69444
REPORT: target=dump class=archive-task tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/TASK-*.md count=207 protected=0 bytes_total=3488754 weighted_bytes=31398786 top_path=archives/surfaces/TASK-DP-OPS-0081-7ae7475b.md top_bytes=37057
REPORT: target=dump class=archive-compile tier=historical tier_weight=3 class_weight=2 retention=canonical pattern=archives/manifests/compile-*.md count=488 protected=0 bytes_total=2400314 weighted_bytes=14401884 top_path=archives/manifests/compile-2026-11-04T194611-d68c49c5.md top_bytes=5734
REPORT: target=dump class=archive-decision tier=historical tier_weight=3 class_weight=1 retention=canonical pattern=archives/decisions/*.md count=47 protected=0 bytes_total=103652 weighted_bytes=310956 top_path=archives/decisions/RoR-2026-03-12-001-cbc-0184.md top_bytes=3455
REPORT: target=dump class=archive-definition tier=historical tier_weight=3 class_weight=1 retention=canonical pattern=archives/definitions/*.md count=15 protected=0 bytes_total=36747 weighted_bytes=110241 top_path=archives/definitions/agent-candidate-2026-02-19-a74a0001.md top_bytes=3181
REPORT: target=dump class=docs-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=docs/* count=109 protected=0 bytes_total=427399 weighted_bytes=427399 top_path=docs/MANUAL.md top_bytes=53611
REPORT: target=dump class=ops-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=ops/* count=83 protected=0 bytes_total=645647 weighted_bytes=645647 top_path=ops/bin/certify top_bytes=87034
REPORT: target=dump class=tools-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=tools/* count=28 protected=0 bytes_total=417085 weighted_bytes=417085 top_path=tools/lint/dp.sh top_bytes=69975
REPORT: target=dump class=opt-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=opt/* count=8 protected=0 bytes_total=7152 weighted_bytes=7152 top_path=opt/_factory/INDEX.md top_bytes=1530
REPORT: target=dump class=planning-topic-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/TOPIC.md count=0 protected=0 bytes_total=0 weighted_bytes=0 top_path=(none) top_bytes=0
REPORT: target=dump class=draft-plan-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/PLAN.md count=0 protected=0 bytes_total=0 weighted_bytes=0 top_path=(none) top_bytes=0
REPORT: target=dump class=audit-results-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/RESULTS.md count=0 protected=0 bytes_total=0 weighted_bytes=0 top_path=(none) top_bytes=0
REPORT: target=dump class=audit-closing-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/CLOSING.md count=1 protected=1 bytes_total=2174 weighted_bytes=2174 top_path=storage/handoff/CLOSING.md top_bytes=2174
SUMMARY: target=dump action=report class_count=14 count_total=1433 protected_total=1 bytes_total=10763136 weighted_bytes_total=76829232
REPORT: target=repo-context class=archives-tree tier=historical tier_weight=3 class_weight=2 retention=canonical pattern=archives/* count=1212 protected=0 bytes_total=9394969 weighted_bytes=56369814 top_path=archives/surfaces/PoW-2026-02-23-eaf0cd925.md top_bytes=96506
REPORT: target=repo-context class=logs-tree tier=historical tier_weight=3 class_weight=1 retention=disposable pattern=logs/* count=3515 protected=0 bytes_total=531769 weighted_bytes=1595307 top_path=logs/trace-stela-20260218T043441Z-11d57a2b-retroleaf.md top_bytes=1516
REPORT: target=repo-context class=storage-dumps tier=historical tier_weight=3 class_weight=2 retention=disposable pattern=redacted-dump-artifact-glob count=7 protected=0 bytes_total=9477491 weighted_bytes=56864946 top_path=redacted-dump-artifact-path top_bytes=3187938
REPORT: target=repo-context class=storage-handoff tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=redacted-open-artifact-glob count=5 protected=1 bytes_total=9598 weighted_bytes=9598 top_path=redacted-open-artifact-path top_bytes=3519
SUMMARY: target=repo-context action=report class_count=4 count_total=4739 protected_total=1 bytes_total=19413827 weighted_bytes_total=114839665
SUMMARY: target=dump action=would_remove removed_count=0 removed_bytes=0
Prune phase complete: phase=report target=dump dry_run=1

Results lint verification:
OK: RESULTS lint passed (1 file(s) checked).
PASS: results template structure headings are present
PASS: recorded Git Hash equals HEAD (d68c49c5e9b03abfcc3cfa3d0e796cacc5e1ae70)
PASS: unresolved slot token scan clear
~~~

## Verification Command Log
### Command 01
- Command: `./ops/bin/certify --dp=DP-OPS-0267 --out=auto`
- Started (UTC): 2026-11-04T19:47:04Z
- Finished (UTC): 2026-11-04T19:47:04Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
Certify process initialized; invocation captured for receipt provenance.
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 02
- Command: `bash tools/lint/dp.sh --test`
- Started (UTC): 2026-11-04T19:47:05Z
- Finished (UTC): 2026-11-04T19:47:28Z
- Duration Seconds: 23
- Exit Code: 0

#### STDOUT
~~~text
CANONICAL_DP_TEMPLATE_SHA256=0b37977494196e0b5d8b485f263459d54431de20a6081ea4a80fa258467ece60
CANONICAL_ADDENDUM_TEMPLATE_SHA256=3bc51a5e6eab76e353ebe571b664f70cb13b905b43c7fdb3fd8794648a7316aa
OK: --test passed
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 03
- Command: `bash tools/lint/dp.sh TASK.md`
- Started (UTC): 2026-11-04T19:47:29Z
- Finished (UTC): 2026-11-04T19:47:30Z
- Duration Seconds: 1
- Exit Code: 0

#### STDOUT
~~~text
PASS: dp: contamination: no foreign citation tokens detected
PASS: dp: include metadata leakage: no leaked include metadata detected
OK: DP lint passed
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 04
- Command: `bash tools/lint/task.sh`
- Started (UTC): 2026-11-04T19:47:30Z
- Finished (UTC): 2026-11-04T19:47:31Z
- Duration Seconds: 1
- Exit Code: 0

#### STDOUT
~~~text
OK: Task lint checks passed.
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 05
- Command: `internal: surface leaf emission and HEAD pointer rewrite`
- Started (UTC): 2026-11-04T19:47:31Z
- Finished (UTC): 2026-11-04T19:47:31Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
Phase 2 surface leaves emitted:
- PoW.md -> archives/surfaces/PoW-2026-11-04-d68c49c5.md
- SoP.md -> archives/surfaces/SoP-2026-11-04-d68c49c5.md
- TASK.md -> archives/surfaces/TASK-DP-OPS-0267-d68c49c5.md
- durable RESULTS destination -> archives/surfaces/RESULTS-DP-OPS-0267-d68c49c5.md
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 06
- Command: `bash tools/lint/integrity.sh`
- Started (UTC): 2026-11-04T19:47:31Z
- Finished (UTC): 2026-11-04T19:47:33Z
- Duration Seconds: 2
- Exit Code: 0

#### STDOUT
~~~text
Integrity scope mode: maintenance-idle
Packet scope paths: 0
Addendum scope paths: 0
Current-run compile leaves: 0
OK: integrity lint passed (16 observed paths).
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 07
- Command: `bash tools/lint/style.sh`
- Started (UTC): 2026-11-04T19:47:33Z
- Finished (UTC): 2026-11-04T19:47:34Z
- Duration Seconds: 1
- Exit Code: 0

#### STDOUT
~~~text
(empty)
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 08
- Command: `./ops/bin/llms`
- Started (UTC): 2026-11-04T19:47:34Z
- Finished (UTC): 2026-11-04T19:47:34Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
Wrote llms-core.txt llms-full.txt llms.txt
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 09
- Command: `git diff --name-only`
- Started (UTC): 2026-11-04T19:47:34Z
- Finished (UTC): 2026-11-04T19:47:34Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
PoW.md
SoP.md
TASK.md
docs/ops/registry/runbook.md
docs/ops/specs/runbook/claude.md
docs/ops/specs/runbook/gpt.md
llms-core.txt
llms-full.txt
llms.txt
ops/lib/manifests/OPS.md
ops/src/runbook/claude.yaml
ops/src/runbook/gpt.yaml
tools/test/inventory.sh
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 10
- Command: `git diff --stat`
- Started (UTC): 2026-11-04T19:47:34Z
- Finished (UTC): 2026-11-04T19:47:34Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
 PoW.md                           |   2 +-
 SoP.md                           |   2 +-
 TASK.md                          | 279 +-------------------------------------
 docs/ops/registry/runbook.md     |   5 +-
 docs/ops/specs/runbook/claude.md |  18 ++-
 docs/ops/specs/runbook/gpt.md    |   7 +-
 llms-core.txt                    | 283 +--------------------------------------
 llms-full.txt                    | 283 +--------------------------------------
 llms.txt                         |   4 +-
 ops/lib/manifests/OPS.md         |   1 +
 ops/src/runbook/claude.yaml      |  20 +--
 ops/src/runbook/gpt.yaml         |  10 +-
 tools/test/inventory.sh          |   2 +-
 13 files changed, 52 insertions(+), 864 deletions(-)
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 11
- Command: `comm -23 <(git diff --name-only | sort) <(sort storage/dp/active/allowlist.txt) || true`
- Started (UTC): 2026-11-04T19:47:34Z
- Finished (UTC): 2026-11-04T19:47:34Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
(empty)
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 12
- Command: `comm -23 <(git ls-files --others --exclude-standard | sort) <(sort storage/dp/active/allowlist.txt) || true`
- Started (UTC): 2026-11-04T19:47:34Z
- Finished (UTC): 2026-11-04T19:47:34Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
archives/manifests/compile-2026-11-04T194611-d68c49c5.md
archives/manifests/compile-2026-11-04T194734-d68c49c5.md
archives/surfaces/PoW-2026-11-04-d68c49c5.md
archives/surfaces/SoP-2026-11-04-d68c49c5.md
archives/surfaces/TASK-DP-OPS-0267-d68c49c5.md
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 13
- Command: `./ops/bin/open`
- Started (UTC): 2026-11-04T19:47:34Z
- Finished (UTC): 2026-11-04T19:47:35Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
===== STELA OPEN PROMPT =====

Adhere to the Behavioral Standard defined in PoT.md.
Mode: collaborator stance. Follow repo canon and request missing context.

[FRESHNESS GATE]
- Active branch: agent/dp-ops-0267-2026-11-04
- HEAD short hash: d68c49c5
- DP id/date (if applicable): (none)
- Intent for today: 
- STELA_TRACE_ID: stela-20261104T194735Z-17455e35

[ROLE CONTRACT]
Constitutional seats: Operator, Integrator, Contractor, and Auditor.
PoT.md Section 3.1 defines authority; the active work contract defines the assigned seat.
AI stance: Canon-first, explicit about unknowns, no invention.

[DO / DO NOT]
Do:
- PR-only changes; no main edits.
- Run required gates before close.
Do not:
- Edit main directly.
- Skip gates.

[CONSTITUTION / FOCUS]
- PoT.md

[PRESENT STATE]
- Current objective: Keep the docs, project, and runbook lanes at current truth on the restored certify path, and take the remaining PLAN items one Operator decision at a time.
- Accepted baseline: Main certifies packets under packet-exact scope; the docs front door, template registry, gates spec, and project lane surfaces match the repository; the three runbook adapters carry the texts the Operator deploys, with specs and registry rows in agreement.
- Exact next action: Decide the consult artifact contract (bounded question, attachment budget, advisory authority, operator disposition) before any consult bundle profile is built.
- TASK routing state: IDLE
- TASK packet state: COMPLETED
- TASK packet id: DP-OPS-0267

[PRIMARY WORK SURFACE]
- TASK.md (DP template + active work log)
- TASK does NOT auto-load unless it is included in your dump/attachments.
- When drafting a DP: use the DP AUTHORING SCAFFOLD embedded in the draft bundle; output only the DP; ask if required fields are missing.

[CANON POINTERS]
- PoT.md
- SoP.md
- PoW.md
- TASK.md
- docs/INDEX.md
- docs/MANUAL.md
- docs/MAP.md
- ops/lib/manifests/CONTEXT.md

[DUMP]
- If you need full repo context, run: ./ops/bin/dump --scope=core --format=chatgpt.
- For a file output: ./ops/bin/dump --scope=core --format=chatgpt --out=auto
- If factory content is intentionally in scope: ./ops/bin/dump --scope=platform --format=chatgpt --out=auto
- For factory-only inspection: ./ops/bin/dump --scope=factory --format=chatgpt --out=auto

[GIT STATE]
- Working tree: dirty
- Porcelain entries: 20
- Porcelain artifact: emitted
- Porcelain saved: redacted-porcelain-artifact-path
- Last commit: d68c49c5 Open DP-OPS-0267: carry the deployed runbook adapter texts for ChatGPT, Claude, and Gemini

[SHIPPING SPINE]
- Main chain: TOPIC.md -> PLAN.md -> storage/dp/intake/DP.md -> execution -> RESULTS + CLOSING -> audit bundle -> merge
- Active draft surface: storage/dp/intake/DP.md (latest-wins); packet identity is bundle/request-mediated.
- Certify requires STELA_TRACE_ID from this OPEN artifact or STELA_TRACE_ID env var.
- Audit dump: ./ops/bin/bundle --profile=audit --out=auto (separate from session refresh)
- Secondary lanes: supervisor/addendum (intervention), execution-decision (disposable/manual at storage/handoff/EXECUTION-DECISION.md)

[NEXT OPERATOR MOVES]
- ./ops/bin/bundle --profile=auto --out=auto
- ./ops/bin/bundle --profile=draft --out=auto
  plan surface: storage/handoff/PLAN.md (absent)
  dp draft surface: storage/dp/intake/DP.md (packet_id in bundle [REQUEST])
- ./ops/bin/dump --scope=core --format=chatgpt

[OPERATOR CONTEXT]
- If any canon pointers are missing, say so.

===== END STELA OPEN PROMPT =====
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 14
- Command: `bash tools/lint/truth.sh`
- Started (UTC): 2026-11-04T19:47:35Z
- Finished (UTC): 2026-11-04T19:47:35Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
Stela Truth Verification
------------------------
Scanning for typos (Stela)...
Scanning for forbidden legacy terminology...
Scanning for legacy registry path casing...
------------------------
OK: Truth Integrity Verified.
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 15
- Command: `bash tools/lint/schema.sh`
- Started (UTC): 2026-11-04T19:47:35Z
- Finished (UTC): 2026-11-04T19:47:58Z
- Duration Seconds: 23
- Exit Code: 0

#### STDOUT
~~~text
OK: schema lint passed (1157 file(s) checked: definitions=15, surfaces=654, manifests=488).
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 16
- Command: `bash tools/test/inventory.sh`
- Started (UTC): 2026-11-04T19:47:58Z
- Finished (UTC): 2026-11-04T19:48:00Z
- Duration Seconds: 2
- Exit Code: 0

#### STDOUT
~~~text
Runtime inventory report contract: pass=17 fail=0
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 17
- Command: `bash tools/verify.sh --inventory`
- Started (UTC): 2026-11-04T19:48:00Z
- Finished (UTC): 2026-11-04T19:48:01Z
- Duration Seconds: 1
- Exit Code: 0

#### STDOUT
~~~text
Stela Repo Hygiene Verification
Root: /home/claude/stela-lab
Verification Mode: full

INVENTORY-CONTRACT version=1 mode=report-only lifecycle_inference=0
INVENTORY-ITEM kind=binary path=ops/bin/addendum present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/addendum.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/allowlist present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/allowlist.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/bundle present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/bundle.md policy_refs=5 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/cbc present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/cbc.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/certify present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/certify.md policy_refs=3 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/compile present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/compile.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/context present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/context.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/decision present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/decision.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/draft present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/draft.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/dump present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/dump.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/factory present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/factory.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/help present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/help.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/hooks present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/hooks.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/hygiene present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/hygiene.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/llms present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/llms.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/manifest present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/manifest.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/map present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/map.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/meta present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/meta.md policy_refs=2 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/open present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/open.md policy_refs=3 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/prune present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/prune.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/scaffold present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/scaffold.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/template present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/template.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=binary path=ops/bin/trace present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/binaries/trace.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-SUMMARY kind=binary present=23 registered=23 present_registered=23 present_unregistered=0 registered_missing=0 spec_missing=0 metadata_missing=0
INVENTORY-ITEM kind=lint path=tools/lint/agent.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/agent.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/context.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/context.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/debt.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/debt.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/dp.sh present=1 registered=1 executable=0 spec=1 spec_path=docs/ops/specs/tools/lint/dp.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/factory.sh present=1 registered=1 executable=0 spec=1 spec_path=docs/ops/specs/tools/lint/factory.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/ff.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/ff.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/integrity.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/integrity.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/leaf.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/leaf.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/llms.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/llms.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/plan.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/plan.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/project.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/project.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/response.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/response.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/results.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/results.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/schema.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/schema.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/skill.sh present=1 registered=1 executable=0 spec=1 spec_path=docs/ops/specs/tools/lint/skill.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/style.sh present=1 registered=1 executable=0 spec=1 spec_path=docs/ops/specs/tools/lint/style.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/task.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/task.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=lint path=tools/lint/truth.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/lint/truth.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-SUMMARY kind=lint present=18 registered=18 present_registered=18 present_unregistered=0 registered_missing=0 spec_missing=0 metadata_missing=0
INVENTORY-ITEM kind=test path=tools/test/agent.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/test/agent.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=test path=tools/test/bundle.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/test/bundle.md policy_refs=5 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=test path=tools/test/dp.sh present=1 registered=0 executable=0 spec=0 spec_path=docs/ops/specs/tools/test/dp.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=test path=tools/test/editor.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/test/editor.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=test path=tools/test/factory.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/test/factory.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=test path=tools/test/integrity.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/test/integrity.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=test path=tools/test/inventory.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/test/inventory.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=test path=tools/test/open.sh present=1 registered=1 executable=0 spec=1 spec_path=docs/ops/specs/tools/test/open.md policy_refs=3 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=test path=tools/test/results.sh present=1 registered=0 executable=0 spec=0 spec_path=docs/ops/specs/tools/test/results.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-SUMMARY kind=test present=9 registered=7 present_registered=7 present_unregistered=2 registered_missing=0 spec_missing=2 metadata_missing=0
INVENTORY-ITEM kind=hook path=.github/hooks/pre-commit present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/hooks/pre-commit.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=hook path=.github/hooks/pre-push present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/hooks/pre-push.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-SUMMARY kind=hook present=2 registered=2 present_registered=2 present_unregistered=0 registered_missing=0 spec_missing=0 metadata_missing=0
INVENTORY-ITEM kind=script path=ops/lib/scripts/agent.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/scripts/agent.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/bundle.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/scripts/bundle.md policy_refs=5 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/common.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/scripts/common.md policy_refs=1 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/editor.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/scripts/editor.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/factory.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/scripts/factory.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/heuristics.sh present=1 registered=1 executable=0 spec=1 spec_path=docs/ops/specs/scripts/heuristics.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/ledger.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/scripts/ledger.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/project.sh present=1 registered=1 executable=0 spec=1 spec_path=docs/ops/specs/scripts/project.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/skill.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/scripts/skill.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/synthesize.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/scripts/synthesize.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/task.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/scripts/task.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=script path=ops/lib/scripts/traverse.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/scripts/traverse.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-SUMMARY kind=script present=12 registered=12 present_registered=12 present_unregistered=0 registered_missing=0 spec_missing=0 metadata_missing=0
INVENTORY-ITEM kind=tool path=tools/verify.sh present=1 registered=1 executable=1 spec=1 spec_path=docs/ops/specs/tools/verify.md policy_refs=2 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-SUMMARY kind=tool present=1 registered=1 present_registered=1 present_unregistered=0 registered_missing=0 spec_missing=0 metadata_missing=0
INVENTORY-ITEM kind=runbook path=ops/src/runbook/claude.yaml present=1 registered=1 executable=na spec=1 spec_path=docs/ops/specs/runbook/claude.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=runbook path=ops/src/runbook/execution-decision.yaml present=1 registered=1 executable=na spec=1 spec_path=docs/ops/specs/runbook/execution-decision.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=runbook path=ops/src/runbook/gemini.yaml present=1 registered=1 executable=na spec=1 spec_path=docs/ops/specs/runbook/gemini.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-ITEM kind=runbook path=ops/src/runbook/gpt.yaml present=1 registered=1 executable=na spec=1 spec_path=docs/ops/specs/runbook/gpt.md policy_refs=0 declared_router=na literal_consumers=na metadata_complete=na lifecycle=unclassified
INVENTORY-SUMMARY kind=runbook present=4 registered=4 present_registered=4 present_unregistered=0 registered_missing=0 spec_missing=0 metadata_missing=0
INVENTORY-ITEM kind=template path=ops/src/decisions/cbc.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=decision literal_consumers=1 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/decisions/dec.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=decision literal_consumers=1 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/decisions/exec.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=decision literal_consumers=1 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/decisions/op.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=decision literal_consumers=1 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/definitions/agent.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=factory literal_consumers=2 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/definitions/skill.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=factory literal_consumers=2 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/definitions/task.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=factory literal_consumers=2 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/docs/adr.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=docs literal_consumers=0 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/docs/changelog.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=docs literal_consumers=0 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/docs/consumer.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=docs literal_consumers=0 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/docs/microdoc.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=docs literal_consumers=0 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/docs/readme.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=docs literal_consumers=0 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/docs/spec.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=1 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/manifests/context.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=0 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/manifests/core.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=0 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/manifests/discovery.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=0 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/manifests/ops.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=0 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/stances/addenda.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=1 declared_router=manifest literal_consumers=2 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/stances/audit.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=1 declared_router=manifest literal_consumers=2 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/stances/draft.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=1 declared_router=manifest literal_consumers=2 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/stances/planning.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=1 declared_router=manifest literal_consumers=2 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/surfaces/addendum.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=2 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/surfaces/closing.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=1 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/surfaces/dp.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=5 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/surfaces/plan.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=0 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/surfaces/results.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=2 metadata_complete=1 lifecycle=unclassified
INVENTORY-ITEM kind=template path=ops/src/surfaces/task.md.tpl present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=1 metadata_complete=1 lifecycle=unclassified
INVENTORY-SUMMARY kind=template present=27 registered=27 present_registered=27 present_unregistered=0 registered_missing=0 spec_missing=0 metadata_missing=0
INVENTORY-TOTAL kinds=8 present=96 registered=94 present_registered=94 present_unregistered=2 registered_missing=0 spec_missing=2 metadata_missing=0
INVENTORY-STATUS mismatches=report-only lifecycle_decisions=0 repository_mutations=0
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 18
- Command: `grep -c "status: active" ops/src/runbook/gpt.yaml`
- Started (UTC): 2026-11-04T19:48:01Z
- Finished (UTC): 2026-11-04T19:48:01Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
1
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 19
- Command: `grep -c "status: active" ops/src/runbook/claude.yaml`
- Started (UTC): 2026-11-04T19:48:01Z
- Finished (UTC): 2026-11-04T19:48:01Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
1
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 20
- Command: `grep -c "status: active" ops/src/runbook/gemini.yaml`
- Started (UTC): 2026-11-04T19:48:01Z
- Finished (UTC): 2026-11-04T19:48:01Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
1
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 21
- Command: `grep -c RUNBOOK-03 docs/ops/registry/runbook.md`
- Started (UTC): 2026-11-04T19:48:01Z
- Finished (UTC): 2026-11-04T19:48:01Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
1
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 22
- Command: `bash tools/verify.sh --mode=certify-critical --paths-file=var/tmp/certify.DP-OPS-0267.E3xV0T/verify-paths.txt`
- Started (UTC): 2026-11-04T19:48:01Z
- Finished (UTC): 2026-11-04T19:48:05Z
- Duration Seconds: 4
- Exit Code: 0

#### STDOUT
~~~text
Stela Repo Hygiene Verification
Root: /home/claude/stela-lab
Verification Mode: certify-critical
Verification Paths File: var/tmp/certify.DP-OPS-0267.E3xV0T/verify-paths.txt

VERIFY-SELECTION: name=open-dedup scope=closeout-critical reason_class=closeout-critical owner=TEST-03 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md detail=bash tools/test/open.sh
VERIFY-SELECTION: name=packet-scope-contract scope=closeout-critical reason_class=closeout-critical owner=TEST-06 infra_importance=critical decision_leaf=none detail=bash tools/test/integrity.sh
VERIFY-SELECTION: name=bundle-certify-critical scope=closeout-critical reason_class=closeout-critical owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md detail=bash tools/test/bundle.sh --mode=certify-critical
VERIFY-LANE-ORDER: mode=certify-critical order=open-dedup,packet-scope-contract,bundle-certify-critical
VERIFY-DEFERRED: name=editor-scaffold scope=standalone-full-only reason_class=standalone-full-only owner=TEST-04 infra_importance=supporting decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md reason=standalone-full-only detail=bash tools/test/editor.sh
VERIFY-DEFERRED: name=guard-debt-lint scope=standalone-full-only reason_class=standalone-full-only owner=LINT-18 infra_importance=supporting decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md reason=standalone-full-only detail=bash tools/lint/debt.sh
VERIFY-DEFERRED: name=runtime-inventory-contract scope=standalone-full-only reason_class=standalone-full-only owner=TEST-07 infra_importance=supporting decision_leaf=none reason=standalone-full-only detail=bash tools/test/inventory.sh
VERIFY-DEFERRED: name=factory-smoke scope=packet-local reason_class=packet-local owner=TEST-05 infra_importance=important decision_leaf=archives/decisions/RoR-2026-03-16-003-cbc-0202.md reason=no-path-match detail=bash tools/test/factory.sh
VERIFY-DEFERRED: name=response-self-test scope=packet-local reason_class=packet-local owner=LINT-17 infra_importance=important decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md reason=no-path-match detail=bash tools/lint/response.sh --test
VERIFY-DEFERRED: name=bundle-route-contract scope=packet-local reason_class=packet-local owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md reason=not-in-mode detail=bash tools/test/bundle.sh --slice=route-contract
VERIFY-DEFERRED: name=bundle-package-contract scope=packet-local reason_class=packet-local owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md reason=not-in-mode detail=bash tools/test/bundle.sh --slice=package-contract
VERIFY-DEFERRED: name=bundle-fail-closed scope=packet-local reason_class=packet-local owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md reason=not-in-mode detail=bash tools/test/bundle.sh --slice=fail-closed
VERIFY-DEFERRED: name=bundle-rerun-lineage scope=packet-local reason_class=packet-local owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md reason=not-in-mode detail=bash tools/test/bundle.sh --slice=rerun-lineage
PASS: open de-dup test
VERIFY-LANE: name=open-dedup scope=closeout-critical reason_class=closeout-critical owner=TEST-03 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md status=pass duration_seconds=0 detail=bash tools/test/open.sh
Integrity scope fixture summary: pass=11 fail=0
VERIFY-LANE: name=packet-scope-contract scope=closeout-critical reason_class=closeout-critical owner=TEST-06 infra_importance=critical decision_leaf=none status=pass duration_seconds=3 detail=bash tools/test/integrity.sh
SKIP: no watched bundle-kernel file changed (mode: certify-critical)
VERIFY-LANE: name=bundle-certify-critical scope=closeout-critical reason_class=closeout-critical owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md status=pass duration_seconds=0 detail=bash tools/test/bundle.sh --mode=certify-critical


Verify lane summary:
VERIFY-LANE-SUMMARY: name=open-dedup scope=closeout-critical reason_class=closeout-critical owner=TEST-03 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md status=pass duration_seconds=0 detail=bash tools/test/open.sh
VERIFY-LANE-SUMMARY: name=packet-scope-contract scope=closeout-critical reason_class=closeout-critical owner=TEST-06 infra_importance=critical decision_leaf=none status=pass duration_seconds=3 detail=bash tools/test/integrity.sh
VERIFY-LANE-SUMMARY: name=bundle-certify-critical scope=closeout-critical reason_class=closeout-critical owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md status=pass duration_seconds=0 detail=bash tools/test/bundle.sh --mode=certify-critical

OK: Clean Platform State.
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 23
- Command: `git diff --exit-code -- ops/bin/open ops/lib/manifests/BUNDLE.md ops/src/runbook/execution-decision.yaml docs/ops/specs/runbook/execution-decision.md`
- Started (UTC): 2026-11-04T19:48:05Z
- Finished (UTC): 2026-11-04T19:48:05Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
(empty)
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 24
- Command: `git diff --check`
- Started (UTC): 2026-11-04T19:48:05Z
- Finished (UTC): 2026-11-04T19:48:05Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
(empty)
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 25
- Command: `bash tools/lint/integrity.sh`
- Started (UTC): 2026-11-04T19:48:05Z
- Finished (UTC): 2026-11-04T19:48:07Z
- Duration Seconds: 2
- Exit Code: 0

#### STDOUT
~~~text
Integrity scope mode: maintenance-idle
Packet scope paths: 0
Addendum scope paths: 0
Current-run compile leaves: 0
OK: integrity lint passed (20 observed paths).
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 26
- Command: `internal: verify active TASK leaf packet consistency`
- Started (UTC): 2026-11-04T19:48:07Z
- Finished (UTC): 2026-11-04T19:48:07Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
TASK packet-consistency check: PASS
- task_pointer: archives/surfaces/TASK-DP-OPS-0267-d68c49c5.md
- frontmatter_packet_id: DP-OPS-0267
- body_packet_id: DP-OPS-0267
- work_branch: agent/dp-ops-0267-2026-11-04
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 27
- Command: `internal: verify changed files subset of allowlist pointer (storage/dp/active/allowlist.txt)`
- Started (UTC): 2026-11-04T19:48:07Z
- Finished (UTC): 2026-11-04T19:48:08Z
- Duration Seconds: 1
- Exit Code: 0

#### STDOUT
~~~text
Changed-file dual-scope check: PASS
Packet exact paths: 14
Current-run compile leaves: 2
Changed files:
- PoW.md
- SoP.md
- TASK.md
- archives/manifests/compile-2026-11-04T194611-d68c49c5.md
- archives/manifests/compile-2026-11-04T194734-d68c49c5.md
- archives/surfaces/PoW-2026-11-04-d68c49c5.md
- archives/surfaces/SoP-2026-11-04-d68c49c5.md
- archives/surfaces/TASK-DP-OPS-0267-d68c49c5.md
- docs/ops/registry/runbook.md
- docs/ops/specs/runbook/claude.md
- docs/ops/specs/runbook/gemini.md
- docs/ops/specs/runbook/gpt.md
- llms-core.txt
- llms-full.txt
- llms.txt
- ops/lib/manifests/OPS.md
- ops/src/runbook/claude.yaml
- ops/src/runbook/gemini.yaml
- ops/src/runbook/gpt.yaml
- tools/test/inventory.sh
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 28
- Command: `./ops/bin/prune --target=dump --phase=report --dry-run`
- Started (UTC): 2026-11-04T19:48:08Z
- Finished (UTC): 2026-11-04T19:48:10Z
- Duration Seconds: 2
- Exit Code: 0

#### STDOUT
~~~text
REPORT: target=dump class=archive-pow tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/PoW-*.md count=213 protected=0 bytes_total=1975007 weighted_bytes=17775063 top_path=archives/surfaces/PoW-2026-02-23-eaf0cd925.md top_bytes=96506
REPORT: target=dump class=archive-sop tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/SoP-*.md count=234 protected=0 bytes_total=1259205 weighted_bytes=11332845 top_path=archives/surfaces/SoP-2026-02-24-ccd451873.md top_bytes=69444
REPORT: target=dump class=archive-task tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/TASK-*.md count=207 protected=0 bytes_total=3488754 weighted_bytes=31398786 top_path=archives/surfaces/TASK-DP-OPS-0081-7ae7475b.md top_bytes=37057
REPORT: target=dump class=archive-compile tier=historical tier_weight=3 class_weight=2 retention=canonical pattern=archives/manifests/compile-*.md count=488 protected=0 bytes_total=2400314 weighted_bytes=14401884 top_path=archives/manifests/compile-2026-11-04T194611-d68c49c5.md top_bytes=5734
REPORT: target=dump class=archive-decision tier=historical tier_weight=3 class_weight=1 retention=canonical pattern=archives/decisions/*.md count=47 protected=0 bytes_total=103652 weighted_bytes=310956 top_path=archives/decisions/RoR-2026-03-12-001-cbc-0184.md top_bytes=3455
REPORT: target=dump class=archive-definition tier=historical tier_weight=3 class_weight=1 retention=canonical pattern=archives/definitions/*.md count=15 protected=0 bytes_total=36747 weighted_bytes=110241 top_path=archives/definitions/agent-candidate-2026-02-19-a74a0001.md top_bytes=3181
REPORT: target=dump class=docs-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=docs/* count=109 protected=0 bytes_total=427399 weighted_bytes=427399 top_path=docs/MANUAL.md top_bytes=53611
REPORT: target=dump class=ops-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=ops/* count=83 protected=0 bytes_total=645647 weighted_bytes=645647 top_path=ops/bin/certify top_bytes=87034
REPORT: target=dump class=tools-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=tools/* count=28 protected=0 bytes_total=417085 weighted_bytes=417085 top_path=tools/lint/dp.sh top_bytes=69975
REPORT: target=dump class=opt-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=opt/* count=8 protected=0 bytes_total=7152 weighted_bytes=7152 top_path=opt/_factory/INDEX.md top_bytes=1530
REPORT: target=dump class=planning-topic-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/TOPIC.md count=0 protected=0 bytes_total=0 weighted_bytes=0 top_path=(none) top_bytes=0
REPORT: target=dump class=draft-plan-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/PLAN.md count=0 protected=0 bytes_total=0 weighted_bytes=0 top_path=(none) top_bytes=0
REPORT: target=dump class=audit-results-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/RESULTS.md count=0 protected=0 bytes_total=0 weighted_bytes=0 top_path=(none) top_bytes=0
REPORT: target=dump class=audit-closing-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/CLOSING.md count=1 protected=1 bytes_total=2174 weighted_bytes=2174 top_path=storage/handoff/CLOSING.md top_bytes=2174
SUMMARY: target=dump action=report class_count=14 count_total=1433 protected_total=1 bytes_total=10763136 weighted_bytes_total=76829232
REPORT: target=repo-context class=archives-tree tier=historical tier_weight=3 class_weight=2 retention=canonical pattern=archives/* count=1212 protected=0 bytes_total=9394969 weighted_bytes=56369814 top_path=archives/surfaces/PoW-2026-02-23-eaf0cd925.md top_bytes=96506
REPORT: target=repo-context class=logs-tree tier=historical tier_weight=3 class_weight=1 retention=disposable pattern=logs/* count=3515 protected=0 bytes_total=531769 weighted_bytes=1595307 top_path=logs/trace-stela-20260218T043441Z-11d57a2b-retroleaf.md top_bytes=1516
REPORT: target=repo-context class=storage-dumps tier=historical tier_weight=3 class_weight=2 retention=disposable pattern=redacted-dump-artifact-glob count=7 protected=0 bytes_total=9477491 weighted_bytes=56864946 top_path=redacted-dump-artifact-path top_bytes=3187938
REPORT: target=repo-context class=storage-handoff tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=redacted-open-artifact-glob count=5 protected=1 bytes_total=9598 weighted_bytes=9598 top_path=redacted-open-artifact-path top_bytes=3519
SUMMARY: target=repo-context action=report class_count=4 count_total=4739 protected_total=1 bytes_total=19413827 weighted_bytes_total=114839665
SUMMARY: target=dump action=would_remove removed_count=0 removed_bytes=0
Prune phase complete: phase=report target=dump dry_run=1
~~~

#### STDERR
~~~text
(empty)
~~~
### Command 29
- Command: `bash tools/lint/results.sh storage/handoff/RESULTS.md`
- Started (UTC): 2026-11-04T19:48:11Z
- Finished (UTC): 2026-11-04T19:48:11Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
OK: RESULTS lint passed (1 file(s) checked).
~~~

#### STDERR
~~~text
(empty)
~~~



## Git State Impact
### git diff --name-only
~~~text
PoW.md
SoP.md
TASK.md
docs/ops/registry/runbook.md
docs/ops/specs/runbook/claude.md
docs/ops/specs/runbook/gemini.md
docs/ops/specs/runbook/gpt.md
llms-core.txt
llms-full.txt
llms.txt
ops/lib/manifests/OPS.md
ops/src/runbook/claude.yaml
ops/src/runbook/gemini.yaml
ops/src/runbook/gpt.yaml
tools/test/inventory.sh
~~~

### git diff --stat
~~~text
 PoW.md                           |   2 +-
 SoP.md                           |   2 +-
 TASK.md                          | 279 +-------------------------------------
 docs/ops/registry/runbook.md     |   5 +-
 docs/ops/specs/runbook/claude.md |  18 ++-
 docs/ops/specs/runbook/gemini.md |  25 ++++
 docs/ops/specs/runbook/gpt.md    |   7 +-
 llms-core.txt                    | 283 +--------------------------------------
 llms-full.txt                    | 283 +--------------------------------------
 llms.txt                         |   4 +-
 ops/lib/manifests/OPS.md         |   1 +
 ops/src/runbook/claude.yaml      |  20 +--
 ops/src/runbook/gemini.yaml      |  62 +++++++++
 ops/src/runbook/gpt.yaml         |  10 +-
 tools/test/inventory.sh          |   2 +-
 15 files changed, 139 insertions(+), 864 deletions(-)
~~~

## Worker Execution Narrative
### Preflight State
git rev-parse --abbrev-ref HEAD
agent/dp-ops-0267-2026-11-04
git rev-parse --short HEAD
d68c49c5
git status --porcelain
(no output; the working tree was clean)
Preflight lint status: bash tools/lint/dp.sh --test exit 0; bash tools/lint/dp.sh TASK.md PASS; bash tools/lint/task.sh PASS.

### Implemented Changes
- ops/src/runbook/gpt.yaml: instruction_text replaced by the Operator's ChatGPT directive, verbatim (286 characters); version 1.1.0; failure modes expired-upload-notice-fallback and evidence-free-audit-output added; behavior probe rewritten; 2 expected signals added.
- ops/src/runbook/claude.yaml: STATUS and status active; instruction_text added verbatim (171 characters); version 1.1.0; description, deployment action, sunset condition, and notes updated; the reserve period is recorded in the notes.
- ops/src/runbook/gemini.yaml (new, version 2.0.0): research-only adapter with the Operator's Gem directive verbatim (2210 characters); role research; 5 failure modes; probe and 4 expected signals; the DP-OPS-0188 retirement of the earlier experimental adapter is recorded in the notes. All three files parse as YAML.
- docs/ops/specs/runbook/gpt.md (scores 45, band 30-45): 2 functional-proof bullets and an anchor for version 1.1.0. docs/ops/specs/runbook/claude.md (scores 45, band 30-45): rewritten for the active adapter. docs/ops/specs/runbook/gemini.md (new, operator-technical 45-60, scores 49): rationale, mechanics, the RUNBOOK-03 history, and the warning that a research adapter receives no audit bundle or dispatch packet.
- docs/ops/registry/runbook.md (scores 30, band 25-35): RUNBOOK-01 and RUNBOOK-02 notes updated; RUNBOOK-03 row added.
- tools/test/inventory.sh: INVENTORY-TOTAL pinned at present=96 registered=94 present_registered=94; 17 of 17 assertions pass; the runbook family reports 4 present, 4 registered, 0 spec missing.
- The two new files were staged before certify so the replayed ./ops/bin/llms compiled ops/lib/manifests/OPS.md with docs/ops/specs/runbook/gemini.md present.
- SoP.md and PoW.md authored for this packet; llms bundles regenerated by the receipt command.

### Closeout Notes
- The first packet-open draft carried a receipt line git diff --exit-code naming ops/bin/dump among untouched binaries; bash tools/lint/dp.sh TASK.md rejected it as a dump invocation without a scoped selection. The packet-open commit was reset before any worker edit, the receipt line reworded, and the packet redrafted; the lesson is that the packet lint treats any ops/bin/dump token in the receipt list as an invocation.
- Protocol deviations: 0. Pushes before certify: 0.

### Decision Leaf
Decision Required: No
Decision Leaf: None