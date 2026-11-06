<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/src/runbook/gemini.yaml` defines the operator-deployed Gemini adapter for Stela research sessions. Gemini has no repository access in the operator's setup, so the adapter exists to keep a research session inside its lane: current-turn attachments are its only local truth, it synthesizes and cross-checks sources, and it proposes no repo edits, authoritative plans, or local-state claims.

## Mechanics and Sequencing
1. The adapter source lives in `ops/src/runbook/gemini.yaml`; status is `active` as of version 2.0.0; the intended role is `research`, not architect or audit.
2. Deployment is manual: the operator pastes `instruction_text` into the Gem instructions of the research Gem.
3. Source proof is operator-visible Gem instruction text or screenshot.
4. Functional proof is behavior-based:
   - current-turn attachments outrank stale thread context,
   - no claim of having inspected files, branches, diffs, logs, or runtime behavior,
   - no redundant clarification when attachments and thread context settle the scope,
   - dense markdown that leads with conclusions and states evidence basis, assumptions, unknowns, and confidence,
   - no synthetic citation tokens, fake references, meta-process lists, or filler,
   - off-topic requests redirected to the research objective.
5. Research output is advisory. It carries no repository authority and enters the repository only through a packet an Integrator drafts and a Worker executes.
6. A bounded question to this adapter lands at `storage/handoff/CONSULT-gemini.md` in the consult envelope of `docs/ops/specs/surfaces/consult.md` (header `### CONSULT gemini <date>`, sections C.1 to C.7), validated by `bash tools/lint/response.sh --mode=consult` before it is read for a decision. The operator records the disposition (`adopt`, `adapt`, `reject`) in the RESULTS narrative of the packet the consult fed, or in that packet's `op` leaf when the consult changed its scope, and never in SoP.md; the artifact itself stays disposable and uncommitted.

## Anecdotal Anchor
RUNBOOK-03 first carried an experimental Gemini adapter for architect and audit roles with no instruction text; DP-OPS-0188 retired it with the other dead Gemini references (`--format=gemini` in `ops/bin/dump` and `ops/bin/open`). DP-OPS-0267 reintroduced the identifier for a different job, research synthesis, with the directive text the operator already runs.

## Integrity Filter Warnings
Presence of the YAML file does not prove deployment. A research adapter must not be handed audit bundles or dispatch packets; the stance templates for those lanes remain `ops/src/stances/*.md.tpl`. Retire or narrow the adapter after two consecutive clean validation rounds.
