#!/usr/bin/env python3
"""Local, provider-neutral execution-control content and event store.

The store is deliberately small: immutable canonical JSON objects, one
append-only event chain, a compare-and-append head, deterministic recovery, and
one sanitized integrity projection. It has no network or service dependency.
"""

from __future__ import annotations

import argparse
import contextlib
import datetime as dt
import errno
import hashlib
import json
import math
import os
import secrets
import stat
import sys
import time
from pathlib import Path
from typing import Any, Iterator

CONTRACT = "execution-control-event"
SCHEMA_VERSION = 1
OBJECT_CONTRACT = "execution-control-object"
PROJECTION_CONTRACT = "execution-control-integrity-projection"
GENESIS = "sha256:" + hashlib.sha256(b"").hexdigest()
EVENT_TYPES = frozenset(("RECORD", "CORRECT", "SUPERSEDE"))
POSTURES = frozenset(("off", "shadow", "reference-enforce", "unsupported"))
DIGEST_PREFIX = "sha256:"
EVENT_FIELDS = frozenset(
    (
        "contractType",
        "schemaVersion",
        "sequence",
        "eventType",
        "eventId",
        "previousEventDigest",
        "eventDigest",
        "recordedAt",
        "occurrenceId",
        "attemptId",
        "posture",
        "subject",
        "objectDigest",
        "supersedesEventId",
        "extensions",
    )
)
PROPOSAL_FIELDS = EVENT_FIELDS - frozenset(("sequence", "previousEventDigest", "eventDigest"))
EXTENSION_FIELDS = frozenset(("namespace", "schemaVersion", "payloadDigest"))
SUBJECT_FIELDS = frozenset(("kind", "id"))
PENDING_FIELDS = frozenset(("contractType", "schemaVersion", "expectedSequence", "expectedHeadDigest", "event"))
HEAD_FIELDS = frozenset(("contractType", "schemaVersion", "sequence", "eventDigest"))
LOCK_WAIT_SECONDS = 10.0


class StoreError(RuntimeError):
    """Fail-closed contract or integrity error."""


def canonical_bytes(value: Any) -> bytes:
    try:
        text = json.dumps(
            value,
            ensure_ascii=False,
            allow_nan=False,
            sort_keys=True,
            separators=(",", ":"),
        )
    except (TypeError, ValueError) as exc:
        raise StoreError(f"value is not canonical JSON: {exc}") from exc
    return text.encode("utf-8")


def canonical_line(value: Any) -> bytes:
    return canonical_bytes(value) + b"\n"


def reject_constant(token: str) -> None:
    raise StoreError(f"non-finite JSON number is forbidden: {token}")


def unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise StoreError(f"duplicate JSON member is forbidden: {key}")
        result[key] = value
    return result


def parse_json_bytes(data: bytes, source: str) -> Any:
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise StoreError(f"{source} is not UTF-8") from exc
    try:
        value = json.loads(
            text,
            object_pairs_hook=unique_object,
            parse_constant=reject_constant,
        )
    except (json.JSONDecodeError, StoreError) as exc:
        if isinstance(exc, StoreError):
            raise
        raise StoreError(f"{source} is not valid JSON: {exc.msg}") from exc
    validate_numbers(value)
    return value


def validate_numbers(value: Any) -> None:
    if isinstance(value, float) and not math.isfinite(value):
        raise StoreError("non-finite JSON numbers are forbidden")
    if isinstance(value, dict):
        for member in value.values():
            validate_numbers(member)
    elif isinstance(value, list):
        for member in value:
            validate_numbers(member)


def strict_read_json(path: Path) -> Any:
    return parse_json_bytes(read_regular(path), str(path.name))


def typed_digest(contract_type: str, schema_version: int, payload: Any) -> str:
    material = {
        "contractType": contract_type,
        "schemaVersion": schema_version,
        "payload": payload,
    }
    return DIGEST_PREFIX + hashlib.sha256(canonical_bytes(material)).hexdigest()


