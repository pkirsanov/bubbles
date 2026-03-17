# Recipe: Check Status

> *"Decent!"*

---

## The Situation

You want to know where things stand.

## The Command

```
/bubbles.status
```

Shows:
- Active specs and their status
- Scope completion progress
- Current phase
- Any blocked items

## For a Specific Feature

```
/bubbles.status  show status of 042-catalog-assistant
```

## What Status Reports

- **Spec status:** not_started / in_progress / done / blocked
- **Scope progress:** N of M scopes Done
- **DoD completion:** N of M items checked
- **Current phase:** What's running now
- **Blockers:** Any gate failures or issues
