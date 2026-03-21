# Session 55 Report — Phase 4 Step 3 Complete: ServiceSubject and ServiceParticipant

**Date:** 21 March 2026
**Session type:** Discussion + implementation
**Participants:** Ella Green, Claude (Opus 4.6)

---

## 1. Summary

Session 55 completed Phase 4 Step 3 — the service subject ≠ customer resolution. Through a discussion that significantly deepened the initial analysis, two sibling General BMM concepts were introduced: `ServiceSubject` (the entity the service acts on) and `ServiceParticipant` (any entity involved in a defined role). Both received full annotation stacks, weighted relationships, and Paws domain instantiations. **Phase 4 is now complete.**

**Key results:**
- **Two new General BMM `part def`s** in `BusinessModel::ServiceConcept`: `ServiceSubject` (5 attributes, 5 weights) and `ServiceParticipant` (5 attributes, 4 weights). Siblings, not a hierarchy — either can independently trigger workflows.
- **Paws instantiations:** `dogSubject` (service subject — the dog) and `petOwnerParticipant` (customer/payer/decision-maker — the pet owner). Closes the original observation from Session 44.
- **Service Participation Model discussion document** produced — captures the full architectural direction: participation as a framework with open roles, many-to-many relationships, independent status tracking, and workflow influence. Future work queued without being foreclosed.
- **28 BMM elements, 79 total weights** (27 strong, 50 moderate, 2 weak) across 27 weighted elements. AuditEvidenceRecord remains a pure receiver.
- **Master register updated** — O13 (service subject observation resolved), O20 (Phase 4 closed), O21 (28/28 coverage), O26 (participation framework as future direction).

---

## 2. Work Performed

### 2.1 Analytical Discussion — Service Subject ≠ Customer

The session began with Claude's initial analysis framing three options: (a) no structural change, (b) new `ServiceSubject` concept, (c) attribute-level refinement. Recommendation was Option (b).

Ella's response reframed the question fundamentally in two stages:

**First correction:** The distinction is not a single separation but a **family of participation roles**. Examples given: a repair shop with three items (two for repair, one for a quote) triggering independent workflows with different timescales; a patient with concurrent clinical problems tracked separately with different clinicians; two customers jointly and severally liable for financial advice. The structural properties: multiple roles, many-to-many relationships at every level, independent status tracking per participation, either subject or participant can trigger workflow.

**Second correction:** Claude's attempt to classify roles as "general" or "tailored" was rejected. Whether a role feels general on a Saturday afternoon in March is irrelevant to whether the framework should accommodate it. The General BMM provides the structural framework; which roles a business instantiates is their decision. Direct application of [[concept-non-constraining|J3]].

### 2.2 Design Decision: Two Sibling Concepts

Ella proposed — and the discussion confirmed — that both `ServiceSubject` and `ServiceParticipant` should exist as independent sibling concepts, not a hierarchy. Reasoning:

- The service subject is categorically distinct — the service acts *on* it. Other participants influence the engagement.
- Either concept can independently trigger workflows. They have parallel structural power.
- A hierarchy (`ServiceSubject :> ServiceParticipant`) would constrain future evolution by implying that everything true of a participant is true of a subject.
- Sibling concepts are related by weighted relationships but not structurally locked. Cleaner and more non-constraining.

### 2.3 KerML Reserved Words Check

`subject` confirmed as NOT a KerML 1.0 reserved word (checked against `02 ARCHITECTURE & MODELLING/Design & Build Reference/KerML-Reserved-Words.md`). It IS a SysML v2 contextual keyword (requirement/case defs), but safe as a compound `part def` name. Syside validated cleanly.

### 2.4 Implementation

Both `part def`s inserted in `model/business-model.sysml` (ServiceConcept package, between DifferentiationClaim and catalogue abstractions). Both Paws instantiations inserted in `paws.sysml`. Paws package doc block updated to mark the original observation as resolved. Generator run confirmed: 28 elements, 79 weights, 100% annotation coverage. Console data updated and committed to GitHub.

---

## 3. Concepts Exercised

| Concept | How |
|---|---|
| [[concept-non-constraining\|J3]] (non-constraining) | Framework designed to accommodate future roles without structural change. General/Tailored classification of individual roles rejected. Sibling concepts rather than constraining hierarchy. Open String types for role vocabulary. |
| [[concept-cross-domain-validation\|J1]] (cross-domain validation) | Observation surfaced from Paws (S44), validated across Paws, Suds, Cafe, GSL, plus repair shop and financial advice examples |
| [[concept-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | Both concepts receive full annotation stacks. Comprehension content generated from model. |
| [[concept-unity-principle\|A11]] (unity principle) | 9 new weighted relationships connect both concepts to existing BMM vocabulary and to each other. Asymmetric cross-weight (B14 non-commutativity). |
| [[concept-co-evolution\|J2]] (co-evolution) | Model concepts → generator → console data advanced together |
| [[concept-model-generates-everything\|A3]] (model generates everything) | All metadata derived from model annotations |
| [[concept-inception-capture\|J13]] (inception capture) | Participation framework insight captured in full at the moment of recognition via discussion document |
| [[concept-design-decision-lifecycle\|J12]] (design decision lifecycle) | ServiceParticipant role vocabulary deliberately left as String (experimentation stage) — typed vocabulary deferred to future phase |
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline) | KerML reserved words checked before naming. Syside validation before generator run. |

---

## 4. Documents Produced

| Document | Type | Location |
|---|---|---|
| Service Participation Model discussion | Discussion document | Container artifact → Vault: `Ontara/Vision, Strategy & Development Reference/` (or `Exploratory & Discussion Papers/` at Ella's discretion) |
| Phase 4 Step 3 implementation plan | Implementation plan | Container artifact → Vault: `Ontara/Plans/` |
| Session 55 report | Session report | Container artifact → Vault |
| Session 56 preparation note | Handover | Container artifact → Vault |

---

## 5. Git Commands

```bash
cd ~/Developer/gsl-tech/gsl-sysml-model

# Already committed and pushed:
# S55: Phase 4 Step 3 — ServiceSubject and ServiceParticipant (99c4264)

# Archive session documents:
cp "/Users/ellagreen/Obsidian/GenderSense/02 ARCHITECTURE & MODELLING/Ontara/Session Reports, Prep & Handover/Sessions 51-60/session-55-report-2026-03-21.md" documentation/archive/session-reports/

git add documentation/archive/session-reports/session-55-report-2026-03-21.md

git commit -m "S55: Archive session report"

git push
```

---

## 6. Next Steps

1. **Phase 5 (O25)** — string-to-typed-ref migration. This unlocks cross-package weight traversal and the remaining weights that don't display in the glossary. Now more valuable with ServiceSubject and ServiceParticipant having cross-package weight targets.

2. **E003** — BMM Concern explanatory text in the glossary. A small, self-contained task: add `@PurposiveDescription` at package level, extend generator and glossary. Good palate cleanser before Phase 5.

3. **Stage 4 planning** — with Phase 4 complete, Stage 3 needs only Phase 5 to close. Stage 4 (structural navigation and construction) should be planned.

---

*Session report prepared 21 March 2026. Session 55.*
