# User Validation - BUG-051 YAML Validator Downstream Root Misresolution

Links: [report.md](report.md)

## Automation Readiness

- [ ] The pre-fix installed fixture reports no repository-root manifests.
- [ ] The fixed installed validator discovers top-level and nested manifests.
- [ ] A malformed installed manifest remains blocking.
- [ ] Source and installed discovery counts agree.
- [ ] Full framework validation and release readiness pass.

Automation readiness does not grant human acceptance.

## Checklist

- [ ] A downstream maintainer can validate a top-level scenario manifest.
- [ ] A downstream maintainer can validate a nested bug scenario manifest.
- [ ] An invalid downstream scenario manifest fails with its repository-relative path.
- [ ] Installing Bubbles does not change which project manifests are discovered.

## Human Acceptance Record

- acceptedBy:
- acceptedAt:
- method:
- record:

## Goal

- Goal: Keep project artifact discovery correct after a downstream install.
- Success signal: Source and installed validators discover the same manifest tree.

## Journey Steps

| Step | User Intent | Observed | Evidence | Friction |
| --- | --- | --- | --- | --- |

## Open Refinements

None recorded during filing.