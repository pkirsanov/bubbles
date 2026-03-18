<!-- governance-version: 2.2.0 -->
# Shared Agent Patterns (Common to all bubbles.* agents)

> **Version:** 2.2.0 | **This file defines shared patterns used by multiple Bubbles agents.**
> Reference this file instead of duplicating content.
> 
> **Portability:** This file is **project-agnostic**. It contains NO project-specific commands, paths, tools, or language references. All project-specific values are resolved via indirection from `.specify/memory/agents.md` and `.github/copilot-instructions.md`. See [project-config-contract.md](project-config-contract.md) for the indirection rules.

### Context Loading Optimization

This file is ~2,400 lines of comprehensive governance. To reduce context overhead:

- **Always load** [critical-requirements.md](critical-requirements.md) (150 lines) — the hard, non-negotiable core
- **Load this file** for reference when hitting completion, evidence, testing, or audit gates
- **Agents SHOULD NOT attempt to load this entire file into context at once** — read targeted sections on demand using the section headers below

**Quick Section Guide:**
| Need | Section |
|------|---------|
| Completion rules | `ABSOLUTE COMPLETION HIERARCHY` (line ~12) |
| Evidence standards | `Execution Evidence Standard` |
| Anti-fabrication | `Anti-Fabrication Policy` |
| Red/green proof | `Rule 6: Red-Green Traceability` |
| Scope sizing | `Rule 7: Scope Size Discipline` |
| Micro-fix loops | `Rule 8: Micro-Fix Containment Loops` |
| Test taxonomy | `Canonical Test Taxonomy` |
| Mock restrictions | `Real Implementation & No-Mock Testing Reality Policy` |
| Status transitions | `Status Transition Summary` |
| Per-agent validation | `Per-Agent Completion Validation Protocol` |

---

## ⛔⛔⛔ ABSOLUTE COMPLETION HIERARCHY — SPEC / SCOPE / DoD CHAIN (NON-NEGOTIABLE — READ FIRST) ⛔⛔⛔

**This is the #1 policy in this entire document. Every agent MUST internalize and follow it EXACTLY. No exceptions. No shortcuts. No "close enough". Violation = immediate status revert and re-execution.**

### The Completion Chain (HARD DEPENDENCY — NOT ADVISORY)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    COMPLETION FLOWS BOTTOM-UP ONLY                      │
│                                                                         │
│  DoD Item ──► Raw Validation Evidence ──► Item marked [x]               │
│       │                                                                 │
│       └── EACH DoD item MUST be individually executed, validated,       │
│           and have legitimate terminal output evidence recorded INLINE   │
│           before it can be checked [x]. NO BATCH CHECKING.              │
│                                                                         │
│  ALL DoD Items [x] ──► Scope marked "Done"                              │
│       │                                                                 │
│       └── A scope CANNOT be marked "Done" until EVERY SINGLE DoD        │
│           item is [x] WITH inline raw evidence. Zero unchecked           │
│           items. Zero items without evidence.                            │
│                                                                         │
│  ALL Scopes "Done" ──► Spec marked "done"                               │
│       │                                                                 │
│       └── A spec CANNOT be marked "done" in state.json until EVERY      │
│           SINGLE scope file has status "Done". Zero scopes              │
│           with "Not Started" or "In Progress". ABSOLUTE.                 │
│                                                                         │
│  VIOLATION OF THIS CHAIN = IMMEDIATE STATUS REVERT                      │
└─────────────────────────────────────────────────────────────────────────┘
```

### Rule 1: Per-DoD-Item Validation Protocol (ABSOLUTE)

**Every single DoD item MUST go through this exact sequence. No exceptions.**

```
FOR EACH DoD item in the active scope definition file (`scopes.md` or `scopes/NN-name/scope.md`):
  1. IMPLEMENT the item (code change, doc update, etc.)
  2. EXECUTE a validation command (test, curl, lint, build, etc.)
  3. OBSERVE the actual terminal output
  4. COPY the raw output (verbatim, must contain real terminal signals) inline under the DoD item
  5. VERIFY the output shows success (exit code 0, tests passing, etc.)
  6. ONLY THEN mark the item [x]
  
  IF steps 2-5 were NOT performed → the item stays [ ]
  IF the output shows failure → the item stays [ ] and you FIX the issue
  IF you batch-check multiple items without individual evidence → ALL revert to [ ]
