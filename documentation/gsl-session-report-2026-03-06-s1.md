# GenderSense SysML v2 Modelling — Session Report (Hormone Initiation)

## 6 March 2026 (Session 1)

**Purpose:** Comprehensive progress report for continuity into the next chat session. This session modelled the first clinical pathway — Hormone Therapy Initiation — end to end across both the domain and orchestration layers, with supporting entity lifecycles, governance requirements, evaluable constraints, and satisfy traceability.

---

## 1. Session Objectives and Outcomes

This session executed the modelling plan for the Hormone Therapy Initiation pathway (Phases A–C of the plan, plus investigation of Phase D). The plan was created at the start of the session and all substantive steps were completed.

### Completed

- **Phase A Step 1:** Entity lifecycle state machines (Episode, Prescription, LabResult, Referral)
- **Phase A Step 2:** Governance requirements in Enterprise::Regulation (8 requirement defs)
- **Phase A Step 3:** Evaluable constraints in Knowledge::ConstraintLibrary (8 constraint defs, 8 satisfy relationships)
- **Phase A Step 4:** MetadataLibrary review — existing metadata defs confirmed sufficient, no additions needed
- **Phase B Step 5:** Domain-layer action flow (14 action steps with clinical metadata annotations)
- **Phase C Step 6:** Orchestration-layer action flow (22 action steps with Temporal metadata)
- **Phase D Step 7:** SysML v2 `view`/`viewpoint` elements investigated — deferred (tooling not ready)

### All model changes verified clean in Syside Modeler 0.8.5 with zero errors.

---

## 2. Repository State

### Repository

- **GitHub:** `ella66gr/gsl-tech-sysmlv2-model`
- **Local path:** `~/Developer/gsl-tech/gsl-sysml-model/`

### Files Modified

| File | Changes |
|---|---|
| `model/service-delivery.sysml` | Entity lifecycle state machines, domain-layer action flow, orchestration-layer action flow |
| `model/enterprise.sysml` | 8 governance requirement defs for hormone initiation |
| `model/knowledge.sysml` | 8 constraint defs, 8 constraint usages, 8 satisfy relationships |
| `model/foundation.sysml` | MetadataLibrary doc comment updated (review outcome recorded) |
| `documentation/gsl-sysml-v2-syntax-reference-v3.2-2026-03-06.md` | Versioned from v3.1; 3 new sections, 7 new verified patterns, TODO updates |
| `documentation/gsl-hormone-initiation-modelling-plan-2026-03-06.md` | Created at start of session |

### Git Commits (5 commits this session)

1. **Entity lifecycle state machines** — EpisodeLifecycle, PrescriptionLifecycle, LabResultLifecycle, ReferralLifecycle with exhibit state on part defs. Discovered `ordered` and `accepted` state name traps.

2. **Governance requirements** — 8 requirement defs covering consent, patient information, baseline investigations, prescribing governance, monitoring, and shared care. Regulatory basis documented (GMC, CQC, Montgomery, NICE/Endocrine Society, BMA/RCGP).

3. **Constraints and satisfy traceability** — 8 constraint defs with evaluable boolean bodies, 8 constraint usages, 8 satisfy relationships providing formal traceability from runtime checks to governance requirements.

4. **Domain-layer action flow** — InitiateHormoneTherapyProcess with 14 action steps, clinical metadata annotations, monitoring loop, and decision branching. First use of clinical metadata defs on action steps. Backward `then` reference (loop) verified.

5. **Orchestration-layer action flow** — InitiateHormoneTherapyWorkflow with 22 action steps mapped to Temporal execution. @TemporalWorkflow, @TemporalActivity, @TemporalSignal, @StateTransitionTrigger annotations. First use of both TemporalMetadata and Foundation::MetadataLibrary in the same package.

---

## 3. Model Element Counts (Post-Session)

### service-delivery.sysml — ClinicalEntities

