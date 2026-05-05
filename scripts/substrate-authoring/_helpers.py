"""
Substrate authoring helpers — shared module.

Inline-content helpers (`t`, `bold`, `italic`, `code`, `wl`), block
builders (`H`, `P`, `CODE`), and the PM-schema validator
(`validate_pm_schema`). Mirrors `block_api._validate_content_shape` from
the resolver — catching invalid text-node shapes at script construction
time so the failure surfaces in the script, not as an HTTP 400 from the
resolver.

Origin: build-script lineage `build_s33N_*.py` from W-K (S340) onward.
W-132 (S354) lifted the helpers into this shared module so future
build scripts and substrate-authoring scripts import rather than copy.

Closes the second leg of OW-S342-1 / OW-S336-2: the resolver's
`_validate_content_shape` is the server-side guard; this module is the
client-side mirror, plus a shape check the resolver does not enforce
(adjacent same-mark text runs render with HTML-comment splices, per the
S353 W-N closing-italic incident).

Validator posture
-----------------
Loud failure, no auto-fix. Adjacent text runs sharing the same single
mark are rejected with a clear error message naming the offending pair
and the parent block; authors collapse the runs into a single call.
This is consistent with the existing validator's character (no magic,
diagnose-at-source) and surfaces authoring bugs at the moment they are
introduced.

Allowed marks
-------------
The default allowlist is {bold, italic, code, wikilink}. Build scripts
may override by passing `allowed_marks=` to validate_pm_schema.
"""

from __future__ import annotations

from typing import Any, Iterable


# ----------------------------------------------------------------------
# Default mark allowlist — kept in sync with the resolver and the
# substrate editor's mark set (Bold, Italic, Code, Wikilink).
# ----------------------------------------------------------------------

DEFAULT_ALLOWED_MARKS: frozenset[str] = frozenset({"bold", "italic", "code", "wikilink"})


# ----------------------------------------------------------------------
# Inline-content helpers
# ----------------------------------------------------------------------
#
# Each helper returns a single ProseMirror text node. The asserts at
# entry are the first line of defence — they catch the most common
# authoring slip (passing a list, None, or an empty string). The PM-
# schema validator (below) is the second line of defence and runs over
# the assembled block list before any resolver write.

def t(text: str) -> dict[str, Any]:
    """Plain text run."""
    assert isinstance(text, str), f"t() requires str, got {type(text).__name__}"
    assert text != "", "t() requires non-empty string"
    return {"type": "text", "text": text}


def bold(text: str) -> dict[str, Any]:
    """Bold-marked text run."""
    assert isinstance(text, str), f"bold() requires str, got {type(text).__name__}"
    assert text != "", "bold() requires non-empty string"
    return {"type": "text", "text": text, "marks": [{"type": "bold"}]}


def italic(text: str) -> dict[str, Any]:
    """Italic-marked text run."""
    assert isinstance(text, str), f"italic() requires str, got {type(text).__name__}"
    assert text != "", "italic() requires non-empty string"
    return {"type": "text", "text": text, "marks": [{"type": "italic"}]}


def code(text: str) -> dict[str, Any]:
    """Inline-code-marked text run (the backtick mark, not a fenced block)."""
    assert isinstance(text, str), f"code() requires str, got {type(text).__name__}"
    assert text != "", "code() requires non-empty string"
    return {"type": "text", "text": text, "marks": [{"type": "code"}]}


def wl(text: str, target: str) -> dict[str, Any]:
    """Wikilink — `[[target|text]]` in source markdown."""
    assert isinstance(text, str), f"wl() text requires str, got {type(text).__name__}"
    assert isinstance(target, str), f"wl() target requires str, got {type(target).__name__}"
    assert text != "", "wl() text requires non-empty string"
    assert target != "", "wl() target requires non-empty string"
    return {
        "type": "text",
        "text": text,
        "marks": [{"type": "wikilink", "attrs": {"target": target, "alias": text}}],
    }


# ----------------------------------------------------------------------
# Block builders
# ----------------------------------------------------------------------

