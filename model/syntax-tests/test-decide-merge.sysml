// =========================================================================
// SYNTAX TEST: decide / merge control nodes
//
// Purpose: Test whether Syside 0.8.5 supports decide and merge nodes
//          in action flows. Previously failed in earlier Syside versions
//          with "No Feature named 'X' found" reference errors.
//
// What to check:
//   1. Does the file parse without errors?
//   2. Do decide/merge nodes appear in the action flow diagram?
//   3. Are the transitions from decide to branches correct?
//
// Previous finding (v3.2 syntax ref, Phase 3 traps):
//   decide hotOrCold; — failed with reference-error
//   merge afterBasePrep; — failed with reference-error
//   Workaround was to use regular action nodes for decisions.
//
// If this still fails: the workaround (action nodes as decision
// points with multiple then lines) remains valid and verified.
// =========================================================================

package SyntaxTestDecideMerge {
    private import ScalarValues::*;

    doc /* Test: decide and merge control nodes in action flows. */

    // --- Variant A: decide node with named branches ---

    action def PrepareOrderWithDecide {
        doc /* Tests decide/merge syntax for drink type branching. */

        action receiveOrder;
        then decideDrinkType;

        decide decideDrinkType;
        then prepareHotDrink;
        then prepareColdDrink;

        action prepareHotDrink {
            doc /* Hot drink preparation path. */
        }
        then mergeAfterPrep;

        action prepareColdDrink {
            doc /* Cold drink preparation path. */
        }
        then mergeAfterPrep;

        merge mergeAfterPrep;
        then serveDrink;

        action serveDrink;
    }

    // --- Variant B: if decide still fails, test action-as-decide ---
    // (This is the known-working pattern for comparison.)

    action def PrepareOrderWithActionDecision {
        doc /* Control: action node as decision point (verified pattern). */

        action receiveOrder;
        then checkDrinkType;

        action checkDrinkType;
        then prepareHotDrink;
        then prepareColdDrink;

        action prepareHotDrink;
        then serveDrink;

        action prepareColdDrink;
        then serveDrink;

        action serveDrink;
    }
}
