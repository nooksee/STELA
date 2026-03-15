<!-- CCD: ff_target="operator-technical" ff_band="25-40" -->
# System Manual (Command Console)

## 0. Mechanical Workflow
**Execution Cycle:**
1.  **Start:** `./ops/bin/open` (Generates prompt + freshness gate).
2.  **Draft:** `./ops/bin/draft` (Generates canonical DP block and updates `TASK.md`).
3.  **Capture (CDD):** `./ops/bin/dump --selection=dp+allowlist --from-dp=auto --format=chatgpt --out=auto` (Serializes Contractor-visible state).
    Note: Audit intake is bundle-first. Use `./ops/bin/bundle --profile=audit --out=auto` for audit review. Bundle dump scope is profile-mapped from `ops/lib/manifests/BUNDLE.md`; current audit mapping is `core`.
4.  **Dispatch:** Hand DP to Worker (See Section 5).
5.  **Review:** Verify `RECEIPT` (Proofs) vs `TASK.md` requirements.
6.  **Close:** Merge PR + Update ledgers as required by closeout policy.

**Dispatch Contract Notes:**
- The DP Preflight Gate runs after the Freshness Gate and before any edits.
- Worker input is DP text only; OPEN is for integrator refresh and receipt pointers and is not required reading for workers.
- DP structure is generated from `ops/src/surfaces/dp.md.tpl` through `ops/bin/draft`; manual structural edits are prohibited.
- Surface and definition rendering is centralized in `ops/bin/template` with YAML metadata parsing, include injection, and strict slot enforcement by default.
- Bundle stance contract rendering is template-backed via `ops/src/stances/*.md.tpl` and manifest stance keys in `ops/lib/manifests/BUNDLE.md`.
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
Mandatory Closing Sidecar schema is defined in `TASK.md` Section 3.5.1.
Only the current six-label closing sidecar schema is accepted; `ops/bin/certify` is the schema authority; `tools/lint/style.sh` enforces that schema. The current label set is SSOT in `ops/lib/manifests/CLOSING.md` (Section 1), and `ops/src/surfaces/closing.md.tpl` includes that section.
Closeout label update procedure (future packets): edit `ops/lib/manifests/CLOSING.md` first, then validate and update every consumer that derives or validates the closing schema (`ops/src/surfaces/closing.md.tpl`, `ops/bin/certify`, `tools/lint/style.sh`, `tools/lint/results.sh`, and any coupled TASK lint logic), then rerun the full verify/certify closeout gates.
The `Confirm Merge (Extended Description)` field accepts only approved-prefix, repo-relative literal paths; root-level canonical surfaces (`PoW.md`, `SoP.md`, `TASK.md`, `llms*.txt`) are not valid entries in this field.
Root-level surface changes that are not valid entries in `Confirm Merge (Extended Description)` are accounted for in RESULTS narrative text.
`PoW.md`, `SoP.md`, `TASK.md` HEAD pointer rewrites and `archives/surfaces/*` leaves are generated by `ops/bin/certify`; do not hand-author those generated outputs.

1. Verify
Run:
~~~bash
./tools/verify.sh --mode=full
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

Before invoking `ops/bin/certify`, run `./ops/bin/allowlist` as a required pre-certify dry-run. This helper
reproduces the RESULTS allowlist subset checks for tracked-changed and untracked
paths and prints ready-to-paste allowlist lines for any missing entries.

Rationale: `ops/bin/certify` now structurally owns its exact current-run generated
surface set:
- `PoW.md`
- `SoP.md`
- `TASK.md`
- the three active `archives/surfaces/...` leaves it emits

Those exact current-run generated paths no longer require packet-specific allowlist
entries. All other touched tracked files still require normal allowlist coverage
before certify runs.

