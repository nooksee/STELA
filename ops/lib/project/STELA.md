<!-- CCD: ff_target="operator-technical" ff_band="35-50" -->
# {{DISPLAY_NAME}} Project Contract

Project ID: {{PROJECT_ID}}
Created: {{CREATED_AT}}
Authority: advisory. `PoT.md` and the active packet remain the authority; this contract narrows a contractor's attention inside `projects/{{PROJECT_ID}}/` and never widens it.

## Purpose
State what the project is for in one short paragraph: the payload it holds, who runs it, and what done looks like.

## Target Root
`projects/{{PROJECT_ID}}/`. A project packet names the files under this root that it may change; everything outside the root belongs to the platform and needs its own packet.

## Bindings
Factory definitions this project may invoke, by identifier as the registries spell them (`R-AGENT-NN`, `B-TASK-NN`, `S-LEARN-NN`), one per line, or `none`. `tools/lint/project.sh` rejects an identifier the registries do not define.
- none

## Entrypoints
The commands or files a session opens first, one per line, with the directory each lives in.
- none

## Allowed Commands
The commands a contractor may run inside the target root (build, test, lint, serve), one per line. A command outside this list is a packet decision, not a contractor decision.
- none

## Conventions
Code organization, style, testing, and security rules that hold for this payload. Keep each rule to one line; point at a file under the root for anything longer.
- none

## Session Classes
A trusted full-access collaborator session may edit this file through a packet that names it. A repo-resident project contractor session reads it and works under the `dp+allowlist` worker baseline inside the target root; `docs/MANUAL.md` names both classes.
