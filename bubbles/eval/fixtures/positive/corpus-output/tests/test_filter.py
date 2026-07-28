"""Regression for the dropped-record defect.

The bug dropped any record lacking the optional "priority" key. The first
fixture below has no "priority" at all -- that is the adversarial case, and it
is what makes this test able to detect the bug returning.
"""

from system.filter_records import select_enabled


def test_keeps_record_without_optional_priority():
    records = [
        {"id": "no-priority", "enabled": True},
        {"id": "disabled", "enabled": False},
    ]
    assert [r["id"] for r in select_enabled(records)] == ["no-priority"]
