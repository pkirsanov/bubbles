# Bubbles Source Repo Command Registry

> Generated: 2026-04-05
> Platform: bash on Linux, macOS, or WSL
> Repo Type: Bubbles framework source repository
> Tech Stack: Bash, Markdown, YAML, agent and prompt definitions

---

## I. Context Loading Priority

| Priority | File | Purpose |
|----------|------|---------|
| 1 | `.specify/memory/constitution.md` | Repo governance for this source checkout |
| 2 | `.specify/memory/agents.md` | Command registry and file layout |
| 3 | `.github/copilot-instructions.md` | Source-repo operating rules |
| 4 | `agents/bubbles_shared/critical-requirements.md` | Top-priority universal constraints |
| 5 | `agents/bubbles_shared/agent-common.md` | Shared workflow and evidence rules |
| 6 | `README.md` | Source-repo overview and maintainer entry points |

---

## II. Design Document References

| Document | Path | Purpose |
|----------|------|---------|
| Framework overview | `README.md` | Source-repo layout, maintainer entry points, install model |
| Maintainer cheatsheet | `docs/CHEATSHEET.md` | Common workflow and framework ops commands |
| Installation guide | `docs/guides/INSTALLATION.md` | Install and upgrade behavior |
| Agent manual | `docs/guides/AGENT_MANUAL.md` | Framework operating model |
| Control plane design | `docs/guides/CONTROL_PLANE_DESIGN.md` | Registry-driven delegation and certification design |
| Framework ops recipe | `docs/recipes/framework-ops.md` | Canonical framework-maintainer command surface |

---

## III. Verification Commands

### CLI Entrypoint

```text
CLI_ENTRYPOINT=bash bubbles/scripts/cli.sh
```

### Core Maintainer Commands

```text
FULL_VALIDATION=bash bubbles/scripts/cli.sh release-check
BUILD_COMMAND=bash bubbles/scripts/cli.sh framework-validate
CHECK_COMMAND=bash bubbles/scripts/cli.sh agnosticity
LINT_COMMAND=bash bubbles/scripts/cli.sh agnosticity
FORMAT_COMMAND=N/A - no repo-wide formatter command exists in the Bubbles source repo
HEALTH_CHECK_COMMAND=bash bubbles/scripts/cli.sh doctor
STATUS_COMMAND=bash bubbles/scripts/cli.sh doctor
DEV_ALL_COMMAND=N/A - this repo does not run an application stack
DEV_ALL_SYNTH_COMMAND=N/A - this repo has no synthetic runtime stack
DOWN_COMMAND=N/A - this repo has no long-running stack to stop
```

### Compatibility Aliases For Legacy Agents

These keys stay present because some installed agents still read the older bootstrap names. They intentionally point at the real framework validation surfaces in this source repo.

```text
UNIT_TEST_COMMAND=bash bubbles/scripts/cli.sh framework-validate
INTEGRATION_TEST_COMMAND=bash bubbles/scripts/cli.sh framework-validate
E2E_TEST_COMMAND=bash bubbles/scripts/cli.sh release-check
```

### Split Test Keys

```text
UNIT_TEST_RUST_COMMAND=N/A - no Rust unit-test tier in this repo
UNIT_TEST_WEB_COMMAND=N/A - no web unit-test tier in this repo
FUNCTIONAL_TEST_COMMAND=bash bubbles/scripts/cli.sh framework-validate
INTEGRATION_AND_E2E_API_COMMAND=N/A - no application API integration suite in this repo
UI_UNIT_TEST_COMMAND=N/A - no standalone UI unit suite in this repo
E2E_API_TEST_COMMAND=N/A - no application API E2E suite in this repo
E2E_UI_TEST_COMMAND=N/A - no browser E2E suite in this repo
E2E_UI_COMMAND=N/A - no browser E2E suite in this repo
STRESS_TEST_COMMAND=N/A - no stress test suite is defined for the framework repo
SECURITY_COMMAND=N/A - no dedicated security scanner script is defined in this repo
```

### Frequently Used CLI Subcommands

```text
bash bubbles/scripts/cli.sh help
bash bubbles/scripts/cli.sh lint <spec>
bash bubbles/scripts/cli.sh guard <spec>
bash bubbles/scripts/cli.sh scan <spec>
bash bubbles/scripts/cli.sh docs-registry effective
bash bubbles/scripts/cli.sh framework-validate
bash bubbles/scripts/cli.sh release-check
bash bubbles/scripts/cli.sh repo-readiness .
bash bubbles/scripts/cli.sh run-state --all
```

---

## IV. Code Patterns

| Category | Convention |
|----------|-----------|
| Framework source | `agents/`, `prompts/`, `bubbles/`, `templates/`, `docs/` |
| Shell validation surfaces | `bubbles/scripts/*.sh` |
| Specs and packets | `specs/` |
| Repo memory and control plane | `.specify/memory/`, `.specify/runtime/`, `.specify/metrics/` |
| Downstream install payload | Downstream repos receive the installed framework under `.github/`, but source-of-truth edits belong in the repo-root framework directories |

### Naming Conventions

- Agent definitions live in `agents/bubbles.*.agent.md`.
- Prompt shims live in `prompts/bubbles.*.prompt.md`.
- Shared governance docs live in `agents/bubbles_shared/*.md`.
- Maintainer scripts live in `bubbles/scripts/*.sh`.

### Required Practices

- Do not invent `./bubbles.sh` in the source repo; use `bash bubbles/scripts/cli.sh` or the specific script under `bubbles/scripts/`.
- For framework-source validation, prefer `framework-validate` during active work and `release-check` before shipping.
- Keep framework-source edits in the repo-root source directories, not downstream installed copies.

---

## V. Error Resolution

1. Read the full command output.
2. Determine whether the failure is in source files, generated docs, or framework registries.
3. Re-run the exact source-repo command after the fix.
4. Use `release-check` for ship-readiness, not just a single narrow selftest.

---

## VI. Quality Standards

- No fabricated commands, evidence, or repo surfaces.
- No bootstrap placeholders where the source repo has a real command.
- Release-facing changes should pass `framework-validate`; release candidates should pass `release-check`.

---

## VII. Sources of Truth

| Item | Source |
|------|--------|
| Commands | This file |
| Framework CLI and scripts | `bubbles/scripts/` |
| Repo policies | `.github/copilot-instructions.md` |
| Governance | `.specify/memory/constitution.md` |
| Shared rules | `agents/bubbles_shared/agent-common.md` |
| Workflow registry | `bubbles/workflows.yaml` |
