<!-- CCD: ff_target="operator-technical" ff_band="25-40" -->
# System Manual (Command Console)

## 0. Mechanical Workflow
**Execution Cycle:**
1.  **Start:** `./ops/bin/open` (Generates prompt + freshness gate).
2.  **Draft:** `./ops/bin/draft` (Generates canonical DP block and updates `TASK.md`).
3.  **Capture (CDD):** `./ops/bin/dump --selection=dp+allowlist --from-dp=auto --format=chatgpt --out=auto` (Serializes Contractor-visible state).
    Note: APD (Audit Platform Dump) is produced at closeout using platform scope capture.
4.  **Dispatch:** Hand DP to Worker (See Section 5).
5.  **Review:** Verify `RECEIPT` (Proofs) vs `TASK.md` requirements.
6.  **Close:** Merge PR + Update ledgers as required by closeout policy.

**Dispatch Contract Notes:**
- The DP Preflight Gate runs after the Freshness Gate and before any edits.
- Worker input is DP text only; OPEN is for integrator refresh and receipt pointers and is not required reading for workers.
- DP structure is generated from `ops/src/surfaces/dp.md.tpl` through `ops/bin/draft`; manual structural edits are prohibited.
- Surface and definition rendering is centralized in `ops/bin/template` with YAML metadata parsing, include injection, and strict slot enforcement by default.
- Definition registry guidance is canonical in `docs/ops/specs/definitions/agents.md`, `docs/ops/specs/definitions/tasks.md`, and `docs/ops/specs/definitions/skills.md`. `opt/_factory/AGENTS.md`, `opt/_factory/TASKS.md`, and `opt/_factory/SKILLS.md` are pointer heads.
- `ops/bin/draft`, `ops/lib/scripts/{agent,task,skill}.sh`, route through `ops/bin/template`.
- Addendum authority: The Contractor receives an addendum as a finished, operator-authorized document. The Contractor does not produce, recommend, or assemble addendum content. If a boundary condition arises during execution, the Contractor stops and reports it to the Integrator.

Local hook activation (one time): run `git config core.hooksPath .github/hooks` in each clone to enable the tracked llms hook. The hook runs `ops/bin/llms` and stages `llms.txt`, `llms-core.txt`, and `llms-full.txt` before each commit so bundle freshness is enforced structurally. Registry: `docs/ops/registry/hooks.md`.

- Disable: `git config --unset core.hooksPath` restores the default hooks path and deactivates all tracked hooks.
- Troubleshoot: if the hook aborts a commit with `ERROR: run llms refresh failed`, confirm `ops/bin/llms` is executable (`chmod +x ops/bin/llms`) and that the invocation is not in a detached HEAD state. Run `./ops/bin/llms` directly to isolate the failure.
- CI fallback: the hook is local only; CI does not run `ops/bin/llms`. A contributor who commits without the hook active can produce stale bundles. The DP integrity lint gate (`tools/lint/integrity.sh`) and DP preflight provide the detection backstop.

**Anchor Hygiene:**
- Refresh anchors when Base HEAD changes or when a new OPEN artifact is generated. Update TASK.md pointer references to the newest OPEN artifact and RESULTS receipts before any work continues; do not rewrite inline branch/hash state in TASK.md.
- Clean after use: complete closeout receipts and start the next session from a fresh OPEN artifact with matching dump artifacts.

### Pointer-First TASK Diagnostics (draft/manifest)
`ops/bin/draft` and `ops/bin/manifest` treat `TASK.md` as pointer-first at runtime. When a guard fails on a TASK-coupled path, the diagnostic now prints a named `guard_condition` plus both:
- `task_source_path` (usually `TASK.md`)
- `task_resolved_path` (the archived TASK surface leaf actually checked when `TASK.md` is a pointer head)

This is a legibility hardening change only. Guard pass/fail semantics are unchanged. CbC rationale: the pointer-first TASK head is an intentional structural design; the failure class here is cross-surface runtime coupling, so the proportionate fix is deterministic diagnostics rather than a new enforcement branch.

