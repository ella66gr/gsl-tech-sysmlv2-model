"""
Principle elaboration: Discipline as Load-Bearing Structure.

Substrate document binding a principle block to the validated T1 concept
'discipline-as-load-bearing-structure' and elaborating its content as
prose. Authored at S327 to exercise the entity-binding render path and
close Phase 1 acceptance condition #4.
"""

SLUG = "principle-elaboration-discipline-as-load-bearing-structure"
TITLE = "Discipline as Load-Bearing Structure — Elaboration"
SESSION = 327

FRONTMATTER = {
    "date": "2026-05-01",
    "session": SESSION,
    "status": "current",
    "tags": ["principle", "elaboration", "substrate", "architecture"],
    "concept": "discipline-as-load-bearing-structure",
    "tier": "T1",
}


def para(text: str) -> dict:
    """Single-text-node paragraph."""
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
    {
        "block_type": "heading",
        "props": {"level": 1},
        "content": heading("Discipline as Load-Bearing Structure"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "This document elaborates the T1 architectural principle "
            "Discipline as Load-Bearing Structure (concept slug: "
            "discipline-as-load-bearing-structure). The principle is bound "
            "into the principle block below via the substrate's entity-binding "
            "field — the rendered output carries a wikilink back to the "
            "concept-graph note as the canonical home of the principle's "
            "definition and metadata."
        ),
    },
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("Statement"),
    },
    {
        "block_type": "principle",
        "props": {"principle_id": "discipline-as-load-bearing-structure"},
        "entity_type": "concept",
        "entity_id": "discipline-as-load-bearing-structure",
        "content": para(
            "Disciplined working practices are load-bearing — like "
            "foundations in structural engineering. Discipline in development "
            "propagates reliability through the platform to the end user. "
            "Skipping a step is not saving time; it is introducing structural "
            "risk."
        ),
    },
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("Why this is load-bearing"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Ontara is a platform whose correctness depends on the integrity "
            "of cross-paradigm bindings — SysML to OWL to PostgreSQL to "
            "rendered prose. Each binding is established by an authoring step. "
            "If any one of those steps is skipped or performed sloppily, the "
            "binding does not exist or is silently inconsistent. The "
            "consequence does not surface at the moment of skipping; it "
            "surfaces later, when downstream work assumes the binding holds. "
            "By that point, the cost of repair is far higher than the cost "
            "of having done the step properly the first time."
        ),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Discipline therefore plays the role that foundations play in "
            "structural engineering: invisible when working, but absolutely "
            "load-bearing for everything above. The Workflow Guide's "
            "session lifecycle (open / work / close) is a load-bearing "
            "structure in this sense. So is the read-before-edit rule for "
            "Obsidian markdown. So is the requirement that every reference "
            "document edit bumps frontmatter session and date fields. None "
            "of these are bureaucratic ceremony; each one prevents a "
            "specific class of latent inconsistency."
        ),
    },
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("How the principle propagates"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "The principle propagates through three mechanisms. First, "
            "structural — many of the platform's invariants are encoded as "
            "discipline rather than as runtime checks (for instance, the "
            "membership invariant for contains-edges, or the rule that "
            "tenant projections carry no annotation work). Second, "
            "compositional — disciplined inputs at one stratum become the "
            "preconditions for the next stratum's correctness. Third, "
            "cumulative — a session's discipline at close becomes the "
            "next session's foundation at open. Drift compounds; "
            "discipline compounds the other way."
        ),
    },
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("What this looks like in practice"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "In a given session, the principle expresses itself as a set "
            "of small refusals. Refusing to skip the corpus sweep when "
            "scope feels narrow. Refusing to merge two close sequence "
            "steps because the difference looks pedantic. Refusing to "
            "treat 'shall I go ahead?' as rhetorical preamble. Each "
            "refusal is individually trivial; the cumulative effect is "
            "the platform's reliability."
        ),
    },
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("Relationship to other principles"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Discipline-as-load-bearing-structure is the practice-layer "
            "counterpart of model-generates-everything (the platform's "
            "architectural commitment to driving runtime artefacts from "
            "canonical model state). Model-generates-everything establishes "
            "what the platform aims to be; discipline-as-load-bearing-"
            "structure establishes what is required to keep the platform "
            "honest about that aim during development. Both are T1 — "
            "neither subordinate to the other, both required."
        ),
    },
    {
        "block_type": "heading",
        "props": {"level": 2},
        "content": heading("Provenance"),
    },
    {
        "block_type": "paragraph",
        "content": para(
            "Authored as a substrate document at Session 327 to close Phase 1 "
            "acceptance condition #4 of W-121 (Block-composable knowledge "
            "substrate, Phase 1). The principle itself is established in the "
            "concept graph and referenced extensively from the Architecture "
            "Principles reference document and the Workflow Guide. This "
            "elaboration is the first principle elaboration to exist as a "
            "substrate document rather than a hand-authored markdown file."
        ),
    },
]
