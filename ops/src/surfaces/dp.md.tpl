---
template_type: surface
template_id: dp
template_version: 2
requires_slots:
  - DP_ID
  - DP_TITLE
  - BASE_BRANCH
  - PROPOSED_WORK_BRANCH
  - BASE_HEAD
  - FRESHNESS_STAMP
  - OPEN_ANCHOR_PATH
  - OPEN_TRACE_ID
  - OPEN_WORKING_TREE
  - DP_SCOPED_LOAD_ORDER
  - OBJECTIVE
  - IN_SCOPE
  - OUT_OF_SCOPE
  - SAFETY_INVARIANTS
  - PLAN_STATE
  - PLAN_REQUEST
  - PLAN_CHANGELOG
  - PLAN_PATCH
  - RECEIPT_EXTRA
  - CBC_PREFLIGHT
includes:
  - ops/lib/manifests/CONSTRAINTS.md#section-1
  - ops/lib/manifests/EXECUTION.md#rules
ff_target: operator-technical
ff_band: "30-40"
---
### {{DP_ID}}: {{DP_TITLE}}

## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: {{BASE_BRANCH}}
Work Branch: {{PROPOSED_WORK_BRANCH}}
Base HEAD: {{BASE_HEAD}}
Freshness Stamp: {{FRESHNESS_STAMP}}
Opening OPEN Artifact: {{OPEN_ANCHOR_PATH}}
Opening OPEN Trace ID: {{OPEN_TRACE_ID}}
Opening OPEN Working Tree: {{OPEN_WORKING_TREE}}
Note: FRESHNESS_STAMP must be YYYY-MM-DD format only. No trace tokens, no timestamps, no other text. Certify rejects all other forms. dp.sh enforces at lint time.
Note: The opening OPEN above is the authoritative packet-start freshness and trace anchor. Later session refreshes do not replace packet-start truth.

Required local re-check (worker runs on the work branch before any edits; paste verbatim outputs under `## Worker Execution Narrative` -> `### Preflight State` in RESULTS):
- git rev-parse --abbrev-ref HEAD
- git rev-parse --short HEAD
- git status --porcelain

These three commands prove worker execution-start state on the work branch. They do not replace the opening OPEN anchor, and §3.4.5 receipt replay is not a substitute for these pre-edit outputs.

Preconditions:
- No commits on main.
- Opening OPEN Working Tree must be clean.
- Working tree must be clean before worker execution begins.
- If Base HEAD changes, regenerate session artifacts from canonical tools before proceeding.

STOP conditions:
- STOP if any mismatch (branch, Base HEAD, missing work branch).
- STOP if Opening OPEN Working Tree is not clean.
- STOP if working tree is dirty before worker execution begins.
- STOP if told to create or switch branches.

## 3.1.1 DP Preflight Gate (Run Before Any Edits)
Purpose:
- Catch malformed DP or TASK schema before work begins.

Worker runs (paste outcome in RESULTS):
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh

STOP if any preflight check fails.

### CbC Design Discipline Preflight (TASK.md §3.1.1)
Required when the DP objective adds, modifies, or replaces a linter, script, guard, or validation binary.
For non-tooling DPs: state "Not applicable" with a one-line justification.
{{CBC_PREFLIGHT}}

## 3.2 Required Context Load (Read Before Doing Anything)

### 3.2.1 Canon load order (always)
Worker must confirm loaded before edits begin:
1. PoT.md
2. SoP.md
3. PoW.md
4. TASK.md
5. docs/MAP.md
6. docs/MANUAL.md
7. ops/lib/manifests/CONTEXT.md

Notes:
- Worker does not read OPEN. OPEN is for Integrator state refresh and for receipts.
- Disposable artifacts must not be referenced or included.
- Worker input is the DP text only.
- DP writer must not attach or cite disposable artifacts.
- DP writer must not embed pasted bundles.

