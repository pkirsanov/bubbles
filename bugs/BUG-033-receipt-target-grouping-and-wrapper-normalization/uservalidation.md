# BUG-033 User Validation

## Automation Readiness

Written by automation. Records that the delivered behavior was verified far
enough to be worth a human's time. Checking every item here satisfies NO
acceptance obligation.

- [x] Facet 1 acceptance and its adversarial bound both executed with real exit codes
- [x] Facet 2 acceptance and its adversarial bound both executed with real exit codes
- [x] The BUG-007 and BUG-032 pins still hold after the relaxation
- [x] The regression surface extracts the guard's own program rather than re-implementing it

## Checklist

Ships UNCHECKED. An item is checked only when a human accepts that behavior.
Automation MUST NOT check one.

- [ ] Repeated honest re-runs of one validator are no longer reported as forged evidence
- [ ] One command spelled through shell, `env` and assignment wrappers is treated as one command
- [ ] Two different commands sharing one captured result are still refused
- [ ] The relaxation did not widen Check 43 into a hole

## Human Acceptance Record

Not yet recorded. A terminal transition requires this section to name a
non-automation acceptor, an acceptance timestamp, and a declared method.