def H(level: int, text_or_runs: str | list[dict[str, Any]]) -> dict[str, Any]:
    """
    Heading block. Renderer reads `props.level` (OW-S332-2 closed).

    `text_or_runs` may be a plain string (single text run) or a list of
    inline-content nodes for headings with marks.
    """
    if isinstance(text_or_runs, str):
        content = [{"type": "text", "text": text_or_runs}]
    else:
        for run in text_or_runs:
            assert isinstance(run, dict), (
                f"heading run must be dict, got {type(run).__name__}"
            )
        content = text_or_runs
    return {
        "block_type": "heading",
        "props": {"level": level},
        "content": {"type": "heading", "attrs": {"level": level}, "content": content},
    }


def P(
    *runs: dict[str, Any],
    entity_type: str | None = None,
    entity_id: str | None = None,
) -> dict[str, Any]:
    """Paragraph block. Optional entity binding."""
    for run in runs:
        assert isinstance(run, dict), (
            f"paragraph run must be dict, got {type(run).__name__}"
        )
    block: dict[str, Any] = {
        "block_type": "paragraph",
        "props": {},
        "content": {"type": "paragraph", "content": list(runs)},
    }
    if entity_type:
        assert entity_id, "P(): entity_type and entity_id must travel together"
        block["entity_type"] = entity_type
        block["entity_id"] = entity_id
    return block


def CODE(language: str, text: str) -> dict[str, Any]:
    """
    Fenced code block (W-P / W-137, S351). Atomic, props-lifted shape:
    language and text live in `props`; `content` is empty.
    """
    assert isinstance(language, str), "CODE() language requires str"
    assert isinstance(text, str), "CODE() text requires str"
    assert language != "", "CODE() language requires non-empty"
    assert text != "", "CODE() text requires non-empty"
    return {
        "block_type": "code",
        "props": {"language": language, "text": text},
        "content": {},
    }


# ----------------------------------------------------------------------
# Validator
# ----------------------------------------------------------------------

def _mark_signature(node: dict[str, Any]) -> tuple[Any, ...] | None:
    """
    Hashable signature of a text node's marks for adjacent-run comparison.

    Returns None for nodes without marks (plain text), or a tuple of
    (mark_type, sorted_attrs_items) per mark, sorted by mark_type so
    `[bold, italic]` and `[italic, bold]` compare equal.
    """
    marks = node.get("marks") or []
    if not marks:
        return None
    sig = []
    for m in marks:
        mtype = m.get("type")
        attrs = m.get("attrs") or {}
        # Wikilink attrs (target, alias) make every wikilink unique;
        # adjacent wikilinks with different targets are legitimately
        # different runs, never a merge candidate. Plain marks (bold,
        # italic, code) carry no attrs and merge as expected.
        attrs_items = tuple(sorted(attrs.items())) if attrs else ()
        sig.append((mtype, attrs_items))
    sig.sort(key=lambda s: s[0])
    return tuple(sig)


def _check_adjacent_marks(
    siblings: Iterable[dict[str, Any]],
    parent_path: str,
) -> None:
    """
    Walk a list of inline-content siblings and reject pairs of adjacent
    text nodes sharing an identical mark signature.

    Two adjacent `italic("foo")` runs render as `*foo*<!--/-->*bar*` —
    visually correct but textually noisy. Authors should collapse the
    runs into a single call (`italic("foobar")`) at source.
    """
    prev_sig: tuple[Any, ...] | None = None
    prev_text: str | None = None
    for i, node in enumerate(siblings):
        if not isinstance(node, dict) or node.get("type") != "text":
            prev_sig = None
            prev_text = None
            continue
        sig = _mark_signature(node)
        # Plain text adjacent to plain text is also redundant (two t()
        # calls that should be one), but is structurally harmless so we
        # only flag mark-bearing adjacency. Plain runs reset the chain.
        if sig is None:
            prev_sig = None
            prev_text = None
            continue
        if sig == prev_sig:
            current_text = node.get("text", "")
            mark_label = ", ".join(s[0] for s in sig) if sig else "<plain>"
            raise AssertionError(
                f"adjacent same-mark text runs at {parent_path}[{i - 1}..{i}]: "
                f"both carry marks=[{mark_label}]. "
                f"Renders with HTML-comment splice ('*{prev_text}*<!--/-->*{current_text}*'); "
                f"collapse into a single call: "
                f"{mark_label}({prev_text!r} + {current_text!r})."
            )
        prev_sig = sig
        prev_text = node.get("text")


