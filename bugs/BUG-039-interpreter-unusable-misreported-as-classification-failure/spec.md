# Spec: BUG-039 Expected Behaviour

## Requirement 1 — A Prerequisite Is Named, Not Misattributed

When the Scan 2B classifier's interpreter cannot execute, the managed selftest
MUST report the missing prerequisite. It MUST NOT report the absence as
failures of the code under scan.

**Acceptance:** with an unusable interpreter the selftest emits a `SKIP:` line
naming the interpreter, its exit status and the underlying diagnostic, and emits
zero `FAIL:` lines attributable to classifier output.

## Requirement 2 — The Remediation Is Actionable

The skip MUST name what the operator has to do, specifically enough to act on
without further investigation.

**Acceptance:** when the diagnostic carries the Xcode licence signature the
message names the active developer directory and offers both
`sudo xcodebuild -license accept` and repointing the active developer directory.
Otherwise it states the generic repair and carries the captured diagnostic.

## Requirement 3 — A Skip Is Discriminable By Machine

A consumer MUST be able to distinguish "ran everything" from "skipped" without
parsing prose.

**Acceptance:** the stable line `SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1`
appears when, and only when, the scenario group did not run.

## Requirement 4 — The Guarantee Is Unchanged When The Prerequisite Is Met

With a usable interpreter, every previously-executing assertion MUST still
execute and MUST still fail on a genuine classifier regression.

**Acceptance:** a one-token mutation of the classifier's classification ladder
drives the selftest to exit 1 under both a normal PATH and the sanitized PATH
with a usable interpreter. Reverting restores exit 0 and byte-identity.

## Requirement 5 — Vacuous Verdicts Are Withheld, Not Reported

An assertion that cannot distinguish pass from fail MUST NOT report either.

**Acceptance:** the four config-integrity scenarios, which report PASS for a
valid config under a dead interpreter, are withheld under the same condition as
the semantic block and named in the skip.

## Requirement 6 — The Cascade Reports Honestly

`tests/regression/test_24_g028_sensitive_client_storage.sh` MUST NOT count a
skipped coverage claim as a pass.

**Acceptance:** when the sentinel is present, `test_24` records a `SKIP:`,
increments a separate skip counter, does not emit the coverage pass label, and
reports skips in its summary line. `FAIL_COUNT` continues to govern exit status.

## Out Of Scope

- Accepting the Xcode licence (operator-only; requires a password).
- Changing the scanner's fail-closed degradation, which is contracted behaviour
  asserted by the "Parser-unavailable configured approval fails closed" scenario.
- Auditing other selftests that use the same presence-not-usability predicate.
  Recorded as a follow-up observation, not fixed here.