#### Proof Matrix (diagnostic fields only; no behavior change)
| Tool path | Deterministic hazard | Expected diagnostic fields |
| :--- | :--- | :--- |
| `ops/bin/draft` TASK marker-count guard | Section 3 marker count or active `### DP-` count is not exactly one on the resolved TASK surface | `guard_condition`, `task_source_path`, `task_resolved_path`, `observed_count`, `expected_count` |
| `ops/bin/draft` TASK replacement guard | Active DP heading cannot be located for replacement under Section 3 | `guard_condition`, `task_source_path`, `task_resolved_path`, `replacement_source_path` |
| `ops/bin/manifest` DP duplicate-id guard | Requested `DP_ID` already exists in active TASK content | `guard_condition`, `packet_id`, `task_source_path`, `task_resolved_path` |
| `ops/lib/scripts/task.sh` TASK metadata pointer resolution guards | TASK head pointer is malformed, missing, or materializes to an empty body during metadata reads | source path and resolved path in the error text (pointer-vs-resolved recovery seam) |

## Closeout Cycle
#### Closing Sidecar Authorship

The Contractor creates and populates `storage/handoff/CLOSING-<DP-ID>.md` before
invoking `ops/bin/certify`. This file is not Operator-authored and is not deferred
to a later session. The Contractor uses `ops/src/surfaces/closing.md.tpl` as the
schema. If that template is absent, the Contractor stops and requests it from the
Operator before proceeding. Absence of the closing sidecar is a certify hard-fail;
it is not a recoverable warning.

Finalization protocol order is strict: Verify -> Generate Results -> COMMIT (Operator Only) -> Prune.
Mandatory Closing Block schema is defined in `TASK.md` Section 3.5.1.
Only the current six-label closing sidecar schema is accepted; `ops/bin/certify` is the schema authority; `tools/lint/style.sh` enforces that schema. The current label set is SSOT in `ops/lib/manifests/CLOSING.md` (Section 1), and `ops/src/surfaces/closing.md.tpl` includes that section.
Closeout label update procedure (future packets): edit `ops/lib/manifests/CLOSING.md` first, then validate and update every consumer that derives or validates the closing schema (`ops/src/surfaces/closing.md.tpl`, `ops/bin/certify`, `tools/lint/style.sh`, `tools/lint/results.sh`, and any coupled TASK lint logic), then rerun the full verify/certify closeout gates.
The `Confirm Merge (Extended Description)` field accepts only approved-prefix, repo-relative literal paths; root-level canonical surfaces (`PoW.md`, `SoP.md`, `TASK.md`, `llms*.txt`) are not valid entries in this field.
Root-level surface changes that are not valid entries in `Confirm Merge (Extended Description)` are accounted for in RESULTS narrative text and the Contractor Notes surface instead.
`PoW.md`, `SoP.md`, `TASK.md` HEAD pointer rewrites and `archives/surfaces/*` leaves are generated by `ops/bin/certify`; do not hand-author those generated outputs.

1. Verify
Run:
~~~bash
./tools/verify.sh
./tools/lint/truth.sh
./tools/lint/style.sh
./tools/lint/ff.sh
./tools/lint/context.sh
./tools/lint/agent.sh
./tools/lint/dp.sh TASK.md
bash tools/lint/factory.sh
~~~
Tooling DP addendum: if the DP objective adds, modifies, or replaces a linter, script, guard, or validation binary, confirm at closeout that: (1) the CbC Design Discipline Preflight block in TASK.md §3.1.1 is present and non-empty; (2) enforcement complexity did not exceed 100 lines without a note in §3.4.4 justifying the budget; (3) a SoP note is added if structural prevention was identified as viable but deferred. Full procedure: docs/DESIGN.md.
Keep `storage/handoff/CLOSING-DP-OPS-XXXX.md` populated throughout execution.

2. Generate Results
#### Pre-Certify Allowlist Declaration (required when DP scope includes closeout)

Before invoking `ops/bin/certify`, confirm that the following three paths are present
in `storage/dp/active/allowlist.txt`:

