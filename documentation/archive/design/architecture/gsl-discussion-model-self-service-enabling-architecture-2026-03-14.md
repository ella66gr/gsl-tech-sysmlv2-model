# Discussion Paper: Self-Service Healthcare — Enabling Architecture, Informed Choice, and Generational Roadmap

**Project:** GenderSense (GSL)
**Date:** 14 March 2026
**Session:** 25
**Status:** Discussion paper — captures architectural thinking for a major strategic capability
**Context:** Conversation spanning Sessions 25, arising from consideration of patient self-service as a foundational design principle before CSW Extension Phase 6. Influenced by Uber's approach to customer empowerment, the Apperta CoPHR Blueprint (2018), the shifting clinical liability landscape in the US and UK, and harm reduction principles in trans healthcare.
**Supersedes:** `gsl-discussion-informed-choice-engine-2026-03-13.md` (absorbed into this document)

---

## 1. Framing: Enabling Architecture, Not a Fixed Model

This paper is not a specification for a self-service healthcare system. It is a description of the **enabling architecture** that the GSL platform needs in order to support successive generations of patient self-service, from minimal (transparent information) to maximal (autonomous navigation with clinical oversight at defined checkpoints).

The self-service model cannot be fixed today because:

- **The clinical liability landscape is shifting.** In the US, widespread patient access to clinical data through EPR systems like Epic has disrupted the traditional physician-centric liability model, creating a complex web of governance that was never anticipated when the doctor assumed virtually all responsibility for the patient in a wholly fiduciary role. The UK is moving in the same direction, but the implications for clinical indemnity, medical regulation, and the standard of care are not yet settled.

- **Medical regulation constrains what can be delegated.** When a patient signs up to receive medical care from a medical practitioner, the practitioner's obligations under GMC regulation, their duty of care, and their clinical accountability do not evaporate because the patient has a portal. These obligations cannot be handed off — including to the patient — without deliberate care, understanding, and appropriate governance.

- **The patient population is heterogeneous.** Some trans patients are starting from scratch; others arrive mid-stream, already self-administering hormones from unregulated or semi-regulated sources. The system must meet people where they are, which means supporting a range of engagement models simultaneously.

- **The governance framework must evolve with the service model.** Each generation of self-service introduces new governance requirements — new consent models, new liability boundaries, new audit requirements. The architecture must support this evolution without requiring structural rebuilds.

The architectural question is therefore not "how do we build self-service?" but "how do we build a platform that can support the right degree of self-service at each stage of the business's maturity, the regulatory landscape's evolution, and the patient's needs?"

---

## 2. Prior Art: The CoPHR Blueprint

The Apperta Foundation's "Blueprint for a Co-Produced Personal Health Record (CoPHR) Ecosystem" (2018) addressed many of these concerns in the context of patient-held records. Several of its authors are former colleagues. The CoPHR blueprint is directly relevant to GenderSense and should be treated as a foundational reference.

### 2.1 Key CoPHR Principles Applicable to GSL

The CoPHR's nine principles encode hard-won thinking about the tension between patient control and clinical governance:

- **Patient control of access** — the patient decides who can view and contribute to their record, but within a governance framework that protects all parties.
- **Irrevocable access to relied-upon data** — once a clinician has been granted access to data they may have relied upon for clinical decisions, the patient cannot retrospectively revoke that access. This protects the clinician's ability to defend their decisions.
- **Mandatory provenance and audit** — every data entry records who contributed it, in what role, at what time, from what device. The full audit trail allows reconstruction of the record state at any point in time.
- **Medico-legal validity** — the record is designed to comply with the Civil Evidence Acts and PACE, making it admissible as evidence.
- **Data portability** — the patient can transfer their complete record to another provider.
- **Separation of record from application** — multiple applications can access the same underlying record, avoiding data silos.

### 2.2 What GSL Adds to the CoPHR Model

The CoPHR is primarily a data architecture — it defines how the record is structured, stored, accessed, and governed. GenderSense adds:

- **Active clinical pathways** — the patient is not just viewing data but navigating a care pathway with deterministic state machines, constraint evaluation, and workflow orchestration.
- **Informed choice interactions** — the system actively supports decision-making through computed option evaluation, projected consequences, and adaptive explanation (the Informed Choice Engine described in this paper).
- **Self-knowledge architecture** — the system can reason about its own state, evaluate constraints, project goals, analyse gaps, and present this reasoning to the patient in comprehensible form.
- **Generation from model** — the clinical pathway, its constraints, its decision points, and its governance artefacts are generated from the SysML model, not hand-coded.

