# Recipe: Quality Sweep

> *"The shit winds are coming, Randy."*

---

## The Situation

Implementation is done but you want a thorough quality check — find gaps, harden weak spots, ensure nothing slipped through.

## The Command

```
/bubbles.workflow  harden-gaps-to-doc for 042-catalog-assistant
```

Or just use natural language:
```
/bubbles.workflow  do a full quality sweep on the catalog feature
```

**Phases:** harden → gaps → test → validate → docs

## What Each Phase Does

### Harden
Looks for fragile code, missing error handling, edge cases, and compliance gaps. The uncomfortable truth-teller.

### Gaps
Finds what nobody noticed — missing test types, undocumented endpoints, spec coverage holes, orphaned code.

### Test
Runs all test suites, verifies coverage, fixes any new failures from hardening.

### Validate
Checks all 42 quality gates, verifies evidence integrity, and enforces artifact ownership routing.

If validate, harden, gaps, stabilize, or security finds missing planning or design content, those agents route the change to `bubbles.plan`, `bubbles.design`, or `bubbles.analyst` instead of patching foreign-owned artifacts themselves.

### Docs
Updates documentation to match the hardened state.

## Alternative: Stochastic Sweep

Don't know what to check? Let the system randomly pick:

```
/bubbles.workflow  stochastic-quality-sweep
```

Like bottle kids — you never know where they'll hit, but they always find something.

## Individual Quality Tools

```
/bubbles.harden    # Deep hardening pass
/bubbles.gaps      # Find missing pieces
/bubbles.chaos     # Break things on purpose
/bubbles.security  # Security scan
```
