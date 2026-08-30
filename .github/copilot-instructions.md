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

### G028 Privileged Reality-Scan Boundary

Use only the canonical Bubbles CLI for an authoritative reality scan:

```bash
# Framework source checkout
bash bubbles/scripts/cli.sh scan <classified-work-path> --verbose

# Installed downstream checkout
bash .github/bubbles/scripts/cli.sh scan <classified-work-path> --verbose
```

- `cli.sh scan` and transition-guard Check 16 enter `privileged-bash-entry-v1` directly.
- They establish `/usr/bin/env -i`, `BUBBLES_SECURITY_ENTRY_MODE=direct`, and `/bin/bash -p` before scanner module sourcing.
- A raw `implementation-reality-scan.sh` invocation is compatibility-only.
- Its `compat-reexec` path cannot attest to or reverse pre-boundary contamination. It cannot supply canonical validation evidence.
- Security authority requires fixed root-protected `/usr/bin/perl` under `root-protected-perl-supervisor-v1`.
- It also requires authenticated Python under `root-protected-native-python-v1`.
- Perl owns one direct worker, the fixed 30-second wall, the two-second grace, and fixed output limits.
- It signals only an unreaped worker, calls `waitpid`, and then emits `BPS1`.
- Bash holds only the Perl supervisor wait handle. Bash never signals a worker or watchdog PID.
- Worker text, pipe EOF, and descriptor-holding descendants never determine completion. This boundary makes no recursive descendant-containment claim.
- Diagnostics expose numeric status, closed enums, and protocol identities. They never replay raw worker output, environment values, or PIDs.
- Missing or untrusted Perl fails closed with `SUPERVISOR_UNAVAILABLE` or `SUPERVISOR_UNTRUSTED`.
- Never use a PATH-selected Perl, Bash supervisor, Python supervisor, external timeout, fallback, or bypass.
- Remediation must install or provide a root-protected fixed `/usr/bin/perl` and an authenticated Python toolchain. Do not suggest a weaker execution path.
- Accepted evidence binds the exact immutable candidate and epoch `privileged-native-supervision-v2`.
- It identifies `BSEC1`, `BPS1`, `PYSEC1`, `PYMOD1`, `SCS1`, `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, and `HAR-R3`.

---

## Terminal Discipline

See [terminal-discipline.instructions.md](instructions/terminal-discipline.instructions.md) (auto-loaded via `applyTo: "**"`) for:
- No piping/redirecting output into files — use IDE file tools
- No truncating command output (`head`, `tail`, filters) — always full output
- Always use `bash bubbles/scripts/cli.sh` (source repo) — no direct tool invocation

---

## Bubbles Artifacts & Workflow (MANDATORY for ALL work)

**This applies to ALL work, whether initiated via a `bubbles.*` prompt or a regular agent request.**

Full workflow rules, artifact templates, and verification gates are in:
- [agent-common.md](../agents/bubbles_shared/agent-common.md) — Anti-Fabrication Policy, Execution Evidence Standard, Canonical Test Taxonomy
- [scope-workflow.md](../agents/bubbles_shared/scope-workflow.md) — Scope templates, artifact structure, phase execution flow

### Source-Repo Evidence Model (G085 — no persistent `specs/`)

This is the canonical Bubbles **source** checkout. Per gate **G085**
(`bubbles/scripts/framework-dogfood-guard.sh`, wired into `framework-validate.sh`
and invoked as state-transition-guard Check 26), the source repo **MUST NOT**
keep persistent repo-local `specs/` execution packets. Its dogfood evidence
comes from `framework-validate.sh`, the hermetic `*selftest.sh` suite,
`bubbles/release-manifest.json`, and downstream or fixture specs — **not** from a
committed `specs/` tree. Framework changes here are proven by
`bash bubbles/scripts/cli.sh framework-validate` and `release-check`, not by a
spec folder.

### Downstream Artifact Workflow (consumer repos)

The `specs/`-based artifact workflow below governs **downstream consumer repos**
that install Bubbles (and the framework's own hermetic fixture repos) — it does
**not** create a persistent `specs/` tree in this source repo. In a consumer
repo, before feature work begins ALL artifacts must exist in `specs/[feature]/`:

| Artifact | Purpose |
|----------|---------|
| spec.md | Feature specification |
| design.md | Design document |
| scopes.md | Scope definitions + DoD |
| report.md | Execution evidence |
| uservalidation.md | User acceptance |
| state.json | Execution state |

#### Work Classification (consumer repos)

All consumer-repo work MUST be organized under feature or bug folders:
- Features: `specs/NNN-feature-name/`
- Bugs: `specs/[feature]/bugs/BUG-NNN-description/`

---

## Key Locations

```
Source code:     agents/, prompts/, bubbles/, templates/, docs/
Tests:           bubbles/scripts/*selftest.sh, tests/regression/, docs/examples/
Specs:           none persisted in source repo (G085); consumer repos use specs/NNN-feature/
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

# 3. Run framework validation (source repo has no ./bubbles.sh product CLI)
bash bubbles/scripts/cli.sh framework-validate

# 4. Run artifact lint (downstream/fixture spec dir)
bash bubbles/scripts/artifact-lint.sh specs/<NNN-feature-name>

# 5. Run implementation reality scan through the privileged CLI boundary
bash bubbles/scripts/cli.sh scan specs/<NNN-feature-name> --verbose

# 6. Run state transition guard
bash bubbles/scripts/state-transition-guard.sh specs/<NNN-feature-name>

# 7. Audit live-system tests for interception before claiming they are real-stack
grep -rn 'page\.route\|context\.route\|route(\|intercept(\|cy\.intercept\|msw\|nock\|wiremock\|responses' [live-system-test-files]

# 8. Audit required regressions for silent-pass bailout patterns
bash bubbles/scripts/regression-quality-guard.sh [required-e2e-files]
bash bubbles/scripts/regression-quality-guard.sh --bugfix [required-e2e-files]
```