def is_digest(value: Any) -> bool:
    if not isinstance(value, str) or not value.startswith(DIGEST_PREFIX):
        return False
    body = value[len(DIGEST_PREFIX) :]
    return len(body) == 64 and all(character in "0123456789abcdef" for character in body)


def require_exact_fields(value: Any, fields: frozenset[str], label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise StoreError(f"{label} must be an object")
    actual = frozenset(value)
    if actual != fields:
        missing = sorted(fields - actual)
        unknown = sorted(actual - fields)
        raise StoreError(f"{label} field mismatch; missing={missing}, unknown={unknown}")
    return value


def require_text(value: Any, label: str) -> str:
    if not isinstance(value, str) or not value:
        raise StoreError(f"{label} must be a non-empty string")
    if "\x00" in value:
        raise StoreError(f"{label} contains NUL")
    return value


def validate_timestamp(value: Any) -> str:
    text = require_text(value, "recordedAt")
    normalized = text[:-1] + "+00:00" if text.endswith("Z") else text
    try:
        parsed = dt.datetime.fromisoformat(normalized)
    except ValueError as exc:
        raise StoreError("recordedAt must be an ISO-8601 date-time") from exc
    if parsed.tzinfo is None:
        raise StoreError("recordedAt must include a timezone")
    return text


def validate_event(event: Any, proposal: bool = False) -> dict[str, Any]:
    fields = PROPOSAL_FIELDS if proposal else EVENT_FIELDS
    value = require_exact_fields(event, fields, "event proposal" if proposal else "event")
    if value["contractType"] != CONTRACT or value["schemaVersion"] != SCHEMA_VERSION:
        raise StoreError("event contractType/schemaVersion is unsupported")
    if value["eventType"] not in EVENT_TYPES:
        raise StoreError("eventType is outside the closed foundation vocabulary")
    if value["posture"] not in POSTURES:
        raise StoreError("posture is outside the closed foundation vocabulary")
    require_text(value["eventId"], "eventId")
    require_text(value["occurrenceId"], "occurrenceId")
    if value["attemptId"] is not None:
        require_text(value["attemptId"], "attemptId")
    validate_timestamp(value["recordedAt"])
    subject = require_exact_fields(value["subject"], SUBJECT_FIELDS, "subject")
    require_text(subject["kind"], "subject.kind")
    require_text(subject["id"], "subject.id")
    if not is_digest(value["objectDigest"]):
        raise StoreError("objectDigest must be a typed sha256 digest")
    supersedes = value["supersedesEventId"]
    if supersedes is not None:
        require_text(supersedes, "supersedesEventId")
    if value["eventType"] == "RECORD" and supersedes is not None:
        raise StoreError("RECORD must not supersede an event")
    if value["eventType"] != "RECORD" and supersedes is None:
        raise StoreError("CORRECT and SUPERSEDE must name supersedesEventId")
    if not isinstance(value["extensions"], list):
        raise StoreError("extensions must be an array")
    for index, extension in enumerate(value["extensions"]):
        item = require_exact_fields(extension, EXTENSION_FIELDS, f"extensions[{index}]")
        require_text(item["namespace"], f"extensions[{index}].namespace")
        if not isinstance(item["schemaVersion"], int) or isinstance(item["schemaVersion"], bool) or item["schemaVersion"] < 1:
            raise StoreError(f"extensions[{index}].schemaVersion must be a positive integer")
        if not is_digest(item["payloadDigest"]):
            raise StoreError(f"extensions[{index}].payloadDigest must be a typed sha256 digest")
    if not proposal:
        if not isinstance(value["sequence"], int) or isinstance(value["sequence"], bool) or value["sequence"] < 1:
            raise StoreError("sequence must be a positive integer")
        if not is_digest(value["previousEventDigest"]) or not is_digest(value["eventDigest"]):
            raise StoreError("event chain digests must be typed sha256 digests")
        expected = event_digest(value)
        if value["eventDigest"] != expected:
            raise StoreError("eventDigest does not match canonical typed event material")
    return value


def event_digest(event: dict[str, Any]) -> str:
    material = dict(event)
    material.pop("eventDigest", None)
    return typed_digest(CONTRACT, SCHEMA_VERSION, material)


def lexical_absolute(path_text: str, label: str) -> Path:
    require_text(path_text, label)
    path = Path(path_text)
    if not path.is_absolute():
        raise StoreError(f"{label} must be absolute")
    if ".." in path.parts:
        raise StoreError(f"{label} must not contain parent traversal")
    return path


def reject_symlink_chain(path: Path, allow_missing_tail: bool) -> None:
    parts = path.parts
    current = Path(parts[0])
    for part in parts[1:]:
        current = current / part
        try:
            metadata = os.lstat(current)
        except FileNotFoundError:
            if allow_missing_tail:
                return
            raise StoreError(f"required path is missing: {current.name}")
        if stat.S_ISLNK(metadata.st_mode):
            raise StoreError(f"symlink path component is forbidden: {current.name}")


def require_owned_private(path: Path, directory: bool) -> os.stat_result:
    metadata = os.lstat(path)
    if stat.S_ISLNK(metadata.st_mode):
        raise StoreError(f"symlink is forbidden: {path.name}")
    expected_kind = stat.S_ISDIR if directory else stat.S_ISREG
    if not expected_kind(metadata.st_mode):
        raise StoreError(f"special or wrong-kind filesystem node is forbidden: {path.name}")
    if metadata.st_uid != os.geteuid():
        raise StoreError(f"filesystem node has wrong owner: {path.name}")
    expected_mode = 0o700 if directory else 0o600
    if stat.S_IMODE(metadata.st_mode) != expected_mode:
        raise StoreError(f"filesystem node has non-private mode: {path.name}")
    return metadata


def ensure_directory(path: Path) -> None:
    if path.exists() or path.is_symlink():
        require_owned_private(path, True)
        return
    path.mkdir(mode=0o700)
    os.chmod(path, 0o700)
    require_owned_private(path, True)
    fsync_directory(path.parent)


def fsync_directory(path: Path) -> None:
    flags = os.O_RDONLY
    if hasattr(os, "O_DIRECTORY"):
        flags |= os.O_DIRECTORY
    descriptor = os.open(path, flags)
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)


