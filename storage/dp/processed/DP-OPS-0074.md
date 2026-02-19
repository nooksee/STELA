### DP-OPS-0074: Factory Chain Remediation

## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0074-2026-02-18
Base HEAD: 45af651e
Freshness Stamp: 2026-02-18

Required local re-check (worker runs; paste outputs in RESULTS):
- git rev-parse --abbrev-ref HEAD
- git rev-parse --short HEAD
- git status --porcelain

Preconditions:
- No commits on main.
- Working tree must be clean before execution begins.
- If Base HEAD changes, regenerate session artifacts from canonical tools before proceeding.

STOP conditions:
- STOP if any mismatch (branch, Base HEAD, missing work branch).
- STOP if working tree is dirty before execution begins.
- STOP if told to create or switch branches.

## 3.1.1 DP Preflight Gate (Run Before Any Edits)
Purpose:
- Catch malformed DP or TASK schema before work begins.

Worker runs (paste outcome in RESULTS):
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh

STOP if any preflight check fails.

## 3.2 Required Context Load (Read Before Doing Anything)

### 3.2.1 Must-Read Canon (Exact Order)

1. `PoT.md`
2. `SoP.md`
3. `PoW.md`
4. `TASK.md`
5. `docs/MANUAL.md`
6. `docs/MAP.md`
7. `ops/lib/manifests/CONTEXT.md`

### 3.2.2 DP-Scoped Load Order (Minimum Set)

1. `opt/_factory/AGENTS.md`
2. `opt/_factory/TASKS.md`
3. `opt/_factory/SKILLS.md`
4. `ops/lib/scripts/agent.sh`
5. `ops/lib/scripts/task.sh`
6. `ops/lib/scripts/skill.sh`
7. `tools/lint/factory.sh`
8. `tools/verify.sh`
9. `docs/ops/specs/scripts/agent.md`
10. `docs/ops/specs/scripts/task.md`
11. `docs/ops/specs/scripts/skill.md`
12. `docs/ops/specs/tools/lint/factory.md`
13. `docs/ops/specs/tools/verify.md`
14. `docs/ops/registry/SCRIPTS.md`
15. `docs/INDEX.md`

## 3.3 Scope and Safety

Objective:
- Normalize factory registries to pointer-first heads for agent, task, and skill candidate and promotion chains, and align scripts, lints, and docs so Phase 4 entry points are explicit and verifiable.

In scope:
- Migrate definition registry guidance out of `opt/_factory/AGENTS.md`, `opt/_factory/TASKS.md`, `opt/_factory/SKILLS.md` into three new specs under `docs/ops/specs/definitions/`.
- Rewrite `opt/_factory/AGENTS.md`, `opt/_factory/TASKS.md`, `opt/_factory/SKILLS.md` to four-line pointer heads (candidate, promotion, spec, registry) using the specified sentinel head values.
- Update `ops/lib/scripts/agent.sh`, `ops/lib/scripts/task.sh`, `ops/lib/scripts/skill.sh` to:
  - Emit candidate and promotion leaf files under `archives/definitions/` with Unified Schema front-matter.
  - Advance the appropriate HEAD pointers by rewriting the relevant line in the factory head files.
  - Treat `-(origin)` head values as origin sentinels and emit `previous: (none)` in leaf front-matter for origin emissions.
- Update `tools/lint/factory.sh` to enforce:
  - Four-line pointer format for the three factory head files.
  - Resolvable spec and registry pointers.
  - Candidate and promotion head validity (origin sentinel or reachable leaf file).
- Update `tools/verify.sh` to include reachability validation for all six factory head entry points (candidate and promotion for agents, tasks, skills).
- Update documentation and registries:
  - `docs/ops/specs/scripts/agent.md`, `docs/ops/specs/scripts/task.md`, `docs/ops/specs/scripts/skill.md`
  - `docs/ops/specs/tools/lint/factory.md`
  - `docs/ops/specs/tools/verify.md`
  - `docs/ops/registry/SCRIPTS.md`
  - `docs/INDEX.md`
  - `docs/MANUAL.md`
- Update `.gitignore` to unignore the six new definition leaf naming patterns under `archives/definitions/` so future candidate and promotion leaves are committable.

