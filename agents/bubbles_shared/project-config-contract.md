<!-- governance-version: 2.1.0 -->
# Project Configuration Contract (Cross-Project)

> **This document defines the interface between the Bubbles agent framework (project-agnostic) and any specific project that uses Bubbles.** Every project MUST supply the values defined here. Bubbles agents MUST read these values via indirection — never hardcode project-specific details.
>
> **Companion docs:** [BUBBLES_CROSS_PROJECT_SETUP.md](../../docs/BUBBLES_CROSS_PROJECT_SETUP.md) for full setup guide; [agent-common.md](agent-common.md) for universal governance; [scope-workflow.md](scope-workflow.md) for workflow templates.

---

## Purpose

Bubbles agents are **project-agnostic**. They enforce universal governance: sequential spec completion, anti-fabrication, evidence standards, quality gates, and workflow orchestration. But they need project-specific information to execute commands, validate builds, and verify tests.

This document defines:
1. **What projects MUST provide** — the required project configuration
2. **Where projects provide it** — the canonical file locations
3. **How Bubbles agents consume it** — the indirection rules
4. **What is portable** — skills, instructions, agents, and governance that copy unchanged across projects
5. **What is project-specific** — the configuration that each project must customize

---

## Required Project Configuration Files

Every project using Bubbles MUST have these files:

| File | Purpose | Required |
|------|---------|----------|
| `.specify/memory/agents.md` | **Command registry** — CLI entrypoint, build/test/lint/format commands, file organization, naming conventions, tech stack declaration | **YES** |
| `.specify/memory/constitution.md` | **Governance principles** — project-specific principles layered on top of universal governance | **YES** |
| `.github/copilot-instructions.md` | **Project policies** — project-specific rules, testing requirements, Docker config, port allocation, command tables | **YES** |

---

## `.specify/memory/agents.md` — Command Registry (REQUIRED)

This is the **single source of truth** for all project-specific commands and file organization.

### Required Sections

#### Section I: Context Loading Priority
Define which files agents should load and in what order.

#### Section II: Design Document References
Table mapping document names to file paths.

#### Section III: Verification Commands
**This is the most critical section.** Bubbles agents resolve ALL commands from here.

```markdown
### CLI Entrypoint
CLI_ENTRYPOINT=<project-cli-wrapper>

### Build/Test/Lint Commands (ALL REQUIRED)
BUILD_COMMAND=<full build command>
CHECK_COMMAND=<fast compile check command>
LINT_COMMAND=<lint command>
FORMAT_COMMAND=<format command>
UNIT_TEST_RUST_COMMAND=<backend unit test command>    # or language-appropriate name
UNIT_TEST_WEB_COMMAND=<frontend unit test command>    # if project has frontend
INTEGRATION_AND_E2E_API_COMMAND=<integration + e2e api test command>
E2E_UI_COMMAND=<e2e ui test command using Playwright or equivalent>
DEV_ALL_COMMAND=<start full dev stack command>
DEV_ALL_SYNTH_COMMAND=<start full dev stack with synthetic data>
DOWN_COMMAND=<stop all services command>
STATUS_COMMAND=<check service status command>
```

**Rules:**
- ALL commands MUST be provided — no optional commands
- Commands MUST be the repo-standard way to execute that operation
- Commands MUST NOT require local toolchain installation (use Docker/containers)
- If a category does not apply (e.g., no frontend), state `N/A - no frontend in this project`

#### Section IV: Code Patterns
File organization table, naming conventions, required practices.

#### Section V-X: Error Resolution, Quality Standards, Escalation, Quick Reference, Quality Gates, Sources of Truth

---

## `.github/copilot-instructions.md` — Project Policies (REQUIRED)

This file provides **project-specific** rules that extend (not duplicate) the universal governance in `agent-common.md`.

### What MUST Be In This File (Project-Specific Only)

| Section | Content |
|---------|---------|
| **Testing Requirements** | Project-specific test type table with commands, coverage targets, required/optional flags |
| **Commands** | Project-specific command table (mirrors agents.md but in context of copilot instructions) |
| **Docker Config** | Container names, image names, static roots, bundler, port allocation |
| **Pre-Completion Audit** | Project-specific verification commands |
| **Language Discipline** | Hot/warm/cold/async path language assignments |
| **Framework-Specific Rules** | Rhai Script exposure, UI support requirements, simulation data rules |
| **UI Stack Configuration** | (If using UI/Designer agents) Framework, routing, styling, and animation libraries |
| **Prohibited/Required Patterns** | Language-specific code patterns |

