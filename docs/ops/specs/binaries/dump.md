# Technical Specification: ops/bin/dump

## Technical Specifications
- Deterministic Selection: uses `git ls-files` to select tracked files for dumping.
- Scope Controls: supports `--scope=platform|full|project` and requires `--target=<slug>` for project scope.
- Refiners: supports `--include-dir`, `--exclude-dir`, and `--ignore-file` filters after scope selection.
- Output Control: supports `--out=auto|path`, `--compress=tar.xz`, and `--bundle` for receipt-ready archives.
- Binary Handling: supports `--include-binary=meta|raw|base64`, defaulting to metadata only.
- Manifest: emits a manifest file alongside the dump payload for receipt tracking.

## Requirements
- Must run from the repository root with git available on PATH.
- Requires `PoT.md`, `SoP.md`, `TASK.md`, and the `docs/`, `tools/`, `ops/`, and `.github/` directories to exist.
- Requires `storage/dumps/` and `storage/handoff/` to be writable.

## Usage
- `./ops/bin/dump --scope=platform --format=chatgpt`
- `./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle`
- `./ops/bin/dump --scope=project --target=example-project --format=chatgpt`

## Forensic Insight
`ops/bin/dump` is the Observer. It forces a deterministic, auditable snapshot into the context window, preventing hidden files or untracked artifacts from reshaping the governance narrative.