def nofollow_flag() -> int:
    return getattr(os, "O_NOFOLLOW", 0)


def read_regular(path: Path) -> bytes:
    require_owned_private(path, False)
    descriptor = os.open(path, os.O_RDONLY | nofollow_flag())
    try:
        metadata = os.fstat(descriptor)
        if not stat.S_ISREG(metadata.st_mode) or metadata.st_uid != os.geteuid() or stat.S_IMODE(metadata.st_mode) != 0o600:
            raise StoreError(f"opened file failed private regular-file checks: {path.name}")
        chunks: list[bytes] = []
        while True:
            chunk = os.read(descriptor, 1024 * 1024)
            if not chunk:
                return b"".join(chunks)
            chunks.append(chunk)
    finally:
        os.close(descriptor)


def atomic_write(path: Path, data: bytes) -> None:
    reject_symlink_chain(path.parent, allow_missing_tail=False)
    require_owned_private(path.parent, True)
    if path.exists() or path.is_symlink():
        require_owned_private(path, False)
    temporary = path.parent / f".{path.name}.tmp.{os.getpid()}.{secrets.token_hex(8)}"
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | nofollow_flag()
    descriptor = os.open(temporary, flags, 0o600)
    try:
        os.fchmod(descriptor, 0o600)
        write_all(descriptor, data)
        os.fsync(descriptor)
    except BaseException:
        with contextlib.suppress(FileNotFoundError):
            temporary.unlink()
        raise
    finally:
        os.close(descriptor)
    os.replace(temporary, path)
    fsync_directory(path.parent)
    require_owned_private(path, False)


