package CoffeeShop {
    private import ScalarValues::*;
    private import ProjectionMetadata::*;
    private import BusinessMetamodelGeneral::CanonicalRuntime::*;

    doc /* A small independent coffee shop —
         * toy exercise for learning SysML v2.
         *
         * Four-layer domain model (CSW Extension, March 2026):
         *   Item definition → Catalogue entry → Inventory record → External references
         * Price is a business decision on CatalogueEntry, not an intrinsic
         * property of MenuItem. */

    // -- Enumerations -------------------------

    enum def DrinkSize {
        small;
        medium;
        large;
    }

    enum def MilkOption {
        whole;
        semi;
        oat;
        soy;
        almond;
        none;
    }
    
    enum def ItemCategory {
        hotDrink;
        coldDrink;
        food;
    }

    enum def AvailabilityStatus {
        doc /* Whether a catalogue item is currently available for ordering. */
        active;
        discontinued;
        seasonal;
        temporarilyUnavailable;
    }

    enum def ProvisionType {
        doc /* How the shop acquires or produces the item. Affects
             * inventory semantics: prepared items track ingredients;
             * bought-in items track finished products. */
        prepared;
        boughtIn;
        hybrid;
    }

    enum def StockStatus {
        doc /* Current stock level classification for a bought-in item. */
        inStock;
        low;
        outOfStock;
        onOrder;
    }

    // -- Core domain definitions ---------------

    part def MenuItem {
        doc /* Something the shop sells. Describes intrinsic product
             * characteristics only. Price and availability are
             * business decisions that live on CatalogueEntry. */

        attribute name : String;
        attribute category : ItemCategory;
        attribute isVegan : Boolean;
        attribute description : String;
        part externalRefs : BusinessMetamodelGeneral::ServiceConcept::ExternalReference [0..*];
    }

    part def Drink :> MenuItem {
        doc /* A drink, extending MenuItem with drink-specific attributes */

        attribute size : DrinkSize;
        attribute milkChoice : MilkOption;
        attribute isCaffeinated : Boolean;
    }

    part def FoodItem :> MenuItem {
        doc /* A food item, extending MenuItem */

        attribute isGlutenFree : Boolean;
        attribute servedWarm : Boolean;
    }

    // -- Catalogue and inventory ----------------

    part def CatalogueEntry :> BusinessMetamodelGeneral::ServiceConcept::CatalogueEntry {
        doc /* The business decision to offer an item for sale.
             * Specialises the General CatalogueEntry (S518, S0.3):
             * references an item definition (MenuItem or specialisation)
             * and adds typed business-context properties: price,
             * availability, provision kind. A single item may appear in
             * multiple catalogues at different prices or terms.
             *
             * effectiveDate and statusNotes are inherited. The typed
             * attributes are the ones the Cafe uses; the inherited
             * untyped pricingDescription, availabilityStatus and
             * provisionType are left unset. */
        ref menuItem : MenuItem;
        attribute pricePence : Integer;
        attribute priceDisplay : String;
        attribute availability : AvailabilityStatus;
        attribute provisionKind : ProvisionType;
    }

    part def InventoryRecord {
        doc /* A point-in-time record of stock level for a catalogue
             * item. References a catalogue entry (not the item
             * definition directly) because inventory is scoped to
             * what the business currently offers. */
        ref catalogueEntry : CatalogueEntry;
        attribute quantityOnHand : Integer;
        attribute stockStatus : StockStatus;
        attribute lowStockThreshold : Integer;
        attribute lastRestocked : String;
        attribute quantityNotes : String;
    }

    // -- People --------------------------------

    enum def StaffRole {
        barista;
        manager;
        kitchenStaff;
    }

    part def Person {
        doc /* A person who interacts with the coffee shop */

        attribute firstName : String;
        attribute lastName : String;
    }

    part def Customer :> Person {
        doc /* Someone who buys from the shop */

        attribute loyaltyPoints : Integer;
        attribute isMember : Boolean;
    }

    part def StaffMember :> Person {
        doc /* Someone who works in the shop */

        attribute role : StaffRole;
        attribute hoursPerWeek : Real;
    }

    // -- Orders ----------------------------------
    //
    // S518 (Plan B Stage 0, S0.4). The Order and the order line are
    // canonical runtime types with declared status axes, following the Paws
    // Booking pattern. The axis declarations are the single source of each
    // lifecycle (decision 3): the former OrderStatus enum, the Order's
    // status attribute and the OrderLifecycle state definition are removed,
    // and each permitted move carries the event that triggers it.
    //
    // Authorities follow the binding classes (AxisAuthority mirrors them):
    // operatorSide is staff through HMB, at the counter, till or kitchen
    // display; systemSide is MRB, deriving a write from other substrate
    // writes in the same transaction.
    //
    // Both types are grounded as information content entities (decision 6):
    // an order is a record of what was asked for, and a line is a record of
    // one item asked for. The fulfilment is the process, in the workflow.

    @BfoType {
        bfoClass = "GenericallyDependentContinuant";
        midLevelClass = "IAO:InformationContentEntity";
        mappingNotes = "An order line is a record of one item asked for on an order: information content, part of the order's record. The preparation of the item is a process in the fulfilment workflow; the line's preparation axis records where that process has reached.";
    }
    @UserFacing {
        friendlyName = "Order Line";
        shortDescription = "One item asked for on an order, with its quantity and its own preparation status.";
    }
    @PurposiveDescription {
        description = "One item on a customer order, with its quantity and, optionally, who it is for. Each line is prepared and collected on its own, so it carries its own preparation status: queued, in preparation, ready, collected, or cancelled if its order is cancelled. A line cannot start preparation until its order is paid.";
    }
    part def OrderLine :> CanonicalRuntimeType {
        doc /* A single line on an order - one item with its quantity.
             * A line may name who it is for (H-0486): a free-text
             * beneficiary label, with an optional contact reference.
             * Both are optional; most lines carry neither.
             *
             * Canonical runtime type (S518, S0.4) with one axis,
             * preparation. Lines are prepared and collected one at a time
             * (H-0486). The line is fixed once its order is placed: no
             * line is added to an order after placement (Ella, S519);
             * S0.6 enforces this when the shapes are written.
             *
             * order: the order this line is on. Single-valued. It is the
             * reference the cross-axis precondition reads (relatedVia). */

        attribute quantity : Integer;
        ref menuItem : MenuItem;
        ref order : Order;
        attribute beneficiaryLabel : String[0..1];
        attribute beneficiaryContactRef : String[0..1];

        // -- preparation axis (ordered enumeration) -----------------

        part preparationAxis : StatusAxis {
            :>> axisName = "preparation";
            :>> axisDescription = "How far the line's item has got, from queued through preparation to ready and collected. Cancelled is a terminal branch outside the ordering, set when the line's order is cancelled.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide, AxisAuthority::systemSide);
            :>> defaultValue = "queued";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::orderedEnum;
                :>> enumValues = ("queued", "inPreparation", "ready",
                                  "collected", "cancelled");
            }

            part queuedToInPreparation : AxisTransition {
                :>> fromValue = "queued";
                :>> toValue = "inPreparation";
                :>> transitionLabel = "Barista: Start Preparation";
                :>> triggerEvent = "LinePreparationStarted";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::systemSide);

                // The Cafe's cross-axis rule (S0.4 item 4).
                part orderPaid : AxisPrecondition {
                    :>> relatedVia = "order";
                    :>> requiredAxis = "payment";
                    :>> requiredValues = ("paid");
                    :>> rejectionReason = "The order is not paid. A line cannot start preparation until its order is paid.";
                }
            }

            part inPreparationToReady : AxisTransition {
                :>> fromValue = "inPreparation";
                :>> toValue = "ready";
                :>> transitionLabel = "Barista: Mark Ready";
                :>> triggerEvent = "LinePreparationComplete";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::systemSide);
            }

            part readyToCollected : AxisTransition {
                :>> fromValue = "ready";
                :>> toValue = "collected";
                :>> transitionLabel = "Customer: Collect Drink";
                :>> triggerEvent = "LineCollected";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            // Cancellation: derived by MRB from the order's cancellation,
            // in the same transaction, for every line not collected.

            part queuedToCancelled : AxisTransition {
                :>> fromValue = "queued";
                :>> toValue = "cancelled";
                :>> transitionLabel = "line cancelled with its order";
                :>> triggerEvent = "LineCancelled";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part inPreparationToCancelled : AxisTransition {
                :>> fromValue = "inPreparation";
                :>> toValue = "cancelled";
                :>> transitionLabel = "line cancelled with its order";
                :>> triggerEvent = "LineCancelled";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part readyToCancelled : AxisTransition {
                :>> fromValue = "ready";
                :>> toValue = "cancelled";
                :>> transitionLabel = "line cancelled with its order";
                :>> triggerEvent = "LineCancelled";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }
        }
    }

    @BfoType {
        bfoClass = "GenericallyDependentContinuant";
        midLevelClass = "IAO:InformationContentEntity";
        mappingNotes = "An order is a record of what a customer asked for: information content, as the Paws Booking is (Ella, S518, decision 6). The fulfilment is the process, and it sits in the workflow; the order's axes record where it has reached.";
    }
    @UserFacing {
        friendlyName = "Order";
        shortDescription = "A customer's order of one or more items, with its lifecycle and payment status.";
    }
    @PurposiveDescription {
        description = "What a customer asked for, as one or more order lines. An order carries two independent statuses. Its lifecycle runs from placed through in preparation and ready to collected, and follows its lines: it is never moved to ready or collected directly. It can be cancelled at the counter before it is ready. Its payment runs from unpaid to paid, taken at the till.";
    }
    part def Order :> CanonicalRuntimeType {
        doc /* A customer order, containing one or more order lines.
             * The participant placing the order (orderingParty) and the
             * service subject are carried as separate fields, both typed
             * by the General defs. For a walk-in Cafe the two coincide;
             * both are carried so that surface work generalises (H-0630).
             *
             * Canonical runtime type (S518, S0.4) with two axes:
             * lifecycle and payment.
             *
             * - The moves to in preparation, ready and collected are
             *   derived by MRB from the lines, never written directly:
             *   in preparation when the first line enters preparation,
             *   ready by the readiness rule (S515, D2; S0.5 and S0.6
             *   build it), collected once every line is collected.
             * - Cancellation is at the counter, by staff, before the
             *   order is ready (H-0498): there is no move from ready to
             *   cancelled. The same transaction sets every line that is
             *   not collected to cancelled (MRB).
             * - A paid order cancelled at the counter keeps payment at
             *   paid. No refund is modelled at Stage 0.
             * - The lines are fixed once the order is placed (Ella,
             *   S519): an add-on is a new order. */

        attribute orderNumber : Integer;
        attribute totalPrice : Real;            // ScalarValue::Real

        ref orderingParty : BusinessMetamodelGeneral::ServiceConcept::ServiceParticipant;
        ref serviceSubject : BusinessMetamodelGeneral::ServiceConcept::ServiceSubject;
        part lines : OrderLine[1..*];  // At least one line; fixed once placed (S519)

        // -- lifecycle axis (ordered enumeration) -------------------

        part lifecycleAxis : StatusAxis {
            :>> axisName = "lifecycle";
            :>> axisDescription = "The order's stage, from placed through preparation to ready and collected, derived from its lines. Cancelled is a terminal branch outside the ordering, reached at the counter before the order is ready.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide, AxisAuthority::systemSide);
            :>> defaultValue = "placed";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::orderedEnum;
                :>> enumValues = ("placed", "inPreparation", "ready",
                                  "collected", "cancelled");
            }

            part placedToInPreparation : AxisTransition {
                :>> fromValue = "placed";
                :>> toValue = "inPreparation";
                :>> transitionLabel = "first line enters preparation";
                :>> triggerEvent = "PreparationStarted";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part inPreparationToReady : AxisTransition {
                :>> fromValue = "inPreparation";
                :>> toValue = "ready";
                :>> transitionLabel = "every line is ready";
                :>> triggerEvent = "PreparationComplete";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part readyToCollected : AxisTransition {
                :>> fromValue = "ready";
                :>> toValue = "collected";
                :>> transitionLabel = "every line is collected";
                :>> triggerEvent = "OrderCollected";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part placedToCancelled : AxisTransition {
                :>> fromValue = "placed";
                :>> toValue = "cancelled";
                :>> transitionLabel = "Cancel Order";
                :>> triggerEvent = "CancellationRequested";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part inPreparationToCancelled : AxisTransition {
                :>> fromValue = "inPreparation";
                :>> toValue = "cancelled";
                :>> transitionLabel = "Cancel Order";
                :>> triggerEvent = "CancellationRequested";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
        }

        // -- payment axis (ordered enumeration) ---------------------

        part paymentAxis : StatusAxis {
            :>> axisName = "payment";
            :>> axisDescription = "Whether the order has been paid, taken at the till. A cancelled order keeps the payment value it had; no refund is modelled at Stage 0.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide);
            :>> defaultValue = "unpaid";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::orderedEnum;
                :>> enumValues = ("unpaid", "paid");
            }

            part unpaidToPaid : AxisTransition {
                :>> fromValue = "unpaid";
                :>> toValue = "paid";
                :>> transitionLabel = "Till: Take Payment";
                :>> triggerEvent = "PaymentTaken";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
        }
    }
}