Out of scope:
- Emitting or backfilling any new leaf files in `archives/definitions/` as part of this DP.
- Modifying the Unified Schema linter semantics beyond what is required to keep existing behavior intact.
- Building Phase 4 graph-walk tooling beyond the reachability checks added to `tools/verify.sh`.
- Any changes outside the allowlisted file set, including other registries, other factory surfaces, or non-target scripts.

Safety and invariants:
- No manual edits to generated outputs, including any content produced by `./ops/bin/certify`, `./ops/bin/template`, or other generation steps.
- No structural edits to `TASK.md` or the DP section structure. Only content edits inside the planned patch files are permitted.
- Allowlist hard gate: all tracked mutations must be explicitly allowlisted in `storage/dp/active/allowlist.txt` before running verification.
- No pattern-paths, globs, or brace expansions in commands or file references in this DP. Paths must be literal.
- If any required file is missing, any lint fails unexpectedly, or scope expansion is required, STOP and request Operator action.

Worker Constraints (SSOT injected):

- Stop if any instructions are ambiguous or incomplete. Request clarification from the Operator.
- Do not invent paths, files, APIs, flags, or tools that are not present in the repository state.
- Use only repository-provided scripts and documented commands. Do not add new tooling unless explicitly in scope and allowlisted.
- Do not hand-edit generated artifacts. Generated artifacts must only be produced by their generators.
- Do not modify protected directories or governance artifacts unless explicitly allowlisted.
- No globbing, brace expansion, or pattern paths in command invocations. Use literal paths.
- Maintain repository style requirements, including no contractions in committed text.
- Keep edits minimal and scoped to the changelog and allowlist.
- Update `storage/dp/active/allowlist.txt` before running any verification commands that may surface new tracked changes.
- Do not include OPEN or dump payloads in committed files. Reference them only via the canonical generation workflow.

Target Files allowlist (hard gate):
- `storage/dp/active/allowlist.txt`

## 3.4 Execution Plan (A-E)

### 3.4.1 State

- Base branch: `main`
- Required work branch: `work/dp-ops-0074-2026-02-18`
- Base HEAD: `45af651e`
- Scope focus: Factory chain entry points for agents, tasks, and skills; scripts, lints, verify, and documentation alignment.

### 3.4.2 Request

Implement factory head normalization and remediation across six definition chains:
- Create three new specs under `docs/ops/specs/definitions/` and relocate definition registry guidance from the three `opt/_factory/*.md` head files into those specs.
- Rewrite `opt/_factory/AGENTS.md`, `opt/_factory/TASKS.md`, `opt/_factory/SKILLS.md` to pointer-first four-line heads with candidate and promotion sentinels plus spec and registry pointers.
- Update the three harvester scripts to:
  - Read current candidate or promotion head from the corresponding factory head file.
  - Emit a new leaf under `archives/definitions/` with Unified Schema front-matter:
    - `trace_id`: from `STELA_TRACE_ID`
    - `packet_id`: from `STELA_PACKET_ID` (expected to be the active DP id during DP work)
    - `created_at`: UTC timestamp
    - `previous`: the prior head, mapped to `(none)` when the head is the origin sentinel
  - Rewrite the head line in the factory file to the new leaf path.
- Update verification:
  - `tools/lint/factory.sh` must validate the new pointer heads and reachability expectations.
  - `tools/verify.sh` must validate reachability for all six head entry points.
- Update docs, registries, and indexes so the new spec location is discoverable and scripts documentation reflects the new behavior.
- Update `.gitignore` so the new definition leaves are not ignored and can be committed.

### 3.4.3 Changelog

UPDATE:
- `.gitignore`
- `opt/_factory/AGENTS.md`
- `opt/_factory/TASKS.md`
- `opt/_factory/SKILLS.md`
- `ops/lib/scripts/agent.sh`
- `ops/lib/scripts/task.sh`
- `ops/lib/scripts/skill.sh`
- `tools/lint/factory.sh`
- `tools/verify.sh`
- `docs/ops/specs/scripts/agent.md`
- `docs/ops/specs/scripts/task.md`
- `docs/ops/specs/scripts/skill.md`
- `docs/ops/specs/tools/lint/factory.md`
- `docs/ops/specs/tools/verify.md`
- `docs/ops/registry/SCRIPTS.md`
- `docs/INDEX.md`
- `docs/MANUAL.md`
- `storage/dp/active/allowlist.txt`
- `PoW.md` (generated by `./ops/bin/certify`, do not hand edit)
- `SoP.md` (generated by `./ops/bin/certify`, do not hand edit)
- `TASK.md` (generated by `./ops/bin/certify`, do not hand edit)