Run:
~~~bash
./ops/bin/allowlist
./ops/bin/certify --dp=DP-OPS-XXXX --out=auto
bash tools/lint/results.sh storage/handoff/DP-OPS-XXXX-RESULTS.md
~~~
`ops/bin/certify` now fails in explicit phases: `preflight`, `replay`, `verify`, `postflight`, and `results`. Cheap closeout defects such as malformed closing sidecar content, malformed narrative scaffolds, missing trace / OPEN prerequisites, or obviously stale receipt-command shapes must fail in `preflight` before long replay begins. Certify emits `Certify phase: <phase>` on phase changes and phase-tags hard-fail output as `ERROR [<phase>]`.
At the end of a run, certify also emits stable timing summaries:
- `CERTIFY-PHASE: name=<phase> duration_seconds=<N>`
- `CERTIFY-LONG-POLE: rank=<N> phase=<phase> command_id=<id> duration_seconds=<N> command=<sanitized-command>`
Before replay, certify also prints the exact current-run generated-surface ownership set so the operator can see which paths are structurally certify-owned.
When certify replays a plain `bash tools/verify.sh` receipt line, it rewrites that invocation to `bash tools/verify.sh --mode=certify-critical` inside the certify loop. The bounded certify-critical mode preserves closeout-safety bundle/open smoke checks while leaving full repo verify coverage available through standalone `./tools/verify.sh --mode=full`. Narrative scaffold validation stays in certify preflight, so editor smoke remains full-verify only.
`tools/verify.sh` emits stable lane lines for each executed smoke/lint lane:
- `VERIFY-LANE: name=<lane> scope=<certify-critical|full-only> status=<pass|fail|missing> duration_seconds=<N> detail=<command-or-path>`
- `VERIFY-LANE-SUMMARY: ...`
It also emits `VERIFY-LANE-ORDER: mode=<mode> order=<comma-separated-lanes>` before lane execution so the active fail-fast lane order is visible.
`ops/bin/certify` runs integrity checks, executes the Section 3.4.5 verification command list, renders the RESULTS receipt from template, and runs `tools/lint/results.sh` as a hard gate.
After surface emission, certify verifies that the active TASK leaf is packet-consistent and runs `./ops/bin/prune --target=dump --phase=report --dry-run` so closeout always captures dump-visible pressure. The prune report is observational receipt evidence only; it does not authorize canonical archive deletion.
Note: certify resolves the target DP from the TASK head leaf by default. Ensure the TASK head leaf is structurally valid and contains the live current DP block before running certify. If the TASK head leaf is absent or invalid, certify falls back to the intake packet; this fallback is a recovery path only.
`tools/lint/results.sh` enforces the RESULTS schema through `## Contractor Execution Narrative` and required Decision Leaf lines. Closing sidecar schema validation remains `ops/bin/certify` authority against `ops/lib/manifests/CLOSING.md` (Section 1).
`ops/bin/certify` also emits schema-stamped surface leaves for PoW/SoP/TASK under `archives/surfaces/` and rewrites `PoW.md`, `SoP.md`, and `TASK.md` to single-line HEAD pointers to those leaves.
If `TASK.md` does not contain the target DP block, certify now fails unless `--allow-intake-fallback` is explicitly provided.
`bash tools/lint/results.sh` without arguments targets the active branch packet receipt when resolvable; use `--all` only for full historical receipt scans.
Manual RESULTS fabrication is prohibited.

### Certify Rerun (Post-Move Recovery)

**Trigger condition:** `ops/bin/certify` has completed at least one invocation for the
active DP and has moved the intake packet from `storage/dp/intake/DP-OPS-XXXX.md` to
`storage/dp/processed/DP-OPS-XXXX.md`. A second certify invocation is required (for
example, after an allowlist correction or a sidecar fix identified during the first run).

**Coexistence prohibition:** The intake packet must not exist simultaneously in both
`storage/dp/intake/` and `storage/dp/processed/` when certify is invoked. Violating this
constraint produces an indeterminate path for certify artifact resolution.

**Recovery steps (run in order; do not skip):**

1. Copy the intake packet back from processed to the intake directory:
~~~bash
cp storage/dp/processed/DP-OPS-XXXX.md storage/dp/intake/DP-OPS-XXXX.md
~~~

2. Move the processed copy to `var/tmp/` to eliminate coexistence:
~~~bash
mv storage/dp/processed/DP-OPS-XXXX.md var/tmp/DP-OPS-XXXX.pre-rerun-processed.md
~~~

