### Addendum A to DP-OPS-0264

## A.1 Authorization
Operator Authorization:
On 2026-11-04 the Operator chose "Addendum A to DP-OPS-0264" in answer to the boundary report "ADDENDUM REQUIRED: DP-OPS-0264 - certify postflight step 25 carries a second dual-scope check that rejects the current-run compile leaf". The Operator authorizes extending the packet by the three exact paths below: the certify binary and its spec so the compile-leaf rule applies in ops/bin/certify as it does in tools/lint/integrity.sh, and the Operator decision leaf that records this authorization and the preflight exception. No other scope changes.

Base Packet: DP-OPS-0264
Addendum ID: A

## A.2 Scope Delta
Exact paths added by this addendum (one per line; no globs; no brace expansion):
ops/bin/certify
docs/ops/specs/binaries/certify.md
archives/decisions/RoR-2026-11-04-002-op-0264.md

## A.3 Addendum Objective
- Apply the current-run compile-leaf rule inside the certify postflight changed-file dual-scope check (function verify_changed_files_subset_allowlist), mirroring tools/lint/integrity.sh: untracked, canonical name, hash prefix equal to the current HEAD.
- Report the exempted count as "Current-run compile leaves" in the check output and describe the rule in docs/ops/specs/binaries/certify.md.
- Replay the base packet proofs under this addendum so the combined RESULTS leaf carries every receipt.

## A.4 Context Load

## Rules

1 Temp path rule uses `var/tmp` only
2 RESULTS generation rule uses `ops/bin/certify` only
3 Receipt rule runs every DP mandated command and treats any skip as STOP
4 Disposable artifact rule treats OPEN dump bundles and manifests as non canonical session artifacts
5 Use repo-relative paths only in all output. Never print absolute filesystem paths. Do not emit clickable file links.

Worker Constraints (SSOT injected):
## Section 1: Universal Template Rules
- Template source uses `tpl` files with optional YAML frontmatter
- Canon frontmatter keys: `template_type` `template_id` `template_version` `requires_slots` `includes`
- Renderer strips frontmatter before output write
- Slot token form `\{\{TOKEN\}\}` with uppercase alphanumeric underscore
- Include forms `\{\{@include:path\}\}` and `\{\{@include:path#section\}\}`
- Include resolution is strict: missing file fail missing section fail circular graph fail
- Strict mode default: every required slot value present and no unresolved token
- Non strict mode allowed only for lint and normalization workflows
- Worker facing generated surfaces remain pointer first and exclude disposable artifacts

## A.5 Addendum Receipt (Proofs to collect) - MUST RUN

**Mandatory receipt commands (always run; do not omit):**
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/integrity.sh
- bash tools/lint/style.sh
- git diff --name-only
- git diff --stat
- comm -23 <(git diff --name-only | sort) <(sort storage/dp/active/allowlist.txt) || true
- comm -23 <(git ls-files --others --exclude-standard | sort) <(sort storage/dp/active/allowlist.txt) || true
- ./ops/bin/open

**Addendum-specific receipt commands:**
- bash tools/lint/dp.sh --test
- bash tools/test/dp.sh
- bash tools/test/integrity.sh
- bash tools/lint/truth.sh
- bash tools/lint/schema.sh
- ./ops/bin/llms
- bash tools/lint/integrity.sh
- ./ops/bin/template render closing --out=var/tmp/closing-render-check.md --slot=DP_ID=DP-OPS-0264
- grep -c Confirm var/tmp/closing-render-check.md
- bash tools/verify.sh --mode=full
- git diff --exit-code -- ops/bin/compile ops/bin/llms ops/lib/scripts/common.sh storage/dp/active/allowlist.txt PoT.md
- git diff --check