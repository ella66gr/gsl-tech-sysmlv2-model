"""Test path 3, in the suite: nothing in generation/ outside tests/ names a tenant."""

import unittest
from pathlib import Path

PACKAGE = Path(__file__).resolve().parent.parent
TENANT_STRINGS = ["CoffeeShop", "coffeeshop", "GenderSense", "Gsl", "gsl-", "Suds", "Paws", "Minds", "Ears"]


class NoTenantNamesTest(unittest.TestCase):
    def test_no_tenant_names_outside_tests(self):
        hits = []
        for path in sorted(PACKAGE.rglob("*")):
            rel = path.relative_to(PACKAGE)
            if not path.is_file() or rel.parts[0] in ("tests", "__pycache__") or path.suffix == ".pyc":
                continue
            for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
                for s in TENANT_STRINGS:
                    if s in line:
                        hits.append(f"{rel}:{n}: {s}")
        self.assertEqual(hits, [])
