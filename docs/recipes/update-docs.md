# Recipe: Update Documentation

> *"Know what I'm sayin'? It's documented."*

---

## The Situation

Code changed, documentation is stale.

## The Command

```
/bubbles.docs  update docs for 042-catalog-assistant
```

Or documentation-only mode:

```
/bubbles.workflow  docs-only for 042-catalog-assistant
```

## What Gets Updated

- API documentation (endpoints, contracts)
- Architecture docs
- Development guides
- Cheatsheets and public HTML reference cards
- Recipes and framework how-to docs
- Feature-specific docs in `specs/`
- Standard docs (README, OPERATIONS, etc.)

## Rules

- Docs must match the actual implementation
- Docs must match the actual workflow contract too: owner-only remediation, concrete result envelopes, and packet-based follow-up
- No stale references
- No broken links
