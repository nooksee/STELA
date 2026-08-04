<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/llms` exists to keep machine discovery entry points synchronized with current manifest truth. It prevents SSOT drift where root `llms` bundles reference outdated manifest memberships or stale synthesis output while keeping receipt-facing success output aligned with the repo-relative path discipline used elsewhere in Stela.

## Mechanics and Sequencing
The binary parses optional out directory and manifest override arguments, enforces repo-root execution, validates dependencies, and runs `ops/bin/compile` before synthesis. It synthesizes `llms-core.txt` from the core manifest and `llms-full.txt` from the discovery manifest into a temporary workspace, verifies both generated files are non-empty, and constructs `llms.txt` with the `content-v1` identity plus SHA-256 identities for both bundle bodies. Commit hashes and commit timestamps are excluded because a tracked pre-commit artifact cannot truthfully contain the identity of the commit that will contain it. Normal mode copies all three outputs to repository root and optionally mirrors them to a non-root `--out-dir`. Before success-path rendering, repo-root `--out-dir` variants are canonicalized so values such as `/repo/` and `/repo///` collapse back to the same root target.

`--check` first invokes `ops/bin/compile --check`, regenerates all three llms outputs in temporary storage, and compares them byte-for-byte with the root bundle set. It accepts no output or manifest overrides, writes tracked files `0` times, and fails on any compiled-manifest or root-bundle mismatch. Because identity is content-derived, an unchanged tree remains valid across the proposed commit and accepted merge commit; any source or manifest change that affects generated content invalidates parity. `--test` exercises identical, mismatched, missing, and content-identity cases without changing tracked files.

## Deprecated Filename Guard
Before writing bundle outputs, `ops/bin/llms` checks the repository root for deprecated slice filenames: `llms-small.txt`, `llms-ops.txt`, and `llms-governance.txt`. The check runs after synthesis and non-empty output validation but before any bundle copy step. If any deprecated filename exists, the binary exits non-zero with an error identifying the offending path and does not write refreshed bundle files.

## Anecdotal Anchor
A recurring risk in AI-driven intake was that discovery pointers could remain static while manifest state changed underneath them. A pre-commit HEAD label also described the parent commit rather than the candidate or eventual merge. Content identity plus read-only parity checking closes both defects without claiming a commit identity that cannot exist yet.

## Integrity Filter Warnings
`ops/bin/llms` exits on unknown, duplicate, or incompatible arguments; missing dependencies or manifests; compile-check failures; empty synthesized output; content-identity mismatch; missing root bundles; or write failure. Normal mode retains its existing refresh behavior. Check and test modes are read-only with respect to tracked files.
