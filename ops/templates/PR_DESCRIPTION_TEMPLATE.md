# PR Description Template (canonical)

Purpose: Ensure every PR is self-documenting, reviewable, and reversible.

Use this template in:
- GitHub PR description (auto-filled via .github/pull_request_template.md)
- Any work handoff to assistants/contractors (copy/paste)

Each section uses a prose line followed by a fenced block for copy/paste.

## Purpose
- One sentence on the goal or problem.
```
<fill>
```

## What shipped
- Bullet list of concrete changes (file-level is fine).
```
- <fill>
```

## Scope
- Exact paths/files touched.
```
- <fill>
```

## Verification
- repo-gates (pass/fail + notes).
- Manual checks (if any).
```
- <fill>
```

## Risk+Rollback
- Risk: top risk in one line.
- Rollback: revert merge commit.
```
- Risk: <fill>
- Rollback: <fill>
```

## Canon updates
- Updated `SoP.md` when doctrine/governance changes.
```
- <fill>
```
