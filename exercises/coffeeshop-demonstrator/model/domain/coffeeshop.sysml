package CoffeeShop {
    private import ScalarValues::*;
    private import OrderLifeCycle::*;

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
        ref item : MenuItem;
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

    enum def OrderStatus {
        placed;
        inPreparation;
        ready;
        collected;
        cancelled;
    }

    part def OrderLine {
        doc /* A single line on an order - one item with its quantity.
             * A line may name who it is for (H-0486): a free-text
             * beneficiary label, with an optional contact reference.
             * Both are optional; most lines carry neither. */
        
        attribute quantity : Integer;
        ref item : MenuItem;
        attribute beneficiaryLabel : String[0..1];
        attribute beneficiaryContactRef : String[0..1];
    }

    part def Order {
        doc /* A customer order, containing one or more order lines.
             * The participant placing the order (orderingParty) and the
             * service subject are carried as separate fields, both typed
             * by the General defs. For a walk-in Cafe the two coincide;
             * both are carried so that surface work generalises (H-0630). */

        attribute orderNumber : Integer;
        attribute status : OrderStatus;
        attribute totalPrice : Real;            // ScalarValue::Real

        ref orderingParty : BusinessMetamodelGeneral::ServiceConcept::ServiceParticipant;
        ref serviceSubject : BusinessMetamodelGeneral::ServiceConcept::ServiceSubject;
        part lines : OrderLine[1..*];  // An order must have at least one line

        exhibit state orderLifecycle : OrderLifecycle; // The `exhibit` keyword says that this part performs (exhibits) this behaviour. Each Order has its own instance of the OrderLifecycle state machine, which tracks the state of that order.
    }
}
