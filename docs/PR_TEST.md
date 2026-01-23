# PR workflow quick test

Use this to verify your local setup and your understanding of governance.

## Goal

Create a **documentation-only** PR that passes repo-gates.

## Steps

1. Create a work branch:
   - `Team → Git → Branch → Create Branch…`
   - Example: `work/docs-pr-workflow-test-YYYY-MM-DD`

2. Make a tiny docs change (safe):
   - Edit `docs/ops/INDEX.md` (add a bullet or fix a typo)

3. Review the diff:
   - `Team → Show Changes`

4. Commit:
   - Message: `docs: PR workflow test`

5. Run gates locally:
   - `bash tools/verify_tree.sh`
   - `bash tools/lint_truth.sh`

6. Push the branch and open a PR on GitHub.

7. Confirm CI gates pass, then merge.

If any step is confusing, capture a screenshot and ask for help.
