// =========================================================================
// SYNTAX TEST: Inline vs prefix annotation placement on part def
//
// Purpose: Resolve the inconsistency between `canonical-runtime.sysml`
//          (which places @UserFacing and @BfoType *inside* the part def
//          body) and `business-model.sysml` (which places ALL six
//          annotations *before* the part def declaration).
//
//          Specifically: do @CatalogueTag, @PurposiveDescription,
//          @Comprehension, and @WeightedRelationship parse when applied
//          INSIDE a part def body, the way @UserFacing and @BfoType
//          evidently do in canonical-runtime.sysml?
//
// Context: W-116 (canonical-runtime.sysml annotation completion).
//          Session 277. Resolves the placement choice before completing
//          the deferred annotation pass first noted at S255.
//
// Background:
//   - business-model.sysml: ALL annotations placed BEFORE part def
//     (the "prefix" or "Position A" convention noted in the BfoType
//     metadata def doc block, Foundation::MetadataLibrary).
//   - canonical-runtime.sysml (S255): @UserFacing and @BfoType placed
//     INSIDE part def body. S255 verified parses cleanly in Syside.
//   - Whether the other four annotations also parse inside the body
//     is unverified — the S255 author noted that @PurposiveDescription
//     and @Comprehension would be "added in a subsequent pass once
//     the structural core parses cleanly", deferring the question.
//
// What to check in Syside:
//   TEST A (control): All six annotations applied as PREFIX (before the
//           part def declaration). This is the business-model.sysml
//           pattern — verified working. Included as a baseline.
//   TEST B: @UserFacing and @BfoType inline (S255 pattern), other four
//           annotations as prefix. Mixed style — what canonical-runtime
//           would look like if we leave the existing inline annotations
//           in place and add the missing four as prefix.
//   TEST C: ALL six annotations applied INLINE (inside the part def
//           body). The "fully inline" extension of the S255 pattern.
//           This is the test that resolves whether inline placement
//           generalises to all six annotations or is specific to
//           @UserFacing and @BfoType.
//   TEST D: ALL six annotations applied INLINE, with multiple
//           @WeightedRelationship to mirror the realistic case (≥1
//           weighted relationships per BMM General element).
//
// For each test, check:
//   1. Does the file parse without errors?
//   2. Do all annotations show correct types on hover?
//   3. Are all annotation attribute values accessible?
//   4. Does the outline view show all annotations?
//
// Expected outcomes (informally):
//   - Test A: passes (matches verified business-model.sysml pattern).
//   - Test B: expected to pass — inline @UserFacing + @BfoType is
//       the S255 verified pattern; prefix @CatalogueTag etc. is the
//       business-model verified pattern; combining the two should not
//       introduce new parser interactions.
//   - Test C: the resolving test. If passes, inline placement works
//       generally; canonical-runtime's existing pattern can be
//       completed inline. If fails (parse error, attribute shadowing,
//       feature-not-found, or metaclass-binding error), inline
//       placement does NOT generalise — Option A (move all to prefix)
//       is the answer.
//   - Test D: same as Test C but with the multi-WeightedRelationship
//       case. Could fail if same-metaclass stacking interacts with
//       inline placement differently from prefix placement.
//
// Recommendation will be made AFTER this test passes or fails in Syside.
// =========================================================================

