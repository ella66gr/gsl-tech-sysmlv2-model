from generation import ts_types
from generation.tests.support import GenTestCase


class TsTypesTest(GenTestCase):
    def gen(self):
        return self.quietly(
            ts_types.generate, self.root / "shop", self.out, self.root, "FixtureShop", "types.ts", None,
            self.root / "shop" / "platform",
        )

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
        self.assertIn("Source: shop/domain/shop.sysml (FixtureShop); shop/platform/platform.sysml", first)
        self.assertIn("Generator: generation/ts_types.py", first)
        self.assert_no_timestamp(first)

    def test_optional_multiplicity(self):
        self.gen()
        self.assertIn("  note?: string;", self.read("types.ts"))

    def test_platform_defs_are_emitted_transitively_and_sorted(self):
        self.gen()
        text = self.read("types.ts")
        self.assertIn("  payer: Party;", text)
        tail = text.split("// Platform defs used by this package (from the platform model)", 1)[1]
        # Grade is pulled in through Party; Unused is not referenced, so not emitted.
        order = [tail.index(f"/** ShopPlatformFixture::Concepts::{n} */") for n in ("Grade", "Party", "Tag")]
        self.assertEqual(order, sorted(order))
        self.assertIn('export enum Grade {\n  basic = "basic",\n  premium = "premium",\n}', tail)
        self.assertIn("export interface Party {\n  partyName: string;\n  grade: Grade;\n}", tail)
        self.assertNotIn("Unused", text)

    def test_platform_def_named_like_a_tenant_def_is_prefixed(self):
        self.gen()
        text = self.read("types.ts")
        self.assertIn("export interface Badge extends ConceptsTag {", text)
        self.assertIn("export interface ConceptsTag {\n  code: string;\n}", text)
        self.assertIn("export interface Tag {\n  label: string;\n}", text)

    def test_qualified_def_needs_a_platform_model(self):
        with self.assertRaises(ts_types.ModelError):
            self.quietly(ts_types.generate, self.root / "shop", self.out, self.root, "FixtureShop", "types.ts", None)

    def test_unknown_platform_def_is_an_error(self):
        self.edit("shop/domain/shop.sysml", "ShopPlatformFixture::Concepts::Party", "ShopPlatformFixture::Concepts::Missing")
        with self.assertRaises(ts_types.ModelError):
            self.gen()

    def test_axis_value_types_and_axis_tuples(self):
        self.gen()
        text = self.read("types.ts")
        self.assertIn('export const ticketStageValues = ["placed", "inPreparation", "ready", "collected", "cancelled"] as const;', text)
        self.assertIn("export type TicketStageValue = (typeof ticketStageValues)[number];", text)
        self.assertIn("export interface TicketAxisTuple {\n  stage: TicketStageValue;\n  payment: TicketPaymentValue;\n}", text)
        self.assertIn("export interface TicketTaskAxisTuple {\n  work: TicketTaskWorkValue;\n}", text)
        ticket = text.split("export interface Ticket extends Item {", 1)[1].split("}", 1)[0]
        self.assertIn("  axes: TicketAxisTuple;", ticket)
        self.assertNotIn("stageAxis", text)  # the axis usages are not fields
