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

    part def ExternalReference {
        doc /* A link to knowledge that lives outside the system.
             * The system does not own this data; it points to it.
             * Examples: SPC, BNF entry, NICE guidance, supplier
             * datasheet, origin certification. */
        attribute referenceType : String;
        attribute referenceId : String;
        attribute referenceSource : String;
        attribute referenceNotes : String;
    }

    part def MenuItem {
        doc /* Something the shop sells. Describes intrinsic product
             * characteristics only. Price and availability are
             * business decisions that live on CatalogueEntry. */

        attribute name : String;
        attribute category : ItemCategory;
        attribute isVegan : Boolean;
        attribute description : String;
        part externalRefs : ExternalReference [0..*];
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

    part def CatalogueEntry {
        doc /* The business decision to offer an item for sale.
             * References an item definition (MenuItem or specialisation)
             * and adds business-context properties: price, availability,
             * provision type. A single item may appear in multiple
             * catalogues at different prices or terms. */
        ref item : MenuItem;
        attribute pricePence : Integer;
        attribute priceDisplay : String;
        attribute availability : AvailabilityStatus;
        attribute provisionType : ProvisionType;
        attribute effectiveDate : String;
        attribute statusNotes : String;
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
        doc /* A single line on an order - one item with its quantity */
        
        attribute quantity : Integer;
        ref item : MenuItem;
    }

    part def Order {
        doc /* A customer order, containing one or more order lines */

        attribute orderNumber : Integer;
        attribute status : OrderStatus;
        attribute totalPrice : Real;            // ScalarValue::Real

        ref customer : Customer;
        part lines : OrderLine[1..*];  // An order must have at least one line

        exhibit state orderLifecycle : OrderLifecycle; // The `exhibit` keyword says that this part performs (exhibits) this behaviour. Each Order has its own instance of the OrderLifecycle state machine, which tracks the state of that order.
    }
}
