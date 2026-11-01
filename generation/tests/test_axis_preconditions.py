"""The generated E6 cross-axis evaluator (Stage 0 test path 5, on a fixture)."""

import json

from generation import constraint_evaluator
from generation.tests.support import GenTestCase, run_node

EVAL = "axis-preconditions.ts"


class AxisPreconditionTest(GenTestCase):
    def gen(self):
        return self.quietly(
            constraint_evaluator.generate, self.root / "shop", self.out, self.root, None, None,
            self.root / "shop" / "platform", None, False,
        )

    def run_eval(self, body: str) -> dict:
        script = self.out / "check.mts"
        script.write_text("import * as e from './" + EVAL + "';\n" + body, encoding="utf-8")
        proc = run_node(script, self.out)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        return json.loads(proc.stdout)

    def test_related_instance_rule_rejects_then_accepts(self):
        """Through relatedVia: rejected while the ticket is not under way, accepted once it is."""
        self.gen()
        r = self.run_eval(
            "const at = (stage: string | null) => e.evaluateAxisMovePreconditions('TicketTask', 'work', 'waitingToWorking',\n"
            "  { self: { work: 'waiting' }, related: stage === null ? {} : { ticket: { stage, payment: 'unpaid' } } });\n"
            "console.log(JSON.stringify({ placed: at('placed'), ready: at('ready'), missing: at(null),\n"
            "  direct: e.evaluateTicketTaskWorkWaitingToWorkingTicketUnderWay({ self: {}, related: { ticket: { stage: 'inPreparation' } } }) }));\n"
        )
        placed = r["placed"]
        self.assertIs(placed["ok"], False)
        self.assertEqual(placed["code"], "preconditionNotMet")
        self.assertEqual(placed["reasons"], ["The ticket is not under way."])
        self.assertEqual(placed["results"][0]["actualValue"], "placed")
        self.assertEqual(placed["results"][0]["relatedType"], "Ticket")
        self.assertIs(r["ready"]["ok"], True)
        self.assertIs(r["missing"]["ok"], False)  # cannot be shown to hold: refused, not passed
        self.assertEqual(r["missing"]["results"][0]["outcome"], "indeterminate")
        self.assertEqual(r["direct"]["outcome"], "pass")

    def test_same_instance_rule_and_moves_without_preconditions(self):
        self.gen()
        r = self.run_eval(
            "const at = (payment: string) => e.evaluateAxisMovePreconditions('Ticket', 'stage', 'readyToCollected',\n"
            "  { self: { stage: 'ready', payment } });\n"
            "console.log(JSON.stringify({ unpaid: at('unpaid'), waived: at('waived'),\n"
            "  none: e.evaluateAxisMovePreconditions('Ticket', 'stage', 'placedToInPreparation', { self: {} }) }));\n"
        )
        self.assertEqual((r["unpaid"]["ok"], r["unpaid"]["reasons"]), (False, ["The ticket is not settled."]))
        self.assertIs(r["waived"]["ok"], True)
        self.assertEqual((r["none"]["ok"], r["none"]["results"]), (True, []))

    def test_no_preconditions_and_no_packages_is_an_error(self):
        for old in ('                part settled : AxisPrecondition {', '                part ticketUnderWay : AxisPrecondition {'):
            text = (self.root / "shop/domain/shop.sysml").read_text(encoding="utf-8")
            start = text.index(old)
            end = text.index("}", start) + 1
            (self.root / "shop/domain/shop.sysml").write_text(text[:start] + text[end:], encoding="utf-8")
        with self.assertRaisesRegex(constraint_evaluator.ModelError, "nothing to generate"):
            self.gen()

    def test_determinism_and_header(self):
        self.gen()
        first = self.read(EVAL)
        self.gen()
        self.assertEqual(first, self.read(EVAL))
        self.assertIn("Generator: generation/constraint_evaluator.py", first)
        self.assertIn("Source: shop/domain/shop.sysml (FixtureShop::Ticket); shop/domain/shop.sysml (FixtureShop::TicketTask)", first)
        self.assert_no_timestamp(first)
