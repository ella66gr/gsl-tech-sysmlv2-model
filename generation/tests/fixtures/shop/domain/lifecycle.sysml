package TicketLifeCycle {
    private import ScalarValues::*;
    private import ProjectionMetadata::*;

    attribute def Opened;
    attribute def Started {
        @UserFacing { friendlyName = "Start work"; }
    }
    attribute def Finished {
        @UserFacing { friendlyName = "Finish work"; }
    }
    attribute def Collected {
        @UserFacing { friendlyName = "Hand over"; }
    }
    attribute def Withdrawn {
        @UserFacing { friendlyName = "Withdraw"; }
    }

    state def TicketLifecycle {
        doc /* Fixture lifecycle. */
        initial;
        state placed;
        state inPreparation;
        state ready;
        state collected;
        state cancelled;

        transition placed_to_inPreparation
            first placed
            accept Started
            then inPreparation;
        transition inPreparation_to_ready
            first inPreparation
            accept Finished
            then ready;
        transition ready_to_collected
            first ready
            accept Collected
            then collected;
        transition placed_to_cancelled
            first placed
            accept Withdrawn
            then cancelled;
        transition inPreparation_to_cancelled
            first inPreparation
            accept Withdrawn
            then cancelled;
    }
}