3. Confirm `storage/dp/processed/DP-OPS-XXXX.md` no longer exists:
~~~bash
ls storage/dp/processed/
~~~

4. Run certify:
~~~bash
./ops/bin/certify --dp=DP-OPS-XXXX --out=auto
~~~

On success, certify moves `storage/dp/intake/DP-OPS-XXXX.md` to
`storage/dp/processed/DP-OPS-XXXX.md` again. The `var/tmp/` staging copy is
disposable and does not require cleanup before certify runs.

**Note:** Replace `DP-OPS-XXXX` with the literal DP identifier for the active packet.
Substitute `DP-OPS-XXXX.md` accordingly in all three commands above.

2.5 Post-Work Audit (Integrator; mandatory before COMMIT)
The Integrator reviews the diff (`git diff --name-only`, `git diff --stat`), the RESULTS receipt at `storage/handoff/DP-OPS-XXXX-RESULTS.md`, and the closing sidecar at `storage/handoff/CLOSING-DP-OPS-XXXX.md` against the DP scope definition (Section 3.3 In scope / Out of scope).

If scope was exceeded, a boundary condition was not anticipated, or an authorization is needed for work already done or needed to complete:
- The Integrator renders an addendum recommendation from `ops/src/stances/addendum.md.tpl` and outputs it as a markdown code block.
- The Operator reviews and provides the `OPERATOR_AUTHORIZATION` field content.
- The authorized addendum is handed to the Contractor as a received, finished document.
- The Contractor executes against the addendum only; the Contractor does not author addendum content.

If scope is clean: proceed to step 3.

### Contractor Execution Narrative
The Contractor Execution Narrative is collected interactively by `ops/bin/certify` at
certify time. When certify runs, it writes a scaffold block to a temp file and opens
the configured editor (`$EDITOR` or `vi`). The worker fills in the narrative before
certify proceeds. The narrative is rendered into the RESULTS receipt under
`## Contractor Execution Narrative`.

Required subsections:
- `### Preflight State` — state the preflight outcome: branch, Base HEAD, clean tree, and preflight lint results.
- `### Implemented Changes` — describe each change made: what was modified, created, or removed, and why.
- `### Closeout Notes` — describe anomalies, open items, or residue; state None. if all items are resolved.
- `### Decision Leaf` — record the decision record outcome:
  - `Decision Required: Yes|No`
  - `Decision Leaf: archives/decisions/... or None`

Decision Record Trigger:
- If anomalies or open items exist, set `Decision Required: Yes` and provide a
  repo-relative path under `archives/decisions/` for the decision leaf file.
- If execution was clean and no items are unresolved, set `Decision Required: No`
  and `Decision Leaf: None`.
- Authoring rule: when `Decision Required: Yes`, the contractor writes a decision
  record leaf under `archives/decisions/` and records its path in the narrative.
- Minimum fields for a decision leaf: `decision_id`, `trace_id`, `packet_id`,
  `decision_type`, `context`, `decision`, `consequence`, `status`, `pointer`.

Routing: the narrative is captured and embedded in RESULTS by `ops/bin/certify`. There
is no separate handoff file for the narrative; it does not exist before certify runs.

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
`### Closeout Notes` and `### Decision Leaf` subsections of the Contractor Execution
Narrative at certify time. Include:
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
If operator authorization expands scope beyond the original DP boundaries, record that authorization explicitly in SoP and PoW entry content and mirror it in the closing sidecar.
PoW contract and schema guidance are canonical in `docs/ops/specs/surfaces/pow.md`; author PoW entry content to that spec before certification snapshotting.
PoW entry receipt pointers must include `RESULTS`, `OPEN`, and `DUMP` artifact paths.
Do not reproduce the verification command list in SoP or PoW entries; RESULTS carries the full command log with outputs.
PoW entry `Notes` are artifact-level context only (scope anomalies affecting the artifact inventory). Execution narrative and anomaly resolution belong in RESULTS Contractor Execution Narrative.
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
OPEN wrapper marker contract:
- Begin marker: `===== STELA OPEN PROMPT =====`
- End marker: `===== END STELA OPEN PROMPT =====`
OPEN de-dup contract:
- OPEN includes porcelain summary fields and a pointer to OPEN-PORCELAIN when dirty.
- OPEN does not inline full or preview porcelain payload blocks.
- OPEN-PORCELAIN is the detailed porcelain payload artifact.

