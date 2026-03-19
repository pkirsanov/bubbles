<!-- governance-version: 2.1.0 -->
# Shared Scope Workflow (Common to iterate & implement)

> **This file defines scope-specific workflow for `bubbles.iterate` and `bubbles.implement`.**
> For common patterns (Loop Guard, User Validation, etc.), see [agent-common.md](agent-common.md).
> For project-specific command resolution, see [project-config-contract.md](project-config-contract.md).
> 
> **Portability:** This file is **project-agnostic**. Commands are referenced as `[cmd]` placeholders resolved from `.specify/memory/agents.md`.

---

## ⚠️ PREREQUISITE: Common Patterns

**This file extends [agent-common.md](agent-common.md).** All patterns from that file apply:

- Loop Guard rules
- **Feature/Bug Folder Resolution - FAIL FAST (ONE search only, no loops)**
- User Validation Gate (blocking at start)
- User Validation Update (last step after audit - items checked `[x]` by default)
- Context Loading (tiered)
- Policy Compliance
- Scope Completion Requirements (ABSOLUTE - NO EXCEPTIONS)
- Test Execution Gate
- **Bug Fix Testing Requirements (unit, component, integration, E2E)**
- **Implementation Test Coverage Validation**
- **Fix ALL Test Failures Policy (including pre-existing)**
- **Bug Awareness (check for incomplete bugs before work)**

---

## ⚠️ ABSOLUTE PROHIBITIONS — FAKE/FABRICATED WORK (NON-NEGOTIABLE)

**These rules have ZERO tolerance. Violating any of them is an immediate policy failure.**

| What is Prohibited | Why | What Happens |
|---------------------|-----|--------------|
| Claiming "tests pass" without running tests | Fabrication — the system may be broken | Spec status reverts to `in_progress`, all DoD items unchecked |
| Writing expected output instead of actual output | Evidence is meaningless if fabricated | All evidence blocks invalidated, re-execution required |
| Batch-checking multiple DoD items in one edit | Prevents individual validation | All batch-checked items reverted to `[ ]` |
| Marking DoD items `[x]` at scope creation time | Pre-checking means no validation occurred | All pre-checked items reverted to `[ ]` |
| Narrative summaries as evidence | "Tests pass" is not evidence | Evidence block must be replaced with real terminal output |
| Template placeholders unfilled | "[ACTUAL terminal output]" is not evidence | Template text must be replaced with real output |
| Skipping specialist phases | Missing phases means incomplete verification | Spec cannot be promoted until all phases execute |
| Moving to next spec before current is complete | Previous work may be broken | Next spec blocked until current passes all gates |
| Default/fallback values in production code | `unwrap_or()`, `\|\| default`, `?? fallback`, `:-default` mask missing config and hide failures | Implementation blocked until all defaults removed and fail-fast applied |
| Stub/placeholder functions in production code | Stubs masquerade as real implementations | Scope cannot be Done until all stubs replaced with real implementations |
| Hardcoded data returned from API handlers | Fake data hides broken data-store integration | Reality scan (G028) blocks completion; handler must query real data store |
| Client caches used as data source | localStorage/IndexedDB/in-memory caches diverge from server truth | Implementation blocked until real API calls replace cache reads |

### Detection & Enforcement

All agents MUST apply **Fabrication Detection Heuristics** from `agent-common.md` (Gate G021) before claiming completion. The **audit agent** serves as the final verification checkpoint — if fabrication is detected during audit, the spec is blocked.

The **artifact lint script** (`artifact-lint.sh`) includes automated detection for:
- DoD items without evidence blocks
- Unfilled template placeholders
- Evidence blocks lacking terminal output signals (fabricated content)
- Narrative summary language
- Missing specialist phases in `completedPhases`
- Duplicate evidence blocks

The **implementation reality scan** (`implementation-reality-scan.sh`) includes automated detection for:
- Backend stub patterns (hardcoded vecs, fake/mock/stub functions)
- Frontend fake data (getSimulationData, import mock modules, hardcoded arrays)
- Frontend API call absence (hooks/services with zero fetch/axios calls)
- Default/fallback patterns (`unwrap_or`, `unwrap_or_default`, `|| default`, `?? fallback`, `getOrElse`)
- Prohibited simulation helpers in production code

---

## Canonical Folder Structure

See [agent-common.md](agent-common.md) → "Feature Folder Structure" for the canonical folder layout and naming conventions.

**Naming:** Feature folders: `NNN-kebab-case-name`. Scope folders: `NN-kebab-case-scope-name`.

**Required artifacts for new scope work:** `spec.md`, `design.md`, and either `scopes.md` (small specs) or `scopes/_index.md` + per-scope directories (large specs).

**⚠️ DEPRECATED:** Do NOT create folders under `specs/_iterations/`.

---

## ⛔ Scope Isolation Model (NON-NEGOTIABLE)

**Scopes are independent units of work. An agent picks up ONE scope and works ONLY within that scope's artifacts. Scopes MUST NOT cross into each other — each scope has its own Gherkin scenarios, test plan, DoD, and evidence.**

### Two Layout Modes (Based on Scope Count)

| Scope Count | Layout | When to Use |
|-------------|--------|-------------|
| **1–5 scopes** | **Single-file** — everything in `scopes.md` + `report.md` | Small features, bug fixes, simple specs |
| **6+ scopes** | **Per-scope directories** — `scopes/_index.md` + `scopes/NN-name/scope.md` + `scopes/NN-name/report.md` | Large features, multi-phase specs |

**Agents MUST check for the per-scope directory layout first.** If `scopes/_index.md` exists, use per-scope directories. If only `scopes.md` exists, use single-file mode.

### Per-Scope Directory Structure (6+ Scopes)

```
specs/NNN-feature-name/
├── spec.md                          # Shared — read-only during implementation
├── design.md                        # Shared — read-only during implementation
├── state.json                       # Spec-level orchestration + scope DAG
├── uservalidation.md                # Shared validation checklist
├── scopes/
│   ├── _index.md                    # Summary table + dependency DAG (lightweight)
│   ├── 01-scope-name/
│   │   ├── scope.md                 # Gherkin + plan + test plan + DoD for THIS scope only
│   │   └── report.md               # Evidence for THIS scope only
│   ├── 02-scope-name/
│   │   ├── scope.md
│   │   └── report.md
│   └── ...
```

