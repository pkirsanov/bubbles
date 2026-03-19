# Bubbles Agent File Guidelines

> Adapted from [github/awesome-copilot](https://github.com/github/awesome-copilot) (MIT License).
> Adapted for repo-local conventions. Keep this document project-agnostic.
>
> **Portability:** This file is **project-agnostic**. Copy unchanged across projects.
> See [project-config-contract.md](../agents/bubbles_shared/project-config-contract.md) for the cross-project portability rules.
> See [agent-common.md](../agents/bubbles_shared/agent-common.md) for universal governance (anti-fabrication, evidence standards, sequential completion).

## Agent File Format

Agent files live in `.github/agents/` and use the `.agent.md` extension.

### Required Frontmatter

```yaml
---
description: <one-sentence summary of what the agent does>
---
```

### Optional Frontmatter Fields

```yaml
---
description: <required>
tools:
  - <tool-name>
  - <another-tool>
model: <model-preference>  # e.g., claude-sonnet-4-20250514, gpt-4.1
---
```

## Prompt Shim Pattern

This repo uses a **prompt shim + agent definition** architecture:

1. **Prompt shims** (`.github/prompts/*.prompt.md`): Minimal files with frontmatter routing to agents
2. **Agent definitions** (`.github/agents/*.agent.md`): Full behavior and instructions

### Prompt Shim Example

```yaml
---
mode: agent
agent: my-agent
description: Brief description shown in UI
---
```

The shim contains no behavior. All logic lives in the agent file.

## Agent Body Structure

After frontmatter, use Markdown with clear sections:

```markdown
## Agent Identity
- **Name**: `<agent-id>` (must match filename and prompt shim)
- **Role**: One sentence describing what the agent is responsible for.
- **Non-goals**: What this agent explicitly does not do.

## Purpose
Brief statement of what this agent does.

## Workflow
1. Step one
2. Step two
3. ...

## Rules
- Constraint or policy
- Another constraint

## Output Format
Description of expected output structure.
```

## Agent Definition Best Practices

- Start with **Agent Identity** so readers immediately know who or what is acting.
- Prefer a **phase-based workflow** when the task is multi-step.
- Keep required inputs explicit.
- Reference source-of-truth docs instead of duplicating policy blocks:
  - `.github/bubbles/workflows.yaml`
  - `.github/agents/bubbles_shared/project-config-contract.md`
- Use tiered context loading:
  - Tier 1: Governance (`constitution.md`, `agents.md`, `copilot-instructions.md`)
  - Tier 2: Feature context (`spec.md`, `scopes.md`, `design.md`)
  - Tier 3: Reference docs (on-demand only)
- If you add or remove a Bubbles command, update the corresponding prompt shim under `.github/prompts/`.

## Bubbles Governance (MANDATORY for `bubbles.*` agents)

All `bubbles.*` agents MUST follow these governance rules and reference canonical docs rather than duplicating policy blocks.

Key governance references:
- [agent-common.md](../agents/bubbles_shared/agent-common.md)
- [critical-requirements.md](../agents/bubbles_shared/critical-requirements.md)
- [scope-workflow.md](../agents/bubbles_shared/scope-workflow.md)
- [project-config-contract.md](../agents/bubbles_shared/project-config-contract.md)
- [workflows.yaml](../bubbles/workflows.yaml)

## Universal Anti-Fabrication Contract (MANDATORY for ALL agents)

All agents MUST enforce strict truthfulness and test-substance requirements per [agent-common.md](../agents/bubbles_shared/agent-common.md) and [critical-requirements.md](../agents/bubbles_shared/critical-requirements.md).

Key rules:
- Every pass or fail claim maps to an executed command with real output.
- Status remains `in_progress` or `blocked` on missing or contradictory evidence.
- Apply fabrication detection heuristics, sequential completion, specialist completion, and mandatory completion checkpoints before reporting complete.

## Agent Identity Section (REQUIRED)

Every `bubbles.*` agent MUST include an `Agent Identity` section immediately after the frontmatter.

```markdown
## Agent Identity

**Name:** bubbles.<agent-name>
**Role:** [One-line description of primary responsibility]
**Expertise:** [Key competencies and knowledge domains]

**Behavioral Rules:**
- [Rule 1: How the agent approaches work]
- [Rule 2: Quality or verification standard]
- [Rule 3: Collaboration or handoff behavior]

**Non-goals:**
- [What this agent explicitly does not do]
- [Boundaries to prevent scope creep]
```

## Policy & Session Compliance

Include this section in every Bubbles agent without duplicating full rules:

```markdown
## Policy & Session Compliance

Follow policy compliance, session tracking, and context loading per the repo governance files and [project-config-contract.md](../agents/bubbles_shared/project-config-contract.md).

Key requirements:
- Load Tier 1 governance docs first (`constitution.md`, `agents.md`, `copilot-instructions.md`)
- Maintain session state in `bubbles.session.json` with `agent: <agent-name>` when the repo uses a session file
- Respect loop limits and status ceilings from `.github/bubbles/workflows.yaml`
```

## Action First

Agents MUST take action, not just analyze:
- Load Tier 1 docs.
- Take one action.
- Load more only if blocked.
- Maximum 3 documents before first action.
- No analysis loops.

For scope completion, test execution, anti-fabrication, and loop limits, reference:
- [agent-common.md](../agents/bubbles_shared/agent-common.md)
- [scope-workflow.md](../agents/bubbles_shared/scope-workflow.md)
- [workflows.yaml](../bubbles/workflows.yaml)

For artifact templates, use:
- [feature-templates.md](../agents/bubbles_shared/feature-templates.md)
- [bug-templates.md](../agents/bubbles_shared/bug-templates.md)

## DoD Evidence Format (MANDATORY)

For all `bubbles.*` agents, DoD completion evidence MUST be embedded directly under each DoD checkbox item in `scopes.md` or bug `scopes.md` as raw execution output.

Rules:
- Do not use `report.md` links as a substitute for DoD completion evidence.
- Do not use summaries or paraphrases as DoD evidence.
- Use verbatim command output with exit code context, with at least 10 lines for test or run evidence.

## Operation Timeout Policy (MANDATORY)

All operations executed by agents MUST have explicit time limits. Agents MUST NEVER wait indefinitely.

Use the timeout rules and enforcement patterns from [agent-common.md](../agents/bubbles_shared/agent-common.md).

On timeout:
1. Log the timeout event with context.
2. Kill any hung processes.
3. Report failure with the timeout reason.
4. Do not retry automatically without explicit user approval.

## Auto-Approvable Command Patterns Only

Agents MUST avoid command patterns that commonly trigger VS Code Copilot approval prompts.

### Prohibited

- `bash -c '...'` or `sh -c '...'` wrappers for normal repo operations
- Chained wrapper commands like `source ... && cd ... && go test ...`
- Temp-file redirection pipelines for output capture

### Required

1. Use repository-standard entrypoints resolved from `.specify/memory/agents.md`.
2. Prefer direct command invocation over shell wrappers.
3. Keep commands auditable and minimal.