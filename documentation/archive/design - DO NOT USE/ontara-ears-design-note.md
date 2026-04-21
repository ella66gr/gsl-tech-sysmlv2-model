---
tags:
  - demonstrator
  - ears
  - design-note
  - domain-intake
date: 2026-04-07
status: working
session: 167
---
# Ears Design Note
> `= this.file.path`

*Ontara Platform — Domain Intake Synthesis*

**Date:** 7 April 2026 (Session 167)
**Purpose:** Synthesises the findings from the Ears (Community Ear Care) domain intake — the coverage map (Session 165), the reasoning instance population (Session 166), and the vertical connection map (Session 162) — into an assessment of the Ontara platform's vocabulary adequacy for clinical domain intake. This is the third and final document in the intake pattern established by Paws: domain description → vertical connection map + coverage map → design note. It draws conclusions about what worked, what stretched, and what needs to evolve.
**Status:** Working document — domain analysis.
**Depends on:**
- [[ontara-ears-coverage-map|Ears Coverage Map]] (Session 165) — field-by-field vocabulary assessment, branching points, watchpoints
- `ontology/reasoning/ears-reasoning-instances.ttl` (Session 166) — ~83 named individuals exercising the reasoning vocabulary
- [[ontara-ears-vertical-connection-map|Ears Vertical Connection Map]] (Session 162) — six-layer systematic mapping, 7 design decisions
- [[ontara-ears-domain-description|Ears Domain Description]] (Session 161) — the domain content
- [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|Clinical Domain Intake Framework]] (Session 160) — governing methodology
- [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning]] (Session 146) — reasoning metamodel
- [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited]] (Session 147)

---

## Contents