**Isolation rules:**
- An agent working on scope 09 reads ONLY `scopes/09-*/scope.md` and writes ONLY to `scopes/09-*/report.md`
- An agent NEVER modifies another scope's `scope.md` or `report.md`
- The shared `_index.md` is updated only for status sync (status column in summary table)
- `state.json` is the machine-readable coordination point

### Scope Dependency DAG (Per-Scope Directory Mode)

**Scopes declare explicit dependencies instead of relying on strict sequential ordering.**

In `_index.md`, the dependency DAG replaces a linear sequence:

```markdown
## Dependency Graph

| # | Scope | Depends On | Surfaces | Status |
|---|-------|-----------|----------|--------|
| 01 | catalog-schema    | —          | Docs, Config     | Not Started |
| 02 | catalog-migration | 01         | Docs             | Not Started |
| 03 | catalog-compiler  | 01, 02     | Libs, CLI        | Not Started |
| 04 | context-plane     | —          | Backend          | Not Started |
| 05 | intent-engine     | 04         | Backend          | Not Started |
| 10 | html-viewer       | 03         | Docs, Libs       | Not Started |
| 13 | enforcement       | 03         | CI, Docs         | Not Started |
```

**Pickup rules:**
1. A scope can move to `In Progress` only when ALL scopes listed in its `Depends On` column are `Done`
2. Scopes with no dependencies (`—`) can start immediately and in parallel
3. An agent picks the **lowest-numbered eligible** scope (all deps done, status = Not Started)
4. Multiple agents can work different scopes in parallel if dependency constraints allow

In `state.json`, each scope declares its dependencies:

```json
{
  "scopeProgress": [
    {
      "scope": 1,
      "name": "Catalog Schema",
      "status": "not_started",
      "dependsOn": [],
      "scopeDir": "scopes/01-catalog-schema"
    },
    {
      "scope": 4,
      "name": "Context Plane",
      "status": "not_started",
      "dependsOn": [],
      "scopeDir": "scopes/04-context-plane"
    },
    {
      "scope": 10,
      "name": "HTML Viewer",
      "status": "not_started",
      "dependsOn": [3],
      "scopeDir": "scopes/10-html-viewer"
    }
  ]
}
```

### Legacy Format Migration (MANDATORY Before Starting Work)

**When an agent encounters a spec with `scopes.md` (single-file) that has 6+ scopes, it MUST refactor to the per-scope directory layout before starting implementation.**

#### Migration Protocol

