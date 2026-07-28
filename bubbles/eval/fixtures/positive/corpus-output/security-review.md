# Security review — submission path

### Finding 1 — unbounded request body

**Claim Source:** interpreted

Read `server/routes.py`; the submit handler does not bound the request body
before parsing. No proof-of-concept was run, so this is inferred from code.

### Finding 2 — limit bypass via negative count

**Claim Source:** executed

Reproduced against the local unit harness.

```text
$ python3 tools/probe_limits.py --count -1
accepted: True   <-- expected rejection
Exit Code: 0
```