| Element Type | Count | Details |
|---|---|---|
| Part definitions | 6 | Patient, Episode, Consultation, Prescription, LabResult, Referral |
| State definitions | 4 | EpisodeLifecycle, PrescriptionLifecycle, LabResultLifecycle, ReferralLifecycle |
| Event attribute defs | 22 | 5 Episode + 6 Prescription + 5 LabResult + 6 Referral |
| Exhibit state usages | 4 | One per entity with lifecycle |

### service-delivery.sysml — HormoneTherapy

| Element Type | Count | Details |
|---|---|---|
| Use case definitions | 3 | InitiateHormoneTherapy, MonitorHormoneTherapy, TransitionToSharedCare |
| Action definitions | 2 | InitiateHormoneTherapyProcess (domain), InitiateHormoneTherapyWorkflow (orchestration) |
| Domain action steps | 14 | 4 phases: eligibility/consent/baseline, prescribing, monitoring cycle, transition |
| Orchestration action steps | 22 | Activities (11), signal waits (8), with state transition triggers (8) |

### enterprise.sysml — Regulation

| Element Type | Count | Details |
|---|---|---|
| Use case definitions | 4 | CQC, data protection, clinical safety, professional standards |
| Requirement definitions | 8 | Consent (2), baseline investigations (1), prescribing (2), monitoring (2), shared care (1) |

### knowledge.sysml — ConstraintLibrary

| Element Type | Count | Details |
|---|---|---|
| Constraint definitions | 8 | One per requirement |
| Constraint usages | 8 | One per definition (required for satisfy `by` target) |
| Satisfy relationships | 8 | One-to-one mapping constraints to requirements |

---

## 4. New Verified Syntax Patterns

Seven new patterns verified in Syside Modeler 0.8.5 during this session:

### 4.1 Entity lifecycle state machines with `exhibit state`

`exhibit state name : StateDef;` inside a `part def` connects a lifecycle state machine to the structural element. Event `attribute def` declarations scoped to the same package. Multiple state defs coexist in the same package. All verified.

### 4.2 Reserved and shadowed state names (syntax traps)

| State name | Problem | Error | Fix |
|---|---|---|---|
| `state ordered;` | `ordered` is a SysML v2 keyword | `parsing-error` | Use `requested` |
| `state accepted;` | Shadows `StatePerformances::StatePerformance::accepted` | `namespace-distinguishability` | Use `referralAccepted` |

**General rule:** Avoid short, generic English words as state names. Known safe names: `created`, `active`, `suspended`, `completed`, `cancelled`, `drafted`, `authorised`, `dispensed`, `collected`, `resulted`, `reviewed`, `actioned`, `sent`, `acknowledged`, `declined`.

### 4.3 Clinical metadata annotations on action steps

All six clinical metadata defs (`@ClinicalReviewGate`, `@ConsentRequired`, `@AuditPoint`, `@LogicRule`, `@DecisionTable`, `@SafetyConstraint`) defined in `Foundation::MetadataLibrary` and imported via `private import Foundation::MetadataLibrary::*;` resolve correctly as `@` annotations on action steps in a different package. Multiple `@` annotations on a single step verified.

### 4.4 Same-file sibling package import

`private import ServiceDelivery::ClinicalEntities::*;` from within `ServiceDelivery::ClinicalPathways::HormoneTherapy` resolves correctly. A package can import from a sibling package within the same top-level package in the same file.

### 4.5 Backward `then` reference (action flow loop)

`then scheduleMonitoringBloods;` from `adjustDose` resolves to an earlier action declaration within the same `action def`. Action flow loops via backward `then` references work. The `then` keyword resolves by name within the enclosing `action def`, not just positionally.

### 4.6 Cross-project metadata import on action steps

`@TemporalWorkflow`, `@TemporalActivity`, `@TemporalSignal`, `@StateTransitionTrigger` from the shared metadata library (`sysml-metadata-lib/temporal/`) imported and applied alongside `Foundation::MetadataLibrary` annotations in the same package. Both metadata libraries coexist without issues.

### 4.7 Scale: 22 action steps in a single action def

No degradation or errors with larger action defs. 22 steps with mixed annotation patterns (activities, signals, state transition triggers), branching, and backward loop all parse clean.

