#!/usr/bin/env python3
"""
The record of generated files, and the generation check (S520, OP-131).

Each tenant's generation run leaves, in its output folder, a record of every
file the generators wrote in that run: ``generated-files.<Model>.txt``, one
path per line relative to the output folder, sorted, under the usual
do-not-edit header. Two tenants sharing one output folder keep separate
records, named by model.

``write`` makes the record at the end of a run. The generators append each
file they write to the log named by ``ONTARA_GEN_WRITTEN`` (see
``output.write``); ``write`` reads that log, deletes any file the previous
record lists that this run did not write (printing each deletion), writes
the new record and removes the log. It never deletes a file the previous
record does not list.

``check`` compares a fresh regeneration with the files at the target paths.
For each target folder it reports:

- ``MISSING:`` a regenerated file that is not present;
- a unified diff for a regenerated file that differs;
- ``ORPHANED:`` a file a committed record lists that no generator writes now;
- ``UNRECORDED:`` a file that carries the ``generation/`` header (the
  do-not-edit marker and a ``Generator: generation/<module>.py`` line) that
  no generator writes now and no record lists.

Files from other producers carry no ``generation/`` header and are never
reported, even in a shared output folder.

Usage (from the repository root; the Makefile does this):
    ONTARA_GEN_WRITTEN=<log> python3 -m generation.<generator> --out <folder> ...
    ONTARA_GEN_WRITTEN=<log> python3 -m generation.record write --model <tenant model folder> \\
        --out <folder> --model-name <name>
    python3 -m generation.record check --folder <regenerated folder> <target folder> [--folder ...]
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path, PurePosixPath

from generation.output import WRITTEN_LOG, header, write

RECORD_PREFIX = "generated-files."
MARKER = "DO NOT EDIT — Generated from"
GENERATOR_LINE = "Generator: generation/"
HEADER_LINES = 10


class RecordError(Exception):
    pass


def record_name(model_name: str) -> str:
    return f"{RECORD_PREFIX}{model_name}.txt"


def is_record(rel: str) -> bool:
    return "/" not in rel and rel.startswith(RECORD_PREFIX) and rel.endswith(".txt")


def read_record(path: Path) -> list[str]:
    """The paths a record lists, in order."""
    lines = path.read_text(encoding="utf-8").splitlines()
    return [line for line in lines if line and not line.startswith("#")]


def render(files: list[str], head: str) -> str:
    return head + "".join(f"{f}\n" for f in files)


def is_marked(path: Path) -> bool:
    """True if the file's header says one of the generation/ generators wrote it."""
    try:
        with path.open("r", encoding="utf-8", errors="replace") as fh:
            head = [fh.readline() for _ in range(HEADER_LINES)]
    except OSError:
        return False
    marked = any(MARKER in line and "SysML v2 model" in line for line in head)
    return marked and any(GENERATOR_LINE in line for line in head)


def _safe(rel: str, source: str) -> str:
    p = PurePosixPath(rel)
    if not rel or p.is_absolute() or ".." in p.parts:
        raise RecordError(f"{source}: '{rel}' is not a path inside the output folder")
    return rel


def write_record(model_dir: Path, out_dir: Path, root: Path, model_name: str, log: Path) -> Path:
    """Write the run's record, pruning files only the previous record listed."""
    if not log.is_file():
        raise RecordError(f"no write log at {log}: run the generators with {WRITTEN_LOG} set first")
    written = sorted({_safe(line, str(log)) for line in log.read_text(encoding="utf-8").splitlines() if line})
    name = record_name(model_name)
    if name in written:
        raise RecordError(f"a generator wrote {name}, which is the record's own name")
    path = out_dir / name
    if path.is_file():
        for rel in read_record(path):
            target = out_dir / _safe(rel, str(path))
            if rel not in written and target.is_file():
                target.unlink()
                print(f"  removed {target} (listed in the previous record, no longer generated)")
    try:
        source = model_dir.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        source = model_dir.as_posix()
    path = write(out_dir, name, render(written, header(__file__, [source], model_name, comment="#")))
    log.unlink()
    print(f"  wrote {path} ({len(written)} generated files)")
    return path


