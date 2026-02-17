# Technical Specification: tools/verify.sh

## Constitutional Anchor
`tools/verify.sh` enforces repository hygiene under PoT Filing Doctrine boundaries.
It validates that run surfaces, explain surfaces, and work payload surfaces remain in their prescribed locations.

## Operator Contract
- Invocation:
  - `./tools/verify.sh`
- Exit behavior:
  - `0` when no hard failures exist (warnings allowed).
  - `1` on one or more hard failures.
- Runtime assumptions:
  - Executed inside a git repository.
  - `file` utility available for binary encoding checks.

Filing Doctrine mapping:
- `docs/` = Explain:
  - Must contain markdown only.
  - Must not contain binary artifacts.
- `ops/` = Run:
  - Markdown is restricted to governed manifest/project subpaths.
- `storage/` = Payload:
  - Must contain expected payload subdirectories (`handoff`, `dumps`, `dp`).
  - Unexpected clutter is warned for cleanup.
- `var/tmp/` = Resume:
  - Must exist with a tracked `.gitkeep` placeholder.
- `logs/` = Telemetry:
  - Must exist with a tracked `.gitkeep` placeholder.
- `archives/` = Cold:
  - Must contain required subroots (`root`, `tasks`, `skills`, `agents`, `context`) with tracked `.gitkeep` placeholders.
- `projects/` = Work:
  - Project folders should contain `README.md` payload anchors.

## Failure States and Drift Triggers
Hard failures:
- Missing required root directories (`ops`, `docs`, `opt`, `tools`, `projects`, `.github`, `storage`, `var`, `logs`, `archives`).
- Missing required storage payload directories (`storage/handoff`, `storage/dumps`, `storage/dp`).
- Missing required runtime directories (`var/tmp`, `logs`).
- Missing required archive subdirectories (`archives/surfaces`, `archives/definitions`, `archives/definitions`, `archives/definitions`, `archives/manifests`).
- Missing required runtime/archive `.gitkeep` placeholders.
- Binary files present in `docs/`.
- Non-markdown files present in `docs/`.
- Markdown files in disallowed `ops/` locations.

Warnings:
- Unexpected top-level items under `storage/`.
- Project directories missing `README.md`.

## Mechanics and Sequencing
1. Resolve repository root via git.
2. Validate platform skeleton directories.
3. Validate required payload and runtime directories (`storage/*`, `var/tmp`, `logs`, `archives/*`).
4. Validate required `.gitkeep` placeholders for ignored runtime and archive roots.
5. Scan storage root for payload drift warnings.
6. Run filing doctrine checks:
- Binary detection for all `docs/` files.
- Markdown-only enforcement for `docs/`.
- Restricted markdown locations under `ops/`.
7. Run project shape warning checks.
8. Print summary status with explicit error and warning counts.

Repository hygiene guarantees:
- Ensures docs remain explain-only and parse-safe.
- Prevents silent binary ingress into canon docs.
- Prevents markdown drift into ad hoc locations under run surfaces.
- Preserves minimum platform directory contract for tooling.

## Forensic Insight
`tools/verify.sh` is the static hygiene baseline for every closeout.
It catches structural drift that lints focused on content semantics cannot see, which makes it the first proof that repository topology still matches constitutional filing boundaries.
