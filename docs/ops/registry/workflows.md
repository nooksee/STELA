<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Workflow Registry

Authoritative registry for GitHub Actions workflows under `.github/workflows/`.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| WORKFLOW-01 | Gates | .github/workflows/gates.yml | Spec: `docs/ops/specs/workflows/gates.md`. Triggers: every pull request; every push to `main`. Steps: pointer reachability; `tools/verify.sh` (gates mode on pull requests, full mode on `main`); truth, schema, style, context, LLMS, hooks, help, agent, factory, DP, RESULTS, leaf. Outermost enforcement boundary; local hooks are opt-in, CI is not. |
