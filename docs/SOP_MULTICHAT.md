# SOP: Multi-Chat Development (Integrator + Workers)

## Non-negotiables (the contract)
1) Repo is truth (paths/files/docs win over chat memory).
2) `upstream/` and `ops/init/icl/` are read-only.
3) No invention: if a file/path isn’t present, say so and propose options.
4) Workers don’t merge. They return diffs + notes. Integrator applies + merges.
5) PR workflow only: `work/* → commit → push → PR → merge` (no direct pushes to main).

## Worker Task Ticket (copy/paste)
ROLE: Worker. Do NOT change architecture. Do NOT merge. Output a unified diff + notes.

REPO CONTEXT (canon):
- Repo is truth. Read required docs first.
- upstream/ and ops/init/icl/ are read-only.
- No private/local artifacts committed.
- PR workflow only.

TASK:
[one sentence]

SCOPE:
Touch only: [paths]
Must not touch: [paths]

OUTPUT REQUIRED:
1) Unified diff (git apply compatible) OR exact file replacements
2) Rationale (short)
3) How verified (commands)
4) Risks/TODOs
