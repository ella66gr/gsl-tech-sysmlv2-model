"""The record of generated files, its pruning, and the orphan check (S520, OP-131)."""

from __future__ import annotations

import contextlib
import io
import os
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from generation import record
from generation.output import WRITTEN_LOG, header, write

MODEL = "Fixture"


def marked(name: str, generator: str = "generation/ts_types.py") -> str:
    """A file body with the do-not-edit header naming ``generator``."""
    head = header(generator, ["model/x.sysml (X)"], MODEL).replace(f"generation/{Path(generator).name}", generator)
    return head + f"export const name = '{name}';\n"


class RecordTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory(prefix="gen-record-")
        self.tmp = Path(self._tmp.name)
        self.out = self.tmp / "out"
        self.model = self.tmp / "model"
        self.log = self.tmp / "out" / f".generation-run.{MODEL}"

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def generate(self, files: dict[str, str]) -> str:
        """One generation run: write ``files`` with the log set, then the record."""
        with mock.patch.dict(os.environ, {WRITTEN_LOG: str(self.log)}):
            for name, body in files.items():
                write(self.out, name, body)
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                record.write_record(self.model, self.out, self.tmp, MODEL, self.log)
        return buf.getvalue()

    def check(self, fresh: Path, target: Path) -> tuple[bool, int, list[str]]:
        lines: list[str] = []
        ok, n = record.check([(fresh, target)], out=lines.append)
        return ok, n, lines

    def plant(self, folder: Path, rel: str, body: str) -> Path:
        path = folder / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body, encoding="utf-8")
        return path


class WriteRecordTest(RecordTestCase):
    def test_record_lists_written_files_sorted_under_the_header(self):
        self.generate({"b.ts": marked("b"), "a.ts": marked("a")})
        text = (self.out / record.record_name(MODEL)).read_text(encoding="utf-8")
        self.assertIn(f"DO NOT EDIT — Generated from {MODEL} SysML v2 model", text)
        self.assertIn("Generator: generation/record.py", text)
        self.assertTrue(text.endswith("a.ts\nb.ts\n"))
        self.assertEqual(record.read_record(self.out / record.record_name(MODEL)), ["a.ts", "b.ts"])
        self.assertFalse(self.log.exists())

    def test_same_run_twice_gives_the_same_bytes(self):
        self.generate({"a.ts": marked("a")})
        first = (self.out / record.record_name(MODEL)).read_bytes()
        self.generate({"a.ts": marked("a")})
        self.assertEqual((self.out / record.record_name(MODEL)).read_bytes(), first)

    def test_prunes_a_file_only_the_previous_record_lists(self):
        self.generate({"a.ts": marked("a"), "old.ts": marked("old")})
        self.plant(self.out, "hand.svg", "<svg/>\n")
        printed = self.generate({"a.ts": marked("a")})
        self.assertFalse((self.out / "old.ts").exists())
        self.assertIn("removed", printed)
        self.assertIn("old.ts", printed)
        self.assertTrue((self.out / "hand.svg").exists())
        self.assertEqual(record.read_record(self.out / record.record_name(MODEL)), ["a.ts"])

    def test_never_prunes_an_unlisted_marked_file(self):
        self.generate({"a.ts": marked("a")})
        self.plant(self.out, "stray.ts", marked("stray"))
        self.generate({"a.ts": marked("a")})
        self.assertTrue((self.out / "stray.ts").exists())

    def test_a_record_path_outside_the_folder_is_refused(self):
        self.generate({"a.ts": marked("a")})
        rec = self.out / record.record_name(MODEL)
        rec.write_text(rec.read_text(encoding="utf-8") + "../escape.ts\n", encoding="utf-8")
        with self.assertRaises(record.RecordError):
            self.generate({"a.ts": marked("a")})

    def test_no_log_is_an_error(self):
        with self.assertRaises(record.RecordError):
            record.write_record(self.model, self.out, self.tmp, MODEL, self.log)


class CheckTest(RecordTestCase):
    def setUp(self) -> None:
        super().setUp()
        self.generate({"a.ts": marked("a"), "b.txt": marked("b")})
        self.target = self.tmp / "target"
        self.out.rename(self.target)
        self.generate({"a.ts": marked("a"), "b.txt": marked("b")})

    def test_clean_pass_counts_the_record(self):
        ok, n, lines = self.check(self.out, self.target)
        self.assertTrue(ok, lines)
        self.assertEqual(n, 3)

    def test_recorded_orphan_fails_and_is_named(self):
        self.plant(self.target, "orphan-test.ts", marked("orphan"))
        rec = self.target / record.record_name(MODEL)
        rec.write_text(rec.read_text(encoding="utf-8") + "orphan-test.ts\n", encoding="utf-8")
        ok, _, lines = self.check(self.out, self.target)
        self.assertFalse(ok)
        self.assertTrue(any(line.startswith("ORPHANED:") and "orphan-test.ts" in line for line in lines), lines)

    def test_unrecorded_marked_file_fails_and_is_named(self):
        self.plant(self.target, "stray.ts", marked("stray"))
        ok, _, lines = self.check(self.out, self.target)
        self.assertFalse(ok)
        self.assertTrue(any(line.startswith("UNRECORDED:") and "stray.ts" in line for line in lines), lines)

    def test_other_producers_are_never_reported(self):
        self.plant(self.target, "projections/report.json", "{}\n")
        self.plant(self.target, "manifest.json", "{}\n")
        self.plant(self.target, "pathway.svg", "<svg/>\n")
        self.plant(self.target, "tables.ts", marked("tables", generator="scripts/gen_tables.py"))
        ok, _, lines = self.check(self.out, self.target)
        self.assertTrue(ok, lines)
        self.assertEqual(lines, [])

    def test_a_retired_record_is_unrecorded(self):
        self.plant(self.target, record.record_name("Retired"),
                   header("generation/record.py", ["model"], "Retired", comment="#") + "a.ts\n")
        ok, _, lines = self.check(self.out, self.target)
        self.assertFalse(ok)
        self.assertTrue(any(line.startswith("UNRECORDED:") and "Retired" in line for line in lines), lines)

    def test_hand_edit_and_missing_file_still_fail(self):
        (self.target / "a.ts").write_text(marked("edited"), encoding="utf-8")
        (self.target / "b.txt").unlink()
        ok, _, lines = self.check(self.out, self.target)
        self.assertFalse(ok)
        self.assertTrue(any(line.startswith("--- committed: ") for line in lines), lines)
        self.assertTrue(any(line.startswith("MISSING:") and "b.txt" in line for line in lines), lines)

    def test_two_tenants_sharing_a_target_see_each_others_files(self):
        other = self.tmp / "other-fresh"
        self.plant(other, "c.ts", marked("c"))
        self.plant(self.target, "c.ts", marked("c"))
        lines: list[str] = []
        ok, n = record.check([(self.out, self.target), (other, self.target)], out=lines.append)
        self.assertTrue(ok, lines)
        self.assertEqual(n, 4)


class WriteLogTest(RecordTestCase):
    def test_write_logs_only_when_the_variable_is_set(self):
        with mock.patch.dict(os.environ, {}, clear=False):
            os.environ.pop(WRITTEN_LOG, None)
            write(self.out, "x.ts", "x\n")
        self.assertFalse(self.log.exists())
        with mock.patch.dict(os.environ, {WRITTEN_LOG: str(self.log)}):
            write(self.out, "x.ts", "x\n")
        self.assertEqual(self.log.read_text(encoding="utf-8"), "x.ts\n")


if __name__ == "__main__":
    unittest.main()
