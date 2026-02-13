# Binary Registry

Authoritative registry for `ops/bin/*` entrypoints.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| OPS-BIN-01 | Context Snapshot | ops/bin/context | Spec: `docs/ops/specs/binaries/context.md`. Captures OPEN and DUMP artifacts into one context archive. |
| OPS-BIN-02 | Dump | ops/bin/dump | Spec: `docs/ops/specs/binaries/dump.md`. Serializes repository state into receipt payloads and manifests. |
| OPS-BIN-03 | Help | ops/bin/help | Spec: `docs/ops/specs/binaries/help.md`. Surfaces operational docs and wayfinding pointers. |
| OPS-BIN-04 | LLMS Bundler | ops/bin/llms | Spec: `docs/ops/specs/binaries/llms.md`. Generates scope bundles and root llms outputs. |
| OPS-BIN-05 | MAP Generator | ops/bin/map | Spec: `docs/ops/specs/binaries/map.md`. Refreshes the auto-generated MAP index block. |
| OPS-BIN-06 | Open | ops/bin/open | Spec: `docs/ops/specs/binaries/open.md`. Produces session-state OPEN artifacts with freshness details. |
| OPS-BIN-07 | Project | ops/bin/project | Spec: `docs/ops/specs/binaries/project.md`. Project lifecycle entrypoint driven by project registry and templates. |
| OPS-BIN-08 | Prune | ops/bin/prune | Spec: `docs/ops/specs/binaries/prune.md`. Cleans local artifacts and performs DP-targeted scrub workflows. |
