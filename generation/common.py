"""Shared helpers for the generation package (platform-general).

What the generators share that is not reading the model: the model-error
exception, header paths, and name conversions. The model itself is read
through OpenSysML's resolved model (``generation.resolved``); the text
reader that used to live beside these helpers (``generation/sysml_text.py``)
was removed in S0.5 Pass A4.
"""

from __future__ import annotations

import re
from pathlib import Path


class ModelError(Exception):
    """The model does not contain what a generator needs."""


def rel_path(path: Path, root: Path) -> str:
    """POSIX path of ``path`` relative to ``root`` (absolute if outside it)."""
    path = path.resolve()
    try:
        return path.relative_to(root.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


def kebab(name: str) -> str:
    """``FulfilDrinkWorkflow`` -> ``fulfil-drink-workflow``."""
    s = re.sub(r"(?<=[a-z0-9])([A-Z])", r"-\1", name)
    s = re.sub(r"(?<=[A-Z])([A-Z][a-z])", r"-\1", s)
    return s.lower()


def lower_first(name: str) -> str:
    return name[:1].lower() + name[1:]


def upper_first(name: str) -> str:
    return name[:1].upper() + name[1:]