1. **Read** the existing `scopes.md` to identify all scope sections
2. **Create** `scopes/_index.md` with the summary table and dependency DAG
3. **For each scope:** create `scopes/NN-scope-name/scope.md` by extracting that scope's section from `scopes.md` (Gherkin, plan, test plan, DoD)
4. **For each scope:** create `scopes/NN-scope-name/report.md` with the report template (extracting any existing evidence from `report.md`)
5. **Update** `state.json` to add `dependsOn` and `scopeDir` fields to each scope entry
6. **Rename** the original `scopes.md` to `scopes.md.legacy` (preserve, don't delete)
7. **Rename** the original `report.md` to `report.md.legacy` if evidence was split (preserve, don't delete)
8. **Apply the Tiered DoD** — collapse boilerplate DoD items (see Tiered DoD below) while migrating

**Migration is a NON-BLOCKING prerequisite** — agents do this as the first step before implementation, not as a separate spec/scope.

### Single-File Mode (1–5 Scopes)

For small specs, the existing single-file model continues to work:

```
specs/NNN-feature-name/
├── spec.md, design.md, scopes.md, report.md, uservalidation.md, state.json
```

All scopes live in `scopes.md`. All evidence lives in `report.md`. This is fine when the total DoD item count is manageable (≤50 items across all scopes).

---

## Status Transition Gate

Use these rules for every scope status change.

1. A scope can move to `In Progress` only when all scopes in its `dependsOn` list are `Done` (DAG mode) OR all prior scopes are `Done` (sequential mode).
2. A scope can move to `Done` only when:
   - Scope DoD items in its `scope.md` (or `scopes.md`) are all checked `[x]`
   - Matching raw evidence is present in the scope's `report.md` (must contain legitimate terminal output signals per command-backed block)
   - Scope entry in `state.json` is updated in `scopeProgress` and `completedScopes`
   - **Zero deferral language exists in scope artifacts** (Gate G040 — "deferred", "future scope", "follow-up", "out of scope", "will address later", "punt", "postpone", "skip for now", "not implemented yet", "placeholder", "temporary workaround" are ALL blocking)
3. If evidence is missing, contradictory, a required test type is absent, or deferral language is present, scope status must remain `In Progress`.
4. Spec status cannot move to `done` until ALL scopes are `Done` and `completedScopes` contains all scope IDs.

**Status sync requirements:**

| Layout Mode | Checklist Source | Evidence Source | Machine Status |
|-------------|-----------------|----------------|----------------|
| Single-file | `scopes.md` | `report.md` | `state.json` |
| Per-scope dirs | `scopes/NN-name/scope.md` | `scopes/NN-name/report.md` | `state.json` |
| Both modes | `scopes/_index.md` status column (if exists) | — | `state.json` is authoritative |

---

## Artifact Templates

Use the shared feature templates in [feature-templates.md](feature-templates.md) when creating `spec.md`, `design.md`, `scopes.md`, and `report.md`.

**Quick-start (feature artifacts):** Start with the `spec.md` and `scopes.md` templates, then fill `design.md`, `uservalidation.md`, and `state.json` from [feature-templates.md](feature-templates.md).

### 1a. `scopes/_index.md` - Scope Index (Per-Scope Directory Mode)

```markdown
# Scope Index: [Feature Name]

Links: [spec.md](../spec.md) | [design.md](../design.md) | [uservalidation.md](../uservalidation.md)

## Scope Ordering Rationale
[Brief explanation of why scopes are ordered/grouped this way]

## Dependency Graph

| # | Scope | Depends On | Surfaces | Status |
|---|-------|-----------|----------|--------|
| 01 | [scope-name] | —    | [surfaces] | Not Started |
| 02 | [scope-name] | 01   | [surfaces] | Not Started |
| 03 | [scope-name] | 01, 02 | [surfaces] | Not Started |

## Pickup Rule

A scope moves to `In Progress` when ALL scopes in its `Depends On` column are `Done`.
An agent picks the **lowest-numbered eligible** scope (all deps done, status = Not Started).

## Spec Completion

Spec status CANNOT be `done` until ALL scopes in this table are `Done` AND zero deferral language exists in any scope artifact (Gate G040). Deferred work = spec stays `in_progress`.
```

### 1b. Per-Scope `scope.md` (Per-Scope Directory Mode)

Each scope directory contains its own `scope.md` with ONLY that scope's content:

```markdown
# Scope [NN]: [Scope Name]

**Status:** Not Started | In Progress | Done | Blocked
**Priority:** P0 | P1 | P2 | P3
**Depends On:** [list of scope numbers, or — for no dependencies]

Links: [spec.md](../../spec.md) | [design.md](../../design.md) | [_index.md](../_index.md)

### Gherkin Scenarios
- Given/When/Then scenarios (each MUST map to a test and DoD evidence item)

### UI Scenario Matrix (Required when UI changes exist)
- User-visible UI flows with e2e-ui test mapping

### Implementation Plan
- Files/surfaces to modify

### Test Plan (ALL TYPES REQUIRED — per Canonical Test Taxonomy in agent-common.md)

**E2E tests are MANDATORY for every scope.** Tests MUST encode exact spec/Gherkin scenarios (no approximations). Live system tests MUST use ephemeral test environment. No skipped required tests.

**⚠️ ACTUAL TEST SPECIFICITY REQUIRED (NON-NEGOTIABLE):**
E2E rows MUST name the **specific Gherkin scenario or UI Scenario ID** they validate.

| Test Type | Category | File/Location | Description | Command | Live System Required |
|-----------|----------|---------------|-------------|---------|---------------------|
| ... | ... | ... | ... | ... | ... |

**Stress tests REQUIRED when SLA/latency targets exist for this scope's endpoints.**

### Definition of Done — Tiered Validation

See the Tiered DoD Model section below for format rules.

#### Core Items (scope-specific — each needs individual inline evidence with real terminal output)

**Evidence legitimacy requirement:** Evidence blocks MUST contain verbatim terminal output with recognizable signals (test pass/fail counts, file paths, exit codes, timing, build tool names, HTTP status codes, etc.). Blocks that lack at least 2 distinct terminal output signal types will be rejected as fabricated. Line count alone is NOT sufficient — content must be real.

- [ ] Implementation complete — [scope-specific description]
  - Raw output evidence (inline, verbatim terminal output only):
    `​``
    [PASTE VERBATIM terminal output here — must contain real test/build/command output]
    `​``
- [ ] [Feature behavior validated — scope-specific item]
  - Raw output evidence (inline, verbatim terminal output only):
    `​``
    [PASTE VERBATIM terminal output here]
    `​``
- [ ] Unit tests pass (`unit`) — [scope-specific tests described]
  - Raw output evidence (inline, verbatim terminal output only):
    `​``
    [PASTE VERBATIM terminal output here — must show test names + pass/fail counts]
    `​``
- [ ] Integration tests pass (`integration`)
  - Raw output evidence (inline, verbatim terminal output only):
    `​``
    [PASTE VERBATIM terminal output here — must show test names + pass/fail counts]
    `​``
- [ ] E2E tests for new behavior pass (`e2e-api`/`e2e-ui`)
  - Raw output evidence (inline, verbatim terminal output only):
    `​``
    [PASTE VERBATIM terminal output here — must show test names + pass/fail counts]
    `​``
- [ ] E2E regression tests pass
  - Raw output evidence (inline, verbatim terminal output only):
    `​``
    [PASTE VERBATIM terminal output here]
    `​``
- [ ] Stress tests pass (REQUIRED if scope defines latency SLAs)
  - Raw output evidence (inline, verbatim terminal output only):
    `​``
    [PASTE VERBATIM terminal output here]
    `​``

#### Build Quality Gate (standard — single combined evidence block)

All checks below verified with one combined evidence block. If ANY fails, scope stays In Progress.

- [ ] Integration completeness verified (Gate G029) — all new artifacts wired into the system: endpoints called by frontends (or documented external-only), libraries imported by consumers, frontend uses real backend APIs (no stubs/mocks), features reachable via navigation, services deployed, DB schema consumed, proto contracts used by both sides
  - Raw output evidence (inline — grep for endpoint usage, import statements, route definitions, API calls):

- [ ] No defaults/fallbacks in production code (Gate G030) — zero `unwrap_or()`, `|| default`, `?? fallback`, `os.getenv("K", "default")` patterns in implementation files; all config fails fast if missing
  - Raw output evidence (inline — reality scan Scan 5 output):

- [ ] Build quality gate passes: zero warnings + no TODOs/FIXMEs/stubs + lint/format clean + artifact lint exits 0 + documentation updated
  - Raw output evidence (inline — combined output from build, grep, lint, artifact-lint):
    `​``
    [PASTE VERBATIM terminal output here — must contain real build/lint/grep output]
    `​``

**Pre-Completion:** See [agent-common.md](agent-common.md) → Anti-Fabrication Gates (including G027 Phase-Scope Coherence, G028 Implementation Reality Scan, G029 Integration Completeness, and G030 No Defaults/No Fallbacks) and Pre-Completion Self-Audit.
```

### 1c. `scopes.md` - Single-File Mode (1–5 Scopes)

For small specs, the traditional single-file format with the same Tiered DoD model:

```markdown
# Scopes

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Scope: [scope-name]

**Status:** Not Started | In Progress | Done | Blocked
**Priority:** P0 | P1 | P2 | P3

### Gherkin Scenarios
- Given/When/Then scenarios (each MUST map to a test and DoD evidence item)

### UI Scenario Matrix (Required when UI changes exist)
- User-visible UI flows with e2e-ui test mapping, user-visible assertions, and cache/bundle freshness checks

### Implementation Plan
- Files/surfaces to modify

### Test Plan (ALL TYPES REQUIRED — per Canonical Test Taxonomy in agent-common.md)

**E2E tests are MANDATORY for every scope.** Tests MUST encode exact spec/Gherkin scenarios (no approximations). Live system tests MUST use ephemeral test environment. No skipped required tests. See [agent-common.md](agent-common.md) for test type definitions, integrity rules, and anti-proxy checklist.

**⚠️ ACTUAL TEST SPECIFICITY REQUIRED (NON-NEGOTIABLE):**
E2E rows MUST name the **specific Gherkin scenario or UI Scenario ID** they validate. Generic descriptions like `[API workflow]` or `[UI workflow]` are **FORBIDDEN**. Each E2E row must answer: *"Which exact scenario from this scope does this test prove works?"*

| Test Type | Category | File/Location | Description | Command | Live System Required |
|-----------|----------|---------------|-------------|---------|---------------------|
| Unit | `unit` | `[path]` | [isolated, mocked deps] | `[cmd]` | No |
| Functional | `functional` | `[path]` | [may use real deps] | `[cmd]` | Optional |
| Integration | `integration` | `[path]` | [multi-component, real deps, no mocks] | `[cmd]` | Yes |
| UI Unit | `ui-unit` | `[path]` | [component test, mocked backend] | `[cmd]` | No |
| E2E API | `e2e-api` | `[path]` | [API workflow, LIVE system, no mocks] | `[cmd]` | Yes |
| E2E UI | `e2e-ui` | `[path]` | [UI workflow, LIVE system, no mocks] | `[cmd]` | Yes |
| E2E Regression | `e2e-api`/`e2e-ui` | `[path]` | [existing workflows still work] | `[cmd]` | Yes |
| Stress | `stress` | `[path]` | [high-concurrency burst] | `[cmd]` | Yes |

**Stress tests REQUIRED when SLA/latency targets exist for this scope's endpoints.**

### Definition of Done — Tiered Validation

#### Core Items (scope-specific — each needs individual inline evidence with real terminal output)

- [ ] Implementation complete
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here — must contain real test/build/command output]
    ```
- [ ] Unit tests pass (`unit`)
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here — must show test names + pass/fail counts]
    ```
- [ ] Integration tests pass (`integration`)
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here — must show test names + pass/fail counts]
    ```
- [ ] E2E tests for new code pass (`e2e-api`/`e2e-ui`)
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here — must show test names + pass/fail counts]
    ```
- [ ] E2E regression tests pass
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here]
    ```