---

## 5. Design Decisions

### 5.1 Prescription immutability

Dose adjustments complete the current Prescription and create a new one, rather than mutating the existing record. Each Prescription is an immutable record of what was prescribed, at what dose, for what period. This supports audit trail integrity and simplifies lifecycle state management.

### 5.2 Entity lifecycles as standalone state defs

Entity lifecycles are defined as standalone `state def` blocks rather than specialising `StandardLifecycle` via `:>`. This keeps us on verified syntax ground. State def specialisation remains on the TODO list for future investigation but is not blocking.

### 5.3 LabResult: `reviewed` vs `resulted` distinction

The LabResultLifecycle makes an explicit governance distinction between `resulted` (data available in CDR) and `reviewed` (clinician has seen it and recorded interpretation). The pathway's clinical review gates check for `reviewed`, not `resulted`. This is clinically significant — results existing in the system is not the same as a clinician having reviewed them.

### 5.4 Referral: `declined` as terminal state

When a referral is declined, the Referral entity reaches a terminal state. Re-referral creates a new Referral entity rather than reusing the declined one. This preserves the audit trail of the declined referral and its reasons.

### 5.5 Domain-layer metadata annotations

Clinical metadata annotations (`@ClinicalReviewGate`, `@ConsentRequired`, etc.) are applied to domain-layer action steps, not just orchestration-layer steps. This is a deliberate choice: the domain layer should indicate *what kind* of governance control each step represents, even though the domain layer's primary audience is clinical governance. This makes the domain model self-describing for governance purposes.

### 5.6 Orchestration: human activities become signal waits

Domain-layer human activities ("clinician reviews results") map to orchestration-layer signal waits ("workflow suspends until clinician-review-completed signal received from portal"). This is the core mapping principle. Activities that a human performs cannot be orchestrated by the workflow — the workflow can only wait for the human to signal completion.

### 5.7 Orchestration: notification steps before review waits

The orchestration layer adds explicit notification activities (e.g. `notifyBaselineResultsReady`) before clinician review signal waits. These don't appear in the domain layer because the domain layer describes *what clinicians do*, not *how the system prompts them*. The notification is an orchestration concern.

### 5.8 Signal timeouts reflect clinical reality

Orchestration-layer signal timeouts are set to clinically realistic durations: 30 days (43,200 minutes) for consent and lab results, 14 days (20,160 minutes) for clinician reviews, 120 days (172,800 minutes) for monitoring cycle waits. These are not arbitrary — they reflect the actual clinical timescales of hormone therapy initiation.

---

## 6. Syntax Reference Status

The syntax reference has been versioned to **v3.2** (6 March 2026) and renamed to `gsl-sysml-v2-syntax-reference-v3.2-2026-03-06.md`. Previous version preserved as `gsl-sysml-v2-syntax-reference-v3.1-2026-03-05.md` in git history.

### Changes in v3.2

- New section: **Entity Lifecycle State Machines** with exhibit state pattern and reserved/shadowed state name traps
- New section: **Domain-Layer Action Flow with Clinical Metadata** covering clinical metadata on action steps, same-file sibling import, backward `then` loop, and scale verification
- TODO updates: `view`/`viewpoint` investigated and deferred with detailed rationale. `state def` specialisation added. Six items marked as done.

---

## 7. Deferred Items

### 7.1 SysML v2 `view` / `viewpoint` elements (Step 7)

Investigated during this session. Sensmetry community forum (January 2026) confirms that rendering results from modelled views is "still a work in progress and not yet possible from Automator." The Sensmetry cheat sheet (August 2025) omits `view def`/`viewpoint def` syntax entirely. No worked examples of the textual syntax exist in Sensmetry documentation. Syside 0.8.5 release notes claim `view` element support but practical utility requires rendering output. **Deferred until tooling matures.**

### 7.2 Items deferred from the modelling plan

These items were intentionally deferred in the original plan and remain deferred:

