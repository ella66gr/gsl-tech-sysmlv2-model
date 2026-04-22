// =========================================================================
// CANONICAL RUNTIME — BMM General vocabulary for multi-axis status primitive
// =========================================================================
//
// Session 255 — First implementation of W-094 (multi-axis status primitive).
// Source specification: ontara-model-multi-axis-status-primitive-2026-04-22
// (Session 253 paper). Stratum-and-side locus: Metamodel stratum, business
// side (BMM General). Per the strengthened A4 (business metamodel concept).
//
// Scope of this file:
//   - CanonicalRuntimeType: base part def for every canonical runtime type,
//     carrying the platform-provided epistemic axis (S253 §4.5).
//   - StatusAxis: BMM General part def naming a single dimension of status
//     on a canonical runtime type (S253 §3).
//   - Supporting types: ValueSpace, AxisTransition, AxisAuthority, AxisScope,
//     EpistemicModality, ValueSpaceShape.
//   - Epistemic axis declaration and its four platform-defined transitions
//     (S253 §5.4; simulatedModality has no outbound transitions).
//
// Out of scope for this session:
//   - E6 generator extension for axis-aware semantics (S253 §6).
//   - OWL axiomatisation (S253 §3.7) — second pass after parse confirmed.
//   - Cross-axis consequence rule vocabulary (S253 §6).
//   - Tenant declarations beyond Paws Booking (carried in paws.sysml).
//
// Verified syntax patterns used:
//   - :>> attribute redefinition (v3.5).
//   - :>> multi-valued tuple (v3.13, v3.19).
//   - Nested :>> inside contained part usages (verified S255 via
//     test-nested-redefinition.sysml, Tests A/B/C).
//   - Part def specialisation :> (throughout).
//   - Metadata annotations alongside :>> (v3.7).
//
// Naming: `valueShape` (not `shape`) per S255 finding that `shape` shadows
//   Items::Item::shape through the standard library inheritance chain.
//
// Annotation note: This first-pass implementation uses @UserFacing only,
// plus @BfoType on the core types. @PurposiveDescription and @Comprehension
// will be added in a subsequent pass once the structural core parses cleanly,
// with attribute names and values reviewed against the actual metadata def
// declarations in Foundation::MetadataLibrary.
//
// =========================================================================