- PoW.md
- SoP.md
- TASK.md

Rationale: `ops/bin/certify` rewrites the current heads of these three canon surfaces
to single-line archive pointers during closeout. These mutations are tracked by git
and must be allowlist-covered before certify runs. Certify invokes
`tools/lint/integrity.sh` internally; if any changed file is outside the allowlist,
integrity.sh will hard-fail. Discovering this gap at runtime is a preventable
protocol error.

Run:
~~~bash
./ops/bin/certify --dp=DP-OPS-XXXX --out=auto
bash tools/lint/results.sh storage/handoff/DP-OPS-XXXX-RESULTS.md
~~~
`ops/bin/certify` runs integrity checks, executes the Section 3.4.5 verification command list, renders the RESULTS receipt from template, and runs `tools/lint/results.sh` as a hard gate.
Note: certify resolves the target DP from the TASK head leaf by default. Ensure the TASK head leaf is structurally valid and contains the live current DP block before running certify. If the TASK head leaf is absent or invalid, certify falls back to the intake packet; this fallback is a recovery path only.
`tools/lint/results.sh` accepts only the current six-label Mandatory Closing Block schema emitted by `ops/bin/certify`; certify remains the schema authority for RESULTS closing-block labels. The current label set is sourced from `ops/lib/manifests/CLOSING.md` (Section 1) in certify and synchronized lint consumers.
`ops/bin/certify` also emits schema-stamped surface leaves for PoW/SoP/TASK under `archives/surfaces/` and rewrites `PoW.md`, `SoP.md`, and `TASK.md` to single-line HEAD pointers to those leaves.
If `TASK.md` does not contain the target DP block, certify now fails unless `--allow-intake-fallback` is explicitly provided.
`bash tools/lint/results.sh` without arguments targets the active branch packet receipt when resolvable; use `--all` only for full historical receipt scans.
Manual RESULTS fabrication is prohibited.

2.5 Post-Work Audit (Integrator; mandatory before COMMIT)
The Integrator reviews the diff (`git diff --name-only`, `git diff --stat`), the RESULTS receipt at `storage/handoff/DP-OPS-XXXX-RESULTS.md`, and the closing sidecar at `storage/handoff/CLOSING-DP-OPS-XXXX.md` against the DP scope definition (Section 3.3 In scope / Out of scope).

If scope was exceeded, a boundary condition was not anticipated, or an authorization is needed for work already done or needed to complete:
- The Integrator renders an addendum recommendation from `ops/src/surfaces/addendum.md.tpl` and outputs it as a markdown code block.
- The Operator reviews and provides the `OPERATOR_AUTHORIZATION` field content.
- The authorized addendum is handed to the Contractor as a received, finished document.
- The Contractor executes against the addendum only; the Contractor does not author addendum content.

If scope is clean: proceed to step 3.

### Contractor Notes Surface
The Contractor creates and populates `storage/handoff/CONTRACTOR-NOTES.md` using
`ops/src/surfaces/notes.md.tpl` as the schema before the operator's post-work audit
review (before step 2.5). This file is not Operator-authored and is not deferred to
a later session.

Required fields:
- `Scope Confirmation:` — what was executed versus what was scoped; note any conditional
  skips with reasons.
- `Anomalies Encountered:` — friction items, unexpected behaviors, workaround decisions.
- `Open Items / Residue:` — anything unresolved, non-blocking residue, or audit hazards.
- `Closing Schema Baseline:` — explicit declaration that the current six-label schema was
  assumed (post-0116+A baseline), or an explicit exception note if the packet
  intentionally touches historical artifacts or compatibility paths. Historical packet
  references may appear in narrative text; this field records only the active packet's
  schema assumptions.

Prior `CONTRACTOR-NOTES.md` files in `storage/handoff/` are not retroactively reformatted
to this schema.

Routing: `storage/handoff/CONTRACTOR-NOTES.md` is a closeout-time handoff surface under
`storage/handoff/`. It is required by closeout procedure and DP routing, but it is not a
global CONTEXT manifest dependency because it is produced late in the session.