def write_all(descriptor: int, data: bytes) -> None:
    offset = 0
    while offset < len(data):
        written = os.write(descriptor, data[offset:])
        if written < 1:
            raise StoreError("file write made no progress")
        offset += written


def unlink_synced(path: Path) -> None:
    require_owned_private(path, False)
    path.unlink()
    fsync_directory(path.parent)


class Store:
    def __init__(self, root_text: str) -> None:
        self.root = lexical_absolute(root_text, "store-root")
        self.events = self.root / "events.jsonl"
        self.head = self.root / "head.json"
        self.pending = self.root / "pending.json"
        self.objects = self.root / "objects"
        self.projections = self.root / "projections"
        self.lock_file = self.root / "lock"
        self.lock_dir = self.root / "lock.d"

    def prepare_root(self) -> None:
        reject_symlink_chain(self.root, allow_missing_tail=True)
        if not self.root.exists():
            self.root.mkdir(mode=0o700)
            os.chmod(self.root, 0o700)
            fsync_directory(self.root.parent)
        reject_symlink_chain(self.root, allow_missing_tail=False)
        require_owned_private(self.root, True)
        ensure_directory(self.objects)
        ensure_directory(self.projections)

    def ensure_layout_locked(self) -> None:
        for path in (self.root, self.objects, self.projections):
            require_owned_private(path, True)
        if not self.events.exists() and not self.events.is_symlink():
            atomic_write(self.events, b"")
        else:
            require_owned_private(self.events, False)
        if not self.head.exists() and not self.head.is_symlink():
            atomic_write(self.head, canonical_line(self.genesis_head()))
        else:
            require_owned_private(self.head, False)

    @staticmethod
    def genesis_head() -> dict[str, Any]:
        return {
            "contractType": "execution-control-head",
            "schemaVersion": 1,
            "sequence": 0,
            "eventDigest": GENESIS,
        }

    @contextlib.contextmanager
    def locked(self) -> Iterator[None]:
        self.prepare_root()
        try:
            import fcntl  # POSIX: Linux and macOS
        except ImportError:
            fcntl = None  # type: ignore[assignment]
        if fcntl is not None:
            if self.lock_file.exists() or self.lock_file.is_symlink():
                require_owned_private(self.lock_file, False)
            descriptor = os.open(self.lock_file, os.O_RDWR | os.O_CREAT | nofollow_flag(), 0o600)
            os.fchmod(descriptor, 0o600)
            deadline = time.monotonic() + LOCK_WAIT_SECONDS
            try:
                while True:
                    try:
                        fcntl.flock(descriptor, fcntl.LOCK_EX | fcntl.LOCK_NB)
                        break
                    except BlockingIOError:
                        if time.monotonic() >= deadline:
                            raise StoreError("timed out acquiring execution-control lock")
                        time.sleep(0.02)
                self.ensure_layout_locked()
                yield
            finally:
                with contextlib.suppress(OSError):
                    fcntl.flock(descriptor, fcntl.LOCK_UN)
                os.close(descriptor)
            return
        with self.mkdir_lock():
            self.ensure_layout_locked()
            yield

    @contextlib.contextmanager
    def mkdir_lock(self) -> Iterator[None]:
        deadline = time.monotonic() + LOCK_WAIT_SECONDS
        token = secrets.token_hex(16)
        owner_path = self.lock_dir / "owner.json"
        while True:
            try:
                self.lock_dir.mkdir(mode=0o700)
                os.chmod(self.lock_dir, 0o700)
                atomic_write(owner_path, canonical_line({"pid": os.getpid(), "token": token}))
                break
            except FileExistsError:
                require_owned_private(self.lock_dir, True)
                judged = self.lock_identity(owner_path)
                if judged is not None and not process_alive(judged[1]):
                    current = self.lock_identity(owner_path)
                    if current == judged:
                        claim = self.root / f"lock.stale.{os.getpid()}.{secrets.token_hex(8)}"
                        try:
                            os.replace(self.lock_dir, claim)
                        except OSError:
                            pass
                        else:
                            remove_lock_claim(claim)
                            continue
                if time.monotonic() >= deadline:
                    raise StoreError("timed out acquiring mkdir execution-control lock")
                time.sleep(0.02)
        try:
            yield
        finally:
            current = self.lock_identity(owner_path)
            if current is not None and current[2] == token:
                unlink_synced(owner_path)
                self.lock_dir.rmdir()
                fsync_directory(self.root)

    def lock_identity(self, owner_path: Path) -> tuple[int, int, str] | None:
        try:
            inode = require_owned_private(self.lock_dir, True).st_ino
            owner = strict_read_json(owner_path)
        except (FileNotFoundError, StoreError):
            return None
        if not isinstance(owner, dict) or set(owner) != {"pid", "token"}:
            raise StoreError("mkdir lock owner record is malformed")
        pid = owner["pid"]
        token = owner["token"]
        if not isinstance(pid, int) or isinstance(pid, bool) or pid < 1 or not isinstance(token, str) or not token:
            raise StoreError("mkdir lock owner identity is malformed")
        return inode, pid, token

    def load_head(self) -> dict[str, Any]:
        value = require_exact_fields(strict_read_json(self.head), HEAD_FIELDS, "head")
        if value["contractType"] != "execution-control-head" or value["schemaVersion"] != 1:
            raise StoreError("head contract is unsupported")
        if not isinstance(value["sequence"], int) or isinstance(value["sequence"], bool) or value["sequence"] < 0:
            raise StoreError("head sequence is invalid")
        if not is_digest(value["eventDigest"]):
            raise StoreError("head digest is invalid")
        return value

    def load_events(self) -> list[dict[str, Any]]:
        raw = read_regular(self.events)
        if raw and not raw.endswith(b"\n"):
            raise StoreError("events ledger has a torn final line")
        events: list[dict[str, Any]] = []
        for line_number, line in enumerate(raw.splitlines(), 1):
            if not line:
                raise StoreError(f"events ledger has an empty line at {line_number}")
            events.append(validate_event(parse_json_bytes(line, f"events line {line_number}")))
        return events

    def recover_pending(self) -> None:
        if not self.pending.exists() and not self.pending.is_symlink():
            return
        pending = require_exact_fields(strict_read_json(self.pending), PENDING_FIELDS, "pending")
        if pending["contractType"] != "execution-control-pending" or pending["schemaVersion"] != 1:
            raise StoreError("pending contract is unsupported")
        expected_sequence = pending["expectedSequence"]
        expected_digest = pending["expectedHeadDigest"]
        event = validate_event(pending["event"])
        if not isinstance(expected_sequence, int) or isinstance(expected_sequence, bool) or expected_sequence < 0 or not is_digest(expected_digest):
            raise StoreError("pending predecessor is invalid")
        if event["sequence"] != expected_sequence + 1 or event["previousEventDigest"] != expected_digest:
            raise StoreError("pending event does not match its predecessor")
        events = self.load_events()
        head = self.load_head()
        tip_sequence = events[-1]["sequence"] if events else 0
        tip_digest = events[-1]["eventDigest"] if events else GENESIS
        if tip_sequence == expected_sequence and tip_digest == expected_digest and head == {
            "contractType": "execution-control-head",
            "schemaVersion": 1,
            "sequence": expected_sequence,
            "eventDigest": expected_digest,
        }:
            unlink_synced(self.pending)
            return
        exact_tip = bool(events) and canonical_bytes(events[-1]) == canonical_bytes(event)
        if exact_tip and tip_sequence == event["sequence"] and tip_digest == event["eventDigest"]:
            expected_old_head = {
                "contractType": "execution-control-head",
                "schemaVersion": 1,
                "sequence": expected_sequence,
                "eventDigest": expected_digest,
            }
            new_head = {
                "contractType": "execution-control-head",
                "schemaVersion": 1,
                "sequence": event["sequence"],
                "eventDigest": event["eventDigest"],
            }
            if head == expected_old_head:
                atomic_write(self.head, canonical_line(new_head))
            elif head != new_head:
                raise StoreError("pending recovery found a conflicting head")
            unlink_synced(self.pending)
            return
        raise StoreError("pending recovery found an impossible ledger/head combination")

    def verify_locked(self) -> dict[str, Any]:
        self.recover_pending()
        events = self.load_events()
        previous = GENESIS
        event_ids: set[str] = set()
        attempt_ids: set[str] = set()
        known_event_ids: set[str] = set()
        for index, event in enumerate(events, 1):
            if event["sequence"] != index:
                raise StoreError("events ledger has a sequence gap or reorder")
            if event["previousEventDigest"] != previous:
                raise StoreError("events ledger predecessor chain is invalid")
            if event["eventId"] in event_ids:
                raise StoreError("eventId is not unique")
            event_ids.add(event["eventId"])
            attempt = event["attemptId"]
            if attempt is not None:
                if attempt in attempt_ids:
                    raise StoreError("attemptId is not distinct per physical execution")
                attempt_ids.add(attempt)
            supersedes = event["supersedesEventId"]
            if supersedes is not None and supersedes not in known_event_ids:
                raise StoreError("supersedesEventId does not name an earlier event")
            self.require_object(event["objectDigest"])
            for extension in event["extensions"]:
                self.require_object(extension["payloadDigest"])
            known_event_ids.add(event["eventId"])
            previous = event["eventDigest"]
        head = self.load_head()
        expected_head = {
            "contractType": "execution-control-head",
            "schemaVersion": 1,
            "sequence": len(events),
            "eventDigest": previous,
        }
        if head != expected_head:
            raise StoreError("head is rolled back, ahead, or inconsistent with ledger tip")
        object_count = self.verify_all_objects()
        return {
            "contractType": "execution-control-verification",
            "schemaVersion": 1,
            "eventCount": len(events),
            "headDigest": previous,
            "objectCount": object_count,
            "verified": True,
        }

    def object_path(self, digest: str) -> Path:
        if not is_digest(digest):
            raise StoreError("object digest is invalid")
        hexadecimal = digest[len(DIGEST_PREFIX) :]
        return self.objects / hexadecimal[:2] / hexadecimal

    def require_object(self, digest: str) -> Any:
        path = self.object_path(digest)
        value = strict_read_json(path)
        if typed_digest(OBJECT_CONTRACT, 1, value) != digest:
            raise StoreError("object bytes do not match content address")
        if canonical_line(value) != read_regular(path):
            raise StoreError("object is not persisted as canonical JSON plus LF")
        return value

    def verify_all_objects(self) -> int:
        count = 0
        for prefix in sorted(self.objects.iterdir(), key=lambda item: item.name):
            require_owned_private(prefix, True)
            if len(prefix.name) != 2 or any(character not in "0123456789abcdef" for character in prefix.name):
                raise StoreError("object prefix directory is invalid")
            for path in sorted(prefix.iterdir(), key=lambda item: item.name):
                require_owned_private(path, False)
                digest = DIGEST_PREFIX + path.name
                if path.name[:2] != prefix.name or not is_digest(digest):
                    raise StoreError("object filename is not a valid content address")
                self.require_object(digest)
                count += 1
        return count

    def put_object_locked(self, input_path: Path) -> dict[str, Any]:
        value = parse_json_bytes(read_external_regular(input_path), "object input")
        digest = typed_digest(OBJECT_CONTRACT, 1, value)
        path = self.object_path(digest)
        ensure_directory(path.parent)
        stored = False
        if path.exists() or path.is_symlink():
            existing = self.require_object(digest)
            if canonical_bytes(existing) != canonical_bytes(value):
                raise StoreError("content-address collision or substitution")
        else:
            atomic_write(path, canonical_line(value))
            stored = True
        return {"objectDigest": digest, "stored": stored}

    def append_locked(self, expected_sequence: int, expected_digest: str, event_path: Path) -> dict[str, Any]:
        self.recover_pending()
        self.verify_locked()
        head = self.load_head()
        if head["sequence"] != expected_sequence or head["eventDigest"] != expected_digest:
            raise StoreError("compare-and-append predecessor is stale")
        proposal = validate_event(parse_json_bytes(read_external_regular(event_path), "event proposal"), proposal=True)
        events = self.load_events()
        if proposal["eventId"] in {event["eventId"] for event in events}:
            raise StoreError("eventId already exists")
        if proposal["attemptId"] is not None and proposal["attemptId"] in {event["attemptId"] for event in events}:
            raise StoreError("attemptId already exists")
        supersedes = proposal["supersedesEventId"]
        if supersedes is not None and supersedes not in {event["eventId"] for event in events}:
            raise StoreError("supersedesEventId does not name an earlier event")
        self.require_object(proposal["objectDigest"])
        for extension in proposal["extensions"]:
            self.require_object(extension["payloadDigest"])
        event = dict(proposal)
        event["sequence"] = expected_sequence + 1
        event["previousEventDigest"] = expected_digest
        event["eventDigest"] = event_digest(event)
        event = validate_event(event)
        pending = {
            "contractType": "execution-control-pending",
            "schemaVersion": 1,
            "expectedSequence": expected_sequence,
            "expectedHeadDigest": expected_digest,
            "event": event,
        }
        atomic_write(self.pending, canonical_line(pending))
        descriptor = os.open(self.events, os.O_WRONLY | os.O_APPEND | nofollow_flag())
        try:
            write_all(descriptor, canonical_line(event))
            os.fsync(descriptor)
        finally:
            os.close(descriptor)
        new_head = {
            "contractType": "execution-control-head",
            "schemaVersion": 1,
            "sequence": event["sequence"],
            "eventDigest": event["eventDigest"],
        }
        atomic_write(self.head, canonical_line(new_head))
        unlink_synced(self.pending)
        return event

    def projection_locked(self) -> dict[str, Any]:
        verification = self.verify_locked()
        events = self.load_events()
        event_type_counts = {name: 0 for name in sorted(EVENT_TYPES)}
        posture_counts = {name: 0 for name in sorted(POSTURES)}
        for event in events:
            event_type_counts[event["eventType"]] += 1
            posture_counts[event["posture"]] += 1
        projection = {
            "contractType": PROJECTION_CONTRACT,
            "schemaVersion": 1,
            "eventCount": verification["eventCount"],
            "eventTypeCounts": event_type_counts,
            "headDigest": verification["headDigest"],
            "objectCount": verification["objectCount"],
            "postureCounts": posture_counts,
        }
        atomic_write(self.projections / "integrity.json", canonical_line(projection))
        return projection


