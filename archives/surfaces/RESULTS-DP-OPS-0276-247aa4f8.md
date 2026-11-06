# DP-OPS-0276 RESULTS

## Certification Metadata
- DP ID: DP-OPS-0276
- Certified At (UTC): 2026-11-06T20:55:37Z
- Branch: agent/dp-ops-0276-2026-11-06
- Git Hash: 247aa4f8fce858d7d90962f734bf684eb3f1e577

## Scope Verification
- Target Files allowlist pointer: storage/dp/active/allowlist.txt
- dp_source: archives/surfaces/TASK-DP-OPS-0276-247aa4f8.md
- dump_manifest: none

### Integrity Lint Output
~~~text
Integrity scope mode: packet-exact
Packet scope paths: 31
Addendum scope paths: 0
Current-run compile leaves: 0
OK: integrity lint passed (27 observed paths).

Artifact Path Consistency: PASS
- Intake DP path: storage/dp/intake/DP.md
- Closing sidecar path: storage/handoff/CLOSING.md
- Active RESULTS path: storage/handoff/RESULTS.md
- Authoritative packet lineage class: archives/surfaces/TASK-DP-OPS-0276-<git-short-hash>.md
- Root-level lookalike variants absent: yes

Generated surface ownership policy:
- PoW.md
- SoP.md
- TASK.md
- archives/surfaces/PoW-2026-11-06-247aa4f8.md
- archives/surfaces/SoP-2026-11-06-247aa4f8.md
- archives/surfaces/TASK-DP-OPS-0276-247aa4f8.md
- archives/surfaces/RESULTS-DP-OPS-0276-247aa4f8.md

Post-command integrity recheck:
Integrity scope mode: maintenance-idle
Packet scope paths: 0
Addendum scope paths: 0
Current-run compile leaves: 0
OK: integrity lint passed (36 observed paths).

Active TASK packet-consistency recheck:
TASK packet-consistency check: PASS
- task_pointer: archives/surfaces/TASK-DP-OPS-0276-247aa4f8.md
- frontmatter_packet_id: DP-OPS-0276
- body_packet_id: DP-OPS-0276
- work_branch: agent/dp-ops-0276-2026-11-06