NEW:
- `docs/ops/specs/definitions/agents.md`
- `docs/ops/specs/definitions/tasks.md`
- `docs/ops/specs/definitions/skills.md`
- `archives/surfaces/PoW-2026-02-18-45af651e.md` (generated by `./ops/bin/certify`, do not hand edit)
- `archives/surfaces/SoP-2026-02-18-45af651e.md` (generated by `./ops/bin/certify`, do not hand edit)
- `archives/surfaces/TASK-DP-OPS-0074-45af651e.md` (generated by `./ops/bin/certify`, do not hand edit)

### 3.4.4 Patch/Diff (Implementation Steps, Exact Files)

A. NEW file placeholders, then allowlist hard gate
1. Create directory and placeholder files:
   - Create directory: `docs/ops/specs/definitions/`
   - Create empty files:
     - `docs/ops/specs/definitions/agents.md`
     - `docs/ops/specs/definitions/tasks.md`
     - `docs/ops/specs/definitions/skills.md`
2. Update `storage/dp/active/allowlist.txt` to include exactly the files in the changelog (UPDATE and NEW), including the three deterministic surface leaves listed above.
3. Run: `bash tools/lint/dp.sh TASK.md`
4. Run: `bash tools/lint/integrity.sh`

B. Git ignore update for definition leaves
1. Update `.gitignore` to unignore the following six patterns under `archives/definitions/`:
   - `archives/definitions/agent-candidate-????-??-??-*.md`
   - `archives/definitions/agent-promotion-????-??-??-*.md`
   - `archives/definitions/task-candidate-????-??-??-*.md`
   - `archives/definitions/task-promotion-????-??-??-*.md`
   - `archives/definitions/skill-candidate-????-??-??-*.md`
   - `archives/definitions/skill-promotion-????-??-??-*.md`

C. Definition spec migration and index wiring
1. Migrate and split the definition registry guidance from:
   - `opt/_factory/AGENTS.md` to `docs/ops/specs/definitions/agents.md`
   - `opt/_factory/TASKS.md` to `docs/ops/specs/definitions/tasks.md`
   - `opt/_factory/SKILLS.md` to `docs/ops/specs/definitions/skills.md`
2. Update discovery pointers:
  - Update `docs/INDEX.md` to include pointers to the new definition specs.
   - Update `docs/MANUAL.md` to include pointers to the new definition specs as the authoritative reference for definition registry guidance.

D. Factory head normalization
1. Rewrite `opt/_factory/AGENTS.md` to exactly:
   - `candidate: archives/definitions/agent-candidate-(origin)`
   - `promotion: archives/definitions/agent-promotion-(origin)`
   - `spec: docs/ops/specs/definitions/agents.md`
   - `registry: docs/ops/registry/AGENTS.md`
2. Rewrite `opt/_factory/TASKS.md` to exactly:
   - `candidate: archives/definitions/task-candidate-(origin)`
   - `promotion: archives/definitions/task-promotion-(origin)`
   - `spec: docs/ops/specs/definitions/tasks.md`
   - `registry: docs/ops/registry/TASKS.md`
3. Rewrite `opt/_factory/SKILLS.md` to exactly:
   - `candidate: archives/definitions/skill-candidate-(origin)`
   - `promotion: archives/definitions/skill-promotion-(origin)`
   - `spec: docs/ops/specs/definitions/skills.md`
   - `registry: docs/ops/registry/SKILLS.md`

E. Harvester script updates (schema-stamped leaf emission and head advancement)
1. Update `ops/lib/scripts/agent.sh`:
   - Replace ledger append behavior with pointer-head advancement behavior.
   - On candidate emission:
     - Read `candidate:` value from `opt/_factory/AGENTS.md`.
     - If value ends with `-(origin)`, set leaf front-matter `previous: (none)`. Otherwise set `previous:` to the current head path.
     - Emit leaf file: `archives/definitions/agent-candidate-YYYY-MM-DD-<short-hash>.md`.
     - Rewrite `candidate:` in `opt/_factory/AGENTS.md` to the new leaf path.
   - On promotion emission:
     - Same approach for `promotion:` and `agent-promotion-YYYY-MM-DD-<short-hash>.md`.
   - Prepend Unified Schema front-matter block to emitted leaves with `trace_id`, `packet_id`, `created_at`, `previous`.
