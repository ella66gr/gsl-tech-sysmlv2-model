# Hormone Therapy Initiation Pathway — Modelling Plan

**Date:** 6 March 2026
**Context:** First clinical pathway for end-to-end SysML v2 modelling in GenderSense
**Prerequisite:** Package hierarchy established and verified in Syside 0.8.5 (session report, 5 March 2026)

---

## 1. What This Pathway Covers

Hormone therapy initiation is the process from a clinical decision that a patient is suitable for hormone therapy through to an established, stable regimen with monitoring in place. It is the recommended first pathway because it exercises the widest range of architectural patterns at realistic clinical complexity.

### Clinical scope

The pathway begins after assessment and treatment planning have concluded that hormone therapy is appropriate. It ends when the patient is on a stable regimen with a defined monitoring schedule and, where applicable, a shared care arrangement with their GP.

The core clinical sequence is:

1. **Eligibility confirmation and consent** — verify clinical eligibility, obtain informed consent, document capacity where relevant
2. **Baseline investigations** — order and review baseline bloods (FBC, U&Es, LFTs, lipids, fasting glucose, prolactin, hormone levels), record baseline observations (weight, BP)
3. **Prescribing decision** — select regimen (medication, route, starting dose) based on clinical assessment, patient preference, and safety profile
4. **Initiate prescription** — issue prescription, arrange dispensing, provide patient information
5. **Early monitoring** — first follow-up bloods at ~3 months, clinical review, dose adjustment if needed
6. **Stabilisation** — repeat monitoring cycle until levels are in therapeutic range and regimen is stable
7. **Transition to ongoing care** — establish monitoring schedule, initiate shared care arrangement with GP if appropriate, handoff to the monitoring pathway

### What makes this pathway architecturally interesting

It exercises long-running waits (lab results return over days to weeks, shared care negotiations take weeks), multiple participants (patient, prescribing clinician, phlebotomy, lab, GP practice, pharmacy), governance requirements (consent, clinical review gates, monitoring intervals, prescribing safety checks), clinical decision logic (eligibility rules, regimen selection, dose adjustment protocols, therapeutic range evaluation), entity lifecycle transitions (episode, prescription, lab result, referral state machines), cross-package references (to ClinicalEntities, ConstraintLibrary, MetadataLibrary, Regulation), and both the domain and orchestration layers of the two-layer action flow pattern.

---

## 2. Modelling Approach

### Guiding principle

Model the clinical process first at the domain layer — what actually happens clinically, in terms a clinician or governance reviewer would recognise. Then model the orchestration layer — how the system manages and executes that process. Both layers live in SysML v2. The domain layer generates governance documentation; the orchestration layer generates executable Temporal workflows.

### Iterative, verifiable steps

Each step produces a verifiable SysML v2 artefact that parses clean in Syside Modeler 0.8.5. New syntax patterns are tested and captured in the syntax reference. Git commits at each verified checkpoint.

### File placement

The pathway model lives in `service-delivery.sysml` under `ServiceDelivery::ClinicalPathways::HormoneTherapy`. Supporting elements (constraints, requirements, metadata, entity lifecycle elaborations) go in their respective package files. Cross-file imports follow the established pattern.

---

## 3. Work Breakdown

### Step 1: Elaborate ClinicalEntities with lifecycle state machines

**What:** Define state machines for the core entities that the hormone initiation pathway operates on — Episode, Prescription, LabResult, and Referral. These specialise the `StandardLifecycle` pattern from `Foundation::StatePatterns` with entity-specific states and transitions.

**Why first:** The pathway's action flow references entity state transitions at multiple points. Defining the entity lifecycles first gives us typed events to reference from the pathway steps.

**Touches:** `service-delivery.sysml` (ClinicalEntities), `foundation.sysml` (StatePatterns — may need additional event attribute defs)

**Syntax needed:** State def specialisation (`:>` on state defs, or parallel state defs with entity-specific states). `exhibit state` on part defs. All verified patterns — no new syntax expected.

**Deliverable:** Four entity state machines, each with `exhibit state` on the corresponding part def. Verified in Syside.

### Step 2: Add clinical requirements to Enterprise::Regulation

**What:** Define the regulatory and governance requirements that the hormone initiation pathway must satisfy. These are the "must" statements that trace to constraints and ultimately to runtime checks.

**Examples:**
- Informed consent must be obtained and documented before prescribing
- Baseline blood tests must be completed and reviewed before prescribing
- Blood monitoring must occur at defined intervals (already partially modelled)
- Prescribing must follow approved clinical protocols
- Clinical review must occur before dose changes
- Patient must have access to relevant information before consenting

