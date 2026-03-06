package TemporalMetadata {
    private import ScalarValues::*;

    doc /* Metadata definitions for Temporal workflow generation.
         *
         * These annotations are applied to action flow steps in
         * orchestration-level action defs. The SysML-to-Temporal
         * generator reads them to produce workflow code.
         *
         * Usage:
         *   private import TemporalMetadata::*;
         *
         *   action def MyOrchestration {
         *       @TemporalWorkflow { workflowName = "myWorkflow"; taskQueue = "my-queue"; }
         *
         *       action doSomething {
         *           @TemporalActivity { activityName = "doSomething"; }
         *       }
         *       then waitForApproval;
         *
         *       action waitForApproval {
         *           @TemporalSignal { signalName = "approved"; timeoutMinutes = 1440; }
         *       }
         *   }
         *
         * Originally at: gsl-tech/sysml-metadata-lib/temporal/
         * Consolidated to: gsl-sysml-model/libraries/temporal-metadata/
         * Consumed by:   gen_temporal_workflow.py
         */

    // -- Workflow-level metadata --------------------------------

    metadata def TemporalWorkflow {
        doc /* Marks an action def as a Temporal workflow orchestration.
             * The generator uses this to identify which action defs
             * to process and to configure the emitted workflow.
             */

        attribute workflowName : String;
        attribute taskQueue : String;
    }

    // -- Step-level metadata ------------------------------------

    metadata def TemporalActivity {
        doc /* Marks an action as a Temporal activity invocation.
             * The generator emits an await activityName(input) call
             * for this step.
             */

        attribute activityName : String;
    }

    metadata def TemporalSignal {
        doc /* Marks an action as a signal wait point.
             * The generator emits a defineSignal + condition(await)
             * pattern for this step. The workflow suspends here
             * until an external signal is received.
             */

        attribute signalName : String;
        attribute timeoutMinutes : Integer;
    }

    // -- Cross-cutting metadata ---------------------------------

    metadata def StateTransitionTrigger {
        doc /* Links an action step to the state machine event it
             * triggers upon completion. Used for traceability between
             * the orchestration flow and the domain lifecycle.
             *
             * The generator can optionally emit a log statement or
             * event emission at this point.
             */

        attribute eventName : String;
    }
}