- **openEHR archetype design** — pathway identifies data capture points; archetype work deferred to CDR integration exercise
- **Generator migration to Syside Automator** — confirmed ready but not blocking
- **Front-end design** — downstream of model
- **Shared care protocol detail** — modelled as single action step; internal complexity is a separate pathway
- **Prescribing protocol detail** — regimen selection is a decision point; DMN-style table deferred to Knowledge::DecisionModels

### 7.3 Syntax patterns still unverified

- `decide` / `merge` control nodes (less urgent now that action-node decisions and backward loops work)
- Guard conditions on action flow transitions
- `fork` / `join` for parallel actions
- `verify` relationships
- `state def` specialisation (`:>`)
- `view` / `viewpoint` elements (deferred — see 7.1)

---

## 8. Companion Documents

These documents are current as of this session and should be available to the next session:

1. **`gsl-sysml-v2-syntax-reference-v3.2-2026-03-06.md`** — Living syntax reference, versioned and updated this session
2. **`gsl-architecture-principles.md`** — Separation principle, openEHR CDR, governance patterns (unchanged from 4 March)
3. **`gsl-sysml-modelling-strategy.md`** — Comprehensive modelling rationale, three-tier reasoning stack, concentric rings (unchanged from 4 March)
4. **`gsl-package-hierarchy-proposal.md`** — Tree diagram of the package hierarchy (unchanged)
5. **`gsl-hormone-initiation-modelling-plan-2026-03-06.md`** — Modelling plan created this session; all substantive steps completed

---

## 9. Recommended Next Steps

### 9.1 Immediate: Coffee shop CDR extension exercise

The architecture principles document recommends validating openEHR integration patterns via a coffee shop CDR extension exercise before applying them to clinical data. This includes standing up EHRbase locally, designing minimal archetypes and templates, committing compositions from Temporal workflow activities, querying via AQL, and running a population-level governance query.

The hormone therapy pathway has now defined *what* clinical data is captured and *when* — this directly informs the archetype design for the CDR exercise.

### 9.2 Near-term: Elaborate the monitoring pathway

The hormone initiation pathway transitions to an ongoing monitoring pathway (via `transitionToOngoingCare`). This monitoring pathway (`MonitorHormoneTherapy` use case) is structurally simpler — it's essentially the monitoring cycle from the initiation pathway extracted as a standalone repeating workflow. Modelling this would validate the pattern of one workflow spawning another.

### 9.3 Near-term: Decision model for regimen selection

The domain-layer `selectRegimen` step references a decision table (`@DecisionTable { tableName = "regimenSelection"; }`). Modelling the actual regimen selection decision table in `Knowledge::DecisionModels` would exercise the DMN-style decision modelling pattern and connect the pathway to the knowledge layer.

### 9.4 Medium-term: Generator adaptation

The orchestration-layer action flow is the generation target for `gen_temporal_workflow.py`. The existing generator (from the demonstrator) can be adapted to produce a TypeScript workflow function from `InitiateHormoneTherapyWorkflow`. Key new patterns to handle: the monitoring loop (backward `then`), branching at the stability assessment, and the larger number of steps.

Syside Automator (confirmed as regex generator replacement) can be used for this adaptation, providing semantic model access rather than regex parsing.

---

## 10. Working Practices Reminder

- **Syntax reference first:** Always check `documentation/gsl-sysml-v2-syntax-reference-v3.2-2026-03-06.md` before writing new `.sysml` code
- **Version the syntax reference:** Bump version number and rename file at the start of any session that adds verified findings, not at the end
- **Verify in Syside:** All new patterns should be tested in Syside Modeler and results captured in the syntax reference
- **Phase exit criteria:** Document what was verified, what traps were found, and update the TODO list
- **Git commits at checkpoints:** Commit when model + verification are known-good
- **MCP filesystem access:** Claude has access to `~/Developer/gsl-tech/` and can read/write files directly. Ella runs shell commands and pastes output back
- **Syside Modeler version:** 0.8.5 (VS Code extension, 1 March 2026)
- **Development environment:** macOS (MacBook Pro), Python 3.12, VS Code

---

*Report generated at end of session, 6 March 2026. For use as context in subsequent chat session.*
