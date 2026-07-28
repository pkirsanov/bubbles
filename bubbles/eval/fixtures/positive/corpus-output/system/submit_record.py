#!/usr/bin/env python3
import json
from pathlib import Path
import re
import sys


def normalize_record(raw_record):
    display_name = " ".join(raw_record["displayName"].split())
    email = raw_record["email"].strip().lower()
    record_id = re.sub(r"[^a-z0-9]+", "-", display_name.lower()).strip("-")
    return {
        "displayName": display_name,
        "email": email,
        "id": record_id,
    }


def persist_record(state_path, record):
    records = []
    if state_path.exists():
        records = json.loads(state_path.read_text(encoding="utf-8"))
    records.append(record)
    state_path.write_text(json.dumps(records, sort_keys=True), encoding="utf-8")
    return len(records)


def main():
    if len(sys.argv) != 2:
        return 64
    record = normalize_record(json.load(sys.stdin))
    count = persist_record(Path(sys.argv[1]), record)
    print(json.dumps({"persistedCount": count, "record": record}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
