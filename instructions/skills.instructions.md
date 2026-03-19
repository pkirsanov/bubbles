# Bubbles Skill File Guidelines

> Adapted from [github/awesome-copilot](https://github.com/github/awesome-copilot) (MIT License).
> Modified to stay project-agnostic and defer to repository policies.
>
> **Portability:** This file is **project-agnostic**. Copy unchanged across projects.
> See [project-config-contract.md](../agents/bubbles_shared/project-config-contract.md) for the cross-project portability rules.
> See [agent-common.md](../agents/bubbles_shared/agent-common.md) for universal governance (anti-fabrication, evidence standards).

## What Are Skills?

Skills provide domain-specific knowledge that agents can load on demand. They are ideal for:

- Procedural workflows and checklists
- Domain expertise
- Reusable templates and patterns
- Reference documentation

## Skill Discovery

- Discover available skills from `.github/skills/*/SKILL.md`.
- Treat skill availability as repository-specific.
- Do not assume cross-repo skill names or file paths unless they exist in the current repository.
- Keep this instruction file project-agnostic. Put repo-specific skill inventories in repo docs if needed.

## Skill Directory Structure

Skills live in `.github/skills/<skill-name>/`:

```text
.github/skills/
└── my-skill/
    ├── SKILL.md           # Required: main skill file
    ├── references/        # Optional: supporting docs
    │   └── patterns.md
    ├── scripts/           # Optional: helpers invoked via the repo-standard workflow
    └── assets/            # Optional: templates, configs
```

## SKILL.md Format

### Required Frontmatter

```yaml
---
name: skill-name
description: One-line description of what this skill provides
---
```

### Portability Rule for Frontmatter

For portable skills, keep frontmatter minimal. Use only `name` and `description` unless the target host explicitly guarantees support for additional fields.

## Writing Guidelines

### Progressive Disclosure

1. `SKILL.md`: High-level workflow and key rules that can be scanned quickly
2. `references/`: Detailed documentation for specific topics
3. `assets/`: Templates, examples, boilerplate

### Content Style

- Use imperative language.
- Be action-oriented.
- Keep sections short. If a section grows beyond roughly 50 lines, move detail into `references/`.

### Example Structure

```markdown
## Purpose
Brief statement of what this skill enables.

## Quick Start
1. Step one
2. Step two
3. Step three

## Key Rules
- Critical constraint
- Another constraint

## Common Patterns

### Pattern A
Description and usage.

## References
- Detailed Topic (references/topic.md)
```

## Repository Policy Hook (MANDATORY)

Skills MUST NOT:

1. Include localhost or hardcoded ports
2. Embed shell scripts directly
3. Contain stubs or placeholder implementations
4. Define default values
5. Allow infinite waits
6. Allow unverified claims
7. Hardcode project-specific commands in portable skills
8. Duplicate governance rules instead of referencing `agent-common.md`

Skills MUST:

1. Reference `.github/copilot-instructions.md` for policy compliance
2. Use the repo-standard runner or workflow for builds and tests
3. Enforce operation timeouts
4. Use configuration from `.specify/memory/agents.md` and project config
5. Require execution evidence when verification is involved
6. Reference `agent-common.md` for anti-fabrication gates and evidence standards
7. State portability status clearly

## Execution Evidence Policy (MANDATORY for Verification Skills)

Skills that involve testing, validation, deployment verification, or health checks MUST require actual execution evidence.

Minimum requirements:
- Commands MUST be executed.
- Raw terminal output of at least 10 lines MUST be captured.
- Exit codes MUST be verified from actual output.
- No summaries or fabricated evidence.

## Governance Enforcement in Skills (MANDATORY)

All skills, portable or project-specific, MUST enforce these universal policies:

| Policy | Gate | What Skills Must Do |
|--------|------|--------------------|
| Anti-Fabrication | G021 | Verification steps require actual execution evidence. No summaries. |
| Evidence Standard | G005 | Use at least 10 lines of raw terminal output for pass or fail claims |
| Operation Timeouts | — | Wrap operations with explicit timeout protection |
| Sequential Completion | G019 | Skills invoked during scope work inherit sequential completion |
| Quality Work Standards | — | No stubs, placeholders, or fake data in skill outputs |
| Specialist Chain | G022 | Skills feeding specialist phases inherit completion requirements |

Portable skills MUST:
- Contain zero project-specific commands, paths, or tools
- Use `agents.md` indirection for commands
- Reference `agent-common.md` for governance policies

Project-specific skills MAY reference repo-specific commands and paths, but they still inherit all governance rules above.

## Operation Timeout Policy (MANDATORY)

All operations invoked by skills MUST have explicit time limits. Skills MUST NEVER instruct waiting indefinitely.

Use the timeout rules from [agent-common.md](../agents/bubbles_shared/agent-common.md).

## Skill Registration

Skills are automatically discovered when placed in `.github/skills/`. No explicit registration is required.

To reference a skill in an agent:

```yaml
---
description: Agent that uses a skill
---
```

```markdown
Load the trading-patterns skill for domain knowledge.

<skill>trading-patterns</skill>
```

## Quality Checklist

Before submitting a skill:

- [ ] `SKILL.md` has required frontmatter (`name`, `description`)
- [ ] Content is scannable quickly
- [ ] No hardcoded URLs, ports, or localhost references
- [ ] Any scripts are invoked via the repo-standard workflow
- [ ] No conflicts with `.github/copilot-instructions.md`
- [ ] Progressive disclosure is used appropriately

## See Also

- [workflows.yaml](../bubbles/workflows.yaml)
- [agent-common.md](../agents/bubbles_shared/agent-common.md)
- [scope-workflow.md](../agents/bubbles_shared/scope-workflow.md)
- [project-config-contract.md](../agents/bubbles_shared/project-config-contract.md)
- [skill-authoring](../skills/skill-authoring/SKILL.md)
- [agents.instructions.md](agents.instructions.md)
- Repository `copilot-instructions.md`