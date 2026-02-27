<!-- CCD: ff_target="discovery" ff_band="35-45" -->
# Documentation Index (Front Door)

## 0. Primary Read-in (Start Here)
* [MANUAL.md](MANUAL.md) — Operator command and mechanics.
* [MANUAL.md#trace-cookbook](MANUAL.md#trace-cookbook) — Quick telemetry caller and leaf trace commands.

## 1. The Constitution (Law & Logic)
* [../PoT.md](../PoT.md) — Policy of Truth: constitution, staffing, jurisdiction, and enforcement.
* [GOVERNANCE.md](GOVERNANCE.md) — Project coherence, tone lanes, and non-negotiables.

## 2. The Ledger (State)
* [../SoP.md](../SoP.md) — State of Play: The history of what shipped and why.
* [../TASK.md](../TASK.md) — The active work surface and Dispatch Packet contract.

## 3. Operations & Maps (Deep Dives)
* [ops/README.md](ops/README.md) — Ops Kernel architecture and subsystem overview.
* [../opt/_factory/INDEX.md](../opt/_factory/INDEX.md) — Curated library of operator guides.
* [DESIGN.md](DESIGN.md) — Correct-by-Construction design discipline, retrospective audit, and decision registry.
* [MAP.md](MAP.md) — Continuity wayfinding for cross-session state.
* [ops/specs/surfaces/notes.md](ops/specs/surfaces/notes.md) — Contractor Notes surface contract and decision record trigger/schema documentation.
* [../archives/decisions/](../archives/decisions/) — Decision record archive. Structured, queryable records of scope-expansion authorizations, certify remediations, CbC verdicts, and operator-approved exceptions. Schema: `DEC-YYYY-MM-DD-<seq>-<slug>.md` with YAML frontmatter fields `trace_id`, `decision_id`, `packet_id`, `decision_type`, `created_at`, `authorized_by`; body sections `Context`, `Decision`, `Consequence`, `Pointer`, `Status`. Trigger rule: decision record required only when Contractor Notes `Anomalies Encountered` or `Open Items / Residue` is not `None.` See ops/specs/surfaces/notes.md.
* [CONTEXT.md](CONTEXT.md) — Definition of required context artifacts.
* [ops/specs/definitions/agents.md](ops/specs/definitions/agents.md) — Agent candidate and promotion head-chain specification.
* [ops/specs/definitions/tasks.md](ops/specs/definitions/tasks.md) — Task candidate and promotion head-chain specification.
* [ops/specs/definitions/skills.md](ops/specs/definitions/skills.md) — Skill candidate and promotion head-chain specification.
