# BUG-033 User Validation

Evidence record: [report.md](report.md). Execution contract:
[scopes.md](scopes.md).

## Automation Readiness

Written by automation. Records that the delivered behavior was verified far
enough to be worth a human's time. Checking every item here satisfies NO
acceptance obligation.

- [x] Facet 1 acceptance and its adversarial bound both executed with real exit codes
- [x] Facet 2 acceptance and its adversarial bound both executed with real exit codes
- [x] The BUG-007 and BUG-032 pins still hold after the relaxation
- [x] The regression surface extracts the guard's own program rather than re-implementing it
- [ ] Timeout, gtimeout, exact Perl alarm, malformed grammar, command mismatch,
      and exit mismatch automation has current execution evidence
- [ ] The whole-guard terminal diagnostic contract has current execution evidence

## Checklist

Ships UNCHECKED. An item is checked only when a human accepts that behavior.
Automation MUST NOT check one.

- [ ] Repeated honest re-runs of one validator are no longer reported as forged evidence
- [ ] One command spelled through shell, `env` and assignment wrappers is treated as one command
- [ ] Two different commands sharing one captured result are still refused
- [ ] The relaxation did not widen Check 43 into a hole
- [ ] `timeout` and `gtimeout` expose the same underlying command as direct invocation
- [ ] Only the exact portable Perl alarm launcher is transparent
- [ ] Launcher removal composes with shell, `env`, and assignment wrappers
- [ ] Arbitrary Perl programs remain visible as recorded command identity
- [ ] Incomplete timeout, option-bearing timeout, missing-command, and near-match Perl grammar remains unchanged
- [ ] Different underlying commands remain visible and refused behind every supported launcher
- [ ] Different exit results remain visible and refused after launcher normalization
- [ ] Accepted output starts with `check=43 verdict=ACCEPTED` and contains no clone, forgery, warning, or refusal wording
- [ ] Refused output starts with `check=43 verdict=REFUSED`, names one stable reason, and ends with `effect=TRANSITION_BLOCKED`
- [ ] Command and exit mismatches label both compared values without truncation
- [ ] Narrow-terminal wrapping, ANSI stripping, and control-character escaping preserve semantic field order

## Human Acceptance Record

Not yet recorded. A terminal transition requires this section to name a
non-automation acceptor, an acceptance timestamp, and a declared method.
