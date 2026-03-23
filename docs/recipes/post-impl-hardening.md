# Recipe: Post-Implementation Hardening

> *"We gotta tighten this up before the shit winds come, Randy."*

---

## The Situation

Implementation and tests pass, but you want the code cleaned up, stable, secure, and regression-free before shipping.

## What Happens Automatically

Every delivery mode (`full-delivery`, `bugfix-fastlane`, `feature-bootstrap`, etc.) now includes a **mandatory post-implementation hardening sequence**:

```
implement → test → regression → simplify → stabilize → security → docs → validate → audit → chaos
```

### The Hardening Sequence

| Phase | Agent | What It Does |
|-------|-------|-------------|
| **regression** | Steve French | Cross-spec regression scan, test baseline comparison, conflict detection |
| **simplify** | Donny | Code reuse, dead code removal, duplication cleanup |
| **stabilize** | Shitty Bill | Performance, infrastructure, config, reliability checks |
| **security** | Cyrus | OWASP scan, dependency audit, code security review |

Each phase that produces findings triggers an inline fix cycle (`implement → test`) before the next phase proceeds.

## Manual Hardening

If you want to run just the hardening sequence on existing code:

```
# Full hardening pipeline
/bubbles.workflow  stabilize-to-doc for 042-catalog

# Just regression + stabilize
/bubbles.regression  check for regressions in catalog feature
/bubbles.stabilize  stabilize the catalog feature

# Quality sweep with all hardening agents
/bubbles.workflow  stochastic-quality-sweep triggerAgents: regression,simplify,stabilize,security maxRounds: 8
```

## Pre-Ship Checklist

Before shipping a major feature, run all hardening agents in sequence:

```
/bubbles.workflow  harden-gaps-to-doc for <feature>
```

This runs: `harden → gaps → implement → test → regression → simplify → stabilize → security → chaos → validate → audit → docs`

The most thorough pre-release verification available. Like Lahey inspecting every trailer before park open.
