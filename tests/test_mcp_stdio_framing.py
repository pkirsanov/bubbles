#!/usr/bin/env python3
"""Adversarial regression test for the MCP stdio transport framing fix.

Proves the Bubbles MCP server speaks NEWLINE-DELIMITED JSON-RPC on stdio
(one JSON object per line, terminated by ``\\n`` — the framing VS Code
actually sends), while still accepting a legacy LSP-style ``Content-Length``
header block on read for back-compat.

Why these are adversarial (they FAIL against the pre-fix server, which used
``Content-Length`` header framing for BOTH read and write, and PASS only with
the fix):

  (a) ``test_newline_delimited_object_parses`` — the pre-fix ``read_message``
      treated the JSON line as an HTTP header block, never found
      ``Content-Length``, looped to ``readline()`` and returned ``None`` on
      EOF. Asserting it returns the parsed dict fails the old code.
  (b) ``test_writes_newline_terminated_json_without_header`` — the pre-fix
      ``write_message`` prepended ``Content-Length: <n>\\r\\n\\r\\n`` and did
      not terminate with ``\\n``. Asserting NO ``Content-Length`` substring
      and a trailing ``\\n`` fails the old code.
  (c) ``test_content_length_backcompat`` — guards the back-compat read path
      so the fix cannot silently drop legacy framing.
  (d) ``test_newline_framed_handshake_lists_ten_tools`` — drives the real
      server as a subprocess over stdio with NEWLINE framing
      (initialize -> notifications/initialized -> tools/list). The pre-fix
      server never replied (it blocked on the unparsable header), so the hard
      15s subprocess timeout fails the test instead of hanging the suite.

The server under test defaults to the canonical
``bubbles/mcp/server.py`` but can be pointed at a vendored copy via the
``BUBBLES_MCP_SERVER_PATH`` environment variable (used to verify the
propagated product-repo copies with the identical suite).

Run: ``python3 tests/test_mcp_stdio_framing.py``
"""

import importlib.util
import io
import json
import os
import subprocess
import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SERVER = REPO_ROOT / "bubbles" / "mcp" / "server.py"
SERVER_PATH = Path(
    os.environ.get("BUBBLES_MCP_SERVER_PATH", str(DEFAULT_SERVER))
).resolve()

# The full v6/A5 tool catalog the MCP server exposes (bash twins under
# bubbles/scripts/). tools/list MUST return exactly these names.
EXPECTED_TOOLS = {
    "check_gate",
    "list_open_findings",
    "query_tool_log",
    "read_spec",
    "record_evidence",
    "resolve_mode",
    "route_finding",
    "search_code",
    "validate_dod",
    "verify_status_transition",
}


def _load_server_module(path: Path):
    """Import the server module by path (it is not an installed package)."""
    spec = importlib.util.spec_from_file_location(
        "bubbles_mcp_server_under_test", str(path)
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


_server = _load_server_module(SERVER_PATH)
StdioTransport = _server.StdioTransport


def _encode(msg: dict) -> bytes:
    """Encode a JSON-RPC message the way an MCP stdio client frames it."""
    return (json.dumps(msg, separators=(",", ":")) + "\n").encode("utf-8")


class ReadMessageTests(unittest.TestCase):
    def test_newline_delimited_object_parses(self):  # (a)
        msg = {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}}
        transport = StdioTransport(io.BytesIO(_encode(msg)), io.BytesIO())
        self.assertEqual(transport.read_message(), msg)

    def test_blank_lines_between_messages_skipped(self):
        msg = {"jsonrpc": "2.0", "id": 7, "method": "ping"}
        transport = StdioTransport(io.BytesIO(b"\n\n" + _encode(msg)), io.BytesIO())
        self.assertEqual(transport.read_message(), msg)

    def test_eof_returns_none(self):
        transport = StdioTransport(io.BytesIO(b""), io.BytesIO())
        self.assertIsNone(transport.read_message())

    def test_content_length_backcompat(self):  # (c)
        msg = {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}}
        body = json.dumps(msg, separators=(",", ":")).encode("utf-8")
        wire = b"Content-Length: %d\r\n\r\n" % len(body) + body
        transport = StdioTransport(io.BytesIO(wire), io.BytesIO())
        self.assertEqual(transport.read_message(), msg)


class WriteMessageTests(unittest.TestCase):
    def test_writes_newline_terminated_json_without_header(self):  # (b)
        writer = io.BytesIO()
        msg = {"jsonrpc": "2.0", "id": 1, "result": {"ok": True}}
        StdioTransport(io.BytesIO(), writer).write_message(msg)
        out = writer.getvalue()
        self.assertTrue(out.endswith(b"\n"), repr(out))
        self.assertNotIn(b"Content-Length", out)
        self.assertEqual(json.loads(out.rstrip(b"\n").decode("utf-8")), msg)

    def test_write_read_roundtrip(self):
        buf = io.BytesIO()
        StdioTransport(io.BytesIO(), buf).write_message(
            {"jsonrpc": "2.0", "id": 9, "result": {}}
        )
        buf.seek(0)
        self.assertEqual(
            StdioTransport(buf, io.BytesIO()).read_message(),
            {"jsonrpc": "2.0", "id": 9, "result": {}},
        )


class FullHandshakeTests(unittest.TestCase):
    def test_newline_framed_handshake_lists_ten_tools(self):  # (d)
        msgs = [
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {},
                    "clientInfo": {"name": "framing-test", "version": "0"},
                },
            },
            {"jsonrpc": "2.0", "method": "notifications/initialized"},
            {"jsonrpc": "2.0", "id": 2, "method": "tools/list"},
        ]
        stdin_bytes = b"".join(_encode(m) for m in msgs)
        proc = subprocess.Popen(
            [sys.executable, str(SERVER_PATH)],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=dict(os.environ, BUBBLES_MCP_LOG_LEVEL="ERROR"),
        )
        try:
            out, err = proc.communicate(input=stdin_bytes, timeout=15)
        except subprocess.TimeoutExpired:
            proc.kill()
            out, err = proc.communicate()
            self.fail(
                "server did not reply within 15s "
                "(newline-framing regression?)\n"
                f"stderr:\n{err.decode('utf-8', 'replace')}"
            )
        replies = {}
        for raw in out.splitlines():
            raw = raw.strip()
            if not raw:
                continue
            try:
                obj = json.loads(raw.decode("utf-8"))
            except (ValueError, UnicodeDecodeError):
                continue
            if isinstance(obj, dict) and "id" in obj:
                replies[obj["id"]] = obj
        self.assertIn(1, replies, f"no initialize reply; stdout={out!r} stderr={err!r}")
        self.assertIn("result", replies[1], replies[1])
        self.assertIn(2, replies, f"no tools/list reply; stdout={out!r} stderr={err!r}")
        names = {tool["name"] for tool in replies[2]["result"]["tools"]}
        self.assertEqual(names, EXPECTED_TOOLS, f"got {sorted(names)}")


if __name__ == "__main__":
    print(f"server under test: {SERVER_PATH}")
    unittest.main(verbosity=2)