The CoPHR provides the governance and data architecture foundation. GenderSense builds the active clinical intelligence and self-service interaction on top of it.

---

## 3. The Clinical Authority Problem

### 3.1 The Traditional Model

In the traditional model, the doctor assumes virtually all responsibility for the patient. The doctor assesses, the doctor decides, the doctor prescribes, the doctor monitors. The patient's role is to present symptoms, answer questions, and comply with treatment. Patient non-compliance has traditionally been given short shrift — it is treated as the patient's problem, not the system's.

This model has a clear liability structure: the doctor is responsible for the quality of their clinical decisions. The clinical indemnity framework (MDU, MPS, CNST) is built around this assumption.

### 3.2 The Disruption

Patient access to clinical data, patient portals, shared decision-making, and patient-initiated pathways all disrupt this model. When a patient can see their blood results before their doctor has reviewed them, when a patient can choose between treatment options presented by a system, when a patient can navigate portions of their care pathway autonomously — the question "who is responsible?" becomes significantly more complex.

Sam's observation about Epic in the US is instructive: giving patients access to their data and pathways has introduced a complex web of governance that must be navigated alongside traditional clinical thinking. The clinical indemnity landscape is not well suited to matching this shifting landscape.

### 3.3 The GenderSense Position

GenderSense operates in a specific regulatory context: a private healthcare service providing gender-affirming care under GMC regulation, with clinical indemnity requirements. The practitioner's duty of care is non-negotiable. The self-service architecture must be designed so that:

1. **The clinician's authority is preserved where it must be.** The system never presents itself as a substitute for clinical judgment. Where clinical judgment is required — interpreting results, making prescribing decisions, handling exceptions — the clinician acts, and the system records their action.

2. **The system's role is transparent.** At every point, it is clear to the patient whether they are interacting with the system (automated, deterministic, model-driven) or with a clinician (human judgment). The governance record distinguishes these.

3. **The authority model is explicit and versioned.** The system records which authority model was in effect at each decision point. As the self-service model evolves through generations, the governance record shows when and how the boundary between patient autonomy and clinician authority shifted.

4. **Nothing is assumed about the future liability model.** The architecture supports a range of authority distributions — from "clinician decides everything" to "patient navigates with clinician oversight" — without requiring structural changes. The configuration is in the model (agency classification, authority metadata), not in the code.

### 3.4 Harm Reduction

Many trans patients undertake various forms of self-administered medication from illicit or barely-regulated sources. This is a clinical reality that the system must acknowledge.

Principles of harm reduction suggest that the system should:

- **Meet the patient where they are.** A patient arriving mid-stream with self-administered hormones needs a pathway that starts from their current state, not from a blank slate.
- **Record without judgment.** The patient's self-medication history is clinical data. It must be recorded accurately for clinical safety (drug interactions, baseline assessment, monitoring context) within the governance framework.
- **Offer a credible alternative.** The value proposition of engaging with GenderSense is access to monitored, clinician-supervised care that is safer and more effective than self-administration. The self-service architecture should make this compelling — transparent, navigable, affordable, and respectful of the patient's autonomy.
- **Maintain clinical safety regardless.** Whether the patient is on a fully clinician-supervised pathway or transitioning from self-medication, the same safety constraints apply. The ConstraintEvaluator doesn't know or care how the patient arrived at their current clinical state — it evaluates safety against current values.

The pathway model must support "patient arrives mid-stream" as a first-class scenario, with appropriate intake assessment, baseline evaluation, and transition planning.

---

## 4. Generational Roadmap

The self-service capability evolves through distinct generations, each building on the architecture of the previous one and each requiring specific governance and regulatory prerequisites.

### Generation 1: Informed Transparency

**What the patient gets:** Visibility of their pathway position, upcoming actions, recent results, projected timeline, and proactive notifications. All clinical decisions remain with the clinician. The patient can see what's happening and what's coming next, but they don't navigate autonomously.

**Authority model:** Clinician decides. Patient is informed. System records everything.

**Architectural requirements:** Patient-facing state projection (§8), notification triggers (§9), patient-level financial projection (§10). Agency classification is modelled but all decision points are classified as clinician-action or collaborative.

**Governance:** Standard clinical governance. The system produces richer audit records than a traditional EPR (because state projections, notifications, and patient interactions are all recorded), but the liability model is unchanged.

**Prerequisites:** None beyond what the GSL architecture already provides or is building. This generation is deployable with the current regulatory and indemnity framework.

**Coffee shop analogue:** The customer can see their order status, estimated preparation time, and gets a notification when their drink is ready. They don't make any choices beyond the initial order.

### Generation 2: Guided Self-Navigation