package CanonicalRuntime {
    private import ScalarValues::*;
    private import Foundation::MetadataLibrary::*;

    doc /* BMM General canonical-runtime vocabulary. Defines
         * CanonicalRuntimeType (the base for every type whose runtime
         * instances live in DBR or DSR), StatusAxis (a single named
         * dimension of status on a canonical runtime type), and the
         * supporting vocabulary (ValueSpace, AxisTransition,
         * AxisAuthority, AxisScope, ValueSpaceShape).
         *
         * Stratum-and-side locus: Metamodel stratum, business side.
         * These are business meta model concepts — structural vocabulary
         * for what canonical runtime types look like, not tenant
         * configuration. Tenant declarations of specific axes (Paws
         * Booking lifecycle axis, Cafe Order lifecycle axis, etc.) are
         * Configured-Model stratum content and live with the tenant.
         *
         * Source: S253 specification paper (ontara-model-multi-axis-
         * status-primitive-2026-04-22). This file is the first
         * implementation landing of W-094. */

    // =====================================================================
    // ENUMS — Axis scope, authority classes, epistemic modality values,
    // value space shapes
    // =====================================================================

    enum def AxisScope {
        doc /* Distinguishes platform-provided built-in axes from
             * tenant-declared axes.
             *
             * platformBuiltIn: the epistemic axis; present on every
             *   canonical runtime instance without tenant declaration.
             * tenantDeclared: the axis is declared by a specific tenant
             *   on a specific canonical type. */
        platformBuiltIn;
        tenantDeclared;
    }

    enum def AxisAuthority {
        doc /* Declares which party or component may write to an axis.
             * Mirrors the binding-class vocabulary at B60 (BRL).
             *
             * A write through the wrong binding class is a constraint
             * violation; the canonical-edge contract (B61) enforces
             * the declaration uniformly. Multi-valued attributes of
             * this type are used where more than one party may
             * legitimately write (e.g. both customer-side and
             * operator-side for a confirmation axis).
             *
             * Values:
             * - operatorSide: HMB with an operator role.
             * - customerSide: HMB with customer identity.
             * - systemSide: MRB (substrate-internal mapping) or ESB
             *     (foreign-system events).
             * - inferenceSide: IGB writes under declared assumptions.
             * - syntheticSide: SGB writes during a simulation run.
             * - platformSide: platform machinery writes at the
             *     substrate seam (epistemic axis primarily). */
        operatorSide;
        customerSide;
        systemSide;
        inferenceSide;
        syntheticSide;
        platformSide;
    }

    enum def EpistemicModality {
        doc /* The B17 value space. Under S253 §4.5, the epistemic axis
             * is a platform-provided built-in axis on every canonical
             * runtime instance inherited from CanonicalRuntimeType.
             *
             * B17 retains its normative role for the epistemic axis
             * specifically; B72 generalises the axis-wise pattern that
             * B17 exemplifies.
             *
             * Values:
             * - actualModality: real occurrence, primary authority.
             * - inferredModality: derived under declared assumptions.
             * - expectedModality: anticipated but not yet occurred.
             * - predictedModality: projected by a reasoner or model.
             * - hypotheticalModality: counterfactual or scenario-only.
             * - simulatedModality: produced by a simulation run (SGB).
             * - retrospectivelyRecorded: authority-post-hoc insert for
             *     an earlier time. */
        actualModality;
        inferredModality;
        expectedModality;
        predictedModality;
        hypotheticalModality;
        simulatedModality;
        retrospectivelyRecorded;
    }

    enum def ValueSpaceShape {
        doc /* The three shapes a StatusAxis value space may take.
             * Selected when the axis is declared (S253 §3.2).
             *
             * - unorderedEnum: a set of named values with no implicit
             *     ordering. Cancellation axis is a typical case.
             * - orderedEnum: a totally-ordered sequence. Lifecycle axes
             *     use this. Admits unordered branches (a "returned for
             *     rework" value sits outside the ordering).
             * - structuredValue: a typed compound (numeric with unit,
             *     timestamp, tagged union). Retained for v1+1
             *     extensions — v1 axes are all enumerations. */
        unorderedEnum;
        orderedEnum;
        structuredValue;
    }

    // =====================================================================
    // SUPPORTING PART DEFS — ValueSpace, AxisTransition
    // =====================================================================

    part def ValueSpace {
        doc /* The permitted values for a StatusAxis, plus the shape
             * (ordered / unordered / structured) that determines how
             * the values relate to one another.
             *
             * For enumeration shapes, the `enumValues` multi-valued
             * attribute holds the permitted value strings. For the
             * structured shape, a tenant-authored spec describes the
             * compound type; not exercised at v1.
             *
             * `valueShape` not `shape` — `shape` is shadowed by
             * Items::Item::shape through standard library inheritance.
             *
             * Business meta model concept. */
        attribute valueShape : ValueSpaceShape;
        attribute enumValues : String[0..*];
        attribute structuredSpec : String;
    }

    part def AxisTransition {
        doc /* A permitted value-to-value transition on a single axis.
             *
             * Declared transitions are exhaustive for the axis — any
             * (fromValue, toValue) pair not represented by an
             * AxisTransition in the permitted set is a prohibited
             * transition. Attempts at prohibited transitions are
             * rejected at write time by the canonical-edge contract
             * with a category-error explanation.
             *
             * Cross-axis preconditions and consequences are specified
             * in S253 §6 and will be added in a subsequent session
             * (not in scope for S255 first implementation).
             *
             * Business meta model concept. */
        attribute fromValue : String;
        attribute toValue : String;
        attribute transitionLabel : String;
        attribute requiredAuthority : AxisAuthority[0..*];
    }

    // =====================================================================
    // STATUS AXIS — B71 primitive
    // =====================================================================

    part def StatusAxis {
        @UserFacing {
            friendlyName = "Status Axis";
            shortDescription = "A single named dimension of status on a canonical runtime type.";
        }

        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A StatusAxis is a structural information artefact specifying a dimension of runtime status; it is generically dependent on the canonical runtime type that declares it.";
        }

        doc /* B71 — StatusAxis as a BMM General part def.
             *
             * A StatusAxis instance declares WHAT A SINGLE DIMENSION
             * OF STATUS LOOKS LIKE: its value space, its permitted
             * transitions, its default, its authority, its scope.
             *
             * A canonical runtime type declares N StatusAxis part
             * usages (one per dimension of status it carries). Runtime
             * instances of that canonical type carry a value for each
             * declared axis; the tuple is persisted in the SRS as one
             * triple per axis (S253 §4.2).
             *
             * Source: S253 §3.1 (internal structure), §3.2 (value-space
             * shapes), §3.3 (permitted transitions), §3.4 (authority),
             * §3.5 (default value), §3.6 (SysML projection).
             *
             * Business meta model concept. */

        attribute axisName : String;
        attribute axisDescription : String;
        attribute axisScope : AxisScope;
        attribute axisAuthority : AxisAuthority[1..*];
        attribute defaultValue : String;

        part valueSpace : ValueSpace;
        part permittedTransitions : AxisTransition[0..*];
    }

    // =====================================================================
    // CANONICAL RUNTIME TYPE — Base for every canonical type
    // =====================================================================

    part def CanonicalRuntimeType {
        @UserFacing {
            friendlyName = "Canonical Runtime Type";
            shortDescription = "Base type for every canonical runtime type (DBR or DSR content).";
        }

        @BfoType {
            bfoClass = "IndependentContinuant";
            midLevelClass = "BFO:IndependentContinuant";
            mappingNotes = "CanonicalRuntimeType is the structural parent for types whose runtime instances live in DBR (business-side continuant trajectories) or DSR (system-side occurrent log). The BFO classification of a concrete canonical type is carried by its own @BfoType annotation; this parent establishes only the platform-level shape.";
        }

        doc /* Base part def for every canonical runtime type — types
             * whose runtime instances live in DBR (business-side
             * continuant trajectories) or DSR (system-side occurrent
             * log).
             *
             * Carries the platform-provided epistemic axis as an
             * inherited part usage (S253 §4.5). Tenant-declared axes
             * are added by the specialising canonical type.
             *
             * Under B69 (indistinguishability), real and simulated
             * activity produce structurally identical SRS content
             * modulo the epistemicAxis value. The SGB writes
             * simulatedModality; the HMB writes actualModality;
             * everything else in the axis tuple is identical in shape
             * and handling.
             *
             * Types that declare no additional axes are still
             * first-class (S253 §4.6) — they get the epistemic axis
             * uniformly and degrade gracefully (substrate queries
             * return the single axis; comprehension shows only
             * epistemic; no axis-gated transitions).
             *
             * Business meta model concept. */

        part epistemicAxis : StatusAxis {
            :>> axisName = "epistemic";
            :>> axisDescription = "The epistemic modality of this canonical runtime instance. Built-in; present on every canonical runtime type. Distinguishes real, inferred, expected, predicted, hypothetical, simulated, and retrospectively-recorded content.";
            :>> axisScope = AxisScope::platformBuiltIn;
            :>> axisAuthority = (AxisAuthority::platformSide);
            :>> defaultValue = "actualModality";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::unorderedEnum;
                :>> enumValues = ("actualModality", "inferredModality", "expectedModality",
                                  "predictedModality", "hypotheticalModality",
                                  "simulatedModality", "retrospectivelyRecorded");
            }

            // Platform-defined transitions (S253 §5.4). Four transitions;
            // simulatedModality has no outbound transitions — a simulated
            // instance never becomes actual.
            part expectedToActual : AxisTransition {
                :>> fromValue = "expectedModality";
                :>> toValue = "actualModality";
                :>> transitionLabel = "expected occurrence realised";
                :>> requiredAuthority = (AxisAuthority::platformSide);
            }

            part predictedToActual : AxisTransition {
                :>> fromValue = "predictedModality";
                :>> toValue = "actualModality";
                :>> transitionLabel = "prediction confirmed by observation";
                :>> requiredAuthority = (AxisAuthority::platformSide);
            }

            part hypotheticalToActual : AxisTransition {
                :>> fromValue = "hypotheticalModality";
                :>> toValue = "actualModality";
                :>> transitionLabel = "hypothetical materialised to canonical history";
                :>> requiredAuthority = (AxisAuthority::platformSide);
            }

            part actualToRetrospective : AxisTransition {
                :>> fromValue = "actualModality";
                :>> toValue = "retrospectivelyRecorded";
                :>> transitionLabel = "authority-post-hoc observation inserted";
                :>> requiredAuthority = (AxisAuthority::platformSide);
            }
        }
    }
}
