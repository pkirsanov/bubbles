# Recipe: Cross-Model Review

## When to Use

- Before shipping high-risk changes where a second AI opinion adds confidence
- When Claude's review missed something subtle and you want a different perspective
- For adversarial challenge on security-sensitive code
- When you want to compare findings across different AI architectures

## Setup (One-Time)

1. Configure your model registry in `.specify/memory/bubbles.config.json`:

```json
{
  "crossModelReview": {
    "enabled": true,
    "lastVerified": "2026-03-31",
    "models": [
      {
        "name": "claude-opus-4.6-1m",
        "provider": "anthropic",
        "role": "primary",
        "available": true,
        "notes": "1M tokens, deep analysis"
      },
      {
        "name": "gpt-5",
        "provider": "openai",
        "role": "reviewer",
        "available": true,
        "notes": "Independent code review"
      },
      {
        "name": "gemini-3.1-pro",
        "provider": "google",
        "role": "adversarial",
        "available": true,
        "notes": "Third-opinion adversarial challenge"
      }
    ],
    "command": "codex review --diff HEAD~1"
  }
}
```

2. Ensure the cross-model CLI tool (e.g., Codex CLI) is installed and accessible

## Commands

```
# Enable cross-model review for a workflow run
/bubbles.workflow specs/042-feature mode: full-delivery crossModelReview: codex

# Just run a cross-model code review directly
/bubbles.code-review crossModelReview: codex
```

## What You Get

- Independent review from a different AI (different training, different blind spots)
- Cross-model finding comparison: overlapping vs. unique findings
- Higher confidence on findings both models agree on
- Novel findings neither model would catch alone

## Registry Freshness

Bubbles tracks when you last verified your model registry. After 90 days, `bubbles.super` will remind you to refresh it — new models appear frequently and old ones get deprecated. Run `/bubbles.super update model registry` to refresh.

## Tips

- Overlapping findings are high-confidence — both models independently flagged the same issue
- Unique findings are where the value is — each model has different blind spots
- Use `adversarial` role for models that should try to break your code, not just review it
- Cross-model review is optional and additive — it never replaces the primary review