**What the patient gets:** The ability to perform certain actions autonomously — booking appointments, uploading results, completing questionnaires, confirming safety information receipt, selecting appointment times. Agency classification determines which actions are patient-autonomous and which require clinician involvement.

**Authority model:** Clinician decides on clinical matters. Patient performs operational actions. System enforces the boundary and records the authority model.

**Architectural requirements:** Agency classification (§7) fully operational — patient-action nodes are interactive in the portal. Escalation rules (reminders, timeouts, clinician escalation) are modelled and enforced. Basic consent-to-share and delegated access are available.

**Governance:** The governance framework records which actions were performed by the patient, which by the clinician, and which by the system. The authority model is recorded per-action. No shift in clinical liability — the clinician still makes all clinical decisions.

**Prerequisites:** Identity verification and authentication architecture (NHS Login or equivalent). Secure patient portal. Tested escalation pathways.

**Coffee shop analogue:** The customer can select items from the catalogue, choose size, apply dietary preferences, and place the order themselves. The barista still makes the drink and decides when it's ready.

### Generation 3: Informed Choice with Shared Authority

**What the patient gets:** At defined decision points, the Informed Choice Engine presents evaluated options with projected consequences. The patient can explore options, ask questions, and express a preference. The clinician reviews the patient's preference and confirms (or overrides with recorded justification). The full ICE interaction is recorded as a governance artefact.

**Authority model:** Patient is informed and expresses preference. Clinician reviews and confirms or overrides. System records the full interaction, the options evaluated, the constraints applied, and the decision provenance.

**Architectural requirements:** OptionEvaluator (§6), Informed Choice Engine (§5), LLM integration with the "explains vs decides" boundary (§5.4), InformedChoiceAttestation governance artefact (§11). Interaction protocol versioning.

**Governance:** The InformedChoiceAttestation (§11.2) produces a fundamentally new standard of evidence for informed consent — structured, auditable, traceable from patient decision through option evaluation back to clinical evidence base. The clinician's review and confirmation is recorded. Overrides require recorded justification.

**Prerequisites:** Settled legal analysis of the ICE's regulatory classification (medical device? clinical decision support?). Clinical indemnity that covers the shared authority model. Validated LLM grounding — the LLM must be demonstrably constrained by knowledge model outputs.

**Coffee shop analogue:** "Help Me Choose" — the system presents options filtered by dietary constraints, explains consequences (caffeine content, allergens, preparation time), and the customer makes an informed selection.

### Generation 4: Autonomous Self-Service within Defined Boundaries

**What the patient gets:** The patient navigates significant portions of their care pathway autonomously, within system-enforced clinical safety boundaries. Clinician involvement is triggered by exception (safety alert, abnormal result, constraint violation), by escalation (patient request, timeout), or by protocol (periodic review, prescribing decision). Between these checkpoints, the patient manages their own care.

**Authority model:** Patient navigates. System enforces safety boundaries. Clinician intervenes at defined checkpoints and by exception. The governance record shows the complete audit trail including the authority model at each point.

**Architectural requirements:** All previous generations plus: real-time clinical safety alerting with escalation ladders, granular data release model (what the patient sees immediately vs after clinician review), comprehensive interoperability (external lab results, pharmacy integration, GP data sharing), robust delegated access for carers/advocates.

**Governance:** Full coPHR-grade governance: provenance, audit, irrevocable access to relied-upon data, data portability, medico-legal validity. The authority model per-decision-point is the primary governance parameter.

**Prerequisites:** Mature regulatory framework. New-form clinical indemnity that covers autonomous patient navigation. Extensive clinical validation of the safety constraint system. Regulatory approval for any components classified as medical devices. Probably: a track record of safe operation at Generation 3.

**Coffee shop analogue:** The customer orders, pays, and tracks their order entirely through the app. The barista makes the drink but the customer controls the entire interaction flow. The system handles edge cases (out of stock, equipment failure) by notification and offering alternatives.

### Generational Principle

Each generation builds on the architecture of the previous one. The OptionEvaluator, agency classification, notification triggers, governance attestation, patient-facing state projection — these are all **present from Generation 1** but exercised to different degrees. The architecture does not change between generations; the **configuration** changes — specifically, the agency classification metadata on pathway nodes and the authority model parameters in the governance framework.

This means the investment in the enabling architecture pays off at every generation, and the transition between generations is a matter of policy and configuration, not re-engineering.

---

## 5. The Informed Choice Engine

### 5.1 What It Is

