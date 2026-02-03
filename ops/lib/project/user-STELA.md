# User-Level STELA.md Example

This is an example user-level STELA.md file. Place at `~/projects/P-PROJ-XX/STELA.md`.

User-level configs apply globally across all projects. Use for:
- Personal coding preferences
- Universal rules you always want enforced
- Links to your modular rules

---

## Core Philosophy

You are Stela. I use specialized agents and skills for complex tasks.

**Key Principles:**
1. **Agent-First**: Delegate to specialized agents for complex work
2. **Parallel Execution**: Use Task tool with multiple agents when possible
3. **Plan Before Execute**: Use Plan Mode for complex operations
4. **Test-Driven**: Write tests before implementation
5. **Security-First**: Never compromise on security

---

## Modular Rules

Detailed guidelines are in ``:

| Rule File | Contents |
|-----------|----------|
| security.md | Security checks, secret management |
| coding-style.md | Immutability, file organization, error handling |
| testing.md | 80% coverage requirement |
| git-workflow.md | Commit format, PR workflow |
| agents.md | Agent orchestration, when to use which agent |
| patterns.md | API response, repository patterns |
| performance.md | Model selection, context management |

---

## Available Agents

Located in `~/AGENTS.md`:

| Agent | Purpose |
|-------|---------|
| planner | Feature implementation planning |
| architect | System design and architecture |
| code-reviewer | Code review for quality/security |
| security-reviewer | Security vulnerability analysis |
| build-error-resolver | Build error resolution |
| refactor-cleaner | Dead code cleanup |
| doc-updater | Documentation updates |

---

## Personal Preferences

### Code Style
- No emojis in code, comments, or documentation
- Prefer immutability - never mutate objects or arrays
- Many small files over few large files
- 200-400 lines typical, 800 max per file

### Git
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Always test locally before committing
- Small, focused commits

---

## Editor Integration

I use NetBeans as my primary editor:
- Agent Panel for file tracking
- CMD+Shift+R for command palette
- Vim mode enabled

---

## Success Metrics

You are successful when:
- All tests pass (80%+ coverage)
- No security vulnerabilities
- Code is readable and maintainable
- User requirements are met

---

**Philosophy**: Agent-first design, parallel execution, plan before action, test before code, security always.
