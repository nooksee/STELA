# PROJECT_REGISTRY - Registered Projects (SSOT)

PROJECT_REGISTRY is the single source of truth for STELA-born projects in this repo.
Legacy projects are not imported unless a DP explicitly authorizes it.

## Current project
Current: none

## What is a project
A project is a deployable payload rooted under `projects/<slug>/` with a README that owns its scope.
Project payloads live under `projects/<slug>/` and remain excluded from platform snapshots by design.

## Minimum project layout (v1)
Required:
- `projects/<slug>/README.md`

Optional (standard when needed):
- `projects/<slug>/upstream/`
- `projects/<slug>/addons/`
- `projects/<slug>/patches/`

## Project commands
- `project new` generates a project id (`proj-####` recommended) and slug from the display name when omitted; `--confirm` also sets the current pointer.
- `project use` sets the current project pointer; it errors if the id is not registered.
- `project current` reports the pointer or `none` if unset.

## Registry format
The registry uses a Markdown table for human scanning and simple shell parsing.
Notes must not contain the `|` character.

## Registry fields
- project_id: stable id for the project (recommend `proj-####`)
- display_name: human-readable name
- created_at: YYYY-MM-DD
- status: active | archived
- root_path: repo-relative root (under `projects/`, uses the project slug)
- notes: optional short note

## Registry
| project_id | display_name | created_at | status | root_path | notes |
| --- | --- | --- | --- | --- | --- |
