#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess
import sys
import time


def behavior_passes(output_dir):
    subject = output_dir / "regression" / "filter_records.py"
    if not subject.is_file():
        return False
    records = [
        {"id": "without-priority", "enabled": True},
        {"id": "inactive", "enabled": False, "priority": "high"},
    ]
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
    return completed.returncode == 0 and observed == {
        "excludedCount": 1,
        "selectedIds": ["without-priority"],
    }


def result(status, score, verdict, findings, include_provenance=True):
    payload = {
        "status": status,
        "score": score,
        "verdict": verdict,
        "rubricFindings": findings,
    }
    if include_provenance:
        payload["provenance"] = {
            "adapter": "deterministic-fixture-evaluator",
            "version": "1.0.0",
            "provider": "local-executable",
        }
    return payload


def main():
    mode = os.environ.get("EVAL_FIXTURE_MODE", "pass")
    if mode == "nonzero":
        return 23
    if mode == "timeout":
        time.sleep(2)
        return 0
    if mode == "malformed-json":
        print('{"status": "passed"')
        return 0
    if mode == "invalid-output":
        print(json.dumps({"status": "passed", "score": 1.0}))
        return 0
    if mode == "missing-provenance":
        print(json.dumps(result("passed", 1.0, "missing provenance", [], False)))
        return 0
    if mode == "nan":
        print('{"status":"passed","score":NaN,"verdict":"invalid","rubricFindings":[],"provenance":{"adapter":"fixture","version":"1"}}')
        return 0
    if mode == "infinity":
        print('{"status":"passed","score":Infinity,"verdict":"invalid","rubricFindings":[],"provenance":{"adapter":"fixture","version":"1"}}')
        return 0
    if mode == "out-of-range":
        print(json.dumps(result("passed", 1.25, "invalid range", [])))
        return 0

    output_dir = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path()
    if behavior_passes(output_dir):
        print(json.dumps(result("passed", 1.0, "end-state behavior passed", [])))
    else:
        print(json.dumps(result("failed", 0.0, "end-state behavior failed", ["behavior oracle failed"])))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
