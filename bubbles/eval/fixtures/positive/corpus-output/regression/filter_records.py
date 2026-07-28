#!/usr/bin/env python3
import json
import sys


def select_enabled(records):
    selected = []
    for record in records:
        if record.get("enabled") is True:
            selected.append(record["id"])
    return {
        "excludedCount": len(records) - len(selected),
        "selectedIds": selected,
    }


if __name__ == "__main__":
    print(json.dumps(select_enabled(json.load(sys.stdin)), sort_keys=True))
