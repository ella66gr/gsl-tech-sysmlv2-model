import json

from generation import state_machine
from generation.sysml_text import ModelError
from generation.tests.support import GenTestCase, run_node

GUARD = "ticket-lifecycle-guard.ts"
MACHINE = "ticket-lifecycle-machine.ts"


class StateMachineTest(GenTestCase):
    def gen(self):
        return self.quietly(state_machine.generate, self.root / "shop", self.out, self.root, None, None)

    def test_machine_has_every_transition_including_cancellation(self):
        self.gen()
        m = self.read(MACHINE)
        self.assertIn('initial: "placed",', m)
        self.assertIn('Withdrawn: "cancelled",', m)
        self.assertEqual(m.count('Withdrawn: "cancelled",'), 2)
        self.assertIn('    collected: {\n      type: "final",', m)
        self.assertIn('    cancelled: {\n      type: "final",', m)
        # Type names come from the exhibiting part def.
        self.assertIn("export type TicketEvent =", m)
        self.assertIn("export type TicketState =", m)
        self.assertIn("export const ticketLifecycleMachine = setup(", m)

    def test_next_action_labels_and_signals_come_from_the_model(self):
        self.gen()
        g = self.read(GUARD)
        self.assertIn(
            '{ event: "Started", target: "inPreparation", transition: "placed_to_inPreparation", '
            'label: "Start work", signal: "workStarted" }',
            g,
        )
        self.assertIn('label: "Withdraw", signal: null', g)
        # Relabel in the model: the map follows.
        self.edit("shop/domain/lifecycle.sysml", 'friendlyName = "Start work";', 'friendlyName = "Begin";')
        self.gen()
        self.assertIn('label: "Begin", signal: "workStarted"', self.read(GUARD))

    def test_missing_label_is_an_error(self):
        self.edit(
            "shop/domain/lifecycle.sysml",
            'attribute def Finished {\n        @UserFacing { friendlyName = "Finish work"; }\n    }',
            "attribute def Finished;",
        )
        with self.assertRaisesRegex(ModelError, "no action label for event.*Finished"):
            self.gen()

    def test_transition_on_undeclared_event_is_an_error(self):
        self.edit("shop/domain/lifecycle.sysml", "accept Collected", "accept Vanished")
        with self.assertRaisesRegex(ModelError, "Vanished"):
            self.gen()

    def test_guard_refuses_illegal_transitions(self):
        """Test path 5 on a fixture: run the generated guard in Node."""
        self.gen()
        script = self.out / "check.mts"
        script.write_text(
            "import * as g from './" + GUARD + "';\n"
            "const r = {\n"
            "  readyToInPreparation: g.isTicketLifecycleTransitionLegal('ready', 'inPreparation'),\n"
            "  startedFromReady: g.nextTicketLifecycleState('ready', 'Started'),\n"
            "  terminal: g.ticketLifecycleTerminalStates.flatMap((s) =>\n"
            "    g.ticketLifecycleEvents.map((e) => g.nextTicketLifecycleState(s, e))),\n"
            "  legal: g.nextTicketLifecycleState('placed', 'Started'),\n"
            "  cancel: g.nextTicketLifecycleState('inPreparation', 'Withdrawn'),\n"
            "  isTerminal: g.isTicketLifecycleTerminal('collected'),\n"
            "};\n"
            "console.log(JSON.stringify(r));\n",
            encoding="utf-8",
        )
        proc = run_node(script, self.out)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        r = json.loads(proc.stdout)
        self.assertIs(r["readyToInPreparation"], False)
        self.assertIsNone(r["startedFromReady"])
        self.assertTrue(r["terminal"])
        self.assertTrue(all(x is None for x in r["terminal"]), r["terminal"])
        self.assertEqual(r["legal"], "inPreparation")
        self.assertEqual(r["cancel"], "cancelled")
        self.assertIs(r["isTerminal"], True)

    def test_determinism_and_header(self):
        self.gen()
        first = (self.read(MACHINE), self.read(GUARD))
        self.gen()
        self.assertEqual(first, (self.read(MACHINE), self.read(GUARD)))
        for text in first:
            self.assertIn("Generator: generation/state_machine.py", text)
            self.assert_no_timestamp(text)
