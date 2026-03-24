# Session 67 Report — 24 March 2026

**Session type:** Implementation / Housekeeping (§3.5 mixed) — rebaselining workstream
**Duration:** Standard session
**Previous session:** [[session-66-report-2026-03-24|Session 66]] (Strategic snapshot refresh, stable filename convention)
**Style:** EXECUTION

---

## 1. What Was Done

### 1.1 Service Business Meta Modelling v2 (Priority A — complete)

The [[ontara-service-business-meta-modelling-v2|Service Business Meta Modelling]] foundations paper received a full v2 revision as the final major document in the rebaselining workstream. The v2 (`ontara-service-business-meta-modelling-v2.md`) replaces a v1 from 10 March 2026 (Session ~16) that used pre-Ontara naming throughout and predated significant architectural developments.

**Key changes from v1:**

- **Five concerns → six.** [[principle-clinical-governance-first-class|GovernanceMapping]] is now a named concern package alongside ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, and Strategy/Evolution. Added Session 42 when the [[domain-suds|Suds]] demonstrator required COSHH governance traceability.
- **[[concept-service-subject|ServiceSubject]] and [[concept-service-participant|ServiceParticipant]] incorporated.** Introduced Session 55 to resolve the subject-≠-customer observation from [[domain-paws|Paws]]. Sibling concepts validated across all four domains.
- **Element count updated.** 28 core elements in `BusinessModel`, plus 14 in `BusinessScenarios`/`BusinessStrategy`, for 42 total. All classified as General ([[ontara-discussion-component-catalogue-model-assembly-2026-03-18|B11]]).
- **New §4: [[concept-comprehension-layer|Comprehension Architecture]] and the BMM.** 28/28 annotation coverage, 79 [[concept-weighted-relationships|weighted relationships]], three-register model, and [[ontara-ref-vision-architecture|Ontara Console]] views.
- **New §5: [[concept-cross-domain-validation|Cross-Domain Validation]].** Concrete findings from [[domain-cafe|Cafe]], [[domain-suds|Suds]], [[domain-paws|Paws]], plus GSL.
- **Package structure updated** to reflect actual three-file structure with typed cross-references (post-[[deferred-string-to-typed-ref-migration|O25]] migration).
- **Mapping to existing system model** updated from "not yet modelled" to "now modelled" for most concerns.
- **Forward direction** incorporates B20 (IG/cybersecurity), [[deferred-system-meta-model-extraction|BSMM extraction]], [[concept-domain-identity|domain identity (B15)]], ontological grounding (B18/B19), and reasoning formalisms (M7).
- **GSL/GenderSense → Ontara** throughout (platform identity). GSL retained as a named tenant under the [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|multi-tenancy principle (A13)]].

**What was preserved:** The six-concern conceptual framework (originally five), [[pattern-activity-taxonomy|Activity Awareness]] as a cross-cutting foundation with progressive elaboration, the modularity principle, the scenario modelling mechanics and operational steering cycle, the simulation vision, and the architectural connection between operational steering and the [[concept-self-knowledge-architecture|self-knowledge architecture]].

### 1.2 Wikilink enrichment of v2

The vault copy received a full enrichment pass adding links to: concept notes (service subject, service participant, catalogue entry, external reference, inventory record, weighted relationships, persistence policy, agency classification), pattern notes (four-layer item model, two-layer action flow, five-layer self-knowledge), principle notes (governance as first-class concern A8), domain notes (Suds, Cafe), deferred items (system meta model extraction, string-to-typed-ref migration), and the [[concept-non-constraining|non-constraining principle (J3)]].

### 1.3 Two new concept notes created

- `concept-service-subject.md` — created during the enrichment pass per §8.4 of the [[ontara-workflow-development-guide-v2-2026-03-23|workflow guide]].
- `concept-service-participant.md` — created during the enrichment pass per §8.4.

Both notes follow the concept template with YAML frontmatter, domain instantiation status, related concepts, and source references.

### 1.4 v1 frontmatter updated

The original `ontara-service-business-meta-modelling.md` had its YAML frontmatter updated: `status: superseded`, `superseded_by: ontara-service-business-meta-modelling-v2`, title updated to include "(v1, Superseded)", and the revision-pending callout replaced with a supersession notice pointing to the v2.

