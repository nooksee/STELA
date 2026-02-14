# System Manual (Command Console)

## 0. Mechanical Workflow
**Execution Cycle:**
1.  **Start:** `./ops/bin/open` (Generates prompt + freshness gate).
2.  **Capture:** `./ops/bin/dump` (Serializes state).
3.  **Assign:** Create DP in `TASK.md` + New Branch `work/topic-date`.
4.  **Dispatch:** Hand DP to Worker (See Section 5).
5.  **Review:** Verify `RECEIPT` (Proofs) vs `TASK.md` requirements.
6.  **Close:** Merge PR + Update `SoP.md` (if Canon changed).

**Dispatch Contract Notes:**
- The DP Preflight Gate runs after the Freshness Gate and before any edits.
- Worker input is DP text only; OPEN is for integrator refresh and receipt pointers and is not required reading for workers.

**Anchor Hygiene:**
- Refresh anchors when Base HEAD changes or when a new OPEN artifact is generated. Update TASK.md pointer references to the newest OPEN artifact and RESULTS receipts before any work continues; do not rewrite inline branch/hash state in TASK.md.
- Clean after use: complete closeout receipts and start the next session from a fresh OPEN artifact with matching dump artifacts.

## Closeout Cycle
The Closeout Cycle is the canonical closeout workflow. Execute the stages in order.
Closeout work is concurrent with execution: draft and maintain receipts and the Mandatory Closing Block during the DP, not only at the end.
Finalize closeout only after verification gates pass.
Finalization protocol order is strict: Verify -> Generate Results -> COMMIT (Operator Only) -> Prune.
The canonical Mandatory Closing Block schema is defined in `TASK.md` Section 3.5.1.

1. Verify
Run:
~~~bash
./tools/verify.sh
./tools/lint/truth.sh
./tools/lint/style.sh
./tools/lint/dp.sh TASK.md
./tools/lint/dp.sh storage/handoff/DP-OPS-XXXX-RESULTS.md
./tools/lint/llms.sh
~~~
Confirm that the RESULTS file contains executable receipt outputs (artifact paths, verification outcomes, `git diff --name-only`, `git diff --stat`, and the Mandatory Closing Block).
Verify that the Section 3.5 Closing Block is populated in RESULTS.

2. Harvest
Run only if new reusable patterns exist.
~~~bash
./ops/lib/scripts/agent.sh harvest-check
~~~
If promotion is needed, use existing ops/lib/scripts/skill.sh and ops/lib/scripts/task.sh workflows.

3. Refresh
Allowlist must include `llms.txt`, `llms-core.txt`, and `llms-full.txt` before running the command.
Out-dir must be absolute. Use `$(pwd)`.
~~~bash
./ops/bin/map
./ops/bin/llms --out-dir="$(pwd)"
~~~

4. Log
Update `SoP.md` with a DP entry that includes verification receipts.
Update `PoW.md` with a proof entry using the strict schema (Packet ID, Timestamp, Work Branch, Base HEAD, Scope, Target Files allowlist, Receipt pointers, Verification commands, Notes).
`PoW.md` receipt pointers must include `RESULTS`, `OPEN`, and `DUMP` artifact paths.
`PoW.md` Notes must record both positive proof and negative proof context (failed checks, ruled-out hypotheses, and abandoned attempts) when they materially affected execution.
Ensure the RESULTS receipt uses RUN or NOT RUN status per verification command, with reason and risk for each NOT RUN item.
If using `./ops/bin/prune --reset-task`, ensure `PoW.md` already contains `- Packet ID: DP-OPS-XXXX`; prune blocks reset-task until that proof exists.

5. Prune
Run local hygiene prune for the DP.
~~~bash
./ops/bin/prune --dp=DP-OPS-0048 --scrub
~~~

---

## 1. Top Commands

