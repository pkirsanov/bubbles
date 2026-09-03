#!/usr/bin/env python3
"""Create broker-owned immutable snapshots for one reference dispatch."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import stat
import sys
import time
from pathlib import Path
from typing import Any

MAX_INPUT_BYTES = 1024 * 1024
MAX_EXECUTABLE_BYTES = 256 * 1024 * 1024


class SnapshotError(Exception):
    pass


def open_regular_no_symlinks(path_text: str) -> int:
    path = Path(path_text)
    if not path.is_absolute():
        raise SnapshotError("input path must be absolute")
    parts = path.parts[1:]
    if not parts:
        raise SnapshotError("input path must name a file")
    directory_fd = os.open("/", os.O_RDONLY | os.O_DIRECTORY)
    try:
        for part in parts[:-1]:
            next_fd = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=directory_fd)
            os.close(directory_fd)
            directory_fd = next_fd
        file_fd = os.open(parts[-1], os.O_RDONLY | os.O_NOFOLLOW, dir_fd=directory_fd)
    except OSError as error:
        raise SnapshotError("path contains an unavailable or symbolic component") from error
    finally:
        os.close(directory_fd)
    if not stat.S_ISREG(os.fstat(file_fd).st_mode):
        os.close(file_fd)
        raise SnapshotError("path does not name a regular file")
    return file_fd


def read_stable(fd: int, limit: int, label: str) -> tuple[bytes, os.stat_result]:
    before = os.fstat(fd)
    if before.st_size > limit:
        raise SnapshotError(f"{label} exceeds the size limit")
    chunks: list[bytes] = []
    total = 0
    while True:
        chunk = os.read(fd, min(65536, limit + 1 - total))
        if not chunk:
            break
        chunks.append(chunk)
        total += len(chunk)
        if total > limit:
            raise SnapshotError(f"{label} exceeds the size limit")
    after = os.fstat(fd)
    stable_fields = ("st_dev", "st_ino", "st_size", "st_mtime_ns", "st_ctime_ns")
    if any(getattr(before, field) != getattr(after, field) for field in stable_fields):
        raise SnapshotError(f"{label} changed while it was read")
    return b"".join(chunks), after


def parse_object(raw: bytes, label: str) -> dict[str, Any]:
    try:
        value = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise SnapshotError(f"{label} is not valid UTF-8 JSON") from error
    if not isinstance(value, dict):
        raise SnapshotError(f"{label} must be a JSON object")
    return value


def validate_action(action: dict[str, Any], consumption: dict[str, Any]) -> tuple[list[str], str]:
    if set(action) != {"actionDigest", "argv"}:
        raise SnapshotError("action has unsupported fields")
    argv = action.get("argv")
    if not isinstance(argv, list) or not argv or not all(
        isinstance(item, str) and item and not any(character in item for character in "\n\r\0")
        for item in argv
    ):
        raise SnapshotError("action argv is invalid")
    if not argv[0].startswith("/"):
        raise SnapshotError("executable must be an absolute path")
    canonical = json.dumps({"argv": argv}, ensure_ascii=False, separators=(",", ":"), sort_keys=True)
    computed_digest = "sha256:" + hashlib.sha256(canonical.encode("utf-8")).hexdigest()
    permit_digest = consumption.get("action_digest", consumption.get("actionDigest"))
    if action.get("actionDigest") != computed_digest or permit_digest != computed_digest:
        raise SnapshotError("action digest does not match permit binding")
    return argv, computed_digest


def copy_linux_elf(source_fd: int, destination: Path) -> dict[str, Any]:
    source_stat = os.fstat(source_fd)
    if source_stat.st_mode & 0o222:
        raise SnapshotError("executable is writable and unsupported")
    if source_stat.st_size > MAX_EXECUTABLE_BYTES:
        raise SnapshotError("executable exceeds the size limit")
    prefix = os.read(source_fd, 4)
    if prefix != b"\x7fELF":
        raise SnapshotError("executable format is unsupported; only Linux ELF is allowed")
    os.lseek(source_fd, 0, os.SEEK_SET)
    digest = hashlib.sha256()
    total = 0
    destination_fd = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o500)
    try:
        while True:
            chunk = os.read(source_fd, 65536)
            if not chunk:
                break
            total += len(chunk)
            if total > MAX_EXECUTABLE_BYTES:
                raise SnapshotError("executable exceeds the size limit")
            digest.update(chunk)
            view = memoryview(chunk)
            while view:
                written = os.write(destination_fd, view)
                if written == 0:
                    raise SnapshotError("executable snapshot write made no progress")
                view = view[written:]
        os.fsync(destination_fd)
    except BaseException:
        destination.unlink(missing_ok=True)
        raise
    finally:
        os.close(destination_fd)
    after = os.fstat(source_fd)
    stable_fields = ("st_dev", "st_ino", "st_size", "st_mtime_ns", "st_ctime_ns")
    if any(getattr(source_stat, field) != getattr(after, field) for field in stable_fields):
        destination.unlink(missing_ok=True)
        raise SnapshotError("executable changed while it was copied")
    return {"bytes": total, "sha256": "sha256:" + digest.hexdigest()}


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, separators=(",", ":"), sort_keys=True) + "\n", encoding="utf-8")
    path.chmod(0o600)


def wait_at_test_seam() -> None:
    ready = os.environ.get("BUBBLES_REFERENCE_BROKER_SNAPSHOT_READY_FILE")
    release = os.environ.get("BUBBLES_REFERENCE_BROKER_SNAPSHOT_RELEASE_FILE")
    if ready is None and release is None:
        return
    if os.environ.get("BUBBLES_REFERENCE_BROKER_TEST") != "enabled":
        raise SnapshotError("snapshot test seam is not enabled")
    if ready is None or release is None:
        raise SnapshotError("snapshot test seam requires ready and release files")
    Path(ready).touch(mode=0o600, exist_ok=False)
    deadline = time.monotonic() + 30
    while not Path(release).exists():
        if time.monotonic() >= deadline:
            raise SnapshotError("snapshot test seam timed out")
        time.sleep(0.01)


def create_snapshot(action_path: str, consumption_path: str, output_dir_text: str) -> None:
    if sys.platform != "linux":
        raise SnapshotError("platform is unsupported; only Linux ELF snapshot launch is allowed")
    output_dir = Path(output_dir_text)
    output_stat = output_dir.lstat()
    if not output_dir.is_dir() or stat.S_IMODE(output_stat.st_mode) != 0o700:
        raise SnapshotError("snapshot directory must be private mode 0700")
    if stat.S_ISLNK(output_stat.st_mode):
        raise SnapshotError("snapshot directory must not be a symlink")
    action_fd = open_regular_no_symlinks(action_path)
    consumption_fd = open_regular_no_symlinks(consumption_path)
    try:
        action = parse_object(read_stable(action_fd, MAX_INPUT_BYTES, "action")[0], "action")
        consumption = parse_object(read_stable(consumption_fd, MAX_INPUT_BYTES, "permit consumption")[0], "permit consumption")
    finally:
        os.close(action_fd)
        os.close(consumption_fd)
    argv, action_digest = validate_action(action, consumption)
    executable_fd = open_regular_no_symlinks(argv[0])
    try:
        executable_metadata = copy_linux_elf(executable_fd, output_dir / "executable")
    finally:
        os.close(executable_fd)
    write_json(output_dir / "action.json", {"actionDigest": action_digest, "argv": argv})
    write_json(output_dir / "permit-consumption.json", consumption)
    write_json(output_dir / "snapshot-metadata.json", {
        "actionDigest": action_digest,
        "executable": executable_metadata,
        "executableFormat": "elf",
        "launchStrategy": "broker-owned-copy",
        "platform": "linux",
        "schemaVersion": 1,
    })
    wait_at_test_seam()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--action", required=True)
    parser.add_argument("--permit-consumption", required=True)
    parser.add_argument("--output-dir", required=True)
    arguments = parser.parse_args()
    try:
        create_snapshot(arguments.action, arguments.permit_consumption, arguments.output_dir)
    except (OSError, SnapshotError) as error:
        print(f"reference-broker: snapshot refused: {error}", file=sys.stderr)
        return 4
    return 0


if __name__ == "__main__":
    raise SystemExit(main())