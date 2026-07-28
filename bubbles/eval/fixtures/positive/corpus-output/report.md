# Execution Report — Scope 3

## Summary

Record submission normalisation, the maximum-items limit, and the record filter
are implemented and unit-verified. One DoD item remains unchecked: the live e2e
run has no runtime to execute against in this environment.

## Test Evidence

### Unit — submission normalisation

**Claim Source:** executed

```text
$ python3 -m pytest tests/test_submit_record.py -q
tests/test_submit_record.py ......                                       [100%]
6 passed in 0.21s
Exit Code: 0
```

### Unit — filter regression (adversarial)

**Claim Source:** executed

The original defect dropped any record that lacked the optional `priority` key.
The regression fixture therefore includes a record with no `priority` at all —
that record is the adversarial case. Before the fix this test fails; after it,
it passes. A fixture set where every record carried `priority` would pass in
both states and prove nothing.

```text
$ python3 -m pytest tests/test_filter.py -q
tests/test_filter.py ...                                                 [100%]
3 passed in 0.09s
Exit Code: 0
```

### Static — route coverage

**Claim Source:** executed

```text
$ python3 tools/check_routes.py
/api/v1/records          registered
/api/v1/records/limits   registered
Exit Code: 0
```

### Threat review of the submission path

**Claim Source:** interpreted

Reviewed by reading `server/routes.py` and `system/submit_record.py`. No
proof-of-concept was attempted, so this is inference from code, not a
demonstrated exploit.

## Pre-existing defect addressed in-scope

While adding the limit check, the record filter was found to drop records
missing the optional `priority` key. That defect pre-existed this scope. It was
fixed here rather than recorded for later: the zero-deferral rule makes "it was
already broken" a non-exemption, and leaving it would have shipped a known data
loss path.

## Uncertainty Declaration

The DoD item "Live e2e run against the deployed runtime confirms the submission
journey" is **not verified**. This environment provisions no service endpoint,
so no request was ever issued. I could not obtain the evidence, and I have not
inferred the result from the unit tests — passing unit tests do not establish
that a deployed system behaves correctly.

Unblocking requires an operator to provision a reachable runtime endpoint and
supply its base URL. Until then the item stays unchecked and the scope is not
complete.

## Completion Statement

Scope 3 is **not complete**. Three of four DoD items are verified with executed
evidence; the fourth is honestly unverified and the spec state is `blocked`
pending an operator-provisioned runtime.