```

**Detection rule:** If a DoD item is marked `[x]` but has NO inline raw output evidence block directly underneath it, the item is INVALID and MUST be reverted to `[ ]`.

### Rule 2: Scope Cannot Be Done Without ALL DoD Items Validated (ABSOLUTE)

**A scope's status CANNOT be changed to "Done" while ANY of these are true:**
- ANY DoD item is unchecked `[ ]`
- ANY DoD item lacks inline raw-output evidence with legitimate terminal signals
- ANY DoD item's evidence shows failure (non-zero exit code, failing tests)
- ANY required test type has not been executed
- ANY required test is skipped, ignored, or conditionally bypassed
- Scope defines latency SLAs but no stress test DoD item exists

**Verification command (MUST be run before marking scope Done):**
```bash
# Per-scope directory mode:
grep -c '^\- \[ \]' {FEATURE_DIR}/scopes/{NN}-*/scope.md
# Single-file mode:
grep -c '^\- \[ \]' {FEATURE_DIR}/scopes.md
# Result MUST be 0
```

### Rule 3: Spec Cannot Be Done Without ALL Scopes Done (ABSOLUTE)

**A spec's status in state.json CANNOT be set to "done" while ANY of these are true:**
- ANY scope has status "Not Started"
- ANY scope has status "In Progress"
- ANY scope has status "Blocked" (must be unblocked first)
- ANY scope has unchecked DoD items

**Verification command (MUST be run before marking spec done):**
```bash
# Per-scope directory mode — count non-Done scopes:
grep -c 'Status:.*Not Started\|Status:.*In Progress\|Status:.*Blocked' {FEATURE_DIR}/scopes/*/scope.md
# Single-file mode:
grep -c 'Status:.*Not Started\|Status:.*In Progress\|Status:.*Blocked' {FEATURE_DIR}/scopes.md
# Result MUST be 0
```

**This is a HARD BLOCK. There is NO override. There is NO workaround.**

### Rule 4: DoD Items MUST Include Tests With 100% Real Scenario Coverage (ABSOLUTE)

**Every scope's DoD MUST include test items that cover ALL real scenarios. "Real scenarios" means:**

1. **ALL Gherkin scenarios** from the scope MUST have corresponding test entries
2. **ALL use cases** from spec.md MUST have corresponding test entries  
3. **ALL error/boundary/negative paths** MUST be tested (not just happy path)
4. **ALL parameter permutations** MUST be tested
5. **100% line coverage** for business logic is REQUIRED
6. **Tests MUST be real** — they must fail if the feature is broken, pass only if the feature works correctly

**What "real scenario coverage" means:**
- Tests MUST exercise actual code paths through the real stack (no mocks of internal code)
- Tests MUST verify actual behavior outcomes (not just status codes or element existence)
- Tests MUST use real data stores (ephemeral test DBs, not mock repositories)
- Tests MUST cover the complete lifecycle (create → read → update → delete → verify)
- Tests MUST include negative cases (invalid input, unauthorized access, missing data)

**DoD test items are NOT optional. Every scope MUST have ALL of these test-related DoD items (plus scope-specific ones):**

```markdown
- [ ] Unit tests pass with 100% line coverage (`unit`)
- [ ] Integration tests pass against live system (`integration`)  
- [ ] E2E tests for ALL Gherkin scenarios pass (`e2e-api`/`e2e-ui`)
- [ ] E2E regression tests pass (existing workflows unbroken)
- [ ] Stress tests pass for performance-sensitive paths (`stress`)
- [ ] ALL error/boundary/negative scenarios tested
- [ ] ALL parameter permutations tested
- [ ] Zero skipped/ignored/conditional tests
- [ ] Test coverage meets 100% threshold for business logic
```

**Each of these items requires individual execution + raw evidence. They cannot be batched or skipped.**

### Rule 5: Tests Must Be Completely Implemented and Passing (ABSOLUTE)

**"Tests exist" is NOT sufficient. ALL of these MUST be true:**

| Requirement | What It Means | How To Verify |
|-------------|---------------|---------------|
| Tests are **implemented** | Test files exist with real test code (not stubs/TODOs) | `ls -la [test-files]` shows files exist |
| Tests are **comprehensive** | Cover all scenarios, not just happy path | Review test descriptions against Gherkin scenarios |
| Tests are **real** | Would fail if feature broken, pass only when correct | Assertions verify actual behavior, not proxies |
| Tests are **executed** | Actually ran in the current session | Terminal output shows test runner execution |
| Tests are **passing** | Exit code 0, all tests pass | Raw output shows pass counts, zero failures |
| Tests **cover all scenarios** | Every Gherkin scenario has ≥1 corresponding test | Count tests ≥ count scenarios |
| Tests **use real systems** | No mocks of internal code, real test DBs | Grep for mock patterns shows zero internal mocks |

**If ANY of these is FALSE → the test-related DoD item stays `[ ]` and the scope stays "In Progress".**

### Rule 6: Red-Green Traceability for New or Fixed Behavior (ABSOLUTE)

**Changed behavior is not proven until the agent shows both the broken state and the fixed state.**

This applies when:
- fixing a bug
- adding behavior-specific tests for new functionality
- adding regression tests for changed behavior

Required sequence:
1. **RED** — run the targeted test or reproduction step against the pre-fix state and capture failing evidence
2. **GREEN** — implement the fix and rerun the targeted test or reproduction step until it passes
3. **REGRESSION SAFETY** — run the broader impacted suite to prove the fix did not break adjacent behavior

Allowed exceptions:
- docs-only work
- artifact-only planning/hardening with no behavior change
- mechanical refactors with zero behavior change and no new behavior-specific tests

Invalid patterns:
- writing the test after the fix and only showing a passing run
- claiming the bug was reproduced earlier without current-session evidence
- treating a broad failing suite as sufficient red evidence when the changed behavior was never isolated

### Rule 7: Scope Size Discipline and Optional Time Budgets (ABSOLUTE)

**Scopes are small, isolated delivery units by default. Time budgets are optional; smallness is not.**

Default expectation:
- one primary user or system outcome per scope
- one coherent slice of behavior per scope
- DoD items small enough to validate individually without batching unrelated work

When optional tags are provided:
- `maxScopeMinutes` is a planning heuristic ceiling for the total scope
- `maxDodMinutes` is a planning heuristic ceiling for each DoD item

Recommended planning bands (when not explicitly provided):
- target ~60-120 minutes per scope
- target ~15-45 minutes per DoD item

Practical split trigger:
- if a scope cannot be completed and fully evidenced in one focused session, split it
- if a DoD item requires more than one unrelated command/evidence path, split it
- if a scope has more than one independent acceptance outcome, split it

Scopes MUST be split unless explicitly justified when they contain:
- multiple unrelated user journeys
- backend, frontend, and ops work that do not form one vertical slice
- more than one independent success outcome
- DoD items that require multiple unrelated validations or manual judgment bundles

### Rule 8: Micro-Fix Containment Loops (ABSOLUTE)

**When a failure is narrow, the repair loop must stay narrow.**

Required behavior:
- start with the smallest failing command, file, symbol, or scope slice
- repair the exact failure with focused context
- rerun only the impacted command first
- expand to broader validation only after the narrow failure is clean
- keep retries bounded and narrowing (full context → file context → function/symbol context)

Forbidden behavior:
- blindly rerunning the entire workflow for a single compile or lint error
- escalating to a broad rewrite when the failure is localized
- moving to a new phase without proving the local failure is resolved

### Enforcement Summary

```
⛔ Agent writes state.json "done" without ALL scopes Done → REVERT
⛔ Agent marks scope "Done" with unchecked DoD items → REVERT  
⛔ Agent marks DoD item [x] without inline raw evidence → REVERT
⛔ Agent batch-checks multiple DoD items → REVERT ALL
⛔ Agent claims "tests pass" without running them → REVERT + re-execute
⛔ Agent skips test types → scope stays "In Progress"
⛔ Tests only cover happy path → scope stays "In Progress"
⛔ Tests mock internal code → scope stays "In Progress"
⛔ Tests use fake data stores → scope stays "In Progress"
```

---

## ⚠️ Per-Agent Completion Validation Protocol (NON-NEGOTIABLE)

**Every agent MUST run its own completion validation before reporting results. The workflow agent orchestrates agents but does NOT substitute for per-agent validation. Each agent is responsible for validating its own work.**

### Validation Tiers

Each agent's completion validation has two tiers:

**Tier 1 — Universal Checks (ALL agents MUST run these):**

| # | Check | Command / Action | Pass Criteria |
|---|-------|-----------------|---------------|
| V1 | Artifact lint | `bash .github/bubbles/scripts/artifact-lint.sh {FEATURE_DIR}` | Exit code 0 |
| V2 | No TODOs/stubs in changed files | `grep -r "TODO\|FIXME\|HACK\|STUB\|unimplemented!" [changed-files]` | Zero matches |
| V3 | Fabrication self-audit | Apply Heuristics 1-9 (Gate G021) to own output | No heuristic triggered |
| V4 | Evidence legitimacy | Every claimed result has raw terminal output with recognizable signals | All evidence legitimate |
| V5 | Implementation reality scan | `bash .github/bubbles/scripts/implementation-reality-scan.sh {FEATURE_DIR} --verbose` | Exit code 0 — no stubs, fakes, hardcoded data, defaults, fallbacks |
| V6 | Scope/DoD coherence | For each scope: Gherkin scenario count ≥ E2E test plan rows; Test Plan rows == DoD test items; no scope marked "Done" with unchecked DoD | Zero parity mismatches |
| V7 | Implementation-claims match | For each DoD item marked `[x]`: verify the claimed file/feature actually exists and matches what the item describes | Zero false-positive DoD items |
| V8 | No mocks in production code | `grep -rn "mock\|Mock\|MOCK\|fake\|Fake\|FAKE\|stub\|Stub" [src-files] --include='*.rs' --include='*.py' --include='*.ts' --include='*.tsx' --include='*.go'` (exclude test dirs) | Zero matches in non-test source files |
| V9 | No defaults/fallbacks in code | `grep -rn "unwrap_or\|unwrap_or_default\|getOrDefault\|?? \"\|\|\| \"" [src-files]` (exclude test dirs) | Zero matches in production code |
| V10 | Red/green traceability | For changed behavior, verify failing evidence exists before passing evidence | Both RED and GREEN evidence present when applicable |
| V11 | Scope size discipline | Verify scopes/DoD items stay isolated and respect optional time budgets if declared | No oversized or mixed-purpose scope without justification |

**Tier 2 — Agent-Specific Checks (defined per agent — see individual agent files):**

Each agent defines its own Tier 2 checks based on its role. These are listed in its `## Agent Completion Validation` section.

### Validation Execution Rules

1. **Run validation BEFORE reporting results** — The agent MUST execute Tier 1 + Tier 2 checks BEFORE generating its output/verdict.
2. **Validation failures block completion** — If ANY check fails, the agent MUST report `VALIDATION_FAILED` with details, NOT a success verdict.
3. **Record validation output** — Raw output from validation commands MUST be included in the agent's report.
4. **State updates only after validation** — Agents that update `state.json` (implement, iterate, test) MUST NOT write status changes until validation passes.
5. **Workflow trusts but verifies** — The workflow agent (`bubbles.workflow`) may spot-check validation outputs but does NOT re-run all validation. Each agent owns its validation.

### ⛔ Validation Evidence Must Be Terminal Output (ABSOLUTE — NON-NEGOTIABLE)

**ALL validation evidence MUST come from actual terminal command execution. Agents MUST NEVER fabricate, compose, reconstruct, or synthesize evidence text.**

| FORBIDDEN | REQUIRED |
|-----------|----------|
| Agent writes text that resembles terminal output (e.g., typing `exit code: 0`, `PASSED`, `12 tests passed`) | Agent runs command in terminal, copies ACTUAL output verbatim |
| Agent paraphrases or summarizes command results | Agent pastes the raw, unmodified terminal output |
| Agent constructs "expected" output before running commands | Agent runs command FIRST, captures output SECOND |
| Agent copies evidence from a previous session or another DoD item | Agent runs the command in THIS session and captures fresh output |
| Agent writes evidence blocks without corresponding `run_in_terminal` / `runTests` tool calls | Every evidence block has a preceding tool call that produced it |

**Detection rule (Gate G021 — Heuristic 10):**
```
IF an evidence block exists in the agent's output but NO terminal tool call
   (run_in_terminal, runTests, get_terminal_output) preceded it in the same session
THEN the evidence is fabricated → REJECT, re-execute the command
```

**Self-check (MANDATORY before every evidence block):**
1. "Did I just run a terminal command that produced this output?" — If NO → run the command now.
2. "Am I copying the exact output from the tool response, or am I typing what I think it says?" — If typing → STOP, re-read the tool response and copy verbatim.
3. "Is this output from THIS session, not a previous one?" — If previous → re-run the command.

**Enforcement:** The audit agent (`bubbles.audit`) MUST cross-reference evidence blocks against the session's terminal execution history. Evidence blocks without corresponding tool executions are fabricated and trigger `🔴 DO_NOT_SHIP`.

### Agent-Specific Validation Requirements

| Agent | Tier 2 Checks (in addition to Tier 1 universal) |
|-------|------------------------------------------------|
| **bubbles.implement** | Reality scan (G028+G030), DoD items [x] with evidence, scope status verification, state transition guard (G023) |
| **bubbles.test** | Skip marker scan, mock audit scan, proxy test scan, all test types executed, test verdict table generated |
| **bubbles.iterate** | Full 7-step completion verification (Phase 7.5), state transition guard (G023), specialist phase completion |
| **bubbles.audit** | Independent test execution, cross-reference evidence, compliance review, state transition guard with `--revert-on-fail` |
| **bubbles.validate** | ALL governance scripts, build/lint/test execution, contract verification, Docker freshness (UI scopes) |
| **bubbles.harden** | 9-step final checklist, skip marker scan, round-trip verification, baseline comparison, findings artifact update (G031) |
| **bubbles.docs** | API doc cross-reference (router vs docs), no orphaned/invented endpoints in docs |
| **bubbles.chaos** | Playwright execution evidence, bug artifact completeness, chaos report generated |
| **bubbles.test** | Noop test detection, default/fallback detection in implementation, coverage threshold verification |
| **bubbles.gaps** | Scope artifact coherence, state coherence, no regression, findings artifact update (G031) |

---

## ⚠️ Project-Agnostic Indirection (NON-NEGOTIABLE)

**Bubbles agents MUST NEVER hardcode project-specific values.** All project commands, paths, Docker images, container names, port ranges, and language-specific tools are resolved from the project's configuration files.

### Required Indirection Points

| What Agent Needs | Where to Resolve It | Example |
|------------------|---------------------|---------|
| Build command | `.specify/memory/agents.md` → `BUILD_COMMAND` | `[BUILD_COMMAND from agents.md]` |
| Test commands | `.specify/memory/agents.md` → `UNIT_TEST_*_COMMAND`, `E2E_*_COMMAND` | `[UNIT_TEST_RUST_COMMAND from agents.md]` |
| Lint/format commands | `.specify/memory/agents.md` → `LINT_COMMAND`, `FORMAT_COMMAND` | `[LINT_COMMAND from agents.md]` |
| Frontend container | `.github/copilot-instructions.md` → Docker Bundle Config table | `<frontend-container>` |
| Static asset root | `.github/copilot-instructions.md` → Docker Bundle Config table | `<static-root>` |
| Port ranges | `.github/copilot-instructions.md` → Docker Port Allocation section | Project-specific |
| CLI entrypoint | `.specify/memory/agents.md` → `CLI_ENTRYPOINT` | `[CLI_ENTRYPOINT from agents.md]` |
| Dev stack start | `.specify/memory/agents.md` → `DEV_ALL_COMMAND` | `[DEV_ALL_COMMAND from agents.md]` |

### Resolution Protocol

1. **Read `agents.md` first** — it contains all commands
2. **Read `copilot-instructions.md`** — it contains project policies and Docker config
3. **Substitute placeholders** before executing — replace `<frontend-container>` etc.
4. **If a value is missing** — STOP and report. NEVER guess or use defaults.

---

## Loop Guard (MANDATORY)

All Bubbles agents MUST enforce these limits to prevent infinite loops and context-gathering spirals.

### Rules

1. **Max 3 consecutive reads**: After 3 `read_file` calls without a substantive action (create, edit, run command, output summary), you MUST stop reading and act on what you have. Reset counter after each action.
2. **Doc-read budget per tier**: Max 3 documents per tier (governance / feature / project refs). After 3 loads in a tier, take an action before loading more.
3. **No duplicate reads**: Track files read in session. Never re-read the same file path twice.
4. **No hunt loops**: If a file doesn't exist after one check, proceed without it.
5. **Action-First Mandate**: Load Tier 1 governance docs + spec.md → take ONE action → load more ONLY if blocked.
6. **Graceful degradation**: If after 3 reads you don't have enough context, output a summary asking user for specific guidance instead of reading more docs.

---

## ⚠️ VS Code Auto-Approval Command Policy (MANDATORY)

Bubbles agents MUST use command patterns that are typically auto-approvable in VS Code Copilot and avoid shell wrappers that trigger approval dialogs.

### PROHIBITED command patterns

- ❌ `bash -c '...'` / `sh -c '...'` wrappers for repo operations
- ❌ Multi-hop shells that combine `cd`, `source`, and test/build commands in one opaque string
- ❌ Output redirection to temp files as a logging workaround (e.g., `> /tmp/*.txt; cat /tmp/*.txt`)
- ❌ Inline shell scripts via heredoc in terminal commands for routine build/test/run flows

### REQUIRED execution patterns

1. **Prefer repo task/CLI entrypoints**
  - Use the project CLI wrapper (defined in `.specify/memory/agents.md` as `CLI_ENTRYPOINT`) instead of raw tool commands or ad-hoc shell chains.
2. **Prefer first-class tools over shell glue**
  - Use `run_task` / `runTests` where available for tests.
  - Use a single direct command invocation; do not wrap it in `bash -c`.
3. **Keep commands transparent and auditable**
  - One clear command per operation, with explicit args and bounded timeout.

If an operation truly requires a non-auto-approvable pattern, agent MUST stop and request explicit user approval before running it.

---

## ⚠️ Autonomous Operation within Guardrails (NON-NEGOTIABLE)

All Bubbles agents MUST operate autonomously within their defined scope. Agents are expected to be self-directed, predictable, and proactive while staying strictly within policy boundaries.

### Autonomy Rules

1. **Act, don't ask** — If the answer can be determined by reading code, docs, specs, or running a command, DO NOT ask the user. Research and act.
2. **Predictable workflows** — Follow the exact execution phases defined in your agent prompt. Do not skip phases, reorder them, or improvise new ones. Same inputs MUST produce the same workflow sequence.
3. **Research over guessing** — When uncertain, read the relevant source code, specs, or docs. Never guess at behavior, never assume things work without evidence.
4. **Clear scope boundaries** — Agents modify code/tests/docs ONLY within their classified feature/bug scope. Scope boundary changes require user approval.
5. **No unnecessary questions** — Questions to the user are justified ONLY when: (a) the information is not available anywhere in the codebase/docs, AND (b) a reasonable default cannot be determined from context.

### Guardrail Rules

1. **Follow ALL repository policies** from `.github/copilot-instructions.md` without exception — every policy is mandatory, not advisory.
2. **Follow the agent's defined workflow** — Each agent has a specific execution flow with numbered phases. Follow them in order, step by step.
3. **No unauthorized side effects** — Do not modify files outside the classified scope unless directly required by the change (e.g., fixing an import in a shared file).
4. **Stop at gates** — If a mandatory gate (artifacts, user validation, test execution) fails, STOP and report. Do not bypass gates.
5. **No new issues** — Every change MUST leave the system in equal or better state. Never introduce new warnings, errors, test failures, or regressions.

---

## ⚠️ Universal Truthfulness & Test Substance Gate (MANDATORY for ALL bubbles.* agents)

Agents MUST NEVER fabricate status, evidence, outputs, or test quality. This gate applies to every phase and every completion decision.

### Absolute Rules

1. **No fabricated claims** — Never state "done", "passing", "verified", "works", "200 OK", or equivalent without current-session execution evidence.
2. **No hallucinated artifacts** — Never reference files/sections/tests/commands that do not exist in the repository or current run output.
3. **No noop tests** — Tests that only assert existence, route load, or non-crash behavior for required workflows are invalid for completion.
4. **No fake quality signals** — Do not treat placeholders, stubs, synthetic pass markers, or skipped tests as valid progress.
5. **No proxy completion** — A scope/bug is not complete because code "looks correct"; completion requires passing required gates with raw evidence.

### Required Evidence Standard

1. Every pass/fail claim must include exact command/tool execution in the current session.
2. Required test evidence must include raw output with legitimate terminal signals (test results, file paths, exit codes, timing) and real exit code.
3. If execution cannot be performed, agent must explicitly state "not executed" and keep status `in_progress`/`blocked`.
4. If evidence is missing, contradictory, or stale, agent must fail the gate and route to remediation.

### Noop/Fake Test Detection (Blocking)

Treat any of the following as blocking failures for required tests:
- Optional assertions for required behavior (`if (...) expect(...)`)
- Early-return pass paths after missing required controls/selectors
- Existence-only assertions where behavior/value/round-trip persistence is required
- Accepted mixed status assertions (e.g., `expect([200,404]).toContain(status)`) when one status is required
- Skipped required tests (`skip`, `xit`, ignored/conditional bypass)

### Mandatory Agent Response on Violation

When fabrication/noop behavior is detected:
1. Fail current gate immediately.
2. Mark scope/spec status `in_progress` or `blocked` (never `done`).
3. Record violation details and exact remediation steps.
4. Re-run required validations only after real fixes are applied.

### Pro-Active Behavior (Within Guardrails)

1. **Anticipate problems** — When implementing a change, proactively check for related issues (type mismatches, missing imports, broken API contracts, stale mocks).
2. **Fix adjacent issues** — If you discover a related bug or missing test while working within scope, fix it. Log what you fixed in report.md.
3. **Strengthen tests** — When writing tests, proactively add edge cases and negative tests beyond the minimum requirement. Weak tests are technical debt.
4. **Update docs proactively** — When code changes affect documented behavior, update related documentation immediately. Don't defer docs updates.

---

## 🧠 Lessons-Learned Memory (Auto-Maintained)

Agents append structured entries to `.specify/memory/lessons.md` when they encounter and resolve non-trivial problems. This builds a project-specific knowledge base over time.

### Entry Format

```markdown
## YYYY-MM-DD | <agent> | specs/<NNN>
**Problem:** <one-line description>
**Root Cause:** <what actually caused it>
**Fix:** <what resolved it>
**Applies To:** <when this lesson is relevant>
```

### Auto-Compaction

`bubbles.workflow` runs compaction at the start of each invocation when `lessons.md` exceeds 150 lines:

1. **Deduplicate:** Same root cause 3+ times → collapse into one entry with count
2. **Recency tiering:** Last 30 days: full detail. 30–90 days: problem + fix only. 90+ days: archive to `lessons-archive.md`
3. **Topic grouping:** Group entries under headings (Routing, Database, Frontend, Testing, etc.)
4. **Size cap:** Keep under 150 lines. Aggressively summarize oldest grouped entries if needed.

### Agent Loading

`bubbles.workflow` loads the first 50 lines of `lessons.md` (topic headings + recent entries) at run start. Agents reference it for known patterns before investigating from scratch.

---

## 🔄 Self-Healing Loop Protocol (G039 — NON-NEGOTIABLE)

When an agent encounters a build, test, lint, or validation failure, it SHOULD attempt a bounded self-healing loop before escalating.

### Rules

| Property | Value |
|----------|-------|
| `maxDepth` | 1 — a fix attempt NEVER triggers another fix loop |
| `maxRetries` | 3 per failure (same error context) |
| `maxTotalRetries` | 5 across ALL failures in one phase |
| Anti-stacking | If a fix introduces a NEW error, it counts against the same retry budget |
| Narrowing | Each retry narrows context: full → file → function |

### Narrowing Rule

- **Retry 1:** Full error context + surrounding code
- **Retry 2:** Only the failing file + error message
- **Retry 3:** Only the specific function/block + error message
- **After 3:** Escalate to next agent or mark blocked

### Anti-Stacking Rule

A self-healing fix attempt is NEVER allowed to trigger another self-healing loop. If a fix introduces a NEW error, it counts against the same retry budget. No recursion. No nesting. This is enforced by G039 (`self_healing_containment_gate`).

---

## 📝 Atomic Commit Protocol (autoCommit Execution Tag)

When `autoCommit` is set to `scope` or `dod`, agents create structured commits after validated milestones.

### Commit Granularity

| Value | When to commit |
|-------|----------------|
| `off` | No automatic commits (default) |
| `scope` | After a scope reaches Done with all DoD items checked |
| `dod` | After each individual DoD item is validated with evidence |

### Commit Message Format

```
bubbles({spec}/{scope}): {scope_name} — Done

Spec: {spec_name}
Scope: {scope_id}-{scope_name}
DoD: {checked}/{total} checked
Agent: {agent_name}
Mode: {workflow_mode}
```

### Rules

- Commits are only made AFTER validation passes (never speculative)
- `git add -A` captures all changes (implementation + tests + docs + artifacts)
- Agents MUST verify the commit was created (check `git log --oneline -1`)
- If `gitIsolation: true`, commits go to the isolated branch

---

## ⚠️ Operation Timeout Policy (NEVER WAIT FOREVER - MANDATORY)

**ALL operations MUST have explicit time limits. Agents MUST NEVER wait indefinitely.**

### Default Timeouts

| Operation | Default | Max |
|-----------|---------|-----|
| Terminal commands | 60s | 5min |
| Build operations | 10min | 30min |
| Deploy/start | 5min | 15min |
| Test execution | 10min | 30min |
| Health checks | 60s (max 30 × 2s) | 3min |
| Network/HTTP requests | 30s | 2min |
| Container start/stop | 60s | 3min |
| Background process checks | max 10 checks | — |

### Rules

1. Wrap ALL shell commands: `timeout <duration> <cmd>`
2. Health check polling MUST have max attempts (e.g., 30 × 2s = 60s)
3. Background processes (`isBackground=true`) — max 10 periodic checks
4. On timeout → treat as FAILURE, kill hung processes, report immediately, do NOT auto-retry

### PROHIBITED

- ❌ Commands without timeout protection
- ❌ Infinite `while true` loops
- ❌ `sleep` without bounded iteration count
- ❌ `docker logs -f` or follow mode without timeout
- ❌ Blocking on network ops without timeout

### ⚠️ FAIL FAST: Feature/Bug Folder Resolution (CRITICAL)

**When resolving a feature or bug folder path:**

1. **ONE search attempt only** - Search for the folder pattern ONCE
2. **If found:** Proceed with the resolved path
3. **If NOT found after ONE search:**
   - ❌ **DO NOT** search again with the same or similar pattern
   - ❌ **DO NOT** loop waiting for the folder to appear
   - ❌ **DO NOT** keep trying different search patterns
   - ✅ **STOP IMMEDIATELY** and report the folder was not found
   - ✅ **List available folders** under `specs/` to help the user
   - ✅ **Suggest alternatives**: "Create the feature folder first using `/bubbles.iterate` or `/bubbles.plan`"

**Detection of loop behavior to AVOID:**

```text
# BAD - This is a loop that MUST NOT happen:
Search: specs/019-* → no matches
Search: specs/019-* → no matches  ← STOP! Don't do this
Search: specs/019-* → no matches  ← STOP! Don't do this
...
```

**Correct behavior:**

```text
# GOOD - Fail fast after ONE search:
Search: specs/019-* → no matches
STOP → Report: "Feature folder specs/019-* not found. Available folders: [list]. Create with /bubbles.iterate."
```

---

## Work Classification Gate (MANDATORY)

**Every piece of work by any `bubbles.*` agent MUST be classified as either:**

1) **Feature work** under `specs/[NNN-feature-name]/`, or
2) **Bug work** under:
  - `specs/[NNN-feature-name]/bugs/BUG-NNN-short-description/`

**If the invocation is not tied to a feature dir or bug dir:**
- The agent MUST STOP and request the missing classification input (feature dir or bug dir).
- For agents running in non-interactive mode: the agent MUST FAIL FAST with a clear instruction to re-run the command with an explicit `specs/...` target.

**PROHIBITED:**
- ❌ Making ad-hoc code/doc changes “outside a feature” or “outside a bug”.
- ❌ Creating placeholder `spec.md`/`design.md`/etc. to satisfy gates.

**Allowed exceptions (read-only utilities):**
- Status/report-only agents may operate without creating artifacts **only if they do not modify code or docs**.

---

## ⚠️ Canonical Test Taxonomy (NON-NEGOTIABLE)

**ALL Bubbles agents MUST use these exact test type definitions. No synonyms, no conflation.**

**Execution objective (MANDATORY):** Bubbles agents optimize for **executing specs/scopes to completion** and proving compliance through passing tests that encode exact spec use cases and Gherkin scenarios. The objective is not to "look successful" — it is to execute required behavior end-to-end with verifiable evidence.

### Test Types — Authoritative Definitions

| Test Type | Abbrev | External Deps | Mocks Allowed | Description |
|-----------|--------|---------------|---------------|-------------|
| **Unit** | `unit` | ❌ None | ⚠️ EXTERNAL ONLY | Tests a specific function/method in isolation. ONLY external third-party dependencies (payment gateways, email services, cloud APIs) may be mocked. Internal code (other services, repositories, business logic, middleware) MUST NEVER be mocked — test real code. No live services required but use real in-process DB for data layer tests where feasible. |
| **Functional** | `functional` | ✅ May use | ⚠️ EXTERNAL ONLY | Same scope as unit (single function/method), but uses real external dependencies (e.g., real DB, real filesystem). ONLY external third-party APIs may be mocked. Internal code and data stores MUST be real. |
| **Integration** | `integration` | ✅ Required | ❌ No mocks | Tests multiple components/services working together. Requires live systems (DB, message queues, caches). MUST use separate/temporary storage or clean up test data after. No mocks — real interactions only. |
| **UI Unit** | `ui-unit` | ❌ None | ✅ Yes (backend mocked) | Tests UI components in isolation using Playwright Component Testing or similar. Backend/API calls are mocked. Tests rendering, user interactions, component state. No live backend required. |
| **E2E (API)** | `e2e-api` | ✅ Live system | ❌ No mocks | Tests system-to-system API workflows against a LIVE running system. No mocks. Uses real HTTP calls against real endpoints. Validates actual request/response contracts, auth flows, data persistence. |
| **E2E (UI)** | `e2e-ui` | ✅ Live system | ❌ No mocks | Tests end-user UI workflows against a LIVE running system using Playwright or similar. No mocks. Must test actual UI behavior, layout, styles, navigation, form submissions, and visual correctness. Browser automation against real frontend + real backend. |
| **Stress** | `stress` | ✅ Live system | ❌ No mocks | High-concurrency/high-load testing against a LIVE system. Tests system behavior under pressure: concurrent requests, resource exhaustion, rate limiting, connection pooling. Short-duration, high-intensity bursts. |
| **Load** | `load` | ✅ Live system | ❌ No mocks | Long-running sustained load testing against a LIVE system. Tests system stability over time: memory leaks, connection exhaustion, degradation under sustained traffic. Duration: minutes to hours. |

### ⚠️ Test Type Integrity Gate (NON-NEGOTIABLE)

**Misclassifying test types is a blocking policy violation.**

| If test uses... | Then category is... | MUST NOT be labeled as... |
|-----------------|---------------------|----------------------------|
| Playwright Component Testing, Jest component tests, MSW/intercepted API calls, mocked backend responses | `ui-unit` | `e2e-ui` |
| API mocks/stubs/fakes for server dependencies | `unit` or `functional` | `integration`, `e2e-api`, `stress`, `load` |
| Browser automation against frontend where backend calls are mocked or intercepted | `ui-unit` | `e2e-ui` |
| Real browser + real frontend + real running backend + real test DB | `e2e-ui` | `ui-unit` |
| Multi-component tests with any mocked service boundary | `unit`/`functional`/`ui-unit` (depending scope) | `integration` |
| High-concurrency test with mocked backend/services | NOT `stress` | `stress` |

**Absolute requirements for live categories:**
- `integration` MUST run against a live test backend and real dependencies (no mocks).
- `e2e-api` MUST run against live API endpoints on a live test backend (no mocks).
- `e2e-ui` MUST run browser automation against live frontend + live backend (no mocks/intercepts for core workflow assertions).
- `stress` and `load` MUST run against a live test backend (no mocks).

**Evidence requirement for classification:**
- Test Plan and report evidence MUST explicitly state backend mode: `live` or `mocked`.
- Any test with backend mode `mocked` is automatically ineligible for `integration`/`e2e-*`/`stress`/`load` labels.

### Live System Testing Requirements (MANDATORY for integration, e2e-api, e2e-ui, stress, load)

Tests that run against live systems MUST follow these rules:

| Rule | Description |
|------|-------------|
| **Use test environment for live tests** | Integration/E2E/Stress/Load MUST target the dedicated test environment by default (isolated backend + isolated test storage). |
| **Ephemeral storage preferred** | Use separate temporary databases/storage that are created for the test run and destroyed after. Prefer `tmpfs`-backed containers. |
| **Seed on demand** | Populate test storage with required data as part of test setup. Do NOT rely on pre-existing data in permanent storage. |
| **Clean up after non-test env usage** | If a non-test environment is used (exception path), ALL test data MUST be cleaned up after the run completes. No residual test data may remain. |
| **No residual data** | After test completion, storage MUST be in the same state as before the test run (or the ephemeral storage is simply destroyed). |
| **Synthetics pattern** | Use synthetic test data with clearly identifiable prefixes/markers (e.g., `test-`, timestamps) to enable reliable cleanup. |
| **Isolation** | Tests MUST NOT interfere with each other. Use unique identifiers per test run to prevent collisions. |

### E2E Tests — Mandatory for Every Scope/Bug (NON-NEGOTIABLE)

**E2E tests (both `e2e-api` and/or `e2e-ui` as applicable) MUST be:**

1. **Defined** — Test files must exist with test cases covering the scope/bug scenario
2. **Executed** — Tests must be run against a live system during the current session
3. **Passing** — All E2E tests must pass (exit code 0)
4. **Validated** — Test output must be reviewed and results confirmed
5. **Evidence recorded** — Raw terminal output with legitimate signals (test results, file paths, exit codes, timing) must be captured in `report.md`

**Skipped tests policy (MANDATORY):**
- Skipped tests (`skip`, `xit`, `it.skip`, ignored markers, conditional bypass) are treated as **not executed** for completion gates.
- A scope/bug cannot be marked complete while any required test is skipped.
- Required test suites must end with **executed + passing** status, not partial execution.

### Unbreakable E2E Anti-False-Positive Guardrails (MANDATORY)

The following patterns are **strictly forbidden** in required `e2e-ui`/`e2e-api` tests because they allow false positives:

| Forbidden Pattern | Why It Fails Integrity |
|---|---|
| `if (!elementVisible) { ... return; }` | Converts missing feature into a passing test |
| URL-only fallback assertions after missing UI controls | Validates routing, not behavior |
| Optional assertions (`if (x) expect(x)...`) for required behavior | Allows silently skipping required verification |
| Existence-only checks for persisted layout (`if (layout) expect(layout).toBeDefined()`) | Does not verify schema/behavior correctness |

Rules:
1. **Missing required selector MUST fail immediately** with `expect(locator).toBeVisible()`.
2. **No early-return branches** are allowed in required scenarios after setup succeeds.
3. **Persistence tests MUST assert contract shape and values**, not mere non-null existence.
4. **UI layout tests MUST assert user-visible outcomes** (computed styles, DOM structure, persisted state round-trip).

Required validation commands before marking scope/bug done:
- `grep -n "if (!has.*)" <required-e2e-file>` MUST return **no matches**.
- `grep -n "return;" <required-e2e-file>` MUST return **no matches inside required test bodies**.
- `grep -n "if (.*layout.*)" <required-e2e-file>` MUST not show optional/non-blocking layout assertions.

Any violation is a **blocking failure** and the scope/bug status MUST remain `in_progress`.

**Every scope in `scopes.md` MUST have corresponding E2E DoD items:**
```markdown
- [ ] E2E tests for new behavior pass (e2e-api and/or e2e-ui)
  - Raw output evidence (inline):
    ```
    [PASTE VERBATIM terminal output here]
    ```
- [ ] E2E regression tests pass (existing workflows unbroken)
  - Raw output evidence (inline):
    ```
    [PASTE VERBATIM terminal output here]
    ```
```

**Every bug fix MUST have E2E regression tests:**
```markdown
- [ ] E2E regression test for bug scenario passes
  - Raw output evidence (inline):
    ```
    [PASTE VERBATIM terminal output here]
    ```
- [ ] E2E existing tests pass (no new regressions)
  - Raw output evidence (inline):
    ```
    [PASTE VERBATIM terminal output here]
    ```
```

**A scope/bug CANNOT be marked "Done" without passing E2E tests. No exceptions.**

### Gherkin Scenario Coverage (MANDATORY)

**Every Gherkin scenario MUST be validated by tests that match the scenario exactly.**

- Each scenario must map to at least one test in the Test Plan table and a DoD item with evidence.
- Tests MUST encode the exact use case behavior from `spec.md`/`scopes.md`; do not test approximations or implementation shortcuts.
- If the scenario is user-visible UI behavior, the validation MUST include `e2e-ui` using a UI automation framework (Playwright or equivalent).
- If the scenario is API behavior, the validation MUST include `e2e-api` against live endpoints (no mocks).
- Live-system tests must use ephemeral or cleaned storage (see Live System Testing Requirements).

**⚠️ ACTUAL E2E TEST SPECIFICITY (NON-NEGOTIABLE):**
Scope Test Plans MUST list **concrete, scenario-specific E2E test entries** — not generic placeholders. Each E2E row must name the exact Gherkin scenario or UI Scenario ID it validates, the actual test file path, and the actual `test()` title/description. Generic rows like `E2E UI | e2e-ui | [path] | [UI workflow]` are **FORBIDDEN** — they allow scopes to pass review without real test planning.

Example of FORBIDDEN (generic):
```
| E2E UI | `e2e-ui` | `[path]` | [UI workflow, LIVE system] | `[cmd]` | Yes |
```

Example of REQUIRED (specific):
```
| E2E UI | `e2e-ui` | `e2e/tests/checkout.spec.ts` | S2: user completes checkout and sees order confirmation | `[cmd]` | Yes |
```

### Regression Test Placement Policy (MANDATORY)

Regression tests are previously missing tests and MUST live with the feature/component they verify.

- Do NOT create catch-all regression buckets/files that mix unrelated features.
- Add missed scenarios to the existing feature/component test files (or create feature-specific files only when none exist).
- Test organization must remain functionality/component scoped.

### Test Type Mapping — When Each Type Is Required

| Scope Change | Required Test Types |
|-------------|-------------------|
| Backend logic only | unit, functional (if DB), integration, e2e-api |
| UI component only | unit, ui-unit, e2e-ui |
| Backend + UI | unit, ui-unit, integration, e2e-api, e2e-ui |
| API contract change | unit, integration, e2e-api |
| Database schema change | unit, functional, integration, e2e-api |
| Performance-sensitive | unit, integration, stress, load, e2e-api |
| Bug fix (any) | unit (regression), integration, e2e-api and/or e2e-ui (regression) |

### Test Plan Table Template (Use in scopes.md)

**⚠️ E2E rows MUST be scenario-specific.** Replace `[path]` and description with actual file paths and the specific Gherkin/UI scenario each test validates. Generic E2E descriptions are FORBIDDEN.

```markdown
| Test Type | Category | File/Location | Description | Command | Live System Required |
|-----------|----------|---------------|-------------|---------|---------------------|
| Unit | `unit` | `[path]` | [what it tests - isolated, mocked deps] | `[cmd]` | No |
| Functional | `functional` | `[path]` | [what it tests - may use real deps] | `[cmd]` | Optional |
| Integration | `integration` | `[path]` | [multi-component, real deps, no mocks] | `[cmd]` | Yes |
| UI Unit | `ui-unit` | `[path]` | [component test, mocked backend] | `[cmd]` | No |
| E2E API | `e2e-api` | `[actual file]` | Scenario [ID]: [exact scenario description] | `[cmd]` | Yes |
| E2E UI | `e2e-ui` | `[actual file]` | Scenario [ID]: [exact scenario description] | `[cmd]` | Yes |
| Stress | `stress` | `[path]` | [high-load burst test] | `[cmd]` | Yes |
| Load | `load` | `[path]` | [sustained load test] | `[cmd]` | Yes |
```

**E2E rows must have ONE row per scenario** — not one generic row covering "all E2E". If the scope has 4 Gherkin scenarios, the Test Plan must have at least 4 E2E rows (one per scenario).

---

## ⚠️ Use Case Testing Integrity (NON-NEGOTIABLE)

**Tests MUST validate actual user/system use cases — NOT internal implementation details.**

Every test must answer: **"Does this test prove that a real user's scenario works correctly?"** If no, it's a **proxy test** and must be rewritten.

### Anti-Proxy Test Rules (BLOCKING)

| Test Pattern | Verdict | Fix |
|---|---|---|
| E2E checks only status code (e.g., `expect(res.status).toBe(200)`) | ❌ PROXY | Assert response body has expected user-visible data |
| E2E hits endpoint without verifying EFFECT | ❌ PROXY | Save → reload → assert saved state persisted |
| Integration test mocks the component being tested | ❌ PROXY | Use real component with live deps |
| UI test checks element exists but not content/state | ❌ PROXY | Assert text, computed styles, or interactive behavior |
| Test passes with wrong data (would pass if feature broken) | ❌ PROXY | Add assertions that FAIL if feature is broken |
| Only happy path tested | ⚠️ INCOMPLETE | Add error, boundary, and negative cases |

### Requirements by Test Category

**E2E UI:** Navigate via app navigation, interact with real UI elements, wait for real backend responses (no mocks), assert visible output, verify round-trip persistence (create → refresh → verify).

**E2E API:** Real HTTP to live endpoints with auth, assert response body (not just status), verify persistence (POST → GET → verify), test complete workflows and error scenarios.

**Integration:** Live dependencies, no mocks for tested components, assert observable system state, clean up data after tests.

---

## ⚠️ No Regression Introduction (NON-NEGOTIABLE)

**Every change MUST leave the system in equal or better state.**

### Pre-Change Baseline Health Check (BLOCKING)

Before making code changes, establish a verifiable baseline:

1. Run the test suite relevant to the feature/bug scope
2. Record baseline in `report.md`:
   - Command, exit code, total/passing/failing/skipped test counts, warning count, timestamp
3. If pre-existing failures exist → fix per "Fix ALL Test Failures Policy"
4. If skipped tests exist → remove skip markers and fix/delete

### Post-Change Verification

After every code change:
1. Run the affected test suite
2. Compare to baseline — any previously-passing test now failing = **REGRESSION** → fix before proceeding
3. New warnings or lint errors = fix before proceeding

### Leave-It-Better Rule

When touching a file: fix pre-existing lint/warnings, strengthen proxy tests, add missing coverage, update stale docs.

---

## Required Bubbles Artifacts Gate (MANDATORY)

**BLOCKING — must execute before ANY feature work begins.**

All feature work requires these artifacts in `{FEATURE_DIR}`: `spec.md`, `design.md`, `uservalidation.md`, `state.json`, plus scope artifacts in one valid layout:

- **Single-file layout:** `scopes.md` + `report.md`
- **Per-scope layout:** `scopes/_index.md` + one or more `scopes/NN-name/scope.md` + matching `scopes/NN-name/report.md`

### Artifact Ownership by Agent Phase

| Phase | Agent | Creates | Prerequisites |
|-------|-------|---------|---------------|
| **Analysis phase** | `/bubbles.analyst` | enriches `spec.md` (actors, use cases, scenarios, competitive analysis), `state.json` | User input / feature description |
| **UX phase** | `/bubbles.ux` | enriches `spec.md` (UI wireframes, user flows), `state.json` | `spec.md` with actors/scenarios |
| **Design phase** | `/bubbles.design` | `spec.md`, `design.md`, `state.json` | User input / feature description |
| **Plan phase** | `/bubbles.plan` | scope artifacts for the selected layout (`scopes.md` + `report.md`, or `scopes/_index.md` + per-scope `scope.md`/`report.md`), plus `uservalidation.md` | `spec.md` + `design.md` must exist |

### State.json Lifecycle (MANDATORY)

**Any Bubbles agent operating on a feature folder MUST ensure `state.json` exists and is kept current.** state.json is created at the first Bubbles touch — not only at the design phase.

**Rules:**
1. **Existence check:** Before starting work, check if `{FEATURE_DIR}/state.json` exists
2. **Create if missing:** If absent, create it with initial schema:
   ```json
   {
     "status": "not_started",
     "workflowMode": "",
     "currentPhase": "",
     "completedPhases": [],
     "completedScopes": [],
     "executionHistory": []
   }
   ```
3. **Update on phase start:** Set `currentPhase` to the agent's phase name (e.g., `"analyze"`, `"implement"`, `"test"`)
4. **Record `statusBefore`** at read-time before making any changes — this is needed for the `executionHistory` entry
5. **Update `completedPhases`** when a phase finishes successfully
6. **Append to `executionHistory`** when the agent's run completes (see Execution History Schema in scope-workflow.md):
   ```json
   {
     "id": 1,
     "agent": "bubbles.analyst",
     "workflowMode": "product-to-delivery",
     "startedAt": "2026-03-15T10:00:00Z",
     "completedAt": "2026-03-15T10:15:00Z",
     "statusBefore": "not_started",
     "statusAfter": "in_progress",
     "phasesExecuted": ["analyze"],
     "scopesCompleted": [],
     "summary": "Business analysis and competitive research completed. spec.md enriched."
   }
   ```
   - Standalone specialist runs (user directly invokes an agent) → append their own entry
   - Specialist agents invoked by `bubbles.workflow` via `runSubagent` → do NOT create separate entries; the workflow orchestrator creates one entry covering the entire run
7. **Preserve existing data:** Never overwrite existing `executionHistory` entries or `completedScopes` — only append
8. **Migrate `phaseHistory`:** If the file contains a `phaseHistory` field but no `executionHistory`, preserve `phaseHistory` as-is (deprecated, read-only) and create `executionHistory: []` for new entries going forward

**This ensures state tracking begins at first Bubbles contact (analyst, UX, design, plan, or any other agent), not only at the design phase.**

### Design-Phase Artifacts Gate (checked by bubbles.design)

1. Create `{FEATURE_DIR}` if missing
2. Create `state.json` with `{"status": "not_started"}` if missing
3. Create or complete `spec.md` (using spec-template-bdd skill)
4. Create `design.md` as primary output
5. Do NOT create `scopes.md`, `report.md`, or `uservalidation.md`

### Plan-Phase Artifacts Gate (checked by bubbles.plan)

1. Verify `spec.md` and `design.md` exist (REQUIRED — stop if missing, instruct user to run `/bubbles.design`)
2. Create `state.json` if missing
3. Create scope artifacts using the correct layout:
  - **1–5 scopes:** create `scopes.md` as primary output and `report.md` template if missing
  - **6+ scopes:** create `scopes/_index.md` and per-scope `scopes/NN-name/scope.md` + `scopes/NN-name/report.md` templates
4. Create `uservalidation.md` template if missing (with `- [x]` baseline checkboxes)

### Full Artifacts Gate (checked by implementation/execution agents)

All 6 artifacts must exist before implementation work begins. If any are missing, the responsible agent phase must be run first. For per-scope directory mode, `scopes/_index.md` + at least one `scopes/NN-name/scope.md` must exist instead of `scopes.md`.

**Creation rules:**
- **NO stubs, TODOs, or placeholders** in content artifacts (`spec.md`, `design.md`, `scopes.md`, `scopes/NN-name/scope.md`)
- Tracking artifacts may have minimal valid content: `state.json` with `status: "not_started"`, and report artifact(s) with required headers only
- `uservalidation.md` MUST have `- [x]` checkbox items (see User Validation Gate)
- If info is missing for content artifacts → stop and request inputs
- Follow templates from [feature-templates.md](feature-templates.md) and [scope-workflow.md](scope-workflow.md)

**Template Compliance Gate (BLOCKING before status transitions):**
- Scope DoD items in `scopes.md` or `scopes/NN-name/scope.md` must be markdown checkboxes (`- [ ]` / `- [x]`)
- Scope definition files must contain mandatory DoD checklist items
- `uservalidation.md` must have checked-by-default checkboxes
- `report.md` or each `scopes/NN-name/report.md` must have required section headers (Summary, Test Evidence, Completion Statement)

---

## Bug Artifacts Gate (MANDATORY)

**BLOCKING — no bug work until ALL artifacts exist.**

Bug folders: `specs/[NNN-feature]/bugs/BUG-NNN-desc/`.

Required artifacts: `bug.md`, `spec.md`, `design.md`, `scopes.md`, `report.md`, `state.json`.

1. Create bug folder if missing
2. Create any missing artifacts immediately (minimal valid content acceptable — see `bubbles.bug` for templates)
3. Verify all 6 exist before proceeding

**PROHIBITED:** Starting bug work without all artifacts present, creating empty files, proceeding before artifacts exist.

- ❌ Starting bug work without all 6 artifacts present
- ❌ Creating empty files to satisfy the gate
- ❌ Proceeding to investigation/fixing before artifacts exist

---

## User Validation Gate (MANDATORY)

**MUST be executed before ANY feature work begins.**

`{FEATURE_DIR}/uservalidation.md` is a user-editable acceptance checklist.

### Step 1: Create If Missing (BLOCKING)

If `{FEATURE_DIR}/uservalidation.md` does not exist, create it using this template:

```markdown
# User Validation

This file is a user-editable acceptance checklist.
- Uncheck (`[ ]`) any behavior that is broken or needs re-verification.
- Bubbles treats unchecked items as **user-reported regressions**.
- `bubbles.validate` investigates root cause of each unchecked item.

## Checklist

### Initial Baseline (REQUIRED)
- [x] Baseline checklist initialized for this feature
```

**Template integrity:** Must contain at least one `- [x]` checkbox. Empty checklists or non-checkbox bullets are invalid and block work.

### Step 2: Check All Items (BLOCKING)

Read the file. If ANY unchecked `[ ]` items exist → these are **user-reported regressions** (user found behavior broken). They are BLOCKING — fix before new work.

### Semantics

- `[x]` = Working as expected (default when created after audit)
- `[ ]` = User unchecked it = NOT working as expected → requires investigation

---

## User Validation Update (End of Scope Work)

**Execute as LAST step after audit passes.** For each verifiable behavior in the completed scope:

1. Append entry using template below, marked `[x]` (just validated via audit)
2. User can later uncheck `[ ]` if they find behavior broken → becomes blocking regression

```markdown
### [Feature] / [Use Case Name]
- [x] **What:** <behavior summary>
  - **Steps:** 1. ... 2. ...
  - **Expected:** <outcome>
  - **Verify:** <UI action | script | API call>
  - **Evidence:** [report.md#scope-name] or [scopes/NN-name/report.md#scope-name] (match active layout)
```

---

## Context Loading (Tiered)

Load documents following Loop Guard rules. Start with Tier 1, expand as needed:

### Tier 1: Core Governance (Load First)
1. `.specify/memory/agents.md` - Project verification commands
2. `.specify/memory/constitution.md` - Core governance principles
3. `.github/copilot-instructions.md` - Repo-specific policies (CRITICAL)

### Tier 2: Feature Context (Load When Starting Feature Work)
4. `{FEATURE_DIR}/spec.md` - Feature specification
5. `{FEATURE_DIR}/design.md` - Design document (if exists)
6. Scope definitions — load `{FEATURE_DIR}/scopes/_index.md` first if it exists, otherwise `{FEATURE_DIR}/scopes.md`
7. Current scope file in per-scope mode — `{FEATURE_DIR}/scopes/NN-name/scope.md` when implementing/resuming a specific scope
7. `{FEATURE_DIR}/uservalidation.md` - User acceptance checklist

### Tier 3: Reference Documentation (Load On-Demand Only)
Load project docs from `docs/` as needed. Recommended categories:
- API contracts (e.g., `docs/API.md`)
- System architecture (e.g., `docs/Architecture.md`)
- Development standards (e.g., `docs/Development.md`)
- Deployment & operations (e.g., `docs/Deployment.md`, `docs/OPERATIONS.md`)
- Testing standards (e.g., `docs/E2E_TESTING.md`)

Actual filenames vary per project — discover via `ls docs/*.md` or check `.specify/memory/agents.md`.

---

## Policy Compliance (MANDATORY)

All Bubbles agents MUST comply with `.github/copilot-instructions.md`, `.specify/memory/constitution.md`, and `.specify/memory/agents.md`. Key rules: no defaults/fallbacks, no hardcoded URLs/ports, no stubs/mocks in production, use repo-standard commands, Zero Deferral, Zero Warnings.

---

## ⚠️ Real Implementation & No-Mock Testing Reality Policy (ABSOLUTE — NON-NEGOTIABLE)

**This policy enforces that ALL implementations are genuine end-to-end code and ALL tests exercise real system behavior. No fakes, no fabrications, no shortcuts.**

### 1. All Implementations Must Be Real (ABSOLUTE)

**Every feature MUST be implemented as real, working code across the ENTIRE stack — from client UI through API gateway, backend services, and data stores. No layer may be faked, stubbed, or simulated.**

| FORBIDDEN | REQUIRED |
|-----------|----------|
| Client-side local caches substituting for real API calls | Real API calls to real backend endpoints for ALL data |
| In-memory caches pretending to be data stores | Real database/storage reads and writes |
| Hardcoded/static data returned from API handlers | Dynamic data served from actual data stores |
| Client-side data stores (localStorage, IndexedDB, in-memory maps) used as primary data source | Server-side data stores as single source of truth; client fetches from server |
| Mock API responses baked into client code | Real HTTP/gRPC calls to running backend services |
| Fake service layers that return canned responses | Real service implementations with real business logic |
| "Optimistic" UI that never validates against server | UI state synchronized with server state via real API calls |
| Caching layers anywhere in the stack (client caches, server caches, intermediate caches) | Direct reads from authoritative data stores on every request |
| Simulated/synthetic data in production paths | Real data from real data stores |
| API stubs/shims that bypass actual business logic | Full request → business logic → data store → response pipeline |

**Implementation Completeness Checklist (BLOCKING for every feature):**

```
[ ] Frontend makes real API calls (no hardcoded data, no local caches as data source)
[ ] API gateway/router forwards to real backend handlers
[ ] Backend handlers execute real business logic (no stubs, no passthrough)
[ ] Business logic reads/writes real data stores (DB, object store, etc.)
[ ] Response flows back through the real stack to the client
[ ] No caching layer anywhere substitutes for real data store access
[ ] No client-side data persisted as source of truth (server is always authoritative)
[ ] All intermediate code (middleware, validators, serializers) is real and functional
[ ] No default/fallback values mask missing config (all config fails fast)
[ ] No stub/placeholder functions exist in production code paths
```

**Detection scan (run before marking any implementation complete):**
```bash
# Scan for local cache/storage patterns in client code
grep -rn "localStorage\|sessionStorage\|IndexedDB\|cacheStorage\|new Map()\|new Set()\|_cache\|cache =\|cached" [frontend-src-dirs]
# Any match must be justified as UI-only transient state (e.g., form draft), NOT as data source

# Scan for default/fallback patterns (FORBIDDEN in production code)
grep -rn "unwrap_or\|unwrap_or_default\|\.unwrap_or_else" [rust-src-dirs]
grep -rn '|| ["'"'"'].*["'"'"']\|?? ["'"'"']' [ts-js-src-dirs]
grep -rn "os\.getenv.*," [python-src-dirs]
# ANY match in production code = VIOLATION. Fail-fast required.

# Run the comprehensive reality scan (covers stubs, fakes, hardcoded data, defaults)
bash .github/bubbles/scripts/implementation-reality-scan.sh {FEATURE_DIR} --verbose
```

### 2. No Caches Anywhere (ABSOLUTE)

**No caching layer may exist between the client and the authoritative data store. Every data request MUST be served from the real, current data in the actual data store.**

| Cache Type | FORBIDDEN | Why |
|------------|-----------|-----|
| **Client-side cache** | localStorage, sessionStorage, IndexedDB used as data source | Data becomes stale; client diverges from server truth |
| **Client-side in-memory cache** | Service-level Map/object caching API responses for reuse | Same request may return stale data |
| **Server-side cache** | Redis/Memcached/in-memory cache in front of DB | Masks data store failures; returns stale data |
| **API response cache** | HTTP cache headers (Cache-Control, ETag) on business data endpoints | Prevents clients from seeing latest data |
| **CDN cache** | CDN caching of API responses (not static assets) | Returns stale business data |
| **Query result cache** | ORM/query-level caching (e.g., Hibernate cache, query plan cache for results) | Returns stale query results |

**Allowed exceptions (NOT data caches):**
- Static asset caching (CSS, JS bundles, images) — these are build artifacts, not business data
- DNS caching — infrastructure concern, not application data
- Connection pooling — reusing connections is not caching data
- Transient UI state (form drafts, unsaved edits in memory) — not persisted, not used as data source

### 3. Test Mock Restrictions (ABSOLUTE — NON-NEGOTIABLE)

**Mocks are ONLY permitted for EXTERNAL third-party dependencies that are outside the system boundary. All internal code MUST be tested with real implementations.**

#### What May Be Mocked (Exhaustive List)

| Dependency Type | Mock Allowed? | Reason |
|----------------|---------------|--------|
| External third-party APIs (payment gateways, email providers, SMS services, cloud provider APIs) | ✅ YES | Not under our control; unreliable in tests; may incur costs |
| External data feeds (market data providers, weather APIs, social media APIs) | ✅ YES | Rate-limited; costly; non-deterministic |
| System clock/time (for time-dependent logic) | ✅ YES | Deterministic testing requires controlled time |
| Random number generators (for deterministic test reproducibility) | ✅ YES | Reproducibility requirement |

#### What MUST NEVER Be Mocked

| Component | Mock Forbidden? | Reason |
|-----------|-----------------|--------|
| Database/data store | ❌ NEVER mock | Must test real queries, real schemas, real constraints |
| Internal services (within the system) | ❌ NEVER mock | Must test real service interactions |
| Internal APIs/endpoints | ❌ NEVER mock | Must test real request/response handling |
| Business logic functions/methods | ❌ NEVER mock | Must test real logic execution |
| Middleware (auth, validation, logging) | ❌ NEVER mock | Must test real middleware behavior |
| Message queues/event buses (internal) | ❌ NEVER mock | Must test real async patterns |
| File system operations (internal) | ❌ NEVER mock | Must test real I/O behavior |
| Internal HTTP clients calling own services | ❌ NEVER mock | Must test real network behavior |
| Configuration loading | ❌ NEVER mock | Must test real config resolution |
| Data serialization/deserialization | ❌ NEVER mock | Must test real encoding/decoding |

#### Per-Test-Type Mock Rules

| Test Type | Internal Code Mocks | External Dep Mocks | Data Store |
|-----------|--------------------|--------------------|------------|
| `unit` | ❌ FORBIDDEN | ✅ Allowed | ❌ Use real test DB or in-process DB (e.g., SQLite for unit scope) |
| `functional` | ❌ FORBIDDEN | ✅ Allowed | ✅ Real DB required |
| `integration` | ❌ FORBIDDEN | ✅ Allowed | ✅ Real test DB (ephemeral) |
| `ui-unit` | ❌ FORBIDDEN (UI internals) | ✅ Backend API calls may be intercepted | N/A — UI isolation |
| `e2e-api` | ❌ FORBIDDEN | ✅ Allowed (external only) | ✅ Real test DB (ephemeral) |
| `e2e-ui` | ❌ FORBIDDEN | ✅ Allowed (external only) | ✅ Real test DB (ephemeral) |
| `stress` | ❌ FORBIDDEN | ✅ Allowed (external only) | ✅ Real test DB (ephemeral) |
| `load` | ❌ FORBIDDEN | ✅ Allowed (external only) | ✅ Real test DB (ephemeral) |

**Clarification on unit tests:** Unit tests test a single function/method. They MUST NOT mock other internal functions, classes, or modules within the system. They MAY mock external third-party dependencies (payment APIs, email services, etc.) and MAY use a lightweight in-process database for data-layer unit tests. The goal is to test real code paths, not mock boundaries between internal components.

**Detection scan (run before marking tests complete):**
```bash
# Scan for internal mocking patterns
grep -rn "mock\|Mock\|jest\.fn\|sinon\.stub\|vi\.fn\|spy\|jest\.spyOn" [test-dirs]
# Every match must be for an EXTERNAL dependency mock. Internal code mocks = VIOLATION.

# Scan for test database mocking (FORBIDDEN)
grep -rn "mockDatabase\|mockDB\|fakeDB\|mock.*Repository\|mock.*Store\|InMemory.*Repository\|InMemory.*Store" [test-dirs]
# ANY match = VIOLATION. Use real test databases.
```

### 4. Complete Test Coverage Per Feature (ABSOLUTE — NON-NEGOTIABLE)

**Every feature MUST have ALL applicable test types implemented. Missing test types = feature is NOT complete.**

| Scope Change | MANDATORY Test Types (ALL required) |
|-------------|-------------------------------------|
| Backend logic only | `unit` + `functional` + `integration` + `e2e-api` + `stress` |
| UI component only | `unit` + `ui-unit` + `e2e-ui` + `stress` |
| Backend + UI | `unit` + `ui-unit` + `functional` + `integration` + `e2e-api` + `e2e-ui` + `stress` |
| API contract change | `unit` + `integration` + `e2e-api` + `stress` |
| Database schema change | `unit` + `functional` + `integration` + `e2e-api` |
| Performance-sensitive | `unit` + `integration` + `e2e-api` + `stress` + `load` |
| Bug fix (any) | `unit` (regression) + `integration` + `e2e-api`/`e2e-ui` (regression) |

**Coverage requirements:**
- 100% line coverage for business logic
- ALL use cases from spec.md covered
- ALL Gherkin scenarios have corresponding tests
- ALL error paths tested
- ALL boundary conditions tested
- ALL parameter permutations tested
- Negative tests for every positive test

**Feature test completeness gate (BLOCKING):**
```
[ ] Backend unit tests exist and pass with 100% line coverage
[ ] Backend functional tests exist and pass against real test DB
[ ] Backend integration tests exist and pass against real services + real test DB
[ ] Frontend unit tests exist and pass with 100% line coverage
[ ] Frontend UI unit tests exist and pass for all components
[ ] E2E API tests exist and pass against live system with real test DB
[ ] E2E UI tests exist and pass against live system with real test DB  
[ ] Stress tests exist and pass against live system with real test DB
[ ] ALL tests use real data stores (ephemeral test DBs), not mocks
[ ] ALL tests cover ALL use cases from spec, not just happy path
[ ] No mocks of internal code anywhere in the test suite
```

### 5. Test Data Storage Requirements (ABSOLUTE)

**All tests that interact with data stores MUST use real, seeded, ephemeral storage — NEVER mocks.**

| Test Type | Storage Requirement |
|-----------|--------------------|
| `unit` (data layer) | Real in-process DB or real test DB; NEVER mock repositories |
| `functional` | Real test DB (ephemeral); seeded with test data |
| `integration` | Real test DB (ephemeral, tmpfs-backed preferred); seeded per test |
| `e2e-api` | Real test DB (ephemeral); full schema + seed data |
| `e2e-ui` | Real test DB (ephemeral); full schema + seed data |
| `stress` | Real test DB (ephemeral); pre-seeded with load-appropriate data |
| `load` | Real test DB (ephemeral); pre-seeded with volume-appropriate data |

**Rules:**
- Test databases MUST be created fresh for each test run (ephemeral)
- Test databases MUST have real schema (same migrations as production)
- Test data MUST be seeded as part of test setup (not hardcoded in test code)
- Test data MUST be cleaned up after test run (or ephemeral DB destroyed)
- `tmpfs`-backed containers preferred for speed
- Test data MUST use identifiable prefixes (e.g., `test-`, timestamps) for reliable cleanup
- NEVER share test data between test runs
- NEVER rely on pre-existing data in a persistent database

---

## Mixed Specialist Work Routing (ALL specialist agents)

When a specialist agent's work expands into another domain (implement/test/docs/gaps/harden/bug) within one session:

- **Small fixes (≤30 lines):** Fix inline within the current agent's execution context.
- **Larger cross-domain work:** Return a failure classification (`code|test|docs|compliance|audit|chaos|environment`) to the orchestrator (`bubbles.workflow`), which routes to the appropriate specialist via `runSubagent`.

All specialist agents follow this pattern. Individual agents reference this section rather than duplicating it.

---

## ⚠️ Docker Build Freshness Policy (MANDATORY for UI Scopes)

**When a scope modifies frontend/UI code served as static assets from a Docker container, image rebuilds MUST use `--no-cache` to prevent stale layers.**

### Why This Is Necessary

Docker layer caching can cause the frontend build step to reuse a cached build output even when source files have changed (especially when `.dockerignore` patterns or COPY context ordering allows it). This results in a container that appears rebuilt but serves stale JavaScript/CSS bundles.

### Rules

| Rule | Description |
|------|-------------|
| **Force no-cache for UI changes** | When scope includes frontend code changes, rebuild with no-cache: `docker compose build --no-cache <frontend-service>` (or project CLI equivalent from `copilot-instructions.md`) |
| **Verify after rebuild** | After rebuilding, verify the served bundle contains expected feature code (Gate 9) |
| **Force container recreation** | After rebuilding, restart services to ensure the new image is used (e.g., `docker compose down && docker compose up -d`) |
| **Record build evidence** | Record the build command, image ID, and bundle hash in `report.md` |

### When to Apply

- ANY change to frontend source files (e.g., `src/`, `app/`, `pages/`)
- ANY change to frontend package manifest or build config (e.g., `package.json`, `vite.config.ts`, `webpack.config.js`)
- When Gate 9 (Docker Bundle Freshness) reports stale hashes

### Rebuild Sequence (UI Changes)

Use your project's CLI commands from `copilot-instructions.md`. Generic pattern:

```bash
# 1. Stop all services
<project-stop-command>      # e.g., docker compose down

# 2. Rebuild with no cache
<project-build-command> --no-cache   # e.g., docker compose build --no-cache frontend

# 3. Start all services (forces container recreation)
<project-start-command>      # e.g., docker compose up -d

# 4. Verify bundle freshness (Gate 9)
docker exec <frontend-container> md5sum <static-root>/index.html
docker exec <frontend-container> ls <static-root>/assets/*.js | head -5
```

**Project-specific commands** (stop/build/start/container name/static root) are defined in `copilot-instructions.md`. Agents MUST NOT hardcode these in agent definitions.

---

## Feature Folder Structure (CANONICAL)

```
specs/
  [NNN-feature-name]/                    # e.g., 003-user-authentication
    spec.md, design.md, uservalidation.md, state.json

    # Single-file layout (1–5 scopes):
    scopes.md, report.md

    # Per-scope directory layout (6+ scopes):
    scopes/
      _index.md                          # Summary table + dependency DAG
      01-scope-name/
        scope.md                         # Gherkin + plan + test plan + DoD for THIS scope
        report.md                        # Evidence for THIS scope
      02-scope-name/
        scope.md
        report.md
      ...

    bugs/[BUG-NNN-description]/          # Bug tracking for this feature
      bug.md, spec.md, design.md, scopes.md, report.md, state.json
```

**Layout selection:** 1–5 scopes → single-file (`scopes.md` + `report.md`). 6+ scopes → per-scope directories (`scopes/_index.md` + `scopes/NN-name/scope.md` + `scopes/NN-name/report.md`). Agents check for `scopes/_index.md` to detect layout mode.

**Key rules:** Items in `uservalidation.md` are `[x]` by default (post-audit). User unchecks `[ ]` to report regression. `design.md` is REQUIRED for new scopes. Do NOT create folders under `specs/_iterations/` (deprecated). Deferred bug work stays in the owning feature's `bugs/` folder with `state.json` status tracking.

---

## ⛔ Scope Isolation & DAG-Based Pickup (NON-NEGOTIABLE)

**Scopes are independent, isolated units of implementation. An agent picks ONE scope and works ONLY within that scope's boundaries. Scopes do NOT cross into each other.**

### Scope Isolation Rules

| Rule | Enforcement |
|------|-------------|
| **Agent reads only its scope** | In per-scope dir mode, agent reads `scopes/NN-name/scope.md` — NOT other scope files |
| **Agent writes only its scope** | Agent writes evidence ONLY to `scopes/NN-name/report.md` — NOT other scope files |
| **No cross-scope edits** | Agent NEVER modifies another scope's `scope.md` or `report.md` |
| **Shared files are read-only** | `spec.md`, `design.md` are read-only during implementation (modify only in plan/design phases) |
| **Status sync via state.json** | `state.json` is the coordination point between scopes — agents update only their scope entry |
| **_index.md status is derived** | `_index.md` status column is updated only from state.json — never manually |

### DAG-Based Scope Pickup

Scopes declare explicit dependencies via `dependsOn` in `state.json` (or `Depends On` column in `_index.md`). This replaces strict sequential ordering with a dependency graph that enables parallelism.

**Pickup algorithm:**
1. Read `state.json` → find all scopes where `status == "not_started"`
2. For each candidate, check `dependsOn` — ALL referenced scopes must have `status == "done"`
3. From eligible candidates (deps satisfied), pick the **lowest-numbered** scope
4. If no eligible scope exists and incomplete scopes remain → report blocked dependency

**Parallelism:** When multiple scopes have satisfied dependencies, multiple agents can work different scopes simultaneously. Each agent's isolation rules prevent conflicts.

**Sequential fallback:** When no `dependsOn` is declared (or in single-file mode), scopes follow strict sequential ordering — a scope can start only when ALL prior-numbered scopes are `Done`.

### Legacy Migration Trigger

When an agent encounters a spec with **single-file `scopes.md` containing 6+ scopes** and no `scopes/_index.md`:

1. **Before any implementation work**, migrate to per-scope directory layout (see scope-workflow.md → Legacy Format Migration)
2. Migration creates the per-scope structure, extracts scope sections, and sets up the dependency DAG
3. The original `scopes.md` is renamed to `scopes.md.legacy` (preserved, not deleted)
4. `state.json` is updated with `scopeLayout`, `dependsOn`, and `scopeDir` fields
5. The agent then picks up the next eligible scope normally

---

## Bug Awareness (MANDATORY for iterate/implement)

### Pre-Work Check

1. Scan `specs/[current-feature]/bugs/*/state.json` for `status` not in `["done"]`
2. If incomplete bugs found → WARN user, recommend completing bug fixes first
3. Allow user to proceed if they explicitly acknowledge

### Bug Discovery During Work

If a bug is discovered: document in `specs/[feature]/bugs/BUG-NNN-desc/bug.md`, fix it NOW, report to user.

### Zero Deferral Policy (NON-NEGOTIABLE)

**NEVER defer, skip, exclude, or work around ANY issue. Fix ALL issues immediately, regardless of origin.**

- "This is a separate bug" → Fix it NOW
- "Pre-existing issue, not mine" → Fix it anyway
- "Will address in a follow-up" → Fix it NOW
- "Out of scope" → Expand scope to include the fix
- If you encounter a 500, 404, error, or unexpected behavior → FIX THE ROOT CAUSE

### Zero Warnings Policy (NON-NEGOTIABLE)

**ALL code MUST produce ZERO warnings in build, lint, tests, and runtime.**

- Warnings are treated as ERRORS — fix, don't suppress
- Do NOT use `// nolint`, `@ts-ignore`, `eslint-disable` — fix the underlying issue
- Pre-existing warnings in touched files MUST be fixed

