# <img src="../../icons/bubbles-glasses.svg" width="28"> Bubbles Agent Manual

> *"Alright boys, here's what we're gonna do."*

This manual covers every agent in the Bubbles system — what it does, when to use it, and how it fits into the overall workflow.

---

## How It Works

Bubbles is a **spec-driven orchestration system**. Work flows through phases:

```
┌─────────┐   ┌────────┐   ┌──────┐   ┌───────────┐   ┌──────┐   ┌──────────┐   ┌───────┐   ┌──────┐
│ Analyst │ → │ Design │ → │ Plan │ → │ Implement │ → │ Test │ → │ Validate │ → │ Audit │ → │ Docs │
└─────────┘   └────────┘   └──────┘   └───────────┘   └──────┘   └──────────┘   └───────┘   └──────┘
```

Each phase is owned by a **specialist agent**. The **workflow orchestrator** decides which phases run, in what order, based on the selected **workflow mode**.

### Key Concepts

| Concept | What It Is |
|---------|-----------|
| **Spec** | A feature or bug folder under `specs/` with required artifacts |
| **Scope** | A unit of work within a spec — has its own DoD, tests, evidence |
| **DoD** | Definition of Done — checkbox items that must all be `[x]` with evidence |
| **Gate** | An automatic quality check (38 total) that must pass before completion |
| **Mode** | A workflow configuration defining which phases run and in what order |
| **Execution Tag** | An optional modifier like `socratic`, `gitIsolation`, `autoCommit`, or `maxScopeMinutes` |
| **Evidence** | Raw terminal output (≥10 lines) proving something actually happened |

---

## <img src="../../icons/bubbles-glasses.svg" width="28"> Orchestrators

### bubbles.workflow — *"Something's fucky."* (when gates fail)

The brain of the operation. Orchestrates end-to-end delivery by driving phases in the order defined by the selected workflow mode.

**Use when:**
- Starting a new feature from scratch
- Running a complete delivery pipeline
- Resuming interrupted work

**Example:**
```
/bubbles.workflow  full-delivery for feature 042-catalog-assistant
/bubbles.workflow  bugfix-fastlane for BUG-015
/bubbles.workflow  resume
```

**What it does:**
1. Loads the workflow mode definition from `workflows.yaml`
2. Determines which phases to execute and in what order
3. Delegates each phase to the specialist agent
4. Enforces gate checks between phases
5. Handles retries and error recovery
6. Tracks progress in `state.json`

**Execution tags it understands:**
- `socratic: true` for bounded questioning before discovery/bootstrap
- `gitIsolation: true` and `autoCommit: true` for opt-in git discipline
- `maxScopeMinutes` and `maxDodMinutes` for tighter scope sizing
- `microFixes: true` for narrow error-scoped fix loops

---

### bubbles.iterate — *"Boys, we need a plan. A good plan."*

Executes scopes one at a time within a spec. Picks the next available scope (respecting DAG dependencies), implements it, tests it, validates it, and moves on.

**Use when:**
- Continuing scope-by-scope implementation
- Picking up where a previous session left off

**Example:**
```
/bubbles.iterate  continue work on 042-catalog-assistant
/bubbles.iterate  implement next scope
```

---

## <img src="../../icons/julian-glass.svg" width="28"> Specialists

### bubbles.implement — *"I got work to do."*

Delivers. Every. Time. Takes a planned scope and implements it to DoD completion with real tests, real evidence, and real documentation updates.

**Use when:**
- A scope is planned and ready for implementation
- You need precise, DoD-driven delivery

**What it does:**
1. Reads spec/design/scopes artifacts
2. Implements code changes per the scope's implementation plan
3. Writes tests that validate specifications (not implementation)
4. Marks DoD checkboxes individually with inline evidence
5. Updates documentation

**Rules:**
- One scope at a time
- DoD items checked immediately with evidence — never batched
- Tests validate specs, not current implementation
- Round-trip verification for all state changes
- New or changed behavior must show red→green proof
- Narrow failures stay in micro-fix loops before broader reruns

---

### bubbles.test — *"Dad, that's not how that works."*

Runs tests, finds gaps, fixes implementations until everything passes. Trusts nothing. Verifies everything independently.

**Use when:**
- Tests need to be run and verified
- Coverage gaps need to be identified
- Test failures need to be triaged and fixed

