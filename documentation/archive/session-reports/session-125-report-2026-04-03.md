# Session 125 Report — Deontic Governance OWL Class Design (S121-Q3)

**Date:** 3 April 2026 (Session 125)
**Type:** Architecture + Design (Chat)
**Plan:** Prep note priority 1 — S121-Q3 (OWL class design for the deontic vocabulary)

---

## Contents

- [[#1. Summary|§1. Summary]]
- [[#2. Design Process|§2. Design Process]]
- [[#3. Design Outcome|§3. Design Outcome]]
- [[#4. Design Decisions|§4. Design Decisions]]
- [[#5. Register Concepts Exercised|§5. Register Concepts Exercised]]
- [[#6. Emergent Ideas|§6. Emergent Ideas]]
- [[#7. Tier 1 Principles Honoured|§7. Tier 1 Principles Honoured]]
- [[#8. Open Items and Deferred Work|§8. Open Items and Deferred Work]]

---

## 1. Summary

Session 125 resolved S121-Q3 — the OWL 2 DL class design for the deontic governance vocabulary described in §5–§7 of the [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture paper (Session 121)]]. The session produced a comprehensive design paper ([[ontara-discussion-deontic-owl-class-design-2026-04-03|Deontic Governance Vocabulary: OWL Class Design]]) containing the complete class hierarchy, object properties, data properties, enumeration classes, axioms, and a full Turtle specification ready for authoring and validation.

**Deliverables:**
- [[ontara-discussion-deontic-owl-class-design-2026-04-03|OWL class design discussion paper]] — 13 sections, complete Turtle specification in §10
- S121-Q3 resolved
- Seven design decisions (S125-D1 to S125-D7)
- One new concept proposed for registration (B35)

## 2. Design Process

The session began with a thorough reading of source material: the full [[ontara-discussion-deontic-governance-architecture-2026-04-03|deontic governance paper]] (all 17 sections), the existing [[ontara-ref-master-register|BMM ontology]] (`ontara-bmm.ttl`, 34 classes), the hand-authored axioms file (`ontara-bmm-axioms.ttl`), the pipeline-generated properties file (`ontara-bmm-properties.ttl`), and the declarative mapping rules (`mapping-rules.yaml`). The IAO ontology was consulted to confirm the exact IRI for `directive_information_entity` (`IAO_0000033`) and `document` (`IAO_0000310`). The relationship between the existing `GovernanceRequirement` (mapped to `IAO_0000005`, objective specification) and the new `DeonticDirective` was carefully analysed.

Five scoping and design questions were presented to Ella and all five confirmed:

1. **Scope:** Vocabulary and structural properties only; activation/operational tiers deferred.
2. **GovernanceRequirement relationship:** Siblings under IAO, not a subclass relationship.
3. **Class hierarchy:** As proposed — 19 classes.
4. **Data vs object properties:** Pragmatic `xsd:string` for textual structural properties, promotable later.
5. **Normative instrument granularity:** All eleven subtypes as proposed from the governance paper's §6.1 taxonomy.

## 3. Design Outcome

### 3.1 Metrics

| Metric | Count |
|---|---|
| Classes | 19 (4 deontic directive types + root + 11 normative instrument types + root + obligation group + governance framework) |
| Enumeration classes | 6 (ContentModality, TemporalScopeType, SanctionSeverity, AuthorityType, EndorsementStatus, CurrencyStatus) |
| Named individuals | 24 (enum members across the 6 enumerations) |
| Object properties | 20 |
| Data properties | 16 |
| Disjointness axiom groups | 3 (deontic modalities, instrument types, top-level classes) |
| Covering axioms | 2 (DeonticDirective, NormativeInstrument) |
| Existential restrictions | 1 (every directive derives from ≥1 instrument) |
| Cardinality restrictions | 5 |

### 3.2 IRI namespace

A separate namespace `https://ontara.dev/ontology/governance/` (`ontara-gov:`) was chosen, with properties under `https://ontara.dev/ontology/governance/axioms#` (`ontara-gov-ax:`). This is a distinct ontology module from the BMM, living in the same [[concept-three-stratum-knowledge-graph|domain graph (B28)]].

### 3.3 BFO/IAO grounding

| Class | BFO/IAO parent |
|---|---|
| `DeonticDirective` (+ 4 subtypes) | `IAO_0000033` (directive information entity) |
| `NormativeInstrument` (+ 11 subtypes) | `IAO_0000310` (document) |
| `ObligationGroup` | `IAO_0000030` (information content entity) |
| `GovernanceFramework` | `IAO_0000030` (information content entity) |

### 3.4 Key structural features

- **Covering axioms** assert that `DeonticDirective` and `NormativeInstrument` are exactly the union of their respective subtypes — closed partitions, consistent with the BMM concern group pattern in [[ontara-ref-master-register|ontara-bmm-axioms.ttl]].
- **Defeasibility** is modelled via explicit `hasException` object property relationships between directives, preserving OWL 2 DL monotonicity (S121-D4).
- **Composition patterns** — composite obligations (`hasComponentDirective`), alternative satisfaction (`hasAlternativeSatisfaction`), and cascading obligations (`triggersObligation`) — are modelled as object properties between `DeonticDirective` instances.
- **Instrument relationships** — `supersedesInstrument`, `implementsInstrument`, `interpretsInstrument`, `crossReferencesInstrument` (symmetric) — capture the inter-instrument dependency structure from §6.3 of the governance paper.

### 3.5 Implementation note

The Turtle specification in §10 of the [[ontara-discussion-deontic-owl-class-design-2026-04-03|design paper]] is complete and loadable. One structural point noted: `DeonticDirective` carries both `rdfs:subClassOf bfo:IAO_0000033` and an `owl:equivalentClass` covering axiom. Both are valid simultaneously in OWL 2 DL — the equivalentClass concerns the four subtypes exhausting the space, while the subClassOf asserts the IAO parent. HermiT should pass clean, but the Protégé rendering may look unusual.

## 4. Design Decisions

| ID | Decision | Rationale |
|---|---|---|
| S125-D1 | Separate IRI namespace `ontara-gov:` for governance vocabulary | Distinct conceptual domain from the BMM. Separate ontology module, same domain graph stratum. |
| S125-D2 | `DeonticDirective` subclass of `IAO_0000033` | Donohue (2017); S121-D1 confirmed. |
| S125-D3 | `NormativeInstrument` subclass of `IAO_0000310` (document) | Source documents are IAO documents, not directives. |
| S125-D4 | `GovernanceRequirement` and `DeonticDirective` remain siblings | Different abstraction levels; connected via future [[ontara-ref-master-register|binding mechanism (B32)]]. |
| S125-D5 | Structural properties as `xsd:string` data properties | Pragmatic first iteration; promotable without refactoring ([[concept-non-constraining\|J3]]). |
| S125-D6 | Covering axioms for `DeonticDirective` and `NormativeInstrument` | Both taxonomies are intentionally closed sets from deontic logic and regulatory analysis. |
| S125-D7 | Hand-authored ontology, OWL-authoritative | No SysML source. Follows `ontara-bmm-axioms.ttl` pattern. [[concept-authority-zones\|B29]] applies. |

## 5. Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[principle-model-generates-everything\|A3]] | OWL is part of the canonical representation |
| [[principle-two-meta-model-distinction\|A4]] | Governance vocabulary spans both stacks per S121-Q1 |
| [[principle-deterministic-over-probabilistic\|A6]] | Deontic vocabulary supports inspectable compliance logic |
| [[concept-non-constraining\|J3]] | Data properties as `xsd:string` — promotable; covering axioms make extension deliberate |
| [[concept-knowledge-graph\|B22]] | Governance vocabulary lives in the KG domain stratum |
| [[concept-bfo-ontological-grounding\|B23]] | All classes grounded in BFO via IAO |
| [[concept-three-stratum-knowledge-graph\|B28]] | Domain graph placement |
| [[concept-authority-zones\|B29]] | OWL-authoritative for class definitions and axioms |
| [[ontara-ref-master-register\|B30]] | Deontic directive vocabulary — this design specifies it |
| [[ontara-ref-master-register\|B31]] | Governance framework library — GovernanceFramework class defined |
| [[ontara-ref-master-register\|B33]] | Normative instrument taxonomy — 11 types with complete partition |

## 6. Emergent Ideas

No new emergent ideas this session.

## 7. Tier 1 Principles Honoured

| Principle | How honoured |
|---|---|
| A3 (model generates everything) | OWL extends the canonical representation with governance vocabulary |
| A4 (two meta model distinction) | Design respects BMM/SMM split per S121-Q1 resolution |
| A6 (deterministic/auditable reasoning) | Deontic vocabulary designed for OWL 2 DL reasoning — inspectable, monotonic |
| A9 (discipline as load-bearing structure) | Design paper follows established patterns from Stage 5; Turtle specification is directly implementable |
| A10 (intrinsic self-knowledge) | Labels, comments, and SKOS definitions on all classes |
| A11 (unity principle) | Governance vocabulary participates in the same knowledge graph as BMM ontology |
| J2 (co-evolution) | Design paper produced; implementation is the next step (co-evolution of model and tooling) |
| J3 (non-constraining) | String data properties promotable; covering axioms make extension deliberate, not foreclosed |

## 8. Open Items and Deferred Work

### 8.1 Remaining S121 open questions

| ID | Status |
|---|---|
| S121-Q1 | Resolved Session 124 |
| S121-Q2 | Open — obligation decomposition granularity heuristics |
| S121-Q3 | **Resolved this session** |
| S121-Q4 | Open — legislative cross-reference handling in ingestion pipeline |
| S121-Q5 | Open — MVP implementation plan (next priority) |
| S121-Q6 | Open — Ears demonstrator relationship |
| S121-Q7 | Open — E011 relationship |

### 8.2 Immediate next steps

1. **Author the Turtle file** from the §10 specification and validate (Protégé, GraphDB, Robot + HermiT). Could be a half-session task.
2. **S121-Q5 — MVP implementation plan.** Now that the OWL class design is settled, plan a phased implementation starting with CQC as the first governance framework. Consider combining with the [[domain-ears|Ears]] demonstrator (S121-Q6).
3. **B35 registration** — governance ontology module concept.

### 8.3 Continuing deferred items from prep note

- **F2 — Vision and Architecture Reference refresh.** Now 16+ sessions stale. Growing priority.
- **F12 — Workflow guide §6.2 old folder names.** Quick fix.
- **Console data source currency check.** Due ~Session 128.

---
