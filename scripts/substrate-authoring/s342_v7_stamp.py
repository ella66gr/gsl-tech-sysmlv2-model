"""
S342 W-K close-out: v7 stamp on BMM main substrate document.

Two ops in one mutation:
  1. patchBlockContent on document_root: frontmatter version v6 -> v7, session -> 342.
  2. patchBlockContent on Version history table: prepend v7 row beneath header.

Per S342 implementation plan section 6.
"""

from __future__ import annotations

import json
import urllib.request
from pathlib import Path

TOKEN_PATH = Path(
    "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/resolver/.ontara-token"
)
TOKEN = TOKEN_PATH.read_text(encoding="utf-8").strip()

BASE = "http://localhost:7300"
DOC_SLUG = "ontara-ref-bmm-business-metamodel"
ROOT_BLOCK_ID = "3f54a1d0-3562-4487-9ddb-e790732466ee"
VERSION_HISTORY_TABLE_ID = "73498700-b09b-4141-a8dd-3344fa8d4d3e"


def _cell(text):
    return {
        "type": "tableCell",
        "content": [{"type": "paragraph", "content": [{"text": text, "type": "text"}]}],
    }


def _header(text):
    return {
        "type": "tableHeader",
        "content": [{"type": "paragraph", "content": [{"text": text, "type": "text"}]}],
    }


def _row(cells_text, header=False):
    factory = _header if header else _cell
    return {"type": "tableRow", "content": [factory(t) for t in cells_text]}


V7_SUMMARY = (
    "Substrate-canonical authoring milestone. Full-rewrite replacement of the "
    "v6 markdown source with the substrate-rendered output, paralleling the "
    "AP v5.3 -> v6 move at W-G close (S333). No content changes - v7 records "
    "the architectural fact that BMM main is now substrate-canonical with "
    "markdown as a rendered view. Render API gained a `path=` parameter at "
    "S342 enabling deliberate canonical placement; legacy `_substrate-rendered/` "
    "staging directory retired."
)

new_frontmatter = {
    "date": "2026-05-03",
    "tags": ["architecture", "foundations", "substrate"],
    "status": "current",
    "session": 342,
    "version": "v7",
    "abbreviation": "bmm",
}

existing_rows = [
    (
        "v6", "318",
        (
            "Full conceptual rewrite incorporating 57 sessions (S261\u2013S317). "
            "Document split into main + three sub-references. Terminology "
            "confirmed as General/Domain (BMG/BMD per architecture diagram "
            "v3.4.0); \"Tailored\" usage from v4\u2013v5 retired. RegulatoryTier "
            "replaced by RegulatoryShape (kind-based, S278); ProfessionalBody "
            "enum added (S278); DomainIdentity extended with "
            "professionalRegistrations, regulatedActivities, "
            "authorisationRequiredToTrade. Five demonstrators (Minds added at "
            "S281, W-107). Canonical-runtime annotations confirmed complete "
            "(S277/W-116). Cross-domain pattern findings updated (D32 four "
            "sharpenings; BP-09 four-domain validation; cadence-commitment-bound "
            "routing candidate; cross-band substrate-mediated handoff; "
            "reasoning-evaluator engagement at clinical band 1). Multi-tenant "
            "evidence for the multi-axis primitive replaces v5's single-tenant "
            "promise. Wikilink hygiene: master register (retired S294) "
            "references replaced with concept-graph notes / glossary fallbacks; "
            "deleted OW references pruned. Frontmatter staleness threshold "
            "aligned to canonical DCR (30 sessions)."
        ),
    ),
    (
        "v5", "261",
        (
            "Full conceptual rewrite incorporating S218\u2013S260. Eight-stratum "
            "architecture, FGZ, BRL, Substrate Reasoning stratum, "
            "canonical-runtime primitive, indistinguishability constraint "
            "integrated."
        ),
    ),
    (
        "v4", "218",
        (
            "Full conceptual rewrite against the strengthened A4. BMM "
            "reframed as metamodel-stratum business-side content."
        ),
    ),
    ("v3.1", "170", "Light touch-up: stale metrics updated."),
    ("v3", "154", "Major refresh incorporating S110\u2013S154."),
    ("v2.2", "110", "Targeted fixes: BSMM\u2192SMM rename."),
    ("v2.1", "82", "StakeholderModel added as sixth concern."),
    ("v2", "67", "Full revision under Ontara rebaselining."),
    ("v1", "~16", "Original document."),
]

new_table_content = {
    "type": "table",
    "content": [
        _row(["Version", "Session", "Summary of changes"], header=True),
        _row(["v7", "342", V7_SUMMARY]),
        *[_row([v, s, summary]) for v, s, summary in existing_rows],
    ],
}

# Fetch current root block props so we can preserve any non-frontmatter keys.
get_req = urllib.request.Request(
    f"{BASE}/block/{ROOT_BLOCK_ID}?format=json",
    headers={"X-Ontara-Token": TOKEN},
)
with urllib.request.urlopen(get_req, timeout=15) as r:
    root_detail = json.loads(r.read())

current_props = root_detail["block"]["props"] or {}
new_props = dict(current_props)
new_props["frontmatter"] = new_frontmatter

payload = {
    "operations": [
        {"op": "patchBlockContent", "block_id": ROOT_BLOCK_ID, "props": new_props},
        {"op": "patchBlockContent", "block_id": VERSION_HISTORY_TABLE_ID, "content": new_table_content},
    ],
}

post_req = urllib.request.Request(
    f"{BASE}/v1/documents/{DOC_SLUG}/mutations",
    method="POST",
    headers={"X-Ontara-Token": TOKEN, "Content-Type": "application/json"},
    data=json.dumps(payload).encode("utf-8"),
)

with urllib.request.urlopen(post_req, timeout=30) as r:
    result = json.loads(r.read())

print(json.dumps(result, indent=2))
