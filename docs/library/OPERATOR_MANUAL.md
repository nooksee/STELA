# Operator Manual (Curated)

This manual is the operator-facing entrypoint for day-to-day commands and the curated docs library.
It is intentionally short and maintained; if it drifts, fix it.

**Canon spelling:** `Stela` (normalize voice-to-text variants before approving/merging).

---

## Top Commands (cheat sheet)

~~~bash
# 1) OPEN (prints + always writes a handoff copy)
./ops/bin/open --intent="short-intent" --dp="DP-XXXX / YYYY-MM-DD"
./ops/bin/open --intent="short-intent" --dp="DP-XXXX / YYYY-MM-DD" --tag=boot --out=auto

# 2) DUMP (stdout by default; use --out=auto to write to storage/dumps/)
./ops/bin/dump --scope=platform --format=chatgpt
./ops/bin/dump --scope=platform --format=chatgpt --out=auto
./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
./ops/bin/dump --scope=full --format=chatgpt --out=auto   # auto-compresses to tar.xz when full+out=auto
./ops/bin/dump --scope=platform --format=chatgpt --out=auto --compress=tar.xz

# 3) HELP (front door for curated docs)
./ops/bin/help
./ops/bin/help continuity
~~~

---

## What exists where (paths you’ll reference constantly)

**Canon / required by OPEN tooling (must exist from repo root):**
- `TRUTH.md` — constitution + invariants (SSOT + filing doctrine)
- `TASK.md` — DP contract + living work surface/log
- `SoP.md` — history ledger (what shipped, when, why)
- `AGENTS.md` — agent roles/expectations
- `docs/INDEX.md` — docs map / entry index
- `docs/library/OPERATOR_MANUAL.md` — this file
- `docs/library/CONTINUITY_MAP.md` — continuity wayfinding
- `ops/lib/manifests/CONTEXT_MANIFEST.md` — what “counts as context” + lint targets

**Untracked operator/worker artifacts (never commit these):**
- `storage/handoff/` — OPEN outputs + worker RESULTS receipts (attach from here)
- `storage/dumps/` — dump outputs / archives (attach from here)

---

## Staffing and logic (pointer-first)

- Roles: Operator (human), Integrator (lead AI), Contractor (guest AI).
- `AGENTS.md` is the jurisdiction spec for roles, AI constraints, and stop conditions.

---

## Platform vs Project (scope sanity)

- **Platform** = repo-resident operating system (`ops/`, `docs/`, `tools/`, governance files).
- **Project payloads** live under `projects/*`.
- During platform construction, default to **platform scope** (exclude project payload).

---

## OPEN

- `./ops/bin/open` prints the copy-safe Open Prompt with the freshness gate + canon pointers.
- It **always** writes the OPEN text to:  
  `storage/handoff/OPEN-<tag>-<branch>-<HEAD>.txt`
- It **always** writes porcelain to:  
  `storage/handoff/OPEN-PORCELAIN-<tag>-<branch>-<HEAD>.txt`
- `--out=auto` adds a trailing convenience line (`OPEN saved: <path>`) after printing.

Paste delimiter (when pasting raw results into chat): `---`

---

## DP workflow (mechanical loop)

1) Run `open` (or attach OPEN artifacts if already generated).  
2) Run `dump` (choose `--scope=platform` for platform work; `--scope=full` only when needed).  
3) Ask for a DP (or DP revision) referencing `TASK.md` as the template/SSOT.  
4) Create/switch to the DP’s branch (operator-controlled).  
5) Hand DP to worker; worker executes.  
6) Worker returns REQUIRED OUTPUT + RECEIPT (proof bundle).  
7) Operator decides: whether to diasapprove (with patch steps) or approve.  
8) If disapproves: re-dispatch patch; worker re-runs verification + regenerates receipt.  
9) Merge.  
10) Ensure merge-gated canon updates (e.g., `SoP.md`, `TASK.md` log append) are present.

---

## DP lint (dp_lint.sh)

Use the DP lint to validate Dispatch Packet shape before dispatching.

~~~bash
./tools/dp_lint.sh --test
./tools/dp_lint.sh path/to/DP.md
./tools/dp_lint.sh - < path/to/DP.md
bash tools/dp_lint.sh storage/handoff/<DP-ID>.md
~~~

Notes:
- Lint is mechanical; it enforces the current TASK.md DP headings/order and required fields.
- It should fail on non-DP documents.

DP file placement (operator):
- Draft DPs live under `storage/dp/intake/`.
- Move or copy completed DPs to `storage/dp/processed/` (untracked).
- Workers lint against the local DP file path, for example: `./tools/dp_lint.sh storage/dp/intake/DP-OPS-0008.md`.

---

## Dump refiners (guardrail)

Dump refiners (`--include-dir`, `--exclude-dir`, `--ignore-file`) are allowed only when explicitly justified in the DP.
When used, the DP must include this fallback line:

`Fallback: ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle`

Narrow dumps should be explicit and minimal. Examples:

~~~bash
./ops/bin/dump --scope=platform --format=chatgpt --out=auto --include-dir=docs/library --exclude-dir=projects
./ops/bin/dump --scope=platform --format=chatgpt --out=auto --ignore-file=.gitignore
~~~

---

## When to DISAPPROVE

- Missing proof bundle required by `TASK.md`.
- Missing RECEIPT or missing results file.
- Forbidden path touched or scope mismatch.
- Verification missing or failed.
- Claims don’t match diffs/stat.

---

## Branch protection

Enable branch protection on `main` in GitHub settings.

---

## What workers must return (SSOT: `TASK.md`)

Use `TASK.md` for the required worker outputs, proof bundle items, and RESULTS headings.
This manual expects a results file under `storage/handoff/<DP-ID>-RESULTS.md` and receipt pointers to OPEN + DUMP artifacts.

---

## Dump

`./ops/bin/dump` emits a repo dump (stdout by default). Use `--out=auto` to write into `storage/dumps/`.

Scopes:
- `--scope=platform` (default; excludes `projects/*`)
- `--scope=full` (full repo scope)
- `--scope=project --target=<slug>` (platform + one project payload)

Archive output:
- `--compress=tar.xz` requires `--out`.
- `--bundle` implies tar.xz output and bundles dump + manifest.

Auto-compress default:
- For `--scope=full` with `--out=auto` and no explicit `--compress`, `--compress=tar.xz` is assumed.

---

## Help

`./ops/bin/help` is the operator front door for curated docs.
- `./ops/bin/help` shows the command menu and quick start.
- `./ops/bin/help <term>` searches `docs/` with line numbers.