---

## Scope Completion Requirements (ABSOLUTE - NO EXCEPTIONS)

### ⛔ THE COMPLETION CHAIN APPLIES HERE (SEE TOP OF DOCUMENT)

**Reminder: DoD item [x] → Scope "Done" → Spec "done". Each level REQUIRES the previous level to be FULLY complete. This is the #1 policy. Re-read the ABSOLUTE COMPLETION HIERARCHY section if uncertain.**

### Scope/Bug CANNOT Be Marked Done Until ALL DoD Items Are `[x]` WITH EVIDENCE

**No exceptions, no shortcuts, no "close enough". EVERY DoD item must have been individually validated with raw terminal output evidence recorded inline. Items without evidence are NOT complete even if checked.**

### 3-Part DoD Validation (implementation + behavior + evidence) — PER ITEM, NOT BATCHED

A DoD item can ONLY be marked `[x]` when ALL THREE conditions are met FOR THAT SPECIFIC ITEM:

1. **Implementation** — code/config/doc change is complete FOR THIS ITEM
2. **Behavior** — validated via actual tool/terminal execution (not assumption) FOR THIS ITEM
3. **Evidence** — raw test/run output with legitimate terminal signals is inserted directly under THIS DoD checkbox item in `scopes.md`

**⚠️ If you did NOT run a command for this item, steps 2 and 3 are NOT satisfied.**

