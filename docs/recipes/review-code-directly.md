# Recipe: Review Code Directly

> *"From parts unknown, I can smell what's broken and what's worth building."*

---

## The Situation

You want a direct code review on a feature, component, path, or the whole repo before deciding what should be fixed immediately and what should become a spec.

This is not a full workflow run. It is a lightweight assessment pass.

## The Command

```
/bubbles.review  profile: engineering-sweep scope: component:dashboard output: summary-doc
```

Or for the whole repo:

```
/bubbles.review  scope: full-repo output: summary-only
```

Or to promote findings into specs:

```
/bubbles.review  scope: feature:auth output: create-specs
```

## Profiles

Review profiles are defined in `bubbles/review.yaml`.

| Profile | Use It For |
|---------|------------|
| `executive-sweep` | business priorities and high-level risk |
| `engineering-sweep` | balanced technical review across quality, drift, tests, and docs |
| `release-readiness` | shipping-focused risk review |
| `security-first` | security and compliance focused review |
| `test-quality` | coverage, realism, taxonomy, and weak-test review |
| `docs-and-drift` | spec/code/docs alignment review |

## What You Get Back

Every run uses the same output shape:

1. Review scope
2. Executive summary
3. Findings by lens
4. Prioritized actions
5. Spec promotion candidates
6. Artifact outputs

## When To Use This Instead Of A Workflow

Use `bubbles.review` when:
- you want to inspect code directly
- you do not want gates or done-state progression
- you want a summary document first
- you only want selected findings promoted into specs later

Use `bubbles.workflow` when:
- you already know the target spec
- you want implementation/test/validation/audit progression
- you want work driven to completion