{{@include:ops/lib/manifests/EXECUTION.md#rules}}

### 3.2.2 DP-scoped load order (per DP)
{{DP_SCOPED_LOAD_ORDER}}

## 3.3 Scope and Safety
Objective:
{{OBJECTIVE}}

In scope:
{{IN_SCOPE}}

Out of scope:
{{OUT_OF_SCOPE}}

Safety and invariants:
{{SAFETY_INVARIANTS}}

Worker Constraints (SSOT injected):
{{@include:ops/lib/manifests/CONSTRAINTS.md#section-1}}

Target Files allowlist (hard gate):
- storage/dp/active/allowlist.txt

## 3.4 Execution Plan (A-E)

### 3.4.1 State
{{PLAN_STATE}}

### 3.4.2 Request
{{PLAN_REQUEST}}

### 3.4.3 Changelog
{{PLAN_CHANGELOG}}

### 3.4.4 Patch / Diff
{{PLAN_PATCH}}

### 3.4.5 Receipt (Proofs to collect) - MUST RUN

**Mandatory receipt commands (always run; do not omit):**
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/integrity.sh
- bash tools/lint/style.sh
- ./ops/bin/llms
- bash tools/lint/integrity.sh
- git diff --name-only
- git diff --stat
- comm -23 <(git diff --name-only | sort) <(sort storage/dp/active/allowlist.txt) || true
- comm -23 <(git ls-files --others --exclude-standard | sort) <(sort storage/dp/active/allowlist.txt) || true
- ./ops/bin/open

**DP-specific receipt commands (scope-specific; author below):**
Note: Command substitution forms (e.g., $(pwd), $(git ...)) are rejected by certify replay. Use literal values only. Repo-local binaries must be authored as literal `./ops/bin/...` or `ops/bin/...` commands. Unsupported receipt-command forms are rejected by dp.sh and certify.
{{RECEIPT_EXTRA}}

## 3.5 Closeout (Mandatory Routing)
- Execute docs/MANUAL.md Closeout Cycle in order (Verify, Harvest, Refresh, Log, Prune).
- Update SoP.md and PoW.md with DP entries, including objective summary and current proof / receipt summary.
- Protocol order for closeout: Verify -> Generate Results -> COMMIT (Operator Only) -> Prune.
- Run prune hygiene: ./ops/bin/prune --scrub.
- Refresh llms artifacts: `./ops/bin/llms`
- Regenerate session artifacts: `./ops/bin/open --out=auto`
- Ensure the next session begins with refreshed session artifacts and matching receipts.
- Note: audit dump generation is owned by `./ops/bin/bundle --profile=audit --out=auto` and is separate from operator session refresh. Do not stamp an additional `ops/bin/dump --scope=core` into closeout unless the DP explicitly authorizes a standalone state capture.
- Refresh side-effect: `ops/bin/llms` regenerates `ops/lib/manifests/OPS.md` as a compile event; if `OPS.md` is not in the allowlist, restore it before running `integrity.sh`. See `docs/MANUAL.md` Refresh side-effect notice for the full procedure.

### 3.5.1 Mandatory Closing Sidecar
Closing sidecar content is generated and maintained at `storage/handoff/CLOSING.md` and is validated by `ops/bin/certify` as a hard gate at certification time. Do not author, predict, populate, or approximate any sidecar-derived closeout output outside this sidecar.
Certify separately collects worker-authored narrative for the RESULTS Worker Execution Narrative section at certify time via interactive editor prompt; this narrative input is independent from closing sidecar content.

Before running certify, confirm `storage/handoff/CLOSING.md` has been maintained throughout execution and reflects observable reality only.

Closing sidecar fields required at certify time:
- Commit Message
- Create Pull Request (Title)
- Create Pull Request (Description)
- Confirm Merge (Commit Message)
- Confirm Merge (Extended Description)
- Confirm Merge (Add a Comment)