**Why:** Requirements defined here are the traceability anchors. Each one will have a `satisfy` relationship to a constraint in the ConstraintLibrary, and the pathway's action flow steps will be annotated to show where each requirement is addressed.

**Touches:** `enterprise.sysml` (Regulation)

**Syntax needed:** `requirement def` with `subject` — verified pattern.

**Deliverable:** 6–10 requirement defs capturing the governance obligations of the hormone initiation pathway.

### Step 3: Add clinical constraints to Knowledge::ConstraintLibrary

**What:** Define evaluable constraints corresponding to the requirements from Step 2. These are the boolean rules that can be checked at runtime.

**Examples:**
- `BaselineBloodsReviewedConstraint` — baseline bloods have been ordered, resulted, and reviewed before prescribing
- `EligibilityCriteriaMetConstraint` — patient meets defined eligibility criteria
- `TherapeuticRangeConstraint` — hormone levels within defined therapeutic range
- `MonitoringDueConstraint` — time since last monitoring check vs required interval

**Wiring:** Each constraint gets a `satisfy requirement X by Y;` relationship linking it to the corresponding requirement.

**Touches:** `knowledge.sysml` (ConstraintLibrary)

**Syntax needed:** `constraint def` with `in` parameters, `satisfy` — all verified patterns.

**Deliverable:** Matching constraints for each requirement, with satisfy traceability. Verified in Syside.

### Step 4: Extend MetadataLibrary for hormone pathway annotations

**What:** Define any new metadata defs needed to annotate the pathway's action flow steps. The existing clinical metadata defs (ClinicalReviewGate, ConsentRequired, AuditPoint, SafetyConstraint) may suffice. Review whether additional annotations are needed for:
- Prescribing decision points
- Lab ordering activities
- Shared care handoff points
- Patient information provision points

**Touches:** `foundation.sysml` (MetadataLibrary)

**Syntax needed:** `metadata def` — verified pattern.

**Deliverable:** Any new metadata defs needed. May be a no-op if existing defs cover the pathway.

### Step 5: Model the domain-layer action flow

**What:** The clinical process as a clinician would describe it. This is the governance view — the pathway diagram that gets reviewed, audited, and shown to regulators. Action nodes represent clinical activities, not system operations.

**Structure (draft):**
```
action def InitiateHormoneTherapyProcess {
    // Inputs
    in item patient : Patient;
    in item episode : Episode;

    action confirmEligibility { ... }
    then obtainConsent;

    action obtainConsent { @ConsentRequired { ... } }
    then orderBaselineBloods;

    action orderBaselineBloods { ... }
    then awaitBaselineResults;

    action awaitBaselineResults { ... }  // long-running wait
    then reviewBaselineResults;

    action reviewBaselineResults { @ClinicalReviewGate { ... } }
    then selectRegimen;

    action selectRegimen { ... }  // clinical decision point
    then issuePrescription;

    action issuePrescription { ... }
    then providePatientInformation;

    action providePatientInformation { ... }
    then scheduleEarlyMonitoring;

    action scheduleEarlyMonitoring { ... }
    then awaitEarlyMonitoringResults;

    action awaitEarlyMonitoringResults { ... }  // long-running wait
    then conductEarlyReview;

    action conductEarlyReview { @ClinicalReviewGate { ... } }
    then assessStability;

    action assessStability { ... }  // decision: stable or adjust?
    // branch: adjustDose -> back to monitoring cycle
    // branch: confirmStable -> transitionToOngoingCare

    action adjustDose { ... }
    then scheduleEarlyMonitoring;  // loop back

    action confirmStable { ... }
    then transitionToOngoingCare;

    action transitionToOngoingCare { ... }
}
```

**Key modelling decisions:**
- The monitoring/adjustment cycle is a loop in the action flow (adjust dose → re-monitor → re-review → assess again). This is the first time we model a loop; it may require syntax exploration.
- Decision points (assessStability) use the branching pattern (multiple `then` lines from one action).
- Long-running waits are explicit action nodes — in the domain layer they represent "waiting for lab results", not the Temporal signal mechanism.

**Touches:** `service-delivery.sysml` (HormoneTherapy)

**Syntax needed:** Action flow branching and convergence (verified), looping (new — needs exploration). `@` metadata annotations on action steps (verified).

**Deliverable:** Complete domain-layer action flow for hormone therapy initiation. Verified in Syside.

### Step 6: Model the orchestration-layer action flow

**What:** The system execution view — how Temporal manages the process. Each domain-layer step maps to one or more orchestration-layer steps annotated with `@TemporalActivity`, `@TemporalSignal`, `@StateTransitionTrigger`, `@ClinicalReviewGate` etc.

