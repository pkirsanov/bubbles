#!/usr/bin/env bash

[[ -n "${_BUBBLES_G073_SOURCE_STATE_SOURCED:-}" ]] && return 0
_BUBBLES_G073_SOURCE_STATE_SOURCED=1

_g073_source_state_python() {
  python3 - "$@" <<'PY'
import hashlib
import json
import os
import re
import stat
import subprocess
import sys


SOURCE_SUFFIX = re.compile(r"\.(go|rs|py|ts|tsx|js|jsx|sql|proto|yaml|yml|toml|json|css|scss|html)$")
ALLOWED_PATH = re.compile(r"^(specs/|docs/|\.github/|\.specify/|CHANGELOG|README|LICENSE|VERSION)")
SAFE_DIGEST = re.compile(r"^sha256:[0-9a-f]{64}$")
SAFE_OBJECT = re.compile(r"^[0-9a-f]{40,64}$")
SAFE_RUN = re.compile(r"^psb-[0-9a-f]{64}$")
SAFE_ARTIFACT = re.compile(r"^\.specify/runtime/planning-source-baselines/[0-9a-f]{64}\.json$")
STATE_CLASSES = {
    "STAGED_ONLY", "UNSTAGED_ONLY", "MIXED_STAGED_UNSTAGED",
    "UNTRACKED", "RENAME", "DELETE",
}
INDEX_STATUSES = {".", "A", "M", "D", "R", "T", "U"}
WORKTREE_STATUSES = {".", "A", "M", "D", "R", "T", "U", "?"}
IDENTITY_KINDS = {"REGULAR", "SYMLINK", "GITLINK", "ABSENT"}
IDENTITY_MODES = {"100644", "100755", "120000", "160000", "ABSENT"}


class SourceStateError(Exception):
    def __init__(self, reason):
        super().__init__(reason)
        self.reason = reason


def run_git(repo, *args, check=True):
    result = subprocess.run(
        ["git", "-C", repo, *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if check and result.returncode != 0:
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    return result


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def sha256_bytes(value):
    return "sha256:" + hashlib.sha256(value).hexdigest()


def classifier_digest():
    contract = (
        "g073-protected-path-universe/v1\n"
        "source_code_pattern=\\.(go|rs|py|ts|tsx|js|jsx|sql|proto|yaml|yml|toml|json|css|scss|html)$\n"
        "allowed_path_pattern=^(specs/|docs/|\\.github/|\\.specify/|CHANGELOG|README|LICENSE|VERSION)\n"
    )
    return sha256_bytes(contract.encode("ascii"))


def repository_id(repo):
    root = os.path.realpath(repo)
    common_raw = run_git(root, "rev-parse", "--git-common-dir").stdout.decode("utf-8").strip()
    if os.path.isabs(common_raw):
        common = os.path.realpath(common_raw)
    else:
        common = os.path.realpath(os.path.join(root, common_raw))
    material = "repositoryRoot\n{}\ngitCommonDir\n{}\n".format(root, common)
    return sha256_bytes(material.encode("utf-8"))


def is_safe_path(path):
    if not isinstance(path, str) or not path or len(path.encode("utf-8")) > 4096:
        return False
    if path.startswith("/") or path.startswith("./") or path.endswith("/"):
        return False
    if "\\" in path or "//" in path:
        return False
    if any(ord(char) < 32 or ord(char) == 127 for char in path):
        return False
    if any(char in path for char in "*?[]{}()^$|+"):
        return False
    parts = path.split("/")
    if any(part in ("", ".", "..") for part in parts):
        return False
    try:
        path.encode("utf-8").decode("utf-8")
    except UnicodeError:
        return False
    return True


def is_protected(path):
    return bool(SOURCE_SUFFIX.search(path)) and not bool(ALLOWED_PATH.match(path))


def absent_identity():
    return {
        "presence": "ABSENT",
        "kind": "ABSENT",
        "mode": "ABSENT",
        "gitObjectId": "ABSENT",
        "contentDigest": "ABSENT",
    }


def object_identity(repo, revision, path):
    result = run_git(repo, "ls-tree", "-z", revision, "--", path)
    if not result.stdout:
        return absent_identity()
    record = result.stdout.rstrip(b"\0")
    metadata, observed_path = record.split(b"\t", 1)
    mode, object_type, object_id = metadata.decode("ascii").split(" ", 2)
    if observed_path.decode("utf-8") != path:
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    if mode == "160000" or object_type == "commit":
        return {
            "presence": "PRESENT",
            "kind": "GITLINK",
            "mode": "160000",
            "gitObjectId": object_id,
            "contentDigest": sha256_bytes(object_id.encode("ascii")),
        }
    if mode == "120000":
        kind = "SYMLINK"
    elif mode in ("100644", "100755"):
        kind = "REGULAR"
    else:
        raise SourceStateError("BASELINE_TYPE_UNSUPPORTED")
    content = run_git(repo, "cat-file", "blob", object_id).stdout
    return {
        "presence": "PRESENT",
        "kind": kind,
        "mode": mode,
        "gitObjectId": object_id,
        "contentDigest": sha256_bytes(content),
    }


def index_identity(repo, path):
    result = run_git(repo, "ls-files", "--stage", "-z", "--", path)
    if not result.stdout:
        return absent_identity()
    records = [record for record in result.stdout.split(b"\0") if record]
    if len(records) != 1:
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    metadata, observed_path = records[0].split(b"\t", 1)
    mode, object_id, stage = metadata.decode("ascii").split(" ", 2)
    if stage != "0" or observed_path.decode("utf-8") != path:
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    if mode == "160000":
        kind = "GITLINK"
        digest = sha256_bytes(object_id.encode("ascii"))
    elif mode == "120000":
        kind = "SYMLINK"
        digest = sha256_bytes(run_git(repo, "cat-file", "blob", object_id).stdout)
    elif mode in ("100644", "100755"):
        kind = "REGULAR"
        digest = sha256_bytes(run_git(repo, "cat-file", "blob", object_id).stdout)
    else:
        raise SourceStateError("BASELINE_TYPE_UNSUPPORTED")
    return {
        "presence": "PRESENT",
        "kind": kind,
        "mode": mode,
        "gitObjectId": object_id,
        "contentDigest": digest,
    }


def worktree_identity(repo, path):
    absolute = os.path.join(repo, path)
    try:
        before = os.lstat(absolute)
    except FileNotFoundError:
        return absent_identity()
    if stat.S_ISLNK(before.st_mode):
        target = os.readlink(absolute)
        target_bytes = os.fsencode(target)
        kind = "SYMLINK"
        mode = "120000"
        content = target_bytes
    elif stat.S_ISREG(before.st_mode):
        kind = "REGULAR"
        mode = "100755" if before.st_mode & 0o111 else "100644"
        with open(absolute, "rb") as handle:
            content = handle.read()
    elif stat.S_ISDIR(before.st_mode):
        raise SourceStateError("BASELINE_TYPE_UNSUPPORTED")
    else:
        raise SourceStateError("BASELINE_TYPE_UNSUPPORTED")
    try:
        after = os.lstat(absolute)
    except FileNotFoundError:
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    before_tuple = (before.st_mode, before.st_size, before.st_mtime_ns, before.st_ino)
    after_tuple = (after.st_mode, after.st_size, after.st_mtime_ns, after.st_ino)
    if before_tuple != after_tuple:
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    object_id = run_git(repo, "hash-object", "--no-filters", "--", path).stdout.decode("ascii").strip()
    if not SAFE_OBJECT.match(object_id):
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    return {
        "presence": "PRESENT",
        "kind": kind,
        "mode": mode,
        "gitObjectId": object_id,
        "contentDigest": sha256_bytes(content),
    }


def relation_layer(index_status, worktree_status):
    index_changed = index_status != "."
    worktree_changed = worktree_status != "."
    if index_changed and worktree_changed:
        return "BOTH"
    if index_changed:
        return "INDEX"
    return "WORKTREE"


def build_entry(repo, start_head, path, index_status, worktree_status, old_path=None, similarity=None):
    if not is_safe_path(path) or (old_path is not None and not is_safe_path(old_path)):
        raise SourceStateError("BASELINE_PATH_UNSAFE")
    head = object_identity(repo, start_head, path)
    index = index_identity(repo, path)
    worktree = worktree_identity(repo, path)
    relation = None
    if old_path is not None:
        state_class = "RENAME"
        relation = {
            "kind": "RENAME",
            "layer": relation_layer(index_status, worktree_status),
            "oldPath": old_path,
            "newPath": path,
            "similarity": similarity or "R0",
            "oldEndpoint": {
                "head": object_identity(repo, start_head, old_path),
                "index": index_identity(repo, old_path),
                "worktree": worktree_identity(repo, old_path),
            },
            "newEndpoint": {"head": head, "index": index, "worktree": worktree},
        }
    elif index_status == "D" or worktree_status == "D":
        state_class = "DELETE"
        relation = {
            "kind": "DELETE",
            "layer": relation_layer(index_status, worktree_status),
            "deletedPath": path,
            "indexAbsent": index["presence"] == "ABSENT",
            "worktreeAbsent": worktree["presence"] == "ABSENT",
            "head": head,
            "index": index,
            "worktree": worktree,
        }
    elif index_status == "?" or worktree_status == "?":
        state_class = "UNTRACKED"
    elif index_status != "." and worktree_status != ".":
        state_class = "MIXED_STAGED_UNSTAGED"
    elif index_status != ".":
        state_class = "STAGED_ONLY"
    else:
        state_class = "UNSTAGED_ONLY"
    entry = {
        "stateClass": state_class,
        "path": path,
        "indexStatus": index_status,
        "worktreeStatus": worktree_status,
        "head": head,
        "index": index,
        "worktree": worktree,
        "worktreeMatchesIndex": worktree == index,
        "relation": relation,
    }
    entry["entryKey"] = sha256_bytes(canonical(entry).encode("utf-8"))
    return entry


def snapshot(repo, start_head):
    output = run_git(
        repo, "status", "--porcelain=v2", "-z", "--untracked-files=all",
        "--renames", "--",
    ).stdout
    records = output.split(b"\0")
    entries = []
    index = 0
    while index < len(records):
        record = records[index]
        index += 1
        if not record:
            continue
        record_type = record[:1]
        if record_type == b"1":
            parts = record.decode("utf-8").split(" ", 8)
            if len(parts) != 9:
                raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
            xy = parts[1]
            path = parts[8]
            if is_protected(path):
                entries.append(build_entry(repo, start_head, path, xy[0], xy[1]))
        elif record_type == b"2":
            parts = record.decode("utf-8").split(" ", 9)
            if len(parts) != 10 or index >= len(records):
                raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
            xy = parts[1]
            similarity = parts[8]
            path = parts[9]
            old_path = records[index].decode("utf-8")
            index += 1
            if is_protected(path) or is_protected(old_path):
                entries.append(build_entry(repo, start_head, path, xy[0], xy[1], old_path, similarity))
        elif record_type == b"?":
            path = record[2:].decode("utf-8")
            if is_protected(path):
                entries.append(build_entry(repo, start_head, path, ".", "?"))
        elif record_type == b"u":
            raise SourceStateError("BASELINE_STATUS_UNSUPPORTED")
        else:
            raise SourceStateError("BASELINE_STATUS_UNSUPPORTED")
    entries.sort(key=lambda item: (item["path"].encode("utf-8"), item["stateClass"], item["entryKey"]))
    return entries


def validate_identity(identity):
    if not isinstance(identity, dict):
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    required = {"presence", "kind", "mode", "gitObjectId", "contentDigest"}
    if not required.issubset(identity):
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    if identity["kind"] not in IDENTITY_KINDS:
        raise SourceStateError("BASELINE_TYPE_UNSUPPORTED")
    if identity["mode"] not in IDENTITY_MODES:
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    if identity["presence"] not in ("PRESENT", "ABSENT"):
        raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    if identity["presence"] == "ABSENT":
        if any(identity[field] != "ABSENT" for field in ("kind", "mode", "gitObjectId", "contentDigest")):
            raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
    else:
        if not SAFE_OBJECT.match(str(identity["gitObjectId"])):
            raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
        if not SAFE_DIGEST.match(str(identity["contentDigest"])):
            raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")


def validate_entries(entries):
    if not isinstance(entries, list):
        raise SourceStateError("BASELINE_REQUIRED_FIELD_MISSING")
    keys = set()
    identities = set()
    for entry in entries:
        if not isinstance(entry, dict):
            raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
        required = {
            "entryKey", "stateClass", "path", "indexStatus", "worktreeStatus",
            "head", "index", "worktree", "worktreeMatchesIndex", "relation",
        }
        if not required.issubset(entry):
            raise SourceStateError("BASELINE_REQUIRED_FIELD_MISSING")
        if entry["entryKey"] in keys or (entry["path"], canonical(entry.get("relation"))) in identities:
            raise SourceStateError("BASELINE_PATH_DUPLICATE")
        keys.add(entry["entryKey"])
        identities.add((entry["path"], canonical(entry.get("relation"))))
        if not is_safe_path(entry["path"]):
            raise SourceStateError("BASELINE_PATH_UNSAFE")
        if entry["stateClass"] not in STATE_CLASSES:
            raise SourceStateError("BASELINE_STATUS_UNSUPPORTED")
        if entry["indexStatus"] not in INDEX_STATUSES or entry["worktreeStatus"] not in WORKTREE_STATUSES:
            raise SourceStateError("BASELINE_STATUS_UNSUPPORTED")
        for field in ("head", "index", "worktree"):
            validate_identity(entry[field])
        if not isinstance(entry["worktreeMatchesIndex"], bool):
            raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
        relation = entry["relation"]
        if entry["stateClass"] == "RENAME":
            if not isinstance(relation, dict) or relation.get("kind") != "RENAME":
                raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
            for field in ("oldPath", "newPath"):
                if not is_safe_path(relation.get(field)):
                    raise SourceStateError("BASELINE_PATH_UNSAFE")
        elif entry["stateClass"] == "DELETE":
            if not isinstance(relation, dict) or relation.get("kind") != "DELETE":
                raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
        elif relation is not None:
            raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")


def load_and_validate(repo, feature_rel, mode, profile, contract_digest, state_file):
    try:
        with open(state_file, "r", encoding="utf-8") as handle:
            state = json.load(handle)
    except Exception:
        raise SourceStateError("BASELINE_REQUIRED_FIELD_MISSING")
    execution = state.get("execution")
    if not isinstance(execution, dict) or "planningSourceBaseline" not in execution:
        raise SourceStateError("BASELINE_ABSENT_LEGACY")
    reference = execution.get("planningSourceBaseline")
    required_ref = {
        "schemaVersion", "lifecycle", "runId", "artifactRef", "payloadDigest",
        "capturedAt", "featureDir", "workflowMode", "auditProfile",
        "repositoryId", "startHead", "transitionContractDigest",
    }
    if not isinstance(reference, dict) or not required_ref.issubset(reference):
        raise SourceStateError("BASELINE_REQUIRED_FIELD_MISSING")
    if reference["schemaVersion"] != "planning-source-baseline-ref/v1":
        raise SourceStateError("BASELINE_SCHEMA_UNSUPPORTED")
    if reference["lifecycle"] != "ACTIVE":
        raise SourceStateError("BASELINE_REQUIRED_FIELD_MISSING")
    if not SAFE_RUN.match(str(reference["runId"])):
        raise SourceStateError("BASELINE_RUN_BINDING_MISMATCH")
    if not SAFE_ARTIFACT.match(str(reference["artifactRef"])):
        raise SourceStateError("BASELINE_RUN_BINDING_MISMATCH")
    expected_artifact = ".specify/runtime/planning-source-baselines/{}.json".format(reference["runId"][4:])
    if reference["artifactRef"] != expected_artifact:
        raise SourceStateError("BASELINE_RUN_BINDING_MISMATCH")
    sidecar = os.path.join(repo, reference["artifactRef"])
    if not os.path.exists(sidecar):
        raise SourceStateError("BASELINE_SIDECAR_MISSING")
    try:
        sidecar_mode = stat.S_IMODE(os.stat(sidecar).st_mode)
        if sidecar_mode & 0o444 == 0:
            raise SourceStateError("BASELINE_PAYLOAD_UNREADABLE")
        with open(sidecar, "r", encoding="utf-8") as handle:
            envelope = json.load(handle)
    except SourceStateError:
        raise
    except PermissionError:
        raise SourceStateError("BASELINE_PAYLOAD_UNREADABLE")
    except (OSError, UnicodeError):
        raise SourceStateError("BASELINE_PAYLOAD_UNREADABLE")
    except json.JSONDecodeError:
        raise SourceStateError("BASELINE_PAYLOAD_MALFORMED")
    if not isinstance(envelope, dict) or envelope.get("schemaVersion") != "planning-source-baseline/v1":
        raise SourceStateError("BASELINE_SCHEMA_UNSUPPORTED")
    payload = envelope.get("payload")
    required_payload = {
        "runId", "capturedAt", "featureDir", "workflowMode", "auditProfile",
        "repositoryId", "startHead", "startTree", "transitionContractDigest",
        "captureTargetRevision", "protectedUniverse", "entries",
    }
    if not isinstance(payload, dict) or not required_payload.issubset(payload):
        raise SourceStateError("BASELINE_REQUIRED_FIELD_MISSING")
    validate_entries(payload["entries"])
    envelope_digest = envelope.get("payloadDigest")
    reference_digest = reference.get("payloadDigest")
    if not SAFE_DIGEST.match(str(envelope_digest)) or not SAFE_DIGEST.match(str(reference_digest)):
        raise SourceStateError("BASELINE_DIGEST_MISSING_OR_INVALID")
    computed = sha256_bytes(canonical(payload).encode("utf-8"))
    if computed != envelope_digest or computed != reference_digest:
        raise SourceStateError("BASELINE_DIGEST_MISMATCH")
    for field, reason in (
        ("featureDir", "BASELINE_SPEC_BINDING_MISMATCH"),
        ("workflowMode", "BASELINE_MODE_BINDING_MISMATCH"),
        ("auditProfile", "BASELINE_PROFILE_BINDING_MISMATCH"),
        ("repositoryId", "BASELINE_REPOSITORY_BINDING_MISMATCH"),
        ("runId", "BASELINE_RUN_BINDING_MISMATCH"),
        ("startHead", "BASELINE_START_HEAD_BINDING_MISMATCH"),
        ("transitionContractDigest", "BASELINE_TRANSITION_BINDING_MISMATCH"),
    ):
        if reference.get(field) != payload.get(field):
            raise SourceStateError(reason)
    if payload["featureDir"] != feature_rel:
        raise SourceStateError("BASELINE_SPEC_BINDING_MISMATCH")
    if payload["workflowMode"] != mode:
        raise SourceStateError("BASELINE_MODE_BINDING_MISMATCH")
    if payload["auditProfile"] != profile:
        raise SourceStateError("BASELINE_PROFILE_BINDING_MISMATCH")
    if payload["repositoryId"] != repository_id(repo):
        raise SourceStateError("BASELINE_REPOSITORY_BINDING_MISMATCH")
    if payload["transitionContractDigest"] != contract_digest:
        raise SourceStateError("BASELINE_TRANSITION_BINDING_MISMATCH")
    universe = payload["protectedUniverse"]
    if not isinstance(universe, dict) or universe.get("schemaVersion") != "g073-protected-path-universe/v1":
        raise SourceStateError("BASELINE_SCHEMA_UNSUPPORTED")
    if universe.get("classifierDigest") != classifier_digest():
        raise SourceStateError("BASELINE_TRANSITION_BINDING_MISMATCH")
    start_head = payload["startHead"]
    if not SAFE_OBJECT.match(str(start_head)):
        raise SourceStateError("BASELINE_START_HEAD_BINDING_MISMATCH")
    start_check = run_git(repo, "rev-parse", "--verify", start_head + "^{commit}", check=False)
    if start_check.returncode != 0:
        raise SourceStateError("BASELINE_START_HEAD_UNRESOLVED")
    start_tree = run_git(repo, "rev-parse", "--verify", start_head + "^{tree}").stdout.decode("ascii").strip()
    if payload["startTree"] != start_tree:
        raise SourceStateError("BASELINE_START_HEAD_BINDING_MISMATCH")
    ancestor = run_git(repo, "merge-base", "--is-ancestor", start_head, "HEAD", check=False)
    if ancestor.returncode != 0:
        raise SourceStateError("BASELINE_START_HEAD_BINDING_MISMATCH")
    return reference, envelope, sidecar


def detail(status, outcome, reason, path="NONE", state_class="NONE", actionability="ACTION_REQUIRED", observed=""):
    return {
        "gateId": "G073",
        "status": status,
        "applicability": "APPLICABLE",
        "scanDisposition": "CLASSIFIED",
        "phraseDisposition": "NONE",
        "outcome": outcome,
        "observed": observed,
        "required": "exact bound planning source baseline",
        "reasonCode": reason,
        "remediationCode": "REVIEW_SOURCE_STATE",
        "actionability": actionability,
        "evidenceIdentity": {
            "protectedPath": path,
            "stateClass": state_class,
        },
    }


def changed_reason(baseline, current):
    if baseline["stateClass"] == "RENAME" or current["stateClass"] == "RENAME":
        if baseline.get("relation") != current.get("relation"):
            return "PATH_RENAME_ENDPOINT_CHANGED"
    if baseline["stateClass"] == "DELETE" or current["stateClass"] == "DELETE":
        if baseline.get("relation") != current.get("relation"):
            return "PATH_DELETION_STATE_CHANGED"
    for identity_name in ("head", "index", "worktree"):
        left = baseline[identity_name]
        right = current[identity_name]
        if left.get("kind") != right.get("kind"):
            return "PATH_TYPE_CHANGED"
        if left.get("mode") != right.get("mode"):
            return "PATH_MODE_CHANGED"
    if baseline["indexStatus"] != current["indexStatus"] or baseline["index"] != current["index"]:
        return "PATH_INDEX_IDENTITY_CHANGED"
    if baseline["worktree"].get("contentDigest") != current["worktree"].get("contentDigest"):
        return "PATH_CONTENT_DIGEST_CHANGED"
    if baseline != current:
        return "PATH_CONTENT_DIGEST_CHANGED"
    return "PATH_AUDITED_EQUAL"


def committed_protected_paths(repo, start_head):
    current = run_git(repo, "rev-parse", "--verify", "HEAD^{commit}").stdout.decode("ascii").strip()
    if current == start_head:
        return []
    output = run_git(repo, "diff", "--name-status", "-z", "--find-renames", start_head + ".." + current, "--").stdout
    records = [record.decode("utf-8") for record in output.split(b"\0") if record]
    paths = []
    index = 0
    while index < len(records):
        status_code = records[index]
        index += 1
        if status_code.startswith("R"):
            if index + 1 >= len(records):
                raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
            old_path = records[index]
            new_path = records[index + 1]
            index += 2
            if is_protected(old_path) or is_protected(new_path):
                paths.append(new_path)
        else:
            if index >= len(records):
                raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
            path = records[index]
            index += 1
            if is_protected(path):
                paths.append(path)
    return sorted(set(paths), key=lambda value: value.encode("utf-8"))


def evaluate(repo, feature_rel, mode, profile, contract_digest, state_file):
    try:
        reference, envelope, _ = load_and_validate(repo, feature_rel, mode, profile, contract_digest, state_file)
        start_head = envelope["payload"]["startHead"]
        head_before = run_git(repo, "rev-parse", "--verify", "HEAD^{commit}").stdout.decode("ascii").strip()
        first = snapshot(repo, start_head)
        second = snapshot(repo, start_head)
        head_after = run_git(repo, "rev-parse", "--verify", "HEAD^{commit}").stdout.decode("ascii").strip()
        if head_before != head_after or canonical(first) != canonical(second):
            raise SourceStateError("BASELINE_ENTRY_IDENTITY_INVALID")
        baseline_entries = envelope["payload"]["entries"]
        current_entries = second
        details = []
        changed = False

        for path in committed_protected_paths(repo, start_head):
            details.append(detail("BLOCKED", "NEW_OR_CHANGED", "PATH_COMMITTED_AFTER_START_HEAD", path, "UNTRACKED"))
            changed = True

        baseline_by_path = {entry["path"]: entry for entry in baseline_entries}
        current_by_path = {entry["path"]: entry for entry in current_entries}
        handled_baseline = set()
        handled_current = set()

        baseline_renames = [entry for entry in baseline_entries if entry["stateClass"] == "RENAME"]
        current_renames = [entry for entry in current_entries if entry["stateClass"] == "RENAME"]
        for baseline in baseline_renames:
            old_path = baseline["relation"]["oldPath"]
            match = next((entry for entry in current_renames if entry["relation"]["oldPath"] == old_path), None)
            if match is not None and baseline["path"] != match["path"]:
                details.append(detail("BLOCKED", "NEW_OR_CHANGED", "PATH_RENAME_ENDPOINT_CHANGED", match["path"], "RENAME"))
                handled_baseline.add(baseline["path"])
                handled_current.add(match["path"])
                changed = True

        for path in sorted(set(baseline_by_path) | set(current_by_path), key=lambda value: value.encode("utf-8")):
            if path in handled_baseline or path in handled_current:
                continue
            baseline = baseline_by_path.get(path)
            current = current_by_path.get(path)
            if baseline is None:
                details.append(detail("BLOCKED", "NEW_OR_CHANGED", "PATH_APPEARED_AFTER_CAPTURE", path, current["stateClass"]))
                changed = True
            elif current is None:
                current_worktree = worktree_identity(repo, path)
                if baseline["worktree"].get("kind") == "SYMLINK" and baseline["worktree"].get("contentDigest") != current_worktree.get("contentDigest"):
                    reason = "PATH_CONTENT_DIGEST_CHANGED"
                elif baseline["worktree"].get("mode") != current_worktree.get("mode"):
                    reason = "PATH_MODE_CHANGED"
                else:
                    reason = "PATH_BECAME_CLEAN"
                details.append(detail("BLOCKED", "NEW_OR_CHANGED", reason, path, baseline["stateClass"]))
                changed = True
            else:
                reason = changed_reason(baseline, current)
                if reason == "PATH_AUDITED_EQUAL":
                    details.append(detail("PASS", "AUDITED_PREEXISTING", reason, path, baseline["stateClass"], "NON_ACTIONABLE"))
                else:
                    detail_state = baseline["stateClass"] if reason == "PATH_DELETION_STATE_CHANGED" else current["stateClass"]
                    details.append(detail("BLOCKED", "NEW_OR_CHANGED", reason, path, detail_state))
                    changed = True
        details.sort(key=lambda item: (
            item["evidenceIdentity"]["protectedPath"].encode("utf-8"),
            item["reasonCode"],
            item["evidenceIdentity"]["stateClass"],
        ))
        return {
            "status": "BLOCKED" if changed else "PASS",
            "outcome": "NEW_OR_CHANGED" if changed else "AUDITED_PREEXISTING",
            "reasonCode": "SOURCE_STATE_CHANGED" if changed else "SOURCE_STATE_EQUAL",
            "actionability": "ACTION_REQUIRED" if changed else "NON_ACTIONABLE",
            "observed": "changedCount={};auditedCount={}".format(
                sum(1 for item in details if item["status"] == "BLOCKED"),
                sum(1 for item in details if item["status"] == "PASS"),
            ),
            "details": details,
        }
    except SourceStateError as error:
        invalid = detail(
            "BLOCKED", "INVALID_BASELINE", error.reason,
            "NONE", "NONE", "ACTION_REQUIRED", "exclusionsApplied=0",
        )
        return {
            "status": "BLOCKED",
            "outcome": "INVALID_BASELINE",
            "reasonCode": error.reason,
            "actionability": "ACTION_REQUIRED",
            "observed": "exclusionsApplied=0",
            "details": [invalid],
        }


def main():
    operation = sys.argv[1]
    if operation == "snapshot":
        repo, start_head = sys.argv[2], sys.argv[3]
        print(canonical(snapshot(repo, start_head)), end="")
    elif operation == "classifier-digest":
        print(classifier_digest(), end="")
    elif operation == "repository-id":
        print(repository_id(sys.argv[2]), end="")
    elif operation == "validate":
        repo, feature_rel, mode, profile, contract_digest, state_file = sys.argv[2:8]
        try:
            reference, envelope, sidecar = load_and_validate(
                repo, feature_rel, mode, profile, contract_digest, state_file,
            )
            result = {
                "status": "VALID",
                "reasonCode": "BASELINE_VALID",
                "runId": reference["runId"],
                "payloadDigest": reference["payloadDigest"],
                "sidecar": sidecar,
                "protectedEntryCount": len(envelope["payload"]["entries"]),
            }
            print(canonical(result), end="")
        except SourceStateError as error:
            print(canonical({"status": "INVALID", "reasonCode": error.reason}), end="")
            sys.exit(1)
    elif operation == "evaluate":
        repo, feature_rel, mode, profile, contract_digest, state_file = sys.argv[2:8]
        print(canonical(evaluate(repo, feature_rel, mode, profile, contract_digest, state_file)), end="")
    else:
        raise SourceStateError("BASELINE_REQUIRED_FIELD_MISSING")


try:
    main()
except SourceStateError as error:
    print(error.reason, file=sys.stderr)
    sys.exit(1)
except Exception:
    print("BASELINE_ENTRY_IDENTITY_INVALID", file=sys.stderr)
    sys.exit(1)
PY
}

g073_source_state_snapshot() {
  _g073_source_state_python snapshot "$1" "$2"
}

g073_source_state_classifier_digest() {
  _g073_source_state_python classifier-digest
}

g073_source_state_repository_id() {
  _g073_source_state_python repository-id "$1"
}

g073_source_state_validate() {
  _g073_source_state_python validate "$@"
}

g073_source_state_evaluate() {
  _g073_source_state_python evaluate "$@"
}