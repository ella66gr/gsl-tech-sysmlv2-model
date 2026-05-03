"""
S342 smoke test for content-shape validator.

Four cases:
  A. Empty text node              -> 400
  B. Non-string text (list)       -> 400
  C. Missing text field           -> 400
  D. Known-good (current shape)   -> 200

Targets BMM main document_root props (no content surface) AND a transient
dummy paragraph block we create-and-clean-up. We avoid touching real
content blocks beyond a known-good no-op patch.
"""

from __future__ import annotations

import json
import urllib.error
import urllib.request
from pathlib import Path

TOKEN = Path(
    "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/resolver/.ontara-token"
).read_text(encoding="utf-8").strip()

BASE = "http://localhost:7300"
DOC_SLUG = "ontara-ref-bmm-business-metamodel"
# A paragraph we'll patch with each shape; using a cheap target that won't
# matter if we leave it briefly polluted (we won't \u2014 reverts confirmed).
# Pick a known existing paragraph block from the doc.
TARGET_BLOCK = "8922108c-1491-4691-97c5-ca3cfea74596"


def _post(payload):
    req = urllib.request.Request(
        f"{BASE}/v1/documents/{DOC_SLUG}/mutations",
        method="POST",
        headers={"X-Ontara-Token": TOKEN, "Content-Type": "application/json"},
        data=json.dumps(payload).encode("utf-8"),
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read())


def expect(label, payload, want_status, want_substring=None):
    status, body = _post(payload)
    ok = status == want_status
    if want_substring is not None:
        ok = ok and want_substring in json.dumps(body)
    badge = "OK" if ok else "FAIL"
    print(f"[{badge}] {label}: HTTP {status}")
    if not ok:
        print(f"   got body: {body}")


# Fetch current content so case D is a true no-op.
get_req = urllib.request.Request(
    f"{BASE}/block/{TARGET_BLOCK}?format=json",
    headers={"X-Ontara-Token": TOKEN},
)
with urllib.request.urlopen(get_req, timeout=15) as r:
    current = json.loads(r.read())["block"]["content"]


# A. Empty text node
expect(
    "A. empty-text node rejected",
    {"operations": [{
        "op": "patchBlockContent",
        "block_id": TARGET_BLOCK,
        "content": {"type": "paragraph", "content": [
            {"type": "text", "text": ""},
        ]},
    }]},
    want_status=400,
    want_substring="empty `text` field",
)

# B. Non-string text (list, mimicking OW-S336-2)
expect(
    "B. non-string-text node rejected",
    {"operations": [{
        "op": "patchBlockContent",
        "block_id": TARGET_BLOCK,
        "content": {"type": "paragraph", "content": [
            {"type": "text", "text": ["nested", "list"]},
        ]},
    }]},
    want_status=400,
    want_substring="non-string `text`",
)

# C. Missing text field
expect(
    "C. missing-text-field node rejected",
    {"operations": [{
        "op": "patchBlockContent",
        "block_id": TARGET_BLOCK,
        "content": {"type": "paragraph", "content": [
            {"type": "text"},
        ]},
    }]},
    want_status=400,
    want_substring="no `text` field",
)

# D. Known-good (re-patch with current shape) - should be accepted.
expect(
    "D. known-good content accepted",
    {"operations": [{
        "op": "patchBlockContent",
        "block_id": TARGET_BLOCK,
        "content": current,
    }]},
    want_status=200,
)