- [[#1. What This Document Does|§1. What This Document Does]]
- [[#2. The Ears Intake in Summary|§2. The Ears Intake in Summary]]
- [[#3. Watchpoint Disposition|§3. Watchpoint Disposition]]
- [[#4. Vocabulary Adequacy Assessment|§4. Vocabulary Adequacy Assessment]]
- [[#5. Cross-Domain Comparison with Paws|§5. Cross-Domain Comparison with Paws]]
- [[#6. Meta-Constraints — A New Pattern|§6. Meta-Constraints — A New Pattern]]
- [[#7. Branching-Point Disposition|§7. Branching-Point Disposition]]
- [[#8. Implications for the Platform|§8. Implications for the Platform]]
- [[#9. Implications for GSL|§9. Implications for GSL]]
- [[#10. Design Decisions|§10. Design Decisions]]
- [[#11. Register Connections|§11. Register Connections]]
- [[#12. Critique Observations and Watchpoints|§12. Critique Observations and Watchpoints]]

---

## 1. What This Document Does

The [[domain-paws|Paws]] design note (Session 44) established the pattern: after the vertical connection map validates vocabulary *reach* and the coverage map quantifies vocabulary *coverage*, the design note asks the harder question — is the vocabulary *adequate*? Adequacy is more than coverage statistics. It asks whether the vocabulary supports the kind of reasoning, governance, and operational logic the domain actually requires, or whether the coverage numbers conceal semantic friction that will surface at implementation time.

For Ears, this question has an additional dimension that Paws lacked. The reasoning instance population (Session 166) moved beyond type-level assessment to instance-level testing — creating ~83 concrete OWL named individuals that exercise the reasoning vocabulary with real clinical content. The design note can therefore assess not only whether the vocabulary *types* are right (coverage map) but whether the vocabulary *works* when populated with real-world data (instances).

The design note is forward-looking. Its primary audience is the next phase of platform development — whether that is GSL clinical intake, governance activation, or meta model evolution. The question it answers is: given what Ears has shown us, what should we build next and what should we change?

---

## 2. The Ears Intake in Summary

Ears is a community ear care service — a small private clinic in Ely, Cambridgeshire, providing earwax removal by irrigation and microsuction. It is the first Ontara domain that is sector-regulated (CQC), clinically complex (branching decision pathways, contraindication screening, capacity assessment), and exercises the reasoning and governance vocabularies with real content.

The intake followed the three-document pattern across six sessions:

| Session | Deliverable | What it established |
|---|---|---|
| 161 | Domain description | The rich narrative: Helen, Ade, Del, Dr Mehta, six service offerings, domiciliary pathway, governance landscape, financial model |
| 162 | Vertical connection map | Six-layer mapping (ontology → BMM → reasoning → governance → instance → systems). 7 design decisions. 7 coverage gap candidates |
| 165 | Coverage map | 65 proforma fields assessed. 86.2% Full, 12.1% Partial, 1.7% Gap. 9 branching points. 4 watchpoints (WP-1 to WP-4) |
| 166 | Reasoning instances | ~83 OWL named individuals across 5 clinical exercises + STAMP/STPA. 25 of 42 reasoning classes exercised. Watchpoints assessed at instance level |
| 167 | Design note (this document) | Synthesis and adequacy assessment |

The Ears intake is the most thorough domain analysis in the project's history. The Paws intake (Sessions 43–44) used a four-layer vertical connection map and no formal coverage map or reasoning instances. The Ears intake adds the reasoning and governance vocabulary layers, a systematic proforma-based coverage methodology, concrete OWL instance testing, and embedded critique watchpoints. The methodology itself — the Clinical Domain Intake Framework (Session 160) — was developed specifically for this intake and is now a reusable platform capability.

---

## 3. Watchpoint Disposition

The coverage map embedded four watchpoints (WP-1 through WP-4) as testable predictions for the reasoning instance population. Session 166 assessed all four. This section reports their disposition and draws conclusions.

### 3.1 WP-1: Sub-field Coverage Stability Under Instance-Level Testing

**Prediction:** Fields assessed as Full at field level might reveal semantic friction when concrete OWL individuals are created.

**Disposition: Confirmed — type-level coverage holds at instance level.** The reasoning instance population created individuals for all five clinical exercises (triage, contraindication, procedure selection, outcome, capacity) and the STAMP/STPA safety structure. In every case, the vocabulary classes accommodated the clinical content without distortion.

Three specific sub-fields flagged for scrutiny:

**Contraindication logic** (absolute/relative distinction). The 7 HardConstraint individuals and 4 GradedRule individuals map precisely to their clinical referents. The absolute contraindications (perforation, grommets, middle ear surgery, only hearing ear, acute otitis externa, unexplained unilateral loss, cleft palate) are genuinely binary — each is a NormativeRegion boundary where crossing produces an immediate safety failure. The relative contraindications (anticoagulant therapy, previous adverse reaction, severe tinnitus, inability to cooperate) are genuinely graded — each produces a spectrum of clinical concern that influences but does not determine the procedure choice. The three-way constraint hierarchy (HardConstraint / GradedRule / SoftConstraint) is not merely adequate — it is the *right* abstraction. The clinical reality maps to the ontological structure with no semantic friction. This is the strongest single validation in the entire Ears intake.

**Procedure selection heuristics** (HeuristicPack family typing). The four heuristics in the procedure selection pack — hard wax → microsuction (DiagnosticHeuristic), anxious patient → extra explanation (CoordinationHeuristic), deep impaction → experienced operator (RiskHeuristic), bilateral mixed → combined approach (DiagnosticHeuristic) — each fit their family subtype without forcing. The family typing captures a real structural distinction in clinical heuristic knowledge: diagnostic heuristics map clinical findings to procedure choices, risk heuristics trigger escalation, coordination heuristics manage the clinician-patient interaction. The HeuristicPack container pattern works as designed — the pack is a coherent collection of domain-specific heuristics that belong together because they all inform the same decision.

**Capacity assessment** (MCA two-stage test). The MCA structure maps well to ReasoningContext → Plan → Decision. The two MCA stages (diagnostic and functional) become sequential steps in the Plan. The four functional elements (understand, retain, use, communicate) become four EvidenceItems within an EvidenceLine. No semantic friction. The legal-clinical intersection that the coverage map flagged as a potential friction point turns out to be a *strength* of the vocabulary — the MCA framework is both a reasoning structure and a governance obligation, and the vocabulary accommodates this duality naturally through the governance–reasoning alignment (Obligation as HardConstraint subclass).

**Conclusion:** WP-1 is satisfied. The 86.2% Full coverage statistic is not inflated by field-level aggregation — it holds when probed at instance level.

### 3.2 WP-2: Cross-Vocabulary Relation Binding

**Prediction:** Relations connecting BMM concepts to reasoning or governance concepts might require ad hoc bridging.

**Disposition: Partially confirmed — governance→reasoning is clean, BMM→reasoning is implicit.** The cross-vocabulary relation between governance and reasoning — where a governance Obligation *requires* a reasoning exercise (the MCA capacity assessment) — is expressible cleanly through PROV-O. The ReasoningActivity `prov:wasInfluencedBy` the Obligation; the reasoning exercise `prov:generated` the evidence that satisfies the obligation. No ad hoc bridging needed.

The cross-vocabulary relation between BMM and reasoning is less formally expressed. The connection between a BMM ServiceOffering (e.g. "Irrigation service A") and its associated ReasoningContext (the contraindication check) is implicit — it is understood from the clinical pathway structure but not explicitly stated in the OWL instances. The instances file connects ReasoningContexts to Goals, Constraints, and KnowledgeSources, but does not formally link them to the BMM ServiceOffering or WorkProcess that triggers them.

This is not a defect — the reasoning instances file intentionally operates within the `ontara-rsn:` vocabulary space and does not import BMM classes. The connection between BMM and reasoning vocabulary layers is an architectural design question: should there be explicit cross-vocabulary object properties (e.g. `ontara-rsn:triggeredBy` → BMM WorkProcess), or is the connection adequately expressed through the vertical connection map's analytical mapping and the coverage map's field-to-vocabulary assignments?

**Conclusion:** WP-2 reveals that governance→reasoning alignment is structurally sound (the subclass relationship and PROV-O provenance handle it). BMM→reasoning alignment is currently analytical (documented in the vertical connection map) rather than formal (expressed as OWL axioms). This is acceptable for now but should be revisited when cross-vocabulary queries become a requirement — for instance, if the console needs to show "which reasoning structures does this ServiceOffering exercise?"

### 3.3 WP-3: Partial Assessments Under Closer Scrutiny

**Prediction:** The 7 Partial assessments might prove more or less problematic than the type-level assessment suggested.

**Disposition: Partials are workable — semantic friction is real but manageable.** The reasoning instance population did not directly exercise all 7 Partial fields (several are in BMM concerns not targeted by instance work). However, the instance work provides indirect evidence:

**Service settings** (Partial — setting captures "where" but not "what changes because of where"). The reasoning instances confirm that the *reasoning layer* handles setting-dependent modification cleanly — the capacity assessment ReasoningContext explicitly captures the domiciliary-specific activation condition (mandatory at every care home visit, not just when capacity is in doubt). The friction is at the BMM level (Facility doesn't capture the cross-cutting modifying effect), not at the reasoning level.

**Medical oversight / competency framework** (Partial). Not directly exercised in reasoning instances, but the KnowledgeSource individuals (Helen's protocols, Mr Oluwo's training, NICE guidance) demonstrate that the *knowledge authority chain* is well captured. The competency gap (BP-01) is a vocabulary gap, not a reasoning gap — the reasoning vocabulary correctly models *what* the clinician knows and *how* they reason, regardless of whether the *credential* that authorises their reasoning is formally represented.

**Referral pathways** (Partial). Not exercised in reasoning instances. Remains a BMM-level vocabulary gap (ReferralNature typing needed).

**Conclusion:** WP-3 confirms the Partial assessments as accurate. The friction is real but none of the Partials require re-assessment to Gap. The Partial fields are workable with current vocabulary; the friction is at the level of pattern recognition (naming recurring combinations), not vocabulary inadequacy (missing concepts).

### 3.4 WP-4: Pattern Maturity Through Instance Work

**Prediction:** PatternCatalogue candidates might dissolve into ad hoc connections when populated with real content.

**Disposition: Patterns are stable — the HeuristicPack pattern is confirmed.** The HeuristicPack is the pattern most directly tested by instance work. It holds its shape: the pack is a coherent collection, the heuristics within it carry meaningful family typing (diagnostic, risk, coordination), the ordering logic captures real clinical reasoning, and the authority basis (KnowledgeSource) provides provenance. The pattern does not dissolve into ad hoc connections — it is a genuine structural motif.

The other PatternCatalogue candidates (BP-04 through BP-07, BP-09) were not directly exercised at instance level. Their stability will be tested when they are exercised in a second clinical domain (GSL).

**Conclusion:** WP-4 is satisfied for the patterns exercised. The HeuristicPack pattern is validated at instance level. Other pattern candidates await cross-domain testing.

---

## 4. Vocabulary Adequacy Assessment

The coverage map asked: *does the vocabulary cover the domain?* The instances asked: *does the vocabulary work with real content?* This section asks the design note's central question: *is the vocabulary adequate for clinical domain intake?*

### 4.1 BMM General Vocabulary (34 Concepts)

**Assessment: Adequate for structural skeleton — no Tailored extensions needed.**

All six BMM concerns are exercised. No new part defs are required. The 34 BMM General concepts provide the structural skeleton for a sector-regulated clinical domain at the same level of coverage they provide for a generally governed dog grooming service (Paws). This is the central validation of the [[concept-multi-tenancy|multi-tenancy principle (A13)]]: the meta model is domain-neutral at the structural level, and clinical specificity is expressed elsewhere.

The BMM's limits are known and categorised. Three vocabulary extension candidates (CompetencyAssessment, ReferralNature, PolicyDocument) represent genuine gaps in the BMM and governance vocabulary — concepts that the Ears domain needs and the vocabulary does not provide. Six PatternCatalogue candidates represent recurring combinations of existing concepts that should be named but do not require new vocabulary. The extension candidates are all trivial in architectural cost (add a sibling concept, add an enum, add a governance class) and none require structural redesign.

### 4.2 Reasoning Vocabulary (42 Classes)

**Assessment: Comprehensive for clinical reasoning — the architectural investment in Stage 7 is validated.**

This is the most significant finding of the Ears intake. The reasoning vocabulary achieves Full coverage for all 6 clinical reasoning fields in the coverage map (§3.4) and all 7 clinical risk and safety fields (§3.6). The reasoning instances exercise 25 of the 42 classes with concrete clinical content, and every exercised class accommodates its content without distortion.

Key validations:

**The three-way constraint hierarchy is the right abstraction.** HardConstraints for absolute contraindications, GradedRules for relative contraindications, and the architectural provision for SoftConstraints (not directly exercised in Ears but available for resource preferences) map precisely to clinical reasoning reality. The two-stage decision plan in the contraindication assessment (hard boundary check first, then graded assessment only if the hard boundary is not violated) validates the computational priority of HardConstraints — they can short-circuit the graded assessment entirely.

**The SEPIO evidence architecture works at clinical depth.** Claim → EvidenceLine → EvidenceItem chains capture the structure of clinical evidence naturally. The evidence structure for the contraindication check (two evidence lines — one for absolute contraindications, one for graded assessment — mirroring the two-stage decision plan) demonstrates that the SEPIO pattern does not merely catalogue evidence but reflects the *structure* of the reasoning it supports.

**STAMP/STPA structures fit clinical safety.** The canonical UnsafeControlAction ("irrigating a perforated eardrum" — ProvidedWhenNotNeeded) is a textbook STPA example. The structural identity between the SafetyConstraint ("never irrigate a perforated eardrum") and the HardConstraint in the contraindication check validates the design decision to make SafetyConstraint a subclass of HardConstraint — they are the same entity, not analogues.

**The 17 classes NOT exercised are explained.** Of the 42 classes, 17 are not instantiated. Of these, 7 are abstract parent classes (correctly not instantiated — subtypes are used), 4 are structured probabilistic types (BayesianUpdater, RiskCalculator, PrognosticModel, PredictiveAnalytics — not relevant to Ears because community ear care uses no validated probabilistic models), and 6 are heuristic subtypes or FRAM structures exercised less directly. The unexercised classes are not vocabulary waste — they serve domains with different reasoning profiles. Structured probabilistic types will be exercised by GSL (where risk calculators and prognostic models are part of clinical practice).

### 4.3 Governance Vocabulary

**Assessment: Comprehensive for regulatory compliance — governance–reasoning alignment is sound.**

The governance vocabulary achieves Full coverage for all 6 governance landscape fields in the coverage map (§3.5). The [[ontara-stage-5-plan-s.130-cqc-governance-mvp|CQC Regulation 12 MVP]] (Session 131) provides the precedent for governance instantiation. The governance–reasoning alignment (Obligation and Prohibition as HardConstraint subclasses) handles the critical intersection where governance obligations create reasoning obligations — the MCA capacity assessment is simultaneously a governance requirement and a clinical reasoning exercise, and the vocabulary accommodates this duality.

One vocabulary extension candidate is identified: PolicyDocument (BP-03). The 17 clinical policies in the Ears domain are governance artefacts that bridge obligations to operational practice, but the governance vocabulary does not currently have a first-class concept for them. This is a moderate-cost extension (new class in `ontara-gov:` with properties linking to Obligation and WorkProcess) with strong cross-domain validation (every demonstrator domain has policies of some kind).

### 4.4 OGMS Clinical Primitives

**Assessment: Adequate for clinical ontological typing.**

The OGMS layer provides the clinical categories (ClinicalEncounter, Symptom, Sign, ClinicalFinding, Diagnosis, TreatmentProcess, TreatmentOutcome) that sit between BFO and the domain vocabulary. This is the first time OGMS has been exercised with real domain content, and it works as expected — each clinical element in the Ears domain has a natural OGMS classification. OGMS does not need extension for Ears; its categories are well-established and well-aligned with BFO.

---

## 5. Cross-Domain Comparison with Paws

The Paws design note (Session 44) established the first vocabulary adequacy assessment. Comparing Paws and Ears reveals how the platform's vocabulary behaves under increasing domain complexity.

### 5.1 What Is Stable Across Domains

**The BMM General vocabulary is domain-neutral.** Neither Paws nor Ears requires Tailored part def extensions. The same 34 concepts describe a dog grooming salon and a CQC-registered clinical service. This is not a trivial finding — it validates the central architectural thesis that the business meta model can abstract across the regulatory spectrum.

**Coverage percentages are remarkably stable.** Paws: ~85% Full (estimated, pre-proforma). Ears: 86.2% Full. Despite Ears exercising two additional vocabulary stacks (reasoning and governance), the headline coverage is essentially the same. The explanation is that the additional clinical complexity is absorbed by the additional vocabulary layers — the reasoning and governance vocabularies handle the clinical specificity that would otherwise create gaps in the BMM. This is exactly what the dual-stack architecture (A4) was designed to achieve.

**Gaps are at the pattern level, not the vocabulary level.** Both domains find that the vocabulary *primitives* are right and that gaps appear as unrecognised *combinations* of existing concepts. Paws identified ServiceSubject, ConstrainableResource, and OverheadStructure as gaps. Ears identifies 6 PatternCatalogue candidates and 3 vocabulary extensions. The consistent pattern is: the primitives compose correctly; what is missing is the intermediate-level patterns that name recurring compositions.

### 5.2 What Ears Reveals That Paws Could Not

**The reasoning vocabulary works.** Paws has no clinical decision-making. Ears exercises the reasoning vocabulary across 5 clinical exercises and confirms that the three-way constraint hierarchy, the SEPIO evidence architecture, the HeuristicPack typing, and the Cynefin-mapped decision modes all find concrete clinical instantiation. This is the first validation of Stage 7's architectural investment against real domain content.

**The governance vocabulary scales.** Paws has 4 compliance items. Ears has 6 governance frameworks, 17 policies, 5 audit workstreams, and 17+ obligations. The governance vocabulary handles this density without structural strain. The governance–reasoning alignment (Obligations as HardConstraints) proves its worth at the MCA capacity assessment — the most architecturally significant reasoning exercise in the Ears intake.

**Setting-dependent modification is a real pattern.** Paws operates from a single location. Ears operates from a clinic and in domiciliary settings. The domiciliary pathway demonstrates that the same service in a different setting systematically modifies reasoning, safety, governance, and resources. This pattern (BP-09: Composite Setting Modifier) has strong cross-domain validation — Cafe, Suds, and Paws all have analogues (food truck, on-site laundry, home grooming visits).

**Communication as cross-cutting concern.** The vertical connection map's systematic mapping of 20 communication events (§6.8) reveals that patient communication distributes across all six BMM concerns — it is not a missing concern but a cross-cutting activity parallel to activity awareness (C6). This observation is new; Paws did not map communication systematically.

### 5.3 Convergent Conclusion

The most significant convergent finding: **the platform's vocabulary architecture — domain-neutral BMM, domain-specific reasoning and governance vocabularies, BFO/OGMS ontological grounding — is the right architecture for clinical domain intake.** The BMM provides the structural skeleton. The reasoning vocabulary provides the clinical decision logic. The governance vocabulary provides the regulatory framework. OGMS provides the clinical ontological typing. Each layer does what it was designed to do, and the layers compose without interference.

This is not guaranteed — there was a real possibility that the reasoning vocabulary, designed from abstract principles and non-clinical demonstrators (Cafe, Suds cross-domain validation during Stage 7), would encounter structural friction when applied to real clinical reasoning. It did not. The architecture is validated.

---

## 6. Meta-Constraints — A New Pattern

The reasoning instance population surfaced a pattern not predicted by the type-level coverage map: **meta-constraints** (E028, captured Session 166).

The MCA capacity assessment contains two HardConstraints that do not constrain the clinical domain — they constrain the *reasoning process itself*:

1. **Presumption of capacity** (MCA Principle 1): capacity must be assumed unless established otherwise. This constrains how the reasoning is *conducted* — the clinician must start from the assumption that the patient has capacity.
2. **Unwise decision ≠ lack of capacity** (MCA Principle 3): a person must not be treated as lacking capacity merely because they make a decision that others consider unwise. This constrains what *evidence* the reasoning may use — disagreement with the patient's decision is not evidence of incapacity.

These are not clinical constraints (they do not specify clinical outcomes) and not governance constraints in the usual sense (they do not specify compliance evidence). They are constraints on the *method* of reasoning — rules about how the reasoning process must be conducted, regardless of its content.

The HardConstraint class accommodates meta-constraints at the instance level. A meta-constraint is structurally identical to a domain constraint — it defines a NormativeRegion boundary that must not be crossed. The difference is in what it constrains: a domain constraint boundaries the clinical decision space; a meta-constraint boundaries the reasoning *methodology* space.

This is worth recognising for three reasons:

**It extends the constraint hierarchy's scope.** The three-way constraint hierarchy was designed to constrain domain reasoning (clinical decisions, procedure selection, safety). Meta-constraints demonstrate that the same hierarchy can constrain the *process* of reasoning, not just its *content*. This is a non-obvious extension that validates the hierarchy's generality.

**It has direct GSL relevance.** Gender-affirming healthcare reasoning is subject to multiple meta-constraints: the requirement for informed consent as a process (not just an outcome), the prohibition on making assumptions about a patient's gender identity based on appearance, the requirement to offer psychosocial support alongside medical treatment. These are all constraints on how clinical reasoning is conducted, not on what conclusions it reaches.

**It suggests a potential vocabulary extension.** A future meta model evolution could distinguish `DomainConstraint` (constraints on the decision space) from `MethodConstraint` (constraints on the reasoning process). This is not urgent — the HardConstraint class handles both at instance level — but it would make the distinction explicit in the vocabulary rather than relying on the `rdfs:comment` to convey it.

---

## 7. Branching-Point Disposition

The coverage map identified 9 branching points (BP-01 through BP-09). The reasoning instance work and this design note's analysis inform their disposition. The recommendation for each is grounded in cross-domain evidence and architectural cost.

### 7.1 Vocabulary Extension Candidates (Build)

| BP | Concept | Recommendation | Timing | Cross-Domain Evidence |
|---|---|---|---|---|
| BP-01 | CompetencyAssessment | **BMM General extension** — new concept as sibling of Qualification. Attributes: assessor, date, threshold, expiry, outcome | Post-Ears intake; schedule when a second domain (likely Suds COSHH training) confirms the pattern | Ears (strong), Suds (likely), GSL (strong — clinical competency assessments are a core governance mechanism) |
| BP-02 | ReferralNature typing | **Evaluate General vs Tailored** — new enum on ReferralPathway. Candidate values: Signposting, ClinicalCommunication, ClinicalEscalation, FormalReferral | Early GSL intake, when the full referral taxonomy is exercised | Ears (strong), GSL (strong — GP referral, endocrinology referral, psychology referral are structurally different), Paws (weak) |
| BP-03 | PolicyDocument | **Governance vocabulary extension** — new class in `ontara-gov:` linking Obligation → PolicyDocument → WorkProcess | Can be done standalone; relatively self-contained | Ears (strong — 17 policies), Cafe (present), Suds (present), Paws (present — weaker) |

### 7.2 PatternCatalogue Candidates (Document)

| BP | Pattern | Recommendation | Timing |
|---|---|---|---|
| BP-04 | External Governance Advisor | Document as PatternCatalogue candidate. Await GSL (clinical advisory committee) for second clinical domain validation | Post-GSL characterisation |
| BP-05 | Commissioning Arrangement | Document as PatternCatalogue candidate. Low priority — Ears commissioning is a future development | Deferred |
| BP-06 | Setting-Dependent Obligation Escalation | Document as PatternCatalogue entry. Cross-domain validated (Cafe, Suds, Paws all have setting-dependent obligations) | Can be done standalone |
| BP-07 | Governed Communication of Reasoning Outputs | Document as PatternCatalogue entry. Most significant in clinical contexts but present in lighter form elsewhere | Post-reasoning instance population in a second domain |
| BP-09 | Composite Setting Modifier | Document as PatternCatalogue entry. Strong cross-domain validation. The most architecturally interesting gap | Can be done standalone |

### 7.3 Platform Capability (Defer)

| BP | Concept | Recommendation | Timing |
|---|---|---|---|
| BP-08 | Feature Taxonomy Representation | Defer until multiple domains have been characterised through the intake framework. The feature taxonomy needs at least 3–4 domain characterisations before the dimension and value spaces are stable enough to formalise | Post-intake framework maturation |

### 7.4 Disposition Summary

Of 9 branching points: 3 are vocabulary extension candidates (build when cross-domain evidence is sufficient), 5 are PatternCatalogue candidates (document when opportunity arises), and 1 is a deferred platform capability. None require structural redesign. The platform's vocabulary primitives are right; what evolves with each domain intake is the library of patterns and the occasional new concept that names something the primitives could express only by composition.

---

## 8. Implications for the Platform

### 8.1 The Three-Document Intake Pattern Is Validated

The Ears intake establishes that the three-document pattern (domain description → vertical connection map + coverage map → design note) works for clinical domain intake. The pattern is more demanding than the Paws precedent — it requires six vocabulary layers instead of four, a formal proforma-based coverage methodology, and reasoning instance testing — but it produces a comprehensive adequacy assessment that the next phase of work can rely on.

The Clinical Domain Intake Framework (Session 160) is confirmed as a reusable methodology. When GSL intake begins, the framework provides the structure; the Ears intake provides the precedent and comparison baseline.

### 8.2 The Ontology Stack Is Ready for Expansion

The 12-file ontology stack is architecturally sound. The reasoning instances file (`ears-reasoning-instances.ttl`) would bring it to 13 files once loaded into GraphDB and validated by HermiT. The stack's layered structure (BFO → CCO/IAO → PROV-O → BMM ontology → governance vocabulary → domain vocabulary → reasoning vocabulary → domain instances) accommodates clinical content without modification.

The next ontology stack action should be the HermiT consistency check on the 13-file stack — this is a Code task that validates OWL 2 DL consistency of the reasoning instances against the vocabulary.

### 8.3 The Console Can Be Extended

The Reasoning Vocabulary Explorer (Session 158) currently shows the 42 reasoning classes and their properties. With reasoning instances now available, the deferred P4-2 (evidence browser) and P4-3 (decision trace) console features are unblocked. These would allow a user to browse the Ears clinical reasoning exercises — navigating from a ReasoningContext through its Claims, EvidenceLines, and Decisions with full provenance.

### 8.4 The PatternCatalogue Should Grow

The Ears intake identifies 5 PatternCatalogue candidates (BP-04 through BP-07, BP-09) plus the meta-constraint observation (E028). The PatternCatalogue currently has 22 validated patterns; these candidates would bring it to 27–28 if validated. The dominant gap type across both Paws and Ears is patterns, not primitives — suggesting that the vocabulary has reached a maturity level where growth is primarily in recognised compositions rather than new base concepts.

---

## 9. Implications for GSL

Ears was deliberately chosen as the Ontara platform's first clinical domain intake because it exercises clinical reasoning, governance, and OGMS at a manageable scale before GSL. The design note identifies several specific implications for GSL intake:

**The reasoning vocabulary will be heavily exercised.** GSL clinical reasoning includes hormone initiation protocols (where BayesianUpdater and RiskCalculator types would be exercised), diagnostic assessment (where the full evidence architecture is load-bearing), and informed consent processes with legal and ethical complexity exceeding even the MCA capacity assessment. The 4 structured probabilistic types unexercised by Ears will find their first domain exercise in GSL.

**Meta-constraints will be more numerous.** The meta-constraint pattern (E028) was discovered in Ears through the MCA statutory principles. GSL clinical reasoning is subject to additional meta-constraints: the requirement for a holistic assessment before any medical intervention, the prohibition on "gatekeeping" (making access conditional on arbitrary criteria), the requirement to respect self-declared gender identity. These are all constraints on the reasoning *method*, not the reasoning *content*, and they validate the meta-constraint pattern's generality.

**Governance density will increase further.** Ears operates under 6 governance frameworks. GSL will operate under additional frameworks: GMC guidance, NHS England service specifications, the Equality Act 2010, the GRA 2004 (for legal recognition matters), and WPATH/Endocrine Society clinical guidelines. The governance vocabulary should be tested against this density before [[domain-gendersense|GSL]] intake begins.

**Referral pathway typing will be immediately relevant.** The referral taxonomy in GSL is complex: GP → gender service (formal NHS referral), gender service → endocrinology (clinical handover), gender service → surgery (complex referral with multiple gatekeeping requirements), gender service → psychology/mental health (bidirectional). BP-02 (ReferralNature typing) should be resolved before GSL intake.

---

## 10. Design Decisions

### S167-D1: The Ontara vocabulary is adequate for clinical domain intake

The Ears intake demonstrates that the platform's vocabulary architecture — domain-neutral BMM, clinical reasoning vocabulary, deontic governance vocabulary, BFO/OGMS ontological grounding — is adequate for sector-regulated clinical domain intake. Adequacy is established at both type level (coverage map: 86.2% Full, 0 structural gaps) and instance level (reasoning instances: 25/42 classes exercised with no semantic friction). The vocabulary architecture does not need restructuring for clinical domains.

### S167-D2: The three-way constraint hierarchy is the right abstraction for clinical reasoning

HardConstraints for absolute contraindications, GradedRules for relative contraindications, and SoftConstraints for resource preferences — this hierarchy maps precisely to the structure of clinical decision-making. Validated at type level (coverage map §3.4) and instance level (contraindication check with 7 HardConstraints and 4 GradedRules). This is the strongest single vocabulary validation in the project.

### S167-D3: Meta-constraints are a recognised pattern, not a vocabulary extension (yet)

Meta-constraints (E028) — constraints on the reasoning process itself, discovered in the MCA capacity assessment — are accommodated by the HardConstraint class at instance level. The pattern should be documented and tracked, but a formal vocabulary distinction (DomainConstraint vs MethodConstraint) is not yet justified. Revisit when GSL intake surfaces additional meta-constraints, confirming the pattern's generality.

### S167-D4: BMM→reasoning cross-vocabulary relations are an identified future work area

The governance→reasoning relation is formally expressed through PROV-O provenance and the Obligation/HardConstraint subclass hierarchy. The BMM→reasoning relation (which ServiceOffering triggers which ReasoningContext) is currently analytical, not formal. This should be formalised when cross-vocabulary queries become a console requirement. Not urgent; current architecture is workable.

### S167-D5: The three-document intake pattern is validated for clinical domains

Domain description → vertical connection map + coverage map → design note is confirmed as the standard clinical domain intake methodology. The Clinical Domain Intake Framework (Session 160) is a reusable platform capability. The Ears intake provides the precedent and comparison baseline for GSL.

---

## 11. Register Connections

| Concept | Relationship to This Work |
|---|---|
| [[principle-self-describing-system\|A2]] | The design note is the platform describing the adequacy of its own vocabulary — self-knowledge about representational fitness, not just reach |
| [[principle-model-generates-everything\|A3]] | Vocabulary adequacy determines what the model can generate. 86.2% Full coverage → 86.2% of domain features directly generatable |
| [[principle-two-meta-model-distinction\|A4]] | BMM (structural skeleton) and SMM vocabularies (reasoning, governance) confirmed as distinct, composable layers. Clinical specificity lives in the SMM layers, not in BMM extensions |
| [[concept-cross-domain-validation\|A5]] | Ears validates clinical patterns; comparison with Paws confirms BMM General stability across regulatory tiers |
| [[principle-deterministic-over-probabilistic\|A6]] | Clinical reasoning follows inspectable paths. Meta-constraints (MCA principles) validate A6's reformulated four-category scheme — these are authoritative constraints that use deterministic, auditable reasoning |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Systematic intake methodology: proforma-based coverage, embedded watchpoints, structured critique. The discipline of the methodology gives confidence in the conclusions |
| [[principle-intrinsic-self-knowledge\|A10]] | Vocabulary adequacy is intrinsic self-knowledge: the platform knows not just what it can model but how well it models it |
| [[principle-unity-principle\|A11]] | The same constraint hierarchy (Hard/Graded/Soft) serves reasoning, governance, safety, and now meta-constraints. The unity principle is validated at instance level |
| [[concept-coordinate-framework\|A12]] | Contraindication constraints exercise coordinate-framework geometry with real clinical parameters. Meta-constraints exercise it at the reasoning-methodology level |
| [[concept-multi-tenancy\|A13]] | Ears as tenant instantiation uses exclusively BMM General vocabulary — no Tailored extensions. Meta model generality confirmed across the regulatory spectrum |
| [[concept-co-evolution\|J2]] | The intake reveals tooling needs: evidence browser (P4-2), decision trace (P4-3), cross-vocabulary query capability |
| [[concept-non-constraining\|J3]] | All gaps are extension points. No structural redesign needed. Future directions not foreclosed |
| [[concept-two-phase-construction\|Two-Phase Construction]] | Coverage map passes the Phase 1 completeness test; instance work validates that Phase 1 classifications hold at instance level |
| B15 ([[concept-domain-identity\|Domain identity]]) | Domain identity fields achieve Full coverage |
| B29 ([[concept-authority-zones\|Authority zones]]) | Governance and reasoning vocabularies are OWL-authoritative; the instances file respects this boundary |
| B30–B35 | Governance vocabulary achieves Full coverage (6/6) and handles the governance–reasoning intersection at the MCA capacity assessment |
| P1–P7 | Reasoning vocabulary achieves Full coverage (6/6 clinical reasoning, 7/7 safety) and holds at instance level with 25/42 classes exercised |
| E028 | Meta-constraints discovered during capacity assessment instance work; documented as a new pattern with GSL implications |

---

## 12. Critique Observations and Watchpoints

Per the Workflow Guide §1 commitment 5 and §2.2.

### 12.1 Qualifying Observations

**CQ-1: The adequacy assessment is bounded by one clinical domain.** The design note concludes that the vocabulary is "adequate for clinical domain intake." This conclusion is based on a single clinical domain (Ears) at a specific point on the complexity spectrum (community ear care — procedural, moderate governance density, no chronic conditions, no probabilistic risk modelling). GSL will test vocabulary adequacy at significantly higher complexity: compound pathways, structured probabilistic reasoning, heavier governance, chronic conditions, psychosocial dimensions. The Ears conclusion should be read as "adequate for clinical domains at Ears-level complexity and below" rather than "adequate for all clinical domains."

**CQ-2: Instance coverage is partial.** The reasoning instances exercise 25 of 42 classes (59.5%). The unexercised classes include all 4 structured probabilistic types, 3 FRAM-specific types, and several heuristic subtypes. The design note explains each gap, but the fact remains that 40% of the reasoning vocabulary has not been tested at instance level. The vocabulary's fitness for structured probabilistic reasoning (GSL's primary extension case) is asserted by architectural argument, not demonstrated by instance evidence.

**CQ-3: The design note does not assess runtime adequacy.** The adequacy assessment covers representational fitness (can the vocabulary *express* the domain?) but not computational fitness (can a reasoning engine *process* the instances to produce useful outputs?). The instances are exemplars, not production data. Whether the HardConstraint/GradedRule distinction produces useful computational behaviour (e.g. a constraint checker that correctly rejects contraindicated procedures) is an execution-layer question that this intake does not test. Runtime adequacy is out of scope for the intake framework — but it is the eventual test that matters.

### 12.2 Watchpoints for Downstream Work

**WP-5: Structured probabilistic types under GSL testing.** *Applies to: GSL clinical domain intake.* The 4 structured probabilistic types (BayesianUpdater, RiskCalculator, PrognosticModel, PredictiveAnalytics) are not exercised by Ears. GSL will be the first domain to test these types with real clinical content (e.g. cardiovascular risk assessment for hormone therapy, bone density monitoring). Verify that the class definitions accommodate real clinical probabilistic reasoning without distortion.

**WP-6: Meta-constraint generality across clinical domains.** *Applies to: GSL clinical domain intake.* The meta-constraint pattern (E028) is observed in one domain (Ears, through MCA principles). GSL is predicted to surface additional meta-constraints (holistic assessment requirement, anti-gatekeeping principle, gender identity self-declaration respect). Verify that (a) the meta-constraint pattern recurs and (b) the HardConstraint class continues to accommodate meta-constraints at instance level, or whether a formal vocabulary distinction becomes necessary.

**WP-7: BMM→reasoning formalisation threshold.** *Applies to: console cross-vocabulary features.* The BMM→reasoning cross-vocabulary relation is currently analytical. Monitor whether console development (evidence browser, decision trace, or future cross-vocabulary query features) reaches a point where formal OWL object properties connecting BMM classes to reasoning classes become necessary. The threshold is: if building a console feature requires ad hoc code to traverse the BMM→reasoning boundary, the formal relation vocabulary is overdue.

---

*Ears Design Note — Ontara Session 167 Working Document. Synthesis of the Ears clinical domain intake: coverage map findings, reasoning instance experience, cross-domain comparison with Paws, and vocabulary adequacy assessment. Completes the three-document intake pattern for the first clinical domain.*
