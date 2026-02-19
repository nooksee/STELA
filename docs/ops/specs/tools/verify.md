# Technical Specification: tools/verify.sh

## Purpose
Enforce repository hygiene under filing doctrine boundaries and validate factory chain entry-point reachability.

## Invocation
- Command: `./tools/verify.sh`
- Exit behavior:
  - `0` when no hard failures exist (warnings allowed).
  - `1` on one or more hard failures.

## Core hygiene checks
- Required platform directories exist (`ops`, `docs`, `opt`, `tools`, `projects`, `.github`, `storage`, `var`, `logs`, `archives`).
- Required payload/runtime subdirectories and `.gitkeep` placeholders exist.
- `docs/` contains markdown-only, non-binary surfaces.
- `ops/` markdown placement obeys filing doctrine constraints.
- `storage/` drift is reported as warnings.
- Project directories missing `README.md` are warned.

## Factory head reachability checks
- Validates existence of:
  - `opt/_factory/AGENTS.md`
  - `opt/_factory/TASKS.md`
  - `opt/_factory/SKILLS.md`
- Validates reachability for all six entry points:
  - `opt/_factory/AGENTS.md` `candidate:`
  - `opt/_factory/AGENTS.md` `promotion:`
  - `opt/_factory/TASKS.md` `candidate:`
  - `opt/_factory/TASKS.md` `promotion:`
  - `opt/_factory/SKILLS.md` `candidate:`
  - `opt/_factory/SKILLS.md` `promotion:`

Pointer validity rules:
- Origin sentinels ending with `-(origin)` are accepted.
- Non-origin pointers must resolve to existing files under `archives/definitions/`.

## Related pointers
- Registry entry: `docs/ops/registry/TOOLS.md`.
- Adjacent structural gate: `tools/lint/factory.sh`.
