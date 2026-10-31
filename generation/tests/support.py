"""Shared test helpers: fixture copies, captured generator output, Node runs."""

from __future__ import annotations

import contextlib
import io
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

FIXTURES = Path(__file__).resolve().parent / "fixtures"


class GenTestCase(unittest.TestCase):
    """Each test gets a scratch folder with a fresh copy of the fixtures."""

    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory(prefix="gen-test-")
        self.tmp = Path(self._tmp.name)
        shutil.copytree(FIXTURES, self.tmp / "fixtures")
        self.root = self.tmp / "fixtures"
        self.out = self.tmp / "out"

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def quietly(self, fn, *args, **kwargs):
        with contextlib.redirect_stdout(io.StringIO()):
            return fn(*args, **kwargs)

    def edit(self, rel: str, old: str, new: str) -> None:
        """Replace ``old`` with ``new`` exactly once in a fixture file copy."""
        path = self.root / rel
        text = path.read_text(encoding="utf-8")
        self.assertEqual(text.count(old), 1, f"{old!r} should occur once in {rel}")
        path.write_text(text.replace(old, new), encoding="utf-8")

    def read(self, name: str) -> str:
        return (self.out / name).read_text(encoding="utf-8")

    def assert_no_timestamp(self, text: str) -> None:
        self.assertNotIn("Generated:", text)
        self.assertNotRegex(text, r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}")


def run_node(script: Path, cwd: Path) -> subprocess.CompletedProcess:
    """Run a TypeScript (.mts) script with Node's type stripping."""
    node = shutil.which("node")
    if node is None:
        raise AssertionError("node is required for the guard tests (Node 23.6 or later)")
    return subprocess.run(
        [node, "--disable-warning=MODULE_TYPELESS_PACKAGE_JSON", str(script)],
        cwd=cwd,
        capture_output=True,
        text=True,
        timeout=60,
    )
