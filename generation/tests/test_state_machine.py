"""The axis guard, next-action map and XState machines (Stage 0 test path 4, on a fixture)."""

import json

from generation import state_machine
from generation.sysml_text import ModelError
from generation.tests.support import GenTestCase, run_node

GUARD = "axis-guard.ts"
MACHINE = "axis-machine.ts"
SHOP = "shop/domain/shop.sysml"


class StateMachineTest(GenTestCase):
    def gen(self):
        return self.quietly(state_machine.generate, self.root / "shop", self.out, self.root, None, None)

    def run_guard(self, body: str) -> dict:
        script = self.out / "check.mts"
        script.write_text("import * as g from './" + GUARD + "';\n" + body, encoding="utf-8")
        proc = run_node(script, self.out)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        return json.loads(proc.stdout)

    def test_guard_rejects_loudly_with_a_structured_rejection(self):
        """Test path 4 on a fixture: a forbidden move, a move from a terminal value, the wrong authority."""
        self.gen()
        r = self.run_guard(
            "console.log(JSON.stringify({\n"
            "  forbidden: g.checkTicketStageMove({ from: 'ready', to: 'inPreparation', authority: 'operatorSide' }),\n"
            "  same: g.checkTicketStageMove({ from: 'ready', to: 'ready', authority: 'operatorSide' }),\n"
            "  terminal: g.checkTicketStageMove({ from: 'cancelled', to: 'placed', authority: 'operatorSide' }),\n"
            "  terminalByEvent: g.checkTicketStageMove({ from: 'collected', event: 'Started', authority: 'operatorSide' }),\n"
            "  authority: g.checkTicketStageMove({ from: 'placed', to: 'inPreparation', authority: 'systemSide' }),\n"
            "  unnamed: g.checkTicketStageMove({ from: 'placed', to: 'inPreparation', authority: 'customerSide' }),\n"
            "  unknown: g.checkTicketStageMove({ from: 'lost', to: 'placed', authority: 'operatorSide' }),\n"
            "  traceTerminal: g.traceTicketStageMove('cancelled', 'Started'),\n"
            "}));\n"
        )
        expect = {
            "forbidden": "moveNotPermitted", "same": "moveNotPermitted", "terminal": "fromTerminalValue",
            "terminalByEvent": "fromTerminalValue", "authority": "authorityNotNamed",
            "unnamed": "authorityNotNamed", "unknown": "unknownValue", "traceTerminal": "fromTerminalValue",
        }
        for key, code in expect.items():
            res = r[key]
            self.assertIs(res["ok"], False, key)
            self.assertEqual(res["code"], code, key)
            self.assertEqual((res["type"], res["axis"]), ("Ticket", "stage"), key)
            self.assertTrue(res["reason"], key)
            self.assertNotIn("value", res, key)  # never an unchanged value dressed as a result
        self.assertEqual([m["to"] for m in r["forbidden"]["permitted"]], ["collected"])
        self.assertEqual(r["terminal"]["permitted"], [])
        self.assertEqual(r["authority"]["authority"], "systemSide")
        self.assertIn("operatorSide", r["authority"]["reason"])

    def test_guard_accepts_declared_moves_and_names_their_preconditions(self):
        self.gen()
        r = self.run_guard(
            "console.log(JSON.stringify({\n"
            "  byTarget: g.checkTicketStageMove({ from: 'placed', to: 'inPreparation', authority: 'operatorSide' }),\n"
            "  byEvent: g.checkTicketStageMove({ from: 'inPreparation', event: 'Withdrawn', authority: 'operatorSide' }),\n"
            "  withPre: g.checkTicketStageMove({ from: 'ready', to: 'collected', authority: 'operatorSide' }),\n"
            "  axisAuthority: g.checkTicketPaymentMove({ from: 'unpaid', to: 'waived', authority: 'systemSide' }),\n"
            "  trace: g.traceTicketStageMove('inPreparation', 'Finished'),\n"
            "  specs: Object.keys(g.axisSpecs).map((t) => [t, Object.keys(g.axisSpecs[t])]),\n"
            "}));\n"
        )
        self.assertEqual((r["byTarget"]["ok"], r["byTarget"]["to"], r["byTarget"]["event"]), (True, "inPreparation", "Started"))
        self.assertEqual((r["byEvent"]["ok"], r["byEvent"]["to"]), (True, "cancelled"))
        self.assertEqual(r["withPre"]["preconditions"], ["settled"])
        # No requiredAuthority on the move: the axis's axisAuthority applies; no triggerEvent: the usage name.
        self.assertEqual((r["axisAuthority"]["ok"], r["axisAuthority"]["event"]), (True, "unpaidToWaived"))
        self.assertEqual((r["trace"]["ok"], r["trace"]["to"], r["trace"]["authority"]), (True, "ready", None))
        self.assertEqual(r["specs"], [["Ticket", ["stage", "payment"]], ["TicketTask", ["work"]]])

    def test_next_actions_are_operator_moves_with_model_labels_and_signals(self):
        self.gen()
        g = self.read(GUARD)
        self.assertIn(
            '{ event: "Started", target: "inPreparation", transition: "placedToInPreparation", '
            'label: "Start work", signal: "workStarted", preconditions: [] }',
            g,
        )
        self.assertIn('label: "Withdraw", signal: null', g)
        # unpaidToPaid is systemSide only, so no surface offers it.
        pay = g.split("export const ticketPaymentNextActions", 1)[1].split("};", 1)[0]
        self.assertNotIn('"Paid"', pay)
        self.assertIn('label: "Waive"', pay)
        # Relabel in the model: the map follows.
        self.edit(SHOP, ':>> transitionLabel = "Start work";', ':>> transitionLabel = "Begin";')
        self.gen()
        self.assertIn('label: "Begin", signal: "workStarted"', self.read(GUARD))

    def test_machine_has_a_parallel_region_per_axis(self):
        self.gen()
        m = self.read(MACHINE)
        self.assertIn("export const ticketAxesMachine = setup(", m)
        self.assertIn('  type: "parallel",', m)
        self.assertIn('    "stage": {\n      initial: "placed",', m)
        self.assertIn('    "payment": {\n      initial: "unpaid",', m)
        self.assertEqual(m.count('"Withdrawn": "cancelled",'), 2)
        self.assertIn('        cancelled: {\n          type: "final",', m)

    def test_a_new_axis_needs_no_generator_change(self):
        """A12 on a fixture: a fourth axis reaches the guard, the map and the machine."""
        self.edit(
            SHOP,
            "    part def TicketTask {",
            "    part def Flagged {\n"
            "        part flagAxis : StatusAxis {\n"
            '            :>> axisName = "flag";\n'
            "            :>> axisAuthority = (AxisAuthority::operatorSide);\n"
            '            :>> defaultValue = "clear";\n'
            '            part :>> valueSpace : ValueSpace { :>> enumValues = ("clear", "raised"); }\n'
            "            part clearToRaised : AxisTransition {\n"
            '                :>> fromValue = "clear"; :>> toValue = "raised"; :>> transitionLabel = "Raise flag";\n'
            "            }\n"
            "        }\n"
            "    }\n\n"
            "    part def TicketTask {",
        )
        self.gen()
        g, m = self.read(GUARD), self.read(MACHINE)
        self.assertIn("export function checkFlaggedFlagMove(", g)
        self.assertIn('label: "Raise flag"', g)
        self.assertIn("export const flaggedAxesMachine", m)

    def test_model_errors(self):
        cases = [
            (':>> defaultValue = "placed";', ':>> defaultValue = "nowhere";', "defaultValue 'nowhere'"),
            (':>> toValue = "collected";', ':>> toValue = "vanished";', "'vanished'"),
            (':>> relatedVia = "ticket";', ':>> relatedVia = "owner";', "'owner' is not a ref of 'TicketTask'"),
            (':>> requiredAxis = "stage";', ':>> requiredAxis = "colour";', "no axis 'colour'"),
        ]
        for old, new, msg in cases:
            with self.subTest(msg=msg):
                self.tearDown()
                self.setUp()
                self.edit(SHOP, old, new)
                with self.assertRaisesRegex(ModelError, msg):
                    self.gen()

    def test_one_event_raised_by_two_signals_is_an_error(self):
        self.edit("shop/domain/orchestration.sysml", 'eventName = "Started";', 'eventName = "Collected";')
        with self.assertRaisesRegex(ModelError, "raised by two signals"):
            self.gen()

    def test_determinism_and_header(self):
        self.gen()
        first = (self.read(MACHINE), self.read(GUARD))
        self.gen()
        self.assertEqual(first, (self.read(MACHINE), self.read(GUARD)))
        for text in first:
            self.assertIn("Generator: generation/state_machine.py", text)
            self.assert_no_timestamp(text)