def _files(folder: Path) -> list[str]:
    """Every file under ``folder``, relative and sorted; hidden names are skipped."""
    if not folder.is_dir():
        return []
    rels = (p.relative_to(folder).as_posix() for p in folder.rglob("*") if p.is_file())
    return sorted(r for r in rels if not any(part.startswith(".") for part in r.split("/")))


def check(folders: list[tuple[Path, Path]], out=print) -> tuple[bool, int]:
    """Compare each regenerated folder with its target folder.

    ``folders`` pairs a regenerated folder with the target folder it stands
    for; two pairs may share a target folder. Returns (passed, files compared).
    """
    targets: dict[Path, list[Path]] = {}
    for fresh, target in folders:
        targets.setdefault(target, []).append(fresh)
    ok, checked = True, 0
    for target, fresh_dirs in targets.items():
        regenerated: set[str] = set()
        for fresh in fresh_dirs:
            for rel in _files(fresh):
                regenerated.add(rel)
                checked += 1
                committed = target / rel
                if not committed.is_file():
                    out(f"MISSING: {committed} is generated but not present")
                    ok = False
                    continue
                diff = subprocess.run(
                    ["diff", "-u", "--label", f"committed: {committed}", "--label", f"regenerated: {committed}",
                     str(committed), str(fresh / rel)],
                    capture_output=True, text=True,
                )
                if diff.returncode != 0:
                    out(diff.stdout.rstrip("\n") or diff.stderr.rstrip("\n"))
                    ok = False
        on_disk = _files(target)
        recorded: dict[str, str] = {}
        for rel in on_disk:
            if is_record(rel):
                for listed in read_record(target / rel):
                    recorded.setdefault(listed, rel)
        for rel in on_disk:
            if rel in regenerated:
                continue
            if rel in recorded:
                out(f"ORPHANED: {target / rel} is listed in {target / recorded[rel]} but no generator writes it any more")
                ok = False
            elif is_marked(target / rel):
                out(f"UNRECORDED: {target / rel} carries the generation/ header, but no generator writes it "
                    "and no record lists it (an orphan: delete it by hand)")
                ok = False
    return ok, checked


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Record generated files, and check generated output against the model.")
    sub = p.add_subparsers(dest="command", required=True)
    w = sub.add_parser("write", help=f"write the output folder's record from the {WRITTEN_LOG} log, pruning orphans")
    w.add_argument("--model", required=True, type=Path, help="tenant model folder (named in the header)")
    w.add_argument("--out", required=True, type=Path, help="output folder")
    w.add_argument("--root", type=Path, default=Path("."), help="folder the header path is relative to")
    w.add_argument("--model-name", required=True, help="model name: names the record and its header")
    c = sub.add_parser("check", help="compare regenerated folders with their target folders")
    c.add_argument("--folder", nargs=2, action="append", required=True, type=Path,
                   metavar=("REGENERATED", "TARGET"), help="a regenerated folder and its target (repeat)")
    a = p.parse_args(argv)
    if a.command == "write":
        log = os.environ.get(WRITTEN_LOG)
        if not log:
            print(f"ERROR: {WRITTEN_LOG} is not set", file=sys.stderr)
            return 1
        try:
            write_record(a.model, a.out, a.root, a.model_name, Path(log))
        except RecordError as e:
            print(f"ERROR: {e}", file=sys.stderr)
            return 1
        return 0
    ok, checked = check([(fresh, target) for fresh, target in a.folder])
    if not ok:
        print("=== GEN-CHECK FAILED: generated files differ from the model (edited by hand, or not regenerated). Run 'make gen'.")
        return 1
    print(f"=== GEN-CHECK PASSED: {checked} generated files match the model")
    return 0


if __name__ == "__main__":
    sys.exit(main())