---

## 2. Decisions Made

| Decision | Rationale |
|---|---|
| Produce v2 as a separate file, not in-place edit | Per §6.4 — major revisions as separate files so Ella can compare with original |
| Count all 42 BMM elements (not just the 28 in BusinessModel) | The full BMM vocabulary spans three packages; the v2 documents all of them with a clear distinction between core (28) and projection/strategy (14) |
| All BMM elements classified as General | Validated finding — four structurally different domains modelled without requiring Tailored extensions |
| GovernanceMapping as a sixth concern (not replacing Governance and Adaptation) | The original "Governance and Adaptation" was broader; GovernanceMapping is the BMM-specific traceability vocabulary. The broader ecosystem spans both BMM and BSMM. |

---

## 3. Register Concepts Exercised

| Code | Concept | How exercised |
|---|---|---|
| A4 | [[principle-two-meta-model-distinction\|Two meta model distinction]] | Central to the document; BMM/BSMM distinction described with current state |
| A8 | [[principle-clinical-governance-first-class\|Governance as first-class concern]] | GovernanceMapping concern documented; COSHH validation cited |
| A9 | [[principle-discipline-as-load-bearing-structure\|Discipline as load-bearing structure]] | Rigorous full revision to presentable standard |
| A10 | [[principle-intrinsic-self-knowledge\|Intrinsic self-knowledge]] | Comprehension architecture section (§4) documents A10 realisation |
| A11 | [[principle-unity-principle\|Unity principle]] | Weighted relationships section (§4.2) |
| A13 | Multi-tenancy (T1 candidate) | GSL reframed as tenant, not platform identity |
| B11 | General/Tailored decomposition | All 42 elements classified; finding that all are General documented |
| B14 | [[concept-weighted-relationships\|Weighted relationships]] | 79 weights documented |
| J1 | [[concept-cross-domain-validation\|Cross-domain validation]] | New §5 with concrete validation findings |
| J2 | [[concept-co-evolution\|Co-evolution]] | Console views documented as BMM legibility tooling (§4.4) |
| J3 | [[concept-non-constraining\|Non-constraining]] | Forward direction preserves optionality for reasoning formalisms, ontological grounding |

**New concept notes created:** `concept-service-subject`, `concept-service-participant`.

---

## 4. Emergent Ideas

No new emergent ideas captured this session. The work was faithful execution of the rebaselining plan.

---

## 5. Open Questions and Deferred Items

| Item | Status |
|---|---|
| Workflow guide v2 stable filename rename | Captured for next session. The workflow guide (`ontara-workflow-development-guide-v2-2026-03-23`) uses a dated filename and should be renamed to a stable filename per §6.4. Affects wikilinks across the vault. |
| Priority B: Broken wikilink cleanup (pre-Session 61 reports) | Deferred from Session 67 preparation note. Best handled as a systematic MCP pass or Code task. |
| Priority C: Archive S60 strategic snapshot from git history | Deferred. Code task. |

---

## 6. Rebaselining Workstream Status

| Document | Status |
|---|---|
| [[ontara-ref-vision-architecture\|Vision and Architecture Reference]] | **v2 complete** (Session 62) |
| [[ontara-platform-architecture-principles-v2\|Architecture Principles]] | **v2 complete** (Session 64) |
| [[ontara-platform-sysml-modelling-strategy-v2\|SysML Modelling Strategy]] | **v2 complete** (Session 65) |
| [[ontara-service-business-meta-modelling-v2\|Service Business Meta Modelling]] | **v2 complete** (Session 67, this session) |
| [[ontara-guide-editing-package-hierarchy\|Package Hierarchy Guide]] | Updated (Session 65) |
| [[SUPERSEDED-ontara-guide-repo-conventions\|Repo Conventions Guide]] | Archived (Session 65) |

**All major foundations papers are now revised.** The rebaselining workstream can be assessed for closure. The workflow guide stable filename rename (noted above) is a residual housekeeping item, not a foundations paper revision.

---

*Session 67 report written 24 March 2026.*
