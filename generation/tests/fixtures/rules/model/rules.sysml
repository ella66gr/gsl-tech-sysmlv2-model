package FixtureTenant {
    private import ScalarValues::*;

    package FixtureRequirements {
        requirement def StaffPresent;
        requirement def WithinCapacity;
    }

    package Rules {
        constraint def StaffPresentConstraint {
            doc /* At least one member of staff is present. */
            in staffPresent : Boolean;
            staffPresent
        }

        constraint def WithinCapacityConstraint {
            doc /* The booking does not exceed capacity. */
            in booked : Integer;
            in capacity : Integer;
            booked <= capacity
        }

        constraint staffPresentCheck : StaffPresentConstraint;
        constraint capacityCheck : WithinCapacityConstraint;

        satisfy requirement FixtureRequirements::StaffPresent
            by staffPresentCheck;
        satisfy requirement FixtureRequirements::WithinCapacity
            by capacityCheck;
    }

    package RuleSpecs {
        part staffSpec : ConstraintEvaluationSpec {
            doc /* Evaluate staff presence. */
            attribute :>> constraintName = "StaffPresentConstraint";
            attribute :>> requirementName = "StaffPresent";
            attribute :>> severity = Severity::critical;
        }
        part capacitySpec : ConstraintEvaluationSpec {
            attribute :>> constraintName = "WithinCapacityConstraint";
            attribute :>> requirementName = "WithinCapacity";
            attribute :>> severity = Severity::warning;
        }
        part tableSpec : DecisionTableEvaluationSpec {
            attribute :>> tableName = "CapacityBands";
            attribute :>> description = "Capacity bands";
        }
    }
}