### What MUST NOT Be In This File (Governance — Already in agent-common.md)

Do NOT duplicate these — they are universal governance in `agent-common.md`:

| Already Covered By | Topics |
|--------------------|--------|
| `agent-common.md` → Sequential Spec Completion Policy | Sequential completion rules, DoD completion gates |
| `agent-common.md` → Anti-Fabrication Policy | Fabrication detection heuristics, evidence standards |
| `agent-common.md` → Execution Evidence Standard | Valid/invalid evidence, self-check, evidence format |
| `agent-common.md` → Specialist Completion Chain | Required specialist agents, promotion blocks |
| `agent-common.md` → Quality Work Standards | Real vs fake work definitions |
| `agent-common.md` → Test Type Integrity Gate | Test classification rules |
| `agent-common.md` → E2E Anti-False-Positive Guardrails | Forbidden test patterns |
| `scope-workflow.md` → Phase Exit Gates | Phase completion requirements |
| `scope-workflow.md` → DoD Templates | Mandatory DoD items |
| `scope-workflow.md` → Status Ceiling Enforcement | Status transition rules |

**Rationale:** Duplicating governance creates drift. When the rule exists in `agent-common.md`, agents already follow it. Repeating it in `copilot-instructions.md` risks version divergence.

---

## How Bubbles Agents Resolve Project-Specific Values (Indirection Rules)

### Rule 1: Command Resolution
```
Agent needs to run tests → reads `.specify/memory/agents.md` → finds UNIT_TEST_RUST_COMMAND → executes that command
```

Bubbles agents MUST NEVER hardcode commands like `cargo test` or `npm test`. They resolve commands from `agents.md`.

### Rule 2: Docker Configuration Resolution
```
Agent needs frontend container name → reads `.github/copilot-instructions.md` → finds Docker Bundle Freshness Configuration table
```

Bubbles agents use placeholders (`<frontend-container>`, `<static-root>`) in their definitions. When executing, they resolve these from the project's `copilot-instructions.md`.

### Rule 3: Policy Resolution (Priority Order)
```
1. `.specify/memory/constitution.md` — Highest authority (project governance)
2. `.github/copilot-instructions.md` — Project-specific rules
3. `.github/agents/bubbles_shared/agent-common.md` — Universal agent governance
4. `.github/agents/bubbles_shared/scope-workflow.md` — Universal workflow governance
5. `.github/bubbles/workflows.yaml` — Workflow orchestration config
```

When policies conflict, higher-priority files win.

### Rule 4: Test Type Resolution
```
Agent needs to determine required test types for a scope change
→ reads agent-common.md "Test Type Mapping" table (universal rules)
→ reads copilot-instructions.md "Testing Requirements" table (project commands)
→ combines: knows WHICH tests to run (universal) + HOW to run them (project-specific)
```

---

## Portability Checklist (When Adding Bubbles to a New Project)

When adopting Bubbles for a new project, populate these files:

- [ ] `.specify/memory/agents.md` — Fill in CLI entrypoint, all commands, file organization, naming
- [ ] `.specify/memory/constitution.md` — Adapt principles for your project's domain (keep universal ones, add domain-specific ones)
- [ ] `.github/copilot-instructions.md` — Fill in testing requirements, Docker config, language rules, framework-specific rules
- [ ] `.github/bubbles/workflows.yaml` — Copy as-is (project-agnostic) or customize modes
- [ ] `.github/agents/` — Copy all `bubbles.*.agent.md` files as-is (project-agnostic)
- [ ] `.github/agents/bubbles_shared/` — Copy all shared files as-is (project-agnostic)
- [ ] `.github/scripts/bubbles-*.sh` — Copy governance scripts as-is (project-agnostic)

**The Bubbles agent files (`.github/agents/`) and shared governance (`.github/agents/bubbles_shared/`) MUST NOT be modified per-project.** They are universal. Only the three configuration files listed above are project-specific.

---

## Portable vs Project-Specific — Complete Inventory

