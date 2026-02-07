# Policy of Truth (PoT)

## Preamble: Doctrine
The system prevents action that violates policy. It does not request compliance.
PoT is the single constitutional document for Stela governance.

## 1. Physical Laws

### 1.1 Filing Doctrine
Filing:
- `ops/` = Run (binaries, manifests, automation).
- `docs/` = Explain (manuals and rationale).
- `projects/` = Work (payload code).
- `storage/` = Trash (local artifacts, never canon).

### 1.2 Axioms
- Precedence: PoT is final authority; if conflict exists, stop and ask.
- SSOT: one canonical file per domain; other mentions are pointers.
- Reuse-first: search `ops/` for an existing template before creating a new artifact.
- Context Hazard: any inclusion of `docs/library/agents`, `docs/library/tasks`, or `docs/library/skills` in the global context manifest is a failure.
- Drift: any divergence between canon and repository state, or duplication of canon outside SSOT, is a failure state that requires stop and correction.
- SoP: history ledger only; no permanent rules live there.

### 1.3 Canon Surfaces
- `PoT.md` — constitution, staffing, jurisdiction, and enforcement (SSOT).
- `TASK.md` — active work surface and DP contract.
- `SoP.md` — history ledger and shipment record.
- `docs/MANUAL.md` — operator mechanics.
- `docs/MAP.md` — context wayfinding.
- `ops/lib/manifests/CONTEXT.md` — required context set.
- `llms.txt` — discovery entry point.

## 2. Enforcement
Integrator plus Automation (linters, repo-gates, and binaries).
Mandate:
- Stop work.
- Reject PRs.
- Kill processes.
Triggers:
- Any PoT violation or canon drift.
- Context hazard in the global manifest.
- Scope breach or forbidden zone access.

## 3. Jurisdiction
Scope: `ops/`, `docs/`, `projects/`, `tools/`, `.github/`, and root governance surfaces.
Law: PoT is the sole authority across all scopes. No parallel jurisdictions exist.

## 4. Staffing & Logic

### 4.1 Staffing Protocol
- Operator (Human): Owns final decisions, approvals, and secrets. Performs all commits, pushes, and merges.
- Integrator (Lead AI): Maintains governance, structural integrity, and auditing. Generates Dispatch Packets and detects system drift.
- Contractor (Guest AI): Executes specific logic tasks and drafts implementation details within a defined scope.

### 4.2 Behavioral Logic Standard
- Linguistic Precision: No contractions across any scope, including projects.
- Linguistic Precision: Quantitative reporting required for deviations from protocol.
- Linguistic Precision: Absolute literalism; seek clarification for ambiguity before proceeding.
- Operational Directives: Anti-drift governance; logic or files misaligned with PoT.md are a system failure.
- Operational Directives: Context hygiene; ops/lib/manifests/CONTEXT.md must exclude docs/library/agents, docs/library/tasks, and docs/library/skills.
- Operational Directives: Logic conflict resolution; stop until the Operator redefines parameters if a task violates PoT.md.
- Operational Directives: Equilibrium maintenance; a task is complete only when SoP.md is updated.
- Operational Directives: Reuse-first discipline; cross-reference ops/ templates before creating new artifacts.
- Operational Directives: Contractor closeout skill harvesting uses ops/lib/scripts/skill.sh harvest for provenance.
- Operational Directives: Contractor closeout skill harvesting forbids manual creation of docs/library/skills markdown files.
- Operational Directives: Contractor closeout skill harvesting is mandatory for production payloads and optional for platform maintenance.

### 4.3 Hard Constraints (SSOT)
- PoT.md
- SoP.md
- TASK.md
- ops/lib/manifests/CONTEXT.md
- docs/MANUAL.md
- docs/MAP.md

### 4.4 Entry Points
- llms.txt

### 4.5 Drafting Proposal Protocol
- Integrator proposals: An Integrator may propose a work branch name and Base HEAD when they are not yet provided.
- Operator authority: The Operator creates branches and provides the final Base HEAD; Contractors do not create or switch branches.
- Provisional marking: Any provisional value must be prefixed with PROPOSED: during drafting and must be removed or replaced with finalized values before any worker runs a DP.

## 5. Workflow & Security

### 5.1 Non-Negotiables
- Do not push to `main`.
- Work only on `work/*` branches.
- Every PR must pass repo-gates.

### 5.2 Standard Workflow
- Create a branch named `work/<topic>-YYYY-MM-DD`.
- Make small, reviewable changes.
- Keep unrelated refactors out of the change set.
- Review changes visually before commit.
- Use clear commit messages.
- Push the `work/*` branch, open a PR, wait for repo-gates, then merge.

### 5.3 Provenance
- Record imported or adapted external code in `docs/UPSTREAMS.md` or the correct truth-layer document.
- Include source, purpose, changes, and known risks or limits.

### 5.4 Security Policy
Roles and access expectations are defined in PoT.md.

#### Secrets Management
- Never commit secrets, API keys, or credentials to the repo.
- Use environment variables or a local secrets manager for sensitive values.
- If a secret is exposed, rotate it and document the remediation.

#### AI Usage Policy
- AI assistance is allowed with human oversight.
- All AI-proposed changes must be reviewed by a human operator.
- Provide citations or provenance for external sources or non-trivial claims.

#### Reporting Vulnerabilities
Preferred:
- Use a GitHub Security Advisory for this repository.

If you cannot use GitHub Security Advisories:
- Contact the repository owners via GitHub and request a private channel.
- Do not disclose details publicly until coordinated.

When reporting, include:
- A clear description of the issue.
- Minimal reproduction steps or proof-of-concept.
- Affected files or versions (if known).
- Suggested mitigations (optional, appreciated).

#### Handling and Disclosure
- Reports are acknowledged as soon as practical.
- Fixes are prioritized by impact, exploitability, and clarity.
- We aim for coordinated, responsible disclosure.

#### Known Issues and Future Improvements