This is where long-running waits become Temporal signals, clinical review gates become human-task wait points, and entity state transitions are explicitly triggered.

**Touches:** `service-delivery.sysml` (HormoneTherapy) or potentially a separate orchestration file

**Syntax needed:** Full metadata annotation pattern from the demonstrator. May need to consider whether orchestration lives in the same file or a separate one.

**Deliverable:** Orchestration-layer action flow with full Temporal metadata. Verified in Syside.

### Step 7: Add `view` elements for scoped diagrams

**What:** SysML v2 `view` elements to produce scoped diagrams of the pathway — the domain process view, the entity lifecycle views, the requirements traceability view. This is a new syntax area flagged in the TODO list.

**Touches:** Potentially a new `views.sysml` file, or inline in `service-delivery.sysml`

**Syntax needed:** `view` and `viewpoint` — not yet verified. This step includes syntax verification.

**Deliverable:** View definitions producing useful scoped diagrams. Syntax findings captured in the syntax reference.

---

## 4. Syntax Exploration Needed

The following syntax patterns are needed for this pathway and not yet verified in Syside:

1. **Looping in action flows** — the dose adjustment cycle requires a loop. Options: backward `then` reference to an earlier action, or a containing action with iteration semantics. Needs experimentation.

2. **`view` / `viewpoint` elements** — for scoped diagram generation (Step 7). On the TODO list.

3. **Guard conditions on branches** — the assessStability decision point ideally has guarded branches ("if stable" / "if adjustment needed"). Guards are on the TODO list as unverified. We can work without them (using doc comments to describe the condition) but it would be cleaner with guards.

4. **`decide` / `merge` in Syside 0.8.5** — worth re-testing now that Sensmetry claim full v2.0 support. If `decide`/`merge` now work, the decision points in the pathway are cleaner.

5. **State def specialisation** — the entity lifecycle state machines may benefit from specialising `StandardLifecycle`. This is `state def EpisodeLifecycle :> StandardLifecycle { ... }` — needs verification.

---

## 5. Cross-Package Wiring Summary

| Source | Target | Mechanism |
|---|---|---|
| HormoneTherapy action flow | ClinicalEntities (Patient, Episode, etc.) | `in item` parameters, `ref` in action bodies |
| HormoneTherapy action flow | MetadataLibrary annotations | `@ClinicalReviewGate`, `@ConsentRequired`, etc. |
| HormoneTherapy action flow | ConstraintLibrary | Precondition references (approach TBD) |
| ConstraintLibrary | Regulation requirements | `satisfy requirement X by Y;` |
| ClinicalEntities state machines | StatePatterns | Specialisation or parallel definition |
| Regulation requirements | ClinicalEntities | `subject patient : Patient;` |

All cross-file imports follow the established `private import Package::SubPackage::*;` pattern.

---

## 6. Proposed Working Order

**Phase A — Entity lifecycles and governance anchors (Steps 1–3)**
Establish the structural foundation: entity state machines, requirements, and constraints. These are referenced by the pathway but don't depend on it. Can be verified independently.

**Phase B — Domain pathway (Steps 4–5)**
Model the clinical process. This is the creative, clinically-driven work. Iterate on the action flow until it accurately represents the hormone initiation pathway. Syntax exploration for loops and decision points happens here.

**Phase C — Orchestration pathway (Step 6)**
Map the domain pathway to Temporal execution. This is more mechanical — applying the demonstrator's patterns to a clinical context. The main new challenge is the monitoring loop.

**Phase D — Views and diagrams (Step 7)**
Produce scoped diagrams. This is exploratory — `view`/`viewpoint` syntax verification and practical use.

Each phase has a clear exit criterion (parses clean in Syside, git tagged) and produces a verifiable increment.

---

## 7. What This Intentionally Defers

- **openEHR archetype design** — the pathway identifies what clinical data is captured and when, which directly informs archetype design, but the archetype work itself is deferred to the CDR integration exercise
- **Generator migration** — Syside Automator is confirmed ready, but generators are not needed until we want to produce executable code from this pathway
- **Front-end design** — patient portal forms, clinician views, and patient-facing information are downstream of the model
- **Shared care protocol detail** — the transition-to-shared-care step is modelled as a single action; the internal complexity of shared care negotiation is a separate pathway to elaborate later
- **Prescribing protocol detail** — regimen selection logic is noted as a clinical decision point; the detailed decision table (DMN-style) is deferred to when we work on `Knowledge::DecisionModels`

---

*Plan prepared 6 March 2026 for use as working roadmap in the current and subsequent sessions.*
