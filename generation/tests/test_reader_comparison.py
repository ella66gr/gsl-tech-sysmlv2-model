"""The two status-axis readers agree on every tenant model and every fixture (S0.5 Pass A2).

``generation.resolved`` (OpenSysML's resolved model, what the generators
use) and the text reader in ``generation.status_axes`` must return the same
unchecked declarations, and the shared checks must give the same result on
both: the same checked axis types, or the same model error. Any difference
fails the test, showing a unified diff of the two readings.

The models compared:

1. every tenant model folder, ``exercises/*/model``, as the Makefile passes
   it to the generators;
2. every fixture folder, ``generation/tests/fixtures/*``, and the fixture
   folders the tests pass to a generator as its model (``rules/model``).

The test also checks that it saw axes where the models declare them, so it
cannot pass by both readers reading nothing.

This test and the text reader are removed together in Pass A4, when no
generator reads the source text any more.
"""

from __future__ import annotations

import dataclasses
import difflib
import json
import unittest
from pathlib import Path

from generation import resolved
from generation.status_axes import check_types, text_decls
from generation.sysml_text import ModelError, load_model

REPO = Path(__file__).resolve().parents[2]
FIXTURES = Path(__file__).resolve().parent / "fixtures"

# Fixture sub-folders a test passes to a generator as its model folder.
FIXTURE_MODEL_SUBFOLDERS = ["rules/model"]

# Models that declare status axes today. Each must read at least one type.
DECLARE_AXES = [
    "exercises/coffeeshop-demonstrator/model",
    "exercises/minds-demonstrator/model",
    "exercises/paws-demonstrator/model",
    "generation/tests/fixtures/shop",
]


def models() -> list[str]:
    out = [p.relative_to(REPO).as_posix() for p in sorted(REPO.glob("exercises/*/model")) if p.is_dir()]
    out += [p.relative_to(REPO).as_posix() for p in sorted(FIXTURES.iterdir()) if p.is_dir()]
    out += [(FIXTURES / s).relative_to(REPO).as_posix() for s in FIXTURE_MODEL_SUBFOLDERS]
    return out


def _checked(decls) -> dict:
    try:
        types = check_types(decls)
    except ModelError as e:
        return {"error": str(e)}
    out = []
    for t in types:
        d = dataclasses.asdict(t)
        d["refs"] = {k: list(v) for k, v in sorted(t.refs.items())}
        for a, ax in zip(d["axes"], t.axes):
            a["ident"] = ax.ident
            a["terminal"] = ax.terminal_values
        out.append(d)
    return {"types": out}


def reading(read) -> dict:
    """What one reader returns for a model: its declarations, and the shared checks' result."""
    try:
        decls = read()
    except ModelError as e:
        return {"read error": str(e)}
    plain = []
    for td in decls:
        d = dataclasses.asdict(td)
        d["refs"] = {k: list(v) for k, v in sorted(td.refs.items())}
        plain.append(d)
    return {"declarations": plain, "checked": _checked(decls)}


def dump(data: dict) -> str:
    return json.dumps(data, indent=2, ensure_ascii=False) + "\n"


class ReaderComparisonTest(unittest.TestCase):
    readings: dict[str, tuple[dict, dict]] = {}

    @classmethod
    def setUpClass(cls) -> None:
        cls.readings = {}
        for rel in models():
            folder = REPO / rel
            text = reading(lambda: text_decls(load_model(folder, REPO)))
            res = reading(lambda: resolved.load(folder, REPO).axis_decls())
            cls.readings[rel] = (text, res)

    def test_every_model_is_compared(self):
        names = set(self.readings)
        for rel in DECLARE_AXES + ["exercises/gendersense/model", "exercises/suds-demonstrator/model"]:
            self.assertIn(rel, names)
        self.assertIn("generation/tests/fixtures/rules", names)
        self.assertIn("generation/tests/fixtures/rules/model", names)

    def test_axes_are_read_where_the_models_declare_them(self):
        for rel in DECLARE_AXES:
            with self.subTest(model=rel):
                text, res = self.readings[rel]
                for label, r in (("text", text), ("resolved", res)):
                    self.assertTrue(r.get("checked", {}).get("types"), f"{label} reader read no axis types in {rel}: {r}")

    def test_the_two_readers_agree(self):
        for rel, (text, res) in self.readings.items():
            with self.subTest(model=rel):
                a, b = dump(text), dump(res)
                if a != b:
                    diff = "".join(
                        difflib.unified_diff(
                            a.splitlines(keepends=True),
                            b.splitlines(keepends=True),
                            fromfile=f"{rel} (text reader, generation/status_axes.py)",
                            tofile=f"{rel} (resolved reader, generation/resolved.py)",
                        )
                    )
                    self.fail(f"the readers differ on {rel}:\n{diff}")


if __name__ == "__main__":
    unittest.main()
