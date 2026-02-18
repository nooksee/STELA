### DP-OPS-0070: Phase 1 TraceID and definition-leaf schema gates

## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0070-2026-02-17
Base HEAD: b8221099
Freshness Stamp: 2026-02-17

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

### 3.2.2 DP-scoped load order (per DP)
Worker must load, in order:
1. docs/ops/specs/binaries/open.md
2. docs/ops/specs/binaries/certify.md
3. docs/ops/specs/scripts/agent.md
4. docs/ops/specs/scripts/task.md
5. docs/ops/specs/scripts/skill.md
6. docs/ops/registry/LINT.md
7. ops/bin/open
8. ops/bin/certify
9. ops/bin/template
10. ops/lib/scripts/agent.sh
11. ops/lib/scripts/task.sh
12. ops/lib/scripts/skill.sh
13. ops/src/definitions/agent.md.tpl
14. ops/src/definitions/task.md.tpl
15. ops/src/definitions/skill.md.tpl
16. tools/lint/style.sh
17. tools/lint/integrity.sh
18. tools/lint/results.sh
19. tools/lint/schema.sh (NEW; created in this DP)
20. docs/ops/specs/tools/lint/schema.md (NEW; created in this DP)

## 3.3 Scope and Safety
Objective:
Implement Phase 1 of the Distributed Index-Leaf Filing Paradigm by introducing session TraceID capture, provenance schema front-matter for definition drafts, a schema lint gate, and a certify telemetry leaf pattern in logs/ without any HEAD-pointer cutover on canon surfaces.

In scope:
- Add STELA_TRACE_ID generation to ops/bin/open and record it in the OPEN prompt artifact.
- Resolve STELA_TRACE_ID for ops/bin/certify (prefer environment, fallback to latest OPEN artifact) and emit a telemetry leaf into logs/ with a reverse-link pointer.
- Extend agent, task, and skill definition templates to include the unified leaf schema keys: trace_id, packet_id, created_at, previous.
- Populate the new template slots from ops/lib/scripts/agent.sh, ops/lib/scripts/task.sh, and ops/lib/scripts/skill.sh during harvest; maintain a per-slug reverse-link chain in archives/definitions using previous.
- Add tools/lint/schema.sh to validate unified schema front-matter presence and previous format for archives/definitions outputs (ignored runtime leaves).
- Document and register the new behavior in the appropriate specs and registries.

Out of scope:
- Phase 2: PoW.md and SoP.md leaf emission, single-line HEAD pointer cutover, and any rewrite of canon surfaces to HEAD pointers.
- Phase 3: ops/bin/compile manifest leaf snapshots in archives/manifests.
- Phase 4: tools/test/graph_walk.sh and any graph-walk integration into tools/verify.sh.
- Any changes to pruning semantics beyond existing docs/MANUAL.md closeout guidance.
- Any manual edits to generated artifacts under storage/handoff, storage/dumps, logs, or archives.
- Any structural edits to TASK.md beyond inserting this DP content at the correct location.

Safety and invariants:
- no manual edits to generated outputs (OPEN artifacts, dump artifacts, RESULTS artifacts, CLOSING sidecars, logs leaves, archives leaves).
- no structural edits to TASK/DP (preserve canonical section numbering and ordering).
- allowlist hard gate: update storage/dp/active/allowlist.txt before modifying any other tracked file; keep the list literal, explicit, and complete.
- No commits on main; all work is on the required work branch.
- No new paths outside the Changelog (except those marked NEW in this DP).

Worker Constraints (SSOT injected):
## Constraints (Sections 1 and 2)

### Section 1 — Structural and Behavioral Constraints
- No inventions. Use repository files as SSOT and stop if required inputs are missing.
- No contractions anywhere (for example: do not, cannot, will not).
- No globs. No wildcard paths. No brace expansion.
- No structural edits to TASK or DP format. Preserve section numbering and ordering.
- No manual edits to generated outputs (OPEN, dump, RESULTS, CLOSING, compiled bundles).
- No references to disposable artifacts inside authored surfaces (do not cite OPEN or dump contents).

### Section 2 — Safety and Scope Gates
- Stay within DP scope. If scope conflict arises, stop and request operator resolution.
- Obey allowlist hard gate: only modify files listed in storage/dp/active/allowlist.txt.
- Do not introduce new top-level platform directories.
- If lints fail, fix root cause; do not bypass.

Target Files allowlist (hard gate):
- storage/dp/active/allowlist.txt

## 3.4 Execution Plan (A-E)

