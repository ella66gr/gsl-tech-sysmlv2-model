// Fixture platform model for the generation package tests. Not real platform content.
package ShopPlatformFixture {
    private import ScalarValues::*;

    package Concepts {
        enum def Grade {
            doc /* A platform enum, used by a platform part def. */
            basic;
            premium;
        }

        part def Party {
            attribute partyName : String;
            attribute grade : Grade;
        }

        part def Tag {
            doc /* Same name as the tenant's own Tag. */
            attribute code : String;
        }

        part def Unused {
            attribute note : String;
        }
    }
}
