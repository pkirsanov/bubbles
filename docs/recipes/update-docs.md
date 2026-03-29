# Recipe: Update Documentation

> *"Know what I'm sayin'? Publish the truth."*

---

## The Situation

Code changed, documentation is stale.

## The Command

```
/bubbles.docs  update docs for 042-catalog-assistant

/bubbles.docs  publish docs for specs/_ops/OPS-001-ci-hardening
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
- Managed docs declared in `bubbles/docs-registry.yaml` (README, OPERATIONS, etc.)

If the published-doc set itself changed, update `bubbles/docs-registry.yaml` in the same change.

## Rules

- Docs must match the actual implementation
- Managed docs must match the current execution packets before closeout
- Docs must match the actual workflow contract too: owner-only remediation, concrete result envelopes, and packet-based follow-up
- No stale references
- No broken links
