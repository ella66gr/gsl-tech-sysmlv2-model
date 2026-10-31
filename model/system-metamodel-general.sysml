// =========================================================================
// SYSTEM METAMODEL GENERAL — the system-side General packages
// =========================================================================
//
// OP-132 step 8 (S515, ADR-012 §4.1–4.2). Sector-agnostic system-side
// vocabulary assembled from the former Knowledge package, Platform::EHR,
// and the Foundation groups A, C, D, E, I and J (ADR-011 §4.7). Imports are
// limited by rule R1: General and apparatus only. Tenant and Domain
// content never appears here.
// =========================================================================

package SystemMetamodelGeneral {
    private import ScalarValues::*;

    doc /* The system metamodel, General layer: how the platform evaluates,
         * reasons, persists, annotates process steps, and integrates with
         * the openEHR clinical data repository. Configured by tenants and
         * extended by sector Domain packages (SystemMetamodelDomain<Sector>).
         * Three-tier reasoning stack: Tier 1 deterministic logic
         * (constraints, safety rules), Tier 2 structured decision support
         * (DMN-style tables), Tier 3 ML/LLM-augmented intelligence
         * (advisory only). */

    package ProcessAnnotations {
        private import ScalarValues::*;

        doc /* General annotations on process steps: consent and audit
             * hooks whose meaning is given by reference to the IGF type
             * module (form of that reference still to be set, ADR-011 §4.7),
             * the Tier 1 and Tier 2 evaluation markers (@LogicRule,
             * @DecisionTable, @SafetyConstraint), and the agency
             * classification enum and annotation. Formerly in
             * Foundation's MetadataLibrary (groups A, B, D, E). */

        // -- Clinical pathway metadata --------------------------

        metadata def ConsentRequired {
            doc /* Marks a pathway step as requiring patient consent
                 * before proceeding. */
            attribute consentType : String;
        }

        metadata def AuditPoint {
            doc /* Marks a step that must produce a governance audit
                 * record. */
            attribute auditCategory : String;
        }

        metadata def LogicRule {
            doc /* Marks an element as containing or referencing a
                 * deterministic logic rule for Tier 1 evaluation. */
            attribute ruleName : String;
        }

        metadata def DecisionTable {
            doc /* Marks an element as containing or referencing a
                 * DMN-style decision table for Tier 2 evaluation. */
            attribute tableName : String;
        }

        metadata def SafetyConstraint {
            doc /* Marks a constraint as safety-critical: must be
                 * evaluated and must not be overridden. */
            attribute constraintName : String;
            attribute severity : String;
        }

        // -- Agency classification metadata -----------------------
        // System meta model concepts: annotate pathway
        // action nodes with the agent who performs them.
        // Prerequisite for all four generations of self-service.
        // Added Session 29: CSW Extension Phase 10 (items 9.1, 9.2).
        // Source: gsl-discussion-model-self-service-enabling-
        //   architecture-2026-03-14.md §7
        // Meta model: Business System (placed in Foundation
        // MetadataLibrary as cross-cutting metadata).

        enum def AgencyType {
            doc /* Who performs an action in a pathway. Applies to
                 * both clinical and non-clinical contexts.
                 *
                 * Coffee shop: customer (self-service kiosk), staff
                 * (barista makes drink), automated (order routing),
                 * collaborative (customer and barista discuss).
                 *
                 * Clinical: patientAgent, clinicianAgent, automated,
                 * collaborative (e.g. ICE-supported shared decision).
                 *
                 * System meta model concept.
                 *
                 * NOTE: 'system' is a KerML reserved word and cannot
                 * be used as an enum literal. 'automated' is used
                 * instead. 'patient' and 'clinician' are suffixed
                 * with 'Agent' to avoid potential conflicts. */
            patientAgent;
            clinicianAgent;
            automated;
            collaborative;
        }

        metadata def AgencyClassification {
            doc /* Annotates a pathway action node with the agent who
                 * performs it. Applied via @AgencyClassification on
                 * action usages within action defs.
                 *
                 * The authorityModelVersion attribute records which
                 * generation's authority rules were in effect when
                 * this classification was assigned. Supports
                 * governance traceability as the self-service model
                 * evolves through generations.
                 *
                 * Initial version: "G1-clinician-authority" — all
                 * clinical decisions made by clinician, patient role
                 * is to provide information and give consent.
                 *
                 * System meta model concept.
                 *
                 * Source: gsl-discussion-model-self-service-enabling-
                 *   architecture-2026-03-14.md §7
                 *
                 * SYNTAX NOTE (Session 29): enum-typed attribute on
                 * metadata def. If agencyType : AgencyType fails in
                 * Syside, fall back to agencyType : String. */
            attribute agencyType : AgencyType;
            attribute authorityModelVersion : String;
            attribute agencyNotes : String;
        }
    }

    package StatePatterns {
        private import ScalarValues::*;

        doc /* Reusable lifecycle state machine patterns. Many entities
             * share similar lifecycle shapes (e.g. created -> active ->
             * suspended -> completed -> cancelled). Define once here,
             * specialise in ClinicalEntities and elsewhere.
             *
             * Pattern: define a generic state def, then specialise it
             * for specific entity types with additional states or
             * transitions as needed. */

        // Standard lifecycle events
        attribute def Activated;
        attribute def Suspended;
        attribute def Resumed;
        attribute def Completed;
        attribute def Cancelled;

        state def StandardLifecycle {
            doc /* A generic lifecycle pattern applicable to many entities.
                 * States: created, active, suspended, completed, cancelled.
                 * Specialise for entity-specific variations. */

            initial;
            state created;
            state active;
            state suspended;
            state completed;
            state cancelled;

            transition created_to_active
                first created
                accept Activated
                then active;

            transition active_to_suspended
                first active
                accept Suspended
                then suspended;

            transition suspended_to_active
                first suspended
                accept Resumed
                then active;

            transition active_to_completed
                first active
                accept Completed
                then completed;

            transition active_to_cancelled
                first active
                accept Cancelled
                then cancelled;

            transition created_to_cancelled
                first created
                accept Cancelled
                then cancelled;
        }
    }

    package LogicEngine {
        private import ScalarValues::*;

        doc /* Inference rules, Prolog-style reasoning, deterministic
             * constraint evaluation, and system self-knowledge
             * infrastructure. Explicit architectural space for logic
             * programming.
             *
             * Component inventory:
             * - ConstraintEvaluator: Tier 1 deterministic evaluation
             *   (InputResolver, ExpressionEvaluator, ExplanationBuilder)
             * - OperationalStateAggregator: Layer 2 operational state
             *   queries across Temporal, CDR, platform services, and
             *   accounting systems
             * - GapAnalyser: Layer 4 comparison of operational state
             *   against goal state (GoalProjector)
             * - AssessmentOrchestrator: coordinates five-layer
             *   SystemStateAssessment production (clinical + business)
             * - SelfExplanationService: audience-appropriate rendering
             *   of evaluation results and assessments
             * - EvaluationSpecRegistry: runtime lookup of constraint
             *   evaluation specifications
             * - InferenceEvaluator: Tier 2 interface (Prolog boundary)
             * - AdvisoryInterface: Tier 3 interface (ML/LLM boundary)
             *
             * Data structures (Phase 1):
             * - EvaluationResult, ExplanationTrace, EvaluatedInput
             * - Deficit, SystemStateAssessment
             *
             * Additional structures (Phase 2):
             * - OperationalSnapshot, OperationalQuery
             * - GoalProjection, EvaluationContext
             *
             * Three-tier reasoning stack:
             * Tier 1 — TypeScript constraint evaluator (generated from
             *   SysML). Boolean constraints with structured explanation
             *   traces. Handles ConstraintLibrary evaluation and
             *   Layers 1-4 of self-knowledge.
             * Tier 2 — Embedded Prolog for inference chains,
             *   contraindication cascades, compound deficit reasoning.
             *   Layer 5 compound remediation.
             * Tier 3 — ML/LLM advisory interface. Cannot override
             *   Tier 1/2 logic.
             *
             * Phase 6B: Extended for business steering. The self-knowledge
             * architecture handles financial goals and variances without
             * new part defs — OperationalSnapshot gains financial
             * attributes, SystemStateAssessment gains business structural
             * counters, and OperationalStateAggregator gains a financial
             * data query. GoalProjection and Deficit handle financial
             * goals and variances without modification, validating the
             * architecture as domain-agnostic.
             *
             * Elaborated Session 8 (Phase 1: data structures),
             * Session 9 (Phase 2: component model),
             * Session 18 (Phase 6B: business steering extension). */

        // -- Evaluation and self-knowledge enumerations ----------
        // Formerly in Foundation's CommonTypes (group J, ADR-011 §4.7); their
        // consumers are LogicEngine, EvaluationSpecs and tenant scenarios.

        // --- Evaluation and self-knowledge types ---------------
        // Added Session 8: Knowledge Layer Phase 1

        enum def EvaluationOutcome {
            doc /* Result of evaluating a constraint, rule, or goal.
                 * Three-valued: pass (condition met), fail (condition
                 * not met), indeterminate (insufficient data). */
            pass;
            fail;
            indeterminate;
        }

        enum def Severity {
            doc /* Severity classification for deficits, constraints,
                 * and audit findings. */
            critical;
            warning;
            informational;
        }

        enum def AssessmentScope {
            doc /* Scope at which an evaluation or assessment is
                 * performed. */
            patient;
            cohort;
            pathway;
            domain;
            system;
        }

        enum def DataSourceType {
            doc /* Authoritative data source for input derivation.
                 * Source-agnostic: same InputDerivation structure
                 * works regardless of where data comes from.
                 *
                 * Phase 6B: added accounting for financial actuals
                 * from Xero via Operations::Finance. */
            cdr;         // openEHR CDR via AQL
            temporal;    // Temporal workflow state and history
            platform;    // Platform services (infrastructure, identity)
            entity;      // Entity lifecycle state (XState / Temporal)
            accounting;  // Accounting system (Xero) via a tenant's finance package (GSL: GslOperations, Finance)
        }

        enum def DeficitDomain {
            doc /* Domain classification for a deficit.
                 *
                 * Phase 6B: added financial for deficits arising
                 * from financial variance (revenue shortfall, cost
                 * overrun, margin below forecast). Distinct from
                 * operational (process state) because financial
                 * deficits are about the money flowing through
                 * processes, not the processes themselves. */
            clinical;
            operational;
            infrastructure;
            governance;
            financial;
        }

        enum def RemediationCategory {
            doc /* How a deficit can be addressed. Defines the boundary
                 * between deterministic system action and advisory
                 * output.
                 * automatic: pathway model defines next step, system
                 *   can trigger it.
                 * recommended: specific action identified but requires
                 *   human decision.
                 * advisory: deficit is systemic or compound, system
                 *   surfaces it with supporting data. */
            automatic;
            recommended;
            advisory;
        }

        enum def ServiceHealthStatus {
            doc /* Health status of an infrastructure service. */
            healthy;
            degraded;
            unreachable;
        }

        // =============================================================
        // Evaluation result structures (Phase 1 — Track A)
        // =============================================================

        part def EvaluatedInput {
            doc /* A single input value used in a rule evaluation.
                 * Records what data was used, where it came from,
                 * and how it was derived — supporting the
                 * self-explanation requirement for clinical governance
                 * and patient safety. */
            attribute inputName : String;
            attribute inputValue : String;     // serialised value
            attribute sourceType : DataSourceType;
            attribute sourceQuery : String;    // AQL, Temporal query, or API call
            attribute derivedAt : String;      // ISO datetime
        }

        part def ExplanationTrace {
            doc /* A structured explanation of how a rule evaluation
                 * reached its conclusion. Supports three audiences:
                 * - Clinicians: why did this safety check pass/fail?
                 * - Patients: why am I eligible or not?
                 * - Auditors: trace from outcome through every decision.
                 *
                 * The trace is the clinical governance artefact that
                 * makes the self-explaining requirement concrete. */
            attribute ruleExpression : String;     // the rule as evaluated
            attribute humanExplanation : String;   // plain-language explanation
            part evaluatedInputs : EvaluatedInput[0..*];
        }

        part def EvaluationResult {
            doc /* The atomic unit of knowledge evaluation. Every rule,
                 * at every point in the system, produces one of these.
                 *
                 * EvaluationResults are persisted (CDR or audit log),
                 * queryable, and presentable to clinicians, patients,
                 * and auditors. They are the structured output of
                 * Tier 1 deterministic evaluation.
                 *
                 * The same structure is produced whether the evaluation
                 * is invoked at point-of-care (single patient, single
                 * rule) or in a governance audit (population, multiple
                 * rules). */
            attribute ruleName : String;
            attribute outcome : EvaluationOutcome;
            attribute evaluatedAt : String;          // ISO datetime
            attribute constraintRef : String;        // ConstraintLibrary def name
            attribute requirementRef : String;       // satisfied requirement name
            part explanation : ExplanationTrace;
            part subEvaluations : EvaluationResult[0..*];
        }

        // =============================================================
        // Self-knowledge structures (Phase 1 — Track B)
        // =============================================================

        part def Deficit {
            doc /* A structured record of a gap between the system's
                 * actual operational state and its goal state.
                 * Generalises the Phase D governance audit pattern
                 * from a single rule to any operational dimension.
                 *
                 * Each deficit references the goal it falls short of
                 * (requirement, constraint, outcome definition, or
                 * projection formula), the actual state found, and
                 * the expected state. Supporting EvaluationResult
                 * records provide the evidence chain.
                 *
                 * Deficits are computed, not stored — they are the
                 * output of comparing Layer 2 (operational state)
                 * against Layer 3 (goal state).
                 *
                 * Phase 6B: financial variances are deficits. A
                 * revenue shortfall is a Deficit with deficitDomain =
                 * DeficitDomain::financial. The existing Deficit
                 * structure handles this without modification —
                 * goalReference points to a ProjectionFormula,
                 * actualState and expectedState carry the figures,
                 * and description carries the variance decomposition.
                 * This validates the domain-agnostic design. */
            attribute deficitDomain : DeficitDomain;
            attribute scope : AssessmentScope;
            attribute description : String;
            attribute goalReference : String;
            attribute actualState : String;
            attribute expectedState : String;
            attribute severity : Severity;
            attribute detectedAt : String;          // ISO datetime
            attribute remediationCategory : RemediationCategory;
            attribute remediationDescription : String;
            part supportingEvaluations : EvaluationResult[0..*];
        }

        part def SystemStateAssessment {
            doc /* The composite output of the self-knowledge
                 * infrastructure. Aggregates across all five layers
                 * to produce a whole-system picture: clinical
                 * governance, operational health, and business
                 * performance in a single assessment.
                 *
                 * Not a new data store — computed on demand by
                 * querying existing authoritative sources (Temporal,
                 * CDR, platform services, accounting system) and
                 * running existing evaluation logic.
                 *
                 * Can be scoped: single patient, clinical pathway,
                 * domain, or entire system. Scheduled Temporal cron
                 * workflows produce periodic assessments; on-demand
                 * requests produce point-in-time assessments.
                 *
                 * This is the primary artefact of the self-describing
                 * property: the system's own structured report on
                 * itself.
                 *
                 * Phase 6B: Layer 1 extended with business model
                 * structural counters. Layer 2 OperationalSnapshot
                 * extended with financial state. No changes to
                 * Layers 3-5 — GoalProjection and Deficit already
                 * handle financial goals and variances. */
            attribute assessmentId : String;
            attribute assessedAt : String;          // ISO datetime
            attribute scope : AssessmentScope;
            attribute scopeFilter : String;
            attribute modelVersion : String;

            // Layer 1 — Structural summary (clinical)
            attribute packagesCount : Integer;
            attribute pathwaysCount : Integer;
            attribute constraintsCount : Integer;
            attribute requirementsCount : Integer;
            attribute entityLifecyclesCount : Integer;

            // Layer 1 — Structural summary (business model, Phase 6B)
            attribute serviceOfferingsCount : Integer;
            attribute revenueStreamsCount : Integer;
            attribute scenarioDefinitionsCount : Integer;
            attribute strategicObjectivesCount : Integer;

            // Layer 2 — Operational snapshot
            part operationalSnapshot : OperationalSnapshot;

            // Layer 3 vs Layer 2 — Goal compliance summary
            attribute totalGoals : Integer;
            attribute goalsMet : Integer;
            attribute goalsUnmet : Integer;
            attribute goalsIndeterminate : Integer;

            // Layer 4 — Deficits
            part deficits : Deficit[0..*];

            // Layer 5 — Evaluation evidence
            part evaluationResults : EvaluationResult[0..*];
        }

        // =============================================================
        // Phase 2 — Tier 1 evaluator component (Stage 1)
        // =============================================================

        part def InputResolver {
            doc /* Resolves constraint inputs from authoritative data
                 * sources. For each InputDerivation in a
                 * ConstraintEvaluationSpec, the resolver executes the
                 * specified query against the appropriate source (CDR,
                 * Temporal, platform service), applies the computation
                 * to derive a typed value, and handles fallback if the
                 * query fails or returns no data.
                 *
                 * Source-agnostic: the resolver dispatches based on
                 * the InputDerivation's sourceType attribute. The
                 * query format varies by source (AQL for CDR, API
                 * call for Temporal, HTTP for platform services,
                 * Xero API for accounting) but the resolution pattern
                 * is identical.
                 *
                 * Produces EvaluatedInput records as output — these
                 * feed both the expression evaluator (for the
                 * constraint check) and the explanation builder (for
                 * the audit trace). */
            attribute resolverId : String;
        }

        part def ExpressionEvaluator {
            doc /* Evaluates a constraint's boolean expression given
                 * resolved input values. For Tier 1, this is
                 * straightforward boolean evaluation: the constraint
                 * def's expression is evaluated with the derived
                 * input values substituted.
                 *
                 * Returns an EvaluationOutcome (pass, fail,
                 * indeterminate). Indeterminate arises when one or
                 * more inputs could not be resolved and the fallback
                 * outcome propagates.
                 *
                 * In a future generated implementation, this component
                 * is replaced by generated TypeScript functions — one
                 * per constraint def. The generated function takes
                 * typed inputs and returns the boolean result directly,
                 * with the expression evaluation compiled rather than
                 * interpreted. */
            attribute evaluatorId : String;
        }

        part def ExplanationBuilder {
            doc /* Assembles ExplanationTrace records from the
                 * evaluation context: the resolved inputs
                 * (EvaluatedInput records), the constraint expression
                 * as evaluated, and a human-readable explanation of
                 * the outcome.
                 *
                 * Supports multiple audiences:
                 * - Clinicians: technical but accessible explanation
                 *   of why a safety check passed or failed, with
                 *   data values
                 * - Patients: plain-language explanation suitable for
                 *   self-management interfaces
                 * - Auditors: full formal trace with data provenance
                 * - Business steering: financial variance explanation
                 *   for founder, investor, board (Phase 6B)
                 *
                 * The audience parameter determines explanation depth
                 * and language register. All audiences are views onto
                 * the same underlying EvaluatedInput and expression
                 * data — the difference is presentation, not
                 * content. */
            attribute builderId : String;
        }

        part def ConstraintEvaluator {
            doc /* The Tier 1 deterministic constraint evaluation
                 * component. Consumes ConstraintEvaluationSpecs from
                 * ClinicalDecisionSupport, derives inputs from
                 * authoritative sources (CDR via AQL, Temporal,
                 * platform services), evaluates constraint boolean
                 * expressions, and produces structured
                 * EvaluationResults with full ExplanationTraces.
                 *
                 * This is a generic runtime component: it does not
                 * contain any specific clinical logic. All rule
                 * knowledge comes from the ConstraintLibrary (what
                 * the rule is) and the ConstraintEvaluationSpec
                 * (how to get the data). The evaluator is the
                 * execution engine that connects the two.
                 *
                 * Invocation: pathway action steps annotated with
                 * @LogicRule or @SafetyConstraint generate Temporal
                 * activities that call this component. See
                 * architecture decision document, Section 1.
                 *
                 * Scope: evaluates one constraint for one context
                 * (typically one patient). Population-level
                 * evaluation (governance audit) wraps this in a
                 * loop over a patient cohort — same component,
                 * iterated. */
            attribute evaluatorId : String;

            // --- Capabilities ---
            part inputResolver : InputResolver;
            part expressionEvaluator : ExpressionEvaluator;
            part explanationBuilder : ExplanationBuilder;
        }

        // =============================================================
        // Phase 2 — Operational state aggregator (Stage 2)
        // =============================================================

        part def OperationalQuery {
            doc /* A single operational state query against an
                 * authoritative source. Structurally parallel to
                 * InputDerivation but scoped to operational rather
                 * than clinical data.
                 *
                 * The query returns a structured result (count,
                 * list, or status) rather than a single typed value.
                 * This is a wider interface than InputDerivation,
                 * which derives a single constraint input.
                 *
                 * At runtime, implemented as a TypeScript function
                 * that calls the appropriate API (Temporal client,
                 * EHRbase REST/AQL, platform health endpoint, Xero
                 * accounting API). */
            attribute queryName : String;
            attribute sourceType : DataSourceType;
            attribute query : String;
            attribute description : String;
        }

        part def OperationalSnapshot {
            doc /* A point-in-time capture of the system's operational
                 * state, produced by the OperationalStateAggregator.
                 * This is the Layer 2 content that feeds into gap
                 * analysis and the SystemStateAssessment.
                 *
                 * Not persisted as a separate data store — computed
                 * on demand. The snapshot captures the query results
                 * at a specific moment for comparison against
                 * goals.
                 *
                 * Phase 6B: extended with financial state summary.
                 * The snapshot becomes a combined clinical + business
                 * operational picture — process state, clinical data,
                 * infrastructure health, and financial performance
                 * in a single capture. Financial attributes are at
                 * the same granularity as clinical (totals, not
                 * per-stream breakdown — decomposition is in the
                 * VarianceAnalysis, not the snapshot). */
            attribute capturedAt : String;          // ISO datetime
            attribute scope : AssessmentScope;

            // Process state summary
            attribute activeWorkflows : Integer;
            attribute blockedWorkflows : Integer;
            attribute failedWorkflows : Integer;
            attribute workflowsPastSla : Integer;

            // Clinical data summary
            attribute overdueMonitoringItems : Integer;
            attribute totalActivePatients : Integer;

            // Infrastructure health
            attribute cdrStatus : ServiceHealthStatus;
            attribute temporalStatus : ServiceHealthStatus;
            attribute externalIntegrationsHealthy : Integer;
            attribute externalIntegrationsTotal : Integer;

            // Financial state summary (Phase 6B)
            attribute financialPeriodLabel : String;       // which reporting period
            attribute forecastRevenue : Real;              // projected revenue for this period
            attribute actualRevenue : Real;                // actual revenue recorded
            attribute forecastCost : Real;                 // projected cost for this period
            attribute actualCost : Real;                   // actual cost recorded
            attribute revenueVariance : Real;              // actual - forecast (negative = shortfall)
            attribute costVariance : Real;                 // actual - forecast (negative = over budget)
            attribute activeScenarioRef : String;          // which scenario is the active baseline
        }

        part def OperationalStateAggregator {
            doc /* Queries the system's operational state across all
                 * authoritative data sources: Temporal (process
                 * state), CDR (clinical data state), entity
                 * lifecycle state, platform services (infrastructure
                 * health), and accounting system (financial actuals).
                 *
                 * Uses the same source-agnostic InputDerivation
                 * pattern as the ConstraintEvaluator, but scoped
                 * to operational rather than clinical queries. Each
                 * operational query is an InputDerivation with the
                 * appropriate sourceType.
                 *
                 * Produces a structured OperationalSnapshot — the
                 * Layer 2 content of a SystemStateAssessment.
                 *
                 * Query categories:
                 * - Process state (Temporal): active, blocked,
                 *   failed workflows; workflow step distribution;
                 *   SLA adherence
                 * - Clinical data state (CDR via AQL): composition
                 *   counts by archetype, overdue monitoring items,
                 *   recording completeness
                 * - Entity lifecycle state: counts by entity type
                 *   and state (e.g. 42 active prescriptions,
                 *   7 pending referrals)
                 * - Infrastructure health: CDR reachable, Temporal
                 *   workers running, external integrations
                 *   responding
                 * - Financial actuals (accounting, Phase 6B):
                 *   PeriodActuals from the tenant's accounting system (for GSL, Xero via the Finance package of its operations model).
                 *   Revenue by stream, cost by driver, margin,
                 *   active patient count. Compared against the
                 *   active ForecastBaseline's ProjectionOutput
                 *   for the same period.
                 *
                 * See architecture decision document, Section 3
                 * (Operational State Query Pattern). */
            attribute aggregatorId : String;
            part processStateQuery : OperationalQuery;
            part clinicalDataQuery : OperationalQuery;
            part entityStateQuery : OperationalQuery;
            part infrastructureQuery : OperationalQuery;
            part financialDataQuery : OperationalQuery;
        }

        // =============================================================
        // Phase 2 — Gap analyser (Stage 3)
        // =============================================================

        part def GoalProjection {
            doc /* A single goal projected from the model into a
                 * shape comparable against operational state. The
                 * unit of comparison for gap analysis.
                 *
                 * Each projection names the goal source
                 * (requirement, constraint, outcome definition, or
                 * projection formula), the expected condition, and
                 * the query needed to check actual state. The gap
                 * analyser evaluates the query and compares the
                 * result against the expected condition.
                 *
                 * Phase 6B: financial goals are a fourth goal source.
                 * A forecast figure from a ProjectionFormula is a
                 * goal — "revenue should be £4,200 in month 6" is
                 * structurally identical to "every patient should
                 * have monitoring bloods within 12 weeks." The
                 * GoalProjection structure handles both without
                 * modification: goalSource references a
                 * ProjectionFormula, expectedCondition states the
                 * target, evaluationQuery describes how to check
                 * Xero actuals. */
            attribute goalName : String;
            attribute goalSource : String;         // requirement, constraint, outcome def, or projection formula
            attribute expectedCondition : String;  // human-readable expected state
            attribute evaluationQuery : String;    // query to check actual state
            attribute scope : AssessmentScope;
        }

        part def GoalProjector {
            doc /* Projects goals from model sources (requirements,
                 * constraints, outcome definitions, and projection
                 * formulas) into a comparable shape against
                 * operational state.
                 *
                 * Each goal is expressed as a GoalProjection: an
                 * expected condition that can be evaluated against
                 * actual data. The projection mechanism varies by
                 * source:
                 *
                 * - Requirement goals: "every active patient has
                 *   a LabResult within N weeks" -> AQL query
                 *   counting patients without recent LabResults
                 * - Constraint goals: constraint evaluates to pass
                 *   for every active patient -> batch constraint
                 *   evaluation across cohort
                 * - Outcome goals: "hormone levels within
                 *   therapeutic range at 6-month measurement
                 *   point" -> AQL query against outcome
                 *   compositions
                 * - Financial goals (Phase 6B): "month 6 revenue
                 *   should be £4,200" -> Xero management accounts
                 *   query for the period. The projection formula
                 *   output for a given period becomes a goal.
                 *   This is the structural connection between
                 *   BusinessMetamodelGeneral::BusinessScenarios::ProjectionFormula and the
                 *   self-knowledge architecture.
                 *
                 * The projector does not evaluate goals — it
                 * transforms them into a shape the gap analyser
                 * can compare against operational data. */
            attribute projectorId : String;
        }

        part def GapAnalyser {
            doc /* Compares the system's operational state (Layer 2,
                 * OperationalSnapshot) against its goal state
                 * (Layer 3, projected from requirements,
                 * constraints, outcome definitions, and projection
                 * formulas) and produces Deficit records for every
                 * unmet goal.
                 *
                 * This is the direct generalisation of the Phase D
                 * governance audit: Phase D compared expected
                 * compositions against actual compositions for a
                 * single rule. The gap analyser applies the same
                 * pattern across all defined goals and all
                 * operational dimensions.
                 *
                 * Goal sources:
                 * - Requirements (a tenant's regulation requirement defs) ->
                 *   expected compliance conditions
                 * - Constraints (a tenant's constraint library) ->
                 *   expected evaluation pass outcomes for all
                 *   active patients
                 * - Outcome definitions
                 *   (OutcomeFramework defs, with each tenant's targets) -> expected
                 *   clinical target achievement
                 * - Projection formulas (BusinessScenarios,
                 *   Phase 6B) -> expected financial and activity
                 *   targets per period. A revenue shortfall is
                 *   a Deficit with deficitDomain = financial,
                 *   structurally identical to a clinical
                 *   monitoring gap.
                 *
                 * Each goal is projected as an expected condition.
                 * The analyser evaluates the condition against
                 * operational data and emits a Deficit if the
                 * condition is not met.
                 *
                 * See architecture decision document, Section 4
                 * (Goal State Projection). */
            attribute analyserId : String;
            part goalProjector : GoalProjector;
        }

        // =============================================================
        // Phase 2 — Tier 2 and Tier 3 interfaces (Stage 4)
        // =============================================================

        part def InferenceEvaluator {
            doc /* Tier 2 reasoning interface: inference chains,
                 * contraindication cascades, compound deficit
                 * reasoning, and "why" queries.
                 *
                 * Where Tier 1 (ConstraintEvaluator) evaluates
                 * single boolean constraints, Tier 2 reasons about
                 * relationships between multiple constraints,
                 * deficits, and available actions. This is the
                 * architectural space for Prolog-style logic
                 * programming.
                 *
                 * Key capabilities (interface only, not yet
                 * implemented):
                 *
                 * - Contraindication cascade: given a proposed
                 *   medication, trace through all interaction
                 *   rules, existing medications, and patient
                 *   conditions to produce a compound safety
                 *   assessment with full inference chain
                 * - Compound deficit reasoning: given multiple
                 *   Deficit records, identify interactions
                 *   (e.g. overdue bloods AND missed appointment
                 *   AND expiring prescription), reason about
                 *   priority and sequencing, and produce a
                 *   compound remediation recommendation
                 * - "Why" queries: given an EvaluationResult,
                 *   trace backward through the inference chain
                 *   to explain not just what the result is but
                 *   why the inputs have their current values
                 * - Financial variance inference (Phase 6B):
                 *   given a revenue deficit, chain backward
                 *   through volume, price, mix, and timing
                 *   factors to identify root causes. "Revenue
                 *   is below plan because acquisition is 3/month
                 *   vs projected 4/month" — each link draws on
                 *   the same authoritative data sources.
                 *
                 * Runtime target: Tau Prolog (pure JS, embeddable
                 * in Temporal activities) or SWI-Prolog WASM.
                 * Decision deferred until clinical rules demand
                 * inference beyond Tier 1 boolean constraints.
                 *
                 * Produces EvaluationResults with the same
                 * structure as Tier 1, but subEvaluations may
                 * form deeper trees reflecting the inference
                 * chain. */
            attribute evaluatorId : String;
            attribute reasoningEngine : String;    // e.g. "tau-prolog", "swi-prolog-wasm"
        }

        part def AdvisoryInterface {
            doc /* Tier 3 advisory interface: ML/LLM-augmented
                 * intelligence. Powerful but probabilistic, always
                 * advisory rather than authoritative. Cannot
                 * override Tier 1 or Tier 2 logic.
                 *
                 * Capabilities (interface boundary only):
                 *
                 * - Pattern recognition across patient cohorts
                 * - Natural language processing of unstructured
                 *   clinical notes
                 * - Predictive analytics (trajectory-based dose
                 *   adjustment suggestions, capacity forecasting)
                 * - Literature synthesis for clinical guideline
                 *   updates
                 * - Advisory remediation for systemic deficits
                 *   where no single deterministic action resolves
                 *   the gap
                 *
                 * Architectural constraints:
                 * - All Tier 3 outputs are labelled as advisory
                 * - Tier 3 cannot modify pathway state or trigger
                 *   automatic actions
                 * - Tier 3 outputs are presented alongside (never
                 *   instead of) Tier 1/2 deterministic results
                 * - Clinical validation is required before any
                 *   Tier 3 capability is surfaced to clinicians
                 *   or patients
                 *
                 * Implementation deferred. The interface exists to
                 * ensure the architecture accommodates ML/LLM
                 * capabilities without compromising the
                 * deterministic foundation. */
            attribute interfaceId : String;
            attribute modelType : String;         // e.g. "llm", "ml-classifier", "predictive"
            attribute confidenceThreshold : Real; // minimum confidence for surfacing
        }

        // =============================================================
        // Phase 2 — Self-explanation and orchestration (Stage 5)
        // =============================================================

        part def SelfExplanationService {
            doc /* The API surface through which consumers access the
                 * system's self-knowledge and evaluation
                 * explanations.
                 *
                 * Five consumer categories, each with different
                 * needs:
                 *
                 * - Clinician UI: point-of-care evaluation results
                 *   with clinical context. "Why did this safety
                 *   check fail?" with data values and rule
                 *   references.
                 * - Patient portal: plain-language explanations
                 *   for self-management. "Why am I eligible / not
                 *   eligible?" with actionable guidance.
                 * - Governance dashboard: population-level
                 *   assessment summaries, deficit inventories,
                 *   compliance rates, trend analysis over
                 *   assessment history.
                 * - Audit endpoint: full formal traces with data
                 *   provenance, constraint references, requirement
                 *   traceability. Exportable for regulatory
                 *   submission.
                 * - Business steering (Phase 6B): financial
                 *   variance explanations for founder, investor,
                 *   board. "Revenue is below forecast because
                 *   patient acquisition is running at 3/month vs
                 *   projected 4/month." Same structured explanation
                 *   pattern as clinical governance, different
                 *   audience and presentation.
                 *
                 * All five are views onto the same underlying data
                 * (EvaluationResults, SystemStateAssessments). The
                 * service applies audience-appropriate filtering,
                 * explanation depth, and presentation format.
                 *
                 * Implements the ExplainEvaluationResult use
                 * case. */
            attribute serviceId : String;
        }

        part def AssessmentOrchestrator {
            doc /* Orchestrates the production of
                 * SystemStateAssessments by coordinating the other
                 * LogicEngine components.
                 *
                 * Assessment production sequence:
                 * 1. Read System Model Manifest for Layer 1
                 *    (structural summary — packages, pathways,
                 *    constraints, service offerings, revenue
                 *    streams, scenario definitions)
                 * 2. Invoke OperationalStateAggregator for Layer 2
                 *    (operational snapshot — clinical state AND
                 *    financial actuals from accounting system)
                 * 3. Invoke GoalProjector for Layer 3 (project all
                 *    in-scope goals — clinical compliance,
                 *    outcome targets, AND financial forecasts
                 *    from projection formulas)
                 * 4. Invoke GapAnalyser for Layer 4 (compare
                 *    Layers 2 and 3, produce Deficit records for
                 *    clinical gaps AND financial variances)
                 * 5. Classify each Deficit's remediation category
                 *    for Layer 5
                 * 6. For Tier 1 deficits with deterministic
                 *    remediation, identify the specific pathway
                 *    action step
                 * 7. For compound deficits, optionally invoke
                 *    InferenceEvaluator (Tier 2) for reasoning
                 * 8. Assemble the composite SystemStateAssessment
                 *
                 * The combined assessment covers both clinical
                 * governance and business performance in a single
                 * artefact. This is the operational expression of
                 * the meta-modelling document section 4.7 insight:
                 * operational steering is a domain extension of
                 * self-knowledge, not a parallel build.
                 *
                 * Invocation patterns (from architecture decision
                 * document, Section 6):
                 * - On-demand: platform API call, scoped by caller
                 * - Scheduled: Temporal cron workflow (daily
                 *   clinical governance, weekly operational health,
                 *   monthly business steering review)
                 * - Triggered: critical deficit in point-of-care
                 *   evaluation triggers broader scoped assessment
                 *
                 * Implements the ProduceSystemStateAssessment use
                 * case. The orchestrator itself is a natural
                 * candidate for a Temporal workflow — it
                 * coordinates multiple queries and evaluations
                 * that may take non-trivial time. */
            attribute orchestratorId : String;
            ref constraintEvaluator : ConstraintEvaluator;
            ref operationalAggregator : OperationalStateAggregator;
            ref gapAnalyser : GapAnalyser;
            ref explanationService : SelfExplanationService;
        }

        // =============================================================
        // Phase 2 — Registry and context (Stage 6)
        // =============================================================

        part def EvaluationSpecRegistry {
            doc /* A runtime registry of ConstraintEvaluationSpecs,
                 * loaded from the model (or generated as a
                 * TypeScript module) at system startup.
                 *
                 * The registry resolves constraint names to their
                 * full evaluation specifications: which inputs to
                 * derive, from which sources, with what
                 * computations, and what fallback behaviour. This
                 * is the lookup table that the ConstraintEvaluator
                 * consults when invoked.
                 *
                 * Generation approach (from architecture decision
                 * document, Section 1):
                 * - A generator reads ConstraintEvaluationSpec
                 *   part usages from
                 *   a tenant's clinical decision support package (for GSL, the ClinicalDecisionSupport package of its knowledge model)
                 * - It produces a TypeScript module exporting a
                 *   map from constraint name to spec object
                 * - The registry loads this module at startup
                 *
                 * This replaces the need to parse SysML at
                 * runtime. The registry is a static, generated
                 * artefact — it changes only when the model is
                 * updated and the generator re-run. */
            attribute registryId : String;
            attribute specCount : Integer;
            attribute modelVersion : String;
        }

        part def EvaluationContext {
            doc /* The runtime context for a single evaluation
                 * invocation. Captures the scope (which patient,
                 * which pathway step), the trigger (point-of-care,
                 * governance audit, triggered assessment), and any
                 * ambient data already available (to avoid
                 * redundant queries).
                 *
                 * Passed to the ConstraintEvaluator alongside the
                 * ConstraintEvaluationSpec. The evaluator uses the
                 * context to parameterise InputDerivation queries
                 * (e.g. substituting the patient's EHR ID into
                 * AQL). */
            attribute contextId : String;
            attribute patientId : String;
            attribute pathwayStepRef : String;
            attribute triggerType : String;        // point-of-care, governance-audit, triggered
            attribute scope : AssessmentScope;
        }

        // =============================================================
        // Use cases (Phase 1 defs, Phase 2 elaboration)
        // =============================================================

        use case def EvaluateConstraint {
            doc /* Evaluate a single constraint for a specific
                 * patient or context.
                 *
                 * Component allocation:
                 * 1. EvaluationSpecRegistry resolves the constraint
                 *    name to its ConstraintEvaluationSpec
                 * 2. InputResolver derives each input from its
                 *    authoritative source per the spec
                 * 3. ExpressionEvaluator evaluates the constraint
                 *    boolean expression with derived inputs
                 * 4. ExplanationBuilder assembles the
                 *    ExplanationTrace
                 * 5. ConstraintEvaluator composes the
                 *    EvaluationResult
                 *
                 * Invoked by:
                 * - Temporal activities generated from pathway
                 *   steps annotated with @LogicRule or
                 *   @SafetyConstraint
                 * - Governance audit workflows iterating over a
                 *   patient cohort
                 * - Triggered assessment when a deficit is
                 *   detected
                 *
                 * Produces: one EvaluationResult with full
                 * ExplanationTrace per invocation. */
        }

        use case def PerformGapAnalysis {
            doc /* Compare operational state against goal state for
                 * a defined scope (patient, pathway, domain,
                 * system).
                 *
                 * Component allocation:
                 * 1. GoalProjector projects all in-scope goals
                 *    from requirements, constraints, outcome
                 *    definitions, and projection formulas
                 * 2. OperationalStateAggregator captures current
                 *    state (or receives a pre-computed
                 *    OperationalSnapshot)
                 * 3. GapAnalyser compares each GoalProjection
                 *    against operational data
                 * 4. For each unmet goal, a Deficit record is
                 *    produced with severity, remediation category,
                 *    and supporting EvaluationResult evidence
                 *
                 * Scope determines breadth:
                 * - Patient: all goals applicable to one patient
                 * - Pathway: all goals for a specific clinical
                 *   pathway
                 * - Domain: all goals within a domain (clinical,
                 *   operational, infrastructure, financial)
                 * - System: all goals across all domains
                 *
                 * Produces: a set of Deficit records. */
        }

        use case def ProduceSystemStateAssessment {
            doc /* Aggregate structural self-knowledge, operational
                 * state, goal compliance, deficits, and
                 * remediation recommendations into a composite
                 * SystemStateAssessment.
                 *
                 * Component allocation: AssessmentOrchestrator
                 * coordinates the full five-layer assembly:
                 * - Layer 1: reads System Model Manifest
                 *   (structural — clinical and business model)
                 * - Layer 2: invokes OperationalStateAggregator
                 *   (clinical state + financial actuals)
                 * - Layer 3: invokes GoalProjector (clinical
                 *   goals + financial forecasts)
                 * - Layer 4: invokes GapAnalyser (clinical
                 *   deficits + financial variances)
                 * - Layer 5: classifies remediation categories
                 *
                 * Three invocation triggers:
                 * - On-demand: API call from clinician or admin UI
                 * - Scheduled: Temporal cron workflow
                 * - Triggered: critical deficit escalation
                 *
                 * Produces: one SystemStateAssessment covering
                 * both clinical governance and business
                 * performance. */
        }

        use case def ExplainEvaluationResult {
            doc /* Given an EvaluationResult or
                 * SystemStateAssessment, produce an
                 * audience-appropriate explanation.
                 *
                 * Component allocation: SelfExplanationService
                 * renders the underlying data (EvaluatedInputs,
                 * ExplanationTraces, Deficit records) into the
                 * appropriate format for the requesting consumer.
                 *
                 * Audience rendering:
                 * - Clinician: data values, rule references,
                 *   clinical context, recommended actions
                 * - Patient: plain-language explanation, actionable
                 *   guidance, self-management prompts
                 * - Auditor: full trace, data provenance,
                 *   requirement traceability, exportable format
                 * - Dashboard: summary statistics, trend
                 *   indicators, deficit inventory, compliance
                 *   rates
                 * - Business steering (Phase 6B): financial
                 *   variance decomposition, forecast-vs-actual
                 *   comparison, re-baseline recommendations */
        }
    }

    package EvaluationSpecs {
        private import ScalarValues::*;
        private import SystemMetamodelGeneral::LogicEngine::*;  // Severity, DataSourceType

        doc /* Decision rules, eligibility criteria, monitoring protocols,
             * and clinical guidelines modelled as evaluable constraints.
             * Consumes CDR data via AQL queries, evaluates against
             * model-derived rules, and surfaces results to pathways
             * and clinician/patient interfaces.
             *
             * Separates "what the rule is" (ConstraintLibrary) from
             * "how to get the data for the rule" (here). Each
             * constraint def has a corresponding ConstraintEvaluationSpec
             * that binds it to its input derivations. Decision tables
             * in DecisionModels have corresponding
             * DecisionTableEvaluationSpecs following the same pattern.
             *
             * Goal-state projection:
             * The GoalProjector (LogicEngine) consumes three goal
             * sources: requirements (a tenant's regulation requirement defs),
             * constraint evaluation specs (here), and outcome
             * definitions (the OutcomeFramework package). Outcome
             * definitions are self-contained — they specify both
             * the target and the evaluation query, so a separate
             * evaluation spec is not needed for them.
             *
             * Elaborated Session 8 (Phase 1: constraint specs),
             * Session 10 (Phase 3: decision table specs),
             * Session 11 (Phase 4: goal-state projection note). */

        // =============================================================
        // Input derivation pattern
        // =============================================================

        part def InputDerivation {
            doc /* Defines how a single constraint input is derived
                 * from an authoritative data source. The pattern is
                 * source-agnostic: the same structure describes AQL
                 * queries against the CDR, Temporal workflow state
                 * queries, and platform service API calls.
                 *
                 * Each input in a constraint def has a corresponding
                 * InputDerivation that specifies the query,
                 * computation, and fallback behaviour. This formalises
                 * what the ConstraintLibrary doc blocks describe
                 * narratively. */
            attribute inputName : String;
            attribute sourceType : DataSourceType;
            attribute query : String;
            attribute computation : String;
            attribute fallbackOutcome : EvaluationOutcome;
            attribute fallbackReason : String;
        }

        part def ConstraintEvaluationSpec {
            doc /* Binds a constraint definition to its input
                 * derivations, forming a complete evaluation
                 * specification. This is the unit that the evaluation
                 * engine consumes: it knows which constraint to
                 * evaluate and how to get every input.
                 *
                 * Separates "what the rule is" (ConstraintLibrary)
                 * from "how to get the data" (here). */
            attribute constraintName : String;
            attribute requirementName : String;
            attribute severity : Severity;
            part inputDerivations : InputDerivation[0..*];
        }

        // =============================================================
        // Decision table evaluation specifications
        //
        // Parallel to ConstraintEvaluationSpecs, these bind decision
        // tables to their input derivations. The same InputDerivation
        // pattern applies: each table input is derived from an
        // authoritative data source.
        // =============================================================

        part def DecisionTableEvaluationSpec {
            doc /* Binds a decision table to its input derivations
                 * and evaluation metadata, parallel to
                 * ConstraintEvaluationSpec for constraints.
                 *
                 * The tableName matches the @DecisionTable metadata
                 * annotation on pathway steps. The evaluation
                 * infrastructure resolves the name to this spec,
                 * derives inputs, evaluates the table, and returns
                 * the matching row's outputs. */
            attribute tableName : String;
            attribute description : String;
            part inputDerivations : InputDerivation[0..*];
        }

    }

    package DecisionModels {
        private import ScalarValues::*;

        doc /* DMN-style decision tables modelled as SysML part defs
             * with typed inputs, outputs, and row-level rules.
             * Deterministic and auditable — clinicians can read and
             * validate the tables directly from the model.
             *
             * SysML v2 does not define a decision table as a first-class
             * language element. The v2 spec expects tabular decision
             * logic to be represented using general-purpose constructs
             * (part defs, constraints, views) with domain-specific
             * methodology layered on top. This package implements that
             * approach.
             *
             * Representation pattern:
             * - DecisionTableDef: abstract table interface with
             *   common metadata (name, hit policy, description)
             * - Concrete table part defs specialise DecisionTableDef
             *   and declare typed input and output attributes
             * - Table rows are part usages of a row def, with :>>
             *   attribute redefinitions providing the concrete input
             *   conditions and output values
             *
             * Decision tables are a specialised form of constraint
             * evaluation. The @DecisionTable metadata annotation on
             * pathway steps triggers evaluation via the same
             * ConstraintEvaluator infrastructure in LogicEngine.
             * The table recommends an output; the clinician makes
             * the final decision at a @ClinicalReviewGate.
             *
             * Two decision tables for the hormone therapy pathway:
             * - regimenSelection: baseline data to medication, route,
             *   starting dose
             * - stabilityAssessment: monitoring data to stability
             *   classification, monitoring action
             *
             * Elaborated Session 10: Knowledge Layer Phase 3. */

        // =============================================================
        // Decision table pattern definitions
        // =============================================================

        enum def HitPolicy {
            doc /* How a decision table resolves when evaluating.
                 * Based on DMN hit policy semantics.
                 * unique: exactly one row must match (error otherwise)
                 * firstMatch: rows are ordered, first match wins
                 * collect: all matching rows contribute to output */
            unique;
            firstMatch;
            collect;
        }

        part def DecisionTableDef {
            doc /* Abstract definition for a decision table. Concrete
                 * tables specialise this with their specific input
                 * and output attributes.
                 *
                 * Each table has a name (matching the @DecisionTable
                 * annotation in the pathway), a hit policy, and a
                 * description of its clinical purpose.
                 *
                 * This part def provides common metadata; it is
                 * not intended to be instantiated directly. */
            attribute tableName : String;
            attribute hitPolicy : HitPolicy;
            attribute tableDescription : String;
        }

    }

    package OutcomeFramework {
        private import ScalarValues::*;
        private import SystemMetamodelGeneral::LogicEngine::*;          // Severity
        private import SystemMetamodelGeneral::OpenEhrIntegration::*;   // @OpenEhrArchetype
        private import ProjectionMetadata::*;

        doc /* Outcome definitions, measurement points, structured outcome
             * capture, and outcome-to-pathway feedback for clinical
             * outcome measurement.
             *
             * Records not just that a patient was treated, but the specific
             * regimen, monitoring results at defined intervals, whether
             * clinical targets were achieved, and any adverse events. Over
             * time this builds a dataset that informs pathway refinement
             * via LearningCycles.
             *
             * Architectural role — outcomes are goals:
             * Each OutcomeDefinition implies an expected state. The
             * GoalProjector (LogicEngine) projects outcome
             * definitions into GoalProjections. The GapAnalyser compares
             * actual outcome data (from CDR) against these projections and
             * produces Deficit records for unmet outcomes. This connects
             * OutcomeFramework directly to the five-layer self-knowledge
             * architecture (Phase 1) — outcomes are the third goal source
             * alongside requirements (a tenant's regulation requirement defs) and
             * constraints (a tenant's constraint library).
             *
             * Data capture — outcomes are CDR compositions:
             * Outcome measurements are captured as openEHR compositions
             * in the CDR via the same two data paths validated in the CDR
             * exercise: workflow-driven (Temporal activities commit
             * compositions during pathway execution) and form-driven
             * (clinician records outcome data directly). The outcome
             * framework defines which compositions constitute outcomes,
             * at which measurement points, and against which targets.
             *
             * Feedback loop — outcomes drive pathway refinement:
             * Aggregated outcome data feeds into LearningCycles:
             * capture structured outcomes → analyse patterns → propose
             * pathway refinement → clinical governance review → update
             * model → regenerate. The model is the mechanism for both
             * capturing and enacting the learning.
             *
             * Elaborated Session 11: Knowledge Layer Phase 4.
             * Connects to Phase 1 (self-knowledge data structures),
             * Phase 2 (GoalProjector, GapAnalyser), and Phase 3
             * (decision tables that consume outcome-derived inputs). */

        // -- Outcome enumerations ---------------------------------
        // Moved here from Foundation's CommonTypes at S514 (OP-125,
        // ADR-011 §4.7). Used only by this package; defined here
        // since Session 11 for it.


        enum def OutcomeCategory {
            doc /* Category of a clinical outcome measure.
                 * Determines which outcomes are collected at
                 * each measurement point and how they are
                 * reported. */
            clinical;
            adherence;
            safety;
            patientReported;
        }

        enum def OutcomeStatus {
            doc /* Status of an individual outcome measurement
                 * against its defined target.
                 * pending: measurement due but not yet taken
                 * measured: data collected, not yet evaluated
                 * targetMet: evaluated and within target
                 * targetNotMet: evaluated and outside target
                 * indeterminate: data insufficient for evaluation */
            pending;
            measured;
            targetMet;
            targetNotMet;
            indeterminate;
        }

        enum def MeasurementFrequency {
            doc /* How often an outcome is measured. Determines
                 * which measurement points include this outcome. */
            baseline;
            threeMonthly;
            sixMonthly;
            annually;
            adHoc;
        }

        enum def ComparisonOperator {
            doc /* How a target value is compared against an actual
                 * measurement. Used in OutcomeDefinition to specify
                 * the target condition.
                 * within: actual falls within a range (uses
                 *   targetValue and targetUpperBound)
                 * greaterThan: actual exceeds a threshold
                 * lessThan: actual is below a threshold
                 * equalTo: actual matches exactly */
            within;
            greaterThan;
            lessThan;
            equalTo;
        }

        // =============================================================
        // Core structural definitions
        // =============================================================

        part def OutcomeDefinition {
            doc /* A defined clinical outcome with target criteria and
                 * measurement specification.
                 *
                 * Each outcome definition specifies:
                 * - What is being measured (name, description, category)
                 * - What the target is (value, range, comparison operator)
                 * - How often it is measured (frequency)
                 * - How to query the CDR for actual data (evaluation query)
                 *
                 * Outcome definitions are the input to goal-state
                 * projection. The GoalProjector transforms each
                 * definition into a GoalProjection that the GapAnalyser
                 * evaluates against CDR data.
                 *
                 * Concrete outcomes are modelled as part usages with
                 * :>> attribute redefinitions, following the
                 * ConstraintEvaluationSpec and decision table row
                 * patterns established in Phases 1 and 3. */
            attribute outcomeName : String;
            attribute description : String;
            attribute category : OutcomeCategory;
            attribute frequency : MeasurementFrequency;
            attribute targetOperator : ComparisonOperator;
            attribute targetValue : String;
            attribute targetUpperBound : String;
            attribute targetUnit : String;
            attribute evaluationQuery : String;
            attribute severity : Severity;
        }

        part def MeasurementPoint {
            doc /* A defined point in time at which outcome measurements
                 * are collected. Each measurement point specifies when
                 * it occurs (weeks from treatment initiation), what
                 * outcomes are assessed, and what the clinical focus is.
                 *
                 * Measurement points are contained within a
                 * MeasurementSchedule. At runtime, the evaluation
                 * infrastructure checks whether due measurement points
                 * have corresponding CDR data — a missing measurement
                 * at a due point produces an adherence deficit. */
            attribute pointName : String;
            attribute timingWeeksFromInitiation : Integer;
            attribute description : String;
            attribute isRepeating : Boolean;
            attribute repeatIntervalWeeks : Integer;
        }

        part def MeasurementSchedule {
            doc /* A complete measurement schedule for a clinical
                 * pathway. Defines the sequence of measurement points
                 * and associates each point with the outcomes to be
                 * measured.
                 *
                 * One schedule per pathway. The schedule is the bridge
                 * between the pathway's temporal structure (when things
                 * happen) and the outcome framework's measurement
                 * structure (what to measure and when). */
            attribute scheduleName : String;
            attribute pathwayRef : String;
            attribute description : String;
            part measurementPoints : MeasurementPoint[0..*];
        }

        part def OutcomeEvaluationResult {
            @OpenEhrArchetype {
                archetypeId = "openEHR-EHR-EVALUATION.outcome_assessment.v0";
                rmClass = "EVALUATION";
            }
            doc /* The result of evaluating an outcome measurement
                 * against its target. Links the outcome definition,
                 * the patient, the measurement point, the actual
                 * value obtained, and whether the target was met.
                 *
                 * Structurally parallel to EvaluationResult in
                 * LogicEngine — both are structured, auditable
                 * records of a comparison against an expected state.
                 * The key difference is that EvaluationResult records
                 * a point-in-time constraint check, while
                 * OutcomeEvaluationResult records a longitudinal
                 * clinical outcome measurement.
                 *
                 * At runtime, these are persisted as CDR compositions
                 * or audit records, queryable for governance reporting
                 * and patient-facing outcome summaries. */
            attribute outcomeRef : String;
            attribute patientId : String;
            attribute measurementPointRef : String;
            attribute measuredAt : String;
            attribute actualValue : String;
            attribute actualUnit : String;
            attribute outcomeStatus : OutcomeStatus;
            attribute clinicianNotes : String;
        }

        // =============================================================
        // Outcome-to-LearningCycles feedback interface
        // =============================================================

        part def OutcomeFeedbackRecord {
            doc /* A structured record linking aggregated outcome data
                 * to a pathway refinement proposal. This is the
                 * interface between OutcomeFramework and LearningCycles.
                 *
                 * When outcome patterns are identified (e.g. a
                 * significant proportion of patients not reaching
                 * target at 6 months on a particular regimen), the
                 * pattern is captured as a feedback record that
                 * feeds into LearningCycles::ProposePathwayRefinement.
                 *
                 * The feedback record is not an automatic trigger —
                 * it surfaces the pattern with supporting data for
                 * clinical governance review. The decision to modify
                 * the pathway or protocol is a human governance
                 * decision, consistent with the remediation boundary
                 * principle (automatic / recommended / advisory). */
            attribute feedbackId : String;
            attribute patternDescription : String;
            attribute affectedOutcome : String;
            attribute affectedPathway : String;
            attribute cohortSize : Integer;
            attribute observationPeriod : String;
            attribute proposedAction : String;
            attribute severity : Severity;
            attribute detectedAt : String;
        }

    }

    package LearningCycles {
        private import ScalarValues::*;

        doc /* Pathway refinement process, evidence review, change control
             * governance. Itself modelled as an action flow.
             *
             * Cycle: capture structured outcomes → analyse patterns →
             * propose pathway refinement → clinical governance review →
             * update model → regenerate. The model is the mechanism for
             * both capturing and enacting the learning.
             *
             * Input from OutcomeFramework:
             * OutcomeFeedbackRecord captures evidence of outcome patterns
             * and feeds into ProposePathwayRefinement.
             *
             * Input from SystemStateAssessment:
             * Advisory-category deficits identified in gap analysis
             * (systemic issues that cannot be resolved by a single action)
             * also feed into the learning cycle as evidence for pathway
             * or protocol review.
             *
             * The governance review step is always human — the learning
             * cycle does not automatically modify the model. */

        use case def ProposePathwayRefinement {
            doc /* Initiate a pathway change proposal based on outcome
                 * data, OutcomeFeedbackRecords, or advisory deficits
                 * from SystemStateAssessments. */
        }

        use case def ReviewAndApproveChange {
            doc /* Clinical governance review and approval of a proposed
                 * pathway or protocol change. Approved changes are
                 * enacted by updating the SysML model and regenerating
                 * affected artefacts. */
        }
    }

    package Analytics {
        private import ScalarValues::*;

        doc /* Data contracts for BI and predictive analytics, event stream
             * definitions, ML/LLM integration points, advisory layer
             * interface definitions.
             *
             * Tier 3 reasoning: powerful but probabilistic, always advisory
             * rather than authoritative. Cannot override Tier 1/2 logic. */

        part def DataContract {
            doc /* Defines the schema and semantics of a data stream
                 * consumed by analytics or ML pipelines. */
            attribute contractName : String;
            attribute description : String;
        }
    }

    package Persistence {
        private import ScalarValues::*;

        doc /* Persistence architecture types: where a domain concept is
             * stored and why. Formerly in Foundation's CommonTypes (group J);
             * consumed by the Cafe persistence policies. */

        // -- Persistence architecture types -------------------------
        // System meta model concepts: describe where domain
        // data lives and why. Cross-cutting — importable by any package.
        // Added Session 29: CSW Extension Phase 10.
        // Source: gsl-spec-catalogue-inventory-v2.1.md §8.3
        // Meta model: Business System (placed in Foundation for
        // practical cross-cutting access until the system meta modee
        // became a named package, SystemMetamodelGeneral, at S515).

        enum def PersistenceLayer {
            doc /* The persistence technology layer where a domain
                 * concept is stored. Each layer has distinct
                 * characteristics:
                 * - clinicalDataRepository: archetype-validated,
                 *   terminology-bound, versioned (openEHR)
                 * - businessDatabase: relational CRUD, transactional
                 *   integrity (PostgreSQL)
                 * - processEngine: durable execution, signal handling
                 *   (Temporal)
                 * - externalReference: knowledge the system links to
                 *   but does not own
                 * - knowledgeGraph: runtime SRS content held as triples
                 *   in the knowledge graph (B56); the default runtime
                 *   store (S197); the Cafe's store from S515 decision D1
                 *
                 * System meta model concept. knowledgeGraph added
                 * Session 518 (S0.3). */
            clinicalDataRepository;
            businessDatabase;
            processEngine;
            externalReference;
            knowledgeGraph;
        }

        enum def DataCharacteristic {
            doc /* Distinguishing characteristics that determine the
                 * natural persistence home for a domain concept.
                 * A concept's characteristic profile maps to a
                 * persistence layer.
                 *
                 * System meta model concept. */
            clinicalSignificance;
            terminologyBound;
            requiresVersioning;
            highFrequencyUpdate;
            transactionalIntegrity;
            relationalJoins;
            archetypeValidated;
            durableExecution;
            eventDriven;
            referenceData;
            regulatoryAudit;
        }

        part def PersistencePolicy {
            doc /* Maps a domain concept to its persistence layer,
                 * with explicit rationale expressed as distinguishing
                 * characteristics. Makes architectural reasoning
                 * queryable and auditable — the system can explain
                 * why each concept lives where it does.
                 *
                 * System meta model concept: describes how
                 * the system is architected, not what the business
                 * offers. Any service business system that uses
                 * multiple persistence technologies needs this.
                 *
                 * Instantiated per domain concept in each domain's
                 * business model (e.g. CoffeeShopBusinessModel).
                 *
                 * Source: gsl-spec-catalogue-inventory-v2.1.md §8.3 */
            attribute domainConcept : String;
            attribute targetLayer : PersistenceLayer;
            attribute rationale : String;
            attribute characteristics : DataCharacteristic [1..*];
        }
    }

    package OpenEhrIntegration {
        private import ScalarValues::*;


        doc /* Clinical record layer: openEHR CDR (EHRbase).
             *
             * The CDR is the persistent, semantically structured clinical
             * data layer. It stores compositions conforming to templates
             * built from archetypes. The CDR does not care how data
             * arrived — it validates against the template on commit.
             *
             * Two data paths, both producing the same structured,
             * queryable, semantically typed data:
             *   - Workflow-driven: Temporal activities commit compositions
             *     as part of pathway execution (validated Phase B)
             *   - Form-driven: direct entry outside workflows via
             *     SvelteKit endpoints (validated Phase C)
             *
             * Entity views query the CDR by archetype type (e.g. all
             * blood results, all consultations) regardless of which
             * pathway or form produced the data.
             *
             * Population-level governance queries compare CDR contents
             * against model-derived rules to identify data completeness
             * gaps (validated Phase D).
             *
             * Elaborated 8 March 2026 (CDR Exercise Phase E) with
             * structural elements informed by Phases A-D findings.
             * See also: @OpenEhrArchetype below in this package
             * and @OpenEhrTemplate metadata defs used to annotate
             * archetype-mapped part defs elsewhere in the model. */

        // -- CDR infrastructure ---------------------------------

        part def CdrConnection {
            doc /* Connection configuration for an openEHR CDR instance.
                 *
                 * Validated against EHRbase 2.11.0 (Docker).
                 * REST API base path: /ehrbase/rest/openehr/v1/
                 * Auth: basic auth for development; production TBD.
                 *
                 * The nodeName appears in composition UIDs as the
                 * second segment: {uuid}::{nodeName}::{version}.
                 * Must match SERVER_NODENAME in EHRbase config. */
            attribute baseUrl : String;
            attribute authType : String;     // basic | oauth2
            attribute nodeName : String;     // e.g. "gendersense.local"
        }

        part def EhrRecord {
            doc /* An openEHR Electronic Health Record for one patient.
                 *
                 * One EHR per patient, created at registration. The
                 * subjectId + subjectNamespace pair enables idempotent
                 * lookup via GET /ehr?subject_id=X&subject_namespace=Y.
                 * The getOrCreateEhr pattern (validated Phase B) makes
                 * EHR resolution safe to call from any activity.
                 *
                 * Namespace must match pattern [a-zA-Z][a-zA-Z0-9-_:/&+?]*
                 * — dots are NOT allowed (EHRbase validation, Phase B
                 * finding). Use hyphens as separators. */
            attribute ehrId : String;              // UUID assigned by CDR
            attribute subjectId : String;          // external patient ID
            attribute subjectNamespace : String;   // e.g. "gendersense-patient"
            attribute systemId : String;           // matches nodeName
        }

        part def RegisteredTemplate {
            doc /* An Operational Template (OPT) registered in the CDR.
                 *
                 * Templates compose archetypes into use-case-specific
                 * data sets. Each template defines one composition type.
                 * Uploaded via the Definition API (POST /definition/template/adl1.4).
                 *
                 * EHRbase rejects duplicate template_id uploads (HTTP 409).
                 * For development: database reset (docker compose down -v).
                 * For production: ehrbase.template.allow-overwrite=true.
                 *
                 * OPTs are exported from Archetype Designer (Firefox only —
                 * Chrome export hangs, Phase A finding). */
            attribute templateId : String;         // e.g. "coffeeshop-order-composition.v1"
            attribute archetypeIds : String;        // comma-separated archetype IDs in this template
        }

        part def Composition {
            doc /* A composition committed to the CDR.
                 *
                 * Compositions are the unit of clinical data committed
                 * and retrieved. Each conforms to a registered template.
                 * Canonical JSON format maps directly to the openEHR
                 * Reference Model hierarchy:
                 *   COMPOSITION > content > ENTRY > data/description > items
                 *
                 * Commit returns 204 with Prefer: return=minimal.
                 * UID in ETag header (quoted): "uid::nodeName::version".
                 *
                 * EHRbase validates DV_CODED_TEXT values against archetype
                 * term definitions — exact text match required (Phase A
                 * finding). Composition builders must derive display text
                 * from the template, not from developer input.
                 *
                 * Entry RM classes have different structures:
                 *   OBSERVATION: data (HISTORY > POINT_EVENT > ITEM_TREE)
                 *   EVALUATION: data (ITEM_TREE)
                 *   ACTION: description (ITEM_TREE) + time + ism_transition
                 * All three validated in CDR Exercise Phases A-D. */
            attribute compositionUid : String;     // uuid::nodeName::version
            attribute templateId : String;         // template this conforms to
            attribute ehrId : String;              // owning EHR
            attribute composerName : String;       // who committed
        }

        part def AqlQuery {
            doc /* A named AQL (Archetype Query Language) query.
                 *
                 * AQL queries the CDR by archetype type, providing
                 * entity views independent of the process that produced
                 * the data. Paths mirror the RM hierarchy using archetype
                 * node IDs (at-codes).
                 *
                 * EHRbase 2.11.0 limitations:
                 *   - COUNT / GROUP BY not supported (use application-
                 *     level aggregation, Phase C finding)
                 *   - NOT EXISTS subqueries not supported (use
                 *     application-level join, Phase D finding)
                 *
                 * Governance audit pattern (validated Phase D): two AQL
                 * queries (one per composition type), joined in
                 * application code by EHR ID, applying rules derived
                 * from the SysML model to identify gaps. */
            attribute queryName : String;          // human-readable name
            attribute aql : String;                // AQL query string
        }

        // -- Use cases ------------------------------------------

        use case def CommitComposition {
            doc /* Store a clinical composition in the CDR conforming to
                 * a registered template. The CDR validates the composition
                 * structure and coded terms against the template.
                 *
                 * Called from: Temporal activity implementations (workflow
                 * path) or SvelteKit server endpoints (form path). Both
                 * use the same EHRbase client module and canonical JSON
                 * composition format. */
        }

        use case def QueryByArchetype {
            doc /* Retrieve clinical data via AQL query filtered by
                 * archetype type. Entity view pattern: "show me all
                 * blood results for this patient" regardless of which
                 * pathway produced them.
                 *
                 * Results are returned as row sets. Application code
                 * maps result columns to typed objects for front-end
                 * rendering. */
        }

        use case def RunGovernanceAudit {
            doc /* Execute a population-level data completeness audit.
                 *
                 * Pattern: query CDR for expected compositions (e.g.
                 * all orders), query for matching compositions (e.g.
                 * all preparations), join by EHR ID in application
                 * code, identify gaps. Produces a governance report
                 * with summary statistics and per-patient detail.
                 *
                 * Can run as scheduled Temporal workflow (cron) or
                 * on-demand from a SvelteKit endpoint. Validated in
                 * CDR Exercise Phase D. */
        }

        use case def ManageArchetypes {
            doc /* Design, version, and deploy archetypes and templates.
                 *
                 * Workflow: design in Archetype Designer (web tool) →
                 * export OPT via Firefox → upload to EHRbase via
                 * Definition API. Term definitions edited in archetype,
                 * not template (two-level modelling principle).
                 *
                 * Archetype Designer traps:
                 *   - OPT export hangs in Chrome (use Firefox)
                 *   - Unassigned elements default to BOOLEAN
                 *   - Always explicitly set every element's data type */
        }

        // -- openEHR annotation metadata ----------------------------
        // Formerly in Foundation's MetadataLibrary (group C). Used by GSL; the
        // Cafe's archetype package was deleted at S518 (S0.3, H-0434).

        // -- openEHR CDR integration metadata -------------------

        metadata def OpenEhrArchetype {
            doc /* Maps a SysML part def to an openEHR archetype.
                 *
                 * Provides traceability between the structural model
                 * and the CDR archetype layer. The archetypeId is the
                 * full openEHR archetype identifier (e.g.
                 * "openEHR-EHR-OBSERVATION.order_record.v0").
                 * The rmClass identifies the Reference Model entry
                 * class (OBSERVATION, ACTION, EVALUATION, etc.).
                 *
                 * Verified on part defs in Syside 0.8.5 (8 March 2026).
                 * Cross-project import resolves correctly. Hover tooltip
                 * shows doc string and source location.
                 *
                 * Does not generate code (yet) — purpose is traceability
                 * and model self-description. A future generator could
                 * use this to produce composition builder code from the
                 * model. Queryable via Syside Automator metadata
                 * filtering (evaluate_filter). */
            attribute archetypeId : String;
            attribute rmClass : String;
        }

        metadata def OpenEhrElement {
            doc /* Maps a SysML element to an openEHR archetype data
                 * element (at-code).
                 *
                 * The nodeId is the at-code within the archetype
                 * (e.g. "at0005"). The rmType is the openEHR data
                 * type (e.g. "DV_CODED_TEXT", "DV_TEXT",
                 * "DV_DATE_TIME", "DV_QUANTITY").
                 *
                 * LIMITATION (verified 8 March 2026): Syside does NOT
                 * accept @ annotations inside attribute bodies, and
                 * doc blocks after semicolon-terminated attributes also
                 * fail. This metadata def cannot be applied to attributes.
                 * Retained for potential use on sub-part defs if a future
                 * modelling pattern represents archetype data elements as
                 * contained parts rather than attributes.
                 *
                 * Current recommendation: use inline comments for
                 * per-element mapping. Format:
                 *   attribute name : Type; // at0NNN | DV_CODED_TEXT */
            attribute nodeId : String;
            attribute rmType : String;
        }

        metadata def OpenEhrTemplate {
            doc /* Maps a SysML part def to an openEHR template
                 * (OPT / operational template).
                 *
                 * Templates compose archetypes into use-case-specific
                 * data sets. Each template corresponds to a composition
                 * type committed to the CDR. The templateId matches
                 * the template_id used in EHRbase API calls.
                 *
                 * Applied to part defs that represent composition
                 * types (containers of archetype-mapped data).
                 * Verified on part defs in Syside 0.8.5 (8 March 2026). */
            attribute templateId : String;
        }
    }

    package DomainConfigurationTypes {
        private import ScalarValues::*;
        private import BusinessMetamodelGeneral::DomainIdentityTypes::*;  // DomainIdentity (ref target)

        doc /* Domain configuration: how the platform discovers, organises,
             * presents and manages a tenant domain (S142-D1). Formerly in
             * Foundation's DomainRegistry (OP-132 step 10, group H). Holds the
             * one-way pairing to the business-side DomainIdentity. Tenant
             * instances live in each tenant's DomainRegistration package. */

        part def DomainConfiguration {
            doc /* System Meta Model concept.
                 * The system configuration for a domain: how the platform
                 * discovers, organises, presents, and manages this domain.
                 *
                 * Connected to DomainIdentity via horizontal mapping.
                 * Changes to configuration (package paths, display names)
                 * do not affect business identity or governance bindings.
                 *
                 * BFO grounding: IAO:data_item (S142-D2).
                 * Domain identity (B15). Dual-stack (B21).
                 * Session 142 design, Session 143. */

            attribute canonicalKey : String;
            attribute displayLabel : String;
            attribute fullName : String;
            attribute packageName : String;
            attribute modelPath : String;
            attribute isActive : Boolean;
            ref domainIdentity : DomainIdentity;
        }
    }
}
