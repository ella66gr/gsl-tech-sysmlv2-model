"""Lightweight text helpers for reading a SysML v2 model folder.

These are text-level readers, not a SysML parser: they find packages,
definitions and metadata annotations by pattern and balanced braces. They
are deliberately small and stdlib-only. Every reader is deterministic:
files are read in sorted path order and elements in source order.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


class ModelError(Exception):
    """The model does not contain what a generator needs."""


@dataclass(frozen=True)
class ModelFile:
    """One .sysml file of a model folder."""

    path: Path  # absolute
    rel: str  # POSIX path relative to the generation root, for headers
    text: str


def load_model(folder: Path, root: Path) -> list[ModelFile]:
    """Read every .sysml file under ``folder``, in sorted path order."""
    folder = folder.resolve()
    root = root.resolve()
    if not folder.is_dir():
        raise ModelError(f"model folder not found: {folder}")
    files = []
    for path in sorted(folder.rglob("*.sysml"), key=lambda p: p.as_posix()):
        files.append(ModelFile(path=path, rel=rel_path(path, root), text=path.read_text(encoding="utf-8")))
    if not files:
        raise ModelError(f"no .sysml files under {folder}")
    return files


def rel_path(path: Path, root: Path) -> str:
    """POSIX path of ``path`` relative to ``root`` (absolute if outside it)."""
    path = path.resolve()
    try:
        return path.relative_to(root.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


def mask_comments(text: str) -> str:
    """``text`` with every comment's characters replaced by spaces.

    Offsets and newlines are kept, so positions found in the masked text
    are valid in the original. Used to find declarations and match braces
    without being misled by prose in doc blocks and comments.
    """
    out = list(text)
    # A doc block's `doc` keyword goes with its comment.
    for m in re.finditer(r"\bdoc(?=\s*/\*)", text):
        out[m.start() : m.end()] = "   "
    i, n = 0, len(text)
    in_string = False
    while i < n:
        c = text[i]
        if in_string:
            if c == '"':
                in_string = False
            i += 1
        elif c == '"':
            in_string = True
            i += 1
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            end = n if end < 0 else end + 2
            for j in range(i, end):
                if out[j] != "\n":
                    out[j] = " "
            i = end
        elif text.startswith("//", i):
            while i < n and text[i] != "\n":
                out[i] = " "
                i += 1
        else:
            i += 1
    return "".join(out)


def braced_body(text: str, open_pos: int) -> tuple[str, int]:
    """Return (body, close_pos) for the brace at ``open_pos``."""
    if text[open_pos] != "{":
        raise ValueError("braced_body: position is not an opening brace")
    depth = 0
    for i in range(open_pos, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return text[open_pos + 1 : i], i
    raise ModelError("unbalanced braces")


def enclosing_packages(text: str, pos: int) -> list[str]:
    """Names of the packages that enclose ``pos``, outermost first."""
    names = []
    for m in re.finditer(r"\bpackage\s+(\w+)\s*\{", text):
        if m.start() >= pos:
            break
        open_pos = m.end() - 1
        _, close = braced_body(text, open_pos)
        if close > pos:
            names.append(m.group(1))
    return names


@dataclass(frozen=True)
class Found:
    """A definition found in a model file."""

    file: ModelFile
    name: str
    body: str  # text between the braces
    start: int  # offset of the declaration keyword in file.text
    qualified: str  # enclosing packages joined with ::, then the name

    @property
    def source(self) -> str:
        """``path (Qualified::Name)``, for a generated-file header."""
        return f"{self.file.rel} ({self.qualified})"


def find_all(files: list[ModelFile], keyword_pattern: str, name: str | None = None) -> list[Found]:
    """Find every braced declaration matching ``keyword_pattern``.

    ``keyword_pattern`` is a regex for the keywords before the name, for
    example ``r"state\\s+def"``. If ``name`` is given, only that name.
    """
    name_re = re.escape(name) if name else r"\w+"
    pattern = re.compile(rf"\b{keyword_pattern}\s+({name_re})\b[^;{{}}]*\{{")
    found = []
    for f in files:
        masked = mask_comments(f.text)
        for m in pattern.finditer(masked):
            open_pos = m.end() - 1
            _, close = braced_body(masked, open_pos)
            body = f.text[open_pos + 1 : close]
            pkgs = enclosing_packages(masked, m.start())
            qualified = "::".join(pkgs + [m.group(1)])
            found.append(Found(file=f, name=m.group(1), body=body, start=m.start(), qualified=qualified))
    return found


def find_one(files: list[ModelFile], keyword_pattern: str, name: str, what: str) -> Found:
    """Exactly one braced declaration of ``name``, or a ModelError."""
    found = find_all(files, keyword_pattern, name)
    if not found:
        raise ModelError(f"{what} {name!r} not found in the model folder")
    if len(found) > 1:
        where = ", ".join(x.file.rel for x in found)
        raise ModelError(f"{what} {name!r} is declared more than once: {where}")
    return found[0]


def metadata(body: str, name: str) -> dict[str, str] | None:
    """Attributes of the first ``@name { ... }`` annotation in ``body``."""
    m = re.search(rf"@{re.escape(name)}\s*\{{([^}}]*)\}}", body)
    if not m:
        return None
    return metadata_attrs(m.group(1))


def metadata_attrs(block: str) -> dict[str, str]:
    """Parse ``key = "value";`` and ``key = 123;`` pairs."""
    attrs: dict[str, str] = {}
    for m in re.finditer(r'(\w+)\s*=\s*"([^"]*)"', block):
        attrs[m.group(1)] = m.group(2)
    for m in re.finditer(r"(\w+)\s*=\s*(-?\d+)\s*;", block):
        attrs.setdefault(m.group(1), m.group(2))
    return attrs


def doc_text(body: str) -> str | None:
    """First doc block in ``body``, as one line of text."""
    m = re.search(r"\bdoc\s*/\*(.*?)\*/", body, re.DOTALL)
    if not m:
        return None
    lines = [ln.strip().lstrip("*").strip() for ln in m.group(1).split("\n")]
    text = " ".join(ln for ln in lines if ln)
    return text or None


def remove_doc_blocks(body: str) -> str:
    """``body`` with doc blocks (keyword included) and block comments removed."""
    return re.sub(r"(?:\bdoc\s*)?/\*.*?\*/", "", body, flags=re.DOTALL)


def top_level_members(body: str) -> str:
    """``body`` with every nested ``{ ... }`` removed, keeping the rest."""
    out = []
    depth = 0
    for c in body:
        if c == "{":
            depth += 1
            if depth == 1:
                out.append(";")
            continue
        if c == "}":
            depth -= 1
            continue
        if depth == 0:
            out.append(c)
    return "".join(out)


# -- Name helpers -------------------------------------------------------


def kebab(name: str) -> str:
    """``FulfilDrinkWorkflow`` -> ``fulfil-drink-workflow``."""
    s = re.sub(r"(?<=[a-z0-9])([A-Z])", r"-\1", name)
    s = re.sub(r"(?<=[A-Z])([A-Z][a-z])", r"-\1", s)
    return s.lower()


def lower_first(name: str) -> str:
    return name[:1].lower() + name[1:]


def upper_first(name: str) -> str:
    return name[:1].upper() + name[1:]


def humanise(name: str) -> str:
    """``baristaStarted`` -> ``barista started``."""
    return re.sub(r"([A-Z])", r" \1", name).strip().lower()
