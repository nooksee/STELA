# PROJECT_REGISTRY - Registered Projects (SSOT)

PROJECT_REGISTRY is the single source of truth for STELA-born projects in this repo.
Legacy projects are not imported unless a DP explicitly authorizes it.

## What is a project
A project is a deployable payload rooted under `projects/<project-id>/` with a README that owns its scope.

## Minimum project layout (v1)
Required:
- `projects/<project-id>/README.md`

Optional (standard when needed):
- `projects/<project-id>/upstream/`
- `projects/<project-id>/addons/`
- `projects/<project-id>/patches/`

## Registry format
The registry uses a Markdown table for human scanning and simple shell parsing.
Notes must not contain the `|` character.

## Registry fields
- project_id: stable slug for the project (lowercase, numbers, hyphen)
- display_name: human-readable name
- created_at: YYYY-MM-DD
- status: active | archived
- root_path: repo-relative root (under `projects/`)
- notes: optional short note

## Registry
| project_id | display_name | created_at | status | root_path | notes |
| --- | --- | --- | --- | --- | --- |