An Informed Choice Engine (ICE) is an architectural component that hosts a structured, adaptive, knowledge-driven interaction between the system and the patient at decision points in a care pathway. It draws on the full self-knowledge architecture — LogicEngine, ConstraintEvaluator, OptionEvaluator, GoalProjector, GapAnalyser — to present options, explain consequences, answer questions, and record decisions.

It is not a chatbot. It is not a leaflet. It is an orchestrated interaction that combines deterministic clinical reasoning with adaptive natural-language explanation, bounded by safety constraints and recorded for governance.

The ICE is the primary enabling component for Generation 3 (Informed Choice with Shared Authority) but its architectural presence supports all generations. In Generation 1, the ICE's underlying components (OptionEvaluator, constraint evaluation, projection) drive the patient's information view even though the patient doesn't interact with them directly. In Generation 2, they support the patient's operational self-navigation. In Generation 3, the full ICE interaction is exposed.

### 5.2 What It Does

At a decision point in the patient's care pathway:

1. **Enumerates options** — the OptionEvaluator computes which options are available to this patient, given their clinical state, pathway position, and any applicable constraints.

2. **Projects consequences** — for each available option, the GoalProjector computes the expected trajectory: timeline, cost, monitoring requirements, expected outcomes, risks.

3. **Excludes and explains** — the ConstraintEvaluator identifies options that are not available and the engine explains why, in patient-appropriate language.

4. **Hosts a dialogue** — the patient can ask questions, explore "what if" scenarios, request more detail on specific options or consequences. The LLM handles natural-language interaction, grounded in and constrained by the knowledge model outputs.

5. **Adapts to the patient** — the interaction adjusts depth, language level, and emphasis based on the patient's engagement.

6. **Checks understanding** — at key points, the engine confirms the patient's understanding of material facts before proceeding. This is not a tick-box; it's an interactive verification.

7. **Records the decision** — the patient's choice, the options that were presented, the constraints that applied, the questions that were asked, the explanations that were given, and the understanding checks — all recorded as a structured governance artefact.

### 5.3 Where It Sits in the Architecture

The ICE is an orchestration pattern, not a single component. It sits at the intersection of the Knowledge Layer (deterministic computation), the LLM Layer (adaptive explanation), and the Governance Layer (audit and attestation):

```
                    ┌──────────────────────────┐
                    │   Patient Interface       │
                    │   (Portal / App)          │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │  Informed Choice Engine   │
                    │  (Orchestration Layer)    │
                    │                          │
                    │  ┌─────────────────────┐ │
                    │  │ Interaction Protocol │ │
                    │  │ (Dialogue Sequencer) │ │
                    │  └──────────┬──────────┘ │
                    │             │             │
                    └─────┬───────┼───────┬─────┘
                          │       │       │
               ┌──────────▼──┐ ┌──▼────┐ ┌▼───────────────┐
               │  Knowledge  │ │  LLM  │ │  Governance    │
               │  Layer      │ │ Layer │ │  Layer         │
               │             │ │       │ │                │
               │ Option      │ │Ground-│ │ Interaction    │
               │  Evaluator  │ │ ed in │ │  Record        │
               │ Constraint  │ │ KL    │ │ Decision       │
               │  Evaluator  │ │outputs│ │  Provenance    │
               │ Goal        │ │       │ │ Authority      │
               │  Projector  │ │       │ │  Model Record  │
               │ Gap         │ │       │ │ Attestation    │
               │  Analyser   │ │       │ │  Structure     │
               └─────────────┘ └───────┘ └────────────────┘
```

### 5.4 The LLM Boundary — "Explains vs Decides"

This is the most critical architectural decision.

**The LLM explains; the knowledge model decides.**

The OptionEvaluator computes which options are available. The ConstraintEvaluator determines what's safe. The GoalProjector models the expected trajectory of each option. These are deterministic, auditable, model-driven computations.

The LLM's role is to take these computed outputs and make them comprehensible: to explain them in natural language, to answer questions about them, to adapt the level of explanation to the patient, to detect when the patient seems uncertain and offer more detail. The LLM is an *interface to the knowledge model*, not a replacement for it.

**What the LLM receives:** Evaluated options (structured data from the OptionEvaluator), constraint explanations, projected trajectories, relevant domain knowledge fragments, interaction history, and patient profile context (relevant clinical state, not raw data).

**What the LLM is not allowed to do:** Generate clinical recommendations beyond what the knowledge model computes. Override constraints. Invent clinical facts. Make promises about outcomes.

**What the LLM excels at:** Translating structured data into natural language. Adapting depth and register. Handling "what if" exploration grounded in GoalProjector output. Providing emotional context and reassurance where appropriate.

**Provenance tagging:** Every LLM-generated explanation is tagged with the knowledge model outputs it's explaining. The governance record shows both the computed facts and the natural language presentation.