### Evidence Format Inline in DoD Item (scopes.md)

```markdown
- [ ] [Item description]
  - Executed: YES (in current session)
  - Command: `[exact command run]`
  - Exit Code: [actual exit code]
  - Timestamp: [ISO 8601 or HH:MM]
  - Raw Output (verbatim terminal output — must contain recognizable signals like test results, file paths, exit codes, timing):
    ```
    [PASTE VERBATIM terminal output here — must contain real test/build/command output]
    ```
  - Result: PASSED / FAILED

Rules:
- Evidence MUST be attached directly under the DoD checkbox item.
- Do NOT use `→ Evidence: [report.md#...]` links for DoD completion.
- Do NOT use narrative summaries in place of raw output.
```

### Mark DoD Items One at a Time

1. Complete the implementation
2. Validate via actual execution (run tests, curl, browser, DB query)
3. Record evidence directly under the DoD item in `scopes.md` (copy real output)
4. Self-check: "Did I actually run this? Can I point to the terminal output?" — if NO, go back to step 2
5. Mark `[x]` in `scopes.md` only after inline raw output evidence is present under that item
6. Re-read file to confirm the mark was saved

**PROHIBITED:**
- ❌ Batching DoD completions
- ❌ Marking `[x]` without inline raw-output evidence under the item
- ❌ Marking `[x]` for implementation-only (no validation)
- ❌ Pre-checking `[x]` at scope creation time
- ❌ Claiming "will add evidence later"

---

## Required DoD Items (Repo-Agnostic) — Tiered DoD Model

**Every scope's DoD uses a two-tier model: Core Items (scope-specific, individually evidenced) + Build Quality Gate (standard, combined evidence).** Commands/thresholds come from the project's `copilot-instructions.md`. All items require 3-part validation (implementation + behavior + evidence).

**Template integrity (BLOCKING):** Every DoD item MUST be a markdown checkbox (`- [ ]` / `- [x]`). Non-checkbox formatting is invalid and blocks completion.

### Tiered DoD Model Rationale

Scopes repeat the same boilerplate checks (lint, format, no TODOs, artifact lint, docs). Repeating each as a separate DoD item with separate evidence blocks creates evidence fatigue without improving safety. The Tiered DoD model:
- **Core Items** — scope-specific behavior, tests, and implementation. Each validated individually with raw terminal evidence containing legitimate output signals.
- **Build Quality Gate** — standard mechanical checks (lint, format, no TODOs, zero warnings, artifact lint, docs updated). Combined into ONE DoD item with ONE evidence block containing output from all checks.

This reduces per-scope DoD items by ~30% while maintaining the same enforcement strength.

### Mandatory DoD Template — Tiered Format

```markdown
### Definition of Done — Tiered Validation

#### Core Items (scope-specific — each needs individual inline evidence with real terminal output)

- [ ] Implementation complete — [scope-specific description]
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here — must contain real test/build/command output]
    ```
- [ ] [Scope-specific behavior item 1 — describe what is validated]
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here]
    ```
