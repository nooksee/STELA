<!-- CCD: ff_target="discovery" ff_band="30-50" -->
# projects/

## Purpose
This directory is the Work lane: payload code lives here, one project per folder, outside the platform surfaces that `ops/`, `docs/`, and `tools/` own.

## Structure
`projects/<name>/` holds one project. The scaffold spec `SCAFFOLD.md` and the project contract `STELA.md` sit at its root; the optional directories come from `ops/lib/project/SCAFFOLD.md`. The directory holds no project today, and `docs/ops/registry/projects.md` says `Current: none`.

## Entry Point
1. Scaffold it: `./ops/bin/scaffold <name>` (lowercase letters, digits, and hyphens). It creates `projects/<name>/` with the optional directories listed in `ops/lib/project/SCAFFOLD.md`, writes `SCAFFOLD.md` and the contract `STELA.md` from the two source files with the project id and date resolved, and adds the registry row to `docs/ops/registry/projects.md`. It refuses a name that already has a directory or a row.
2. Fill the contract: edit `projects/<name>/STELA.md` (purpose, target root, bindings, entrypoints, allowed commands, conventions). `docs/MAP.md` lists a project only when this file exists; `bash tools/lint/project.sh` rejects any `R-AGENT-`, `B-TASK-`, or `S-LEARN-` identifier in it that the registries do not define.
3. Regenerate the map: `./ops/bin/map`, so the generated map and the registry agree; `./ops/bin/map --check` reports drift.
4. Ship context: `./ops/bin/bundle --profile=project --project=<name> --out=auto` emits the project bundle; `./ops/bin/meta <name>` is the compatibility shim for the same call.

Allowlist rows and packet drafting stay manual. There is no `ops/bin/project`; it was retired in DP-OPS-0145 (`docs/ops/specs/binaries/project.md`).

## Constraints
- Do not edit project payloads unless a Dispatch Packet names them in scope.
- `STELA.md` and `SCAFFOLD.md` are advisory until the first project contract is ratified by a packet; the Policy of Truth and the active packet remain the authority (`docs/MANUAL.md`, Session Classes and ATS Validation Mode).
- Worker baseline context is `dp+allowlist`; `opt/_factory/` is never project baseline context.

## Canonical Pointer
`docs/ops/registry/projects.md` is the registry of record; `docs/MAP.md` is generated from it and from the `STELA.md` files it finds.

## Where to Look Next
- `ops/lib/project/README.md` for the source files the lane binaries read.
- `docs/ops/specs/binaries/scaffold.md` and `docs/ops/specs/binaries/bundle.md` for the two binaries.
- `docs/MAP.md` section 5 for why a project is a payload under PoT and not a separate tier.
