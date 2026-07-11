#!/usr/bin/env python3
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time


def verify_bugfix(output_dir):
    subject = output_dir / "regression" / "filter_records.py"
    if not subject.is_file():
        return False

    records = [
        {"id": "without-priority", "enabled": True},
        {"id": "inactive", "enabled": False, "priority": "high"},
        {"id": "second-active", "enabled": True, "priority": "low"},
    ]
    expected = {
        "excludedCount": 1,
        "selectedIds": ["without-priority", "second-active"],
    }
    try:
        completed = subprocess.run(
            [sys.executable, str(subject)],
            input=json.dumps(records),
            capture_output=True,
            text=True,
            timeout=2,
            check=False,
        )
        observed = json.loads(completed.stdout)
    except (OSError, subprocess.TimeoutExpired, json.JSONDecodeError):
        return False
    return completed.returncode == 0 and observed == expected


def section(text, heading):
    match = re.search(
        rf"(?ms)^## {re.escape(heading)}[ \t]*\n(.*?)(?=^## |\Z)",
        text,
    )
    return match.group(1) if match else None


def significant_words(value):
    stop_words = {
        "after",
        "before",
        "caller",
        "from",
        "into",
        "that",
        "their",
        "then",
        "when",
        "with",
    }
    return {
        word.lower()
        for word in re.findall(r"[A-Za-z][A-Za-z0-9-]{3,}", value)
        if word.lower() not in stop_words
    }


def verify_feature(output_dir):
    spec_path = output_dir / "spec.md"
    if not spec_path.is_file():
        return False
    text = spec_path.read_text(encoding="utf-8")
    if re.search(r"PLACEHOLDER|\bTBD\b|lorem ipsum|TODO:", text, re.IGNORECASE):
        return False

    outcome = section(text, "Outcome Contract")
    scenarios = section(text, "Scenarios")
    if outcome is None or scenarios is None:
        return False

    fields = {}
    for label in ("Intent", "Success Signal", "Hard Constraints", "Failure Condition"):
        match = re.search(rf"(?m)^{re.escape(label)}:\s+(.+)$", outcome)
        if not match or len(match.group(1).split()) < 4:
            return False
        fields[label] = match.group(1)

    block = re.search(r"(?ms)^```gherkin\s*\n(.*?)^```\s*$", scenarios)
    if not block or not re.search(r"(?m)^Scenario:\s+\S", block.group(1)):
        return False
    steps = {}
    for keyword in ("Given", "When", "Then"):
        match = re.search(rf"(?m)^{keyword}\s+(.+)$", block.group(1))
        if not match or len(match.group(1).split()) < 4:
            return False
        steps[keyword] = match.group(1)

    contract_is_coherent = bool(
        significant_words(fields["Success Signal"])
        & significant_words(steps["Then"])
    )
    if not contract_is_coherent:
        return False

    subject = output_dir / "system" / "submit_record.py"
    if not subject.is_file():
        return False
    request = {
        "displayName": "  Ada   Lovelace  ",
        "email": " ADA@EXAMPLE.COM ",
    }
    expected_record = {
        "displayName": "Ada Lovelace",
        "email": "ada@example.com",
        "id": "ada-lovelace",
    }
    try:
        with tempfile.TemporaryDirectory() as temp_dir:
            state_path = Path(temp_dir) / "records.json"
            completed = subprocess.run(
                [sys.executable, str(subject), str(state_path)],
                input=json.dumps(request),
                capture_output=True,
                text=True,
                timeout=2,
                check=False,
            )
            response = json.loads(completed.stdout)
            persisted = json.loads(state_path.read_text(encoding="utf-8"))
    except (OSError, subprocess.TimeoutExpired, json.JSONDecodeError):
        return False
    return (
        completed.returncode == 0
        and response == {"persistedCount": 1, "record": expected_record}
        and persisted == [expected_record]
    )


def main():
    if len(sys.argv) < 2:
        return 64
    mode = sys.argv[1]
    output_dir = Path(os.environ.get("BUBBLES_EVAL_OUTPUT", "")).resolve()

    if mode == "bugfix":
        return 0 if verify_bugfix(output_dir) else 1
    if mode == "feature":
        return 0 if verify_feature(output_dir) else 1
    if mode == "nonzero":
        return 19
    if mode == "timeout":
        time.sleep(2)
        return 0
    if mode == "argv-literal":
        expected = [
            "alpha;touch",
            "$(touch injected)",
            "space separated",
            "a|b",
            "x&&y",
        ]
        sentinels = (output_dir / "injected", output_dir / "touch")
        return 0 if sys.argv[2:] == expected and not any(path.exists() for path in sentinels) else 1
    return 65


if __name__ == "__main__":
    raise SystemExit(main())