### DP Draft (Canonical Generator)
~~~bash
# Generate DP-OPS-0065 from canonical template with slot sidecar input
./ops/bin/draft --id=DP-OPS-0065 --title="Immutable workflow adoption" \
  --work-branch=work/dp-ops-0065-2026-02-14 --base-head=d3801c3a \
  --slots-file=storage/dp/intake/DP-OPS-0065.slots

# Emit plan scaffold for analyst/architect authoring
./ops/bin/draft --emit-plan-scaffold=var/tmp/plan-scaffold.md

# Emit DP slots scaffold for sidecar authoring
./ops/bin/draft --emit-dp-slots-scaffold=var/tmp/dp-slots-scaffold.md

# Interactive scaffold edit (single target only)
./ops/bin/draft --emit-plan-scaffold=var/tmp/plan-scaffold.md --edit-scaffold

# Non-interactive scaffold ingest and validation
./ops/bin/draft --emit-dp-slots-scaffold=var/tmp/dp-slots-scaffold.md \
  --load-scaffold-file=var/tmp/dp-slots-filled.md

# Explicit scaffold validation entrypoints
./ops/bin/draft --validate-plan-scaffold=var/tmp/plan-scaffold.md
./ops/bin/draft --validate-dp-slots-scaffold=var/tmp/dp-slots-scaffold.md
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
# Core Scope (Default - Excludes projects/ and opt/_factory/)
./ops/bin/dump --scope=core --format=chatgpt --out=auto

# Platform Scope (Opt-in - Keeps opt/_factory/ visible)
./ops/bin/dump --scope=platform --format=chatgpt --out=auto

# Factory Scope (Opt-in - Only opt/_factory/)
./ops/bin/dump --scope=factory --format=chatgpt --out=auto

# Full Scope (Includes projects/ - auto-compressed)
./ops/bin/dump --scope=full --format=chatgpt --out=auto

# Receipt Bundle (Dump + Manifest inside tarball)
./ops/bin/dump --scope=core --out=auto --bundle
~~~

### Scope Taxonomy

The following named scopes define traversal boundaries. Definitions are canonical in `docs/ops/specs/binaries/dump.md`.

- `core`: All tracked text content except `projects/` and `opt/_factory/`. Use for standard operator audit dumps where factory content is not under review.
- `platform`: All tracked text content except `projects/`. Keeps `opt/_factory/` visible. Use when factory surfaces are intentionally included in scope.
- `factory`: Only `opt/_factory/`. Use for targeted factory-only inspection.
- `dp+allowlist` (contractor baseline): Not a traversal scope. Uses `--selection=dp+allowlist` mode. Assembles a bounded file set from canon baseline files, DP-scoped load-order files, and explicit allowlisted additions. Forbidden-prefix behavior (`opt/_factory/`, `storage/handoff/OPEN-`) remains in effect for all contractor-authorized sessions. This is the default contractor context path.

### Factory-Only Audit Recipe and Guardrail Examples

Use factory scope only when factory inspection is intentional. Factory scope is never a contractor baseline.

~~~bash
# Contractor baseline (CDD): DP + allowlist selection (excludes opt/_factory/ by forbidden-prefix policy)
./ops/bin/dump --selection=dp+allowlist --from-dp=auto --format=chatgpt --out=auto

# Core audit (default operator audit baseline): excludes projects/ and opt/_factory/
./ops/bin/dump --scope=core --format=chatgpt --out=auto

# Factory audit (opt-in): only opt/_factory/
./ops/bin/dump --scope=factory --format=chatgpt --out=auto
~~~

When to use:
- Use `--scope=factory` only when reviewing `opt/_factory/` content directly.
- Use `--scope=core` for standard operator audits when factory content is not under review.

