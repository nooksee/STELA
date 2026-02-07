# Technical Specification: ops/bin/open

## Technical Specifications
- Freshness Gate: captures `git rev-parse --abbrev-ref HEAD`, `git rev-parse --short HEAD`, and `git status --porcelain`.
- Dirty State Capture: writes `storage/handoff/OPEN-PORCELAIN-<tag>-<branch>-<hash>.txt` when the working tree is dirty.
- Intent Injection: injects `--intent` and `--dp` into the prompt header.
- Canon Injection: lists PoT, TASK, SoP, and other canon pointers in the OPEN artifact.
- Output Artifact: writes `storage/handoff/OPEN-<tag>-<branch>-<hash>.txt` and optionally echoes the path when `--out=auto` is used.

## Requirements
- Must run from the repository root with git available on PATH.
- Requires `PoT.md`, `SoP.md`, `TASK.md`, `docs/INDEX.md`, `docs/MANUAL.md`, `docs/MAP.md`, and `ops/lib/manifests/CONTEXT.md` to exist.
- Requires the `storage/handoff/` directory to be writable.

## Usage
- `./ops/bin/open --intent="DP execution" --dp="DP-OPS-0028 / 2026-02-06"`
- `./ops/bin/open --out=auto --tag=dp-ops-0028`

## Forensic Insight
`ops/bin/open` is the Timekeeper. By freezing the active branch, commit hash, and porcelain state at session start, it creates a verifiable checkpoint that prevents stale or hallucinated state from entering the control plane.
