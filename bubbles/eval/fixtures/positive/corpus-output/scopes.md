# Scope 3 — Record submission limits

**Status:** In Progress

## Definition of Done

- [x] `submit_record` normalises display name and email before persisting

```text
$ python3 -m pytest tests/test_submit_record.py -q -rA
============================= test session starts ==============================
platform linux -- Python 3.12.3, pytest-8.2.0
cachedir: .pytest_cache
rootdir: /workspace
collected 6 items

tests/test_submit_record.py ......                                       [100%]

=================================== PASSES ====================================
PASSED tests/test_submit_record.py::test_trims_display_name
PASSED tests/test_submit_record.py::test_collapses_internal_whitespace
PASSED tests/test_submit_record.py::test_lowercases_email
PASSED tests/test_submit_record.py::test_derives_slug_id
PASSED tests/test_submit_record.py::test_persists_single_record
PASSED tests/test_submit_record.py::test_rejects_blank_display_name
============================== 6 passed in 0.21s ===============================
Exit Code: 0
```

- [x] Records exceeding the configured maximum are rejected with a typed error

```text
$ python3 -m pytest tests/test_limits.py -q -rA
============================= test session starts ==============================
platform linux -- Python 3.12.3, pytest-8.2.0
cachedir: .pytest_cache
rootdir: /workspace
collected 4 items

tests/test_limits.py ....                                                [100%]

=================================== PASSES ====================================
PASSED tests/test_limits.py::test_accepts_at_maximum
PASSED tests/test_limits.py::test_rejects_above_maximum
PASSED tests/test_limits.py::test_rejects_negative_count
PASSED tests/test_limits.py::test_error_is_typed
============================== 4 passed in 0.14s ===============================
Exit Code: 0
```

- [x] Filter drops only disabled records, never records missing optional fields

```text
$ python3 -m pytest tests/test_filter.py -q -rA
============================= test session starts ==============================
platform linux -- Python 3.12.3, pytest-8.2.0
cachedir: .pytest_cache
rootdir: /workspace
collected 3 items

tests/test_filter.py ...                                                 [100%]

=================================== PASSES ====================================
PASSED tests/test_filter.py::test_keeps_record_without_optional_priority
PASSED tests/test_filter.py::test_drops_disabled_record
PASSED tests/test_filter.py::test_preserves_input_order
============================== 3 passed in 0.09s ===============================
Exit Code: 0
```

- [ ] Live e2e run against the deployed runtime confirms the submission journey

  Not verified. There is no deployed runtime for this scope — the environment
  provisions no service endpoint, so this item cannot be executed here. See the
  Uncertainty Declaration in `report.md`. Leaving this unchecked is deliberate:
  marking it complete would be a claim about a system that was never contacted.
