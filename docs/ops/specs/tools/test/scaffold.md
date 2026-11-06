<!-- CCD: ff_target="operator-technical" ff_band="40-55" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Project Lane Contract Test

## First Principles Rationale
`ops/bin/scaffold` does three jobs in one call: the project tree, the two file copies with their tokens resolved, and the registry row. A binary that writes three places must be proved as one transaction, including every refusal that happens before the first write, and that proof must not touch the live `projects/` directory or the live registry.

## Mechanics and Sequencing
The test copies the working tree (tracked and unignored untracked files) into a fresh repository under `var/tmp/_smoke/` and commits a baseline, so the binaries and lints run as they are against an empty `projects/` directory. Four cases:
1. `./ops/bin/scaffold demo-app` succeeds; `SCAFFOLD.md`, `STELA.md`, and the four optional directories exist; neither copy carries an unresolved `{{` token; the contract names the project id and states advisory authority; the registry has the row and its `Current:` line reads `demo-app`; the output names the contract path.
2. `./ops/bin/map` regenerates, the map lists the project, `./ops/bin/map --check` passes, and `bash tools/lint/project.sh` accepts the contract.
3. A second scaffold of the same name and an invalid name both fail closed, and the registry still holds one row for the name.
4. A name that has a registry row but no directory is refused before any write; no directory appears.
The fixture is removed at exit. The test runs as the `project-lane-contract` lane of `ops/etc/verification.manifest` (packet-local, `full` and `gates` modes).

## Anecdotal Anchor
DP-OPS-0273 gave `ops/bin/scaffold` the contract copy and the registry row under the Operator's delegated decision (DECISIONS.md item 8: one tool, three jobs); the test landed with the change so the three jobs were never proved by hand alone.

## Integrity Filter Warnings
The copy is about 50 MB because the research records are tracked, and the whole run takes about two seconds. The test proves the current working tree, not a committed snapshot, so it belongs in the packet that changes the binary. It does not exercise `bundle --profile=project`, which `tools/test/bundle.sh` owns.
