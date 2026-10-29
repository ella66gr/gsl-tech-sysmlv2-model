// =========================================================================
// PROJECTION METADATA — The generators' own annotation schema
// =========================================================================
//
// Session 514 — OP-125 canon pass, Step 2 (ADR-011 §4.7, decision 7).
// The SysML `Foundation` package was dissolved by meaning. The only part
// that survives as a unit is this annotation schema, the metadata the
// projection and the generators run on. It was `Foundation::MetadataLibrary`
// (the catalogue, comprehension, weighted-relationship and BFO-grounding
// annotations). It is projection apparatus and belongs to no layer; it is
// FGZ (Formalism Governance Zone) machinery, not content of any layer.
//
// History of the annotations themselves is kept in the section comments
// below, unchanged from foundation.sysml.
//
// =========================================================================

package ProjectionMetadata {
    private import ScalarValues::*;

    doc /* The annotation schema the projection and the generators run on:
         * @CatalogueTag, @UserFacing, @PurposiveDescription, @Comprehension,
         * @WeightedRelationship (with RelationshipStrength) and @BfoType.
         *
         * Projection apparatus, belonging to no layer (ADR-011 §4.7). The
         * generators read these annotations to produce console data, the
         * concept graph, and the OWL projection; @BfoType reaches BFO and
         * CCO IRIs through the lookup tables in ontology/config/.
         *
         * Formerly Foundation::MetadataLibrary (S514, OP-125). The clinical,
         * governance, openEHR and agency annotations that shared that
         * package were not projection apparatus and did not move here. */

    // -- Catalogue and comprehension metadata -----------------
    // Added Session 38: Ontara Stage 2 Phase 1.
    // Source: ontara-discussion-element-grouping-viewpoints-
    //   comprehension-2026-03-19.md §9.1
    // Meta model: Business System (placed in Foundation
    // MetadataLibrary as cross-cutting metadata).

    metadata def CatalogueTag {
        doc /* Catalogue classification metadata for dynamic
             * grouping and filtering. Applied to any element
             * that should appear in the Component Catalogue.
             *
             * Each attribute represents a classification
             * dimension. New dimensions are added as new
             * attributes when needed.
             *
             * bmmConcern: which BMM concern this element belongs
             *   to (ServiceConcept, ActivityModel,
             *   ResourceCapability, FinancialModel, Governance).
             *   Named 'bmmConcern' because 'concern' triggers a
             *   Syside parsing error (not a KerML reserved word
             *   but treated as one by the parser).
             * classification: General (domain-agnostic) or
             *   Tailored (domain-specific). May evolve to a
             *   multi-tiered scheme.
             *
             * One @CatalogueTag per element. The generator
             * reads all attributes and produces a faceted
             * structure in JSON.
             *
             * System meta model concept. */
        attribute bmmConcern : String;
        attribute classification : String;
    }

    metadata def UserFacing {
        doc /* Human-readable metadata for the comprehension layer.
             * Applied to any element that should be comprehensible
             * to non-specialist users of the Ontara Console.
             *
             * friendlyName: a short, lay-language name
             *   (e.g. "Pricing Model" for PricingModel).
             * shortDescription: a brief explanation (1-2 sentences)
             *   in plain language.
             *
             * Generated into the console as tooltips, glossary
             * entries, and info panel content. Consistent with
             * I14 (comprehension layer) and A3 (model generates
             * everything).
             *
             * System meta model concept. */
        attribute friendlyName : String;
        attribute shortDescription : String;
    }

    metadata def PurposiveDescription {
        doc /* Authored purposive description for the comprehension
             * layer. Explains what this element means for a service
             * business and what the system does with it — the
             * "why should I care?" and "what happens when I define
             * one of these?" explanation.
             *
             * Register 1 (authored comprehension content). Distinct
             * from @UserFacing (labels and short tooltips) and
             * @Comprehension (traversal instructions for dynamically
             * assembled content).
             *
             * Style: purposive, systemic, second-person, contract
             * language. See phase-3-draft-descriptions for the
             * style guide.
             *
             * System meta model concept.
             * Intrinsic self-knowledge principle (A10).
             * Session 49 — Stage 3 Phase 3, Step 2. */
        attribute description : String;
    }

    metadata def Comprehension {
        doc /* Comprehension traversal schema. Declares which
             * categories of dynamically assembled content the
             * comprehension engine should surface for this
             * element.
             *
             * The annotation is a recipe — it declares what to
             * show, not what to say. The generator reads these
             * flags and discovers structural facts from the live
             * model at generation time.
             *
             * 3b approach (Session 49, S49-D4): declarative
             * flags with smart generator. The annotation is
             * lightweight; the intelligence is in the
             * generator's traversal logic.
             *
             * surfaceEnumValues: show associated enum values
             *   discovered via attribute type matching.
             * surfaceDomainInstantiations: show cross-domain
             *   usage counts and instance names.
             * surfaceRelatedConcepts: show structurally related
             *   elements (same-package siblings for pilot;
             *   typed refs in future per O25).
             * surfaceAttributes: show the element's own
             *   attributes with their types.
             *
             * System meta model concept.
             * Intrinsic self-knowledge principle (A10).
             * Unity principle (A11).
             * Session 50 — Stage 3 Phase 3, Step 3. */
        attribute surfaceEnumValues : Boolean;
        attribute surfaceDomainInstantiations : Boolean;
        attribute surfaceRelatedConcepts : Boolean;
        attribute surfaceAttributes : Boolean;
    }

    // -- Weighted relationship metadata -----------------------
    // Added Session 51: Ontara Stage 3 Phase 3, Step 4.
    // Source: ontara-stage-3-plan-phase-3-implementation-2026-03-20.md §4 (Step 4)
    // Design: Option B — one annotation per relationship,
    //   multiple same-metaclass annotations per element.
    //   Verified v3.17: stacking up to 6 annotations works.
    // Meta model: Business System (cross-cutting metadata).

    enum def RelationshipStrength {
        doc /* Ordinal classification of interaction effect strength
             * between related elements. Starting point for the
             * weighted relationship model (B14).
             *
             * Designed for hybrid evolution: ordinal now, numeric
             * weights later, structural derivation baseline with
             * human overrides (J12 — experimentation before
             * convention).
             *
             * System meta model concept. Unity principle
             * (A11): same weights inform comprehension, reasoning,
             * simulation, governance, and assembly guidance. */
        strong;
        moderate;
        weak;
        contextual;
    }

    metadata def WeightedRelationship {
        doc /* Declares a weighted relationship from the annotated
             * element to a named target element. Each annotation
             * declares one relationship. Multiple annotations of
             * this metaclass may be applied to a single element
             * (verified v3.17, Session 51).
             *
             * target: name of the related element (String for now;
             *   migration to typed ref per O25 is the architectural
             *   direction).
             * strength: ordinal classification of the interaction
             *   effect. Typed as RelationshipStrength enum.
             * rationale: brief explanation of why this weight was
             *   assigned.
             *
             * Annotation ordering convention (Position A, prefix):
             *   @CatalogueTag → @UserFacing → @PurposiveDescription
             *   → @Comprehension → @WeightedRelationship (multiple)
             *
             * System meta model concept.
             * Unity principle (A11). Weighted relationships (B14).
             * Non-constraining (J3): ordinal weights designed for
             * hybrid evolution to numeric/structural derivation.
             * Session 51 — Stage 3 Phase 3, Step 4. */
        attribute target : String;
        attribute strength : RelationshipStrength;
        attribute rationale : String;
    }

    // -- BFO ontological grounding metadata ---------------
    // Added Session 98: Knowledge graph architecture (Session 97).
    // Source: ontara-discussion-bfo-type-mapping-2026-04-01.md
    // Meta model: Business System (cross-cutting metadata).

    metadata def BfoType {
        doc /* BFO ontological grounding annotation. Declares the
             * BFO 2020 category and mid-level ontology parent for
             * a BMM or SMM element.
             *
             * This annotation is the input to Stage 2 of the
             * OWL mapping pipeline — the classification step that
             * determines how each SysML element projects into the
             * knowledge graph's domain graph stratum.
             *
             * bfoClass: the BFO 2020 class name. Uses the standard
             *   BFO label (e.g. "Role", "Process", "Quality",
             *   "GenericallyDependentContinuant"). Validated against
             *   the loaded BFO OWL file at pipeline Stage 4.
             * midLevelClass: the CCO, IAO, OGMS, or other mid-level
             *   ontology class that this element maps to. Uses
             *   prefix:ClassName format (e.g. "CCO:ActOfServiceProvision",
             *   "IAO:InformationContentEntity"). Empty string if no
             *   mid-level mapping is identified yet.
             * mappingNotes: brief rationale for the classification,
             *   especially where the mapping is non-obvious or where
             *   alternatives were considered.
             *
             * Annotation ordering convention (Position A, prefix):
             *   @CatalogueTag → @BfoType → @UserFacing →
             *   @PurposiveDescription → @Comprehension →
             *   @WeightedRelationship (multiple)
             *
             * Ontological grounding (B18, B19). OWL 2 DL (B23).
             * Knowledge graph (B22). Mapping ontology (B24).
             * Domain-semantic mapping (Session 97 D6).
             * System meta model concept.
             * Session 98. */
        attribute bfoClass : String;
        attribute midLevelClass : String;
        attribute mappingNotes : String;
    }
}