---

## 6. The OptionEvaluator

### 6.1 Relationship to Existing Self-Knowledge Architecture

The OptionEvaluator is a natural extension of the self-knowledge architecture, sitting alongside the ConstraintEvaluator as a sibling component:

| Component | Question it answers | Input | Output |
|---|---|---|---|
| **ConstraintEvaluator** | "Is this valid / safe / allowed?" | A specific state or proposed action | Pass/fail with explanation |
| **OptionEvaluator** | "What are the available choices and their consequences?" | A decision point + patient state | Enumerated options with projected consequences |
| **GoalProjector** | "Where is this heading?" | Current state + projection parameters | Projected trajectory over time |
| **GapAnalyser** | "What's missing or at risk?" | Current state vs target state | Gap items with severity and remediation |

The ConstraintEvaluator answers a binary question about a single option. The OptionEvaluator answers a generative question about all options at a decision point. The OptionEvaluator *uses* the ConstraintEvaluator to filter its option set.

### 6.2 How It Works

Given a decision point and the patient's current state:

1. **Enumerate candidates** from the domain model's option set for this decision point.
2. **Evaluate eligibility** for each candidate via the ConstraintEvaluator.
3. **Project consequences** for each eligible option via the GoalProjector.
4. **Attach explanatory context** — plain-language descriptions, differentiators, FAQ references.
5. **Return structured result** — the LLM layer transforms this into the patient-facing interaction.

### 6.3 Domain Model Implications

The OptionEvaluator requires decision points in the SysML model to carry:

- **The option set** — references to catalogue entries, formulary items, pathway branches, or other domain objects
- **The eligibility constraints** — which constraints apply to which options
- **The projection parameters** — what the GoalProjector needs per option
- **The explanatory metadata** — patient-facing descriptions, differentiator summaries

Decision points become richer than simple branching nodes, annotated with metadata that the OptionEvaluator reads — following the existing pattern of `@TemporalActivity` metadata that generators read.

---

## 7. Agency Classification

### 7.1 The Concept

Every action node in a pathway carries an explicit **agency classification**: who does this?

| Agency | Meaning | Clinical example | Coffee shop example |
|---|---|---|---|
| **Patient** | Patient performs via self-service | Upload blood results, confirm safety information, select formulation | Select drink, confirm order |
| **Clinician** | Clinician performs, requiring judgment | Interpret results, make prescribing decision | Barista prepares drink |
| **System** | System performs automatically | Send reminder, check constraint, generate document | Validate order, update inventory |
| **Collaborative** | Patient and clinician together | Discuss treatment options (with ICE support), review progress | — |

### 7.2 Why It Matters

Agency classification drives: the patient portal UI (which steps are interactive vs status indicators), escalation rules (what happens on patient inaction), and governance scope (what kind of attribution record each step produces).

### 7.3 The Authority Model Parameter

At each generation of self-service, the agency classification can be reconfigured. A node classified as "collaborative" in Generation 2 might be reclassified as "patient" (with clinician review) in Generation 3, or as "patient" (autonomous) in Generation 4. The governance record captures which classification was in effect when each action was performed.

This is a model-level configuration, not a code change. The SysML model's agency metadata is the control surface.

### 7.4 Model Representation

```
metadata def AgencyClassification {
    attribute agencyType : AgencyType;
    attribute authorityModel : AuthorityModelVersion;
    attribute timeoutDays : ScalarValues::Integer[0..1];
    attribute escalationTarget : String[0..1];
    attribute notificationOnEntry : Boolean;
    attribute notificationOnCompletion : Boolean;
}
```

The `authorityModel` attribute records which generation's authority rules were in effect — supporting the versioned governance requirement.

---

## 8. Patient-Facing State Projection

The patient sees a simplified, role-appropriate view of their pathway state — not the clinician's view, but a *reframed* view for the patient's cognitive context.

| System knows | Clinician sees | Patient sees |
|---|---|---|
| State: `awaitingLabResults`, 2/10 days | Lab results pending (2/10 days). Auto-escalate day 10. | "We're waiting for your blood test results. Usually 5–10 working days." |
| Constraint: `haemoglobin_check` PASS, `liver_function` PENDING | Hb OK. LFTs outstanding. | "One blood test has come back fine. We're waiting for another before next step." |
| Projection: prescription ~15 April ± 7 days | Target prescribing mid-April, subject to LFTs and clinic. | "If everything goes well, we'd expect to discuss prescription options around mid-April." |

Each pathway state carries patient-facing narrative templates with uncertainty-appropriate language, proactive information selection, and clear indication of what (if anything) the patient needs to do.

