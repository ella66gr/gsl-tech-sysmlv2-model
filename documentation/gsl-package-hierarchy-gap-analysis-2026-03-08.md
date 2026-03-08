# Package Hierarchy — Model vs Proposal Gap Analysis

**Date:** 8 March 2026
**Status:** Gaps resolved. All 14 missing Platform packages added to model. Proposal updated with correct naming. This document retained as a record of the reconciliation.

**Method:** Direct comparison of `.sysml` model files (read via MCP filesystem) against the markdown package hierarchy proposal document.

---

## 1. Summary

The model and the proposal are well aligned at the top two levels. All six top-level packages exist in both. Most second-level packages exist in both. The significant gaps were in **Platform**, where the proposal had elaborated the PatientPortal, Education, and Community sub-packages into a much richer structure than the model contained.

**Resolution (8 March 2026, Session 7):** All 14 missing Platform packages added to `platform.sysml`. Proposal updated with corrected naming (`IdentityAndAvatar`, `PrescribingSystem`) and TemporalMetadata location note. Model and proposal are now fully reconciled.

---

## 2. Package-by-Package Comparison

### 2.1 GenderSense (root)

| Aspect | Model | Proposal | Status |
|---|---|---|---|
| Root package | ✓ `package GenderSense` | ✓ `GenderSense` | **Match** |
| Doc block | ✓ Comprehensive | — (tree only) | Model richer |

### 2.2 Enterprise

| Package | Model | Proposal | Status |
|---|---|---|---|
| Enterprise | ✓ | ✓ | **Match** |
| Organisation | ✓ (Role, Team, GovernanceBody) | ✓ | **Match** |
| Regulation | ✓ (use cases + 8 requirement defs for HT pathway) | ✓ | **Model richer** — proposal just says "CQC, ICO/GDPR, DCB0129, professional standards" |
| Strategy | ✓ (Partnership, BusinessModel) | ✓ | **Match** |
| Risk | ✓ (3 use cases) | ✓ | **Match** |

**No gaps.**

### 2.3 Knowledge

| Package | Model | Proposal | Status |
|---|---|---|---|
| Knowledge | ✓ | ✓ | **Match** |
| ClinicalDecisionSupport | ✓ (3 use cases) | ✓ | **Match** |
| ConstraintLibrary | ✓ (8 constraint defs, 8 usages, 8 satisfy relationships) | ✓ | **Model richer** |
| LogicEngine | ✓ (doc block only) | ✓ | **Match** (both placeholder) |
| DecisionModels | ✓ (doc block only) | ✓ | **Match** (both placeholder) |
| OutcomeFramework | ✓ (1 part def: OutcomeDefinition) | ✓ | **Match** |
| LearningCycles | ✓ (2 use cases) | ✓ | **Match** |
| Analytics | ✓ (1 part def: DataContract) | ✓ | **Match** |

**No gaps.**

### 2.4 ServiceDelivery

| Package | Model | Proposal | Status |
|---|---|---|---|
| ServiceDelivery | ✓ | ✓ | **Match** |
| PatientJourney | ✓ (5 use cases) | ✓ | **Match** |
| ClinicalPathways | ✓ | ✓ | **Match** |
| ClinicalPathways::HormoneTherapy | ✓ (3 use cases, full domain + orchestration action flows) | ✓ | **Model much richer** |
| ClinicalPathways::Assessment | ✓ (3 use cases) | ✓ | **Match** |
| ClinicalPathways::Referrals | ✓ (3 use cases) | ✓ | **Match** |
| ClinicalPathways::Prescribing | ✓ (3 use cases) | ✓ | **Match** |
| Consent | ✓ (3 use cases) | ✓ | **Match** |
| CoachingSupport | ✓ (2 use cases) | ✓ | **Match** |
| ClinicalGovernance | ✓ (3 use cases) | ✓ | **Match** |
| ClinicalEntities | ✓ (Patient, Episode, Consultation, Prescription, LabResult, Referral — 4 with full lifecycle state machines) | ✓ | **Model much richer** |

**No gaps.**

### 2.5 Platform