### dp.md.tpl Hash-Coupling Recovery

**Authorized trigger condition:** `bash tools/lint/dp.sh TASK.md` fails with a canonical
template hash mismatch immediately after `ops/src/surfaces/dp.md.tpl` was edited in the
current work branch.

This recovery procedure is authorized for this exact trigger condition only. Any other
`dp.sh` failure requires a stop and Integrator review, and may require an addendum before
work continues.

**Recovery steps (run in order; do not skip):**

1. Compute the new template hash:
   ~~~bash
   sha256sum ops/src/surfaces/dp.md.tpl
   ~~~
   If `sha256sum` is not available, use: `shasum -a 256 ops/src/surfaces/dp.md.tpl`

2. Update the `CANONICAL_DP_TEMPLATE_SHA256` constant in `tools/lint/dp.sh` to the
   computed hash value.

3. Re-run the template hash preflight and confirm PASS:
   ~~~bash
   bash tools/lint/dp.sh --test
   ~~~

4. Re-run the full DP lint:
   ~~~bash
   bash tools/lint/dp.sh TASK.md
   ~~~
   If PASS: recovery is complete. If the lint fails on normalized-structure mismatch
   (not a hash mismatch): proceed to step 5.

5. Rerender `TASK.md` mechanically using the canonical generator with the same arguments
   as the original draft invocation:
   ~~~bash
   ./ops/bin/draft --id=<DP_ID> ...
   ~~~
   Do not hand-edit structural boilerplate in the rendered output.

6. Re-run `bash tools/lint/dp.sh TASK.md` and confirm PASS.

**Documentation requirement:** When this recovery is used, record it in the
`Anomalies Encountered` field of `storage/handoff/CONTRACTOR-NOTES.md`. Include:
the triggering lint failure output, the `CANONICAL_DP_TEMPLATE_SHA256` value before
and after the update, whether a TASK rerender (step 5) was required, and the final
`bash tools/lint/dp.sh TASK.md` PASS confirmation.

**Addendum path:** If a `dp.sh` failure does not match the authorized trigger condition
above, do not apply this recovery. Stop, report to the Integrator, and await addendum
authorization before proceeding.

3. Harvest
Run only if new reusable patterns exist.
~~~bash
./ops/lib/scripts/agent.sh harvest-check
~~~
If promotion is needed, use existing ops/lib/scripts/skill.sh and ops/lib/scripts/task.sh workflows.

4. Refresh
Allowlist must include `llms.txt`, `llms-core.txt`, and `llms-full.txt` before running the command.
Out-dir must be absolute. Use `$(pwd)`.
Do not hand-edit `llms.txt`, `llms-core.txt`, or `llms-full.txt`; regenerate with tooling only.
~~~bash
./ops/bin/map
./ops/bin/llms --out-dir="$(pwd)"
~~~
`ops/bin/llms` Refresh Side-Effect Notice:
- `ops/bin/llms` is a compile event. It regenerates `ops/lib/manifests/OPS.md` in addition to `llms*.txt` bundle outputs. This is expected behavior, not a defect.
- The pre-commit hook (`.github/hooks/llms`) protects against committing `OPS.md` out-of-scope at the commit boundary. It does not prevent the working-tree modification from occurring during Refresh.
- If `OPS.md` is not in the active DP allowlist, restore it after Refresh before running `tools/lint/integrity.sh`:
  `git restore --source=HEAD --staged --worktree -- ops/lib/manifests/OPS.md`
  Then re-run `bash tools/lint/integrity.sh` to confirm clean state before proceeding.
- If `OPS.md` content genuinely needs updating, add it to the allowlist and authorize the change explicitly before proceeding.
- OPEN/DUMP Refresh can legitimately produce porcelain entries (e.g., modified `OPS.md`, new `archives/manifests/compile-*.md` leaves) even when the DP is docs-only. Account for these before running `integrity.sh` or interpreting `git status --porcelain` output.
Compile snapshot policy:
- `ops/bin/compile` is an archiving event; each successful run emits a new immutable leaf under `archives/manifests/`.
- Treat new `archives/manifests/compile-*.md` leaves as audit artifacts and include them in branch closeout commits.
- Allowlist policy entries may use wildcard paths (for example `archives/manifests/compile-*.md`) to cover generated compile leaves.