---

## 9. Notification Triggers

State transitions generate modelled notifications — not ad-hoc.

| Type | Trigger | Example |
|---|---|---|
| **Progress** | State transition | "Your blood results have been reviewed — everything looks good." |
| **Action required** | Entry to patient-agency state | "Please book your 3-month blood test." |
| **Waiting** | Entry to clinician/system state | "Your case is with Dr Green for review. Expect 3 working days." |
| **Reminder** | Patient-agency timeout approaching | "Blood test booking due in 5 days." |
| **Escalation** | Patient-agency timeout exceeded | "We've asked your clinician to follow up." |
| **Milestone** | Significant pathway event | "You've completed your 6-month review — everything on track." |

Model representation:

```
metadata def NotificationTrigger {
    attribute notificationType : NotificationType;
    attribute recipientRole : AgencyType;
    attribute templateRef : String;
    attribute channelPreference : String[0..*];
    attribute delayMinutes : ScalarValues::Integer;
}
```

---

## 10. Patient-Level Financial Projection

The existing projection engine operates at the business level. The self-service principle requires a patient-level mode: given this patient's pathway position and selected options, what will this cost over the next 12 months?

Patient-level projections are the atomic units that aggregate into business-level projections — providing a powerful self-consistency check.

---

## 11. The Governance Uplift

### 11.1 What Changes

Current evidence for informed consent: a signed form, possibly a note that risks and benefits were discussed.

What the ICE produces: a structured interaction record showing what options were presented, which were excluded and why, what the patient asked, what was explained (grounded in which knowledge model outputs), understanding checks, the patient's decision, and the full provenance chain.

### 11.2 The Attestation Structure

```
InformedChoiceAttestation:
  session_id, patient_id, pathway_position, decision_point_id, timestamp
  authority_model_version: which generation's rules were in effect

  options_presented:
    - option_id, label, eligibility_status, constraint_results[], projected_consequences

  options_excluded:
    - option_id, label, exclusion_reason, constraint_id, evaluated_values

  dialogue_record:
    - turn_number, speaker (patient|system), content, grounding_references[]

  understanding_checks:
    - check_id, prompt, patient_response, assessment

  decision:
    option_selected, patient_confirmation_timestamp, clinician_review (if applicable),
    clinician_override (if applicable, with justification),
    outstanding_questions_referred_to_clinician[]

  provenance:
    knowledge_sources[], model_version, evaluator_versions[]
```

### 11.3 Regulatory and Legal Implications

An informed choice attestation of this quality has implications for: CQC inspection evidence, clinical negligence defence, patient complaints handling, and aggregate service improvement analysis. The authority model version in each attestation provides evidence of what governance framework was in effect at the time of each decision.

---

## 12. Broader Platform Concerns

The self-service architecture raises concerns beyond informed choice that must be addressed as the generational roadmap progresses. These are listed here as architectural topics requiring future treatment, not as current implementation items.

### 12.1 Clinical Safety Alerting

A self-service system that receives lab results and monitors prescriptions needs real-time alerting: inbound alert processing and classification (informational / urgent / critical), alert routing and escalation ladders with hard timing constraints, alert fatigue management, and patient-initiated alert triage.

### 12.2 Data Access and Privacy

Granular data visibility (what the patient sees immediately vs after clinician review), consent-to-share architecture (patient-controlled sharing with partners, family, other clinicians — modelled consent, not just access control), data portability (FHIR, patient-readable export), and GDPR right-to-be-forgotten vs clinical record retention.

### 12.3 Identity, Authentication, and Security

Identity verification (NHS Login or equivalent), MFA, delegated access model (carer, partner, advocate — with formal powers, duration, and audit), session security for ICE interactions.

### 12.4 Interoperability

Inbound data (lab results, GP correspondence, hospital summaries — FHIR messaging, NHS Spine), outbound data (prescriptions via EPS, referral letters, shared care agreements, clinical summaries), patient-mediated interoperability (patient as data conduit), and standards compliance (HL7 FHIR, openEHR, SNOMED CT, dm+d, NHS number).

### 12.5 Real-Time Information

Patient dashboard state accuracy and freshness, appointment and scheduling (self-service booking with real-time availability), medication and prescription tracking, wait time transparency (operational state visibility pointed at the patient portal).

### 12.6 The Liability Architecture

The system needs to model the *boundaries of self-service authority* explicitly: what the patient can do autonomously, what requires clinician co-signature, what the system must escalate regardless of patient preference. The governance framework records not just what happened, but *which authority model was in effect* when it happened — this is the `authorityModel` attribute in the agency classification metadata.

