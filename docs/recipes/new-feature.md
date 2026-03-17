# Recipe: New Feature (End-to-End)

> *"Freedom 35, boys!"* — Taking a feature from idea to shipped code.

---

## The Situation

You have a feature idea (or a requirement from a stakeholder) and need to take it through the full pipeline: analysis → design → implementation → testing → docs → ship.

## The Steps

### Step 1: Discover Requirements

```
/bubbles.analyst  Build a real-time notification system with email and push support
```

**What happens:** The analyst agent researches requirements, identifies actors, creates use cases, and writes `spec.md`.

**You'll get:** A `specs/NNN-notification-system/spec.md` with requirements, acceptance criteria, and use cases.

### Step 2: Design the System

```
/bubbles.design  Create technical design for the notification system
```

**What happens:** The design agent reads the spec, creates data models, API contracts, service boundaries, and writes `design.md`.

**You'll get:** A `design.md` with architecture, schemas, and technical decisions.

### Step 3: Break Into Scopes

```
/bubbles.plan  Create scopes for the notification feature
```

**What happens:** The plan agent reads spec + design, creates implementable scopes with Gherkin scenarios, test plans, and Definition of Done checklists.

**You'll get:** `scopes.md` with 3-8 scopes, each with clear DoD.

### Step 4: Implement (Scope by Scope)

```
/bubbles.implement  Execute scope 1 of notification system
```

**What happens:** The implement agent works through one scope's DoD — writing code, tests, and marking checkboxes with evidence.

Repeat for each scope, or use:

```
/bubbles.iterate  Continue notification system
```

### Step 5: Full Pipeline (Or Do It All At Once)

If you want the orchestrator to handle the entire flow:

```
/bubbles.workflow  full-delivery for notification-system
```

This runs all phases automatically: analyze → design → plan → implement → test → validate → audit → docs.

---

## Tips

- **Start small.** If the feature is large, use `/bubbles.plan` first, then `/bubbles.iterate` to work through scopes.
- **Check progress** anytime: `/bubbles.status`
- **Something wrong?** `/bubbles.validate` to check gates.
- **End of day?** `/bubbles.handoff` to save context.

---

## The Artifacts You'll End Up With

```
specs/NNN-notification-system/
├── spec.md              # What we're building (requirements)
├── design.md            # How we're building it (architecture)
├── scopes.md            # The work breakdown (DoD per scope)
├── report.md            # Evidence of execution
├── uservalidation.md    # User acceptance checklist
└── state.json           # Machine-readable progress
```