5. Log
Prepare SoP/PoW ledger updates before running certify so the emitted leaf snapshots capture the intended entry content.
After certify, treat `PoW.md`, `SoP.md`, and `TASK.md` as pointer heads; do not manually edit pointer lines or emitted `archives/surfaces/*` leaves.
If operator authorization expands scope beyond the original DP boundaries, record that authorization explicitly in SoP and PoW entry content and mirror it in the Closing Block sidecar.
PoW contract and schema guidance are canonical in `docs/ops/specs/surfaces/pow.md`; author PoW entry content to that spec before certification snapshotting.
PoW entry receipt pointers must include `RESULTS`, `OPEN`, and `DUMP` artifact paths.
PoW entry `Notes` must record both positive proof and negative proof context (failed checks, ruled-out hypotheses, and abandoned attempts) when they materially affected execution.
Ensure the RESULTS receipt uses RUN or NOT RUN status per verification command, with reason and risk for each NOT RUN item.

### Log Step: Pre-certify single-entry head authoring (`SoP.md` and `PoW.md`)
1. Rule: before running `ops/bin/certify`, author `SoP.md` and `PoW.md` to contain only the single new entry for the current DP. Do not copy archive leaf history from prior `archives/surfaces/` leaves into the current head.
2. Reason: `tools/lint/truth.sh` scans current heads and rejects historical strings from archive leaves. Those strings are tolerated in `archives/surfaces/` but are forbidden in head-lint context. Copying history into the head causes `truth.sh` to fail.
3. Invariant: `ops/bin/certify` generates the `previous:` pointer on the new archive leaf and manages chain linkage. The contractor does not manage or reconstruct chain history manually.
4. Confirmation note: DP-OPS-0116 and ADDENDUM-A confirmed that certify-managed pointer rewrites of `PoW.md`, `SoP.md`, and `TASK.md` to single-line HEAD pointers are expected closeout behavior; do not interpret those rewrites as corruption.
5. Worked example (same pattern for both `SoP.md` and `PoW.md`):

~~~md
# Correct single-entry head (current DP only)
## <timestamp> UTC - DP-OPS-0113 <summary>
...current DP entry fields only...
~~~

~~~md
# Incorrect full-history head (copied archive history)
## <timestamp> UTC - DP-OPS-0113 <summary>
...current DP entry fields...

## <older timestamp> UTC - DP-OPS-XXXX <prior summary>
...copied prior archive leaf entry...
~~~

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

### DP Draft (Canonical Generator)
~~~bash
# Generate DP-OPS-0065 from canonical template with slot sidecar input
./ops/bin/draft --id=DP-OPS-0065 --title="Immutable workflow adoption" \
  --work-branch=work/dp-ops-0065-2026-02-14 --base-head=d3801c3a \
  --slots-file=storage/dp/intake/DP-OPS-0065.slots
~~~

### Template Renderer
~~~bash
# Render a DP template in strict mode (default)
./ops/bin/template render dp --slots-file=storage/dp/intake/DP-OPS-0065.slots --out=storage/dp/intake/DP-OPS-0065.md

# Render canonical DP body for lint normalization (non-strict mode)
./ops/bin/template render dp --non-strict --out=-
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
bash tools/lint/dp.sh storage/dp/intake/DP-OPS-0050.md

# Validate Context consistency
./tools/lint/context.sh
~~~
Pre-dispatch DP finalize gate: run `bash tools/lint/dp.sh <intake-packet>` and confirm PASS (`OK: DP lint passed`). A PASS confirms both that no `PROPOSED` tokens remain and that the packet is structurally well-formed. No separate finalize step or binary is required.

### Skills (Harvest + Promote)
Skills remain on-demand only and must not be placed in `ops/lib/manifests/CONTEXT.md`.