---

## 13. Coffee Shop Demonstrator Analogue

The coffee shop analogue is structurally identical to the clinical system at each generation:

**Generation 1:** Customer sees order status and estimated times. Gets notified when drink is ready.

**Generation 2:** Customer selects from catalogue, chooses size, places order autonomously. Barista makes the drink.

**Generation 3 ("Help Me Choose"):** Customer gets a responsive interaction explaining options in context — dietary constraints, caffeine content, price, preparation time — driven by catalogue data and the OptionEvaluator. Choice recorded in governance log.

**Generation 4:** Customer orders, pays, and tracks entirely through the app. System handles edge cases by notification.

The coffee shop validates each generation's architecture before clinical deployment.

---

## 14. New Architectural Components Summary

| Component | Type | Location | Purpose | Generation |
|---|---|---|---|---|
| **OptionEvaluator** | Knowledge Layer | Sibling to ConstraintEvaluator | Enumerate and evaluate choices at decision points | G1+ (drives info), G3 (exposed) |
| **InformedChoiceEngine** | Orchestration pattern | Application layer | Host structured patient–system dialogue | G3 |
| **AgencyClassification** | Metadata definition | Foundation MetadataLibrary | Annotate action nodes with who-does-this and authority model | G1+ |
| **NotificationTrigger** | Metadata definition | Foundation MetadataLibrary | Annotate state transitions with patient notification rules | G1+ |
| **PatientProjection** | State metadata | Per-state on pathway state machines | Patient-facing narrative for each state | G1+ |
| **InformedChoiceAttestation** | Governance artefact | Governance / audit framework | Structured record of ICE interaction with authority model | G3 |
| **Patient-level projection** | Projection engine mode | Financial planning | Per-patient cost and timeline projection | G1+ |
| **AuthorityModelVersion** | Configuration | Governance framework | Records which generation's rules were in effect | G1+ |

---

## 15. Relationship to Existing Architecture

### 15.1 Self-Knowledge Architecture

The ICE is the most significant *consumer* of the self-knowledge architecture. The five-layer stack was designed as domain-agnostic computational infrastructure. The ICE puts it to work for the patient.

### 15.2 Three-Tier Reasoning Stack

The ICE exercises all three tiers: Tier 1 (deterministic constraints) for safety boundaries, Tier 2 (decision tables) for clinical decision support, Tier 3 (ML/LLM advisory) for adaptive explanation — in a constrained role.

### 15.3 Two-Phase Generation Pipeline

ICE artefacts flow through the pipeline: Phase 1 generates OptionEvaluator configurations, notification templates, patient projection templates from the SysML model. Phase 2 wires them into the application.

### 15.4 Catalogue-as-UI-Contract

The option set at a decision point is a "catalogue" of available choices — the Counter page's catalogue-driven tiles are a direct precursor.

### 15.5 CoPHR Heritage

The CoPHR's governance principles (provenance, audit, irrevocable access, medico-legal validity, data portability) form the governance foundation. GenderSense extends this with active pathway intelligence and the authority model versioning required for generational evolution.

---

## 16. Recommendations for Current Architecture Decisions

The following recommendations should be exported to the strategic snapshot as they affect architecture decisions being made now, not in the future.

### 16.1 Model Agency Classification Now

**Recommendation:** Add `AgencyClassification` metadata definition to the Foundation MetadataLibrary in the SysML model. Annotate the existing hormone therapy initiation pathway with agency classifications, even though all nodes are currently clinician-action or system-action. This costs one stage of work and establishes the pattern before it's needed.

**Rationale:** Agency classification is a prerequisite for all four generations. Adding it retroactively to a mature model is harder than building it in from the start. The coffee shop demonstrator can validate the metadata pattern immediately.

### 16.2 Model Authority Model Versioning Now

**Recommendation:** Include an `AuthorityModelVersion` attribute in the agency classification metadata from the outset. Initially, this has a single value ("G1-clinician-authority"). As the service evolves, new versions can be added without structural changes.

**Rationale:** The governance record needs to know which authority model was in effect at each point. Retrofitting this is possible but loses historical traceability.

### 16.3 Design Notification Triggers on the Next Pathway Modelling Pass

**Recommendation:** When the second clinical pathway is modelled (Workstream 3, Architecture Generalisation), include `NotificationTrigger` metadata on state transitions as a first-class modelling concern, not an afterthought.

**Rationale:** Notifications are a Generation 1 requirement. They need to be in the model so they can be generated, not hand-coded.

### 16.4 Plan the OptionEvaluator as Knowledge Layer Increment 4

