package OrderLifeCycle {
    private import ScalarValues::*;
    private import ProjectionMetadata::*;

    doc /* State machine defining the lifecycle of a customer order,
         * from placement through to collection or cancellation.
         */

    // -- Events that drive transitions -------------------------

    // Each event that a transition accepts carries its action label, the
    // text a surface shows for the action that raises it (S517, S0.2).
    // OrderPlaced creates the order and so enters the initial state
    // `placed`; no transition accepts it and no workflow step triggers it.

    attribute def OrderPlaced;
    attribute def PreparationStarted {
        @UserFacing { friendlyName = "Barista: Start Preparation"; }
    }
    attribute def PreparationComplete {
        @UserFacing { friendlyName = "Barista: Mark Ready"; }
    }
    attribute def OrderCollected {
        @UserFacing { friendlyName = "Customer: Collect Drink"; }
    }
    attribute def CancellationRequested {
        @UserFacing { friendlyName = "Cancel Order"; }
    }

    // -- The state machine -------------------------------------

    state def OrderLifecycle {
        doc /* Models the lifecycle of an Order through the shop. */
        
        initial;  // ← initial pseudostate
        
        state placed;
        state inPreparation;
        state ready;

        // -- Terminal states -----------
        state collected;
        state cancelled;

        // Transitions ------------------
        transition placed_to_inPreparation
            first placed
            accept PreparationStarted
            then inPreparation;

        transition inPreparation_to_ready
            first inPreparation
            accept PreparationComplete
            then ready;

        transition ready_to_collected
            first ready
            accept OrderCollected
            then collected;

        // -- Cancellation transitions ---

        transition placed_to_cancelled
            first placed
            accept CancellationRequested
            then cancelled;

        transition inPreparation_to_cancelled
            first inPreparation
            accept CancellationRequested
            then cancelled;

    }
}