- [ ] Stress tests pass (REQUIRED if scope defines latency SLAs)
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here]
    ```

#### Build Quality Gate (standard — single combined evidence block)

- [ ] Integration completeness verified (Gate G029) — all new artifacts wired into the system: endpoints called by frontends (or documented external-only), libraries imported by consumers, frontend uses real backend APIs (no stubs/mocks), features reachable via navigation, services deployed, DB schema consumed, proto contracts used by both sides
  - Raw output evidence (inline — grep for endpoint usage, import statements, route definitions, API calls):
    ```
    [PASTE VERBATIM grep/ls output here]
    ```
- [ ] Vertical slice complete (Gate G035, REQUIRED for cross-layer scopes) — every frontend API call maps to a .route()-wired backend handler, gateway forwards all service routes, no orphaned handlers, E2E tests exercise full stack. Skip line if scope is pure-frontend or pure-backend.
  - Raw output evidence (inline — cross-reference frontend API calls ↔ backend router registrations ↔ gateway forwarding):
    ```
    [PASTE VERBATIM cross-reference output here — frontend endpoint calls matched to backend .route() registrations]
    ```
- [ ] No defaults/fallbacks in production code (Gate G030) — zero `unwrap_or()`, `|| default`, `?? fallback`, `os.getenv("K", "default")` patterns; all config fails fast if missing
  - Raw output evidence (inline — reality scan Scan 5 output):
    ```
    [PASTE VERBATIM reality scan output here]
    ```
- [ ] Build quality gate passes: zero warnings + no TODOs/FIXMEs/stubs + lint/format clean + artifact lint exits 0 + documentation updated
  - Raw output evidence (inline — combined output from build, grep, lint, artifact-lint):
    ```
    [PASTE VERBATIM terminal output here]
    ```

**Scope-specific items:**
- [ ] [Item 1]
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here]
    ```

**Pre-Completion:** See [agent-common.md](agent-common.md) → Anti-Fabrication Gates (0-8, G027, G028, G029, G030, G035) and Pre-Completion Self-Audit.
```

### 2. `report.md` - Execution Reports

**In per-scope directory mode:** Each scope has its own `scopes/NN-name/report.md` containing ONLY that scope's evidence.
**In single-file mode:** A single `report.md` file with sections appended per scope execution.

```markdown
# Execution Report: [Scope Name]

Links: [scope.md](scope.md) | [spec.md](../../spec.md) | [_index.md](../_index.md)
(Adjust links for single-file mode: [scopes.md](scopes.md) | [uservalidation.md](uservalidation.md))

## Scope: [scope-name] - [YYYY-MM-DD HH:MM]

### Summary
- What changed (files/surfaces)
- Scenarios validated

### Decision Record (Required for non-trivial work)
- Option A / Option B: [summary + tradeoffs]
- Chosen: [option + rationale]
- Failure Modes → Tests: [mapping]