### 3.4.1 State
- OPEN artifact indicates base branch main at Base HEAD b8221099 with a clean working tree at time of state refresh.
- Dump artifacts (platform scope) are available for file-level inspection of main at b8221099; no payload text is to be pasted into DP or canon surfaces.
- Platform skeleton already includes logs/ and archives/ roots, with .gitignore configured to ignore runtime leaf outputs under logs/* and archives/* while retaining required .gitkeep placeholders.
- ops/bin/open, ops/bin/certify, and ops/bin/template exist and are active, with certify enforcing integrity and results lints.
- tools/lint/schema.sh does not exist yet; no unified-schema linter is currently registered in docs/ops/registry/LINT.md.
- Definition templates under ops/src/definitions already use YAML front-matter for template metadata; this DP will extend that same front-matter block with the unified leaf schema keys.

### 3.4.2 Request
Implement Phase 1 (TraceID and Telemetry) as follows:
- Introduce a session TraceID generated by ops/bin/open and persisted in the OPEN artifact for downstream parsing.
- Ensure agent, task, and skill harvest flows emit definition drafts whose YAML front-matter includes trace_id, packet_id, created_at, and previous.
- Add a schema linter that validates the required front-matter keys and previous formatting for archives/definitions leaf files.
- Update certify to emit a logs/ telemetry leaf that follows the unified schema and chains via a reverse-link pointer file in logs/.
- Update documentation (specs) and registries so the behavior is discoverable and auditable.
- Maintain strict allowlist discipline and pass all baseline gates and lints.

### 3.4.3 Changelog
UPDATE:
- storage/dp/active/allowlist.txt
- storage/dp/intake/DP-OPS-0070.md
- ops/bin/open
- docs/ops/specs/binaries/open.md
- ops/bin/certify
- docs/ops/specs/binaries/certify.md
- ops/lib/scripts/agent.sh
- docs/ops/specs/scripts/agent.md
- ops/lib/scripts/task.sh
- docs/ops/specs/scripts/task.md
- ops/lib/scripts/skill.sh
- docs/ops/specs/scripts/skill.md
- ops/src/definitions/agent.md.tpl
- ops/src/definitions/task.md.tpl
- ops/src/definitions/skill.md.tpl
- docs/ops/registry/LINT.md
- ops/lib/manifests/OPS.md

NEW:
- tools/lint/schema.sh
- docs/ops/specs/tools/lint/schema.md

### 3.4.4 Patch / Diff
A. Allowlist hard gate
1. Edit storage/dp/active/allowlist.txt to include every file in the Changelog (UPDATE and NEW), one path per line, exact and literal.
2. Do not proceed to any other tracked file edit until allowlist is updated.

B. ops/bin/open: TraceID generation and persistence
1. Update ops/bin/open to generate a STELA_TRACE_ID value per invocation.
   - Generation must be local, non-interactive, and stable-format (UTC timestamp + random hex suffix is acceptable).
2. Include the TraceID in the emitted OPEN prompt body (for example, under Freshness Gate or in a dedicated Trace section) so it is persisted inside storage/handoff/OPEN-*.txt.
3. Ensure any additional stdout lines that are not part of the OPEN artifact remain outside the emit pipeline (preserve the existing rule that the final “OPEN saved:” line is not appended into the OPEN artifact).
4. Update docs/ops/specs/binaries/open.md to document:
   - STELA_TRACE_ID generation.
   - Where it appears in the OPEN prompt.
   - The contract that downstream tools may parse it from the latest OPEN artifact when the environment variable is absent.

C. Definition templates: unified schema keys added to existing YAML front-matter
1. Update ops/src/definitions/agent.md.tpl:
   - Add YAML keys trace_id, packet_id, created_at, previous to the existing front-matter block.
   - Add requires_slots entries for TRACE_ID, PACKET_ID, CREATED_AT, PREVIOUS.
2. Update ops/src/definitions/task.md.tpl similarly.
3. Update ops/src/definitions/skill.md.tpl similarly.
4. Ensure the template engine continues to parse required slots and includes without regression.

D. Harvest scripts: populate schema slots and maintain reverse-link chain
1. Update ops/lib/scripts/agent.sh harvest flow:
   - Resolve a trace_id value in this priority order: STELA_TRACE_ID environment variable, then parse from the selected OPEN artifact, then generate a local fallback.
   - Compute created_at as an ISO-8601 UTC timestamp with Z suffix.
   - Determine previous as the latest existing definition draft in archives/definitions for the same slug (if present), else (none).
   - Pass TRACE_ID, PACKET_ID (dp_id), CREATED_AT, PREVIOUS into render_definition_template for the agent template.
2. Update ops/lib/scripts/task.sh harvest flow with the same schema-slot behavior (TRACE_ID, PACKET_ID, CREATED_AT, PREVIOUS).
3. Update ops/lib/scripts/skill.sh harvest flow with the same schema-slot behavior (TRACE_ID, PACKET_ID, CREATED_AT, PREVIOUS).
4. Update docs/ops/specs/scripts/agent.md, docs/ops/specs/scripts/task.md, and docs/ops/specs/scripts/skill.md to document:
   - The unified schema front-matter keys included in produced drafts.
   - TraceID resolution priority (environment first, OPEN artifact fallback).
   - The meaning of previous and the (none) origin case.

E. tools/lint/schema.sh: new unified schema linter for archives/definitions
1. Create tools/lint/schema.sh (NEW) as an executable bash script that:
   - Scans archives/definitions for candidate markdown files (excluding archives/definitions/.gitkeep).
   - For each file found, verifies the first YAML front-matter block contains keys: trace_id, packet_id, created_at, previous.
   - Validates created_at is ISO-8601 UTC with Z suffix.
   - Validates previous is either (none) or a repository-relative path with a .md suffix.
   - Emits clear, actionable failure messages and exits non-zero on the first failure.
2. Add docs/ops/specs/tools/lint/schema.md (NEW) documenting:
   - Purpose, scope, and schema expectations.
   - What it scans and what it ignores.
   - Failure modes and operator actions.
3. Update docs/ops/registry/LINT.md to add:
   - LINT-12 | Schema Lint | tools/lint/schema.sh | Spec: docs/ops/specs/tools/lint/schema.md.

F. ops/bin/certify: establish logs/ leaf pattern
1. Update ops/bin/certify to emit a telemetry leaf in logs/ on successful completion (after RESULTS lint passes).
2. Telemetry leaf requirements:
   - File written under logs/ with a deterministic, collision-resistant name that includes dp id and a UTC timestamp.
   - YAML front-matter keys: trace_id, packet_id, created_at, previous.
   - previous resolves from a tool-local head pointer file under logs/ (if present), else (none).
   - After writing the leaf, update the head pointer file in logs/ to reference the newly-written leaf path.
3. TraceID resolution in certify must be: STELA_TRACE_ID environment variable first, otherwise parse from the latest OPEN artifact under storage/handoff.
4. Update docs/ops/specs/binaries/certify.md to document the logs/ telemetry leaf emission and chaining.

G. Final gates
1. Ensure storage/dp/active/allowlist.txt remains complete and accurate for all modified and new tracked files.
2. Run the Receipt command sequence in order and address any failures by fixing root causes (no bypass).

### 3.4.5 Receipt (Proofs to collect) - MUST RUN
- ./ops/bin/open --out=auto --dp="DP-OPS-0070 / 2026-02-17"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto
- git status --porcelain
- bash tools/verify.sh
- bash tools/lint/context.sh
- bash tools/lint/truth.sh
- bash tools/lint/llms.sh
- bash tools/lint/factory.sh
- bash tools/lint/style.sh
- bash tools/lint/agent.sh
- bash tools/lint/task.sh
- bash tools/lint/dp.sh
- bash tools/lint/schema.sh
- ./ops/bin/certify --dp="DP-OPS-0070" --out=auto
- ls -la storage/handoff/DP-OPS-0070-RESULTS.md
- bash tools/lint/results.sh storage/handoff/DP-OPS-0070-RESULTS.md

## 3.5 Closeout (Mandatory Routing)
- Execute docs/MANUAL.md Closeout Cycle in order (Verify, Harvest, Refresh, Log, Prune).
- Update SoP.md and PoW.md with DP entries, including objective summary and verification commands run.
- Protocol order for closeout: Verify -> Generate Results -> COMMIT (Operator Only) -> Prune.
- Run prune hygiene at the end of the closeout sequence: ./ops/bin/prune --dp=DP-OPS-0070 --scrub.
- Use ./ops/bin/prune --reset-task only for explicit TASK baseline reset after PoW entry exists for the active DP id.
- Ensure the next session begins with refreshed session artifacts and matching receipts.

### 3.5.1 Mandatory Closing Block
Primary Commit Header (plaintext)

Pull Request Title (plaintext)

Pull Request Description (markdown)

Final Squash Stub (plaintext) (Must differ from #1)

Extended Technical Manifest (plaintext)

Review Conversation Starter (markdown)
