# Recipe: Resume Work

> *"Way she goes, boys."*

---

## The Situation

You were working on something in a previous session and need to pick up where you left off.

## The Command

```
# Simplest — just say "continue":
/bubbles.workflow  continue

# Or resume explicitly:
/bubbles.workflow  resume
```

**What happens:**
1. "continue" delegates to `iterate` to pick the next highest-priority work
2. "resume" reads `state.json` from the last active spec
3. Continues from exactly where it stopped

## Alternative: Check Status First

```
/bubbles.status
```

See what's in progress, what's done, what's remaining. Then:

```
/bubbles.iterate  continue 042-catalog-assistant
```

If the next executable action is unclear, `bubbles.iterate` can now run a narrow `bubbles.code-review` or `bubbles.system-review` first, then continue the same iteration with planning or execution.

## If the Previous Session Saved a Handoff

Check `.specify/memory/bubbles.session.json` — the handoff agent saves context there.

```
/bubbles.status  show handoff for 042
```

## Tip

End every session with:

```
/bubbles.handoff
```

This saves a snapshot of what was done, what's next, and any open questions — making the next resume seamless.