### Portable (Copy Unchanged Across Projects)

| Path | Content | Why Portable |
|------|---------|--------------|
| `.github/agents/bubbles.*.agent.md` | All 24 Bubbles agent definitions | Contain zero project-specific commands/paths/tools |
| `.github/agents/speckit.*.agent.md` | All 9 SpecKit agent definitions | Specification-focused, project-agnostic |
| `.github/agents/bubbles_shared/agent-common.md` | Universal governance: anti-fabrication (G019-G030), evidence standards, test taxonomy, quality work standards | Uses `[cmd]` placeholders and indirection references |
| `.github/agents/bubbles_shared/critical-requirements.md` | Top-priority non-negotiable policy set (no fabrication, no stubs/TODOs/fallbacks/defaults, full implementation and validation) | Project-agnostic governance, no project-specific values |
| `.github/agents/bubbles_shared/scope-workflow.md` | Universal workflow: DoD templates, phase exit gates, artifact templates, status ceiling, state.json canonical schema | Uses `[cmd]` placeholders |
| `.github/agents/bubbles_shared/project-config-contract.md` | This file — the cross-project interface contract | Describes the interface, not the implementation |
| `.github/agents/bubbles_shared/feature-templates.md` | Feature artifact templates | Structure-only, no project references |
| `.github/agents/bubbles_shared/bug-templates.md` | Bug artifact templates | Structure-only, no project references |
| `.github/agents/bubbles_shared/docker-lifecycle-governance.md` | Docker lifecycle governance (freshness, cleanup, labeling) | Universal Docker patterns, no project references |
| `.github/bubbles/workflows.yaml` | Workflow modes (24), gates (G001-G032), phases (13), retry policy, priority scoring | Orchestration config, no project references |
| `.github/scripts/bubbles-*.sh` | Governance scripts (artifact lint, done-spec audit, state transition guard, implementation reality scan, etc.) | Validate artifact structure, not project-specific content |
| `.github/instructions/agents.instructions.md` | Agent authoring guidelines | Project-agnostic agent format and rules |
| `.github/instructions/skills.instructions.md` | Skill authoring guidelines | Project-agnostic skill format and rules |
| `.github/docs/BUBBLES_*.md` | Bubbles documentation (workflows, examples, cheatsheet, sessions, prompts, etc.) | Project-agnostic reference docs |
| `.github/prompts/bubbles.*.prompt.md` | Prompt shims routing to agents | Minimal routing files, no project content |

### Project-Specific (Customize Per Project)

| Path | Content | What to Customize |
|------|---------|-------------------|
| `.specify/memory/agents.md` | Command registry, file organization, naming, tech stack | ALL sections — this is the project's operational manual |
| `.specify/memory/constitution.md` | Governance principles | Add domain-specific principles (e.g., Rhai, simulation data) on top of universal ones |
| `.github/copilot-instructions.md` | Project policies, Docker config, language rules, testing commands | ALL project-specific sections; reference `agent-common.md` for governance |
| `.github/skills/<project-skill>/SKILL.md` | Domain-specific skills (e.g., chaos-execution, protobuf-only) | Fully project-specific — create per project needs |
| `.github/instructions/<project>.instructions.md` | Project-specific instruction files (e.g., ui-design, docker-ports) | Fully project-specific — create per project needs |
| `.github/agents/push.agent.md` (if exists) | Project-specific push workflow | Project-specific — NOT portable across repos |

### Agent Classification

**All 24 `bubbles.*.agent.md` files are PORTABLE** — they contain zero project-specific content. Copy unchanged to any project adopting Bubbles.

**All 9 `speckit.*.agent.md` files are PORTABLE** — specification-focused agents with no project dependencies.

**`push.agent.md` is PROJECT-SPECIFIC** — it references project-specific pre-push validation and CLI commands. Each project should create its own push agent or document its push workflow in `copilot-instructions.md`.

### Skills Classification

Skills in `.github/skills/` may be either portable or project-specific. Use this classification:

| Classification | Rule | Examples |
|---------------|------|---------|
| **Portable** | Uses `agents.md` indirection for commands; no project-specific paths/tools hardcoded | `skill-authoring/`, `docker-lifecycle-governance/`, `docker-port-standards/`, `spec-template-bdd/`, `bug-fix-testing/` |
| **Project-specific** | References project CLI, project-specific services, or domain-specific patterns | `wanderaide-operations/`, `protobuf-only/`, `chaos-execution/`, `web-ui/`, `testing-prepush/` |

