# Operator Manual (Command Console)

## 0. The Loop (Mechanical Workflow)
**Execution Cycle:**
1.  **Start:** `./ops/bin/open` (Generates prompt + freshness gate).
2.  **Capture:** `./ops/bin/dump` (Serializes state).
3.  **Assign:** Create DP in `TASK.md` + New Branch `work/topic-date`.
4.  **Dispatch:** Hand DP to Worker (See Section 5).
5.  **Review:** Verify `RECEIPT` (Proofs) vs `TASK.md` requirements.
6.  **Close:** Merge PR + Update `SoP.md` (if Canon changed).

---

## 1. Top Commands (Cheat Sheet)

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

### Documentation (Help)
~~~bash
./ops/bin/help              # Show menu
./ops/bin/help continuity   # Grep docs for "continuity"
~~~

### Validation (Lint)
~~~bash
# Validate DP format before dispatch
./tools/dp_lint.sh storage/dp/intake/DP-OPS-0050.md

# Validate Context consistency
./tools/context_lint.sh
~~~

### Skills (Harvest + Promote)
Skills remain on-demand only and must not be placed in `ops/lib/manifests/CONTEXT.md`.

~~~bash
# Enforce Skills Context Hazard
ops/lib/skill/skill_lib.sh check

# Draft a skill candidate
ops/lib/skill/skill_lib.sh harvest --name "skill-title" --context "when to use it" --solution "what to do"

# Promote the draft into docs/library/skills and register it
ops/lib/skill/skill_lib.sh promote storage/handoff/skill-draft-YYYYMMDD-HHMMSS-skill-title.md
~~~

---

## 2. Dispatch Packet (DP) Mechanics
**Placement:**
* Drafts: `storage/dp/intake/`
* Processed: `storage/dp/processed/`

**Disapproval Triggers (When to Reject):**
* ❌ Missing `RECEIPT` (Proof Bundle).
* ❌ Verification steps reported as "NOT RUN".
* ❌ `git diff --stat` does not match the claims.
* ❌ Forbidden scope touched (Drift).

---

## 3. Scope Definition
* **Platform:** `ops/`, `docs/`, `tools/`, `.github/`. (The OS).
* **Project:** `projects/`. (The Payload).
* **Rule:** Default to `--scope=platform` unless the DP explicitly targets a project.

---

## 4. Key Paths (Reference)
* **Constitution:** [`../../TRUTH.md`](../../TRUTH.md)
* **Active Contract:** [`../../TASK.md`](../../TASK.md)
* **History:** [`../../SoP.md`](../../SoP.md)
* **Artifacts:** `storage/handoff/` (Results), `storage/dumps/` (State).