- [ ] Unit tests pass (`unit`) — [scope-specific test description]
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here — must show test names + pass/fail counts]
    ```
- [ ] Functional tests pass (`functional`, if applicable)
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here — must show test names + pass/fail counts]
    ```
- [ ] Integration tests pass (`integration`)
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here — must show test names + pass/fail counts]
    ```
- [ ] UI unit tests pass (`ui-unit`, if UI affected)
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here]
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
- [ ] Stress tests pass (REQUIRED when scope defines latency SLAs — e.g., "under 50ms", "under 200ms")
  - Raw output evidence (inline, verbatim terminal output only):
    ```
    [PASTE VERBATIM terminal output here]
    ```

#### Build Quality Gate (standard — single combined evidence block)

All checks below verified with one combined evidence block. If ANY fails, scope stays In Progress.

- [ ] Build quality gate passes: zero warnings + no TODOs/FIXMEs/stubs + lint/format clean + artifact lint exits 0 + documentation updated
  - Raw output evidence (inline — combined output from build, grep, lint, artifact-lint):
    ```
    [PASTE VERBATIM terminal output here]
    ```
```

**E2E tests are MANDATORY for every scope/bug. Test types follow the Canonical Test Taxonomy.**
**Stress tests are MANDATORY when the scope defines latency SLAs (NFRs).**

### Stress Test Requirement for SLA-Scoped Work (Gate G026 — NON-NEGOTIABLE)

**When a scope defines latency SLAs or performance NFRs (e.g., "under 50ms", "under 200ms", "within 10 seconds", "under 100ms"), that scope MUST include stress tests in its Test Plan and DoD.**

| SLA Example | Stress Test Required? | What to Test |
|-------------|----------------------|-------------|
| `/suggestions` under 50ms | YES | Concurrent request burst, verify P99 < 50ms |
| `/ask` under 200ms | YES | Concurrent NL queries, verify P99 < 200ms |
| Hot-reload within 60s | YES | Concurrent reloads, verify completion time |
| No SLA mentioned | NOT REQUIRED | — |

**Detection rule:** If any Gherkin scenario or NFR in `spec.md` mentions a response time, latency, duration, or throughput target, the corresponding scope MUST have stress test rows in its Test Plan and a stress test DoD item.

**Missing stress tests for SLA scopes = scope CANNOT be Done.**

### Coverage Thresholds

Coverage thresholds are defined per-project (check `copilot-instructions.md` or project test config). If not specified, coverage must not decrease.

---

## ⚠️ Execution Evidence Standard (ABSOLUTE - NON-NEGOTIABLE)

**Evidence is ONLY valid when it comes from actual tool/terminal execution in the current agent session.**

Claiming "tests pass" or "endpoint returns 200" without having run the command is **fabrication** and absolutely prohibited.

### Valid vs Invalid Evidence

| ✅ Valid | ❌ Invalid |
|----------|-----------|
| Terminal output showing exit code 0 | Writing "Exit Code: 0" without running command |
| Actual curl response body from terminal | Writing "HTTP 200" without executing curl |
| E2E test runner output with pass/fail counts | Writing "E2E tests pass" without running suite |
| `runTests` tool output showing results | Asserting "tests pass" from code inspection |

### Rules

1. **RUN BEFORE RECORDING** — execute first, then record actual output
2. **TERMINAL OUTPUT IS TRUTH** — evidence = real command + real exit code + real output
3. **SESSION-BOUND** — prior session evidence is NOT valid for current DoD items
4. **SHOW, DON'T TELL** — record actual output, not summaries of what you think happened
5. **SELF-CHECK** — before marking `[x]`: "Did I run this? Can I point to terminal output?" If NO → go run it

### PROHIBITED

- ❌ Writing "tests pass" without running tests
- ❌ Copying expected output instead of actual output
- ❌ Marking DoD items based on "code looks correct"
- ❌ Summarizing what "should" happen instead of what DID happen
- ❌ Marking ALL DoD items in one batch without individual execution evidence

---

## Agent Honesty Contract (MANDATORY)

Every scope/bug execution MUST emit a structured completion statement:

```yaml
status: done | blocked | failed | specs_hardened | docs_updated | validated
workflowMode: <active mode from workflows.yaml>
statusCeiling: <mode's statusCeiling from workflows.yaml>
claims: [{ id, statement, evidenceRef: report.md#section | scopes/NN-name/report.md#section }]
unknowns: [string]  # MUST list explicitly — no hidden uncertainty
nextActions: [string]
```

**Rules:** No evidence = no claim. No vague success language without raw output evidence. If any gate/evidence is missing → status MUST be `blocked`. Session-bound evidence only. Status MUST NOT exceed mode's `statusCeiling`.

---

## Best-Solution Selection Protocol (Non-Trivial Work)

For multi-file, behavior-affecting, or architecture-impacting work, evaluate ≥2 options before finalizing. Record in `report.md`: options, tradeoff scoring (correctness, regression risk, complexity, rollback safety, testability), chosen option + rationale, top 3 failure modes with test coverage.

---

## Machine-Verifiable Completion Gate (MANDATORY)

Before status → "done", complete deterministic validation (not narrative claims):

- Test Plan ↔ DoD parity confirmed
- Gherkin/use-case ↔ test-case traceability confirmed
- All required test types executed and passing
- Required test skips = 0
- Evidence sections have raw output with legitimate terminal signals
- Unresolved unknowns = 0

**If ANY validation output is missing → status = `blocked`. This gate is authoritative over narrative summaries.**

---

## ⚠️ Anti-Fabrication Policy — Test Evidence Integrity (NON-NEGOTIABLE)

**This policy prevents agents from marking bugs/features as "done" without running ALL required tests. It extends the Execution Evidence Standard with enforceable gates.**

**All gates below are BLOCKING — failing ANY gate keeps status at "in_progress".**

### Gate 0: Bug Reproduction (bugs only — BEFORE any fix work)

Before implementing ANY bug fix:

1. Follow the EXACT reproduction steps from `bug.md` using available tools
2. Record broken behavior in `report.md` under `## Bug Reproduction — Before Fix`
3. After fix: repeat same steps, record corrected behavior under `## Bug Reproduction — After Fix`
4. If bug cannot be reproduced → STOP and document why. Do NOT fix what you cannot reproduce.
5. If fix cannot be verified → bug is NOT fixed, status stays "in_progress"

### Gate 1: Test Plan ↔ DoD Cross-Check

- Every Test Plan row MUST have a matching DoD checkbox with inline raw-output evidence block
- Every test file path in Test Plan MUST be verified via `ls -la` (output in report.md)
- **Gherkin traceability:** E2E test count ≥ Gherkin scenario count; each scenario traceable by test name or comment
- **E2E specificity check:** Every E2E row in the Test Plan MUST reference a specific scenario (by ID or description). Generic rows like `[UI workflow]` or `[API workflow]` without scenario mapping = gate FAILS

### Gate 2: E2E Test Existence

- E2E test files MUST exist on disk (proven by `ls -la`)
- E2E tests MUST be executed against live system with raw output in report.md
- If E2E tests are skipped → document in `## ⚠️ SKIPPED TESTS` section; status stays "in_progress"

### Gate 3: Raw Evidence Legitimacy Standard

- Evidence MUST be raw copy-pasted terminal output, NOT agent-written summaries
- Evidence blocks MUST contain at least 2 distinct terminal output signal types (test pass/fail counts, file paths with extensions, exit codes, timing/duration, build tool names, HTTP status codes, count patterns, filesystem output)
- Blocks that lack terminal output signals are rejected as fabricated regardless of length
- A block of 10+ lines of prose in a code fence is NOT valid evidence — content must be real terminal output

### Gate 4: Test Type Completeness

ALL required test types (per Canonical Test Taxonomy) must be executed with raw evidence before status → "done". E2E tests (`e2e-api`/`e2e-ui`) are ALWAYS required. Use project-specific commands from `copilot-instructions.md`.

### Gate 5: Pre-Completion Self-Audit

Execute this checklist with actual tool calls before status → "done":

```
[ ] grep -r "TODO\|FIXME\|HACK\|STUB" [changed-files] → zero results
[ ] grep -rn "t\.Skip\|\.skip(\|xit(\|xdescribe(\|\.only(\|test\.todo\|it\.todo" [changed-test-files] → zero results
[ ] bash .github/bubbles/scripts/artifact-lint.sh {FEATURE_DIR} → exit code 0
[ ] ls -la [every-test-file-in-test-plan] → all exist
[ ] Test Plan rows = test-related DoD items (count match)
[ ] All DoD items use checkbox syntax (`- [ ]` / `- [x]`)
[ ] uservalidation.md has checked-by-default checkboxes (`- [x]`)
[ ] Every DoD item has inline raw-output evidence block directly below the checkbox item
[ ] Every DoD item's evidence block contains legitimate terminal output signals (not just prose)
[ ] E2E tests executed in THIS session with output in report.md
[ ] No DoD items were pre-checked [x] at creation time
[ ] (If UI scope) Gate 9 Docker Bundle Freshness verified — hashes differ, feature strings found, container fresh
[ ] (If SLA scope) Stress tests exist in Test Plan and DoD, executed and passing (Gate G026)
[ ] Scope isolation: only this scope's scope.md and report.md were modified (per-scope dir mode)
```

### Gate 6: Skip Marker Scan

Scan ALL changed/new test files: `grep -rn 't\.Skip\|\.skip(\|xit(\|xdescribe(\|xcontext(\|\.only(\|test\.todo\|it\.todo\|pending(' [files]`

Zero skip/only/todo markers allowed. If found → remove and fix the underlying issue.

### Gate 7: E2E Test Substance

- E2E tests MUST verify ACTUAL USER BEHAVIOR, not proxies (status-code-only, element-existence, page-loads)
- State-changing tests MUST verify the EFFECT (reload/re-query after mutation)
- Tests MUST NOT accept multiple status codes (`expect([200, 404])` is FORBIDDEN)
- UI bug tests MUST use browser interaction, not just API calls
- **Quality heuristic:** If a test could pass against a completely broken implementation, it is INVALID

### Gate 8: User-Facing Verification (FINAL GATE)

> "If a user followed the reproduction steps RIGHT NOW, would they see the bug is fixed?"

- YES with confidence → proceed to mark done
- MAYBE or NO → status stays "in_progress"
- "I didn't try" → go back to Gate 0

This gate is SEMANTIC (does it actually work?) vs the structural gates above. Cannot be satisfied by automated tests alone — trace through the user's manual workflow.

**Enhanced verification for UI changes (MANDATORY when scope includes frontend):**
1. **Bundle Content Verification** — After Docker rebuild, verify the served bundle contains expected feature code:
   ```bash
   # List chunk files in the running container (use project-specific container name and static root)
   docker exec <frontend-container> ls <static-root>/assets/ | head -20
   # Grep for expected data-testids / feature strings in the served chunks
   docker exec <frontend-container> grep -rl '<expected-data-testid>' <static-root>/assets/ | head -5
   ```
   If expected feature strings are NOT found in the served bundle → build is stale → status stays "in_progress".
   
   **Note:** `<frontend-container>` and `<static-root>` are project-specific values defined in `copilot-instructions.md` (e.g., container `my-frontend`, root `/usr/share/nginx/html`).

2. **Live Browser Verification** — Automated E2E tests run in clean browser profiles (no cache). To verify ACTUAL user experience:
   - Navigate to the affected page in a real or MCP-controlled browser
   - Capture a screenshot or page snapshot confirming the feature is visually present
   - Record the verification evidence in `report.md`
   - If MCP Playwright is available, use `browser_snapshot` + `browser_take_screenshot`

3. **Browser Cache Freshness Instruction** — After confirming features are present in the served bundle:
   - Instruct the user: "After Docker rebuild, hard-refresh your browser (Ctrl+Shift+R / Cmd+Shift+R) to clear cached bundles."
   - Record this instruction in `report.md` as a post-deployment note
   - Modern bundlers (Vite, webpack) use content-hashed filenames (`index-{hash}.js`), but `index.html` (which references them) may be cached by the browser
   - Even with `no-cache` headers on `index.html`, some browsers may still use stale copies

### Gate 9: Docker Bundle Freshness (MANDATORY for UI scopes)

**Applies when the scope modifies frontend/UI code served from a Docker container.**

This gate prevents the scenario where automated tests pass (clean browser) but the user sees stale UI (cached browser).

**Project-specific values required** (defined in `copilot-instructions.md`):
- `<frontend-container>` — Docker container name serving the frontend (e.g., `my-frontend`)
- `<frontend-image>` — Docker image name for the frontend (e.g., `my-frontend`)
- `<static-root>` — Path to static assets inside the container (e.g., `/usr/share/nginx/html`)
- `<stop-command>` — Command to stop services (e.g., `docker compose down`)
- `<start-command>` — Command to start services (e.g., `docker compose up -d`)

#### 9.1 Build Hash Tracking

Record bundle fingerprints before and after changes in `report.md`:

```markdown
### Build Hash Tracking
| Phase | index.html hash | Chunk files (sample) | Container Image ID |
|-------|----------------|----------------------|--------------------|
| Pre-change | `md5sum index.html` | `ls assets/*.js \| head -5` | `docker images -q <frontend-image>` |
| Post-change | `md5sum index.html` | `ls assets/*.js \| head -5` | `docker images -q <frontend-image>` |
```

**Verification commands:**
```bash
# Get container image ID
docker inspect <frontend-container> --format '{{.Image}}' | cut -c1-12
# Get index.html fingerprint from running container
docker exec <frontend-container> md5sum <static-root>/index.html
# List JS chunk filenames (content-hashed)
docker exec <frontend-container> ls <static-root>/assets/*.js | head -10
```

**Post-change hashes MUST differ from pre-change.** If they match → Docker cache served stale build → rebuild with `--no-cache`.

#### 9.2 Anti-Stale-Container Check

After starting services or Docker rebuild, verify the running container uses the latest image:

```bash
# Compare running container's image to latest built image
RUNNING=$(docker inspect <frontend-container> --format '{{.Image}}' 2>/dev/null | cut -c8-19)
LATEST=$(docker images <frontend-image> --format '{{.ID}}' | head -1)
echo "Running: $RUNNING | Latest: $LATEST"
if [ "$RUNNING" != "$LATEST" ]; then echo "⚠️ STALE CONTAINER — recreate required"; fi
```

If stale: stop and restart services using project CLI to force container recreation.

#### 9.3 Feature String Verification

For UI changes, identify 3-5 key data-testid attributes or feature strings that MUST appear in the served bundle:

```bash
# Example: verify specific data-testids exist in served JS chunks
for testid in "<data-testid-1>" "<data-testid-2>" "<data-testid-3>"; do
  found=$(docker exec <frontend-container> grep -rl "$testid" <static-root>/assets/ 2>/dev/null | wc -l)
  echo "$testid: $found file(s)"
done
```

**ALL expected feature strings MUST be found.** Missing strings = stale build = BLOCKING.

#### 9.4 Evidence Template (in report.md)

```markdown
## Docker Bundle Freshness — Gate 9

### Build Hash Tracking
- Pre-change index.html hash: [hash]
- Post-change index.html hash: [hash]
- Hashes differ: ✅/❌

### Container Freshness
- Running image ID: [id]
- Latest built image ID: [id]
- Match: ✅/❌

### Feature String Verification
| Feature String | Found in Bundle | Status |
|----------------|-----------------|--------|
| [data-testid-1] | Yes/No | ✅/❌ |
| [data-testid-2] | Yes/No | ✅/❌ |
| [data-testid-3] | Yes/No | ✅/❌ |

### Browser Cache Note
- User instructed to hard-refresh (Ctrl+Shift+R): ✅
```

### Status Transition Summary: "in_progress" → "done"

**ALL conditions must be TRUE — failing ANY ONE blocks the transition:**

| # | Requirement | Gate |
|---|-------------|------|
| 1 | **Status Ceiling respected** (mode's `statusCeiling` allows `done`) | Status Ceiling |
| 2 | **ALL scopes are "Done"** (zero Not Started/In Progress/Blocked) | G024 |
| 3 | **ALL DoD items are [x] with inline raw evidence** (zero unchecked, zero without evidence) | G025 |
| 4 | **EACH DoD item was individually validated** (not batch-checked) | G025 |
| 5 | **ALL test-related DoD items have passing test output** (with legitimate terminal output signals) | G025 |
| 6 | **ALL required test types executed** (unit, integration, e2e, stress per scope type) | 4 |
| 7 | **100% real scenario coverage** (all Gherkin scenarios, error paths, boundary conditions) | G025 |
| 8 | **Tests are real** (no mocks of internal code, real test DBs, real assertions) | 3 |
| 9 | Bug reproduced before/after fix (bugs only) | 0 |
| 10 | Artifact lint passes (`artifact-lint.sh`) | 5 |
| 11 | Test files exist on disk | 1, 2 |
| 12 | Gherkin ↔ E2E traceability | 1 |
| 13 | Evidence contains legitimate terminal output signals per test type | 3 |
| 14 | Test Plan ↔ DoD parity | 1 |
| 15 | Self-audit passes | 5 |
| 16 | Session-bound evidence only | (Execution Evidence Standard) |
| 17 | Zero deferral (no issues skipped/deferred) | (Zero Deferral Policy) |
| 18 | Zero warnings (build + lint + tests + runtime) | (Zero Warnings Policy) |
| 19 | Skip markers clean | 6 |
| 20 | E2E tests verify actual behavior | 7 |
| 21 | User-facing verification passes (+ live browser for UI) | 8 |
| 22 | Docker bundle freshness verified (UI scopes) | 9 |
| 23 | State transition guard script exits 0 | G023 |
| 24 | **Stress tests pass when scope defines latency SLAs** | G026 |
| 25 | **Scope isolation respected** (agent modified only its scope artifacts in per-scope dir mode) | Scope Isolation |
| 26 | **Build Quality Gate passes** (zero warnings + lint + format + no TODOs + artifact lint + docs) | Tiered DoD |
| 27 | **Findings artifact updates complete** (all discovered issues have corresponding Gherkin/TestPlan/DoD entries in scopes.md) | G031 |
| 28 | **Design readiness verified** (design.md and scopes.md exist with substantive content before implementation started; auto-escalation to bubbles.design + bubbles.plan if missing) | G033 |
| 29 | **Vertical slice complete** (cross-layer scopes: every frontend API call maps to a .route()-wired backend handler, gateway forwards all service routes, E2E tests exercise full stack; pure-frontend or pure-backend scopes exempt) | G035 |

**Items 2, 3, 4, 5, 6, 7, and 8 are the CORE COMPLETION CHAIN. They enforce that:**
- Every DoD item is individually validated with raw evidence
- Every scope is Done with all DoD items checked  
- Every spec has all scopes Done before it can be done
- Every test covers real scenarios through the real stack
### ⚠️ Status Ceiling Enforcement (NON-NEGOTIABLE)

**The workflow mode's `statusCeiling` (from `.github/bubbles/workflows.yaml`) is the MAXIMUM status that may be set in `state.json`. No agent may exceed it.**

**Modes that do NOT include `implement` + `test` phases MUST NOT set `status: "done"`.** These modes produce artifact improvements (specs, docs, validation reports) but do not constitute completed implementation work.

| Mode Category | Allowed Final Status Values | Forbidden |
|---------------|---------------------------|-----------|
| Implementation modes (`full-delivery`, `full-delivery-strict`, `value-first-e2e-batch`, `feature-bootstrap`, `bugfix-fastlane`, `chaos-hardening`) | `done`, `in_progress`, `blocked` | — |
| Quality chain modes (`harden-to-doc`, `gaps-to-doc`, `harden-gaps-to-doc`, `test-to-doc`, `chaos-to-doc`) | `done`, `in_progress`, `blocked` | — |
| Artifact-only modes (`spec-scope-hardening`) | `specs_hardened`, `in_progress`, `blocked` | `done` |
| Docs-only modes (`docs-only`) | `docs_updated`, `in_progress`, `blocked` | `done` |
| Validation/audit modes (`validate-only`, `audit-only`, `validate-to-doc`) | `validated`, `in_progress`, `blocked` | `done` |
| Resume modes (`resume-only`) | `in_progress`, `blocked` | `done` |

**Enforcement rules:**
1. Before setting status in `state.json`, resolve the active mode's `statusCeiling` from `.github/bubbles/workflows.yaml`
2. If the intended status exceeds the ceiling, cap it at the ceiling value
3. Record `workflowMode` in `state.json` so downstream agents can verify the ceiling was respected
4. The `completedPhases` array is informational — it records which phases ran, NOT whether implementation is complete
5. **Violation of this policy (setting `done` from an artifact-only mode) is a governance failure**

---

## Test Execution Gate (MANDATORY)

Before marking ANY test-related DoD item complete, follow the Execution Evidence Standard above and Anti-Fabrication Gates 3-4. In summary:

1. **EXECUTE** all required test types using project-specific commands (from `copilot-instructions.md`)
2. **VERIFY** pass (exit code 0) and coverage meets project threshold — from actual terminal output
3. **RECORD** in report.md using the Evidence Format Template (verbatim terminal output with recognizable signals per type)
4. **CROSS-CHECK** against Anti-Fabrication Gates before status → "done"

---

## Fix ALL Test Failures Policy (MANDATORY)

**Test failures are BLOCKING. There is NO "pre-existing" exemption.**

When tests fail:
1. DO NOT proceed, mark DoD items complete, or claim "pre-existing"
2. Analyze and fix ALL failures
3. Re-run until ALL pass (exit code 0)
4. Record in report.md: pre-existing failures count, fixes applied, final passing run

**Flaky test handling:** If a test passes on re-run without code changes, it is flaky. Flaky tests MUST be fixed (not ignored or retried). Common causes: race conditions, missing `await`, shared mutable state, port conflicts. Document the flakiness fix in report.md.

---

## Session Tracking

**Primary mechanism:** Per-feature `{FEATURE_DIR}/state.json` — used by iterate, implement, and bug agents to track scope progress, current phase, and resume state.

**Cross-session coordination (optional):** Agents may update `.specify/memory/bubbles.session.json` for global session state. See [BUBBLES_SESSIONS.md](../../docs/BUBBLES_SESSIONS.md) for schema.

---

## ⚠️ Sequential Spec Completion Policy (NON-NEGOTIABLE — Gate G019)

**A spec MUST be fully complete before ANY work begins on the next spec. No exceptions.**

### ⛔ SPEC CANNOT BE DONE UNTIL ALL SCOPES ARE DONE (ABSOLUTE — Gate G024)

**This is the most critical completion rule. A spec's state.json status CANNOT be set to "done" while ANY scope definition file has a status other than "Done".**

```
IF any scope status != "Done" THEN spec status CANNOT be "done"
IF any scope has unchecked DoD items THEN that scope is NOT "Done"
IF any DoD item lacks raw evidence THEN that item is NOT checked
```

**Verification (MANDATORY before setting spec status to done):**
```bash
# 1. ALL scopes must be Done — this MUST return 0
# Per-scope directory mode:
grep -c 'Status:.*Not Started\|Status:.*In Progress\|Status:.*Blocked' {FEATURE_DIR}/scopes/*/scope.md
# Single-file mode:
grep -c 'Status:.*Not Started\|Status:.*In Progress\|Status:.*Blocked' {FEATURE_DIR}/scopes.md

