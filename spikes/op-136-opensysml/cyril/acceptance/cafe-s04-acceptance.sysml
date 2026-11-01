// =========================================================================
// OP-136 Step 2 (d) - worked example of executable acceptance (E044)
//
// Spike file on spike/op-136-opensysml; never merged. Not part of the
// Cafe model: it is loaded beside it, so the model under judgement is
// unchanged and the acceptance cannot be satisfied by editing it.
//
// Written from intent, not from the model (E044 caution 1). The sources:
//   - Stage 0 specification, section 5.5 item 4: "no line moves from
//     queued to in preparation while its order's payment is unpaid."
//   - Section 5.7 test path 5: "rejected while its order is unpaid,
//     accepted once it is paid."
//   - Section 4.3 enforcer table: "Cross-axis preconditions, such as no
//     preparation before payment".
//   - Section 5.3 decision 2: the order's payment axis is "unpaid, then
//     paid".
// It reads the declaration through the General metamodel's own vocabulary
// (StatusAxis, AxisTransition, AxisPrecondition and their features), which
// is the platform's language, not the Cafe design it judges. The value
// identifiers ("inPreparation", "payment", "paid", "unpaid") and the
// reference name "order" are the shared names section 5.3 fixes; that is
// the residue of coupling to the model, and it is stated here so a reader
// can see it.
//
// Two deliberate choices:
//   1. "No preparation before payment" is read as every move INTO in
//      preparation, not only the move from queued. Section 5.5 item 4
//      names the one move the Cafe has today; the enforcer table states
//      the rule. The stricter reading is the one a new move must also meet.
//   2. The positive half (a line can start preparation at all) is a
//      separate constraint. Without it, the rule holds vacuously on an
//      axis with no moves: forAll over nothing is true.
//
// Run (repository root, pinned sysml v0.11.0):
//   sysml -no-record-cache model libraries exercises/coffeeshop-demonstrator/model \
//     spikes/op-136-opensysml/cyril/acceptance/cafe-s04-acceptance.sysml -satisfy
// =========================================================================

package CafeS04Acceptance {
    private import ScalarValues::*;
    private import ControlFunctions::*;
    private import SequenceFunctions::*;
    private import BusinessMetamodelGeneral::CanonicalRuntime::*;

    requirement def <S04_TP5> PreparationAwaitsPayment {
        doc /* A line on an order cannot start preparation while its
             * order is unpaid, and can start it once the order is paid.
             * Judged on the line's preparation axis as declared: some
             * permitted move enters in preparation, and every permitted
             * move that enters in preparation carries a precondition on
             * the payment axis of the line's order that admits paid and
             * does not admit unpaid. */
        subject axis : StatusAxis;

        require constraint lineCanStartPreparation {
            doc /* Accepted once paid: there is a move into in preparation. */
            axis.permittedTransitions->exists{in t : AxisTransition; t.toValue == "inPreparation"}
        }

        require constraint startAwaitsPayment {
            doc /* Rejected while unpaid: every move into in preparation
                 * is guarded by the order's payment, paid only. */
            axis.permittedTransitions->forAll{in t : AxisTransition;
                t.toValue != "inPreparation" or
                t.preconditions->exists{in p : AxisPrecondition;
                    p.relatedVia == "order" and p.requiredAxis == "payment"
                    and includes(p.requiredValues, "paid")
                    and not includes(p.requiredValues, "unpaid")}}
        }
    }

    // The design's claim, judged by `sysml -satisfy`.
    requirement cafeLinePreparation : PreparationAwaitsPayment;
    satisfy cafeLinePreparation by CoffeeShop::OrderLine::preparationAxis;
}