2. Update `ops/lib/scripts/task.sh` with the parallel candidate and promotion logic for `opt/_factory/TASKS.md` and `task-(candidate|promotion)` leaves.
3. Update `ops/lib/scripts/skill.sh` with the parallel candidate and promotion logic for `opt/_factory/SKILLS.md` and `skill-(candidate|promotion)` leaves.
4. Ensure emitted leaf files still include the existing template-rendered definition content and that the schema front-matter is prepended above the definition body.

F. Lint and verify remediation
1. Update `tools/lint/factory.sh` to validate:
   - Each of `opt/_factory/AGENTS.md`, `opt/_factory/TASKS.md`, `opt/_factory/SKILLS.md` has exactly four lines with keys `candidate`, `promotion`, `spec`, `registry`.
   - `spec:` targets exist and match the expected new spec paths.
   - `registry:` targets exist and point to the expected registry files.
   - `candidate:` and `promotion:` values are either:
     - An origin sentinel ending with `-(origin)`, or
     - A resolvable file path under `archives/definitions/` that exists.
2. Update `tools/verify.sh` to add reachability checks for:
   - `opt/_factory/AGENTS.md` candidate and promotion heads
   - `opt/_factory/TASKS.md` candidate and promotion heads
   - `opt/_factory/SKILLS.md` candidate and promotion heads
   Origin sentinels must be accepted; non-origin heads must resolve to existing leaf files.
3. Update documentation for the new behavior:
   - Update `docs/ops/specs/scripts/agent.md`, `docs/ops/specs/scripts/task.md`, `docs/ops/specs/scripts/skill.md` to reflect:
     - Leaf emission targets `archives/definitions/`
     - Head advancement via factory head files
     - Removal of append-to-ledger behavior
   - Update `docs/ops/specs/tools/lint/factory.md` to document the new factory head invariants and checks.
   - Update `docs/ops/specs/tools/verify.md` to document the added reachability checks.
4. Update `docs/ops/registry/SCRIPTS.md` to reflect the updated behaviors of the three harvester scripts.

G. Post-patch sanity (no commits)
1. Run: `bash tools/lint/integrity.sh`
2. Run: `bash tools/lint/factory.sh`
3. Run: `./tools/verify.sh`
4. Run: `bash tools/lint/schema.sh`
5. Run: `bash tools/lint/style.sh`
6. Run: `bash tools/lint/context.sh`

### 3.4.5 Receipt (Verification Commands, Deterministic Order)

The following command list is executed via `./ops/bin/certify` during closeout. Do not hand assemble RESULTS.

1. `./ops/bin/open --out=auto --dp="DP-OPS-0074"`
2. `./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
3. `./ops/bin/map --check`
4. `./ops/bin/llms`
5. `bash tools/lint/llms.sh`
6. `./tools/verify.sh`
7. `bash tools/lint/factory.sh`
8. `bash tools/lint/schema.sh`
9. `bash tools/lint/style.sh`
10. `bash tools/lint/context.sh`
11. `bash tools/lint/agent.sh`
12. `bash tools/lint/task.sh`
13. `bash tools/lint/skill.sh`
14. `bash tools/lint/truth.sh`

## 3.5 Closeout (Mandatory Routing)

1. Ensure the working tree reflects only allowlisted changes and all lints are passing locally (or are ready to be executed by certify).
2. Maintain the closeout sidecar:
   - Create or update `storage/handoff/CLOSING-DP-OPS-0074.md` before RESULTS generation.
3. Generate RESULTS (mandatory, do not hand author):
   - Run: `./ops/bin/certify --dp="DP-OPS-0074" --out=auto`
4. Validate generated RESULTS:
   - Run: `bash tools/lint/results.sh storage/handoff/DP-OPS-0074-RESULTS.md`
5. Operator-only steps (do not perform as Contractor):
   - Review diff, ensure scope is satisfied, and commit with the required header and contents recorded below.
   - Do not run destructive pruning operations as part of this DP unless the Operator explicitly directs and the resulting tracked changes remain within the allowlist and receipt evidence.

### 3.5.1 Mandatory Closing Block
Primary Commit Header (plaintext)

Pull Request Title (plaintext)

Pull Request Description (markdown)

Final Squash Stub (plaintext) (Must differ from #1)

Extended Technical Manifest (plaintext)

Review Conversation Starter (markdown)
