"""S0.5 Pass A5: no generated file imports opensysml.

The OpenSysML reader runs only inside ``make gen``, on the authoring rig. What
it produces is plain committed TypeScript, Mermaid and text, and the Cafe's
runtime never depends on the rig. This test holds that line: it fails, naming
each file and line, if any file under a generation output folder imports
``opensysml`` in any language form.

The output folders are:

1. each ``<NAME>_OUT := <folder>`` in the Makefile (the Cafe's and
   GenderSense's generation output);
2. the folder of every generated-file record (``generated-files.<Model>.txt``)
   in the repository, and the folder of every file a record lists.

Every file under those folders is read, whatever its extension, and checked
for the Python forms (``import opensysml``, ``from opensysml… import``,
``__import__`` / ``importlib.import_module``) and the TS/JS forms (a static
``import``/``export … from``, a side-effect ``import``, a dynamic
``import()``, a ``require()``) of the package ``opensysml``, its subpaths, and
any ``@opensysml/…`` package.
"""

from __future__ import annotations

import os
import re
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
MAKEFILE = REPO / "Makefile"
RECORD_GLOB = re.compile(r"^generated-files\..+\.txt$")
PRUNE = {".git", ".venv", "node_modules", "__pycache__", ".svelte-kit"}

_SPEC = r"""['"](?:@opensysml/[^'"]*|(?:@[\w.-]+/)?opensysml(?:/[^'"]*)?)['"]"""
IMPORT_FORMS = [
    ("python import", re.compile(r"^\s*import\s+(?:[\w.]+(?:\s+as\s+\w+)?\s*,\s*)*opensysml(?:\.[\w.]+)?\b", re.M)),
    ("python from-import", re.compile(r"^\s*from\s+opensysml(?:\.[\w.]+)?\s+import\b", re.M)),
    ("python dynamic import", re.compile(r"(?:__import__|import_module)\s*\(\s*['\"]opensysml(?:\.[\w.]+)?['\"]")),
    ("js/ts import or export from", re.compile(r"\bfrom\s*" + _SPEC)),
    ("js/ts side-effect import", re.compile(r"\bimport\s*" + _SPEC)),
    ("js/ts dynamic import", re.compile(r"\bimport\s*\(\s*" + _SPEC)),
    ("js/ts require", re.compile(r"\brequire\s*\(\s*" + _SPEC)),
]


def makefile_output_folders(makefile: Path = MAKEFILE) -> list[Path]:
    folders = []
    for line in makefile.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^\s*([A-Z][A-Z0-9_]*)_OUT\s*:?=\s*(\S+)\s*$", line)
        if m:
            folders.append(REPO / m.group(2))
    return folders


def record_folders(root: Path = REPO) -> list[Path]:
    folders = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in PRUNE]
        for name in filenames:
            if not RECORD_GLOB.match(name):
                continue
            here = Path(dirpath)
            folders.append(here)
            for entry in (here / name).read_text(encoding="utf-8").splitlines():
                entry = entry.strip()
                if entry and not entry.startswith("#"):
                    folders.append((here / entry).parent)
    return folders


def output_folders() -> list[Path]:
    seen, out = set(), []
    for f in makefile_output_folders() + record_folders():
        r = f.resolve()
        if r not in seen:
            seen.add(r)
            out.append(f)
    return out


def imports_in(folder: Path, base: Path = REPO) -> list[str]:
    """Every opensysml import under ``folder``, as ``path:line: form: text``."""
    hits = []
    for dirpath, dirnames, filenames in os.walk(folder):
        dirnames[:] = sorted(d for d in dirnames if d not in PRUNE)
        for name in sorted(filenames):
            path = Path(dirpath) / name
            try:
                text = path.read_bytes().decode("utf-8", errors="replace")
            except OSError as e:
                hits.append(f"{path}: unreadable ({e})")
                continue
            for form, pattern in IMPORT_FORMS:
                for m in pattern.finditer(text):
                    n = text.count("\n", 0, m.start()) + 1
                    line = text.splitlines()[n - 1].strip()
                    try:
                        shown = path.relative_to(base)
                    except ValueError:
                        shown = path
                    hits.append(f"{shown}:{n}: {form}: {line}")
    return hits


class NoOpensysmlImportTest(unittest.TestCase):
    def test_output_folders_found(self):
        folders = {f.resolve() for f in output_folders()}
        for named in ("generated", "exercises/coffeeshop-demonstrator/generated"):
            self.assertIn((REPO / named).resolve(), folders, f"{named} is not among the output folders scanned")
        for f in folders:
            self.assertTrue(f.is_dir(), f"output folder {f} does not exist")

    def test_no_generated_file_imports_opensysml(self):
        hits = []
        for folder in output_folders():
            hits += imports_in(folder)
        if hits:
            self.fail(
                "generated files import opensysml; the reader runs only inside make gen, "
                "and nothing it writes may depend on it:\n  " + "\n  ".join(hits)
            )


class DetectorTest(unittest.TestCase):
    """The detector itself: each import form is caught, near misses are not."""

    CAUGHT = {
        "a.py": "import opensysml\n",
        "b.py": "import os, opensysml as o\n",
        "c.py": "from opensysml.enumeration import EnumLiteral\n",
        "d.py": "    from opensysml import parse_sources\n",
        "e.py": "m = importlib.import_module('opensysml')\n",
        "f.ts": "import { parse_sources } from 'opensysml';\n",
        "g.ts": 'import * as o from "opensysml/model";\n',
        "h.ts": "export { x } from '@opensysml/client';\n",
        "i.js": "import 'opensysml';\n",
        "j.mjs": "const o = await import('opensysml');\n",
        "k.cjs": 'const o = require("opensysml");\n',
        "l.ts": "import type { Model } from '@scope/opensysml';\n",
    }
    MISSED = {
        "m.py": "import opensysmlx\nfrom opensysml_extra import y\n# opensysml is used only by make gen\n",
        "n.ts": "import { a } from 'opensysml-adjacent';\n// see opensysml docs\nconst s = 'opensysml';\n",
        "o.txt": "The generators read the model through opensysml at authoring time.\n",
    }

    def run_on(self, files: dict[str, str]) -> list[str]:
        with tempfile.TemporaryDirectory(prefix="no-opensysml-") as d:
            for name, text in files.items():
                (Path(d) / name).write_text(text, encoding="utf-8")
            return imports_in(Path(d), base=Path(d))

    def test_each_form_caught(self):
        hits = self.run_on(self.CAUGHT)
        for name in self.CAUGHT:
            self.assertTrue(any(h.startswith(f"{name}:") for h in hits), f"{name} not caught: {self.CAUGHT[name]!r}")

    def test_near_misses_not_caught(self):
        self.assertEqual(self.run_on(self.MISSED), [])


if __name__ == "__main__":
    unittest.main()
