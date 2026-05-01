"""
Insert a substrate document into the ontara database.

Usage: python insert_substrate_doc.py <doc-spec-module>

The doc-spec module must export:
    SLUG: str
    TITLE: str
    FRONTMATTER: dict
    SESSION: int
    BLOCKS: list of dicts, each:
        {
            'block_type': 'heading' | 'paragraph' | 'principle' | 'table',
            'content': <ProseMirror JSON>,
            'props': <dict>,
            'entity_type': str | None,
            'entity_id': str | None,
        }

The script:
  1. Creates the document_root block.
  2. Creates the document row.
  3. Creates each child block.
  4. Adds 'contains' edges from root to each child with linear ordinals.
  5. Adds document_block membership rows.

Idempotent: if a document with the same slug exists, the script aborts.
"""

from __future__ import annotations

import json
import sys
import importlib
from pathlib import Path
from uuid import uuid4

import psycopg
from psycopg.rows import dict_row


def insert_doc(spec_module_path: str) -> None:
    spec_path = Path(spec_module_path).resolve()
    sys.path.insert(0, str(spec_path.parent))
    spec = importlib.import_module(spec_path.stem)

    slug = spec.SLUG
    title = spec.TITLE
    frontmatter = spec.FRONTMATTER
    session = spec.SESSION
    blocks_spec = spec.BLOCKS

    with psycopg.connect("dbname=ontara", row_factory=dict_row) as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1 FROM document WHERE slug = %s", (slug,))
            if cur.fetchone() is not None:
                print(f"ABORT: document {slug!r} already exists. Delete it first.")
                sys.exit(1)

        with conn.transaction():
            # 1. Document root block.
            root_block_id = uuid4()
            root_props = {"slug": slug, "frontmatter": frontmatter}
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO block
                        (id, block_type, props, content,
                         created_session, updated_session)
                    VALUES (%s, %s, %s::jsonb, %s::jsonb, %s, %s)
                    """,
                    (str(root_block_id), "document_root",
                     json.dumps(root_props), json.dumps({}),
                     session, session),
                )

            # 2. Document row.
            doc_id = uuid4()
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO document
                        (id, slug, title, root_block_id,
                         created_session, updated_session)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (str(doc_id), slug, title, str(root_block_id),
                     session, session),
                )
                # Root is a member of its own document.
                cur.execute(
                    "INSERT INTO document_block (document_id, block_id) VALUES (%s, %s)",
                    (str(doc_id), str(root_block_id)),
                )

            # 3. Child blocks + 4. contains edges + 5. document_block.
            for ordinal, b in enumerate(blocks_spec, start=1):
                child_id = uuid4()
                content = b.get("content") or {}
                props = b.get("props") or {}
                entity_type = b.get("entity_type")
                entity_id = b.get("entity_id")

                with conn.cursor() as cur:
                    cur.execute(
                        """
                        INSERT INTO block
                            (id, block_type, props, content,
                             entity_type, entity_id,
                             created_session, updated_session)
                        VALUES (%s, %s, %s::jsonb, %s::jsonb, %s, %s, %s, %s)
                        """,
                        (str(child_id), b["block_type"],
                         json.dumps(props), json.dumps(content),
                         entity_type, entity_id,
                         session, session),
                    )
                    cur.execute(
                        """
                        INSERT INTO block_edge
                            (from_block_id, to_block_id, edge_type,
                             ordinal, props)
                        VALUES (%s, %s, 'contains', %s, %s::jsonb)
                        """,
                        (str(root_block_id), str(child_id),
                         float(ordinal), json.dumps({})),
                    )
                    cur.execute(
                        "INSERT INTO document_block (document_id, block_id) VALUES (%s, %s)",
                        (str(doc_id), str(child_id)),
                    )

        print(f"OK: inserted {len(blocks_spec)} child blocks under "
              f"document {slug!r} (id {doc_id}, root {root_block_id})")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python insert_substrate_doc.py <spec.py>")
        sys.exit(2)
    insert_doc(sys.argv[1])
