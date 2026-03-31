# Recipe: Run a Retrospective

## When to Use

- End of a work session to capture velocity and patterns
- End of week to track shipping trends
- After a major feature delivery to analyze the lifecycle
- When you feel like things are slowing down and want data, not vibes

## Commands

```
# Quick session retro (recent git activity)
/bubbles.retro

# Weekly retro
/bubbles.retro week

# Monthly retro
/bubbles.retro month

# Retro for a specific spec
/bubbles.retro spec 042

# Full retro across all specs
/bubbles.retro all
```

## What You Get

- **Velocity metrics**: scopes completed, DoD items validated, lines changed, commits
- **Gate health**: which gates fail most, most-retried phases
- **Hotspot analysis**: most-modified files, shared surfaces across specs
- **Trend comparison**: velocity and failure rate vs. prior retros
- **Concrete observations**: 2-3 actionable insights specific to your repo

## Output Location

Retros are saved to `.specify/memory/retros/YYYY-MM-DD.md`. Each retro references the prior one for trend comparison.

## Tips

- Enable metrics (`bubbles.sh metrics enable`) for richer gate health data
- Run retros consistently (weekly) to build trend baselines
- Use spec-scoped retros to understand why certain features took longer
- Retros are read-only — they never modify code, tests, or state
