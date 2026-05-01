"""
Substrate scoping v3 — post-implementation iteration of v2.

Authored as a substrate document at S327. Captures what's landed in
S321-S327 (W-120 / W-121 / W-122), what worked, what surprised us, and
what remains. Supersedes v2 in conceptual terms; v2 retirement is a
separate operation.
"""

SLUG = "substrate-scoping-v3"
TITLE = "Block-Composable Knowledge Substrate — Scoping v3"
SESSION = 327

FRONTMATTER = {
    "date": "2026-05-01",
    "session": SESSION,
    "status": "current",
    "tags": ["architecture", "tooling", "substrate", "documentation",
             "dogfooding", "brl", "scoping"],
    "version": "v3",
    "supersedes": "session-320-block-composable-knowledge-substrate-scoping-v2",
}


def para(text: str) -> dict:
    return {
        "type": "paragraph",
        "content": [{"type": "text", "text": text}],
    }


def heading(text: str) -> dict:
    return {
        "type": "heading",
        "content": [{"type": "text", "text": text}],
    }


BLOCKS = [
    # ----------------------------------------------------------
    # Title + opening
    # ----------------------------------------------------------
    {
        "block_type": "heading",
        "props": {"level": 1},
        "content": heading("Block-Composable Knowledge Substrate — Scoping v3"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Authored at Session 327 as the post-implementation iteration of "
            "v2 (S320). v2 framed the workstream conceptually; v3 captures "
            "what has landed across S321–S327, what worked as designed, what "
            "surprised us during implementation, and what remains. v3 is "
            "itself the first substantive substrate document of the platform "
            "— authored against the canonical schema, persisted as blocks and "
            "edges, and rendered to this markdown projection by the W-D "
            "render pipeline."
        ),
    },

    # ----------------------------------------------------------
    # 1. Status
    # ----------------------------------------------------------
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("1. Status"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Phase 1 of W-121 is largely complete. The substrate schema is "
            "instantiated (Group A tables: block, block_edge, document, "
            "document_block, revision; plus the registry tables: "
            "block_type_registry, edge_type_registry, entity_type_registry). "
            "The resolver substrate API is operational at /v1/documents/* "
            "with mutation, projection, compose, and render endpoints. The "
            "Tiptap editor is wired into the Portal as a direct integration "
            "with five custom node types (paragraph, heading, principle, "
            "table, doc) and a per-block-id global attribute. Tree-diff for "
            "structural saves (W-122) is implemented client-side and "
            "confirmed end-to-end through the in-browser save path at S327."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "What is not yet done: Phase 1 acceptance condition #4 (substrate "
            "documents rendered to vault paths and read cleanly in Obsidian) "
            "is being closed by this very document and a parallel principle "
            "elaboration. The W-E ODC unification (consolidating Portal and "
            "Resolver into a single Ontara Developer Console) is open and "
            "constitutes the bulk of remaining Phase 1 work. v2 retirement "
            "follows this v3 landing."
        ),
    },

    # ----------------------------------------------------------
    # 2. Conceptual model — confirmed
    # ----------------------------------------------------------
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("2. Conceptual model — confirmed shape"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "v2's recursive-block model has held up under implementation. "
            "The schema crystallised at S322 around three shapes: blocks "
            "carry their own ProseMirror JSON content directly (no separate "
            "content-store table); structural relationships live in "
            "block_edge with typed edges (contains, transcludes, cites, "
            "mentions, instance_of, relates_to); document membership is "
            "recorded explicitly in document_block to permit a block to "
            "appear in multiple documents and to maintain that membership "
            "as edges are added or removed."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "The ordinal scheme is numeric(20,10) on block_edge to permit "
            "midpoint inserts without reflowing siblings. In practice the "
            "client-side diff allocates linear ordinals (1.0, 2.0, 3.0, …) "
            "rather than midpoints, which means every reorder produces "
            "moveBlock ops for every kept sibling — a correctness-first "
            "rather than efficiency-first choice. Whether to retrofit "
            "midpoint allocation is an open question (§5)."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Entity bindings — block.entity_type and block.entity_id paired "
            "fields constrained by entity_type_registry — proved to be "
            "exactly the right primitive for the prose-as-formalism case. A "
            "principle block in a document binds to its concept-graph entry "
            "via these fields; the resolver validates the binding against "
            "the registered source table at write time when validate=true, "
            "and the periodic /v1/audit/bindings endpoint scans for broken "
            "bindings across the corpus. The registry currently holds three "
            "active entity types: concept, bmm_element, stratum."
        ),
    },

    # ----------------------------------------------------------
    # 3. What worked as designed
    # ----------------------------------------------------------
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("3. What worked as designed"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "The Tiptap-direct integration approach (rather than building "
            "a custom ProseMirror layer) was the right call. The custom "
            "node-type extensions for paragraph, heading, principle, and "
            "table were straightforward; the per-block-id global attribute "
            "extension carries the substrate identity transparently through "
            "the editor's transactions. ProseMirror decorations for "
            "unresolved-binding warnings are exactly the lightweight overlay "
            "mechanism v2 anticipated."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "The resolver-side mutation engine's design — each operation as "
            "its own SQL statement rather than a single CTE — proved correct "
            "given Postgres's pre-statement snapshot semantics. The "
            "operation set (createBlock, insertChild, patchBlockContent, "
            "addEdge, removeEdge, moveBlock) is sufficient for Phase 1 needs "
            "and maps cleanly to the editor's diff output."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "The W-D render pipeline produces clean Obsidian markdown for "
            "the block types exercised so far. Frontmatter merge (carrying "
            "user-authored frontmatter through document_root.props.frontmatter "
            "and stamping substrate_rendered metadata) does what is needed; "
            "callout rendering for principle blocks is correct; entity "
            "bindings render as wikilinks. The pipeline is fast — sub-millisecond "
            "for documents at this corpus size."
        ),
    },

    # ----------------------------------------------------------
    # 4. What surprised us
    # ----------------------------------------------------------
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("4. What surprised us"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Three bugs surfaced at S327 during the W-122 in-browser "
            "confirmation that had been masked by direct-resolver smoke "
            "tests. Each is small individually; collectively they are "
            "instructive about the cost of testing a layered stack only at "
            "the lower layer."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "First, the Tiptap doc node did not carry the data-block-id "
            "global attribute. The BlockIdAttribute extension registered "
            "the attribute against heading, paragraph, principle, and table "
            "— but not doc. Tiptap's schema enforcement therefore stripped "
            "the attribute from the document root on every getJSON() call, "
            "leaving the client-side diff with no rootId to walk under. "
            "The diff returned an empty op list, the editor reported "
            "'No changes to save', and no save attempt reached the server. "
            "Fix: add 'doc' to the types array. One-line change."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Second, the SvelteKit form-action response unwrapping in the "
            "Portal page was hand-rolled and incorrect. The handler "
            "JSON-parsed the action result envelope and read arr[0] as the "
            "action's return value. SvelteKit's form-action serialiser uses "
            "a deduplication-indexed encoding where arr[0] is an integer "
            "index into the rest of the array, not the value itself. The "
            "consequence was that the first save returned an apparently "
            "successful integer (the dedup index) which got assigned to "
            "baseRevision, and every subsequent save sent baseRevision=2 "
            "to the resolver — which rejected it as an invalid UUID. The "
            "client then misparsed the rejection envelope as another "
            "successful integer and reported 'Saved 0 changes' instead of "
            "an error. Fix: use deserialize from $app/forms, the official "
            "SvelteKit unwrapper. Replaced both save and validateBindings "
            "paths."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Third, the snapshot refresh after a successful save updates "
            "from the editor's view, not from a fresh DB read. If the "
            "editor's view drifts from the DB (because the user edited "
            "before the previous save round-tripped, or the render diverges "
            "from the input), the next diff is computed against a snapshot "
            "that already disagrees with the DB. This is a structural "
            "concern rather than a bug per se — it surfaces only when the "
            "edit cadence outruns the round-trip — but it merits attention "
            "before multi-author or long-document work."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "A common thread runs through these three: layered systems "
            "fail in the layer not under test. The direct-resolver smoke "
            "tests at S326 exercised the resolver leg perfectly; the bugs "
            "lived in the editor leg and the form-action wrapping. The "
            "lesson is that end-to-end through the actual UI surface is "
            "the only confirmation that counts for an interactive "
            "system."
        ),
    },

    # ----------------------------------------------------------
    # 5. Open design questions
    # ----------------------------------------------------------
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("5. Open design questions"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Five design questions remain open at the close of Phase 1. "
            "Each is captured here as a placeholder for resolution at the "
            "appropriate phase or workstream."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "First, the document_block membership invariant on edge "
            "removal (W-126). When a contains edge is severed, the child "
            "block's document_block row remains, leaving a referencible "
            "but unreachable orphan. Two paths: accept Phase 1 orphan "
            "tolerance, or tighten _op_remove_edge to drop document_block "
            "when severing the last contains parent. Decision pending."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Second, ordinal allocation strategy. Linear allocation is "
            "correct but produces O(n) moveBlock ops on every reorder. "
            "Midpoint allocation reduces this to O(1) but requires the "
            "client-side diff and the resolver's ordering semantics to "
            "agree on midpoint computation. Whether the change is "
            "warranted at v1 corpus size or deferred is open."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Third, snapshot refresh authoritativeness. Phase 1 refreshes "
            "snapshots from the editor's view post-save. A more authoritative "
            "approach reads back from the database after a successful save "
            "and rebuilds the snapshot map from the canonical state. The "
            "trade-off is round-trip latency vs drift safety. For "
            "single-author short-document workflows the current approach is "
            "adequate; for collaborative or long-document workflows it is "
            "not."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Fourth, the entity-binding wikilink target convention. The "
            "render pipeline emits [[entity_id]] for concept bindings, but "
            "the concept-graph notes are named with kind-prefixed filenames "
            "(principle-foo.md, pattern-bar.md). The wikilink does not "
            "resolve in Obsidian as written. Either the render path must "
            "consult the concepts table for the canonical filename, or "
            "the concept-graph notes must adopt non-prefixed filenames, or "
            "Obsidian's alias mechanism is used. Decision pending."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Fifth, the render quarantine folder strategy. v2 anticipated a "
            "_substrate-rendered/ folder distinct from canonical vault "
            "content; this is implemented at "
            "02 ONTARA/04 Ontara ARCHITECTURE/_substrate-rendered/. The "
            "question is whether rendered substrate documents should "
            "eventually move to their natural locations in the vault tree "
            "(e.g. principle elaborations under "
            "03 Ontara CONCEPT GRAPH/principles/) or whether the "
            "quarantine remains permanent. The quarantine is sound for "
            "Phase 1; the longer-term policy is open."
        ),
    },

    # ----------------------------------------------------------
    # 6. What Phase 2 needs
    # ----------------------------------------------------------
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("6. Looking ahead — Phase 2"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Phase 2 is the foundations refresh: Architecture Principles "
            "and Vision and Architecture Reference, currently both past "
            "their 30-session DCR thresholds, refreshed by being authored "
            "as substrate documents from the outset. The substrate is now "
            "ready for that work — the schema, the editor, the render "
            "pipeline, and the entity-binding mechanism are all "
            "operational. The five open design questions above will "
            "surface in Phase 2 work and can be resolved as they bite "
            "rather than speculatively."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Phase 2's first concrete deliverable is therefore "
            "Architecture Principles authored as a substrate document. "
            "The existing markdown is read, the principles are "
            "decomposed into individual principle blocks bound to their "
            "concept-graph entries, and the structure is recomposed under "
            "a fresh document_root. The result is rendered to the "
            "principles' canonical vault location and the markdown source "
            "retired."
        ),
    },

    # ----------------------------------------------------------
    # 7. Relationship to v2
    # ----------------------------------------------------------
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("7. Relationship to v2"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "v2 (session-320-block-composable-knowledge-substrate-scoping-v2.md) "
            "remains in the vault as the historical record of the scoping "
            "work that motivated this workstream. v3 supersedes v2 in "
            "conceptual terms — the §1 framing is now the §1 status here, "
            "the §11 phasing is now confirmed by what has actually shipped, "
            "and the §12 open design questions are mostly resolved or "
            "narrowed. v2 retirement is a separate operation, captured as "
            "a follow-up work item rather than performed inline. Until "
            "retirement, the two coexist."
        ),
    },

    # ----------------------------------------------------------
    # 8. Provenance
    # ----------------------------------------------------------
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("8. Provenance"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Authored as a substrate document at Session 327 to close "
            "Phase 1 acceptance condition #4 of W-121. The block sequence "
            "was specified in a Python module and inserted via direct "
            "psycopg connection to the ontara database; rendered to the "
            "vault via the resolver's POST /v1/documents/{slug}/render "
            "endpoint with target=vault. The first substantive substrate "
            "document of the platform — and a worked example of the "
            "authoring path that v2 anticipated."
        ),
    },
]
