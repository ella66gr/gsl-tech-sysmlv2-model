"""
Smoke test for substrate-authoring/_helpers.py (W-132).

Verifies:
  1. Inline-content helpers produce the expected ProseMirror shape.
  2. Block builders (H, P, CODE) produce the expected substrate-block shape.
  3. Validator passes a known-good block list.
  4. Validator rejects each known-bad shape with a clear error.

Run from anywhere:
    python /Users/ellagreen/Developer/gsl-tech/gsl-sysml-model/scripts/substrate-authoring/_helpers_smoke.py

No DB or resolver dependency.
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _helpers import (  # noqa: E402
    CODE,
    DEFAULT_ALLOWED_MARKS,
    H,
    P,
    bold,
    code,
    collect_used_marks,
    italic,
    t,
    validate_pm_schema,
    wl,
)


def _expect_assertion(label: str, fn) -> None:
    """Run fn() and expect an AssertionError; print PASS / FAIL."""
    try:
        fn()
    except AssertionError as exc:
        print(f"  PASS  {label}: {exc}")
        return
    print(f"  FAIL  {label}: expected AssertionError, none raised")
    sys.exit(1)


def main() -> None:
    print("=" * 72)
    print("substrate-authoring/_helpers smoke test")
    print("=" * 72)

    # ------------------------------------------------------------------
    # 1. Inline helpers — shape checks.
    # ------------------------------------------------------------------
    print()
    print("1. Inline helper shapes")
    assert t("hello") == {"type": "text", "text": "hello"}
    print("  PASS  t('hello')")
    assert bold("h") == {"type": "text", "text": "h", "marks": [{"type": "bold"}]}
    print("  PASS  bold('h')")
    assert italic("h") == {"type": "text", "text": "h", "marks": [{"type": "italic"}]}
    print("  PASS  italic('h')")
    assert code("h") == {"type": "text", "text": "h", "marks": [{"type": "code"}]}
    print("  PASS  code('h')")
    assert wl("alias", "target-slug") == {
        "type": "text",
        "text": "alias",
        "marks": [{"type": "wikilink", "attrs": {"target": "target-slug", "alias": "alias"}}],
    }
    print("  PASS  wl('alias', 'target-slug')")

    # ------------------------------------------------------------------
    # 2. Inline helpers — assertion failures at entry.
    # ------------------------------------------------------------------
    print()
    print("2. Inline helper input asserts")
    _expect_assertion("t() rejects non-str", lambda: t(123))
    _expect_assertion("t() rejects empty", lambda: t(""))
    _expect_assertion("bold() rejects non-str", lambda: bold(["x"]))
    _expect_assertion("italic() rejects empty", lambda: italic(""))
    _expect_assertion("code() rejects non-str", lambda: code(None))
    _expect_assertion("wl() rejects non-str text", lambda: wl(42, "slug"))
    _expect_assertion("wl() rejects empty target", lambda: wl("alias", ""))

    # ------------------------------------------------------------------
    # 3. Block builders.
    # ------------------------------------------------------------------
    print()
    print("3. Block builders")
    h2 = H(2, "Heading text")
    assert h2["block_type"] == "heading"
    assert h2["props"] == {"level": 2}
    assert h2["content"]["type"] == "heading"
    assert h2["content"]["attrs"] == {"level": 2}
    assert h2["content"]["content"] == [{"type": "text", "text": "Heading text"}]
    print("  PASS  H(2, str) shape")

    para = P(t("hello "), bold("world"))
    assert para["block_type"] == "paragraph"
    assert para["content"]["type"] == "paragraph"
    assert para["content"]["content"] == [
        {"type": "text", "text": "hello "},
        {"type": "text", "text": "world", "marks": [{"type": "bold"}]},
    ]
    assert "entity_type" not in para
    print("  PASS  P(*runs) shape")

    para_bound = P(t("bound"), entity_type="bmm_element", entity_id="referral-pathway")
    assert para_bound["entity_type"] == "bmm_element"
    assert para_bound["entity_id"] == "referral-pathway"
    print("  PASS  P(*runs, entity_type=, entity_id=) shape")

    cb = CODE("sysml", "package Foo {}")
    assert cb["block_type"] == "code"
    assert cb["props"] == {"language": "sysml", "text": "package Foo {}"}
    assert cb["content"] == {}
    print("  PASS  CODE(language, text) shape")

    _expect_assertion("CODE() rejects empty language", lambda: CODE("", "x"))
    _expect_assertion("CODE() rejects empty text", lambda: CODE("sysml", ""))

    # ------------------------------------------------------------------
    # 4. Validator — known-good block list.
    # ------------------------------------------------------------------
    print()
    print("4. Validator on good block lists")

    good_blocks = [
        H(2, "Section"),
        P(t("plain "), bold("bold "), italic("italic "), code("code"), t(" mixed.")),
        P(
            t("Wikilink chain: "),
            wl("First", "first-slug"),
            t(" then "),
            wl("Second", "second-slug"),  # adjacent wikilinks: different attrs, OK
            t("."),
        ),
        CODE("turtle", "@prefix : <http://x/> ."),
    ]
    validate_pm_schema(good_blocks, verbose=True)
    print("  PASS  good block list validates")

    # ------------------------------------------------------------------
    # 5. Validator — adjacent same-mark detection.
    # ------------------------------------------------------------------
    print()
    print("5. Validator rejects adjacent same-mark runs")

    # The S353 W-N closing-italic case: five adjacent italic runs.
    bad_italic_chain = [
        P(
            italic("foo"),
            italic("bar"),  # adjacent italic — REJECT
        ),
    ]
    _expect_assertion(
        "adjacent italic runs rejected",
        lambda: validate_pm_schema(bad_italic_chain, verbose=False),
    )

    bad_bold_chain = [
        P(
            t("prefix "),
            bold("first"),
            bold("second"),  # adjacent bold — REJECT
            t(" suffix"),
        ),
    ]
    _expect_assertion(
        "adjacent bold runs rejected",
        lambda: validate_pm_schema(bad_bold_chain, verbose=False),
    )

    bad_code_chain = [
        P(
            code("foo"),
            code("bar"),  # adjacent code — REJECT
        ),
    ]
    _expect_assertion(
        "adjacent code runs rejected",
        lambda: validate_pm_schema(bad_code_chain, verbose=False),
    )

    # Plain text adjacency is permitted (no marks, no splice).
    plain_adjacency = [P(t("foo"), t("bar"))]
    validate_pm_schema(plain_adjacency, verbose=False)
    print("  PASS  plain text adjacency permitted")

    # Different marks adjacent — permitted (italic next to bold renders cleanly).
    mixed_adjacency = [P(italic("foo"), bold("bar"))]
    validate_pm_schema(mixed_adjacency, verbose=False)
    print("  PASS  mixed-mark adjacency permitted")

    # Wikilinks with different targets adjacent — permitted (different attrs).
    different_wikilinks = [P(wl("First", "a"), wl("Second", "b"))]
    validate_pm_schema(different_wikilinks, verbose=False)
    print("  PASS  different-target wikilink adjacency permitted")

    # Wikilinks with identical target/alias adjacent — REJECT.
    duplicate_wikilinks = [P(wl("Same", "same-slug"), wl("Same", "same-slug"))]
    _expect_assertion(
        "duplicate-attr wikilink adjacency rejected",
        lambda: validate_pm_schema(duplicate_wikilinks, verbose=False),
    )

    # Plain run between marked runs breaks the chain — permitted.
    interrupted = [P(italic("a"), t(" "), italic("b"))]
    validate_pm_schema(interrupted, verbose=False)
    print("  PASS  plain-run-interrupted same-mark sequence permitted")

    # ------------------------------------------------------------------
    # 6. Validator — text-node leaf checks (mirror of resolver validator).
    # ------------------------------------------------------------------
    print()
    print("6. Validator rejects bad text-node shapes")

    bad_text_missing = [{
        "block_type": "paragraph",
        "props": {},
        "content": {"type": "paragraph", "content": [{"type": "text"}]},  # no text field
    }]
    _expect_assertion(
        "text node missing `text` field rejected",
        lambda: validate_pm_schema(bad_text_missing, verbose=False),
    )

    bad_text_nonstring = [{
        "block_type": "paragraph",
        "props": {},
        "content": {"type": "paragraph", "content": [{"type": "text", "text": 42}]},
    }]
    _expect_assertion(
        "text node with non-string `text` rejected",
        lambda: validate_pm_schema(bad_text_nonstring, verbose=False),
    )

    bad_text_empty = [{
        "block_type": "paragraph",
        "props": {},
        "content": {"type": "paragraph", "content": [{"type": "text", "text": ""}]},
    }]
    _expect_assertion(
        "text node with empty `text` rejected",
        lambda: validate_pm_schema(bad_text_empty, verbose=False),
    )

    # ------------------------------------------------------------------
    # 7. Validator — mark allowlist + block-nesting + code-block props.
    # ------------------------------------------------------------------
    print()
    print("7. Validator allowlist / nesting / code-block")

    bad_mark = [{
        "block_type": "paragraph",
        "props": {},
        "content": {
            "type": "paragraph",
            "content": [{"type": "text", "text": "x", "marks": [{"type": "strikethrough"}]}],
        },
    }]
    _expect_assertion(
        "unknown mark type rejected",
        lambda: validate_pm_schema(bad_mark, verbose=False),
    )

    nested_para = [{
        "block_type": "paragraph",
        "props": {},
        "content": {
            "type": "paragraph",
            "content": [{"type": "paragraph", "content": [{"type": "text", "text": "nested"}]}],
        },
    }]
    _expect_assertion(
        "paragraph nested in paragraph rejected",
        lambda: validate_pm_schema(nested_para, verbose=False),
    )

    bad_code_block = [{"block_type": "code", "props": {"language": "", "text": "x"}, "content": {}}]
    _expect_assertion(
        "code block with empty language rejected",
        lambda: validate_pm_schema(bad_code_block, verbose=False),
    )

    # ------------------------------------------------------------------
    # 8. Mark allowlist override.
    # ------------------------------------------------------------------
    print()
    print("8. Allowlist override")
    extended = frozenset({"bold", "italic", "code", "wikilink", "underline"})
    underline_block = [{
        "block_type": "paragraph",
        "props": {},
        "content": {
            "type": "paragraph",
            "content": [{"type": "text", "text": "u", "marks": [{"type": "underline"}]}],
        },
    }]
    validate_pm_schema(underline_block, allowed_marks=extended, verbose=False)
    print("  PASS  custom allowed_marks accepted")

    # ------------------------------------------------------------------
    # 9. collect_used_marks
    # ------------------------------------------------------------------
    print()
    print("9. collect_used_marks")
    blocks = [
        P(bold("a"), italic("b"), code("c"), wl("d", "e")),
        CODE("sysml", "package x;"),  # code blocks ignored
    ]
    used = collect_used_marks(blocks)
    assert used == {"bold", "italic", "code", "wikilink"}, f"got {used}"
    print(f"  PASS  collected {sorted(used)}")

    # ------------------------------------------------------------------
    print()
    print("=" * 72)
    print("ALL SMOKE CHECKS PASSED")
    print("=" * 72)


if __name__ == "__main__":
    main()
