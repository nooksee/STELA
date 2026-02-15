# Technical Specification: ops/lib/scripts/task.sh

## Constitutional Anchor
`ops/lib/scripts/task.sh` governs task artifact lifecycle under a pointer-first model.
It is the automation boundary for drafting, validating, and promoting reusable task instructions while preserving context hazard rules.

## Operator Contract
- Invocation:
  - `ops/lib/scripts/task.sh harvest --id B-TASK-XX --name "..." --objective "..." [--dp "DP-OPS-XXXX"]`
  - `ops/lib/scripts/task.sh promote <draft_path> [--delete-draft]`
  - `ops/lib/scripts/task.sh check`
- Required files:
  - `opt/_factory/TASKS.md`
  - `docs/ops/registry/TASKS.md`
  - `TASK.md`
  - `ops/lib/manifests/CONTEXT.md`
- Key directories:
  - Drafts: `storage/archives/tasks/`
  - Canon tasks: `opt/_factory/tasks/`
- Exit behavior:
  - `0` on success.
  - `1` on command/validation failure.

Harvest contract:
- Requires task ID format `B-TASK-[0-9]{2,}` and unique registry ID.
- Requires non-placeholder objective and DP values.
- Writes redacted draft file and appends Candidate Log entry in `opt/_factory/TASKS.md`.

Promote contract:
- Validates draft schema, required pointers, and final closeout step.
- Rewrites `# Task Draft:` to `# Task:`.
- Writes canon task file at `opt/_factory/tasks/<ID>.md`.
- Upserts registry row in `docs/ops/registry/TASKS.md`.
- Appends Promotion Log entry in `opt/_factory/TASKS.md`.

Check contract:
- Fails if tasks are referenced in `ops/lib/manifests/CONTEXT.md`.
- Runs `bash tools/lint/task.sh` for full schema validation.

## Failure States and Drift Triggers
- Missing required ledger/registry/manifest files.
- Duplicate task ID in registry during harvest.
- Placeholder or missing draft fields.
- Invalid or missing required sections in draft.
- Missing required pointers in draft (`PoT.md`, `docs/GOVERNANCE.md`, `TASK.md`).
- Missing final Closeout pointer to `TASK.md` Section 3.5.
- Ambiguous draft auto-selection when multiple drafts share same timestamp.
- Registry insertion/update failure.
- Context hazard detected during `check`.

## Mechanics and Sequencing
1. Parse command and validate required dependencies.
2. `harvest` sequence:
- Validate ID/name/objective/DP inputs.
- Generate provenance block (from heuristics  when available).
- Emit draft template with required sections.
- Redact known secret token classes.
- Append candidate log record.
3. `promote` sequence:
- Resolve draft path (explicit path or latest candidate).
- Validate draft schema and closeout step.
- Materialize canon task file and registry row.
- Append promotion log record.
- Optionally delete draft.
4. `check` sequence:
- Enforce context hazard exclusion.
- Delegate deep validation to `tools/lint/task.sh`.

Subsystem invariants:
- Task lifecycle is append-log driven (`Candidate Log`, `Promotion Log`).
- Registry is the authoritative index for task IDs and canonical paths.
- Promotion never bypasses validation gates.

## Forensic Insight
The task lifecycle script is both a generator and a control surface.
It narrows drift by forcing explicit provenance and closeout routing at draft time, then re-validating before promotion so canonical task instructions remain executable and audit-safe.
