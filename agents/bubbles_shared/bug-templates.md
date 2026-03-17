# Bug Artifact Templates

Use these templates when creating bug artifacts.

## bug.md Template

```markdown
# Bug: [BUG-NNN] Short Description

## Summary
One-line summary of the bug.

## Severity
- [ ] Critical - System unusable, data loss
- [ ] High - Major feature broken, no workaround
- [ ] Medium - Feature broken, workaround exists
- [ ] Low - Minor issue, cosmetic

## Status
- [ ] Reported
- [ ] Confirmed (reproduced)
- [ ] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Reproduction Steps
1. Step 1
2. Step 2
3. ...

## Expected Behavior
What should happen.

## Actual Behavior
What actually happens.

## Environment
- Service: [service-name]
- Version: [commit/version]
- Platform: [OS/browser/device]

## Error Output
```
[stack trace or error message]
```

## Root Cause (filled after analysis)
[Description of root cause]

## Related
- Feature: `specs/[NNN-feature-name]/`
- Related bugs: [links]
- Related PRs: [links]

## Deferred Reason (if mode: document)
[Why this bug is being deferred, priority, when to fix]
```

## design.md Template (Bug Fix)

```markdown
# Bug Fix Design: [BUG-NNN]

## Root Cause Analysis

### Investigation Summary
[What was investigated]

### Root Cause
[Precise technical root cause]

### Impact Analysis
- Affected components: [list]
- Affected data: [if any]
- Affected users: [scope]

## Fix Design

### Solution Approach
[Chosen solution and why]

### Alternative Approaches Considered
1. [Alternative 1] - Why rejected
2. [Alternative 2] - Why rejected
```