def read_external_regular(path: Path) -> bytes:
    reject_symlink_chain(path, allow_missing_tail=False)
    metadata = os.lstat(path)
    if stat.S_ISLNK(metadata.st_mode) or not stat.S_ISREG(metadata.st_mode):
        raise StoreError(f"input must be a regular non-symlink file: {path.name}")
    descriptor = os.open(path, os.O_RDONLY | nofollow_flag())
    try:
        chunks: list[bytes] = []
        while True:
            chunk = os.read(descriptor, 1024 * 1024)
            if not chunk:
                return b"".join(chunks)
            chunks.append(chunk)
    finally:
        os.close(descriptor)


def process_alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    return True


def remove_lock_claim(claim: Path) -> None:
    owner = claim / "owner.json"
    if owner.exists():
        require_owned_private(owner, False)
        owner.unlink()
    require_owned_private(claim, True)
    claim.rmdir()
    fsync_directory(claim.parent)


def safe_output(path_text: str, data: bytes) -> None:
    path = lexical_absolute(path_text, "output")
    reject_symlink_chain(path.parent, allow_missing_tail=False)
    if path.exists() or path.is_symlink():
        metadata = os.lstat(path)
        if stat.S_ISLNK(metadata.st_mode) or not stat.S_ISREG(metadata.st_mode):
            raise StoreError("projection output must be a regular non-symlink file")
        if metadata.st_uid != os.geteuid():
            raise StoreError("projection output has wrong owner")
    temporary = path.parent / f".{path.name}.tmp.{os.getpid()}.{secrets.token_hex(8)}"
    descriptor = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_EXCL | nofollow_flag(), 0o600)
    try:
        os.fchmod(descriptor, 0o600)
        write_all(descriptor, data)
        os.fsync(descriptor)
    except BaseException:
        with contextlib.suppress(FileNotFoundError):
            temporary.unlink()
        raise
    finally:
        os.close(descriptor)
    os.replace(temporary, path)
    fsync_directory(path.parent)
    os.chmod(path, 0o600)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Bubbles execution-control store")
    subparsers = parser.add_subparsers(dest="command", required=True)

    object_put = subparsers.add_parser("object-put")
    object_put.add_argument("--store-root", required=True)
    object_put.add_argument("--input", required=True)

    append = subparsers.add_parser("append")
    append.add_argument("--store-root", required=True)
    append.add_argument("--expected-sequence", required=True, type=int)
    append.add_argument("--expected-head-digest", required=True)
    append.add_argument("--event-file", required=True)

    read = subparsers.add_parser("read")
    read.add_argument("--store-root", required=True)
    read.add_argument("--from-sequence", required=True, type=int)
    read.add_argument("--limit", required=True, type=int)

    verify = subparsers.add_parser("verify")
    verify.add_argument("--store-root", required=True)

    project = subparsers.add_parser("project")
    project.add_argument("--store-root", required=True)
    project.add_argument("--output", required=True)
    return parser


