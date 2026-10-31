"""Shared output helpers: the do-not-edit header and deterministic writes."""

from __future__ import annotations

import argparse
from pathlib import Path

RULE = "=" * 60


def header(generator_file: str, sources: list[str], model_name: str | None, comment: str = "//") -> str:
    """The do-not-edit header block, ending with a newline.

    ``generator_file`` is the generator module's ``__file__``; the header
    names it as ``generation/<module>.py``. ``sources`` are the model
    inputs, each as ``path (Qualified::Name)``. No timestamp is written,
    so the same model always gives the same bytes.
    """
    origin = f"Generated from {model_name} SysML v2 model" if model_name else "Generated from SysML v2 model"
    lines = [
        f"{comment} {RULE}",
        f"{comment} DO NOT EDIT — {origin}",
        f"{comment} Source: {'; '.join(sources)}",
        f"{comment} Generator: generation/{Path(generator_file).name}",
        f"{comment} {RULE}",
    ]
    return "\n".join(lines) + "\n"


def write(out_dir: Path, filename: str, content: str) -> Path:
    """Write ``content`` to ``out_dir/filename`` exactly, with LF endings."""
    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / filename
    with path.open("w", encoding="utf-8", newline="\n") as fh:
        fh.write(content)
    return path


def base_parser(description: str) -> argparse.ArgumentParser:
    """Arguments every generator takes."""
    p = argparse.ArgumentParser(description=description)
    p.add_argument("--model", required=True, type=Path, help="tenant model folder (read recursively)")
    p.add_argument("--out", required=True, type=Path, help="output folder")
    p.add_argument(
        "--root",
        type=Path,
        default=Path("."),
        help="folder that header paths are written relative to (default: current folder)",
    )
    p.add_argument("--model-name", default=None, help="model name for the header line (optional)")
    return p
