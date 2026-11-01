from generation import temporal_workflow
from generation.sysml_text import ModelError
from generation.tests.support import GenTestCase

WF = "handle-ticket.ts"
STEPS = "handle-ticket-steps.ts"
ORCH = "shop/domain/orchestration.sysml"


class TemporalWorkflowTest(GenTestCase):
    def gen(self):
        return self.quietly(
            temporal_workflow.generate,
            self.root / "shop",
            self.out,
            self.root,
            None,
            "../activities/fixture.js",
            "TicketInput",
            None,
            None,
        )

    def test_timers_from_timeout_minutes(self):
        self.gen()
        wf = self.read(WF)
        for minutes, signal in ((30, "workStarted"), (15, "workReady"), (60, "handedOver")):
            self.assertIn(f"await condition(() => {signal}, '{minutes} minutes')", wf)
        steps = self.read(STEPS)
        self.assertIn("temporalName: 'workStarted', expectedMinutes: 30,", steps)
        self.assertIn("temporalName: 'workReady', expectedMinutes: 15,", steps)
        self.assertIn("temporalName: 'handedOver', expectedMinutes: 60,", steps)
        self.assertIn("temporalName: 'openTicket', expectedMinutes: null,", steps)

    def test_changing_timeout_minutes_changes_timer_and_audit_expectation(self):
        """Test path 4: the timer and the audit expectation follow the model."""
        self.gen()
        self.assertIn("'30 minutes'", self.read(WF))
        self.edit(ORCH, "timeoutMinutes = 30;", "timeoutMinutes = 45;")
        self.gen()
        wf, steps = self.read(WF), self.read(STEPS)
        self.assertIn("await condition(() => workStarted, '45 minutes')", wf)
        self.assertNotIn("'30 minutes'", wf)
        self.assertIn("temporalName: 'workStarted', expectedMinutes: 45,", steps)
        self.assertNotIn("expectedMinutes: 30,", steps)

    def test_trigger_events_are_raised_through_the_guard(self):
        self.gen()
        wf = self.read(WF)
        for event in ("Started", "Finished", "Collected"):
            self.assertIn(f"raise('{event}');", wf)
        self.assertIn("import { traceTicketStageMove, ticketStageDefault } from './axis-guard.js';", wf)
        self.assertIn("const r = traceTicketStageMove(state, event);", wf)
        self.assertIn("throw ApplicationFailure.nonRetryable(r.reason, 'AxisMoveRejected', r);", wf)
        self.assertIn("export const ticketStageStateQuery = defineQuery<string>('ticketStageState');", wf)
        self.assertIn("export async function handleTicket(ticket: activities.TicketInput)", wf)
        self.assertIn("import type * as activities from '../activities/fixture.js';", wf)
        # Order: the event is raised after its step's wait.
        self.assertLess(wf.index("'15 minutes'"), wf.index("raise('Finished')"))

    def test_trigger_no_axis_move_carries_is_an_error(self):
        """The OrderPlaced case: an event no move carries, on the first step."""
        self.edit(
            ORCH,
            '@TemporalActivity { activityName = "openTicket"; }',
            '@TemporalActivity { activityName = "openTicket"; }\n'
            '            @StateTransitionTrigger { eventName = "Opened"; }',
        )
        with self.assertRaisesRegex(ModelError, "trigger 'Opened' is not the triggerEvent of a move on a status axis of Ticket"):
            self.gen()

    def test_trigger_out_of_order_is_an_error(self):
        # Finished is a real move, but not from the axis default.
        self.edit(
            ORCH,
            '@TemporalActivity { activityName = "openTicket"; }',
            '@TemporalActivity { activityName = "openTicket"; }\n'
            '            @StateTransitionTrigger { eventName = "Finished"; }',
        )
        with self.assertRaisesRegex(ModelError, "triggers 'Finished', but Ticket stage has no move on it from 'placed'"):
            self.gen()

    def test_succession_must_follow_step_order(self):
        self.edit(ORCH, "then work;", "then close;")
        with self.assertRaisesRegex(ModelError, "successions"):
            self.gen()

    def test_step_without_annotation_is_an_error(self):
        self.edit(ORCH, '@TemporalActivity { activityName = "doWork"; }', "")
        with self.assertRaisesRegex(ModelError, "'work'"):
            self.gen()

    def test_triggers_on_two_axes_are_an_error(self):
        self.edit(ORCH, 'eventName = "Finished";', 'eventName = "Paid";')
        with self.assertRaisesRegex(ModelError, "more than one axis"):
            self.gen()

    def test_identity_and_determinism(self):
        self.gen()
        first = (self.read(WF), self.read(STEPS))
        self.gen()
        self.assertEqual(first, (self.read(WF), self.read(STEPS)))
        steps = first[1]
        self.assertIn("export const handleTicketWorkflowName = 'handleTicket';", steps)
        self.assertIn("export const handleTicketTaskQueue = 'fixture-queue';", steps)
        self.assertIn("export const handleTicketSignals = ['workStarted', 'workReady', 'handedOver'] as const;", steps)
        for text in first:
            self.assertIn("Generator: generation/temporal_workflow.py", text)
            self.assert_no_timestamp(text)