def execute(arguments: argparse.Namespace) -> dict[str, Any]:
    store = Store(arguments.store_root)
    if arguments.command == "object-put":
        with store.locked():
            store.recover_pending()
            store.verify_locked()
            return store.put_object_locked(lexical_absolute(arguments.input, "input"))
    if arguments.command == "append":
        if arguments.expected_sequence < 0:
            raise StoreError("expected-sequence must be non-negative")
        if not is_digest(arguments.expected_head_digest):
            raise StoreError("expected-head-digest must be a typed sha256 digest")
        with store.locked():
            return store.append_locked(
                arguments.expected_sequence,
                arguments.expected_head_digest,
                lexical_absolute(arguments.event_file, "event-file"),
            )
    if arguments.command == "read":
        if arguments.from_sequence < 1 or arguments.limit < 1:
            raise StoreError("from-sequence and limit must be positive")
        with store.locked():
            verification = store.verify_locked()
            selected = [event for event in store.load_events() if event["sequence"] >= arguments.from_sequence][: arguments.limit]
            return {
                "contractType": "execution-control-read",
                "schemaVersion": 1,
                "events": selected,
                "headDigest": verification["headDigest"],
            }
    if arguments.command == "verify":
        with store.locked():
            return store.verify_locked()
    if arguments.command == "project":
        with store.locked():
            projection = store.projection_locked()
        safe_output(arguments.output, canonical_line(projection))
        return projection
    raise StoreError("unsupported command")


def main() -> int:
    parser = build_parser()
    try:
        result = execute(parser.parse_args())
        sys.stdout.buffer.write(canonical_line(result))
        sys.stdout.buffer.flush()
        return 0
    except (StoreError, OSError) as exc:
        print(f"execution-control-store: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