Do not use:
- Do not use `--scope=platform` or `--scope=factory` for contractor baseline dumps.
- Contractor baseline dumps must use `--selection=dp+allowlist` with forbidden-prefix enforcement.

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
Pre-dispatch DP finalize gate: run `bash tools/lint/dp.sh <intake-packet>` and confirm PASS (`OK: DP lint passed`). A PASS confirms that the packet is structurally well-formed and that any provisional-value usage matches the canonical draft-time DP contract. No separate finalize step or binary is required.

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
* `ops/src/stances` — Operator stance templates and usage.

### Attachment Contract Table

Attachment contract defaults and profile routing semantics are governed by `ops/lib/manifests/BUNDLE.md`.

| Profile | Bundle Command | Required Attachments | Notes |
| --- | --- | --- | --- |
| `analyst` | `./ops/bin/bundle --profile=analyst --out=auto` | `ANALYST-*.txt`, `ANALYST-*.manifest.json`, `storage/handoff/TOPIC.md` | Analyst reads `TOPIC.md` and emits `PLAN.md`; attach `ANALYST-*.tar` when the model session reliably ingests tar artifacts. |
| `architect` | `./ops/bin/bundle --profile=architect --out=auto` | `ARCHITECT-*.txt`, `ARCHITECT-*.manifest.json`, `storage/handoff/PLAN.md` | PLAN-driven drafting requires Architect Handoff fields in PLAN. |
| `audit` | `./ops/bin/bundle --profile=audit --out=auto` | `AUDIT-*.txt`, `AUDIT-*.manifest.json`, DP RESULTS receipt | Audit stance is PASS/FAIL verdict only. |
| `foreman` | `./ops/bin/bundle --profile=foreman --intent="ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>" --out=auto` | `FOREMAN-*.txt`, `FOREMAN-*.manifest.json` | Addendum authorization intake only; not used for PASS/FAIL verdicts. |
| `project` | `./ops/bin/bundle --profile=project --project=<name> --out=auto` | `PROJECT-*.txt`, `PROJECT-*.manifest.json` | Project-scoped dump context is embedded in the bundle metadata. |
| `conform` | `./ops/bin/bundle --profile=conform --out=auto` | `CONFORM-*.txt`, `CONFORM-*.manifest.json`, draft DP input | Conformist stance normalizes structure without changing intent. |

> **Model-compat fallback:** If tar ingestion is unreliable in a web model context, attach the dump payload (`dump-*.txt`) and dump manifest (`dump-*.manifest.txt`) directly in place of the bundle tar.
> **Legacy compatibility:** During prefix migration, legacy `BUNDLE-*` artifacts may be emitted as compatibility copies when policy flag `compatibility_emit_legacy_bundle_artifacts=true`.
> **Alias sunset window:** Legacy profile alias `hygiene` remains a compatibility route in `sunset` status with removal target `DP-OPS-0165`.
> **front-door contract:** `./ops/bin/bundle` is canonical. `./ops/bin/meta <project-name>` remains a project-only compatibility shim that delegates to `bundle --profile=project`.

### ATS Validation Mode (S8)

Bundle supports optional ATS triplet validation:

~~~bash
./ops/bin/bundle --profile=analyst --agent-id=R-AGENT-01 --skill-id=S-LEARN-08 --task-id=B-TASK-08 --out=auto
~~~

ATS rules:
- `--agent-id`, `--skill-id`, and `--task-id` are all-or-none.
- IDs must match assembly policy patterns and canonical registry IDs.
- Validation fails before artifact emission on malformed or unknown IDs.
- Runtime emits `assembly` metadata in bundle manifest when ATS is applied.
- Runtime emits deterministic `assembly.pointer` metadata and pointer artifact when ATS is applied; non-ATS runs set `assembly.pointer.emitted=false` and emit no pointer artifact.
- `STELA.md` and `SCAFFOLD.md` are advisory-only in this phase and are not gating inputs.

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

### Audit Visibility

