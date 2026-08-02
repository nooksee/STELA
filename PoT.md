<!-- CCD: ff_target="governance-narrative" ff_band="40-65" -->
# Policy of Truth (PoT)

## Preamble: Doctrine
The system prevents action that violates policy. It does not request compliance.
PoT is the single constitutional document for Stela governance.

## 1. Physical Laws

### 1.1 Filing Doctrine
- `ops/` = Run (binaries, manifests, automation).
- `docs/` = Explain (manuals and rationale).
- `opt/` = Isolate (JIT-only  content excluded from global context).
- `projects/` = Work (payload code).
- `storage/` = Payload (handoff, dumps, dp).
- `var/tmp/` = Resume (ephemeral worker scratch and task-local workspace).
- `logs/` = Telemetry (runtime logs and diagnostics).
- `archives/` = Cold (long-lived draft and ledger archives).

### 1.2 Axioms
- Precedence: PoT is final authority; if conflict exists, PoT prevails.
- SSOT: one canonical file per domain; other mentions are pointers.
- Reuse-first: search `ops/` for an existing template before creating a new artifact.
- Drift: any divergence between canon and repository state, or duplication of canon outside SSOT, is a failure state that requires stop and correction.
- Routing: closeout routing failure is a system failure state.
- RoR: decision ledger only; authorization and anomaly records live there.
- SoP: history ledger only; no permanent rules live there.
- PoW: proof ledger only; execution evidence pointers live there.

### 1.3 Canon Surfaces
- `PoT.md` — constitution, staffing, jurisdiction, and enforcement (SSOT).
- `TASK.md` — active work surface and DP contract.
- `SoP.md` — history ledger and shipment record.
- `PoW.md` — proof ledger and execution evidence pointers.
- `RoR.md` — decision ledger and anomaly record pointer surface.
- `docs/MANUAL.md` — operator mechanics.
- `docs/MAP.md` — context wayfinding.
- `ops/lib/manifests/CONTEXT.md` — required context set.
- `llms.txt` — discovery entry point.

**Source of Truth Read-in Order**:
1. `PoT.md`: The Constitution. Physical laws, staffing, jurisdiction. The final authority.
2. `SoP.md`: The History. State of Play ledger. Context on *why* things are the way they are.
3. `PoW.md`: The Proof Ledger. Validate evidence pointers before state-changing maintenance.
4. `TASK.md`: The Contract. Active work surface. Contains the current Dispatch Packet (DP).
5. `docs/MAP.md`: The Terrain. Continuity map for navigating the repository context.

## 2. Enforcement
Executed by the worker and through automated subsystems, including linters, build gates, and binary validation.

**STOP WORK**: worker complaint and halt and/or request clarification.
- Canon Drift: divergence between `PoT.md` and repo state.
- Dirty State: uncommitted changes in `main`.
- Ambiguity: instructions capable of multiple interpretations.
- Immediate Cessation: Cease all active task processing.
- Process Termination: Kill any executing processes that violate safety or state constraints.

## 3. Jurisdiction
Scope: `archives/`, `ops/`, `docs/`, `logs/`, `opt/`, `projects/`, `storage/`, `tools/`, `var/tmp`, `.github/`, and root governance surfaces.
Law: PoT is the sole authority across all scopes. No parallel jurisdictions exist.

## 4. Staffing & Logic
Hard constraints are: PoT.md, SoP.md, TASK.md, ops/lib/manifests/CONTEXT.md, docs/MANUAL.md, and docs/MAP.md.

### 4.1 Staffing Protocol
- Operator (Human): Owns final decisions, approvals, and secrets. Performs all commits, pushes, and merges.
- Integrator (Lead AI): Maintains governance, structural integrity, and auditing. Generates Dispatch Packets and detects system drift.
- Contractor (Guest AI): Executes the defined packet scope, implements changes, runs required checks, and reports results within the provided contract.

### 4.2 Behavioral Logic Standard
- No contractions across any scope, including projects.
- Quantitative reporting required for deviations from protocol.
- Absolute literalism; seek clarification for ambiguity before proceeding.
- Verification outputs must be generated, not pre-filled or assumed.
- Receipts are generated artifacts produced by the system; manual fabrication is prohibited.
- Imagine the same way an operator explains a failure, picture a concrete branch state, and consider a direct recovery action.
- Prefer prevention over detection. Document why structural prevention is not viable.

### 4.4 Entry Points
- llms.txt

### 4.5 Epistemic Standards
- System: everything the system proves is actually true.
- Truth: primitive predicate governed by specific rules rather than a mere definition.
- Action: deception or incoherence are inherently destabilizing and must be resolved.

## 5 Security Policy

### 5.1 Vulnerability Reporting
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

### 5.2 Handling and Disclosure
- Reports are acknowledged as soon as practical.
- Fixes are prioritized by impact, exploitability, and clarity.
- We aim for coordinated, responsible disclosure.

## 6 Workflow

### 6.1 Non-Negotiables
- Do not push to `main`.
- Work only on `work/*` branches.
- Every PR must pass gates.

### 6.2 Standard Workflow
- Create a branch named `work/<DP-ID>-YYYY-MM-DD`.
- Make small, reviewable changes.
- Keep unrelated refactors out of the change set.
- Review changes visually before commit.
- Use clear commit messages.
- Push the `work/*` branch, open a PR, wait for gates, then merge.

### 6.2.1 Branching Doctrine (SSoT)
- Immutable Trunk: main is verified state; direct pushes are forbidden.
- Work Namespace: all work occurs on work/* branches.
- Naming Schema: `work/<DP-ID>-YYYY-MM-DD`.
- Drift Prevention: branches outside schema are trash and subject to pruning.

### 6.2.2 Immutable Dispatch Packet Workflow
- Refresh state from current canonical session artifacts before packet execution.
- Generate dispatch packet structure; do not hand-author structural boilerplate.
- Resolve every provisional value before worker execution begins.
- Edit only approved dispatch packet slot content after draft generation.
- If canonical dispatch packet template hash or normalized structure hash fails, stop and repair before proceeding.
- Maintain closing-sidecar input during execution.
- Execute receipt commands and generate RESULTS.