**Example:**
```
/bubbles.test  run all tests for feature 019
/bubbles.test  fix failing integration tests
```

**Rules:**
- Tests validate specs/use cases, not implementation details
- No skips, no xfails, no disabled tests
- Evidence from actual terminal execution only
- Detects and rewrites "proxy tests" (status-code-only, assertion-free)
- Requires red→green traceability for changed behavior

---

### bubbles.docs — *"Know what I'm sayin'?"*

Makes sure everything is documented. Updates API docs, architecture docs, development guides — whatever changed.

**Use when:**
- Implementation is complete, docs need updating
- API changes need documentation
- Architecture decisions need recording

---

### bubbles.validate — *"Mr. Lahey, the tests aren't passing!"*

Runs the full validation suite. Checks every gate, verifies every DoD item, ensures evidence is real.

**Use when:**
- Pre-merge check
- Something seems off and needs systematic verification
- After `bubbles.implement` or `bubbles.test` complete

---

### bubbles.audit — *"The shit winds are coming."* (pre-audit)

The final line of defense. Policy enforcer. Obsessive, thorough, slightly unhinged about compliance. Verifies that ALL evidence is real, ALL gates pass, ALL policies are followed.

**Use when:**
- Final check before merge
- After all implementation and testing
- When you suspect fabricated evidence

**Anti-fabrication checks:**
- Evidence blocks must have ≥10 lines of raw output
- No template placeholders left unfilled
- No batch-completed DoD items
- No narrative summaries instead of terminal output
- Cross-references DoD items with report.md evidence

---

### bubbles.chaos — *"It's not rocket appliances."*

Breaks things in ways nobody could predict. Runs chaos testing scenarios — resource exhaustion, concurrent access, malformed inputs, dependency failures.

**Use when:**
- Testing system resilience
- After major changes that affect reliability
- When you need to find edge cases

---

## <img src="../../icons/barb-keys.svg" width="28"> Planning & Design

### bubbles.analyst — *"Way she goes, boys."*

Business analysis. Discovers requirements, competitive landscape, actor/use-case modeling. Figures out the *why*.

**Use when:**
- Starting a brand new feature
- Need to understand business requirements before design
- Competitive analysis needed

**Optional mode:**
- `socratic: true` turns the analyst into a bounded interviewer that asks only the questions that materially change product direction

**Example:**
```
/bubbles.analyst  Build a real-time portfolio dashboard with P&L tracking
```

---

### bubbles.ux — *"Ricky, you can't just— fine."*

UX design. Creates wireframes, user flows, interaction patterns. Cares about how things feel.

**Use when:**
- UI/UX work is needed
- User flows need to be designed
- Interaction patterns need defining

---

### bubbles.design — *"I can help with that."*

Technical architecture. Data models, API contracts, service boundaries, system design.

**Use when:**
- Creating `design.md` for a feature
- System architecture decisions
- Database schema design

**Example:**
```
/bubbles.design  Create technical design for auth system
```

---

### bubbles.plan — *"Jim, you need a plan."*

Scope planning. Takes a spec and design, breaks it into implementable scopes with Gherkin scenarios, test plans, and DoD checklists.

**Use when:**
- Breaking a feature into scopes
- Creating or repairing scope definitions
- After design is complete, before implementation

**Example:**
```
/bubbles.plan  Create scopes for feature 042
```

**Planning rules:**
- scopes are small, isolated, and single-outcome by default
- optional `maxScopeMinutes` and `maxDodMinutes` further tighten the split
- if a scope mixes unrelated journeys, it gets split before implementation

---

### bubbles.clarify — *"What in the f— is going on here?"*

Asks the obvious-but-important questions. Resolves ambiguity in specs and requirements.

**Use when:**
- Requirements are underspecified
- Edge cases haven't been considered
- Stakeholder intent is unclear

---

### bubbles.harden — *"Why don't you go pave your cave?"*

Says the uncomfortable truths. Confrontational but necessary. Deep hardening pass for reliability and compliance.

**Use when:**
- Code is "done" but feels fragile
- Pre-release hardening
- After chaos results reveal weaknesses

---

### bubbles.gaps — *"BAAAAAM!"*

Gap analysis. Finds things nobody else noticed — missing test types, undocumented endpoints, spec coverage holes.

**Use when:**
- Post-implementation quality check
- Before final audit
- When you suspect something's missing

