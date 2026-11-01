// OP-136 spike fixture (S519, spike/op-136-opensysml; never merged).
//
// Types that get their status axes through `:>` from a type that declares
// them, which generation/status_axes.py does not read (it reads axes only on
// the def that declares them). Platform-neutral names; not tenant content.
//
//   Ticket          declares the progress axis (two moves, one with a
//                   cross-axis precondition through the ref `desk`)
//   Desk            declares the staffing axis the precondition reads
//   UrgentTicket    :> Ticket, declares no axis: inherits progress and desk
//   EscalatedTicket :> UrgentTicket: inherits them two levels down
//   ReopenableTicket :> Ticket, redefines progressAxis to add one move;
//                   its values, default and other moves are inherited

package InheritFixture {
    private import ScalarValues::*;
    private import BusinessMetamodelGeneral::CanonicalRuntime::*;

    part def Desk :> CanonicalRuntimeType {
        doc /* A desk that tickets are worked at. */

        part staffingAxis : StatusAxis {
            :>> axisName = "staffing";
            :>> axisDescription = "Whether the desk is staffed.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide);
            :>> defaultValue = "unstaffed";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::unorderedEnum;
                :>> enumValues = ("unstaffed", "staffed");
            }

            part unstaffedToStaffed : AxisTransition {
                :>> fromValue = "unstaffed";
                :>> toValue = "staffed";
                :>> transitionLabel = "someone sits down";
                :>> triggerEvent = "DeskStaffed";
            }

            part staffedToUnstaffed : AxisTransition {
                :>> fromValue = "staffed";
                :>> toValue = "unstaffed";
                :>> transitionLabel = "the desk is left";
                :>> triggerEvent = "DeskLeft";
            }
        }
    }

    part def Ticket :> CanonicalRuntimeType {
        doc /* A unit of work. Declares the progress axis. */

        ref desk : Desk;

        part progressAxis : StatusAxis {
            :>> axisName = "progress";
            :>> axisDescription = "How far the work has got.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide, AxisAuthority::systemSide);
            :>> defaultValue = "open";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::orderedEnum;
                :>> enumValues = ("open", "working", "done");
            }

            part openToWorking : AxisTransition {
                :>> fromValue = "open";
                :>> toValue = "working";
                :>> transitionLabel = "work starts";
                :>> triggerEvent = "WorkStarted";
                :>> requiredAuthority = (AxisAuthority::operatorSide);

                part deskStaffed : AxisPrecondition {
                    :>> relatedVia = "desk";
                    :>> requiredAxis = "staffing";
                    :>> requiredValues = ("staffed");
                    :>> rejectionReason = "Work cannot start at an unstaffed desk.";
                }
            }

            part workingToDone : AxisTransition {
                :>> fromValue = "working";
                :>> toValue = "done";
                :>> transitionLabel = "work finishes";
            }
        }
    }

    part def UrgentTicket :> Ticket {
        doc /* Inherits every axis and ref of Ticket; declares none. */

        attribute priority : Integer;
    }

    part def EscalatedTicket :> UrgentTicket {
        doc /* Inherits Ticket's axes two levels down. */
    }

    part def ReopenableTicket :> Ticket {
        doc /* Redefines progressAxis to add one move, done back to
             * working. Its values, default and other moves are Ticket's.
             * (A subtype cannot change the default: Ticket binds it with
             * `=`, which a redefinition may not override.) */

        part :>> progressAxis {
            part doneToWorking : AxisTransition {
                :>> fromValue = "done";
                :>> toValue = "working";
                :>> transitionLabel = "work is reopened";
                :>> triggerEvent = "WorkReopened";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
        }
    }
}