### Session Start (Open)
~~~bash
# Standard Open (Prints to stdout + saves to storage/handoff/)
./ops/bin/open --intent="Refactor docs" --dp="DP-OPS-0050"

# Auto-save convenience (Adds "OPEN saved: <path>" line)
./ops/bin/open --intent="..." --out=auto
~~~

### State Capture (Dump)
~~~bash
# Platform Scope (Default - Excludes projects/)
./ops/bin/dump --scope=platform --format=chatgpt --out=auto

# Full Scope (Includes projects/ - auto-compressed)
./ops/bin/dump --scope=full --format=chatgpt --out=auto

# Receipt Bundle (Dump + Manifest inside tarball)
./ops/bin/dump --scope=platform --out=auto --bundle
~~~

### Map (Auto-Generated Index)
~~~bash
# Refresh the auto-generated MAP block
./ops/bin/map

# Check mode (non-zero if MAP is stale)
./ops/bin/map --check
~~~

### Context Snapshot (Context Archive)
~~~bash
# Assemble OPEN + DUMP archive for SoP linkage
./ops/bin/context --dp=DP-OPS-0035
~~~

### Documentation (Help)
~~~bash
./ops/bin/help              # Show menu
./ops/bin/help continuity   # Grep docs for "continuity"
~~~

### Validation (Lint)
~~~bash
# Validate DP format before dispatch
./tools/lint/dp.sh storage/dp/intake/DP-OPS-0050.md

# Validate Context consistency
./tools/lint/context.sh
~~~

### Skills (Harvest + Promote)
Skills remain on-demand only and must not be placed in `ops/lib/manifests/CONTEXT.md`.

~~~bash
# Enforce Skills Context Hazard
ops/lib/scripts/skill.sh check

# Draft a skill candidate
ops/lib/scripts/skill.sh harvest --name "skill-title" --context "when to use it" --solution "what to do"

# Promote the draft into docs/library/skills and register it
ops/lib/scripts/skill.sh promote storage/archives/skills/skill-YYYYMMDD-HHMMSS-skill-title.md
~~~

### Tasks (Harvest + Promote)
Tasks remain on-demand only and must not be placed in `ops/lib/manifests/CONTEXT.md`.

~~~bash
# Enforce Tasks Context Hazard
ops/lib/scripts/task.sh check

# Draft a task candidate
ops/lib/scripts/task.sh harvest --id B-TASK-01 --name "task-title" --objective "one sentence objective"

# Promote the draft into docs/library/tasks and register it
ops/lib/scripts/task.sh promote storage/archives/tasks/task-B-TASK-01-YYYYMMDD-task-title.md
~~~

---

## 2. Dispatch Packet (DP) Mechanics
**Placement:**
* Drafts: `storage/dp/intake/`
* Processed: `storage/dp/processed/`

**Operator Prompts:**
* `docs/ops/prompts` — Operator prompt stances and usage.

**Disapproval Triggers (When to Reject):**
* ❌ Missing `RECEIPT` (Proof Bundle).
* ❌ Verification steps reported as "NOT RUN".
* ❌ `git diff --stat` does not match the claims.
* ❌ Forbidden scope touched (Drift).

**Allowlist Rule:**
* **Rule:** If a DP includes the llms command, the allowlist must include `llms.txt`, `llms-core.txt`, and `llms-full.txt`.

---

## 3. Scope Definition
* **Platform:** `ops/`, `docs/`, `tools/`, `.github/`. (OS).
* **Project:** `projects/`. (Payload).
* **Rule:** Default to `--scope=platform` unless the DP explicitly targets a project.

---

## 4. Key Paths (Reference)
* **Constitution:** [`../../PoT.md`](../../PoT.md)
* **Active Contract:** [`../../TASK.md`](../../TASK.md)
* **History:** [`../../SoP.md`](../../SoP.md)
* **Artifacts:** `storage/handoff/` (Results), `storage/dumps/` (State).
* **Archives:** `storage/archives/` (Museum).
