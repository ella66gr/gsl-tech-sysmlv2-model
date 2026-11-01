package FulfilDrinkOrchestration {
    private import ScalarValues::*;
    private import TemporalMetadata::*;
    private import CoffeeShop::*;

    doc /* Orchestration-level action flow for drink fulfilment.
         *
         * This models HOW THE SYSTEM MANAGES the drink fulfilment
         * process — activity boundaries, signal waits, and timeout
         * points. It is distinct from the domain-level FulfilDrink
         * action flow (DrinkFulfilment::FulfilDrink, in
         * drink-fulfilment.sysml in this folder) which models WHAT
         * THE BARISTA DOES.
         *
         * The Temporal workflow generator reads this action def and
         * its metadata annotations to produce a TypeScript workflow
         * function. The domain-level action flow remains the
         * governance-readable process description.
         *
         * Input (S518, S0.4): one OrderLine, a canonical runtime type.
         * The workflow runs per line. Each @StateTransitionTrigger names
         * the triggerEvent of a move on the line's preparation axis
         * (CoffeeShop::OrderLine::preparationAxis). The order's own
         * lifecycle moves are derived from its lines by MRB, not raised
         * by this workflow.
         *
         * Mapping to domain flow:
         *   validateOrder    → receiveOrder (domain)
         *   waitBaristaStart → barista picks up order
         *   prepareDrink     → checkDrinkType..assembleDrink (domain)
         *   waitDrinkReady   → markReady (domain)
         *   waitCollected    → customer collection
         *   completeOrder    → order closure
         */

    action def FulfilDrinkWorkflow {
        doc /* Temporal workflow orchestrating drink fulfilment. */

        @TemporalWorkflow {
            workflowName = "fulfilDrink";
            taskQueue = "coffeeshop";
        }

        in item orderLine : OrderLine;

        // -- Step 1: Validate the incoming order --

        action validateOrder {
            doc /* Validate order details before processing. */
            @TemporalActivity { activityName = "validateOrder"; }
        }
        then waitBaristaStart;

        // -- Step 2: Wait for barista to pick up the order --

        action waitBaristaStart {
            doc /* Suspend until a barista signals they have started.
                 * In clinical context: clinician picks up referral. */
            @TemporalSignal { signalName = "baristaStarted"; timeoutMinutes = 30; }
            @StateTransitionTrigger { eventName = "LinePreparationStarted"; }
        }
        then prepareDrink;

        // -- Step 3: Prepare the drink --

        action prepareDrink {
            doc /* Record that drink preparation has occurred.
                 * The domain-level detail (hot/cold path, milk choice)
                 * is modelled in the FulfilDrink domain action flow. */
            @TemporalActivity { activityName = "prepareDrink"; }
        }
        then waitDrinkReady;

        // -- Step 4: Wait for drink to be marked ready --

        action waitDrinkReady {
            doc /* Suspend until barista marks drink as ready.
                 * In clinical context: lab results returned. */
            @TemporalSignal { signalName = "drinkReady"; timeoutMinutes = 15; }
            @StateTransitionTrigger { eventName = "LinePreparationComplete"; }
        }
        then waitCollected;

        // -- Step 5: Wait for customer to collect --

        action waitCollected {
            doc /* Suspend until customer collects their drink.
                 * In clinical context: patient attends appointment. */
            @TemporalSignal { signalName = "drinkCollected"; timeoutMinutes = 60; }
            @StateTransitionTrigger { eventName = "LineCollected"; }
        }
        then completeOrder;

        // -- Step 6: Close the order --

        action completeOrder {
            doc /* Finalise the order after collection. */
            @TemporalActivity { activityName = "completeOrder"; }
        }
    }
}
