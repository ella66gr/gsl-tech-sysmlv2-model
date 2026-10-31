from generation import element_list
from generation.tests.support import GenTestCase

PACKAGES = ["ShopPlatformFixture"]


class ElementListTest(GenTestCase):
    def gen(self):
        return self.quietly(
            element_list.generate, self.root / "shop" / "domain", self.out, self.root,
            self.root / "shop" / "platform", PACKAGES, "general-elements.txt", None,
        )

    def test_specialisations_and_typed_usages_are_listed(self):
        self.gen()
        text = self.read("general-elements.txt")
        self.assertIn("ShopPlatformFixture::Concepts::Party\n  ref FixtureShop::Ticket::payer\n", text)
        self.assertIn("ShopPlatformFixture::Concepts::Tag\n  def FixtureShop::Badge\n", text)

    def test_usage_through_a_tenant_specialisation_names_it(self):
        self.edit("shop/domain/shop.sysml", "        attribute shown : Boolean;\n",
                  "        attribute shown : Boolean;\n    }\n\n    part def Board {\n        part badges : Badge [0..*];\n")
        self.gen()
        self.assertIn("  part FixtureShop::Board::badges (via FixtureShop::Badge)\n", self.read("general-elements.txt"))

    def test_named_import_resolves_a_plain_name(self):
        self.edit("shop/domain/shop.sysml", "    private import ScalarValues::*;\n",
                  "    private import ScalarValues::*;\n    private import ShopPlatformFixture::Concepts::Party;\n")
        self.edit("shop/domain/shop.sysml", "        ref owner : Item;\n", "        ref owner : Item;\n        ref buyer : Party;\n")
        self.gen()
        self.assertIn("  ref FixtureShop::Ticket::buyer\n", self.read("general-elements.txt"))

    def test_unused_and_tenant_only_defs_and_attributes_are_left_out(self):
        self.gen()
        text = self.read("general-elements.txt")
        self.assertNotIn("Unused", text)
        self.assertNotIn("Grade", text)  # used only as a platform attribute type
        self.assertNotIn("FixtureShop::Item\n", text)

    def test_sorted_header_and_determinism(self):
        self.gen()
        first = self.read("general-elements.txt")
        self.gen()
        self.assertEqual(first, self.read("general-elements.txt"))
        self.assertTrue(first.startswith("# ===="))
        self.assertIn("DO NOT EDIT", first)
        self.assertIn("Generator: generation/element_list.py", first)
        self.assert_no_timestamp(first)
        elements = [l for l in first.splitlines() if l and not l.startswith(("#", " "))]
        self.assertEqual(elements, sorted(elements))

    def test_no_general_package_is_an_error(self):
        with self.assertRaises(element_list.ModelError):
            self.quietly(
                element_list.generate, self.root / "shop" / "domain", self.out, self.root,
                self.root / "shop" / "platform", ["NoSuchPackage"], "general-elements.txt", None,
            )
