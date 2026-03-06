// =========================================================================
// SYNTAX TEST: fork / join for parallel actions
//
// Purpose: Test whether Syside 0.8.5 supports fork and join nodes
//          in action flows for modelling concurrent execution.
//
// What to check:
//   1. Does the file parse without errors?
//   2. Do fork/join nodes appear correctly in diagrams?
//   3. Are parallel branches represented correctly?
//
// Clinical relevance: Some pathway steps can run concurrently
// (e.g. order bloods AND send patient information simultaneously).
// In Temporal, this maps to Promise.all() for parallel activities.
//
// SysML v2 spec: fork and join are control nodes in action flows.
// They create concurrent branches that execute in parallel.
// =========================================================================

package SyntaxTestForkJoin {
    private import ScalarValues::*;

    doc /* Test: fork and join control nodes for parallel actions. */

    // --- Variant A: fork/join as named control nodes ---

    action def PrepareOrderParallelA {
        doc /* Tests fork/join nodes for parallel drink preparation. */

        action receiveOrder;
        then forkPreparation;

        fork forkPreparation;
        then prepareEspresso;
        then steamMilk;

        action prepareEspresso {
            doc /* Pull espresso shot. */
        }
        then joinPreparation;

        action steamMilk {
            doc /* Steam milk to temperature. */
        }
        then joinPreparation;

        join joinPreparation;
        then assembleDrink;

        action assembleDrink {
            doc /* Combine espresso and milk. */
        }
    }

    // --- Variant B: fork/join without explicit names ---
    //     (testing if Syside accepts bare fork/join)

    action def PrepareOrderParallelB {
        doc /* Tests: bare fork; and join; syntax. */

        action receiveOrder;
        then startParallel;

        fork startParallel;
        then grindBeans;
        then heatWater;
        then getCup;

        action grindBeans;
        then endParallel;

        action heatWater;
        then endParallel;

        action getCup;
        then endParallel;

        join endParallel;
        then brew;

        action brew;
    }
}
