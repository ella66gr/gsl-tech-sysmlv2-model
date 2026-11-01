// Fixture tenant for the generation package tests. Not a real tenant.
package FixtureShop {
    private import ScalarValues::*;
    private import BusinessMetamodelGeneral::CanonicalRuntime::*;

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

        doc /* Fixture status axes. stage has a same-instance precondition
             * on its readyToCollected move. */

        part stageAxis : StatusAxis {
            :>> axisName = "stage";
            :>> axisDescription = "Fixture stage axis; cancelled is a terminal branch.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide, AxisAuthority::systemSide);
            :>> defaultValue = "placed";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::orderedEnum;
                :>> enumValues = ("placed", "inPreparation", "ready", "collected", "cancelled");
            }

            part placedToInPreparation : AxisTransition {
                :>> fromValue = "placed";
                :>> toValue = "inPreparation";
                :>> transitionLabel = "Start work";
                :>> triggerEvent = "Started";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
            part inPreparationToReady : AxisTransition {
                :>> fromValue = "inPreparation";
                :>> toValue = "ready";
                :>> transitionLabel = "Finish work";
                :>> triggerEvent = "Finished";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::systemSide);
            }
            part readyToCollected : AxisTransition {
                :>> fromValue = "ready";
                :>> toValue = "collected";
                :>> transitionLabel = "Hand over";
                :>> triggerEvent = "Collected";
                :>> requiredAuthority = (AxisAuthority::operatorSide);

                part settled : AxisPrecondition {
                    :>> requiredAxis = "payment";
                    :>> requiredValues = ("paid", "waived");
                    :>> rejectionReason = "The ticket is not settled.";
                }
            }
            part placedToCancelled : AxisTransition {
                :>> fromValue = "placed";
                :>> toValue = "cancelled";
                :>> transitionLabel = "Withdraw";
                :>> triggerEvent = "Withdrawn";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
            part inPreparationToCancelled : AxisTransition {
                :>> fromValue = "inPreparation";
                :>> toValue = "cancelled";
                :>> transitionLabel = "Withdraw";
                :>> triggerEvent = "Withdrawn";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
        }

        part paymentAxis : StatusAxis {
            :>> axisName = "payment";
            :>> axisDescription = "Fixture payment axis; one move has no triggerEvent.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide, AxisAuthority::systemSide);
            :>> defaultValue = "unpaid";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::orderedEnum;
                :>> enumValues = ("unpaid", "paid", "waived");
            }

            part unpaidToPaid : AxisTransition {
                :>> fromValue = "unpaid";
                :>> toValue = "paid";
                :>> transitionLabel = "payment received";
                :>> triggerEvent = "Paid";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }
            part unpaidToWaived : AxisTransition {
                :>> fromValue = "unpaid";
                :>> toValue = "waived";
                :>> transitionLabel = "Waive";
            }
        }
    }

    part def TicketTask {
        doc /* Fixture related instance: a precondition through relatedVia. */
        ref ticket : Ticket;

        part workAxis : StatusAxis {
            :>> axisName = "work";
            :>> axisDescription = "Fixture work axis.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide, AxisAuthority::systemSide);
            :>> defaultValue = "waiting";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::orderedEnum;
                :>> enumValues = ("waiting", "working", "done");
            }

            part waitingToWorking : AxisTransition {
                :>> fromValue = "waiting";
                :>> toValue = "working";
                :>> transitionLabel = "Begin task";
                :>> triggerEvent = "TaskBegun";
                :>> requiredAuthority = (AxisAuthority::operatorSide);

                part ticketUnderWay : AxisPrecondition {
                    :>> relatedVia = "ticket";
                    :>> requiredAxis = "stage";
                    :>> requiredValues = ("inPreparation", "ready");
                    :>> rejectionReason = "The ticket is not under way.";
                }
            }
            part workingToDone : AxisTransition {
                :>> fromValue = "working";
                :>> toValue = "done";
                :>> transitionLabel = "task done";
                :>> triggerEvent = "TaskDone";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }
        }
    }
}