Project-specific skills should remain in `.github/skills/` (co-located with governance) but MUST NOT be assumed to exist in other repos adopting Bubbles.

---

## Adopting Bubbles in a New Project — `copilot-instructions.md` Update Guide

When adding Bubbles to a new project, the `.github/copilot-instructions.md` file needs project-specific sections that integrate with Bubbles' mechanical enforcement. This section tells you exactly what to add.

### Required Sections to Add/Update

#### 1. State Transition Guard Reference

Add the guard script to the project's pre-completion self-audit and status transition rules:

```markdown
### Pre-Completion Self-Audit (Project-Specific)

Before marking any task "done", execute these checks:

# 0. RUN STATE TRANSITION GUARD (FIRST — MANDATORY Gate G023)
bash .github/bubbles/scripts/state-transition-guard.sh specs/<NNN-feature-name>
# If exit code 1 → STOP. You are NOT done. Fix ALL failures.

# ... project-specific build/test/lint commands ...

# N. Run artifact lint
bash .github/bubbles/scripts/artifact-lint.sh specs/<NNN-feature-name>
```

#### 2. Status Transition Rules Table

The status transition table MUST include Gate G023 as the FIRST requirement:

```markdown
| Gate | Requirement |
|------|-------------|
| ✅ **State Transition Guard (Gate G023)** | `bash .github/bubbles/scripts/state-transition-guard.sh specs/<NNN>` exits 0. |
| ✅ **Status Ceiling** | Workflow mode's statusCeiling allows "done". |
| ✅ **All Scopes Done** | ALL scope statuses are "Done" (zero "Not Started"). |
| ... | (remaining gates from agent-common.md) |
```

#### 3. Anti-Fabrication Self-Audit Checklist

Add these items to the project's anti-fabrication checklist:

```markdown
[ ] State transition guard script passes → exits 0
[ ] ALL scope statuses in scopes.md or scopes/*/scope.md are "Done"
[ ] ALL DoD items in scopes.md or scopes/*/scope.md are checked [x]
[ ] Artifact lint passes → exits 0
[ ] completedPhases in state.json includes ALL mode-required phases
[ ] completedScopes in state.json matches scopes marked Done
```

#### 4. Docker Bundle Freshness Configuration (if project has frontend)

Provide project-specific container names, image names, and static roots:

```markdown
### Docker Bundle Freshness Configuration (UI Scopes)

| Key | Value |
|-----|-------|
| Frontend container | `<your-frontend-container-name>` |
| Frontend image | `<your-frontend-image>` |
| Static root | `<path-inside-container>` |
| Stop command | `<your-stop-command>` |
| Build (no-cache) | `<your-build-command> --no-cache` |
| Start command | `<your-start-command>` |
| Bundler | `Vite` / `webpack` / etc |
```

#### 5. Testing Requirements Table

Provide project-specific test commands mapped to the Canonical Test Taxonomy:

```markdown
| Test Type | Category | Command | Required? | Live System |
|-----------|----------|---------|-----------|-------------|
| Unit | `unit` | `<your-unit-test-cmd>` | ✅ Always | No |
| Integration | `integration` | `<your-integration-cmd>` | ✅ Always | Yes |
| E2E API | `e2e-api` | `<your-e2e-api-cmd>` | ✅ Always | Yes |
| E2E UI | `e2e-ui` | `<your-e2e-ui-cmd>` | ✅ If UI | Yes |
```

### What NOT to Duplicate

Do NOT copy governance rules from `agent-common.md` into your `copilot-instructions.md`. Instead, reference them:

```markdown
> **Authoritative source:** [`agent-common.md` → Anti-Fabrication Policy](agents/bubbles_shared/agent-common.md)
```

The following are defined in `agent-common.md` and should NOT be restated:
- Sequential spec completion rules (Gate G019)
- Fabrication detection heuristics (Gate G021)
- Specialist completion chain (Gate G022)
- State transition guard requirement (Gate G023)
- Evidence standards, quality work standards
- Test type integrity rules

