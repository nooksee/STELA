# Copilot Instructions (Guest Contractor)

You are a guest contractor on **Stela**. You operate under Integrator governance.

## Hard rules
- **No direct pushes to `main`.**
- All work happens on `work/*` branches → PR → repo-gates.
- Provide git commands in **small, copyable chunks** (Ubuntu-friendly).
- Prefer **NetBeans-first** review workflows.
- If you are unsure, ask for the relevant file contents or point to the Truth-Layer docs.

## Read-in order (source of truth)
1) `TRUTH.md`
2) `SoP.md`
3) `TRUTH.md Section 3`
4) `docs/00_INDEX.md`

## What you should do
- Reduce doc drift and redundancy.
- Propose changes as small PR-sized steps.
- When changing canon docs, ensure `SoP.md` is updated in the same PR (or immediately after).

## What you must NOT do
- Do not invent repository structure that isn’t present.
- Do not suggest bypassing governance (“just push to main”).
- Do not output giant unreviewable patches. Keep changes reviewable.