~~~bash
# Enforce Skills Context Hazard
ops/lib/scripts/skill.sh check

# Draft a skill candidate
ops/lib/scripts/skill.sh harvest --name "skill-title" --context "when to use it" --solution "what to do"

# Promote the draft into opt/_factory/skills and register it
ops/lib/scripts/skill.sh promote archives/definitions/skill-candidate-YYYY-MM-DD-<suffix>.md
~~~

### Tasks (Harvest + Promote)
Tasks remain on-demand only and must not be placed in `ops/lib/manifests/CONTEXT.md`.

~~~bash
# Enforce Tasks Context Hazard
ops/lib/scripts/task.sh check

# Draft a task candidate
ops/lib/scripts/task.sh harvest --id B-TASK-01 --name "task-title" --objective "one sentence objective"

# Promote the draft into opt/_factory/tasks and register it
ops/lib/scripts/task.sh promote archives/definitions/task-candidate-YYYY-MM-DD-<suffix>-B-TASK-01.md
~~~

---

## 2. Dispatch Packet (DP) Mechanics
**Placement:**
* Drafts: `storage/dp/intake/`
* Processed: `storage/dp/processed/`
* `storage/dp/intake/` is staging-only and must not contain tracked `DP-*.md` packets in commits.

**Operator Prompts:**
* `docs/ops/prompts` — Operator prompt stances and usage.

**Disapproval Triggers (When to Reject):**
* ❌ Missing `RECEIPT` (Proof Bundle).
* ❌ Verification steps reported as "NOT RUN".
* ❌ `git diff --stat` does not match the claims.
* ❌ Forbidden scope touched (Drift).

**Allowlist Rule:**
* **Rule:** If a DP includes the llms command, the allowlist must include `llms.txt`, `llms-core.txt`, and `llms-full.txt`.
* **Rule:** `storage/dp/active/allowlist.txt` is persistent-path policy only. Do not include runtime artifact prefixes (`storage/handoff/`, `storage/dumps/`, `storage/dp/intake/`, `storage/dp/processed/`).

### Contractor Dispatch Dump (CDD)

DP writer must include a `Contractor Dispatch Dump (CDD)` field in dispatch notes.
The value is the exact `./ops/bin/dump` command used to generate the Contractor-visible dump.
Default recommended value for most DPs: `./ops/bin/dump --selection=dp+allowlist --from-dp=auto --format=chatgpt --out=auto`.
If additional forbidden prefixes are needed for a sensitive engagement, the DP writer lists them explicitly with `--fail-on-forbidden-prefix=...`.

### Auditor Visibility

Auditor visibility is intentionally bounded and documented as an allow/deny contract.
- External auditor receives: RESULTS receipt and APD (Audit Platform Dump).
- External auditor does not receive: CDD, OPEN artifacts, closing sidecars, or any other `storage/handoff/` artifacts.
- Evidence surfaces for audit are SoP and PoW entries plus the committed diff and RESULTS.

### Certify Compatibility Authoring Rules

Two DP authoring constraints are enforced by both dp.sh at lint time and certify at replay time.

Freshness Stamp format: The Freshness Stamp field value must be YYYY-MM-DD and nothing else.
No trace tokens, no timestamps, no other text. Examples of invalid forms: stela-20260223T151354Z-16f27113,
2026-02-23T15:13Z, today. Example of valid form: 2026-02-23. Certify rejects all other forms and dp.sh
fails at preflight if the format is invalid.

Receipt command substitution: Section 3.4.5 receipt commands must use literal values only.
Command substitution forms (expressions beginning with $() ) are rejected by certify's literal replay
engine. Example of invalid form: ./ops/bin/llms --out-dir="$(pwd)". Example of valid form:
./ops/bin/llms --out-dir=. . Use literal relative or absolute paths in all receipt commands.
dp.sh fails at preflight if any command substitution token is found in Section 3.4.5.

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
* **Resume cache:** `var/tmp/` (ephemeral worker scratch).
* **Telemetry:** `logs/` (runtime diagnostics).
* **Archives:** `archives/` (Museum).
