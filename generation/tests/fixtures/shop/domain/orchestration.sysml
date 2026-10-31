package TicketOrchestration {
    private import TemporalMetadata::*;
    private import FixtureShop::*;

    doc /* The generator reads this action def and its annotations. */

    action def HandleTicketWorkflow {
        @TemporalWorkflow { workflowName = "handleTicket"; taskQueue = "fixture-queue"; }

        in item ticket : Ticket;

        action open {
            @TemporalActivity { activityName = "openTicket"; }
        }
        then waitStart;

        action waitStart {
            @TemporalSignal { signalName = "workStarted"; timeoutMinutes = 30; }
            @StateTransitionTrigger { eventName = "Started"; }
        }
        then work;

        action work {
            @TemporalActivity { activityName = "doWork"; }
        }
        then waitReady;

        action waitReady {
            @TemporalSignal { signalName = "workReady"; timeoutMinutes = 15; }
            @StateTransitionTrigger { eventName = "Finished"; }
        }
        then waitCollect;

        action waitCollect {
            @TemporalSignal { signalName = "handedOver"; timeoutMinutes = 60; }
            @StateTransitionTrigger { eventName = "Collected"; }
        }
        then close;

        action close {
            @TemporalActivity { activityName = "closeTicket"; }
        }
    }
}
