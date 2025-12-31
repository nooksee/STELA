# Contributing

Welcome. nukeCE is an explainability-first, provenance-forward CMS program.
That means we care about *how we know what we know*, not just “it works on my machine.” 🙂

## Non-negotiables (the house rules)

- **No direct pushes to `main`.** Work happens on `work/*` branches → PR → merge.
- **Repo gates must pass.** If `repo-gates` is red, we fix the branch — we don’t merge and hope.
- **Upstreams are donors, not identity.** We preserve upstream snapshots as read-only.
- **Imports require receipts.** Anything brought in must include provenance notes in `docs/upstreams.md`.

## Where changes belong

- `public_html/` — deployable webroot (what the server serves)
- `src/` — nukeCE core development (primary)
- `packages/` — extracted/imported features adapted into nukeCE
- `upstream/` — read-only upstream snapshots (do not edit)
- `docs/` — architecture, ops, governance, release process
- `scripts/` — build/sync/release tooling

## The workflow (do this every time)

1. **Create a branch**
   - Name format: `work/<topic>-YYYY-MM-DD`
   - Examples:
     - `work/readme-philosophy-2025-12-31`
     - `work/module-x-cleanup-2025-12-31`

2. **Make changes**
   - Keep the scope tight.
   - Prefer small commits with clear messages.

3. **Run the repo gates (or let CI run them)**
   - If it fails, fix it on the branch.

4. **Open a PR**
   - Describe *why* and *what changed*.
   - Link provenance notes if relevant.

5. **Merge only when green**
   - If CI is red, merging is forbidden (even if it “probably works”).

## Commit message vibe

Keep it boring and specific:

- `docs: clarify release steps`
- `chore: ignore NetBeans private settings`
- `ci: add repo gates (verify_tree + lint_truth)`

If you can’t summarize the change in one sentence, the PR is probably too big.

## IDE notes (NetBeans)

NetBeans may generate local metadata under `nbproject/`.
Private settings (especially `nbproject/private/*`) should **never** be committed.
If you see them in Git changes, that’s usually a sign your ignore rules need tuning.