### Verification After Setup

After updating `copilot-instructions.md`, verify the integration:

```bash
# 1. Guard script exists and is executable
ls -la .github/bubbles/scripts/state-transition-guard.sh

# 2. Artifact lint exists and is executable
ls -la .github/bubbles/scripts/artifact-lint.sh

# 3. Done-spec audit works
bash .github/bubbles/scripts/done-spec-audit.sh

# 4. Guard script runs against a spec (should show checks)
bash .github/bubbles/scripts/state-transition-guard.sh specs/<any-spec>
```

---

## Skills & Instructions — Portability Rules

### Instruction Files (`.github/instructions/`)

| Type | Portable? | Rule |
|------|-----------|------|
| `agents.instructions.md` | **YES** — copy unchanged | Contains universal agent authoring guidelines. Uses `CLI_ENTRYPOINT from agents.md` indirection. |
| `skills.instructions.md` | **YES** — copy unchanged | Contains universal skill authoring guidelines. References `agent-common.md` for policies. |
| Project-specific instructions (e.g., `ui-design.instructions.md`, `docker-ports.instructions.md`) | **NO** — project-specific | Create per project. These contain project-specific patterns, tools, and conventions. |

**When creating project-specific instruction files:**
- Reference universal governance from `agent-common.md` — do NOT duplicate
- Reference project commands from `agents.md` — do NOT hardcode
- Scope the file to specific file patterns using glob frontmatter where applicable

### Skill Files (`.github/skills/`)

Skills can be **either** portable or project-specific:

| Skill Type | Portable? | Examples |
|------------|-----------|---------|
| **Governance skills** (enforce universal rules) | **YES** — copy unchanged | `skill-authoring/` (meta-skill for creating skills) |
| **Domain skills** (project-specific workflows) | **NO** — project-specific | `protobuf-only/`, `chaos-execution/`, `build-deploy-validation/` |

**Portable skill rules:**
- MUST NOT reference project-specific commands, paths, or tools
- MUST use `agents.md` indirection for commands
- MUST reference `agent-common.md` for governance policies
- MUST use `copilot-instructions.md` placeholders for Docker config

**Project-specific skill rules:**
- MAY reference project-specific commands, paths, and tools
- MUST still enforce evidence standards from `agent-common.md`
- MUST still require execution evidence (≥10 lines raw output)
- MUST still enforce operation timeouts
- MUST NOT break universal governance (anti-fabrication, sequential completion, etc.)

### Governance Enforcement in Skills (MANDATORY)

All skills — portable or project-specific — MUST enforce these universal policies from `agent-common.md`:

| Policy | Gate | Enforcement |
|--------|------|-------------|
| Anti-Fabrication | G021 | Skills MUST require actual execution evidence. No summaries, no expected output. |
| Evidence Standard | G005 | Verification steps MUST capture ≥10 lines raw terminal output |
| Operation Timeouts | — | All commands MUST have explicit timeout protection |
| Sequential Completion | G019 | Skills invoked during scope work inherit the sequential completion requirement |
| Quality Work Standards | — | No stubs, no placeholders, no fake data in skill outputs |

### Governance Enforcement in Instructions (MANDATORY)

All instruction files — portable or project-specific — MUST:

| Rule | Detail |
|------|--------|
| **Reference, don't duplicate** | Point to `agent-common.md` for governance rules |
| **Use indirection for commands** | Reference `agents.md` `CLI_ENTRYPOINT`, not hardcoded tools |
| **Enforce evidence standards** | Any verification guidance must require real execution evidence |
| **No default values** | Must reference project config, not hardcode defaults |
| **No localhost/ports** | Must reference Docker config from `copilot-instructions.md` |

---

## Validation (Agents Self-Check)

When an agent cannot resolve a required project-specific value, it MUST:

1. **STOP** — do not guess or use defaults
2. **REPORT** — state exactly which value is missing and from which file
3. **INSTRUCT** — tell the user to populate the missing value in the correct file

**PROHIBITED:**
- ❌ Guessing project commands (e.g., assuming `npm test` because the project has a `package.json`)
- ❌ Using fallback/default commands when `agents.md` is missing
- ❌ Hardcoding project-specific values in agent definitions
- ❌ Skipping test types because no command is defined (report the gap instead)
