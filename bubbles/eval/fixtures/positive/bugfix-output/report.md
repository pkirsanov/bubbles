# Bugfix Evaluation Output

## Test Evidence

Command: executable oracle invokes `regression/filter_records.py` with an active
record that omits the legacy priority field and an inactive control record.
Exit Code: 0

Observed behavior: the active record without priority is selected, the active
record with priority is also selected, and the inactive record is excluded.

## Adversarial Regression

The regression is adversarial because the required oracle controls an input
that does not satisfy the removed priority-field gate. Reintroducing that gate
causes the independently computed selected-ID assertion to fail.
