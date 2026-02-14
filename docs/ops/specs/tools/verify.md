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
- `storage/` = Trash:
  - Must contain expected hygiene subdirectories.
  - Unexpected clutter is warned for cleanup.
- `projects/` = Work:
  - Project folders should contain `README.md` payload anchors.

## Failure States and Drift Triggers
Hard failures:
- Missing required root directories (`ops`, `docs`, `tools`, `projects`, `.github`).
- Missing required storage runtime directories (`storage/handoff`, `storage/dumps`, `storage/tmp`).
- Binary files present in `docs/`.
- Non-markdown files present in `docs/`.
- Markdown files in disallowed `ops/` locations.

Warnings:
- Unexpected top-level items under `storage/`.
- Project directories missing `README.md`.

## Mechanics and Sequencing
1. Resolve repository root via git.
2. Validate platform skeleton directories.
3. Validate required storage subdirectories.
4. Scan storage root for hygiene drift warnings.
5. Run filing doctrine checks:
- Binary detection for all `docs/` files.
- Markdown-only enforcement for `docs/`.
- Restricted markdown locations under `ops/`.
6. Run project shape warning checks.
7. Print summary status with explicit error and warning counts.

Repository hygiene guarantees:
- Ensures docs remain explain-only and parse-safe.
- Prevents silent binary ingress into canon docs.
- Prevents markdown drift into ad hoc locations under run surfaces.
- Preserves minimum platform directory contract for tooling.

## Forensic Insight
`tools/verify.sh` is the static hygiene baseline for every closeout.
It catches structural drift that lints focused on content semantics cannot see, which makes it the first proof that repository topology still matches constitutional filing boundaries.
