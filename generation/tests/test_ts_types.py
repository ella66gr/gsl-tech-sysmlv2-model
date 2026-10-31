from generation import ts_types
from generation.tests.support import GenTestCase


class TsTypesTest(GenTestCase):
    def gen(self):
        return self.quietly(ts_types.generate, self.root / "shop", self.out, self.root, "FixtureShop", "types.ts", None)

    def test_enum_member_after_doc_block_is_kept(self):
        self.gen()
        text = self.read("types.ts")
        self.assertIn('export enum Size {\n  small = "small",\n  large = "large",\n}', text)

    def test_parts_specialisation_refs_and_multiplicities(self):
        self.gen()
        text = self.read("types.ts")
        self.assertIn("export interface Ticket extends Item {", text)
        self.assertIn("  owner: Item;", text)
        self.assertIn("  tags: Tag[];", text)  # space before [0..*]
        self.assertIn("  lines: Tag[];", text)  # [1..*]
        self.assertIn("  price: number;", text)  # trailing // comment
        self.assertNotIn("lifecycle", text)  # exhibit state is not a field

    def test_header_and_determinism(self):
        self.gen()
        first = self.read("types.ts")
        self.gen()
        self.assertEqual(first, self.read("types.ts"))
        self.assertTrue(first.startswith("// ===="))
        self.assertIn("DO NOT EDIT", first)
        self.assertIn("Source: shop/domain/shop.sysml (FixtureShop)", first)
        self.assertIn("Generator: generation/ts_types.py", first)
        self.assert_no_timestamp(first)
