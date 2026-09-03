# User Validation - BUG-043 Bash Parser Compatibility

## Automation Readiness

- [ ] The persistent pre-fix test reproduces both supplied parser outcomes.
- [ ] The repaired source passes the real Bash 3 and Bash 5 parser matrix.
- [ ] The adversarial mutant proves that the regression detects the defect.
- [ ] Existing transition guard behavior passes under supported Bash.
- [ ] A temporary downstream install receives the repaired source bytes.
- [ ] Framework validation and release readiness pass.

Automation readiness does not grant human acceptance.

## Checklist

- [ ] The transition guard syntax-checks with macOS system Bash.
- [ ] The transition guard syntax-checks with supported Homebrew Bash.
- [ ] The parser repair does not weaken any transition verdict.
- [ ] The installed downstream guard matches the validated source guard.
- [ ] The standard upgrade path carries the repair into a consumer repository.

## Human Acceptance Record

Not recorded. A human must complete the checklist and add the required record
before a terminal transition.

Evidence belongs in [report.md](report.md).