def _walk_content(
    node: Any,
    path: str,
    allowed_marks: frozenset[str],
    parent_type: str | None,
) -> None:
    """Recursive content walk shared between paragraphs, headings, and nested marks."""
    if not isinstance(node, dict):
        return
    node_type = node.get("type")

    # Text-node leaf checks — mirror block_api._validate_content_shape.
    if node_type == "text":
        if "text" not in node:
            raise AssertionError(f"text node at {path} has no `text` field")
        text_val = node.get("text")
        if not isinstance(text_val, str):
            raise AssertionError(
                f"text node at {path} has non-string `text` field "
                f"(type={type(text_val).__name__}); "
                f"Tiptap requires `text` to be a non-empty string"
            )
        if text_val == "":
            raise AssertionError(
                f"text node at {path} has empty `text` field; "
                f"Tiptap rejects empty text nodes (RangeError on mount)"
            )

    # Mark allowlist.
    for j, mark in enumerate(node.get("marks") or []):
        if not isinstance(mark, dict):
            raise AssertionError(
                f"mark at {path}.marks[{j}] must be dict, got {type(mark).__name__}"
            )
        mtype = mark.get("type")
        if not isinstance(mtype, str):
            raise AssertionError(
                f"mark at {path}.marks[{j}] must carry string type, got {mtype!r}"
            )
        if mtype not in allowed_marks:
            raise AssertionError(
                f"unknown mark type at {path}.marks[{j}]: {mtype!r} "
                f"(allowed: {sorted(allowed_marks)})"
            )

    # Block-level nesting check.
    if parent_type in ("paragraph", "heading") and node_type in ("paragraph", "heading"):
        raise AssertionError(f"{node_type} nested inside {parent_type} at {path}")

    children = node.get("content") or []
    if children:
        # Adjacent-same-mark check across siblings before recursion.
        _check_adjacent_marks(children, path + ".content")
        for i, child in enumerate(children):
            _walk_content(
                child,
                f"{path}.content[{i}]",
                allowed_marks,
                parent_type=node_type or parent_type,
            )


def validate_pm_schema(
    blocks: list[dict[str, Any]],
    *,
    allowed_marks: frozenset[str] | set[str] | None = None,
    verbose: bool = True,
) -> None:
    """
    Run the full validator over an assembled block list.

    Checks:
      1. Each text node has a non-empty string `text` field.
      2. Each mark is a dict with a string `type` from the allowlist.
      3. Block-level nesting (paragraph/heading inside paragraph/heading)
         is rejected.
      4. Adjacent text runs sharing an identical mark signature are
         rejected (would render with HTML-comment splices).
      5. Code blocks have non-empty string `props.language` and
         `props.text`; their `content` is skipped (atomic, props-lifted).

    Raises AssertionError with a path identifying the offending node.
    Prints a one-line OK summary when `verbose=True` (default).
    """
    if allowed_marks is None:
        allowed_marks_fs = DEFAULT_ALLOWED_MARKS
    else:
        allowed_marks_fs = frozenset(allowed_marks)

    for i, blk in enumerate(blocks):
        path = f"$[{i}]"
        block_type = blk.get("block_type")
        if block_type == "code":
            props = blk.get("props") or {}
            if not isinstance(props.get("language"), str) or props["language"] == "":
                raise AssertionError(
                    f"code block at {path}: props.language must be non-empty string"
                )
            if not isinstance(props.get("text"), str) or props["text"] == "":
                raise AssertionError(
                    f"code block at {path}: props.text must be non-empty string"
                )
            continue
        _walk_content(
            blk.get("content"),
            path + ".content",
            allowed_marks_fs,
            parent_type=None,
        )

    if verbose:
        print(f"PM-schema validator: OK ({len(blocks)} blocks).")


# ----------------------------------------------------------------------
# Mark usage scan — used by build scripts at pre-flight as a separate
# affordance from the validator (some scripts want the set of marks
# actually used printed alongside the OK summary).
# ----------------------------------------------------------------------

def collect_used_marks(blocks: list[dict[str, Any]]) -> set[str]:
    """Return the set of mark types actually used across all blocks."""
    used: set[str] = set()

    def _walk(node: Any) -> None:
        if not isinstance(node, dict):
            return
        for m in node.get("marks") or []:
            if isinstance(m, dict) and isinstance(m.get("type"), str):
                used.add(m["type"])
        for child in node.get("content") or []:
            _walk(child)

    for blk in blocks:
        if blk.get("block_type") == "code":
            continue
        _walk(blk.get("content"))
    return used
