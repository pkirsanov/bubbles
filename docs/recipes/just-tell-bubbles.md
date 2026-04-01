# Recipe: Just Tell Bubbles

> *"Decent. I can see how all this fits together."*

`/bubbles.workflow` is the **universal entry point** for all Bubbles work. You don't need to know which agent, mode, or parameters to use — just describe what you want in plain English.

## How It Works

Workflow has a Phase -1 (Intent Resolution) that classifies your input:

| Input Type | What Happens | Example |
|-----------|-------------|---------|
| **Plain English** | Delegates to `super` for NLP resolution → gets mode + spec + tags | `/bubbles.workflow improve the booking feature` |
| **"Continue" / "next"** | Delegates to `iterate` for work-picking → gets next priority item | `/bubbles.workflow continue` |
| **Structured** | Skips resolution, executes directly | `/bubbles.workflow specs/042 mode: full-delivery` |
| **Framework ops** | Delegates to `super` for framework operations | `/bubbles.workflow doctor` |

## Examples

```
# Describe what you want — workflow figures out the rest
/bubbles.workflow  improve the booking feature to be competitive
/bubbles.workflow  fix the calendar bug in page builder
/bubbles.workflow  spend 2 hours on whatever needs attention
/bubbles.workflow  harden specs 11 through 37
/bubbles.workflow  chaos test the whole system

# Continue from where you left off
/bubbles.workflow  continue
/bubbles.workflow  next

# Framework operations
/bubbles.workflow  doctor
/bubbles.workflow  show runtime lease conflicts
/bubbles.workflow  show status

# Structured input still works
/bubbles.workflow  specs/042 mode: full-delivery tdd: true
/bubbles.workflow  011-037 mode: harden-to-doc
```

## When To Use Direct Agents Instead

| Situation | Use |
|-----------|-----|
| Framework ops, advice, command recommendations without execution | `/bubbles.super` |
| Single-iteration work-picking with type filter | `/bubbles.iterate type: tests` |
| Direct specialist work on a known scope | `/bubbles.implement`, `/bubbles.test`, etc. |
| Bug documentation from scratch | `/bubbles.bug` |

## The Delegation Graph

```
/bubbles.workflow <anything>
  │
  ├─ structured input → execute phases directly
  ├─ vague input     → runSubagent(super) → resolve → execute
  ├─ "continue"      → runSubagent(iterate) → pick work → execute
  └─ framework op    → runSubagent(super) → execute op → report
```

## Related Recipes

- [Ask the Super First](ask-the-super-first.md) — for framework ops and advice
- [Resume Work](resume-work.md) — for continuing from a saved session
- [New Feature](new-feature.md) — for building from scratch