# 2. ALL DoD items must be checked — this MUST return 0
# Per-scope directory mode:
grep -c '^\- \[ \]' {FEATURE_DIR}/scopes/*/scope.md
# Single-file mode:
grep -c '^\- \[ \]' {FEATURE_DIR}/scopes.md

# 3. ALL DoD items must have evidence — verify manually that every [x] item has a raw output block beneath it
```

**If ANY of these checks fail → state.json status stays "in_progress". There is NO alternative path.**

### ⛔ ALL DoD ITEMS MUST HAVE RECORDED RAW VALIDATION RESULTS (ABSOLUTE — Gate G025)

**Every single DoD item that is marked [x] MUST have raw terminal output evidence directly beneath it in scopes.md. No narrative summaries. No references to report.md. No "see above". The evidence must be INLINE and REAL.**

**What counts as valid evidence for a DoD item:**
- Actual terminal output from running a command (must contain recognizable signals: test results, file paths, exit codes, timing)
- Includes the command that was run
- Includes the exit code
- Shows real test counts, real error/success messages
- Was generated in the CURRENT session

**What does NOT count:**
- "Tests pass" or "All green" without terminal output
- References like "→ Evidence: [report.md#section]"
- Evidence from a previous session
- Expected/predicted output that wasn't actually observed
- Content that lacks terminal output signals (prose in a code fence)

This policy prevents the critical failure mode where agents advance to new specs while leaving previous ones incomplete, with unchecked DoD items, missing evidence, or unexecuted specialist phases.

### Hard Sequential Block

| Rule | Enforcement |
|------|-------------|
| **Previous spec must be `done` or `blocked`** before starting next | Check `state.json` status of previous spec |
| **ALL DoD items must be `[x]`** in previous spec | Parse active scope file(s) for unchecked `- [ ]` items |
| **ALL specialist agents must have executed** for previous spec | Check that `completedPhases` in `state.json` includes all mode-required phases |
| **Artifact lint must pass** for previous spec | Run `artifact-lint.sh` on previous spec |
| **Scope report artifact(s) must have real evidence** for previous spec | Verify `report.md` or per-scope `report.md` files contain evidence sections with legitimate terminal output signals |

### Verification Procedure (MANDATORY before advancing to next spec)

```bash
# 1. Check previous spec state
prev_status=$(grep -oP '"status":\s*"\K[^"]+' specs/<prev-spec>/state.json)
if [[ "$prev_status" != "done" && "$prev_status" != "blocked" ]]; then
  echo "BLOCKED: Previous spec status is '$prev_status', not done/blocked"
  exit 1
fi

# 2. Check all DoD items are checked
# Per-scope directory mode:
unchecked=$(grep -c '^\- \[ \]' specs/<prev-spec>/scopes/*/scope.md || true)
# Single-file mode fallback:
# unchecked=$(grep -c '^\- \[ \]' specs/<prev-spec>/scopes.md || true)
if [[ "$unchecked" -gt 0 ]]; then
  echo "BLOCKED: Previous spec has $unchecked unchecked DoD items"
  exit 1
fi

# 3. Run artifact lint on previous spec
bash .github/bubbles/scripts/artifact-lint.sh specs/<prev-spec>
# Must exit 0

