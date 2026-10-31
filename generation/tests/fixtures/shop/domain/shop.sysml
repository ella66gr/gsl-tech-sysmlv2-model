// Fixture tenant for the generation package tests. Not a real tenant.
package FixtureShop {
    private import ScalarValues::*;
    private import TicketLifeCycle::*;

    doc /* A fixture: the words action def and state def in this doc
         * must not be read as declarations. { braces } too. */

    enum def Size {
        doc /* The first member follows a doc block. */
        small;
        large;
    }

    part def Tag {
        attribute label : String;
    }

    part def Item {
        doc /* An item. */
        attribute name : String;
        attribute price : Real;   // a trailing comment
        part tags : Tag [0..*];
        part lines : Tag[1..*];
    }

    part def Badge :> ShopPlatformFixture::Concepts::Tag {
        attribute shown : Boolean;
    }

    part def Ticket :> Item {
        attribute count : Integer;
        attribute note : String[0..1];
        ref owner : Item;
        ref payer : ShopPlatformFixture::Concepts::Party;
        exhibit state lifecycle : TicketLifecycle;
    }
}
