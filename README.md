<!-- CCD: ff_target="discovery" ff_band="30-50" -->
# STELA

## Purpose
STELA is a repository that governs its own agents. One constitution, `PoT.md`, binds every role; every change enters through a dispatch packet, every closeout leaves a receipt under `archives/`, and the gates refuse what the policy forbids.

## Structure
`ops/` runs (binaries, manifests, automation), `docs/` explains, `opt/` isolates definitions and research records, `projects/` holds work payloads, `storage/`, `var/tmp/`, and `logs/` hold runtime state, and `archives/` holds the ledger leaves. `docs/MAP.md` is the generated map of all of it.

## Entry Point
Start with `llms.txt`, the machine-readable index, then `docs/INDEX.md`, the curated front door. A working session starts with `./ops/bin/open --out=auto` and follows the procedure in `docs/MANUAL.md`.

## Constraints
`PoT.md` is the final authority on every scope, and no parallel jurisdiction exists. Work happens on `agent/*` branches through dispatch packets; `main` takes merges only; `.github/workflows/gates.yml` runs on every pull request and every push to `main`.

## Canonical Pointer
`PoT.md`, then the four one-line heads `SoP.md`, `PoW.md`, `TASK.md`, and `RoR.md`, each pointing at its current leaf under `archives/`.

## Where to Look Next
- `docs/MANUAL.md` for the command workflow and closeout routing.
- `docs/RESEARCH.md` for the research that preceded the packets and what current main does with it.
- `docs/ops/README.md` for the runtime kernel, its registries, and its specifications.

[![gates](https://github.com/nooksee/STELA/actions/workflows/gates.yml/badge.svg)](https://github.com/nooksee/STELA/actions/workflows/gates.yml)