package SyntaxTestInlineVsPrefixAnnotation {
    private import ScalarValues::*;

    doc /* Syntax test: inline vs prefix annotation placement on
         * part def. Session 277 — resolves W-116 placement question. */

    // -- Supporting definitions ----------------------------------
    // Mirror the production metadata defs and enum from
    // Foundation::MetadataLibrary so this test is self-contained
    // (matches the convention of test-multiple-same-metaclass-
    // annotations.sysml, which mirrors RelationshipStrength and
    // WeightedRelationship locally).

    enum def RelationshipStrength {
        doc /* Mirrors Foundation::MetadataLibrary::RelationshipStrength. */
        strong;
        moderate;
        weak;
        contextual;
    }

    metadata def CatalogueTag {
        doc /* Mirrors Foundation::MetadataLibrary::CatalogueTag. */
        attribute bmmConcern : String;
        attribute classification : String;
    }

    metadata def BfoType {
        doc /* Mirrors Foundation::MetadataLibrary::BfoType. */
        attribute bfoClass : String;
        attribute midLevelClass : String;
        attribute mappingNotes : String;
    }

    metadata def UserFacing {
        doc /* Mirrors Foundation::MetadataLibrary::UserFacing. */
        attribute friendlyName : String;
        attribute shortDescription : String;
    }

    metadata def PurposiveDescription {
        doc /* Mirrors Foundation::MetadataLibrary::PurposiveDescription. */
        attribute description : String;
    }

    metadata def Comprehension {
        doc /* Mirrors Foundation::MetadataLibrary::Comprehension. */
        attribute surfaceEnumValues : Boolean;
        attribute surfaceDomainInstantiations : Boolean;
        attribute surfaceRelatedConcepts : Boolean;
        attribute surfaceAttributes : Boolean;
    }

    metadata def WeightedRelationship {
        doc /* Mirrors Foundation::MetadataLibrary::WeightedRelationship. */
        attribute target : String;
        attribute strength : RelationshipStrength;
        attribute rationale : String;
    }

    // -- TEST A: ALL annotations as PREFIX (control) -------------
    // The business-model.sysml pattern. Should parse cleanly.

    @CatalogueTag {
        bmmConcern = "TestConcern";
        classification = "General";
    }
    @BfoType {
        bfoClass = "GenericallyDependentContinuant";
        midLevelClass = "IAO:InformationContentEntity";
        mappingNotes = "Test A control — prefix placement of all six annotations.";
    }
    @UserFacing {
        friendlyName = "Test A Element";
        shortDescription = "Element with all six annotations as prefix.";
    }
    @PurposiveDescription {
        description = "Test A — verifies the verified-working prefix placement pattern parses in this test file as it does in business-model.sysml.";
    }
    @Comprehension {
        surfaceEnumValues = false;
        surfaceDomainInstantiations = true;
        surfaceRelatedConcepts = true;
        surfaceAttributes = true;
    }
    @WeightedRelationship {
        target = "TestBPrefixUserFacing";
        strength = RelationshipStrength::strong;
        rationale = "Test A — single weighted relationship as prefix.";
    }
    part def TestAAllPrefix {
        doc /* Control: all six annotations as prefix.
             * Expected: parses cleanly. */
        attribute name : String;
    }

    // -- TEST B: @UserFacing and @BfoType INLINE, others PREFIX --
    // Mirrors what canonical-runtime.sysml currently looks like
    // (with the S255 inline placement of @UserFacing and @BfoType)
    // if we add the four missing annotations as prefix.

    @CatalogueTag {
        bmmConcern = "TestConcern";
        classification = "General";
    }
    @PurposiveDescription {
        description = "Test B — verifies that mixing prefix CT/PD/Comp/WR with inline UF/Bfo parses cleanly. Combines the two verified-working patterns.";
    }
    @Comprehension {
        surfaceEnumValues = false;
        surfaceDomainInstantiations = true;
        surfaceRelatedConcepts = true;
        surfaceAttributes = true;
    }
    @WeightedRelationship {
        target = "TestAAllPrefix";
        strength = RelationshipStrength::moderate;
        rationale = "Test B — single weighted relationship as prefix; UF and Bfo inline.";
    }
    part def TestBMixed {
        @UserFacing {
            friendlyName = "Test B Element";
            shortDescription = "Element with UserFacing inline, others prefix.";
        }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "Test B — mixed placement: UF and Bfo inline (S255 pattern), others prefix.";
        }
        doc /* Mixed: UF + Bfo inline (S255 verified), others prefix
             * (business-model verified). Expected: parses cleanly. */
        attribute name : String;
    }

    // -- TEST C: ALL six annotations INLINE (resolving test) -----
    // The fully-inline extension of the S255 pattern.
    // This is the test that determines whether inline placement
    // generalises to all six annotation types.

    part def TestCAllInline {
        @CatalogueTag {
            bmmConcern = "TestConcern";
            classification = "General";
        }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "Test C — all six annotations inline. The resolving test.";
        }
        @UserFacing {
            friendlyName = "Test C Element";
            shortDescription = "Element with all six annotations inline.";
        }
        @PurposiveDescription {
            description = "Test C — verifies whether @PurposiveDescription parses inside a part def body. If this fails, inline placement does not generalise beyond UF and Bfo.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "TestAAllPrefix";
            strength = RelationshipStrength::strong;
            rationale = "Test C — single weighted relationship inline. Resolves whether inline @WeightedRelationship parses.";
        }
        doc /* All six annotations inline. The resolving test for
             * W-116. Expected outcome unknown — that is what this
             * test is for. */
        attribute name : String;
    }

    // -- TEST D: ALL six annotations INLINE with multiple WR -----
    // Same as Test C but with the realistic multi-WeightedRelationship
    // case. Tests interaction of inline placement with same-metaclass
    // stacking.

    part def TestDAllInlineMultiWR {
        @CatalogueTag {
            bmmConcern = "TestConcern";
            classification = "General";
        }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "Test D — all six inline with three WeightedRelationships.";
        }
        @UserFacing {
            friendlyName = "Test D Element";
            shortDescription = "Element with all annotations inline plus multiple WR.";
        }
        @PurposiveDescription {
            description = "Test D — combines inline placement with multi-annotation stacking, the realistic case for any BMM General element.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "TestAAllPrefix";
            strength = RelationshipStrength::strong;
            rationale = "Test D — first of three inline weighted relationships.";
        }
        @WeightedRelationship {
            target = "TestBMixed";
            strength = RelationshipStrength::moderate;
            rationale = "Test D — second of three inline weighted relationships.";
        }
        @WeightedRelationship {
            target = "TestCAllInline";
            strength = RelationshipStrength::weak;
            rationale = "Test D — third of three inline weighted relationships.";
        }
        doc /* All six annotations inline plus multiple
             * @WeightedRelationship. Tests whether same-metaclass
             * stacking (verified at prefix in test-multiple-same-
             * metaclass-annotations.sysml) also works inline. */
        attribute name : String;
    }
}
