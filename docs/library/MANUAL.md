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

---

## 5. AI Interaction Protocols (Mode Switching)
*To prevent logic drift, explicitly set the AI's "mode" at the start of a session. Use these templates to lock in the correct jurisdiction and context.*

### Mode 1: Refresh + Discuss (Analyst Stance)
**Use when:** Starting fresh or analyzing without editing. Locks the AI into a read-only, advisory role.
**Attach:** `OPEN` + `dump`.

SEE ATTACHED: OPEN + repo dump. Refresh state.
PREPARE TO DISCUSS: <topic>.
Use attached files as ground truth.
Discussion only (no edits, no DP, no commands).

### Mode 2: Refresh + Draft DP (Architect Stance)
**Use when:** Creating a new Dispatch Packet. Enforces `TASK.md` structure and prevents hallucinated requirements.
**Attach:** `OPEN` + `dump` + `plan.md`.

SEE ATTACHED: OPEN + repo dump. Refresh state.
DRAFT <DP-ID> from the attached <summary-file>.
- Use the dump branch + freshness (Base HEAD) exactly as shown in the dump/OPEN.
- Strictly use the headings + order in TASK.md (including closing headings).
- Output ONLY the DP.
- Do not add/rename sections.
- If required inputs are missing, STOP and ask only for the missing items.

### Mode 3: Refresh + Conform DP (Hygiene Stance)
**Use when:** Updating an old DP to the current template.
**Attach:** `OPEN` + `dump` + `Old-DP.md`.

SEE ATTACHED: OPEN + repo dump. Refresh state.
CONFORM <DP-ID> TO CURRENT TASK.md — INTENT UNCHANGED.
- Use the dump branch + freshness (Base HEAD) exactly as shown in the dump/OPEN.
- Strictly use the headings + order in TASK.md.
- Output ONLY the DP.

### Mode 4: Refresh + Audit (Gatekeeper Stance)
**Use when:** Validating worker output before merge. Forces a binary PASS/FAIL decision based on evidence.
**Attach:** `RESULTS.md` + `OPEN` + `dump` + `manifest`.

SEE ATTACHED: RESULTS + OPEN + OPEN-PORCELAIN + dump + dump manifest. Refresh state.
AUDIT: Does <DP-ID> meet spec?
- receipt complete
- allowlist respected
- proofs present
- verification present
If anything is missing/incorrect: DISAPPROVE and issue a patch request.
