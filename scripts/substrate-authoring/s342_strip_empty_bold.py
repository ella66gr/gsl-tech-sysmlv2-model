"""
S342 OW-S336-3 first-load fix: strip empty-text bold node from paragraph
8922108c-1491-4691-97c5-ca3cfea74596 in BMM main substrate document.

Tiptap's PM schema rejects empty text nodes (RangeError: Empty text nodes
are not allowed); a single such node anywhere in a doc blocks the entire
editor mount. The offender originated as a `****` artefact in the v6
markdown source for the D32 bullet in S6.2 'Pattern findings since v5'.
"""

from __future__ import annotations

import json
import urllib.request
from pathlib import Path

TOKEN = Path(
    "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/resolver/.ontara-token"
).read_text(encoding="utf-8").strip()

BASE = "http://localhost:7300"
DOC_SLUG = "ontara-ref-bmm-business-metamodel"
BLOCK_ID = "8922108c-1491-4691-97c5-ca3cfea74596"

# Fetch current content to preserve everything except the empty-bold node.
req = urllib.request.Request(
    f"{BASE}/block/{BLOCK_ID}?format=json",
    headers={"X-Ontara-Token": TOKEN},
)
with urllib.request.urlopen(req, timeout=15) as r:
    block = json.loads(r.read())

content = block["block"]["content"]
inline = content["content"]

# Strip empty-text nodes. Defensive: also strip any other empty text nodes
# anywhere in this paragraph, in case there are siblings of the same shape.
filtered = [
    n for n in inline
    if not (n.get("type") == "text" and n.get("text", "") == "")
]

stripped = len(inline) - len(filtered)
print(f"Stripped {stripped} empty text node(s).")

new_content = {"type": "paragraph", "content": filtered}

payload = {
    "operations": [
        {"op": "patchBlockContent", "block_id": BLOCK_ID, "content": new_content},
    ],
}

post_req = urllib.request.Request(
    f"{BASE}/v1/documents/{DOC_SLUG}/mutations",
    method="POST",
    headers={"X-Ontara-Token": TOKEN, "Content-Type": "application/json"},
    data=json.dumps(payload).encode("utf-8"),
)

with urllib.request.urlopen(post_req, timeout=30) as r:
    print(json.dumps(json.loads(r.read()), indent=2))