# 4. Verify evidence depth in scope report artifact(s)
# Per-scope directory mode example:
evidence_sections=$(grep -c '```' specs/<prev-spec>/scopes/*/report.md || true)
# Single-file mode fallback:
# evidence_sections=$(grep -c '```' specs/<prev-spec>/report.md || true)
if [[ "$evidence_sections" -lt 6 ]]; then
  echo "BLOCKED: Previous spec report artifact(s) have insufficient evidence blocks"
  exit 1
fi
```

### What Happens When Blocked

If the previous spec is `blocked`:
- The orchestrator MUST first attempt to unblock it (re-invoke the appropriate specialist agent)
- Only if the block is unresolvable (retry limits exceeded), the orchestrator may skip to the next spec
- The skip MUST be logged with explicit justification in the session report
- Skipping is NEVER allowed when `continueOnBlocked: false`

**PROHIBITED:**
- ❌ Starting next spec while previous has unchecked DoD items
- ❌ Starting next spec while previous has unexecuted specialist phases
- ❌ Starting next spec while artifact lint fails for previous
- ❌ Marking previous spec `done` without real evidence, then moving on
- ❌ Batch-completing previous spec's DoD items to unblock advancement

---

## ⚠️ Cross-Agent Output Verification (NON-NEGOTIABLE — Gate G020)

**When the orchestrator receives output from a specialist agent, it MUST verify the output is real before advancing to the next phase.**

### Verification Checklist (MANDATORY after each specialist `runSubagent` call)

| Check | How to Verify | Failure Action |
|-------|---------------|----------------|
| **Commands were executed** | Specialist output contains actual terminal commands with exit codes | Re-invoke specialist |
| **Evidence is real** | Output contains raw terminal text (not summaries, not "tests pass") | Re-invoke specialist |
| **Files were modified** | `git diff --name-only` or `ls -la` confirms expected file changes | Re-invoke specialist |
| **Tests actually ran** | Test output contains specific pass/fail counts, not claims | Re-invoke specialist with explicit test execution instruction |
| **DoD items have evidence** | Each `[x]` in scopes.md has inline raw output block underneath | Revert `[x]` to `[ ]`, re-invoke specialist |

### Fabrication Detection Heuristics (MANDATORY — Gate G021)

The orchestrator (and all agents self-checking) MUST apply these heuristics to detect fabricated work:

#### Heuristic 1: Evidence Legitimacy
```
IF a DoD evidence block lacks at least 2 distinct terminal output signal types
   (test results, file paths, exit codes, timing, build tool names, HTTP codes,
    count patterns like "N passed", filesystem output like ls/grep)
THEN it is presumed fabricated → REJECT, re-execute

Note: Line count alone is NOT sufficient. A code block with 20 lines of prose
is NOT valid evidence. Content must be recognizable terminal/tool output.
```

#### Heuristic 2: Template Matching
```
IF evidence text matches the DoD template verbatim (e.g., "[PASTE VERBATIM terminal output here]")
THEN it is definitely fabricated → REJECT, re-execute
```

#### Heuristic 3: Batch Completion
```
IF multiple DoD items were marked [x] in a single edit without intervening command executions
THEN batch completion is presumed → REJECT all batch-marked items, re-execute one at a time
```

#### Heuristic 4: Timestamp Anomalies
```
IF all evidence timestamps are identical or missing
THEN sequential execution is not proven → require re-execution with timestamps
```

#### Heuristic 5: Impossible Success
```
IF ALL tests pass on first run AND implementation was non-trivial (>50 lines changed)
THEN verify by re-running tests independently — first-time-perfect is suspicious
```

#### Heuristic 6: Missing Command Artifacts
```
IF a DoD item claims "Executed: YES" but no command is recorded
THEN it is fabricated → REJECT
```

#### Heuristic 7: Copy-Paste Evidence
```
IF evidence blocks across different DoD items contain identical text
THEN evidence is duplicated/fabricated → REJECT both items
```

#### Heuristic 8: Summary Language Detection
```
IF evidence contains phrases like "all tests pass", "everything works", "no issues found",
   "verified successfully", "confirmed working" WITHOUT accompanying raw terminal output
THEN it is a narrative summary, not evidence → REJECT
```

#### Heuristic 9: Default/Fallback/Stub Code Detection
```
IF implementation source files contain default-value patterns (unwrap_or, unwrap_or_default,
   || "default", ?? "fallback", os.getenv with default, ${VAR:-default}),
   stub functions (fn fake_/mock_/stub_/placeholder_), or hardcoded data returns
   (vec![...{..."literal"}], static RESPONSES, MOCK_DATA constants)
THEN real implementation policy is violated → REJECT implementation, run reality scan
```

#### Heuristic 10: Evidence Without Tool Execution (Terminal Provenance)
```
IF an evidence block exists in the agent's output (report.md, scopes.md, or inline)
   BUT no terminal tool call (run_in_terminal, runTests, get_terminal_output)
   preceded it in the current session to produce that specific output
THEN the evidence is agent-fabricated → REJECT, re-execute the command and capture real output

ADDITIONALLY:
IF evidence text contains exact formatting, exit codes, pass/fail counts, or status lines
   that do not appear verbatim in any tool response in the current session
THEN the agent composed/reconstructed the evidence → REJECT as fabricated
```

### Application Points

These heuristics MUST be applied:
1. **After each specialist agent returns** — orchestrator checks output
2. **Before marking any DoD item `[x]`** — agent self-checks
3. **Before advancing to next phase** — orchestrator verifies
4. **Before promoting spec status** — final verification pass
5. **In artifact lint** — automated detection

---

## ⚠️ Specialist Agent Completion Chain (NON-NEGOTIABLE — Gate G022)

**ALL specialist agents required by the workflow mode MUST execute and return verified results before spec promotion.**

### Required Specialists by Mode

| Mode | Required Specialists (ALL must complete) |
|------|------------------------------------------|
| `full-delivery` | implement, test, docs, validate, audit, chaos |
| `full-delivery-strict` | implement, test, docs, validate, audit, chaos (with per-phase evidence) |
| `value-first-e2e-batch` | implement, test, docs, validate, audit, chaos |
| `feature-bootstrap` | implement, test, docs, validate, audit |
| `bugfix-fastlane` | implement, test, validate, audit |
| `chaos-hardening` | chaos, implement, test, validate, audit |
| `harden-to-doc` | harden, test, chaos, validate, audit, docs |
| `gaps-to-doc` | gaps, test, chaos, validate, audit, docs |
| `test-to-doc` | test, validate, audit, docs |
| `chaos-to-doc` | chaos, validate, audit, docs |
| `validate-to-doc` | validate, audit, docs |
| `spec-scope-hardening` | harden, docs, validate, audit (no implementation) |
| `docs-only` | docs, validate, audit |

### Completion Tracking (MANDATORY)

The orchestrator MUST maintain a per-spec specialist completion ledger:

```yaml
spec: "NNN-feature-name"
specialists:
  implement:
    executed: true/false
    exitStatus: pass/fail/not_run
    evidence: "report.md#implement-evidence"
    verifiedAt: "RFC3339"
  test:
    executed: true/false
    exitStatus: pass/fail/not_run
    evidence: "report.md#test-evidence"
    verifiedAt: "RFC3339"
  docs:
    executed: true/false
    exitStatus: pass/fail/not_run
    evidence: "report.md#docs-evidence"
    verifiedAt: "RFC3339"
  validate:
    executed: true/false
    exitStatus: pass/fail/not_run
    evidence: "report.md#validation-evidence"
    verifiedAt: "RFC3339"
  audit:
    executed: true/false
    exitStatus: pass/fail/not_run
    evidence: "report.md#audit-evidence"
    verifiedAt: "RFC3339"
  chaos:
    executed: true/false
    exitStatus: pass/fail/not_run
    evidence: "report.md#chaos-evidence"
    verifiedAt: "RFC3339"
```

### Promotion Block

**Before promoting a spec to `done`:**

1. Check that ALL required specialists for the mode have `executed: true` and `exitStatus: pass`
2. Check that evidence references are non-empty and point to real report.md sections
3. Check that each specialist's evidence section contains legitimate terminal output signals
4. If ANY specialist has `executed: false` or `exitStatus: fail` → spec CANNOT be promoted

**PROHIBITED:**
- ❌ Promoting spec to `done` with any specialist showing `executed: false`
- ❌ Promoting spec to `done` with any specialist showing `exitStatus: fail`
- ❌ Claiming a specialist "executed" without having invoked it via `runSubagent`
- ❌ Skipping required specialists to advance faster
- ❌ Substituting one specialist's work for another (e.g., claiming audit covers validation)

---

## ⚠️ Phase-Scope Coherence (ABSOLUTE — Gate G027)

**`completedPhases` and `completedScopes` MUST be coherent. Claiming implementation lifecycle phases while scopes remain incomplete is fabrication.**

### The Coherence Rule

```
┌──────────────────────────────────────────────────────────────────────┐
│  completedPhases includes "implement" or "test"                      │
│     ↓ REQUIRES                                                       │
│  completedScopes is NON-EMPTY                                        │
│     ↓ REQUIRES                                                       │
│  Scope artifacts have matching "Done" status markers                 │
│                                                                      │
│  VIOLATION: completedPhases claims 6-7 phases but                    │
│             completedScopes shows 0 or partial = FABRICATION         │
└──────────────────────────────────────────────────────────────────────┘
```

### Detection Rules (Mechanically Enforced by Guard Script Check 15)

| Condition | Verdict |
|-----------|---------|
| `completedPhases` includes `implement` or `test` BUT `completedScopes` is empty | 🔴 FABRICATION — phases were written without work being done |
| `completedPhases` claims ≥5 phases BUT only partial scopes are Done | 🔴 INCOHERENCE — full pipeline claimed on partial work |
| `completedScopes` has entries BUT `implement` not in `completedPhases` | ⚠️ WARNING — scopes done but phase not recorded |
| `completedScopes` count matches Done scope count in artifacts | ✅ COHERENT |

### What This Gate Catches

**Pattern observed in 12 specs:** Agents wrote `completedPhases: ["implement", "test", "docs", "validate", "audit", "chaos"]` into state.json while `completedScopes: []` — claiming the entire lifecycle was complete when zero scopes had actually finished. Gate G027 makes this a BLOCKING failure.

### Enforcement

The guard script (`state-transition-guard.sh` Check 15) mechanically enforces this by:
1. Extracting `completedPhases` and checking for implementation phase names
2. Cross-referencing against `completedScopes` count from state.json
3. Cross-referencing against scope artifact status markers (Done count)
4. Failing if implementation phases are claimed but scopes are empty/partial

---

## ⚠️ Implementation Reality Scan (ABSOLUTE — Gate G028)

**Source files referenced in scope artifacts MUST NOT contain stub, fake, hardcoded, or simulation data patterns. Real implementations require real data flow.**

### What This Gate Detects

| Pattern Category | Examples | Why It's a Violation |
|-----------------|----------|---------------------|
| **Gateway/Backend stubs** | `vec![Struct { field: "literal" }]` returned from handlers | Handler returns hardcoded data instead of querying a real service |
| **Simulation data calls** | `getSimulationData()`, `simulate_*_data()`, `generate_fake_*()` | Production code calls simulation generators instead of real backends |
| **Frontend hardcoded data** | `MOCK_DATA = [...]`, `SAMPLE_DATA = [...]`, `import { mockData }` | UI uses static arrays instead of API calls |
| **Missing API calls** | Hook/service files with zero `fetch`, `useQuery`, `axios` calls | Data-layer code returns data without ever calling a backend |
| **Prohibited simulation helpers** | `seeded_pick()`, `seeded_range()` in production Rust code | Non-model-based simulation in production paths |

### Scan Categories (4 scans, applied to scope-referenced files)

1. **Backend Stub Scan** — Checks `.rs`, `.go`, `.py`, `.java` files for hardcoded response patterns, `generate_fake_*`, `simulation_data`, static response arrays
2. **Frontend Fake Data Scan** — Checks `.ts`, `.tsx`, `.js`, `.jsx`, `.dart` files for `getSimulationData`, `mockData`, `SAMPLE_DATA`, simulation module imports
3. **Frontend API Call Absence Scan** — Checks data hook/service files for ZERO occurrences of `fetch`, `useQuery`, `axios`, `grpc` — a hook that fetches no data is returning hardcoded data
4. **Prohibited Simulation Helpers** — Checks `.rs` production files for `seeded_pick`/`seeded_range` patterns

### What This Gate Catches

**Pattern observed in specs 018, 020, 022-030:** Gateway handlers returning `vec![...]` with hardcoded/seeded struct construction instead of calling real backend services. The handler compiles and "works" but serves fabricated data.

**Pattern observed in specs 013, 015, 016, 017:** Frontend hooks calling `getSimulationData()` or containing `const data = [...]` with zero `fetch()` calls. The UI renders data that was never fetched from a real backend.

### Enforcement

The scan script (`implementation-reality-scan.sh`) runs as guard script Check 16 and:
1. Extracts source file paths from scope artifacts (backtick-wrapped paths)
2. Scans each file against 4 pattern categories
3. Skips test files (stubs in tests are a separate concern)
4. Skips comment lines (prose about stubs is allowed)
5. Fails with blocking violations for any match

### Running Manually

```bash
# Full scan with verbose context
bash .github/bubbles/scripts/implementation-reality-scan.sh specs/<NNN-feature-name> --verbose

# As part of pre-completion self-audit
bash .github/bubbles/scripts/state-transition-guard.sh specs/<NNN-feature-name>
# (Check 16 runs automatically)
```

### PROHIBITED Patterns (Reference — from scan script)

```text
# Backend (any handler/service file):
❌ vec![Struct { field: "hardcoded" }]       → Query real data store
❌ simulate_*_data() in handler              → Call real service
❌ generate_fake_*() in handler              → Call real service
❌ static RESPONSES: [...]                   → Dynamic from data store
❌ fn fake_handler() / fn stub_handler()     → Real handler implementation

# Frontend (any hook/service/component file):
❌ getSimulationData()                       → fetch() from real API
❌ import { mockData } from './mock'         → import { useQuery } from API layer
❌ const SAMPLE_DATA = [...]                 → useQuery/fetch from backend
❌ Hook with zero fetch/useQuery calls       → Add real API integration

# Rust production code:
❌ seeded_pick(seed, offset, &[...])         → Use SimPrng with proper distribution
❌ seeded_range(seed, offset, lo, hi)        → Use model-based simulation
```

---

## ⚠️ Integration Completeness (ABSOLUTE — Gate G029)

**Every implemented feature MUST be fully integrated into the system. Implementation without integration is incomplete work. Code that exists but is not wired, called, exposed, or reachable by end users is effectively dead code.**

### The Integration Completeness Rule

```
┌──────────────────────────────────────────────────────────────────────┐
│  IMPLEMENTATION alone is NOT sufficient.                             │
│  Every artifact MUST be INTEGRATED into the running system:          │
│                                                                      │
│  Backend API endpoint → MUST be called by at least one frontend      │
│                         OR documented as external-only               │
│  Library / shared code → MUST be imported and used by a consumer     │
│  Frontend page/component → MUST use real backend APIs, not stubs     │
│  Service / worker → MUST be deployed, health-checked, and monitored  │
│  Database migration → MUST be consumed by backend code               │
│  Proto / contract → MUST be used by both producer AND consumer       │
│                                                                      │
│  VIOLATION: any of the above existing without integration = BLOCKED  │
└──────────────────────────────────────────────────────────────────────┘
```

### Integration Categories (ALL are BLOCKING)

| Category | What "Integrated" Means | What "NOT Integrated" Means (BLOCKING) |
|----------|------------------------|----------------------------------------|
| **Backend API** | At least one first-party frontend (web/mobile/admin) calls the endpoint with correct contracts, OR endpoint is explicitly documented as external-only with auth/rate-limit/docs | Endpoint exists in router but no frontend calls it and no external documentation exists |
| **Library / Shared Module** | At least one service or frontend imports and calls the library's public API | Library compiles but nothing imports or calls it |
| **Frontend Page / Component** | Page uses real backend API calls (`fetch`, `useQuery`, gRPC) and renders real data from the backend | Page exists but uses hardcoded data, stubs, mock responses, or has no API integration |
| **Frontend Feature** | Feature is reachable via navigation (route, menu, link) and exercises real backend flows end-to-end | Feature code exists but is not in navigation, not routed, or calls non-existent endpoints |
| **Service / Worker** | Service is started by deployment, has health checks, is monitored, and serves traffic to consumers | Service binary exists but is not in docker-compose / deployment manifests |
| **Database Migration** | Migration's tables/columns are read from and written to by backend code with tests | Migration creates schema that nothing queries |
| **Proto / Contract Definition** | Both the producing service AND the consuming client use the generated code from this proto | Proto file exists but generated code is unused on one or both sides |
| **Configuration / Feature Flag** | Config value is read by application code at startup with fail-fast on missing | Config key defined but never read by any code path |

### Detection Rules

| Check | How to Detect | Verdict |
|-------|---------------|--------|
| Backend endpoint with zero frontend callers | Search frontend code for the endpoint path; check API docs for external-only designation | 🔴 ORPHAN — wire into frontend or document as external |
| Library with zero importers | Search codebase for `import`/`use`/`require` of the library's modules | 🔴 DEAD CODE — integrate or delete |
| Frontend page with zero `fetch`/`useQuery`/API calls | Scan page component tree for network calls | 🔴 STUB UI — add real API integration |
| Frontend page calling non-existent backend endpoints | Cross-reference frontend API calls with backend router | 🔴 INVENTED ENDPOINT — implement backend first |
| Service not in deployment manifests | Check docker-compose / k8s manifests for service entry | 🔴 UNDEPLOYED — add to deployment |
| Proto with one-sided usage | Check both producer service and consumer client for generated imports | 🔴 ONE-SIDED CONTRACT — integrate both sides |
| Frontend using hardcoded/mock data instead of real backend | Scan for `MOCK_DATA`, `SAMPLE_DATA`, hardcoded arrays in components | 🔴 FAKE INTEGRATION — replace with real API calls |

### Scope-Level Integration Verification (MANDATORY in DoD)

Every scope that produces an artifact (API, UI, library, service, migration, proto) MUST include an **Integration Completeness** DoD item:

```markdown
- [ ] Integration completeness verified (Gate G029) — all new code is wired into the system:
  - Backend endpoints called by frontend(s) or documented as external-only
  - Libraries/modules imported and used by at least one consumer
  - Frontend pages use real backend APIs (no stubs/mocks/hardcoded data)
  - Frontend features reachable via navigation
  - Services deployed and health-checked
  - Database schema consumed by backend code
  - Proto contracts used by both producer and consumer
  - Raw output evidence (inline, no references/summaries):
    ```
    [PASTE VERBATIM verification output — grep for endpoint usage, import statements, route definitions, etc.]
    ```
```

### Integration Verification Commands (Project-Agnostic Examples)

```bash
# 1. Verify backend endpoints have frontend callers
# Search frontend code for each new endpoint path
grep -rn '/api/v1/new-endpoint' frontend/ dashboard/ mobile/ web/

# 2. Verify libraries are imported
# Search for imports of the new library module
grep -rn 'use new_module\|from.*new_module\|import.*new_module' services/ frontend/

# 3. Verify frontend pages call real APIs (no stubs)
# Check that page files contain fetch/useQuery/API calls
grep -rn 'fetch\|useQuery\|useMutation\|axios\|grpc' frontend/src/pages/NewPage.tsx

# 4. Verify frontend routes are navigable
# Check router config for the new route
grep -rn '/new-route' frontend/src/router/ frontend/src/App.tsx

# 5. Verify no orphan endpoints (endpoints with zero callers)
# Cross-reference backend routes with frontend API calls
# (project-specific script recommended)

# 6. Verify no hardcoded/mock data in frontend
grep -rn 'MOCK_DATA\|SAMPLE_DATA\|mockData\|hardcoded\|getSimulationData' frontend/src/

# 7. Verify service is in deployment
grep -rn 'new-service' docker-compose*.yml deployment/

# 8. Verify database schema is consumed
grep -rn 'new_table\|new_column' backend/
```

### What This Gate Catches

**Pattern observed repeatedly:** Agents implement a backend service with endpoints, write tests for the service in isolation, mark the scope "Done" — but never wire the frontend to call those endpoints. The result: working backend code that no user can reach. The feature is "implemented" but not "integrated".

**Pattern observed in UI scopes:** Agents create a frontend page, add it to the router, but the page renders hardcoded sample data instead of fetching from the real backend. The UI looks complete but shows fake data.

**Pattern observed in library scopes:** Agent creates a shared library with utilities, writes unit tests, marks Done — but no service ever imports or calls the library. The library is dead code from day one.

### Critical Failure Pattern: Handler Code Without Route Wiring

**Most common G029 violation observed:** Agent writes handler code (e.g., `pub async fn handle_ratings()`) and places it in a handler module — but NEVER registers it with `.route()` in the service's axum/actix/gin router, and NEVER updates the API gateway forwarding rules. The handler compiles, tests may even pass in isolation, but no HTTP request can ever reach it.

**Detection checklist for this pattern:**

```bash
# 1. List all handler functions defined in handler files
grep -rn 'pub async fn\|func.*Handler\|async function.*handler\|def.*_handler' backend/

# 2. List all .route() registrations in router files
grep -rn '\.route\|\.get\|\.post\|\.put\|\.delete\|\.patch' backend/**/router* backend/**/routes* backend/**/main*

# 3. Cross-reference: handler defined but not .route()-wired = ORPHAN
# Every handler function MUST appear in a .route() call

# 4. List all frontend API calls
grep -rn 'fetch\|dio\.\|http\.\|useQuery\|useMutation\|axios\.\|apiClient\.' frontend/ mobile/ dashboard/ web/

# 5. Cross-reference: frontend calls endpoint that has no backend route = BROKEN
# Every frontend API call MUST map to a .route()-wired backend handler
```

### Relationship to Other Gates

| Gate | What It Catches | G029 Adds |
|------|----------------|----------|
| G028 (Implementation Reality) | Stubs/hardcoded data in source files | **Wiring**: code exists AND is connected to the system |
| G035 (Vertical Slice) | Frontend↔backend route mismatches | **Consumer↔producer contract**: both sides of the call exist and connect |
| Gate 9 (E2E Substance) | E2E tests verify actual behavior | **Consumer existence**: the consumer that E2E tests would exercise actually exists |
| Gate 0-8 (Test/Evidence) | Tests exist and evidence is real | **Integration tests**: tests prove the integration path works end-to-end |

---

## ⚠️ Vertical Slice Completeness (ABSOLUTE — Gate G035)

**When a scope produces code across multiple layers (frontend + backend, or backend + database), the ENTIRE vertical slice MUST be complete. Implementing one layer without its dependent layers is incomplete work that creates dead code, broken UI, and false "Done" status.**

### The Vertical Slice Rule

```
┌──────────────────────────────────────────────────────────────────────┐
│  A VERTICAL SLICE is a complete path through ALL system layers.     │
│                                                                      │
│  Frontend (UI) ─── calls ──→ API Gateway ─── forwards ──→ Service  │
│       ↑                                                      │      │
│       │                                    .route()-wired handler    │
│       │                                                      │      │
│       │                                                      ↓      │
│       └──────── renders ←── response ←── Data Store query/mutation  │
│                                                                      │
│  ALL layers in the path MUST be implemented and connected.          │
│  A break at ANY point = BLOCKING violation.                         │
│                                                                      │
│  Common breaks this gate detects:                                   │
│  ❌ Frontend calls endpoint → handler exists → NOT .route()-wired   │
│  ❌ Frontend calls endpoint → no handler code exists at all         │
│  ❌ Frontend calls endpoint → gateway has no forwarding rule        │
│  ❌ Handler is .route()-wired → but returns hardcoded data (G028)   │
│  ❌ Handler queries DB → but migration not applied (G029)           │
│  ❌ Backend endpoint exists → no frontend calls it (G029 orphan)    │
└──────────────────────────────────────────────────────────────────────┘
```

### Applicability (CONDITIONAL — Not All Scopes Need This)

| Scope Type | G035 Applies? | Why |
|------------|--------------|-----|
| **Frontend + Backend** | ✅ YES | Both layers must connect end-to-end |
| **Frontend + New API** | ✅ YES | Frontend API calls must reach working backend handlers |
| **Backend + Database** | ✅ YES | Handlers must use real data store, not stubs |
| **Pure Frontend** (using existing API) | ❌ NO | No new backend needed; existing API already works |
| **Pure Backend** (no UI change) | ❌ NO | Backend endpoints will be consumed later; G029 external-only docs suffice |
| **Infrastructure / Config** | ❌ NO | No cross-layer integration needed |
| **Documentation only** | ❌ NO | No code layers involved |

**Key distinction from G029:** G029 checks "does every artifact have a consumer?" (orphan detection). G035 checks "when both layers exist, do they actually connect?" (wiring verification). A scope can pass G029 (backend endpoint is documented as external-only) but fail G035 (the frontend that was supposed to call it doesn't work).

### Detection Rules (MANDATORY Cross-Layer Checks)

#### Check 1: Frontend→Backend Route Existence

**For every API call in frontend code, verify a matching route exists in the backend router.**

```bash
# Extract frontend API endpoint paths
grep -rn 'fetch.*api/v1\|dio\..*api/v1\|http\..*api/v1\|useQuery.*api/v1\|apiClient.*api/v1' frontend/ mobile/ dashboard/

# For each path found, verify it exists in backend router
grep -rn '\.route.*ENDPOINT_PATH\|\.get.*ENDPOINT_PATH\|\.post.*ENDPOINT_PATH' backend/**/routes* backend/**/router* backend/**/main*

# RESULT: If frontend calls an endpoint that has NO backend route → ❌ BLOCKING
```

#### Check 2: Handler→Router Wiring

**For every handler function defined, verify it is registered in the service router.**

```bash
# Find handler functions
grep -rn 'pub async fn handle_\|pub async fn get_\|pub async fn create_\|pub async fn update_\|pub async fn delete_\|pub async fn list_' backend/**/handlers/

# For each handler, verify .route() registration
grep -rn 'handler_function_name' backend/**/routes* backend/**/router* backend/**/main*

# RESULT: Handler exists but NOT in any .route() call → ❌ BLOCKING (dead handler)
```

#### Check 3: Gateway Forwarding

**For every backend service endpoint, verify the API gateway forwards requests to it.**

```bash
# List service routes
grep -rn '\.route\|\.nest' backend/**/routes* backend/**/main* | grep -v test

# For services behind a gateway, verify gateway has forwarding config
grep -rn 'forward\|proxy\|upstream\|service_url\|ENDPOINT_PREFIX' gateway/ proxy/ 

# RESULT: Service has routes but gateway doesn't forward → ❌ BLOCKING (unreachable)
```

#### Check 4: E2E Test Covers Full Stack

**For every vertical slice (frontend → backend), verify an E2E test exercises the complete path.**

```bash
# E2E test files should hit the actual API endpoints
grep -rn 'api/v1/ENDPOINT\|fetch.*ENDPOINT\|request.*ENDPOINT' tests/e2e/ e2e/

# RESULT: No E2E test exercises the full slice → ❌ MISSING E2E VERTICAL TEST
```

### Scope-Level DoD Item (MANDATORY for Cross-Layer Scopes)

Every scope that modifies BOTH frontend and backend code MUST include:

```markdown
- [ ] Vertical slice completeness verified (Gate G035) — every frontend API call maps to a .route()-wired backend handler, gateway forwards all service routes, E2E tests exercise full stack:
  - Frontend API calls identified and mapped to backend routes:
    ```
    [PASTE grep output showing frontend endpoint calls → matching backend route registrations]
    ```
  - No orphaned handlers (all handler functions registered in router):
    ```
    [PASTE cross-reference output]
    ```
  - Gateway forwarding verified (if applicable):
    ```
    [PASTE gateway config verification]
    ```
```

### What This Gate Catches (Observed Failure Patterns)

**Pattern 1 — "Handler without .route()":** Agent writes `pub async fn handle_sos_trigger()` in a handler file, creates tests for the handler in isolation. But never adds `.route("/sos/trigger", post(handle_sos_trigger))` to the router. Frontend calls the endpoint and gets 404.

**Pattern 2 — "Frontend calls non-existent endpoint":** Agent creates a Flutter `SosRepository` that calls `POST /api/v1/sos/trigger`, `GET /api/v1/sos/active`, etc. The backend service has `GET /api/v1/sos/contacts` wired but NOT the other SOS endpoints. Result: 4 out of 5 SOS features silently fail.

**Pattern 3 — "Gateway doesn't forward":** Backend service has routes wired and working on port 8003. But the API gateway on port 8080 has no forwarding rule for `/api/v1/sos/*`. Frontend calls the gateway, gateway returns 404, even though the service behind it works fine.

**Pattern 4 — "Backend-only implementation":** Agent implements a complete ratings system with handlers, database migrations, unit tests — marks scope "Done." But the frontend `RatingsScreen` still has hardcoded sample data because the agent never updated the frontend to use the real backend.

**Pattern 5 — "Partial feature implementation":** Feature has 6 endpoints. Agent implements 1 endpoint (the simplest one), marks the scope "Done." Frontend calls all 6, only 1 works. The scope should have been broken into sub-items or the DoD should have listed all 6 individually.

### When to Exempt (Not a Violation)

- **Deliberate phased rollout:** If `design.md` explicitly plans "Phase 1: backend only, Phase 2: frontend integration" AND Phase 1 scope DoD says "backend endpoints implemented but not yet consumed by frontend" — this is acceptable AS LONG AS the frontend integration is tracked as a separate scope.
- **External-only APIs:** If an endpoint is documented as external-only (for third-party consumers, not first-party frontends) — G029 external-only docs suffice.
- **Prototyping / spike scopes:** If a scope is explicitly labeled as a spike/prototype in design.md, G035 applies only to the layers the spike covers.

---

## ⚠️ Design Readiness Before Implementation (ABSOLUTE — Gate G033)

**Implementation MUST NOT start until design artifacts (design.md and scopes.md) exist with substantive content. Starting implementation with only spec.md is a governance violation.**

### What G033 Checks

| Artifact | Requirement | Minimum Evidence |
|----------|-------------|-----------------|
| `design.md` | Exists with substantive technical design | >20 lines, contains architecture/data model/API design/component design |
| `scopes.md` | Exists with Gherkin scenarios and DoD | Has `Given/When/Then` patterns AND `- [ ]` DoD checkboxes |
| `spec.md` | Exists (already enforced by G001) | Non-empty file |

### Enforcement Model

G033 is enforced at TWO levels:

1. **Phase-level:** The `implement` phase in workflows.yaml requires G033 in its `requiredGates`. The workflow orchestrator MUST verify design readiness before dispatching `bubbles.implement`.

2. **Mode-level:** All delivery modes that include an `implement` phase now also include a `bootstrap` phase that creates missing design/scope artifacts BEFORE implementation. The `requireDesignBeforeImplement: true` constraint makes this explicit.

### Auto-Escalation on G033 Failure

When G033 fails (design.md/scopes.md missing or stubs), the workflow orchestrator MUST:

1. Invoke `bubbles.design` via `runSubagent` → create/complete design.md
2. Invoke `bubbles.clarify` via `runSubagent` → resolve ambiguities
3. Invoke `bubbles.plan` via `runSubagent` → create/complete scopes.md with Gherkin, Test Plan, and DoD
4. Re-verify G033. If still failing after 3 bootstrap iterations → mark spec `blocked`.

### Exemptions

- **`bugfix-fastlane` mode:** Bug fixes may proceed with existing (possibly minimal) design artifacts, since `bug.md` and `spec.md` serve as the design context.
- **Modes with `analyze` phase** (e.g., `product-to-delivery`): G033 is checked AFTER the analyze + bootstrap phases, not before.

### Why This Gate Exists

Without G033, workflows like `full-delivery` (the default mode) would jump from `select` directly to `implement` without ensuring design.md or scopes.md exist. This leads to:
- Implementation without architectural guidance
- Missing Gherkin scenarios and Test Plans
- No DoD to validate against
- Implementations that cannot pass downstream quality gates (validate, audit)

G033 ensures the **design → plan → implement** sequence is mechanically enforced, not just suggested.

---

## ⚠️ Findings Artifact Update Protocol (ABSOLUTE — Gate G031)

**When ANY agent discovers issues, gaps, or failures during analysis, it MUST update scope artifacts BEFORE reporting its verdict. Reporting findings without updating artifacts is a governance violation equivalent to fabrication.**

### The Rule

**Every finding that requires code changes, test additions, or behavioral fixes MUST be recorded as a trackable artifact update — not just listed in a report. Findings that exist only in a verdict/report but are NOT reflected in scopes.md/state.json are LOST FINDINGS and will be ignored by downstream agents.**

### What "Update Scope Artifacts" Means (ALL are MANDATORY)

For EACH finding/issue discovered:

| Artifact | Required Update |
|----------|-----------------|
| **scopes.md** (or `scopes/NN-name/scope.md`) | Add new Gherkin scenario describing the discovered issue as a testable behavior requirement |
| **Test Plan table** | Add new row for the Gherkin scenario with correct test type, file path, command, and live-system flag |
| **Definition of Done** | Add new unchecked `- [ ]` checkbox item with evidence template for the test/fix |
| **Scope status** | If scope was "Done" but now has unchecked DoD items → reset to **"In Progress"** |
| **state.json** | If scope status changed: update `status` to `"in_progress"`, remove scope from `completedScopes`, remove stale phase names from `completedPhases` |

### When This Gate Applies

| Agent | Trigger |
|-------|---------|
| **bubbles.harden** | Any finding classified as ⚠️ PARTIAL or ❌ FAILED during task/code verification |
| **bubbles.gaps** | Any finding classified as 🟡 PARTIAL, 🔴 MISSING, 🟣 DIVERGENT, 🔵 UNDOCUMENTED, 🟠 PATH_MISMATCH, or ⬛ UNTESTED |
| **bubbles.validate** | Any validation failure that requires code/test changes |
| **bubbles.audit** | Any compliance finding that requires remediation |
| **bubbles.chaos** | Any chaos probe failure that requires a fix |
| **bubbles.test** | Any test gap or missing coverage requiring new test additions |

### Pre-Verdict Blocking Gate (MANDATORY)

**Before reporting ANY verdict (HARDENED, GAP_FREE, PASSED, etc.), the agent MUST verify:**

```
□ 1. FINDINGS COUNT: How many findings/issues were discovered this session?
     → If > 0: proceed to checks 2-5
     → If 0: proceed to verdict (all clear)

□ 2. ARTIFACT UPDATES EXIST: For EACH finding, does a new Gherkin scenario exist in scopes.md?
     → If ANY finding has no corresponding Gherkin scenario: STOP — add the scenario NOW

□ 3. TEST PLAN SYNC: For EACH new Gherkin scenario, does a Test Plan row exist?
     → If ANY scenario lacks a Test Plan row: STOP — add the row NOW

□ 4. DOD SYNC: For EACH new Test Plan row, does a DoD checkbox item exist?
     → If ANY row lacks a DoD item: STOP — add the item NOW

□ 5. STATE COHERENCE: If new unchecked DoD items were added to a scope previously marked "Done":
     → Did scope status reset to "In Progress"? If NO: reset it NOW
     → Did state.json update to reflect the change? If NO: update it NOW
```

**If ANY check fails → the agent MUST NOT report its verdict. Fix the artifact gap FIRST, then report.**

### What This Gate Catches

**Pattern observed repeatedly:** Harden/gaps agents analyze code, discover 5 issues, write a beautiful report with findings — but never update scopes.md with new DoD items. The orchestrator receives the verdict, routes to implement, but implement has no updated scope artifacts to work from. The findings are effectively lost.

**Pattern observed in batch modes:** Harden finds issues in Spec A, reports NOT_HARDENED, but scopes.md still shows all DoD items as `[x]` and scope status as "Done". The implement agent checks scopes.md, sees everything is Done, and does nothing.

### Enforcement

- **Pre-verdict check**: Agent MUST count findings and verify matching artifact updates before generating verdict output
- **Orchestrator verification**: `bubbles.workflow` MUST verify scope artifacts were updated after harden/gaps phases (see Findings Handling Protocol)
- **Audit detection**: `bubbles.audit` MUST flag findings-without-artifact-updates as a governance violation

### PROHIBITED

```
⛔ Reporting findings in verdict/report only without updating scopes.md → GOVERNANCE VIOLATION
⛔ Leaving scope status as "Done" when new unchecked DoD items were added → STALE STATUS
⛔ Not updating state.json after scope status changes → STATE DRIFT  
⛔ Adding findings to report.md but not to scopes.md DoD → LOST FINDINGS
⛔ Listing issues in the hardening/gap report without Gherkin scenarios → UNTRACKABLE FINDINGS
```

---

## ⚠️ Cross-Artifact Coherence Rule (ABSOLUTE — Applies to ALL Agents)

**When ANY agent modifies ANY spec artifact (spec.md, design.md, scopes.md), ALL related artifacts MUST be updated to maintain coherence. Partial artifact updates create drift — one artifact says one thing, another says something different. Downstream agents (implement, test, validate) cannot work correctly with drifted artifacts.**

### The Rule

**Spec artifacts form a coherent chain: `spec.md` → `design.md` → `scopes.md`. Changes to any link MUST propagate to downstream links.**

| If This Changed | Then These MUST Be Updated | By Whom |
|-----------------|---------------------------|---------|
| `spec.md` (new actors, use cases, requirements, improvement proposals) | `design.md` (architecture/API contracts for new requirements) + `scopes.md` (new Gherkin scenarios + DoD) | `bubbles.design` → `bubbles.plan` |
| `design.md` (new API contracts, architecture changes, new components) | `scopes.md` (implementation plan + DoD items reflecting design) | `bubbles.plan` |
| `scopes.md` (new findings/scenarios/DoD items added by trigger agents) | `design.md` (ensure design covers the implementation approach for new items) | `bubbles.design` |

### When This Rule Is Enforced

1. **Fix cycle bootstrap phase** — After ANY trigger agent modifies spec artifacts, the bootstrap phase ALWAYS invokes design + plan agents to ensure coherence. This is unconditional in fix cycles. See the Fix Cycle Bootstrap Phase Protocol in the workflow agent.

2. **Sequential phaseOrder bootstrap phase** — Before the implement phase, the orchestrator verifies G033 and invokes design + plan if artifacts are missing or insufficient.

3. **Findings Artifact Update (G031)** — When trigger/analysis agents discover issues, they must update scopes.md. The bootstrap ensures the matching design.md updates happen too.

### Violations (ALL are BLOCKING)

```
⛔ Analyst enriches spec.md with new use cases but design.md still reflects pre-analysis state → ARTIFACT DRIFT
⛔ Harden adds new DoD items to scopes.md but design.md doesn't describe how to implement them → ARTIFACT DRIFT
⛔ Gaps agent finds missing implementations in scopes.md but design.md lacks the API contracts → ARTIFACT DRIFT
⛔ Bootstrap skips design/plan invocation because design.md "already exists" even though spec.md just changed → SKIPPED COHERENCE
⛔ Any agent modifies spec.md without the workflow ensuring design.md and scopes.md are updated → ORPHANED CHANGES
```

### Detection (Orchestrator Responsibility)

The workflow orchestrator (`bubbles.workflow`) MUST verify cross-artifact coherence after every bootstrap phase:
- If `spec.md` was modified in the current round, confirm `design.md` was updated in the same round
- If `scopes.md` had new DoD items added, confirm `design.md` covers the implementation approach
- If `design.md` was updated, confirm `scopes.md` reflects the design changes in Gherkin scenarios

---

## ⚠️ Quality Work Standards (NON-NEGOTIABLE)

**ALL work produced by Bubbles agents MUST be genuine, high-quality, and production-ready.**

### What Constitutes Real Work

| Real Work | Fake Work (PROHIBITED) |
|-----------|------------------------|
| Actual implementation code that compiles and runs | Stub functions with TODO comments |
| Tests that execute against real code and verify behavior | Tests that always pass regardless of implementation |
| Documentation that accurately describes the implemented system | Copy-pasted templates with placeholders unfilled |
| Evidence from actual command execution with real output | Made-up output that looks like it could be real |
| Each DoD item validated individually with its own execution | All DoD items batch-checked in one edit |

### Quality Thresholds

| Dimension | Minimum Standard |
|-----------|-----------------|
| **Test specificity** | Each test must fail if the feature it tests is broken |
| **Test independence** | Each test must pass/fail independently of other tests |
| **Evidence authenticity** | Every evidence block must contain real terminal output from actual execution |
| **DoD granularity** | Each DoD item must be marked `[x]` separately after its own validation |
| **Implementation completeness** | No `TODO`, `FIXME`, `unimplemented!()`, `NotImplementedError` anywhere |
| **Documentation accuracy** | Every doc statement must match the actual implementation |

### Self-Check Before Claiming Completion

Every agent MUST answer these questions HONESTLY before claiming any work is complete:

1. **"Did I ACTUALLY run this command, or am I writing what I think the output would be?"** → If writing expected output: STOP, run the command, use real output
2. **"Could this test pass even if the feature is completely broken?"** → If yes: the test is worthless, rewrite it
3. **"If a human reviewed my evidence, would they find real terminal output or narrative summaries?"** → If summaries: replace with real execution output
4. **"Did I check each DoD item one at a time, or did I batch-check them all at once?"** → If batched: uncheck all, re-validate one at a time
5. **"Did I actually invoke the specialist agents, or did I skip them and claim they ran?"** → If skipped: invoke them now
6. **"Is every line of implementation code tested and reachable?"** → If untested code exists: write tests now

---

## ⚠️ Fabrication Termination Protocol (ABSOLUTE — ZERO TOLERANCE)

**When fabrication is detected — whether by self-check, audit agent, artifact lint, or orchestrator verification — the following protocol is MANDATORY:**

### ⚠️ MANDATORY STATE TRANSITION GUARD SCRIPT (MECHANICAL ENFORCEMENT)

**Before ANY agent writes `"status": "done"` to state.json, it MUST execute the state transition guard script:**

```bash
bash .github/bubbles/scripts/state-transition-guard.sh {FEATURE_DIR}
```

**This is a BLOCKING gate. If the script exits with code 1, the agent MUST NOT set status to "done".**

**Auto-revert mode** (recommended for orchestrators):
```bash
bash .github/bubbles/scripts/state-transition-guard.sh {FEATURE_DIR} --revert-on-fail
```

When `--revert-on-fail` is specified and checks fail, the script automatically:
- Reverts state.json status to `in_progress`
- Clears `completedScopes` and `completedPhases`
- Adds a failure record with timestamp

**The guard script verifies ALL of the following mechanically:**
1. All required artifacts exist (spec.md, design.md, scopes.md, report.md, uservalidation.md, state.json)
2. Status ceiling enforcement (workflow mode allows "done")
3. ALL DoD items in scopes.md are checked `[x]` (zero unchecked)
4. ALL scope statuses in scopes.md are "Done" (zero "Not Started" or "In Progress")
5. ALL required specialist phases are in completedPhases
6. Timestamp plausibility (no uniform spacing, no impossible compression)
7. Test file existence (Test Plan files exist on disk)
8. DoD evidence presence (every [x] item has evidence block)
9. Template placeholder detection (no unfilled `[ACTUAL terminal output]`)
10. Report.md required sections exist
11. Report.md evidence legitimacy (terminal output signals present)
12. Duplicate evidence detection
13. Artifact lint passes
14. No TODO/FIXME/STUB markers in implementation files
15. **Phase-Scope Coherence (Gate G027)** — completedPhases claiming implementation phases MUST have matching non-empty completedScopes and Done scope artifacts
16. **Implementation Reality Scan (Gate G028)** — source files referenced in scope artifacts scanned for stub/fake/hardcoded data patterns via `implementation-reality-scan.sh`
17. **Integration Completeness (Gate G029)** — every implemented artifact (endpoint, library, page, service, migration, proto) is wired into the running system with at least one real consumer
18. **Findings Artifact Update (Gate G031)** — if harden/gaps phases ran and found issues, scope artifacts (scopes.md Gherkin scenarios, Test Plan rows, DoD items, scope status, state.json) MUST have been updated to reflect findings. Findings that exist only in reports but not in scope artifacts are lost findings.

**PROHIBITED:**
- ❌ Writing `"status": "done"` to state.json without first running the guard script
- ❌ Ignoring guard script exit code 1
- ❌ Deleting or modifying the guard script to make it pass
- ❌ Bypassing the guard by writing state.json before the script runs

**Agent Self-Enforcement Rule:**
Every agent that can modify state.json MUST include this sequence in its finalization:
```
1. Run: bash .github/bubbles/scripts/state-transition-guard.sh {FEATURE_DIR}
2. IF exit code 0 → proceed to write "status": "done"
3. IF exit code 1 → status remains "in_progress", report blocking failures
```

### Immediate Actions

1. **HALT** — Stop all forward progress immediately
2. **REVERT** — All DoD items marked `[x]` without real evidence revert to `[ ]`
3. **DOWNGRADE** — Spec/scope status reverts to `in_progress` (never stays at `done`)
4. **INVALIDATE** — All evidence sections presumed fabricated are marked `⚠️ INVALIDATED — re-execution required`
5. **RE-EXECUTE** — Every invalidated item must be re-executed with real terminal commands and real output captured

### Fabrication Categories and Severity

| Category | Severity | Example | Recovery |
|----------|----------|---------|----------|
| **Evidence fabrication** | CRITICAL | Writing "Exit Code: 0" without running command | Re-run ALL commands, re-capture ALL evidence |
| **Test fabrication** | CRITICAL | Tests that always pass (noop assertions) | Delete tests, rewrite with substance |
| **Batch completion** | HIGH | All DoD items checked in one edit | Uncheck all, re-validate one at a time |
| **Specialist skipping** | CRITICAL | Claiming audit/chaos/validate ran without invoking | Re-invoke ALL skipped specialists |
| **Phase-scope incoherence** | CRITICAL | completedPhases claims 6 phases but completedScopes is empty | Revert completedPhases; complete actual scope work |
| **Gateway stubs** | CRITICAL | Handler returns `vec![Struct { field: "hardcoded" }]` instead of real service call | Replace with real DB queries / service calls |
| **Frontend hardcoded data** | CRITICAL | Hook calls `getSimulationData()` or has zero `fetch()` calls | Replace with real API integration |
| **Orphan implementation** | CRITICAL | Backend endpoint exists but no frontend calls it; library published but nothing imports it | Wire into system or delete |
| **Stub UI integration** | CRITICAL | Frontend page exists but uses hardcoded data instead of real backend API calls | Replace with real API integration |
| **Lost findings** | CRITICAL | Agent found 5 issues but scopes.md still shows all DoD `[x]` and scope "Done" — findings exist only in report, not in scope artifacts | Update scopes.md with new Gherkin/TestPlan/DoD per finding, reset scope status (Gate G031) |
| **Narrative evidence** | HIGH | "All tests pass" without terminal output | Replace with real terminal output containing legitimate signals |
| **Template evidence** | HIGH | "[ACTUAL terminal output]" unfilled | Execute and fill with real output |

### Prevention Rules (MANDATORY for ALL agents)

1. **Execute → Record** — NEVER Record → Execute. The sequence is: run command first, then copy output.
2. **One at a time** — Mark DoD items `[x]` ONE AT A TIME. Never batch.
3. **Real commands only** — Every `Executed: YES` must have a corresponding `Command:` that was actually run.
4. **No expected output** — NEVER type what you think the output should be. Copy what it actually was.
5. **Specialist invocation is mandatory** — Every phase in the workflow MUST be executed by its specialist agent. Skipping phases is fabrication.
6. **Artifact lint is mandatory** — Run `artifact-lint.sh` before claiming completion. If it fails, you are NOT done.
7. **Phase-scope coherence is mandatory** — Do NOT write implementation phase names to `completedPhases` until the corresponding scopes are actually Done with evidence (Gate G027).
8. **Implementation reality scan is mandatory** — Run `implementation-reality-scan.sh` before claiming any implementation is complete. Stubs, hardcoded data, and simulation calls in production code are blocking (Gate G028).
9. **Integration completeness is mandatory** — Every implemented artifact (endpoint, library, page, service, migration, proto) MUST have at least one real consumer. Orphan endpoints, dead libraries, stub UIs, and undeployed services are blocking (Gate G029).
10. **Findings artifact update is mandatory** — When discovering issues (harden/gaps/validate/audit/chaos/test), update scope artifacts (scopes.md Gherkin, Test Plan, DoD) BEFORE reporting verdict. Findings that exist only in reports are lost findings (Gate G031).

---

## ⚠️ Mandatory Completion Checkpoint (BLOCKING — Every Agent)

**Before ANY agent reports "work complete" or "scope done" or "iteration finished", it MUST execute this checkpoint.**

### The Eleven Final Questions (ALL must be YES)

```
□ 1. EVIDENCE: Did I execute EVERY command whose output I recorded?
     → If NO: go execute the missing commands NOW

□ 2. GATES: Did I apply Fabrication Detection Heuristics (G021) to my own evidence?
     → If NO: apply them NOW — check for shallow evidence, template text, batch completion

□ 3. SPECIALISTS: Did I invoke (or was I acting as) EVERY specialist agent required by this mode?
     → If NO: invoke the missing specialists NOW

□ 4. LINT: Did I run artifact lint and did it pass?
     → If NO: run `artifact-lint.sh` NOW and fix failures

□ 5. SEQUENTIAL: Is the previous spec/scope fully complete (if applicable)?
     → If NO: go complete it FIRST before finishing this one

□ 6. GUARD SCRIPT: Did I run the state transition guard script and did it pass?
     → If NO: run `bash .github/bubbles/scripts/state-transition-guard.sh {FEATURE_DIR}` NOW
     → If it exits with code 1: I am NOT done. Fix all failures FIRST.
     → NEVER write "status": "done" without guard script exit code 0.

□ 7. COMPLETION CHAIN: Are ALL scopes "Done" AND ALL DoD items [x] WITH inline raw evidence?
     → If ANY scope is not Done: spec CANNOT be done — go finish the scope
     → If ANY DoD item is unchecked: scope CANNOT be Done — go validate the item
     → If ANY DoD item lacks raw evidence: item is NOT validly checked — go execute and record

□ 8. TEST REALITY: Do ALL test-related DoD items have REAL tests that cover ALL scenarios?
     → If tests only cover happy path: NOT DONE — add error/boundary/negative tests
     → If tests mock internal code: NOT DONE — replace with real implementations
     → If tests use fake data stores: NOT DONE — use real ephemeral test DBs
     → If any Gherkin scenario lacks a corresponding test: NOT DONE — write the test
     → If test coverage < 100% for business logic: NOT DONE — add missing coverage

□ 9. PHASE-SCOPE COHERENCE (G027): Do completedPhases entries match completedScopes reality?
     → If completedPhases has "implement"/"test" but completedScopes is empty: FABRICATION — remove phases, complete scopes first
     → If completedPhases has ≥5 phases but scopes are only partially Done: INCOHERENCE — complete all scopes first
     → If completedScopes count doesn't match Done scope count in artifacts: FIX state.json

□ 10. IMPLEMENTATION REALITY (G028): Does source code contain real implementations, not stubs?
     → Run: bash .github/bubbles/scripts/implementation-reality-scan.sh {FEATURE_DIR} --verbose
     → If violations found: BLOCKED — replace stubs/hardcoded data with real implementations
     → If gateway handlers return vec![...] with literals: replace with real DB/service queries
     → If frontend hooks have zero fetch() calls: add real API integration
     → If getSimulationData() appears in production code: replace with real data fetching

□ 11. INTEGRATION COMPLETENESS (G029): Is every new artifact wired into the running system?
     → If a backend API endpoint has zero frontend callers AND is not documented as external-only: NOT DONE — wire frontend or document as external
     → If a library/module has zero importers: NOT DONE — integrate or delete
     → If a frontend page uses hardcoded/mock data instead of real backend APIs: NOT DONE — add real API calls
     → If a frontend feature is not reachable via navigation (no route, no menu link): NOT DONE — add navigation
     → If a service is not in deployment manifests (docker-compose, k8s): NOT DONE — add to deployment
     → If a proto/contract is used on only one side (producer OR consumer, not both): NOT DONE — integrate both sides
     → If a database migration creates schema that nothing queries: NOT DONE — add backend queries

□ 12. FINDINGS ARTIFACT UPDATES (G031): Were ALL discovered issues recorded in scope artifacts?
     → If this agent found issues/gaps/failures: count them
     → For EACH finding: does a Gherkin scenario exist in scopes.md? If NO → add it NOW
     → For EACH new Gherkin scenario: does a Test Plan row exist? If NO → add it NOW
     → For EACH new Test Plan row: does a DoD checkbox item exist? If NO → add it NOW
     → If new DoD items were added to a scope marked "Done": was status reset to "In Progress"? If NO → reset NOW
     → If scope status changed: was state.json updated? If NO → update NOW
     → If ALL findings have artifact updates: PASS
     → If ANY finding is only in the report but NOT in scopes.md: NOT DONE — update artifacts NOW

□ 13. DESIGN READINESS (G033): Were design.md and scopes.md created BEFORE implementation started?
     → If the mode includes an implement phase: verify design.md exists with >20 lines of content
     → If design.md is missing/stub: NOT DONE — invoke bubbles.design to create it
     → If scopes.md lacks Gherkin scenarios or DoD items: NOT DONE — invoke bubbles.plan to create them
     → Exempt: bugfix-fastlane mode (bug.md + spec.md suffice for bug fixes)
```

**If ANY answer is NO → the work is NOT complete. Fix it before reporting.**

**This checkpoint is NOT optional. It is a BLOCKING gate that must execute before any completion claim.**
