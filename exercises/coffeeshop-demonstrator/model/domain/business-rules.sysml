package BusinessRules {
    private import ScalarValues::*;
    private import CoffeeShop::*;

    doc /* Requirements and constraints governing CoffeeShop operations. */

    // -- Requirements -------------------------------------

    requirement def LoyaltyDiscountRequired {
        doc /* Members of the loyalty scheme must receive
             * a minimum 10% discount on every order. */

        subject order : Order;
    }

    requirement def MinimumOrderSize {
        doc /* Orders must contain at least one item. */

        subject order : Order;
    }

    requirement def MaximumOrderSize {
        doc /* Orders must contain no more than 10 items
             * to avoid barista overload. */

        subject order : Order;
    }

    requirement def veganMilkDrinkRule {
        doc /* Any drink marked as vegan must not use
             * dairy milk — only oat, soy, or almond. */

        subject drink : Drink;
    }

    requirement def BaristaMinimumHours {
        doc /* Staff members in the barista role must be
             * contracted for at least 12 hours per week. */

        subject staff : StaffMember;
    }

    // -- Constraints ------------------------------------

    constraint def LoyaltyDiscountConstraint {
        doc /* Formalises the loyalty discount rule:
             * if the customer is a member, discount >= 10%. */

        in isMember : Boolean;
        in discount : Real;

        isMember implies discount >= 10.0
    }

    constraint def OrderSizeConstraint {
        doc /* Formalises the order size rules:
             * quantity of items must be between 1 and 10. */

        in lineCount : Integer;

        lineCount >= 1 and lineCount <= 10
    }

    constraint def VeganMilkConstraint {
        doc /* Formalises the vegan milk rule:
             * if the drink is vegan, milk choice must not be dairy. */

        in isVegan : Boolean;
        in milkChoice : MilkOption;

        isVegan implies (
            milkChoice == MilkOption::oat or
            milkChoice == MilkOption::soy or
            milkChoice == MilkOption::almond or
            milkChoice == MilkOption::none
        )

    }

    constraint def BaristaHoursConstraint {
        doc /* Baristas must work at least 12 hours per week. */

        in role : StaffRole;
        in hoursPerWeek : Real;

        role == StaffRole::barista implies hoursPerWeek >= 12  

    }
}