### Completion Statement (MANDATORY)
- **Status:** done | blocked | failed | specs_hardened | docs_updated | validated
- **Workflow Mode:** [active mode]
- **Status Ceiling:** [mode's statusCeiling from workflows.yaml]
- **Claims:** [claim] → Evidence: [inline in scope.md DoD]
- **Unknowns:** [none OR items]
- **Next Actions:** [action]

### Test Evidence (ALL TYPES REQUIRED)

**⚠️ Each section MUST contain VERBATIM terminal output with recognizable signals (test pass/fail counts, file paths, exit codes, timing, tool names). Agent-written summaries are FORBIDDEN. Evidence blocks are validated for terminal output legitimacy, not just line count. See [agent-common.md](agent-common.md) → Execution Evidence Standard and Anti-Fabrication Policy.**

**Per-type section template** (repeat for each test type: unit, functional, integration, ui-unit, e2e-api, e2e-ui, e2e-regression, stress, skip-check):

#### [Test Type] (`[category]`)
- **Executed:** YES/NO | **Command:** `[exact cmd]` | **Exit Code:** [actual]
- **Tests Executed:** [count] | **New Tests Added:** [list]
- **Live System:** [URL/port, if applicable] | **Environment:** [test env]
- **Output:**
  ```
  [PASTE VERBATIM terminal output — must contain real test/build output with pass/fail counts, file paths, timing]
  ```

### Coverage Report
- Overall: XX% | Threshold: YY% | Status: ✅/❌

### Lint/Quality
- Command: `[cmd]` | Exit: 0 | Warnings: [count] | Errors: 0

### Validation Summary
- Build: ✅ | Tests: ✅ | Coverage: ✅ XX% | Lint: ✅

### Audit Verdict
- Status: Clean/Issues | Command: [cmd] | Output: [key lines]
```

### 3. `uservalidation.md` - User Acceptance Checklist

See [agent-common.md](agent-common.md#user-validation-gate-mandatory) for template and rules.

Key points:
- Items are **CHECKED `[x]` by default** when created (post-audit, already validated)
- User can UNCHECK `[ ]` to report that a feature is NOT working as expected
- Unchecked items are **USER-REPORTED REGRESSIONS** — the user found the behavior broken
- **bubbles.validate** investigates root cause of each unchecked item and documents findings
- Unchecked items are **BLOCKING** — must be fixed before new work proceeds

### 4. `state.json` - Execution State (Canonical Schema v2)

> **Version:** 2 — All new state.json files MUST use this schema. Existing v1 files are tolerated but should be migrated.

#### Feature state.json

```json
{
  "version": 2,
  "featureDir": "specs/NNN-feature-name",
  "featureName": "Human-Readable Feature Name",
  "status": "not_started | in_progress | blocked | done | specs_hardened | docs_updated | validated",
  "workflowMode": "full-delivery | spec-scope-hardening | docs-only | ...",
  "currentScope": null,
  "currentPhase": null,
  "completedScopes": ["scope-1-name", "scope-2-name"],
  "completedPhases": ["select", "implement", "test", "docs", "validate", "audit", "chaos"],
  "failures": [],
  "executionHistory": [],
  "lastUpdatedAt": "RFC3339"
}
```

#### Bug state.json

```json
{
  "version": 2,
  "bugDir": "specs/NNN-feature/bugs/BUG-NNN-description",
  "bugId": "BUG-NNN",
  "status": "not_started | in_progress | blocked | done",
  "currentPhase": null,
  "mode": "bugfix-fastlane | full-delivery | ...",
  "executionHistory": [],
  "createdAt": "RFC3339",
  "lastUpdatedAt": "RFC3339"
}
```

#### Schema Rules (MANDATORY)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `version` | integer | YES | Always `2` for new files |
| `featureDir` / `bugDir` | string | YES | Relative path from repo root |
| `featureName` / `bugId` | string | YES | Human-readable identifier |
| `status` | string | YES | One of the allowed values |
| `workflowMode` / `mode` | string | YES | Mode that produced this state |
| `currentScope` | string or null | YES | Currently active scope name, or null |
| `currentPhase` | string or null | YES | Currently active phase, or null |
| `completedScopes` | string[] | YES | Array of scope NAME strings |
| `completedPhases` | string[] | YES | Preferred format for new files: array of phase name strings. Legacy object entries with `phase`, `completedAt`, and optional `details` are still accepted by the repo scripts for backward compatibility |
| `failures` | array | YES | Empty array `[]` if no failures |
| `executionHistory` | array | YES | Chronological log of all agent/workflow runs against this spec (see Execution History Schema below). Empty array `[]` initially |
| `lastUpdatedAt` | string | YES | RFC3339 timestamp |

#### Execution History Schema (MANDATORY)

Every time a Bubbles agent or workflow runs against a spec, it MUST append an entry to `executionHistory`. This provides a complete audit trail of all work performed.

```json
{
  "executionHistory": [
    {
      "id": 1,
      "agent": "bubbles.workflow",
      "workflowMode": "full-delivery",
      "startedAt": "2026-03-15T10:00:00Z",
      "completedAt": "2026-03-15T12:30:00Z",
      "statusBefore": "not_started",
      "statusAfter": "done",
      "phasesExecuted": ["select", "implement", "test", "docs", "validate", "audit", "chaos", "finalize"],
      "scopesCompleted": ["scope-1-name", "scope-2-name"],
      "summary": "Full delivery of 2 scopes. All tests pass, all gates satisfied."
    },
    {
      "id": 2,
      "agent": "bubbles.harden",
      "workflowMode": "harden-to-doc",
      "startedAt": "2026-03-16T09:00:00Z",
      "completedAt": "2026-03-16T09:45:00Z",
      "statusBefore": "done",
      "statusAfter": "in_progress",
      "phasesExecuted": ["harden"],
      "scopesCompleted": [],
      "summary": "Found 3 coverage gaps. Reverted status to in_progress. Added new DoD items."
    }
  ]
}
```

**Execution History Field Reference:**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | integer | YES | Sequential integer (1, 2, 3...). Next = length of array + 1 |
| `agent` | string | YES | Agent that initiated the run (e.g., `bubbles.workflow`, `bubbles.iterate`, `bubbles.harden`) |
| `workflowMode` | string | YES | Workflow mode used (e.g., `full-delivery`, `harden-to-doc`, `bugfix-fastlane`) |
| `startedAt` | string | YES | RFC3339 timestamp when the run started |
| `completedAt` | string | YES | RFC3339 timestamp when the run ended |
| `statusBefore` | string | YES | Value of `status` field BEFORE this run began |
| `statusAfter` | string | YES | Value of `status` field AFTER this run completed |
| `phasesExecuted` | string[] | YES | Phases that executed during this run |
| `scopesCompleted` | string[] | YES | Scopes that reached "Done" during this run (empty if none) |
| `summary` | string | YES | Brief description of what was accomplished or why status changed |

**Rules:**
- Entries are **append-only** — NEVER modify or delete existing entries
- `id` is a simple sequential counter, not a UUID
- Each workflow invocation = one entry (even if it spans multiple phases/scopes)
- Specialist agents invoked by a workflow orchestrator do NOT create separate entries — they are covered by the orchestrator's entry
- Standalone specialist runs (e.g., user directly invokes `bubbles.harden`) DO create their own entry
- `statusBefore` captures the status at read-time before the agent makes any changes
- `statusAfter` captures the final status when the agent finishes (may differ from `statusBefore` if the run changed status)

#### Deprecated Fields (DO NOT USE in new files)

| Deprecated | Use Instead |
|------------|-------------|
| `featureId` | `featureDir` |
| `featureFile` | `featureDir` |
| `selectedScopeName` | `currentScope` |
| `created` / `updatedAt` / `createdAt` | `lastUpdatedAt` |
| `completedPhases` as objects `[{phase, completedAt}]` | Prefer `completedPhases` as strings `["select", "implement"]` in new files; legacy object entries remain supported during migration |
| `completedScopes` as numbers `[1, 2, 3]` | `completedScopes` as strings `["scope-name"]` |
| `scopeProgress` | Scope status lives in `scopes.md` / `scope.md`, not state.json |
| `scopeLayout` | Detected from filesystem (presence of `scopes/` dir) |
| `statusDiscipline` | Rules in scope-workflow.md, not embedded in state.json |
| `phaseHistory` | `executionHistory` — the new field captures the same information (agent, timestamps, phases) plus workflow mode and status transitions |

**Status field semantics:**
- `done` — Implementation complete, all tests pass, all gates satisfied. Only set by modes with `statusCeiling: done`.
- `specs_hardened` — Spec/design/scopes improved. No implementation work done. Set by `spec-scope-hardening` mode.
- `docs_updated` — Documentation updated. No implementation work done. Set by `docs-only` mode.
- `validated` — Validation/audit completed. No implementation work done. Set by `validate-only`/`audit-only` modes.
- `in_progress` — Work started but not finished. Used during active execution or by `resume-only`.
- `blocked` — Cannot proceed due to unresolved failures or missing inputs.

---

## Artifact Cross-Linking (MANDATORY)

All generated documents MUST include links to related artifacts:

**Single-file mode:**

| Document | Must Link To |
|----------|--------------|
| `scopes.md` | `spec.md`, `design.md`, `report.md`, `uservalidation.md` |
| `report.md` | `scopes.md` (specific scope), `uservalidation.md` |
| `uservalidation.md` | `report.md` (evidence sections) |

**Per-scope directory mode:**

| Document | Must Link To |
|----------|--------------|
| `scopes/_index.md` | `spec.md`, `design.md`, `uservalidation.md` |
| `scopes/NN/scope.md` | `spec.md`, `design.md`, `_index.md` |
| `scopes/NN/report.md` | `scope.md` (same directory), `spec.md`, `_index.md` |
| `uservalidation.md` | scope evidence (per-scope `report.md` files) |

---

## Execution Phases

Both iterate and implement follow these phases:

### Phase 0: Context & Validation
1. Resolve `{FEATURE_DIR}` from arguments
2. Load/validate `spec.md`, `design.md`, `scopes.md`
3. **Run User Validation Gate** (per [agent-common.md](agent-common.md))
4. **Run Baseline Health Check** (per [agent-common.md](agent-common.md)) — record pre-change test counts
5. Update `state.json`

### Phase 1: Scope Selection/Definition
- **implement:** Select next eligible scope from `scopes/_index.md` (per-scope dir mode) or `scopes.md` (single-file mode) using the Pickup Rule (lowest-numbered scope with all deps done)
- **iterate:** Identify work, create scope if needed, add to `_index.md` or `scopes.md`
- **Legacy migration:** If `scopes.md` exists with 6+ scopes and no `scopes/_index.md`, refactor to per-scope directories first (see Legacy Format Migration)

### Phase 2: Implementation
1. Implement changes across all surfaces
2. Add required tests (unit, component for UI, integration, E2E, stress if SLAs exist)
3. As each DoD item is completed:
   - **Validate** the item (run tests, verify behavior)
   - **Record evidence** inline under the corresponding DoD checkbox item in `scope.md` (per-scope dir) or `scopes.md` (single-file) — verbatim terminal output only, must contain recognizable terminal signals (test results, file paths, exit codes, timing, etc.)
   - **Mark `[x]`** ONLY after evidence is recorded
   - Do NOT pre-check DoD items when creating scope definitions
   - Do NOT batch-check multiple DoD items
   - **Each item MUST be validated individually** with its own execution and evidence
4. Update `state.json` after each step

**CRITICAL — THE COMPLETION CHAIN (see agent-common.md top section):**
- A DoD item CANNOT be [x] without inline raw evidence containing legitimate terminal output signals
- A scope CANNOT be "Done" until ALL DoD items are [x] with evidence
- A spec CANNOT be "done" until ALL scopes are "Done"
- Tests MUST cover ALL real scenarios (Gherkin, error paths, boundaries, parameter permutations)
- Tests MUST be real (no internal mocks, real test DBs, 100% business logic coverage)
- Tests MUST be passing (exit code 0, all tests pass)

### Phase 3: Tests

**Note:** Use project-specific test commands from `copilot-instructions.md`. Do NOT hardcode tool names.

1. Run ALL required test types (using project-specific commands)
2. Record evidence for EACH test type in `report.md`
3. Verify test coverage meets thresholds (per project config)
4. **Fix ALL failures** (including pre-existing) and re-run until all pass
5. Follow **Test Execution Gate**, **Bug Fix Testing Requirements**, and **Fix ALL Test Failures Policy** (per [agent-common.md](agent-common.md))
6. **Run Skip Marker Scan** — verify zero skip/only/todo markers in changed test files (per Skip Marker Scan Gate in agent-common.md)

### Phase 4: Validation
1. Run validation suite via `/bubbles.validate`
2. Fix issues and re-validate

### Phase 5: Documentation
1. Update feature docs (`spec.md`, `design.md`)
2. Update standard docs (API, ARCHITECTURE, etc.)
3. Update execution evidence artifact for the active layout:
  - **Per-scope directory mode:** update only `scopes/NN-name/report.md`
  - **Single-file mode:** append/update the scope section in `report.md`

### Phase 6: Audit
1. Run `/bubbles.audit`
2. If issues: route back per routing table
3. Repeat until clean

### Phase 7: Finalize (LAST STEP)
1. **Update `uservalidation.md`** with all verifiable behaviors
2. **Mark items `[x]` by default** (just validated via audit)
3. **Resolve effective status from workflow mode `statusCeiling`** (see Status Ceiling Enforcement below)
4. Mark scope status in the active scope definition file (`scope.md` or `scopes.md`) according to resolved status, and sync `_index.md` if present
5. Update `state.json` status to the resolved status
6. Record `workflowMode` in `state.json` so resume and downstream agents know what was executed

**⛔ COMPLETION CHAIN ENFORCEMENT (ABSOLUTE — from agent-common.md):**

Before marking ANY scope "Done" or setting spec status to "done", the agent MUST verify the ENTIRE completion chain:

- **Per-DoD-Item Evidence (G025):** EVERY DoD item that is [x] MUST have raw terminal output evidence inline under it containing legitimate terminal signals (test results, file paths, exit codes, timing). Items without evidence or with fabricated content are INVALID.
- **All DoD Items Checked:** for per-scope dirs use `grep -c '^\- \[ \]' {FEATURE_DIR}/scopes/*/scope.md`; for single-file use `grep -c '^\- \[ \]' {FEATURE_DIR}/scopes.md`. Result MUST be 0.
- **All Scopes Done (G024):** for per-scope dirs use `grep -c 'Status:.*Not Started\|Status:.*In Progress\|Status:.*Blocked' {FEATURE_DIR}/scopes/*/scope.md`; for single-file use `grep -c 'Status:.*Not Started\|Status:.*In Progress\|Status:.*Blocked' {FEATURE_DIR}/scopes.md`. Result MUST be 0.
- **Test Reality:** ALL test-related DoD items show tests covering ALL real scenarios with 100% business logic coverage
- **Tests Passing:** ALL test outputs show exit code 0 with zero failures

**If ANY of these fail → scope stays "In Progress" and spec stays "in_progress". No exceptions.**

**⚠️ MANDATORY FINALIZATION CHECKS (NON-NEGOTIABLE — Execute ALL before finalizing):**

7. **Run state transition guard script (Gate G023 — MECHANICAL ENFORCEMENT):**
   ```bash
   bash .github/bubbles/scripts/state-transition-guard.sh {FEATURE_DIR}
   ```
   - **This is the FIRST check to run.** If it exits with code 1, ALL subsequent checks are moot — status MUST remain `in_progress`.
   - The guard script consolidates checks 8-13 below into a single blocking pass, but agents MUST also verify these individually for transparency.
   - **NEVER write `"status": "done"` to state.json without guard script exit code 0.**

8. **Run artifact lint** — `bash .github/bubbles/scripts/artifact-lint.sh {FEATURE_DIR}` must exit 0
9. **Verify ALL DoD items are `[x]`** — for per-scope dirs: `grep -c '^\- \[ \]' {FEATURE_DIR}/scopes/*/scope.md` must be 0; for single-file: `grep -c '^\- \[ \]' {FEATURE_DIR}/scopes.md` must be 0
10. **Verify ALL scope statuses are Done** — check `_index.md` status column (per-scope dirs) or `scopes.md` (single-file): `grep -c 'Status:.*Not Started\|Status:.*In Progress' {SCOPE_FILES}` must be 0
11. **Verify evidence legitimacy** — every `[x]` item must have inline evidence containing real terminal output signals (test results, file paths, exit codes, timing, build tool names)
12. **Verify no fabrication** — apply Fabrication Detection Heuristics (Gate G021 from agent-common.md):
    - No template placeholders unfilled
    - No narrative summaries as evidence
    - No duplicate evidence blocks
    - No batch-checked items
13. **Verify specialist completion** — `state.json` `completedPhases` includes ALL mode-required phases (Gate G022)
14. **Verify no TODOs/stubs** — `grep -r "TODO\|FIXME\|HACK\|STUB\|unimplemented!" [changed-files]` must return 0 results
15. **Verify completion chain (G024)** — ALL scopes are "Done" before spec can be "done"
16. **Verify per-DoD-item evidence (G025)** — EVERY [x] item has raw terminal output evidence inline with legitimate terminal signals. Manually verify each checked item has an evidence block containing real output (pass/fail counts, file paths, exit codes). Items without evidence or with fabricated prose MUST be reverted to [ ]
17. **Verify test reality (G025)** — ALL test-related DoD items show tests covering ALL Gherkin scenarios, error paths, boundary conditions, and parameter permutations. Tests MUST use real systems (no internal mocks, real test DBs). 100% business logic coverage required.
18. **Verify stress coverage** — If scope defines latency SLAs (e.g., "under 50ms"), stress test DoD items MUST exist and pass.
19. **Verify no defaults/fallbacks (G030)** — `bash .github/bubbles/scripts/implementation-reality-scan.sh {FEATURE_DIR} --verbose` covers Scan 5. Zero `unwrap_or()`, `|| default`, `?? fallback`, `os.getenv("K", "default")` in production code. All config MUST fail-fast if missing.
20. **If ANY check fails** → status MUST remain `in_progress`, NOT be promoted to `done`

**⚠️ STATE TRANSITION SEQUENCE (NON-NEGOTIABLE):**
```
Step 1: Run guard script → bash .github/bubbles/scripts/state-transition-guard.sh {FEATURE_DIR}
Step 2: IF exit code 1 → STOP. Status stays "in_progress". Fix ALL failures.
Step 3: IF exit code 0 → Run artifact lint as confirmation
Step 4: IF lint passes → Write the resolved status (never exceeding `statusCeiling`) to state.json
Step 5: IF lint fails → STOP. Status stays "in_progress". Fix failures.
```

**This sequence is ABSOLUTE. There is NO alternative path to "done" without the guard script passing.**

#### Status Ceiling Enforcement (NON-NEGOTIABLE)

**The `state.json` `status` field MUST NOT exceed the `statusCeiling` defined for the active workflow mode in `.github/bubbles/workflows.yaml`.**

| Workflow Mode | `statusCeiling` | Meaning |
|---------------|-----------------|---------|
| `full-delivery` | `done` | Implementation + tests completed and verified |
| `value-first-e2e-batch` | `done` | Full delivery with value-first selection |
| `feature-bootstrap` | `done` | Bootstrap + implementation completed |
| `bugfix-fastlane` | `done` | Bug fixed with reproduction evidence |
| `chaos-hardening` | `done` | Chaos rounds clean + implementation verified |
| `spec-scope-hardening` | `specs_hardened` | Planning artifacts improved — NO implementation done |
| `docs-only` | `docs_updated` | Documentation updated — NO implementation done |
| `validate-only` | `validated` | Validation completed — NO implementation done |
| `audit-only` | `validated` | Audit completed — NO implementation done |
| `resume-only` | `in_progress` | Partial work resumed |

**Rules:**
- If the mode's `statusCeiling` is NOT `done`, the finalize phase MUST NOT set `status: "done"` in `state.json` or mark scopes as `Done` in `scopes.md`
- Artifact-only modes (`spec-scope-hardening`, `docs-only`, `validate-only`, `audit-only`) produce planning/quality improvements but do NOT constitute completed implementation work
- The `completedPhases` array records which phases ran in this session — it is informational but MUST be coherent with `completedScopes` (Gate G027: claiming implementation phases with empty completedScopes = fabrication)
- **Phase Recording Responsibility (MANDATORY):** Each specialist agent is responsible for appending its OWN phase name to `completedPhases` in `state.json` AFTER its Tier 1 + Tier 2 validation checks pass. Agents MUST NOT add other agents' phase names. Pre-populating phases that have not actually executed is fabrication (Gate G027). The recording happens as the agent's LAST step — never before validation succeeds.
- **Execution History Ownership (MANDATORY):** `executionHistory` is the audit trail for agent/workflow runs. Standalone specialist runs MUST append their own `executionHistory` entry. When a specialist is invoked by the workflow/orchestrator via `runSubagent`, the specialist MUST skip appending `executionHistory`; the workflow/orchestrator records the authoritative entry for that run to avoid duplicate history rows. This exception does NOT change the specialist's responsibility to append its own phase name to `completedPhases`.
- **Phase name mapping:** `bubbles.implement` → `"implement"`, `bubbles.test` → `"test"`, `bubbles.docs` → `"docs"`, `bubbles.validate` → `"validate"`, `bubbles.audit` → `"audit"`, `bubbles.chaos` → `"chaos"`
- A subsequent `full-delivery` or `feature-bootstrap` run is required to advance status to `done`

**Example state.json after `spec-scope-hardening`:**
```json
{
  "status": "specs_hardened",
  "workflowMode": "spec-scope-hardening",
  "completedPhases": ["select", "bootstrap", "harden", "docs", "validate", "audit", "finalize"],
  "notes": "Specs/scopes hardened. Implementation not started — run full-delivery to advance to done."
}
```

**Example state.json after `full-delivery`:**
```json
{
  "status": "done",
  "workflowMode": "full-delivery",
  "completedPhases": ["select", "implement", "test", "docs", "validate", "audit", "chaos", "finalize"]
}
```

---

## Phase Exit Gates (MANDATORY)

**A phase is ONLY complete when its exit conditions are ALL satisfied. Proceeding without meeting exit gates is a policy violation.**

| Phase | Exit Condition | Verification |
|-------|---------------|--------------|
| **0: Context** | All required artifacts loaded; baseline health recorded in report.md | `state.json` updated, baseline section exists in report.md |
| **1: Scope** | Scope selected/created with Gherkin scenarios, test plan, and DoD; legacy migration done if needed | `scope.md` (per-scope dir) or `scopes.md` has non-empty scope with all sections |
| **2: Implementation** | Code changes complete; all DoD items have 3-part validation (impl + behavior + evidence) | Every `[x]` has inline raw evidence with legitimate terminal output signals |
| **3: Tests** | All test types pass (exit code 0); skip marker scan clean; coverage meets threshold | Raw terminal output in report.md for each test type |
| **4: Validation** | Validation suite passes; no regressions vs baseline | Validation output in report.md |
| **5: Documentation** | All impacted docs updated; no stale references | Doc file list in report.md |
| **6: Audit** | Audit verdict is SHIP_IT or SHIP_WITH_NOTES; fabrication detection passes | Audit report in report.md; artifact lint exits 0 |
| **7: Finalize** | uservalidation.md updated; scope status set to mode's `statusCeiling`; state.json status ≤ `statusCeiling`; `workflowMode` recorded; ALL finalization checks pass (steps 7-19 above); **state transition guard script exits 0 (Gate G023)**; **ALL scopes Done before spec done (Gate G024)**; **ALL DoD items have per-item raw evidence (Gate G025)**; **ALL tests cover all real scenarios with 100% coverage (Gate G025)**; **stress tests exist when SLAs are defined** | File timestamps verify updates; status matches ceiling; guard script exits 0; artifact lint exits 0; all DoD `[x]` with inline evidence; all scopes Done; specialist completion verified; test coverage verified; stress coverage verified |

**Rollback Protocol:** If a phase fails its exit gate and the agent cannot resolve the issue within 3 attempts:
1. Revert any partial changes from the current phase
2. Return to the previous phase's entry point
3. Record the failure and reason in report.md under `## Phase Rollback`
4. Do NOT skip the phase — resolve the blocker or stop and report

---

## Audit Failure Routing

| Issue Type | Return To Phase |
|------------|-----------------|
| Spec/design/scopes mismatch | Phase 1 |
| Bug / incorrect behavior | Phase 2 (implement) |
| Missing/weak tests | Phase 3 (tests) |
| Validation failures | Phase 4 (validate) |
| Security issues | Phase 2 (implement) |
| Documentation drift | Phase 5 (docs) |

After fixes: re-run Phase 3 → 4 → 5 → 6 → 7.

---

## Resume Behavior

On startup, before selecting a new scope:

1. Check `{FEATURE_DIR}/state.json`
2. If `status` is `in_progress` or `blocked`: resume from `currentPhase`
3. If `status` is `specs_hardened`, `docs_updated`, or `validated`: these are terminal states for artifact-only modes — do NOT resume; instead, select a new scope or switch to an implementation mode (`full-delivery`)
4. If `status` is `done`: all scopes complete — report and stop
5. Do NOT re-select scope unless user explicitly requests fresh start
