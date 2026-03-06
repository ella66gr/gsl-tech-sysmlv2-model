// =========================================================================
// SYNTAX TEST: state def specialisation (:>)
//
// Purpose: Test whether Syside 0.8.5 supports state def specialisation
//          — extending a base lifecycle state machine with additional
//          states and transitions.
//
// What to check:
//   1. Does the specialised state def parse without errors?
//   2. Does it inherit states and transitions from the base?
//   3. Can additional states/transitions be added in the specialisation?
//   4. Does exhibit state work with a specialised state def?
//
// Context: Foundation::StatePatterns::StandardLifecycle defines a
// generic 5-state lifecycle. If specialisation works, entity-specific
// lifecycles can extend it rather than duplicating the base pattern.
// Currently, entity lifecycles are standalone (duplicating base states)
// because this pattern is unverified.
//
// SysML v2 spec: state def SubState :> SuperState { ... }
// =========================================================================

package SyntaxTestStateSpecialisation {
    private import ScalarValues::*;

    doc /* Test: state def specialisation via :> */

    // --- Base lifecycle (mirrors StandardLifecycle) ---

    attribute def Activated;
    attribute def Suspended;
    attribute def Resumed;
    attribute def Completed;
    attribute def Cancelled;

    state def BaseLifecycle {
        doc /* Generic base lifecycle for specialisation testing. */

        initial;
        state created;
        state active;
        state suspended;
        state completed;
        state cancelled;

        transition created_to_active
            first created
            accept Activated
            then active;

        transition active_to_suspended
            first active
            accept Suspended
            then suspended;

        transition suspended_to_active
            first suspended
            accept Resumed
            then active;

        transition active_to_completed
            first active
            accept Completed
            then completed;

        transition active_to_cancelled
            first active
            accept Cancelled
            then cancelled;

        transition created_to_cancelled
            first created
            accept Cancelled
            then cancelled;
    }

    // --- Variant A: Specialise with additional states ---

    attribute def ItemDispatched;
    attribute def ItemDelivered;

    state def OrderLifecycleSpecialised :> BaseLifecycle {
        doc /* Extends BaseLifecycle with dispatch and delivery states. */

        state dispatched;
        state delivered;

        transition active_to_dispatched
            first active
            accept ItemDispatched
            then dispatched;

        transition dispatched_to_delivered
            first dispatched
            accept ItemDelivered
            then delivered;
    }

    // --- Variant B: Specialise with only additional transitions ---

    attribute def Escalated;

    state def PriorityOrderLifecycle :> BaseLifecycle {
        doc /* Extends BaseLifecycle with a direct suspended-to-completed
             * transition (e.g. order cancelled while suspended). */

        transition suspended_to_completed
            first suspended
            accept Completed
            then completed;

        transition suspended_to_cancelled
            first suspended
            accept Cancelled
            then cancelled;
    }

    // --- Test exhibit state with specialised state def ---

    part def OrderItem {
        doc /* Tests exhibit state with a specialised state def. */
        attribute itemName : String;

        exhibit state lifecycle : OrderLifecycleSpecialised;
    }

    part def PriorityOrderItem {
        doc /* Tests exhibit state with a different specialised state def. */
        attribute itemName : String;
        attribute priority : Integer;

        exhibit state lifecycle : PriorityOrderLifecycle;
    }
}
