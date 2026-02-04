# Project STELA.md

Project-level rules for a single project. Store at `projects/<ID>/STELA.md`.

## Project Overview
Describe the project purpose, scope, and stack in a short paragraph.

## Critical Rules

### 1. Code Organization

- Many small files over few large files
- High cohesion, low coupling
- 200-400 lines typical, 800 max per file
- Organize by feature and domain, not by type

### 2. Code Style

- No emojis in code, comments, or documentation
- Immutability always; never mutate objects or arrays
- No console.log in production code
- Proper error handling with try/catch
- Input validation with Zod or similar

### 3. Testing

- 80% minimum coverage
- Unit tests for utilities
- Integration tests for APIs
- E2E tests for critical flows

### 4. Security

- No hardcoded secrets
- Environment variables for sensitive data
- Validate all user inputs
- Parameterized queries only
- CSRF protection enabled

## File Structure

```
projects/
|-- app/              # Next.js app router
|-- components/       # Reusable UI components
|-- hooks/            # Custom React hooks
|-- lib/              # Utility libraries
|-- types/            # TypeScript definitions
```

## Key Patterns

### API Response Format

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
}
```

### Error Handling

```typescript
try {
  const result = await operation()
  return { success: true, data: result }
} catch (error) {
  console.error('Operation failed:', error)
  return { success: false, error: 'User-friendly message' }
}
```

## Environment Variables

```bash
# Required
DATABASE_URL=
API_KEY=

# Optional
DEBUG=false
```

## Available Commands

- `/plan` - Create implementation plan
- `/code-review` - Review code quality
- `/build-fix` - Fix build errors

## Git Workflow

- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Never commit to main directly
- PRs require review
- All tests must pass before merge

<!--
User-level overlay (deprecated).
Do not create per-user STELA files. Use project-level STELA only.

Legacy outline from user-STELA:
- Agent-first, parallel execution, plan before execute, test-driven, security-first.
- Modular rules: security, coding-style, testing, git-workflow, agents, patterns, performance.
- Preferred agents: integrator, architect, code-reviewer, security-reviewer, build-error-resolver, refactor-cleaner, doc-updater.
- Code style: no emojis, immutability, many small files, 200-400 lines typical, 800 max.
- Git: conventional commits; test before commit; small focused commits.
- Editor: NetBeans with agent panel, command palette, Vim mode.
- Success metrics: tests pass, no security vulnerabilities, readable, requirements met.
-->
