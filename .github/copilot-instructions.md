# Bubbles Source Repository Guidelines

Maintained for the Bubbles framework source repository. This checkout does not host a product runtime; the authoritative maintainer command surface lives in `.specify/memory/agents.md` and `bubbles/scripts/cli.sh`.

---

## Commands

| Action | Command | Timeout |
|--------|---------|---------|
| Build all | `bash bubbles/scripts/cli.sh framework-validate` | 30 min |
| Test all | `bash bubbles/scripts/cli.sh framework-validate` | 30 min |
| Lint | `bash bubbles/scripts/cli.sh agnosticity` | 10 min |
| Format | `N/A - no repo-wide formatter command exists in the Bubbles source repo` | N/A |
| Start dev | `N/A - this repo does not run an application stack` | N/A |
| Stop all | `N/A - this repo does not run an application stack` | N/A |
| Status | `bash bubbles/scripts/cli.sh doctor` | 30 sec |

---

## Testing Requirements

| Test Type | Category | Command | Required? |
|-----------|----------|---------|-----------|
| Framework validation | `framework` | `bash bubbles/scripts/cli.sh framework-validate` | Always |
| Release readiness | `release` | `bash bubbles/scripts/cli.sh release-check` | Before shipping framework changes |
| Artifact lint | `artifact` | `bash bubbles/scripts/cli.sh lint <spec>` | When spec artifacts change |
| Transition guard | `guard` | `bash bubbles/scripts/cli.sh guard <spec>` | When scope or state transitions change |
| Repo readiness advisory | `readiness` | `bash bubbles/scripts/cli.sh repo-readiness .` | When refining downstream install guidance |

### Framework Validation Reality

- The source repo validates framework behavior through script-driven selftests, guard fixtures, and registry linting rather than a live product stack.
- `framework-validate` is the canonical maintainer check during active development.
- `release-check` is the canonical ship-readiness surface before publishing installer-facing changes.

### Adversarial Regression Tests For Bug Fixes

- Every bug-fix regression test MUST include at least one adversarial case that would fail if the bug were reintroduced.
- Tautological regressions are forbidden: if all fixtures already satisfy the broken filter/gate/path, the regression cannot detect the bug.
- Required tests MUST NOT use bailout returns such as `if (page.url().includes('/login')) { return; }` or equivalent failure-condition early exits.

---

## Terminal Discipline

See [terminal-discipline.instructions.md](instructions/terminal-discipline.instructions.md) (auto-loaded via `applyTo: "**"`) for:
- No piping/redirecting output into files — use IDE file tools
- No truncating command output (`head`, `tail`, filters) — always full output
- Always use `./bubbles.sh` — no direct tool invocation

---

## Bubbles Artifacts & Workflow (MANDATORY for ALL work)

**This applies to ALL work, whether initiated via a `bubbles.*` prompt or a regular agent request.**

Full workflow rules, artifact templates, and verification gates are in:
- [agent-common.md](agents/bubbles_shared/agent-common.md) — Anti-Fabrication Policy, Execution Evidence Standard, Canonical Test Taxonomy
- [scope-workflow.md](agents/bubbles_shared/scope-workflow.md) — Scope templates, artifact structure, phase execution flow

### Required Artifacts (BLOCKING)

Before feature work begins, ALL artifacts must exist in `specs/[feature]/`:

| Artifact | Purpose |
|----------|---------|
| spec.md | Feature specification |
| design.md | Design document |
| scopes.md | Scope definitions + DoD |
| report.md | Execution evidence |
| uservalidation.md | User acceptance |
| state.json | Execution state |

### Work Classification

All work MUST be organized under feature or bug folders:
- Features: `specs/NNN-feature-name/`
- Bugs: `specs/[feature]/bugs/BUG-NNN-description/`

---

## Key Locations

```
Source code:     agents/, prompts/, bubbles/, templates/, docs/
Tests:           bubbles/scripts/*selftest.sh, specs/, docs/examples/
Specs:           specs/
Config:          bubbles/workflows.yaml, bubbles/agent-capabilities.yaml, bubbles/agent-ownership.yaml, .specify/memory/
```

---

## Docker Bundle Freshness Configuration

Not applicable in the Bubbles source repo because this checkout does not serve a Docker-hosted frontend bundle.

| Key | Value |
|-----|-------|
| Frontend container | `N/A - no frontend container in the source repo` |
| Frontend image | `N/A - no frontend image in the source repo` |
| Static root | `N/A - no static bundle served from this repo` |
| Stop command | `N/A - no application stack to stop` |
| Build command | `N/A - no Docker-hosted frontend bundle to build` |
| Start command | `N/A - no application stack to start` |
| Bundler | `N/A - no frontend bundler in the source repo` |

---

## Pre-Completion Self-Audit

Before marking ANY task "done":

```bash
# 1. Verify test files exist
ls -la [every-test-file-in-test-plan]

# 2. Verify no incomplete work markers
grep -r "TODO\|FIXME\|HACK\|STUB" [changed-files]

# 3. Run tests
./bubbles.sh test

# 4. Run artifact lint
bash .github/bubbles/scripts/artifact-lint.sh specs/<NNN-feature-name>

# 5. Run implementation reality scan
bash .github/bubbles/scripts/implementation-reality-scan.sh specs/<NNN-feature-name> --verbose

# 6. Run state transition guard
bash .github/bubbles/scripts/state-transition-guard.sh specs/<NNN-feature-name>

# 7. Audit live-system tests for interception before claiming they are real-stack
grep -rn 'page\.route\|context\.route\|route(\|intercept(\|cy\.intercept\|msw\|nock\|wiremock\|responses' [live-system-test-files]

# 8. Audit required regressions for silent-pass bailout patterns
bash .github/bubbles/scripts/regression-quality-guard.sh [required-e2e-files]
bash .github/bubbles/scripts/regression-quality-guard.sh --bugfix [required-e2e-files]
```