---

## <img src="../../icons/bill-wrench.svg" width="28"> Quality & Ops

### bubbles.bootstrap — *"Smokes, let's go."*

Sets up scaffolding. Creates feature/bug directories with required artifacts (`spec.md`, `design.md`, `scopes.md`, `report.md`, `uservalidation.md`, `state.json`).

**Use when:**
- Starting a new feature or bug
- Artifacts are missing and need to be created

**Example:**
```
/bubbles.bootstrap  create feature folder for portfolio-dashboard
```

---

### bubbles.stabilize

Quiet. Reliable. Fixes infrastructure. Doesn't say much. Addresses stability issues — test flakiness, infrastructure gaps, environment problems.

**Use when:**
- Tests are flaky
- Infrastructure is unstable
- Build system needs fixing

---

### bubbles.security — *"Safety... always ON."*

Security scanning. Finds vulnerabilities, injection risks, auth issues, OWASP violations.

**Use when:**
- Security review needed
- Before shipping to production
- After dependency updates

---

### bubbles.simplify — *"Duct tape fixes everything."*

Cuts through complexity. Identifies over-engineering and simplifies.

**Use when:**
- Code is getting too complex
- Abstractions are unnecessary
- Functions are too long

---

### bubbles.cinematic-designer — *"I was in Skid Row!"*

Premium design system creation. Over-the-top production value.

**Use when:**
- Building design systems
- Creating component libraries
- Premium UI work

---

## <img src="../../icons/camera-crew.svg" width="28"> Utilities

### bubbles.status

Read-only observer. Reports spec/scope state without changing anything.

**Use when:**
- Checking progress on a feature
- Getting an overview of spec status

**Example:**
```
/bubbles.status
/bubbles.status  show status of feature 042
```

---

### bubbles.handoff — *"Have a good one, boys."*

Packages session context for the next session. Creates a handoff document with what was done, what's remaining, and current state.

**Use when:**
- End of a work session
- Switching to a different task
- Before stepping away

---

### bubbles.commands

Command registry manager. Keeps the project's command reference up to date.

---

### bubbles.create-skill — *"BAAAAM!"*

Creates new repo-local skills under `.github/skills/`.

**Use when:**
- Packaging domain knowledge into reusable skills
- Creating procedural checklists

---

### bubbles.bug

Bug investigation and fixing. Full workflow: reproduction → root cause → fix → verify.

**Use when:**
- A bug needs investigation
- Bug fix with proper regression testing

**Example:**
```
/bubbles.bug  Users can't log in when password contains special characters
```

---

## Workflow Phases

Each phase has a specific purpose and exit criteria:

| Phase | Agent | Purpose |
|-------|-------|---------|
| `analyze` | `bubbles.analyst` | Business requirements discovery |
| `ux` | `bubbles.ux` | UI/UX wireframes and flows |
| `design` | `bubbles.design` | Technical architecture |
| `clarify` | `bubbles.clarify` | Resolve ambiguity |
| `plan` | `bubbles.plan` | Scope definition with DoD |
| `implement` | `bubbles.implement` | Code delivery to DoD |
| `test` | `bubbles.test` | Test execution and gap fixing |
| `validate` | `bubbles.validate` | Gate verification |
| `audit` | `bubbles.audit` | Final compliance check |
| `docs` | `bubbles.docs` | Documentation updates |
| `harden` | `bubbles.harden` | Deep hardening pass |
| `gaps` | `bubbles.gaps` | Gap analysis |
| `chaos` | `bubbles.chaos` | Chaos/resilience testing |
| `security` | `bubbles.security` | Security scanning |
| `stabilize` | `bubbles.stabilize` | Stability fixes |

---

## Evidence Standard

Every completed item requires evidence. This is non-negotiable.

**Valid evidence:**
```
✅ Actual terminal output from running a command
✅ ≥10 lines of raw output
✅ Includes the command, exit code, and key results
```

**Invalid evidence (fabrication):**
```
❌ "Tests pass" without terminal output
❌ Writing expected output instead of actual output
❌ Summaries instead of raw terminal output
❌ Evidence from a different session
❌ Template placeholders left unfilled
```

---

<p align="center">
  <img src="../../icons/bubbles-glasses.svg" width="32">
  <br>
  <em>"DEEEE-CENT!"</em>
</p>
