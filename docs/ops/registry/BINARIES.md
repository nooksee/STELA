# Binary Registry

Authoritative registry for `ops/bin/*` entrypoints.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| OPS-BIN-01 | Context Session Stream | ops/bin/context | Spec: `docs/ops/specs/binaries/context.md`. Wrapper over `ops/lib/scripts/synthesize.sh`; defaults to OPS layer and injects OPEN session state. |
| OPS-BIN-02 | Dump | ops/bin/dump | Spec: `docs/ops/specs/binaries/dump.md`. Serializes repository state into receipt payloads and manifests. |
| OPS-BIN-03 | Help | ops/bin/help | Spec: `docs/ops/specs/binaries/help.md`. Surfaces operational docs and wayfinding pointers. |
| OPS-BIN-04 | LLMS Bundler | ops/bin/llms | Spec: `docs/ops/specs/binaries/llms.md`. Wrapper over `ops/lib/scripts/synthesize.sh`; writes only `llms.txt`, `llms-core.txt`, and `llms-full.txt`. |
| OPS-BIN-05 | MAP Generator | ops/bin/map | Spec: `docs/ops/specs/binaries/map.md`. Refreshes the auto-generated MAP index block. |
| OPS-BIN-06 | Open | ops/bin/open | Spec: `docs/ops/specs/binaries/open.md`. Produces session-state OPEN artifacts with freshness details. |
| OPS-BIN-07 | Project | ops/bin/project | Spec: `docs/ops/specs/binaries/project.md`. Project lifecycle entrypoint driven by project registry and templates. |
| OPS-BIN-08 | Prune | ops/bin/prune | Spec: `docs/ops/specs/binaries/prune.md`. Cleans local artifacts and performs DP-targeted scrub workflows. |
| OPS-BIN-09 | Manifest Compiler | ops/bin/compile | Spec: `docs/ops/specs/binaries/compile.md`. Compiles manifest templates from `ops/src/manifests/` into deterministic explicit outputs in `ops/lib/manifests/`. |
| OPS-BIN-10 | Template Renderer | ops/bin/template | Spec: `docs/ops/specs/binaries/template.md`. Renders `.tpl` surfaces/definitions with frontmatter parsing, include injection, and strict slot validation. |
| OPS-BIN-11 | Certifier | ops/bin/certify | Spec: `docs/ops/specs/binaries/certify.md`. Runs integrity and receipt verification gates, then renders and validates DP RESULTS artifacts; intake fallback is explicit-only via `--allow-intake-fallback`. |
