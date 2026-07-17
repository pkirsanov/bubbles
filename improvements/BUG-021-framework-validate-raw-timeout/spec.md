# Expected Behavior: BUG-021 Framework Validate Raw Timeout

## Problem Contract

Every framework validation deadline must use the framework's portable timeout
contract rather than assume an optional GNU executable is present.

## Actors

- A macOS contributor running canonical framework validation.
- A Linux contributor relying on GNU timeout-compatible exit semantics.
- A downstream repository consuming installed framework validation bytes.
- A release owner requiring a clean exact portability scan and source identity.

## Requirements

### BR-021-001 Use The Portable Timeout Contract

The macOS portability guard selftest and workflow planning provenance selftest
registrations must invoke the existing `bubbles_run_with_timeout` helper instead
of raw `timeout`.

### BR-021-002 Preserve Deadline Configuration

The existing environment-controlled deadline values and defaults must retain
their meaning. The repair must not remove, lengthen silently, or bypass either
deadline.

### BR-021-003 Preserve Exit Semantics

Normal child exits must propagate unchanged and a deadline expiration must
normalize to exit `124` across GNU timeout, `gtimeout`, and watchdog fallback
paths.

### BR-021-004 Work Without Optional Coreutils

Both registered checks must remain bounded when a sanitized macOS path contains
neither `timeout` nor `gtimeout`.

### BR-021-005 Pass Exact Portability Scanning

The exact BUG-019 portability surface and a direct scan of
`framework-validate.sh` must report no raw-timeout finding after the repair.

### BR-021-006 Scenario-First Regression

A persistent regression must exercise the production framework-validation call
path under a system-only tool path. A copied helper unit alone is insufficient.

### BR-021-007 Adversarial Reintroduction Signal

The regression must fail if either raw call returns, if the timeout is silently
dropped, or if a timed-out child is reported as success or an exit other than
`124`.

### BR-021-008 Canonical-Only Delivery

Canonical source, install provenance, generated release identity, and supported
downstream upgrade must agree before certification.

### Single-Capability Justification

This is a narrow repair inside the framework's existing portable timeout
capability, not a new capability or a second implementation. The only affected
consumers are the macOS portability guard selftest registration controlled by
`BUBBLES_MACOS_PORTABILITY_GUARD_SELFTEST_TIMEOUT_SECONDS` and the workflow
planning provenance selftest registration controlled by
`BUBBLES_WORKFLOW_PLANNING_PROVENANCE_SELFTEST_TIMEOUT_SECONDS`; both currently
pass raw `timeout`, while `bubbles/scripts/guard-lib.sh` already owns the shared
`bubbles_run_with_timeout` contract and its `timeout` -> `gtimeout` -> watchdog
provider resolution.

Both registrations must therefore use that existing helper, with their
configured deadlines and `120`-second defaults unchanged. The helper must load
fail-loud from the managed sibling script, remain bounded on a system-only
macOS PATH with neither optional timeout executable, preserve ordinary child
statuses, and expose expiration as `124` at the helper boundary; `run_check`
must continue to report the named check as failed and preserve the validator's
observable aggregate failure. Adding another provider, selector, wrapper, or
timeout abstraction would duplicate the established authority without adding a
business capability or reducing complexity.

## Acceptance Scenarios

```gherkin
Feature: Bound framework selftests with the portable timeout helper

  Scenario: Framework validation runs both deadline-bearing checks without GNU timeout
    Given a macOS system-only PATH with neither timeout nor gtimeout
    When framework validation reaches the portability and planning provenance selftests
    Then both checks execute through the portable watchdog path
    And no command-not-found or raw-timeout portability finding occurs

  Scenario: Portable timeout outcomes remain observable and exact
    Given a controlled child that exceeds its configured deadline
    When the production framework validation timeout path runs
    Then the check observes exit 124
    And a non-timeout child exit remains unchanged
    And removing the helper call makes the adversarial regression fail
```

## Release Train

Target train: `framework-next`. This bug introduces no feature flag. Other
trains remain unchanged until supported release/install/upgrade provenance
consumes the repaired canonical bytes.

## Non-Goals

- Weakening or exempting the portability scanner.
- Refactoring every framework validation registration.
- Changing the behavior of either wrapped selftest.
- Requiring Homebrew/MacPorts coreutils.
- Hand-editing generated release metadata or downstream installed bytes.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