Dump-visible prune pressure report:
REPORT: target=dump class=archive-pow tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/PoW-*.md count=222 protected=0 bytes_total=1986209 weighted_bytes=17875881 top_path=archives/surfaces/PoW-2026-02-23-eaf0cd925.md top_bytes=96506
REPORT: target=dump class=archive-sop tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/SoP-*.md count=243 protected=0 bytes_total=1286792 weighted_bytes=11581128 top_path=archives/surfaces/SoP-2026-02-24-ccd451873.md top_bytes=69444
REPORT: target=dump class=archive-task tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/TASK-*.md count=216 protected=0 bytes_total=3649110 weighted_bytes=32841990 top_path=archives/surfaces/TASK-DP-OPS-0081-7ae7475b.md top_bytes=37057
REPORT: target=dump class=archive-compile tier=historical tier_weight=3 class_weight=2 retention=canonical pattern=archives/manifests/compile-*.md count=506 protected=0 bytes_total=2504508 weighted_bytes=15027048 top_path=archives/manifests/compile-2026-11-06T204656-247aa4f8.md top_bytes=5894
REPORT: target=dump class=archive-decision tier=historical tier_weight=3 class_weight=1 retention=canonical pattern=archives/decisions/*.md count=64 protected=0 bytes_total=150372 weighted_bytes=451116 top_path=archives/decisions/RoR-2026-11-06-004-op-0269.md top_bytes=3651
REPORT: target=dump class=archive-definition tier=historical tier_weight=3 class_weight=1 retention=canonical pattern=archives/definitions/*.md count=15 protected=0 bytes_total=36747 weighted_bytes=110241 top_path=archives/definitions/agent-candidate-2026-02-19-a74a0001.md top_bytes=3181
REPORT: target=dump class=docs-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=docs/* count=114 protected=0 bytes_total=496333 weighted_bytes=496333 top_path=docs/MANUAL.md top_bytes=58235
REPORT: target=dump class=ops-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=ops/* count=84 protected=0 bytes_total=668427 weighted_bytes=668427 top_path=ops/bin/certify top_bytes=89256
REPORT: target=dump class=tools-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=tools/* count=30 protected=0 bytes_total=453759 weighted_bytes=453759 top_path=tools/lint/dp.sh top_bytes=70012
REPORT: target=dump class=opt-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=opt/* count=166 protected=0 bytes_total=40911425 weighted_bytes=40911425 top_path=opt/_research/agent-system-upgrade-plan.pdf top_bytes=409597
REPORT: target=dump class=planning-topic-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/TOPIC.md count=0 protected=0 bytes_total=0 weighted_bytes=0 top_path=(none) top_bytes=0
REPORT: target=dump class=draft-plan-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/PLAN.md count=0 protected=0 bytes_total=0 weighted_bytes=0 top_path=(none) top_bytes=0
REPORT: target=dump class=audit-results-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/RESULTS.md count=1 protected=1 bytes_total=39866 weighted_bytes=39866 top_path=storage/handoff/RESULTS.md top_bytes=39866
REPORT: target=dump class=audit-closing-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/CLOSING.md count=1 protected=1 bytes_total=3630 weighted_bytes=3630 top_path=storage/handoff/CLOSING.md top_bytes=3630
SUMMARY: target=dump action=report class_count=14 count_total=1662 protected_total=2 bytes_total=52187178 weighted_bytes_total=120460844
REPORT: target=repo-context class=archives-tree tier=historical tier_weight=3 class_weight=2 retention=canonical pattern=archives/* count=1283 protected=0 bytes_total=10147934 weighted_bytes=60887604 top_path=archives/surfaces/PoW-2026-02-23-eaf0cd925.md top_bytes=96506
REPORT: target=repo-context class=logs-tree tier=historical tier_weight=3 class_weight=1 retention=disposable pattern=logs/* count=8107 protected=0 bytes_total=1237694 weighted_bytes=3713082 top_path=logs/trace-stela-20260218T043441Z-11d57a2b-retroleaf.md top_bytes=1516
REPORT: target=repo-context class=storage-dumps tier=historical tier_weight=3 class_weight=2 retention=disposable pattern=redacted-dump-artifact-glob count=27 protected=0 bytes_total=44790869 weighted_bytes=268745214 top_path=redacted-dump-artifact-path top_bytes=3789025
REPORT: target=repo-context class=storage-handoff tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=redacted-open-artifact-glob count=63 protected=2 bytes_total=32468556 weighted_bytes=32468556 top_path=storage/handoff/AUDIT-agent-dp-ops-0275-2026-11-06-8a8adc02.tar top_bytes=3880960
SUMMARY: target=repo-context action=report class_count=4 count_total=9480 protected_total=2 bytes_total=88645053 weighted_bytes_total=365814456
SUMMARY: target=dump action=would_remove removed_count=0 removed_bytes=0
Prune phase complete: phase=report target=dump dry_run=1

Results lint verification:
OK: RESULTS lint passed (1 file(s) checked).
PASS: results template structure headings are present
PASS: recorded Git Hash equals HEAD (247aa4f8fce858d7d90962f734bf684eb3f1e577)
PASS: unresolved slot token scan clear
~~~

## Verification Command Log
### Command 01
- Command: `./ops/bin/certify --dp=DP-OPS-0276 --out=auto`
- Started (UTC): 2026-11-06T20:46:26Z
- Finished (UTC): 2026-11-06T20:46:26Z
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
- Started (UTC): 2026-11-06T20:46:26Z
- Finished (UTC): 2026-11-06T20:46:49Z
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
- Started (UTC): 2026-11-06T20:46:49Z
- Finished (UTC): 2026-11-06T20:46:51Z
- Duration Seconds: 2
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
- Started (UTC): 2026-11-06T20:46:51Z
- Finished (UTC): 2026-11-06T20:46:51Z
- Duration Seconds: 0
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
- Started (UTC): 2026-11-06T20:46:51Z
- Finished (UTC): 2026-11-06T20:46:52Z
- Duration Seconds: 1
- Exit Code: 0

#### STDOUT
~~~text
Phase 2 surface leaves emitted:
- PoW.md -> archives/surfaces/PoW-2026-11-06-247aa4f8.md
- SoP.md -> archives/surfaces/SoP-2026-11-06-247aa4f8.md
- TASK.md -> archives/surfaces/TASK-DP-OPS-0276-247aa4f8.md
- durable RESULTS destination -> archives/surfaces/RESULTS-DP-OPS-0276-247aa4f8.md
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 06
- Command: `bash tools/lint/integrity.sh`
- Started (UTC): 2026-11-06T20:46:52Z
- Finished (UTC): 2026-11-06T20:46:55Z
- Duration Seconds: 3
- Exit Code: 0

#### STDOUT
~~~text
Integrity scope mode: maintenance-idle
Packet scope paths: 0
Addendum scope paths: 0
Current-run compile leaves: 0
OK: integrity lint passed (31 observed paths).
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 07
- Command: `bash tools/lint/style.sh`
- Started (UTC): 2026-11-06T20:46:55Z
- Finished (UTC): 2026-11-06T20:46:56Z
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
- Started (UTC): 2026-11-06T20:46:56Z
- Finished (UTC): 2026-11-06T20:46:56Z
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
- Started (UTC): 2026-11-06T20:46:56Z
- Finished (UTC): 2026-11-06T20:46:57Z
- Duration Seconds: 1
- Exit Code: 0

#### STDOUT
~~~text
PoW.md
RoR.md
SoP.md
TASK.md
docs/MANUAL.md
docs/ops/registry/binaries.md
docs/ops/registry/decisions.md
docs/ops/registry/templates.md
docs/ops/specs/binaries/bundle.md
docs/ops/specs/binaries/manifest.md
docs/ops/specs/runbook/gemini.md
docs/ops/specs/scripts/bundle.md
docs/ops/specs/surfaces/consult.md
docs/ops/specs/tools/test/bundle.md
llms-core.txt
llms-full.txt
llms.txt
ops/bin/manifest
ops/bin/template
ops/etc/persistence.manifest
ops/etc/verification.manifest
ops/lib/manifests/BUNDLE.md
ops/lib/manifests/OPS.md
ops/lib/scripts/bundle.sh
ops/src/runbook/gemini.yaml
storage/dp/active/allowlist.txt
tools/test/bundle.sh
tools/test/inventory.sh
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 10
- Command: `git diff --stat`
- Started (UTC): 2026-11-06T20:46:57Z
- Finished (UTC): 2026-11-06T20:46:57Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
 PoW.md                              |   2 +-
 RoR.md                              |   2 +-
 SoP.md                              |   2 +-
 TASK.md                             | 298 +----------------------------------
 docs/MANUAL.md                      |   3 +-
 docs/ops/registry/binaries.md       |   2 +-
 docs/ops/registry/decisions.md      |   1 +
 docs/ops/registry/templates.md      |   1 +
 docs/ops/specs/binaries/bundle.md   |  19 ++-
 docs/ops/specs/binaries/manifest.md |   2 +-
 docs/ops/specs/runbook/gemini.md    |   2 +-
 docs/ops/specs/scripts/bundle.md    |   2 +-
 docs/ops/specs/surfaces/consult.md  |   4 +-
 docs/ops/specs/tools/test/bundle.md |  10 +-
 llms-core.txt                       | 302 +-----------------------------------
 llms-full.txt                       | 302 +-----------------------------------
 llms.txt                            |   4 +-
 ops/bin/manifest                    |   5 +-
 ops/bin/template                    |   2 +-
 ops/etc/persistence.manifest        |   1 +
 ops/etc/verification.manifest       |   1 +
 ops/lib/manifests/BUNDLE.md         |  24 ++-
 ops/lib/manifests/OPS.md            |   1 +
 ops/lib/scripts/bundle.sh           | 121 ++++++++++++++-
 ops/src/runbook/gemini.yaml         |   1 +
 storage/dp/active/allowlist.txt     |   4 +
 tools/test/bundle.sh                |  99 +++++++++++-
 tools/test/inventory.sh             |   4 +-
 28 files changed, 294 insertions(+), 927 deletions(-)
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 11
- Command: `comm -23 <(git diff --name-only | sort) <(sort storage/dp/active/allowlist.txt) || true`
- Started (UTC): 2026-11-06T20:46:57Z
- Finished (UTC): 2026-11-06T20:46:57Z
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
- Started (UTC): 2026-11-06T20:46:57Z
- Finished (UTC): 2026-11-06T20:46:57Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
archives/manifests/compile-2026-11-06T204656-247aa4f8.md
archives/surfaces/PoW-2026-11-06-247aa4f8.md
archives/surfaces/SoP-2026-11-06-247aa4f8.md
archives/surfaces/TASK-DP-OPS-0276-247aa4f8.md
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 13
- Command: `./ops/bin/open`
- Started (UTC): 2026-11-06T20:46:57Z
- Finished (UTC): 2026-11-06T20:46:57Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
===== STELA OPEN PROMPT =====

Adhere to the Behavioral Standard defined in PoT.md.
Mode: collaborator stance. Follow repo canon and request missing context.

[FRESHNESS GATE]
- Active branch: agent/dp-ops-0276-2026-11-06
- HEAD short hash: 247aa4f8
- DP id/date (if applicable): (none)
- Intent for today: 
- STELA_TRACE_ID: stela-20261106T204657Z-2ae7582e

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
- Current objective: Execute the Operator's delegated decisions of 2026-11-06 as certified packets, one lane at a time; with DP-OPS-0276 every lane of the delegated table is closed.
- Accepted baseline: Main certifies packets under packet-exact scope with one shared dual-scope check and a certify dry run; a bounded question to an external runtime adapter ships as a consult bundle (storage/handoff/QUESTION.md, the core dump, a consult stance, an attachment budget equal to the package member count) and lands as a consult artifact under one schema at storage/handoff/CONSULT-<adapter>.md, validated by the response lint before any decision reads it, with its disposition recorded in a RESULTS narrative or an op leaf and never in SoP; the project lane scaffolds a registered project with a resolved contract copy in one call, proved by a verify lane whose project lint runs without ripgrep; the contract is advisory and two session classes are named in the manual; every README is authored to one discovery template; every template carries complete metadata; the research corpus lives under opt/_research as PDF records whose digest list is a verify lane.
- Exact next action: Merge the DP-OPS-0276 pull request as its gates pass; then the delegated table of 2026-11-06 is closed and the next packet starts from a new Operator topic, not from the table.
- TASK routing state: IDLE
- TASK packet state: COMPLETED
- TASK packet id: DP-OPS-0276

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
- Porcelain entries: 36
- Porcelain artifact: emitted
- Porcelain saved: redacted-porcelain-artifact-path
- Last commit: 247aa4f8 DP-OPS-0276: open packet (consult bundle profile)

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
- Command: `bash tools/test/bundle.sh --slice=consult-contract`
- Started (UTC): 2026-11-06T20:46:57Z
- Finished (UTC): 2026-11-06T20:47:31Z
- Duration Seconds: 34
- Exit Code: 0

#### STDOUT
~~~text
--- slice: consult-contract
--- slice: consult-contract done
PASS: bundle smoke test (slice: consult-contract)
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 15
- Command: `bash tools/test/bundle.sh`
- Started (UTC): 2026-11-06T20:47:31Z
- Finished (UTC): 2026-11-06T20:51:09Z
- Duration Seconds: 218
- Exit Code: 0

#### STDOUT
~~~text
--- slice: route-contract
--- slice: route-contract done
--- slice: package-contract
--- slice: package-contract done
--- slice: fail-closed
--- slice: fail-closed done
--- slice: rerun-lineage
--- slice: rerun-lineage done
--- slice: consult-contract
--- slice: consult-contract done
PASS: bundle smoke test
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 16
- Command: `bash tools/test/inventory.sh`
- Started (UTC): 2026-11-06T20:51:09Z
- Finished (UTC): 2026-11-06T20:51:11Z
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
- Command: `bash tools/lint/leaf.sh`
- Started (UTC): 2026-11-06T20:51:11Z
- Finished (UTC): 2026-11-06T20:51:11Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
leaf lint: PASS
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 18
- Command: `./ops/bin/manifest render stance-consult --out=-`
- Started (UTC): 2026-11-06T20:51:11Z
- Finished (UTC): 2026-11-06T20:51:11Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
Rules:
* Follow constraints in `ops/lib/manifests/CONSTRAINTS.md` (Sections 1 & 2).
* Execution constraints: ops/lib/manifests/EXECUTION.md
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached bundle manifest `resolved_profile=consult`; if not, **STOP** and request a correct consult bundle.
* This stance is advisory. Your answer is subordinate to RESULTS, CLOSING, audit verdicts, and Operator approval; it carries no repository authority and proposes no repo edits, authoritative plans, or local-state claims beyond the attached material.
* Require `CONSULT:` intent in bundle OPEN metadata carrying the adapter identifier and a one-line question; the full question is `storage/handoff/QUESTION.md` in the package.
* Answer only the bounded question. Treat the attached bundle as the only local truth; do not claim to have inspected files, branches, diffs, logs, or runtime behavior beyond it.

Steps:
0. **PRECONDITIONS**: Confirm the bundle `[CONSULT]` block names the adapter, the question source, the attachment budget, and the output surface. If missing: **STOP** and request a correctly assembled consult bundle.
1. **READ**: Read `storage/handoff/QUESTION.md` in full; state the question as asked in C.1.
2. **ATTACHMENTS**: In C.2, write `Budget: <attachment budget from the bundle>` and list the package members you used, one `- <path>` line each, never more lines than the budget.
3. **CONTEXT MODE**: In C.3, write `in_thread` when this answer continues a running thread with delta context, or `fresh_thread` when the bundle rehydrated a new thread.
4. **ANSWER**: In C.4, state findings with their evidence basis, assumptions, unknowns, and confidence; in C.5, state the recommendation.
5. **AUTHORITY**: In C.6, write exactly `Advisory. Subordinate to RESULTS, CLOSING, audit verdicts, and Operator approval.`
6. **DISPOSITION**: In C.7, write `Disposition: pending` and `Recorded in: none`; the Operator overwrites both lines at disposal.

Output Structure:
- `### CONSULT <adapter> <YYYY-MM-DD>`
- `## C.1 Question` through `## C.7 Disposition`

Output only: Complete consult answer (C.1-C.7) in a markdown code block.
* Emit exactly one fenced markdown code block.
* Emit no text before or after the fenced code block.
First non-empty line inside the code block must start with `### CONSULT`.
For machine-ingest consult mode: include every heading `## C.1 Question`, `## C.2 Attachments`, `## C.3 Context Mode`, `## C.4 Findings`, `## C.5 Recommendation`, `## C.6 Authority`, `## C.7 Disposition`, once each, in that order, none empty.
* Do not emit audit verdict markers or Worker Execution Narrative sections.
For machine-ingest consult mode: do not emit `Decision Required:` or `Decision Leaf:` lines; the Operator validates the landed answer with `bash tools/lint/response.sh --mode=consult`.
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 19
- Command: `grep -c "consult" ops/lib/manifests/BUNDLE.md`
- Started (UTC): 2026-11-06T20:51:11Z
- Finished (UTC): 2026-11-06T20:51:11Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
17
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 20
- Command: `grep -c "bundle-consult-contract" ops/etc/verification.manifest`
- Started (UTC): 2026-11-06T20:51:11Z
- Finished (UTC): 2026-11-06T20:51:11Z
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
- Command: `grep -c "profile=consult" ops/etc/persistence.manifest`
- Started (UTC): 2026-11-06T20:51:11Z
- Finished (UTC): 2026-11-06T20:51:11Z
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
- Command: `bash tools/lint/response.sh --test`
- Started (UTC): 2026-11-06T20:51:11Z
- Finished (UTC): 2026-11-06T20:51:14Z
- Duration Seconds: 3
- Exit Code: 0

#### STDOUT
~~~text
OK: --test passed
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 23
- Command: `bash tools/lint/truth.sh`
- Started (UTC): 2026-11-06T20:51:14Z
- Finished (UTC): 2026-11-06T20:51:14Z
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

### Command 24
- Command: `bash tools/lint/schema.sh`
- Started (UTC): 2026-11-06T20:51:14Z
- Finished (UTC): 2026-11-06T20:51:37Z
- Duration Seconds: 23
- Exit Code: 0

#### STDOUT
~~~text
OK: schema lint passed (1202 file(s) checked: definitions=15, surfaces=681, manifests=506).
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 25
- Command: `bash tools/verify.sh --mode=certify-critical --paths-file=var/tmp/certify.DP-OPS-0276.QqEzQt/verify-paths.txt`
- Started (UTC): 2026-11-06T20:51:37Z
- Finished (UTC): 2026-11-06T20:55:30Z
- Duration Seconds: 233
- Exit Code: 0

#### STDOUT
~~~text
Stela Repo Hygiene Verification
Root: /home/claude/stela-lab
Verification Mode: certify-critical
Verification Paths File: var/tmp/certify.DP-OPS-0276.QqEzQt/verify-paths.txt

VERIFY-SELECTION: name=open-dedup scope=closeout-critical reason_class=closeout-critical owner=TEST-03 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md detail=bash tools/test/open.sh
VERIFY-SELECTION: name=packet-scope-contract scope=closeout-critical reason_class=closeout-critical owner=TEST-06 infra_importance=critical decision_leaf=none detail=bash tools/test/integrity.sh
VERIFY-SELECTION: name=bundle-certify-critical scope=closeout-critical reason_class=closeout-critical owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md detail=bash tools/test/bundle.sh --mode=certify-critical
VERIFY-LANE-ORDER: mode=certify-critical order=open-dedup,packet-scope-contract,bundle-certify-critical
VERIFY-DEFERRED: name=editor-scaffold scope=standalone-full-only reason_class=standalone-full-only owner=TEST-04 infra_importance=supporting decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md reason=standalone-full-only detail=bash tools/test/editor.sh
VERIFY-DEFERRED: name=guard-debt-lint scope=standalone-full-only reason_class=standalone-full-only owner=LINT-18 infra_importance=supporting decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md reason=standalone-full-only detail=bash tools/lint/debt.sh
VERIFY-DEFERRED: name=runtime-inventory-contract scope=standalone-full-only reason_class=standalone-full-only owner=TEST-07 infra_importance=supporting decision_leaf=none reason=standalone-full-only detail=bash tools/test/inventory.sh
VERIFY-DEFERRED: name=factory-smoke scope=packet-local reason_class=packet-local owner=TEST-05 infra_importance=important decision_leaf=archives/decisions/RoR-2026-03-16-003-cbc-0202.md reason=no-path-match detail=bash tools/test/factory.sh
VERIFY-DEFERRED: name=response-self-test scope=packet-local reason_class=packet-local owner=LINT-17 infra_importance=important decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md reason=no-path-match detail=bash tools/lint/response.sh --test
VERIFY-DEFERRED: name=dp-lint-self-test scope=standalone-full-only reason_class=standalone-full-only owner=LINT-03 infra_importance=important decision_leaf=archives/decisions/RoR-2026-11-06-005-cbc-0270.md reason=standalone-full-only detail=bash tools/lint/dp.sh --test
VERIFY-DEFERRED: name=records-digest scope=packet-local reason_class=packet-local owner=LINT-19 infra_importance=supporting decision_leaf=archives/decisions/RoR-2026-11-06-005-cbc-0270.md reason=no-path-match detail=bash tools/lint/records.sh
VERIFY-DEFERRED: name=project-lane-contract scope=packet-local reason_class=packet-local owner=TEST-08 infra_importance=supporting decision_leaf=archives/decisions/RoR-2026-11-06-011-cbc-0273.md reason=not-in-mode detail=bash tools/test/scaffold.sh
VERIFY-DEFERRED: name=bundle-route-contract scope=packet-local reason_class=packet-local owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md reason=not-in-mode detail=bash tools/test/bundle.sh --slice=route-contract
VERIFY-DEFERRED: name=bundle-package-contract scope=packet-local reason_class=packet-local owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md reason=not-in-mode detail=bash tools/test/bundle.sh --slice=package-contract
VERIFY-DEFERRED: name=bundle-fail-closed scope=packet-local reason_class=packet-local owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md reason=not-in-mode detail=bash tools/test/bundle.sh --slice=fail-closed
VERIFY-DEFERRED: name=bundle-rerun-lineage scope=packet-local reason_class=packet-local owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md reason=not-in-mode detail=bash tools/test/bundle.sh --slice=rerun-lineage
VERIFY-DEFERRED: name=bundle-consult-contract scope=packet-local reason_class=packet-local owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-11-06-016-cbc-0276.md reason=not-in-mode detail=bash tools/test/bundle.sh --slice=consult-contract
PASS: open de-dup test
VERIFY-LANE: name=open-dedup scope=closeout-critical reason_class=closeout-critical owner=TEST-03 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md status=pass duration_seconds=0 detail=bash tools/test/open.sh
Integrity scope fixture summary: pass=13 fail=0
VERIFY-LANE: name=packet-scope-contract scope=closeout-critical reason_class=closeout-critical owner=TEST-06 infra_importance=critical decision_leaf=none status=pass duration_seconds=15 detail=bash tools/test/integrity.sh
--- slice: route-contract
--- slice: route-contract done
--- slice: package-contract
--- slice: package-contract done
--- slice: fail-closed
--- slice: fail-closed done
--- slice: rerun-lineage
--- slice: rerun-lineage done
--- slice: consult-contract
--- slice: consult-contract done
PASS: bundle smoke test (mode: certify-critical)
VERIFY-LANE: name=bundle-certify-critical scope=closeout-critical reason_class=closeout-critical owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md status=pass duration_seconds=217 detail=bash tools/test/bundle.sh --mode=certify-critical


Verify lane summary:
VERIFY-LANE-SUMMARY: name=open-dedup scope=closeout-critical reason_class=closeout-critical owner=TEST-03 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md status=pass duration_seconds=0 detail=bash tools/test/open.sh
VERIFY-LANE-SUMMARY: name=packet-scope-contract scope=closeout-critical reason_class=closeout-critical owner=TEST-06 infra_importance=critical decision_leaf=none status=pass duration_seconds=15 detail=bash tools/test/integrity.sh
VERIFY-LANE-SUMMARY: name=bundle-certify-critical scope=closeout-critical reason_class=closeout-critical owner=TEST-02 infra_importance=critical decision_leaf=archives/decisions/RoR-2026-03-16-004-cbc-0204.md status=pass duration_seconds=217 detail=bash tools/test/bundle.sh --mode=certify-critical

OK: Clean Platform State.
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 26
- Command: `git diff --exit-code -- tools/lint/response.sh ops/src/runbook/gpt.yaml ops/src/runbook/claude.yaml ops/src/runbook/execution-decision.yaml ops/src/shared/stances.json ops/lib/manifests/ASSEMBLY.md PoT.md`
- Started (UTC): 2026-11-06T20:55:30Z
- Finished (UTC): 2026-11-06T20:55:30Z
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

### Command 27
- Command: `git diff --check`
- Started (UTC): 2026-11-06T20:55:30Z
- Finished (UTC): 2026-11-06T20:55:30Z
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

### Command 28
- Command: `bash tools/lint/integrity.sh`
- Started (UTC): 2026-11-06T20:55:30Z
- Finished (UTC): 2026-11-06T20:55:33Z
- Duration Seconds: 3
- Exit Code: 0

#### STDOUT
~~~text
Integrity scope mode: maintenance-idle
Packet scope paths: 0
Addendum scope paths: 0
Current-run compile leaves: 0
OK: integrity lint passed (36 observed paths).
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 29
- Command: `internal: verify active TASK leaf packet consistency`
- Started (UTC): 2026-11-06T20:55:33Z
- Finished (UTC): 2026-11-06T20:55:33Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
TASK packet-consistency check: PASS
- task_pointer: archives/surfaces/TASK-DP-OPS-0276-247aa4f8.md
- frontmatter_packet_id: DP-OPS-0276
- body_packet_id: DP-OPS-0276
- work_branch: agent/dp-ops-0276-2026-11-06
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 30
- Command: `internal: verify changed files subset of allowlist pointer (storage/dp/active/allowlist.txt)`
- Started (UTC): 2026-11-06T20:55:33Z
- Finished (UTC): 2026-11-06T20:55:34Z
- Duration Seconds: 1
- Exit Code: 0

#### STDOUT
~~~text
Changed-file dual-scope check: PASS
Packet exact paths: 31
Current-run compile leaves: 1
Changed files:
- PoW.md
- RoR.md
- SoP.md
- TASK.md
- archives/decisions/RoR-2026-11-06-016-cbc-0276.md
- archives/decisions/RoR-2026-11-06-017-op-0276.md
- archives/manifests/compile-2026-11-06T204656-247aa4f8.md
- archives/surfaces/PoW-2026-11-06-247aa4f8.md
- archives/surfaces/SoP-2026-11-06-247aa4f8.md
- archives/surfaces/TASK-DP-OPS-0276-247aa4f8.md
- docs/MANUAL.md
- docs/ops/registry/binaries.md
- docs/ops/registry/decisions.md
- docs/ops/registry/templates.md
- docs/ops/specs/binaries/bundle.md
- docs/ops/specs/binaries/manifest.md
- docs/ops/specs/runbook/gemini.md
- docs/ops/specs/scripts/bundle.md
- docs/ops/specs/stances/consult.md
- docs/ops/specs/surfaces/consult.md
- docs/ops/specs/tools/test/bundle.md
- llms-core.txt
- llms-full.txt
- llms.txt
- ops/bin/manifest
- ops/bin/template
- ops/etc/persistence.manifest
- ops/etc/verification.manifest
- ops/lib/manifests/BUNDLE.md
- ops/lib/manifests/OPS.md
- ops/lib/scripts/bundle.sh
- ops/src/runbook/gemini.yaml
- ops/src/stances/consult.md.tpl
- storage/dp/active/allowlist.txt
- tools/test/bundle.sh
- tools/test/inventory.sh
~~~

#### STDERR
~~~text
(empty)
~~~

### Command 31
- Command: `./ops/bin/prune --target=dump --phase=report --dry-run`
- Started (UTC): 2026-11-06T20:55:34Z
- Finished (UTC): 2026-11-06T20:55:37Z
- Duration Seconds: 3
- Exit Code: 0

#### STDOUT
~~~text
REPORT: target=dump class=archive-pow tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/PoW-*.md count=222 protected=0 bytes_total=1986209 weighted_bytes=17875881 top_path=archives/surfaces/PoW-2026-02-23-eaf0cd925.md top_bytes=96506
REPORT: target=dump class=archive-sop tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/SoP-*.md count=243 protected=0 bytes_total=1286792 weighted_bytes=11581128 top_path=archives/surfaces/SoP-2026-02-24-ccd451873.md top_bytes=69444
REPORT: target=dump class=archive-task tier=historical tier_weight=3 class_weight=3 retention=canonical pattern=archives/surfaces/TASK-*.md count=216 protected=0 bytes_total=3649110 weighted_bytes=32841990 top_path=archives/surfaces/TASK-DP-OPS-0081-7ae7475b.md top_bytes=37057
REPORT: target=dump class=archive-compile tier=historical tier_weight=3 class_weight=2 retention=canonical pattern=archives/manifests/compile-*.md count=506 protected=0 bytes_total=2504508 weighted_bytes=15027048 top_path=archives/manifests/compile-2026-11-06T204656-247aa4f8.md top_bytes=5894
REPORT: target=dump class=archive-decision tier=historical tier_weight=3 class_weight=1 retention=canonical pattern=archives/decisions/*.md count=64 protected=0 bytes_total=150372 weighted_bytes=451116 top_path=archives/decisions/RoR-2026-11-06-004-op-0269.md top_bytes=3651
REPORT: target=dump class=archive-definition tier=historical tier_weight=3 class_weight=1 retention=canonical pattern=archives/definitions/*.md count=15 protected=0 bytes_total=36747 weighted_bytes=110241 top_path=archives/definitions/agent-candidate-2026-02-19-a74a0001.md top_bytes=3181
REPORT: target=dump class=docs-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=docs/* count=114 protected=0 bytes_total=496333 weighted_bytes=496333 top_path=docs/MANUAL.md top_bytes=58235
REPORT: target=dump class=ops-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=ops/* count=84 protected=0 bytes_total=668427 weighted_bytes=668427 top_path=ops/bin/certify top_bytes=89256
REPORT: target=dump class=tools-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=tools/* count=30 protected=0 bytes_total=453759 weighted_bytes=453759 top_path=tools/lint/dp.sh top_bytes=70012
REPORT: target=dump class=opt-tree tier=operational tier_weight=1 class_weight=1 retention=canonical pattern=opt/* count=166 protected=0 bytes_total=40911425 weighted_bytes=40911425 top_path=opt/_research/agent-system-upgrade-plan.pdf top_bytes=409597
REPORT: target=dump class=planning-topic-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/TOPIC.md count=0 protected=0 bytes_total=0 weighted_bytes=0 top_path=(none) top_bytes=0
REPORT: target=dump class=draft-plan-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/PLAN.md count=0 protected=0 bytes_total=0 weighted_bytes=0 top_path=(none) top_bytes=0
REPORT: target=dump class=audit-results-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/RESULTS.md count=1 protected=1 bytes_total=39866 weighted_bytes=39866 top_path=storage/handoff/RESULTS.md top_bytes=39866
REPORT: target=dump class=audit-closing-input tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=storage/handoff/CLOSING.md count=1 protected=1 bytes_total=3630 weighted_bytes=3630 top_path=storage/handoff/CLOSING.md top_bytes=3630
SUMMARY: target=dump action=report class_count=14 count_total=1662 protected_total=2 bytes_total=52187178 weighted_bytes_total=120460844
REPORT: target=repo-context class=archives-tree tier=historical tier_weight=3 class_weight=2 retention=canonical pattern=archives/* count=1283 protected=0 bytes_total=10147934 weighted_bytes=60887604 top_path=archives/surfaces/PoW-2026-02-23-eaf0cd925.md top_bytes=96506
REPORT: target=repo-context class=logs-tree tier=historical tier_weight=3 class_weight=1 retention=disposable pattern=logs/* count=8107 protected=0 bytes_total=1237694 weighted_bytes=3713082 top_path=logs/trace-stela-20260218T043441Z-11d57a2b-retroleaf.md top_bytes=1516
REPORT: target=repo-context class=storage-dumps tier=historical tier_weight=3 class_weight=2 retention=disposable pattern=redacted-dump-artifact-glob count=27 protected=0 bytes_total=44790869 weighted_bytes=268745214 top_path=redacted-dump-artifact-path top_bytes=3789025
REPORT: target=repo-context class=storage-handoff tier=operational tier_weight=1 class_weight=1 retention=disposable pattern=redacted-open-artifact-glob count=63 protected=2 bytes_total=32468556 weighted_bytes=32468556 top_path=storage/handoff/AUDIT-agent-dp-ops-0275-2026-11-06-8a8adc02.tar top_bytes=3880960
SUMMARY: target=repo-context action=report class_count=4 count_total=9480 protected_total=2 bytes_total=88645053 weighted_bytes_total=365814456
SUMMARY: target=dump action=would_remove removed_count=0 removed_bytes=0
Prune phase complete: phase=report target=dump dry_run=1
~~~

#### STDERR
~~~text
(empty)
~~~
### Command 32
- Command: `bash tools/lint/results.sh storage/handoff/RESULTS.md`
- Started (UTC): 2026-11-06T20:55:37Z
- Finished (UTC): 2026-11-06T20:55:37Z
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
RoR.md
SoP.md
TASK.md
archives/decisions/RoR-2026-11-06-016-cbc-0276.md
archives/decisions/RoR-2026-11-06-017-op-0276.md
docs/MANUAL.md
docs/ops/registry/binaries.md
docs/ops/registry/decisions.md
docs/ops/registry/templates.md
docs/ops/specs/binaries/bundle.md
docs/ops/specs/binaries/manifest.md
docs/ops/specs/runbook/gemini.md
docs/ops/specs/scripts/bundle.md
docs/ops/specs/stances/consult.md
docs/ops/specs/surfaces/consult.md
docs/ops/specs/tools/test/bundle.md
llms-core.txt
llms-full.txt
llms.txt
ops/bin/manifest
ops/bin/template
ops/etc/persistence.manifest
ops/etc/verification.manifest
ops/lib/manifests/BUNDLE.md
ops/lib/manifests/OPS.md
ops/lib/scripts/bundle.sh
ops/src/runbook/gemini.yaml
ops/src/stances/consult.md.tpl
storage/dp/active/allowlist.txt
tools/test/bundle.sh
tools/test/inventory.sh
~~~

### git diff --stat
~~~text
 PoW.md                                            |   2 +-
 RoR.md                                            |   2 +-
 SoP.md                                            |   2 +-
 TASK.md                                           | 298 +--------------------
 archives/decisions/RoR-2026-11-06-016-cbc-0276.md |  52 ++++
 archives/decisions/RoR-2026-11-06-017-op-0276.md  |  35 +++
 docs/MANUAL.md                                    |   3 +-
 docs/ops/registry/binaries.md                     |   2 +-
 docs/ops/registry/decisions.md                    |   1 +
 docs/ops/registry/templates.md                    |   1 +
 docs/ops/specs/binaries/bundle.md                 |  19 +-
 docs/ops/specs/binaries/manifest.md               |   2 +-
 docs/ops/specs/runbook/gemini.md                  |   2 +-
 docs/ops/specs/scripts/bundle.md                  |   2 +-
 docs/ops/specs/stances/consult.md                 |  50 ++++
 docs/ops/specs/surfaces/consult.md                |   4 +-
 docs/ops/specs/tools/test/bundle.md               |  10 +-
 llms-core.txt                                     | 302 +---------------------
 llms-full.txt                                     | 302 +---------------------
 llms.txt                                          |   4 +-
 ops/bin/manifest                                  |   5 +-
 ops/bin/template                                  |   2 +-
 ops/etc/persistence.manifest                      |   1 +
 ops/etc/verification.manifest                     |   1 +
 ops/lib/manifests/BUNDLE.md                       |  24 +-
 ops/lib/manifests/OPS.md                          |   1 +
 ops/lib/scripts/bundle.sh                         | 121 ++++++++-
 ops/src/runbook/gemini.yaml                       |   1 +
 ops/src/stances/consult.md.tpl                    |  34 +++
 storage/dp/active/allowlist.txt                   |   4 +
 tools/test/bundle.sh                              |  99 ++++++-
 tools/test/inventory.sh                           |   4 +-
 32 files changed, 465 insertions(+), 927 deletions(-)
~~~

## Worker Execution Narrative
### Preflight State
git rev-parse --abbrev-ref HEAD
agent/dp-ops-0276-2026-11-06
git rev-parse --short HEAD
247aa4f8
git status --porcelain
(no output; the working tree was clean)
Preflight lint status: bash tools/lint/dp.sh --test exit 0; bash tools/lint/dp.sh TASK.md PASS; bash tools/lint/task.sh PASS. The worker edits were made before the packet-open commit, stashed so that ops/bin/draft saw a clean tree, and restored after the commit; the outputs above were captured between the commit and the restore. The first draft was rejected by the DP lint because a receipt line named the dump binary as a git diff path and the lint reads that token as a dump invocation; the line was shortened and the packet redrafted before the packet-open commit.

### Implemented Changes
- ops/lib/manifests/BUNDLE.md: consult in supported_profiles; consult_profile, consult_intent_form, consult_question_surface, consult_adapter_root, consult_output_surface_pattern, stance_template_consult, artifact_prefix_consult, dump_scope_consult; the attachment, disposable-transport, and persistence-routing sections; a Consult Transport Contract section; the secondary-lanes line. ops/etc/persistence.manifest: profile consult at core depth.
- ops/lib/scripts/bundle.sh (112 added, 3 removed): the five keys loaded and validated at policy load; bundle_parse_consult_intent, bundle_consult_adapter_source_rel, bundle_validate_consult_adapter, bundle_consult_output_surface_rel; the consult case of the disposable-input collector requiring QUESTION.md; the attachment budget computed as the package member count; the CONSULT text block; the manifest consult object with requested false and null fields for other profiles; the usage line and the SPINE secondary-lanes line. Probed live: a valid run produced CONSULT-branch-head artifacts with budget 5 and five package members, and the four fail-closed inputs (no QUESTION.md, malformed intent, adapter without a source, source that is not an external runtime adapter) each stopped with their own message.
- ops/src/stances/consult.md.tpl (new, TPL-29, score 40, band 25-40): rules, six steps, and the output structure of the consult envelope with C.7 at pending; renders through ops/bin/manifest as stance-consult with 0 unresolved tokens; ops/bin/template routes the key. docs/ops/specs/stances/consult.md (new, score 40, band 30-45). docs/ops/registry/templates.md: one row; docs/ops/specs/binaries/manifest.md: the key list.
- tools/test/bundle.sh (87 added): make_question and the consult-contract slice; eleven assertions on the valid run including attachment budget equal to the manifest package member count, one planning manifest check, four fail-closed runs; the slice runs in full mode and by name. docs/ops/specs/tools/test/bundle.md: the slice. ops/etc/verification.manifest: the bundle-consult-contract lane (order 93, full and gates, packet-local). tools/test/inventory.sh: template 28 and 28, total 99 and 97; the inventory test passes 17 of 17.
- docs/ops/specs/binaries/bundle.md (score 40 before and after; band 45-60, inside tolerance as before), docs/ops/specs/scripts/bundle.md (39), docs/ops/registry/binaries.md (35): the profile. docs/MANUAL.md (score 40 before and after; band 25-40): the transport line replaces the no-profile line. docs/ops/specs/surfaces/consult.md (39): the transport line and step 1. ops/src/runbook/gemini.yaml: bundle_command in the consult block; instruction_text unchanged; the four runbook sources still parse. docs/ops/specs/runbook/gemini.md (48): step 6.
- docs/ops/registry/decisions.md: one row (score C, keep). archives/decisions/RoR-2026-11-06-016-cbc-0276.md (cbc, accepted, created through --tool and --decision) and archives/decisions/RoR-2026-11-06-017-op-0276.md (op, approved); RoR.md points at the op leaf. storage/dp/active/allowlist.txt: 4 rows; every other touched path already had a row.
- SoP.md and PoW.md authored; llms bundles and OPS.md regenerated by the receipt command.

### Closeout Notes
- Decision closed under the Operator delegation of 2026-11-06 (archives/decisions/RoR-2026-11-06-004-op-0269.md): DECISIONS.md item 15 (consult bundle profile after items 12 to 14), as recommended. With it the runbook lane and the whole delegated table are closed: items 1 to 3 in DP-OPS-0272, 4 to 6 and 10, 11, 19 as record-only dispositions in the delegation leaf, 7 to 9 in DP-OPS-0273, 12 to 14 in DP-OPS-0275, 15 here, 16 in DP-OPS-0270, 17 and 18 in DP-OPS-0271.
- The attachment budget is computed from the package member list rather than declared by the operator, so the number the adapter repeats in C.2 cannot exceed the files it received; the slice asserts the equality against the manifest.
- The bundle artifact prefix CONSULT shares a prefix with the landing file CONSULT-adapter.md; the artifact carries the branch and head with a txt suffix and the landing carries the adapter name with an md suffix, and the attachment contract in the policy manifest says so.
- ff.sh baseline: 5 pre-existing failures before and after; 124 files scored (123 before); 0 new failures, 0 warnings.
- Protocol deviations: 0. Certify runs: 1 live, 1 dry run before it. Draft runs: 2 (the first rejected by the DP lint as described above).

### Decision Leaf
Decision Required: Yes
Decision Leaf: archives/decisions/RoR-2026-11-06-017-op-0276.md