| Package | Model | Proposal | Status |
|---|---|---|---|
| Platform | ✓ | ✓ | **Match** |
| PatientPortal | ✓ (2 use cases + 5 sub-packages) | ✓ | **Match** |
| PatientPortal::SelfManagement | ✓ (3 use cases) | ✓ | **RESOLVED** |
| PatientPortal::IdentityAndAvatar | ✓ (3 use cases, rich doc block) | ✓ | **RESOLVED** |
| PatientPortal::Journal | ✓ (2 use cases) | ✓ | **RESOLVED** |
| PatientPortal::SessionPlanning | ✓ (2 use cases) | ✓ | **RESOLVED** |
| PatientPortal::DocumentAccess | ✓ (3 use cases) | ✓ | **RESOLVED** |
| Education | ✓ (4 sub-packages) | ✓ | **RESOLVED** |
| Education::KnowledgeBase | ✓ (2 use cases) | ✓ | **RESOLVED** |
| Education::LearningContent | ✓ (1 use case) | ✓ | **RESOLVED** |
| Education::TherapyPathways | ✓ (2 use cases) | ✓ | **RESOLVED** |
| Education::ContentDelivery | ✓ (2 use cases) | ✓ | **RESOLVED** |
| Community | ✓ (3 sub-packages) | ✓ | **RESOLVED** |
| Community::GroupSpaces | ✓ (2 use cases) | ✓ | **RESOLVED** |
| Community::GroupSessions | ✓ (2 use cases) | ✓ | **RESOLVED** |
| Community::PeerMessaging | ✓ (1 use case) | ✓ | **RESOLVED** |
| Booking | ✓ (2 use cases) | ✓ | **Match** |
| EHR | ✓ (5 part defs, 4 use cases) | ✓ | **Model much richer** |
| Forms | ✓ (2 use cases) | ✓ | **Match** |
| Messaging | ✓ (2 use cases) | ✓ | **Match** |
| VideoConsulting | ✓ (1 use case) | ✓ | **Match** |
| LabInterface | ✓ (2 use cases) | ✓ | **Match** |
| PrescribingSystem | ✓ (2 use cases) | ✓ | **Match** (proposal updated) |
| Payments | ✓ (2 use cases) | ✓ | **Match** |
| Documents | ✓ (2 use cases) | ✓ | **Match** |
| Identity | ✓ (1 part def, 2 use cases) | ✓ | **Match** |
| Orchestration | ✓ (doc block only) | ✓ | **Match** |
| Integration | ✓ (doc block only) | ✓ | **Match** |

**All gaps resolved.**

### 2.6 Operations

| Package | Model | Proposal | Status |
|---|---|---|---|
| Operations | ✓ | ✓ | **Match** |
| Finance | ✓ (2 use cases) | ✓ | **Match** |
| People | ✓ (doc block only) | ✓ | **Match** |
| Marketing | ✓ (1 use case) | ✓ | **Match** |
| CRM | ✓ (doc block only) | ✓ | **Match** |
| Reporting | ✓ (2 use cases) | ✓ | **Match** |

**No gaps.**

### 2.7 Foundation

| Package | Model | Proposal | Status |
|---|---|---|---|
| Foundation | ✓ | ✓ | **Match** |
| MetadataLibrary | ✓ (6 clinical + 3 openEHR metadata defs) | ✓ | **Model richer** |
| CommonTypes | ✓ (5 enums, 2 part defs) | ✓ | **Match** |
| StatePatterns | ✓ (StandardLifecycle state def, 5 event defs) | ✓ | **Match** |
| GenerationPipeline | ✓ (doc block only) | ✓ | **Match** |

**No gaps.**

### 2.8 TemporalMetadata (library)

TemporalMetadata lives in `libraries/temporal-metadata/` as a separate top-level package. Proposal updated with a note documenting this arrangement.

---

## 3. Next Step: Verify in Syside

The updated `platform.sysml` should be verified clean in Syside Modeler 0.8.5. The new packages use only `package`, `doc`, and `use case def` constructs — all previously verified. The three-level nesting (Platform → PatientPortal → SelfManagement) should work but has not been tested at this depth in this specific file.

---

*Analysis performed and gaps resolved 8 March 2026 (Session 7).*
