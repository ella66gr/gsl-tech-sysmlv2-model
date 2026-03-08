// =========================================================================
// Coffee Shop Archetype Mappings — CDR Exercise Phase E
// =========================================================================
// Tests @OpenEhrArchetype and @OpenEhrTemplate metadata annotations on
// part defs. Validates the previously untested pattern of metadata
// annotations on part def elements (syntax reference TODO item).
//
// FINDINGS (8 March 2026, Session 6):
//   @metadata on part def: WORKS — Syside parses and resolves correctly
//   @metadata on attribute: FAILS — parser does not accept metadata
//     annotations inside attribute bodies (parsing-error)
//   doc block after attribute;  FAILS — parser does not accept doc /* */
//     after a semicolon-terminated attribute declaration. doc blocks
//     require attachment to an element with a body { }
//   'comment' is a reserved word — cannot be used as an attribute name
//     (same class of trap as 'ordered' and 'accepted' in state machines)
//
// DESIGN DECISION: Per-element archetype mapping uses inline comments
// (// nodeId: ...) rather than doc blocks or metadata annotations.
// Comments are always legal and serve as human-readable reference
// documentation. The archetype-level @OpenEhrArchetype annotation
// provides machine-queryable traceability (via Syside Automator).
// If a future generator needs per-element metadata, the alternative
// is to model elements as sub-part defs (which accept @ annotations).
// =========================================================================

package CoffeeShopArchetypes {
    private import ScalarValues::*;
    private import Foundation::MetadataLibrary::*;

    doc /* SysML representation of the coffee shop openEHR archetypes
         * and templates. Maps structural model elements to their CDR
         * counterparts for traceability and self-description.
         *
         * CDR Exercise Phase E, Step E1: exploratory exercise to
         * determine whether the @OpenEhrArchetype pattern is useful
         * for GenderSense's clinical archetype-to-model mapping.
         *
         * Element-level mapping convention: each attribute within an
         * archetype-mapped part def documents its openEHR node ID and
         * RM data type via an inline comment. Format:
         *   attribute name : Type; // at0NNN | DV_CODED_TEXT
         * This is reference documentation, not metadata. */

    // ==================================================================
    // Enumerations matching archetype internal terminology
    // ==================================================================

    enum def DrinkName {
        doc /* Drink types — matches ORDER_RECORD at0010/at0011. */
        coffee;
        tea;
    }

    enum def DrinkSize {
        doc /* Drink sizes — matches ORDER_RECORD at0007/at0008/at0009. */
        small;
        medium;
        large;
    }

    enum def MilkChoice {
        doc /* Milk options — matches ORDER_RECORD at0013-at0017. */
        none;
        whole;
        semiSkimmed;
        oat;
        soy;
    }

    enum def DrinkPrice {
        doc /* Fixed price points — matches ORDER_RECORD at0020-at0023. */
        small125;
        medium175;
        large230;
        premium285;
    }

    enum def PreparationMethod {
        doc /* Preparation methods — matches PREPARATION_EVENT at0003/at0004. */
        hotPath;
        coldPath;
    }

    // ==================================================================
    // Archetype-mapped part definitions
    // ==================================================================

    part def OrderRecord {
        doc /* Models the ORDER_RECORD archetype: what was ordered.
             *
             * openEHR RM class: OBSERVATION
             * Data path: OBSERVATION > data (HISTORY) > events (POINT_EVENT)
             *            > data (ITEM_TREE) > items (ELEMENT)
             *
             * Validated in CDR Exercise Phases A-B: archetype designed
             * in Archetype Designer, OPT exported, compositions committed
             * via Temporal workflow activity, AQL queries working. */

        @OpenEhrArchetype {
            archetypeId = "openEHR-EHR-OBSERVATION.order_record.v0";
            rmClass = "OBSERVATION";
        }

        attribute drinkName : DrinkName;     // at0005 | DV_CODED_TEXT
        attribute drinkSize : DrinkSize;     // at0006 | DV_CODED_TEXT
        attribute milkChoice : MilkChoice;   // at0012 | DV_CODED_TEXT
        attribute extras : String;           // at0018 | DV_TEXT
        attribute price : DrinkPrice;        // at0019 | DV_CODED_TEXT
    }

    part def CustomerFeedback {
        doc /* Models the CUSTOMER_FEEDBACK archetype: customer satisfaction.
             *
             * openEHR RM class: EVALUATION
             * Data path: EVALUATION > data (ITEM_TREE) > items (ELEMENT)
             *
             * Validated in CDR Exercise Phase C: archetype designed,
             * compositions committed via form-driven data entry (no
             * workflow), AQL queries working. */

        @OpenEhrArchetype {
            archetypeId = "openEHR-EHR-EVALUATION.customer_feedback.v0";
            rmClass = "EVALUATION";
        }

        attribute rating : Integer;          // at0002 | DV_COUNT
        attribute feedbackComment : String;  // at0003 | DV_TEXT — 'comment' is reserved
        attribute orderReference : String;   // at0004 | DV_TEXT
    }

    part def PreparationEvent {
        doc /* Models the PREPARATION_EVENT archetype: what happened
             * during drink preparation.
             *
             * openEHR RM class: ACTION
             * Data path: ACTION > description (ITEM_TREE) > items (ELEMENT)
             * Also requires: time (DV_DATE_TIME), ism_transition
             *
             * ACTION uses 'description' not 'data' for its ITEM_TREE.
             * ISM transition codes: planned=526, active=245,
             * completed=532, aborted=531.
             *
             * Validated in CDR Exercise Phase D: archetype designed,
             * compositions committed via seeding script, governance
             * audit joins order and preparation compositions. */

        @OpenEhrArchetype {
            archetypeId = "openEHR-EHR-ACTION.preparation_event.v0";
            rmClass = "ACTION";
        }

        attribute preparationMethod : PreparationMethod; // at0002 | DV_CODED_TEXT
        attribute baristaName : String;                  // at0005 | DV_TEXT
        attribute startTime : String;                    // at0006 | DV_DATE_TIME
        attribute endTime : String;                      // at0007 | DV_DATE_TIME
        attribute preparationNotes : String;             // at0008 | DV_TEXT
    }

    // ==================================================================
    // Template-mapped composition types
    // ==================================================================

    part def OrderComposition {
        doc /* Composition template for order recording.
             * Committed by the validateOrder Temporal activity. */

        @OpenEhrTemplate {
            templateId = "coffeeshop-order-composition.v1";
        }

        part orderRecord : OrderRecord;
    }

    part def PreparationComposition {
        doc /* Composition template for preparation events.
             * Committed by the seeding script (and in future by
             * the prepareDrink Temporal activity). */

        @OpenEhrTemplate {
            templateId = "coffeeshop-preparation-composition.v1";
        }

        part preparationEvent : PreparationEvent;
    }

    part def FeedbackComposition {
        doc /* Composition template for customer feedback.
             * Committed via form-driven data entry (no workflow). */

        @OpenEhrTemplate {
            templateId = "coffeeshop-feedback-composition.v1";
        }

        part customerFeedback : CustomerFeedback;
    }
}