Audit visibility is intentionally bounded and documented as an allow/deny contract.
- External reviewer receives: RESULTS receipt and native audit bundle artifacts generated by `./ops/bin/bundle --profile=audit --out=auto` (`AUDIT-*.txt` and `AUDIT-*.manifest.json`; `.tar` optional; legacy `BUNDLE-*` copies may be present during migration).
- External reviewer does not receive by default: CDD artifacts, addendum-authorization bundles (`--profile=foreman`), or contractor-only intake artifacts.
- Evidence surfaces for audit are SoP and PoW entries plus the committed diff, RESULTS, and audit bundle pointers to OPEN and dump artifacts.

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
* **Rule:** Default to `--scope=core` unless the DP explicitly targets a project. Use `--scope=platform` only when `opt/_factory/` visibility is intentionally required. Use `--scope=factory` for targeted factory-only inspection.

---

## 4. Key Paths (Reference)
* **Constitution:** [`../../PoT.md`](../../PoT.md)
* **Active Contract:** [`../../TASK.md`](../../TASK.md)
* **History:** [`../../SoP.md`](../../SoP.md)
* **Artifacts:** `storage/handoff/` (Results), `storage/dumps/` (State).
* **Resume cache:** `var/tmp/` (ephemeral worker scratch).
* **Telemetry:** `logs/` (runtime diagnostics).
* **Archives:** `archives/` (Museum).

### Trace Cookbook
Primary interface: `ops/bin/trace`.
Telemetry callers write leaves at `logs/<caller>-<label>-<stamp>-<trace-digest>.md` and update
`logs/<caller>.telemetry.head` to point at the latest leaf for that caller.

~~~bash
# Run from repository root.
# Latest head pointers per caller (stable placeholder for missing targets)
./ops/bin/trace heads

# Caller list with current head pointer values
./ops/bin/trace callers

# Recent telemetry leaves (default table output includes duration_seconds when known)
./ops/bin/trace recent --limit=30

# Recent leaves in markdown or JSON
./ops/bin/trace recent --limit=5 --format=md
./ops/bin/trace recent --limit=5 --format=json

# Filter by caller slug
./ops/bin/trace by-caller open --limit=10
./ops/bin/trace by-caller verify --limit=10
./ops/bin/trace by-caller certify --limit=10
./ops/bin/trace by-caller prune --limit=10

# Filter by trace identifier (digest computed internally)
./ops/bin/trace by-trace stela-20260227T202038Z-6dd41793
~~~

#### Trace Health Check
~~~bash
./ops/bin/trace health
~~~

~~~bash
bash tools/lint/leaf.sh --health
~~~

`trace health` reports gap findings but exits zero and is safe to run at any
time. `bash tools/lint/leaf.sh --health` exits non-zero when gaps are found and
is suitable for CI or pre-closeout manual gates.

### Prune Pressure Report
~~~bash
./ops/bin/prune --target=storage --phase=report --dry-run
~~~

`--target=storage` is report-only. It emits weighted pressure rows for disposable
runtime artifact classes under `logs/`, `storage/dumps/`, and generated bundle
artifacts under `storage/handoff/` while skipping live protected proof surfaces.

Legacy shell pipelines remain available as secondary reference:

~~~bash
# Latest caller heads
find logs -maxdepth 1 -type f -name '*.telemetry.head' -print | sort | while IFS= read -r head; do
  caller="${head#logs/}"
  caller="${caller%.telemetry.head}"
  leaf=""
  IFS= read -r leaf < "$head" || true
  if [ -n "$leaf" ]; then
    printf '%s\t%s\n' "$caller" "$leaf"
  fi
done

# Grep by trace id (set TRACE_ID first)
TRACE_ID="replace-with-trace-id"
find logs -maxdepth 1 -type f -name '*.md' -print | sort | while IFS= read -r leaf; do
  grep -nH -m 1 -F "trace_id: ${TRACE_ID}" "$leaf" || true
done

# Recent certify + lint activity (sorted by filename stamp token)
find logs -maxdepth 1 -type f \( -name 'certify-*.md' -o -name 'lint-*.md' \) -print \
| awk -F'[-/]' '{ stamp=$(NF-1); print stamp "\t" $0 }' \
| sort -k1,1 -k2,2 \
| tail -n 30 \
| cut -f2-
~~~