**Recommendation:** Formally add the OptionEvaluator to the Knowledge Layer increment sequence, after KL Increments 1–3 (constraint evaluation, decision table routing, operational state aggregation). The coffee shop "Help Me Choose" feature is the demonstrator.

**Rationale:** The OptionEvaluator is the enabling component for Generation 3. Building it incrementally through the coffee shop gives it a validation history before clinical deployment.

### 16.5 Reference the CoPHR Governance Principles

**Recommendation:** Document the CoPHR's nine principles as reference requirements in the GSL governance architecture. Not all are immediately applicable (GenderSense is not a multi-repository ecosystem), but the principles on provenance, audit, irrevocable access, and medico-legal validity are directly relevant and should be adopted.

**Rationale:** The CoPHR principles encode well-tested thinking about the tension between patient control and clinical governance. GenderSense can build on this rather than reinventing it.

### 16.6 Ensure the Three-Persistence-Layer Architecture Supports Patient-Facing Data Release

**Recommendation:** When designing the patient portal data access layer, implement a data release model from the outset: what the patient sees immediately (e.g. appointment confirmations, pathway status), what the patient sees after clinician review (e.g. lab results), and what is visible only in consultation. This is a configuration per data type, not a structural decision.

**Rationale:** The Epic problem (patients seeing raw results before their doctor) is a known source of clinical and governance complexity. Designing for controlled data release from the start avoids retrofitting.

---

## 17. Open Questions

1. **LLM selection and hosting.** Which LLM, where hosted, what latency constraints? Privacy constraints for patient data in the LLM context window need careful architectural treatment.

2. **Interaction protocol versioning.** How are ICE dialogue protocol versions managed as they improve? Patients consented under different protocol versions need their governance records to reflect this.

3. **Multi-language support.** The LLM is naturally multilingual, but knowledge model metadata, notification templates, and patient projection templates need internationalisation.

4. **Patient data in LLM context.** What is the minimum patient context needed? How is it protected? What are the data protection implications?

5. **Clinician override and review.** Can a clinician override an OptionEvaluator result with recorded clinical justification? (Yes — this is architecturally supported by the attestation structure.)

6. **Patient opt-out.** The ICE is an enhancement, not a gate. Traditional consent processes must remain available.

7. **Regulatory classification.** Does an LLM-assisted clinical explanation constitute a medical device or clinical decision support system under UK/EU regulations? Early legal analysis needed.

8. **Clinical indemnity for shared authority.** What indemnity framework covers Generations 3 and 4? This needs engagement with MDOs before those generations are deployed.

9. **Harm reduction pathway design.** How should the pathway model handle patients transitioning from self-medication? This needs clinical content design, not just architectural support.

10. **CoPHR alignment.** To what extent should GenderSense formally adopt the CoPHR governance framework vs treating it as reference material? This depends on whether the service ultimately operates within a broader ecosystem or as a standalone platform.

---

## 18. Summary

This paper describes the **enabling architecture** for patient self-service in GenderSense — not a fixed model, but a platform capable of supporting successive generations of self-service as the regulatory landscape, clinical indemnity framework, and service maturity evolve.

The architecture builds on what already exists in the GSL platform — the self-knowledge stack, the three-tier reasoning framework, the catalogue-as-UI-contract pattern, the metadata-driven generation pipeline — and on prior art from the Apperta CoPHR Blueprint. It extends these with the OptionEvaluator, agency classification with authority model versioning, notification triggers, patient-facing state projection, the Informed Choice Engine, and the InformedChoiceAttestation governance artefact.

The generational roadmap (Informed Transparency → Guided Self-Navigation → Informed Choice with Shared Authority → Autonomous Self-Service) provides a structured path from current capability to the aspired-to Uber-level customer empowerment, with explicit prerequisites at each stage and governance that records which model was in effect at each decision point.

The six architecture recommendations (§16) should be acted on now — they are low-cost decisions that establish patterns the platform will need at every generation, and they are harder to retrofit than to build in from the start.

The medical practitioner's duty of care, clinical accountability, and regulatory obligations are structural constants throughout. The self-service architecture empowers the patient within these constraints, transparently and with full governance. It does not replace the clinician — it makes the clinician's work more effective, the patient's experience more transparent, and the evidence of good practice more comprehensive than anything currently available.

---

*Discussion paper prepared 14 March 2026 (Session 25). Captures architectural thinking from extended conversation about patient self-service, informed choice, clinical authority, harm reduction, and the Uber design philosophy applied to healthcare. Supersedes the initial ICE-focused paper. References the Apperta CoPHR Blueprint (2018). Not yet a committed workstream — intended to inform strategic planning, model development, and current architecture decisions.*
