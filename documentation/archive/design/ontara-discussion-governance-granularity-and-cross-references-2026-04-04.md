---
tags:
  - discussion-paper
  - governance
  - ontology
date: 2026-04-04
status: current
session: 132
---
# Decomposition Granularity and Legislative Cross-References in Governance Ontology

**Session:** 132
**Date:** 4 April 2026
**Status:** Discussion paper
**Resolves:** S121-Q2 (W-013), S121-Q4 (W-014)
**Depends on:** [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture]] (Session 121), [[ontara-discussion-deontic-owl-class-design-2026-04-03|OWL Class Design]] (Session 125), [[session-130-stage5-cqc-governance-mvp-plan|CQC Governance MVP Plan]] (Session 130)

---

## Contents

- [[#1. Purpose|§1. Purpose]]
- [[#2. Empirical Basis — What the MVP Taught Us|§2. Empirical Basis]]
- [[#3. Decomposition Granularity (S121-Q2)|§3. Decomposition Granularity]]
- [[#4. Legislative Cross-References (S121-Q4)|§4. Legislative Cross-References]]
- [[#5. Interaction Between the Two Questions|§5. Interaction]]
- [[#6. Vocabulary Extensions Required|§6. Vocabulary Extensions]]
- [[#7. Design Decisions|§7. Design Decisions]]
- [[#8. Open Questions|§8. Open Questions]]
- [[#9. Register Connections|§9. Register Connections]]

---

## 1. Purpose

Session 121 raised two open questions about the governance ontology that could not be answered without practical experience of formalising real regulatory content:

- **S121-Q2 (W-013):** How granular should obligation decomposition be? Too fine-grained and the framework becomes unmanageable; too coarse and compliance checking is imprecise.
- **S121-Q4 (W-014):** How does the governance ontology handle legislative cross-references? A statute may say "subject to section X" — the ontology must represent and resolve these references.

The CQC Governance MVP (Sessions 130–131), which formalised CQC Regulation 12 (Safe Care and Treatment) as 21 production-quality OWL individuals, now provides concrete empirical data to address both questions. This paper analyses the MVP's decomposition structure and the cross-reference patterns encountered, proposes heuristics and vocabulary extensions, and identifies the remaining design space.

---

## 2. Empirical Basis — What the MVP Taught Us

### 2.1 The Regulation 12 decomposition structure

The MVP formalised Regulation 12 at three tiers of granularity:

| Tier | Source | Count | Example |
|---|---|---|---|
| **Parent obligation** | Reg 12(1) statutory text | 1 | `reg12-1-safe-care` — "Care and treatment must be provided in a safe way" |
| **Sub-obligations** | Reg 12(2)(a)–(i) statutory text | 9 | `reg12-2a-risk-assessment` — "Assessing the risks to the health and safety of service users" |
| **Guidance directives** | CQC Guidance for Providers | 5 | `guidance-risk-assessment-methodology` — Validated tools, person-centred, proportionate |

This produced a **1 → 9 → 5** tree (15 directives total, plus 1 permission, 4 normative instruments, 1 group, 1 framework = 21 individuals).

### 2.2 Key structural observations

**What worked well:**

1. **Statutory sub-clause decomposition is natural.** Regulation 12(2)(a)–(i) provides an author-given decomposition that maps directly to individual OWL individuals. Each sub-clause has distinct evidential requirements and can be independently assessed.

2. **Guidance-level directives add operational specificity.** The statutory text says "assessing the risks" — the CQC guidance says *how* (validated tools, person-centred, proportionate). This two-tier pattern (statute → guidance) recurs across regulatory regimes.

3. **GSL-specific guidance directives emerged naturally.** Two of the five guidance directives (`guidance-staff-competence-gender-identity`, `guidance-medicines-management-gender-affirming`) are sector-specific applications of general CQC guidance. This validates the [[concept-multi-tenancy|multi-tenancy principle (A13)]]: the framework library holds general obligations, while tenant-specific refinements extend them.

4. **`hasComponentDirective` provided the right structural link.** Parent → sub-obligation and statutory-obligation → guidance-directive both used the same property, keeping the model simple.

**What was difficult or ambiguous:**

1. **Where to stop decomposing.** CQC guidance on risk assessment could be further decomposed: "use validated tools" is one obligation, "involve the service user" is another, "consider links between IPC and medicines" is a third. We chose to keep these as a single guidance directive with compound `directiveContent`. This was a judgement call.

2. **The `evidentialSpecification` strings do significant implicit decomposition.** For `reg12-2c-staff-competence`, the evidential spec lists seven distinct evidence types (training records, registration checks, supervision records, etc.). Each of these *could* be a separate directive with its own freshness requirement. We chose not to decompose to that level.

3. **Cross-regulation dependencies surfaced but were not formalised.** Regulation 12(2)(h) (infection control) references the HSCA 2008 Code of Practice on the Prevention and Control of Infections — a separate normative instrument with its own 10 criteria. We noted this in the `applicabilityCondition` string but did not model the cross-reference structurally.

### 2.3 Individual counts at different granularity levels

To make the granularity question concrete, here is what the full CQC Fundamental Standards (Regulations 9–20) might look like at different decomposition depths:

| Decomposition level | Estimated individuals per regulation | × 12 regulations | Notes |
|---|---|---|---|
| Parent obligation only | ~1 | ~12 | Too coarse — no actionable compliance checking |
| Statutory sub-clauses | ~8–15 | ~100–180 | The MVP level. Actionable, manageable |
| + CQC guidance layer | ~12–25 | ~150–300 | Adds operational specificity |
| + Evidential decomposition | ~30–80 | ~360–960 | Each evidence type becomes a directive |
| + Operational procedure | ~50–200+ | ~600–2400+ | Individual checklist items, policy requirements |

---

## 3. Decomposition Granularity (S121-Q2)

### 3.1 The granularity principle

The right level of decomposition is determined by asking: **at what level can compliance be independently assessed?**

An obligation should be decomposed into sub-directives when:

1. **Independent assessment.** The sub-components can be independently compliant or non-compliant. If "premises are safe" and "equipment is safe" can have different compliance states, they should be separate directives (as they are — Reg 12(2)(d) and (e)).

2. **Distinct evidence.** The sub-components require fundamentally different evidence types. "Staff training records" and "premises safety certificates" are different evidence domains.

3. **Different freshness cadences.** If one component needs quarterly review and another needs annual review, they benefit from separate `freshnessRequirement` values.

4. **Distinct sanction exposure.** If failure of one sub-component carries different regulatory consequences than failure of another.

An obligation should **not** be further decomposed when:

1. **The sub-components are assessed holistically.** CQC inspectors assess risk assessment methodology as a single practice, not as separate "use validated tools" and "involve the service user" items.

2. **Decomposition produces items that cannot fail independently.** If you can't have good risk assessment tools but poor service user involvement *within the same risk assessment*, the components are not independently assessable.

3. **The decomposition is operational rather than normative.** "Check the fridge temperature" is an operational procedure, not a governance obligation. The obligation is "manage medicines properly" — the fridge check is evidence of compliance.

### 3.2 Recommended decomposition heuristic

Based on the MVP experience, we propose a **three-tier standard decomposition**:

| Tier | Name | Source | Modelled as | Purpose |
|---|---|---|---|---|
| **T1** | Statutory obligation | Legislative text (regulation, section, sub-section) | `Obligation` with `derivesFrom` → instrument | Legal anchor. What the law requires. |
| **T2** | Guidance directive | Regulator guidance, codes of practice, professional standards | `Obligation` or `Permission` with `derivesFrom` → guidance instrument | Operational interpretation. What good practice looks like. |
| **T3** | Evidential specification | Domain expertise, inspection criteria | `evidentialSpecification` data property (string) | Assessment criteria. What an inspector looks for. |

**The boundary rule:** T1 and T2 are modelled as OWL individuals (separate directives). T3 stays as structured text within the `evidentialSpecification` data property on T1 or T2 directives. This is the level the MVP implemented and it worked well.

**Promotion criterion:** A T3 evidential item should be promoted to a T2 directive if and only if it satisfies at least two of the four decomposition conditions in §3.1 (independent assessment, distinct evidence, different freshness, distinct sanction). This is a deliberate design act requiring domain expertise.

### 3.3 The multi-tenancy dimension

The MVP revealed that tenant-specific guidance directives (e.g., `guidance-staff-competence-gender-identity`) are a natural T2-level extension. This suggests a decomposition pattern:

```
Platform-level framework (e.g., CQC Fundamental Standards)
  └── Statutory obligations (T1) — regime-universal
       └── General guidance directives (T2a) — regime-universal
       └── Sector-specific guidance directives (T2b) — tenant-appropriate
            └── Evidential specs (T3) — operational, textual
```

The `T2b` layer is where multi-tenancy meets governance decomposition. Different tenants activating the same framework might have different T2b directives depending on their regulated activities, service types, and clinical specialisms. This aligns with the three-tier architecture from the [[ontara-discussion-deontic-governance-architecture-2026-04-03|governance architecture paper]]: the library holds T1 + T2a; activation binds them to a tenant; T2b directives may be authored at the tenant level.

### 3.4 Scale implications

At the recommended three-tier level (T1 + T2), a full CQC Fundamental Standards framework would contain approximately 150–300 directive individuals. This is:

- **Manageable for hand-authoring** if done regulation-by-regulation (the MVP approach). The MVP took one session to produce 15 directives for one regulation; 12 regulations would take approximately 10–12 sessions at similar density.
- **Within GraphDB capacity** — trivially so. The current 10-file ontology stack has ~500 triples; adding 300 directives with ~10 triples each would add ~3,000 triples.
- **Queryable via SPARQL** — the 7 Governance-MVP queries already demonstrate structural, provenance, and completeness queries. These patterns extend to multi-regulation scope.
- **Amenable to future tooling.** E022 (governance editing tooling) becomes important at this scale — hand-editing Turtle files for 300+ individuals is error-prone.

---

## 4. Legislative Cross-References (S121-Q4)

### 4.1 Cross-reference patterns encountered in the MVP

The MVP encountered several categories of cross-reference, ordered by structural complexity:

#### Pattern 1: Vertical hierarchy — instrument implements instrument

Already modelled. The Regulations 2014 `implementsInstrument` the HSCA 2008. CQC guidance `interpretsInstrument` the Regulations 2014. This is a provenance chain, not a lateral cross-reference.

```turtle
ontara-gov:regulated-activities-regs-2014
    ontara-gov-ax:implementsInstrument ontara-gov:hsca-2008 .

ontara-gov:cqc-guidance-for-providers
    ontara-gov-ax:interpretsInstrument ontara-gov:regulated-activities-regs-2014 .
```

**Status:** Fully modelled in the MVP. No changes needed.

#### Pattern 2: Intra-regulation cross-reference — regulation refers to another regulation within the same instrument

The Regulations 2014 contain extensive internal cross-references. Examples relevant to Regulation 12:

- **Regulation 22 (offences)** defines the criminal liability and "reasonably practicable" defence that applies to Regulation 12 obligations. The MVP encoded this in the `exceptionCondition` data property on `reg12-2b-risk-mitigation`, but there is no structural link to a formalised Regulation 22.
- **Regulation 13 (safeguarding)** overlaps with Regulation 12 — "preventing abuse" (Reg 13) and "assessing risks to health and safety" (Reg 12) interact when considering safeguarding risks.
- **Regulation 17 (good governance)** requires systems for assessing, monitoring and improving quality and safety — which directly governs *how* Regulation 12 compliance is monitored.

**Status:** Not modelled. The MVP did not formalise any regulations other than Regulation 12, so intra-instrument cross-references had no target to point to.

#### Pattern 3: Inter-instrument cross-reference — one normative instrument refers to another

Regulation 12(2)(h) references the "Code of Practice on the Prevention and Control of Infections" (the Hygiene Code), which is a separate statutory instrument. The MVP noted this in the `applicabilityCondition` string but did not model the Hygiene Code as a separate normative instrument or link the obligations structurally.

Other examples from the CQC landscape:
- The Regulations 2014 defer certain definitions to the HSCA 2008 ("regulated activity" means what the Act says it means).
- CQC guidance cross-references NICE guidelines, professional standards (GMC, NMC), and NHS England service specifications.
- The Medicines Act 1968 and Human Medicines Regulations 2012 underpin Regulation 12(2)(g) (medicines management) but are not part of the CQC regulatory instrument hierarchy.

**Status:** Not modelled. Would require additional normative instrument individuals and a cross-reference property.

#### Pattern 4: Conditional activation — "subject to" and "except where"

Legislative text frequently qualifies obligations with conditional references:

- "Subject to paragraph (3)" — an obligation is qualified by a later provision in the same regulation.
- "Except where regulations made under section X provide otherwise" — an obligation is overridden by delegated legislation.
- "Having regard to" — a softer reference requiring the reader to consider another instrument without being bound by it.

**Status:** Not modelled. The MVP encoded qualifications in the `exceptionCondition` and `applicabilityCondition` data properties as text strings.

#### Pattern 5: Temporal supersession — an instrument replaces or amends another

The Regulations 2014 replaced the Health and Social Care Act 2008 (Regulated Activities) Regulations 2010. The HSCA 2008 has been amended numerous times. The MVP captured this partially via `hasCurrencyStatus` (Current, Amended, Superseded) but did not model the amendment/supersession relationships structurally.

**Status:** `hasCurrencyStatus` exists as an enumerated attribute. Amendment chains are not modelled.

### 4.2 Proposed vocabulary extensions for cross-references

Based on the patterns above, we propose the following additions to the governance ontology:

#### New object properties

| Property | Domain | Range | Description | Pattern |
|---|---|---|---|---|
| `crossReferencesRegulation` | `DeonticDirective` | `DeonticDirective` | One directive structurally refers to another directive within the same or different instrument. Symmetric. | P2, P3 |
| `qualifiedBy` | `DeonticDirective` | `DeonticDirective` | A directive's scope or force is constrained by another directive. Not symmetric — the qualifying directive limits the qualified one. | P4 |
| `crossReferencesInstrument` | `NormativeInstrument` | `NormativeInstrument` | One instrument refers to another without implementing or interpreting it. Weaker than `implementsInstrument`/`interpretsInstrument` — a lateral reference, not a vertical hierarchy. | P3 |
| `amendsInstrument` | `NormativeInstrument` | `NormativeInstrument` | One instrument modifies provisions of another without replacing it entirely. | P5 |
| `supersedesInstrument` | `NormativeInstrument` | `NormativeInstrument` | One instrument replaces another. The superseded instrument's `hasCurrencyStatus` should be `SupersededStatus`. | P5 |

#### New data property

| Property | Domain | Range | Description |
|---|---|---|---|
| `crossReferenceNote` | `DeonticDirective` | `xsd:string` | Free-text annotation recording cross-references that are not yet structurally modelled — an escape valve for references that fall outside the typed property patterns. |

### 4.3 What should NOT be a structural cross-reference

Not every textual mention of another regulation or instrument warrants a structural OWL property. The following should remain as text in existing data properties:

- **Incidental mentions** in `directiveContent` ("providers should consider infection control" does not create a link to Regulation 12(2)(h) — that's the content of the obligation, not a cross-reference).
- **Evidence guidance** in `evidentialSpecification` that references external standards ("NICE guidelines" as an evidence source is not a normative cross-reference — it's guidance on what good evidence looks like).
- **Historical context** ("this regulation replaced Regulation X of the 2010 Regulations" is relevant for provenance but only warrants a structural link if the old regulation's obligations are still being mapped forward).

**Heuristic:** A textual reference should become a structural cross-reference property when the reference **changes the normative force** of the directive. If removing the reference would change what the bearer must do, how they are assessed, or what defences they have, it is structural. If removing it would only remove context, it is textual.

### 4.4 Implementation priority

The five cross-reference patterns have different implementation urgency:

| Pattern | Priority | Rationale |
|---|---|---|
| P1 (vertical hierarchy) | ✅ Done | Already in the MVP |
| P2 (intra-regulation) | **Next** | Becomes necessary as soon as a second regulation is formalised. Regulation 17 (good governance) is the most natural next target because it governs *how* Regulation 12 compliance is monitored. |
| P3 (inter-instrument) | **Next** | The Hygiene Code reference from Regulation 12(2)(h) is a concrete, immediate example. |
| P5 (temporal supersession) | Moderate | Important for legislative currency tracking but not blocking for compliance modelling. |
| P4 (conditional activation) | Lower | Complex semantics. The text-based `exceptionCondition` and `applicabilityCondition` approach works for now. Structural modelling of "subject to" clauses requires deeper analysis of defeasibility (see S121-D4). |

---

## 5. Interaction Between the Two Questions

The granularity question and the cross-reference question interact in two important ways:

### 5.1 Cross-references create implicit decomposition pressure

When Regulation 12(2)(h) references the Hygiene Code's 10 criteria, this creates pressure to decompose infection control into 10 sub-directives — one per criterion. This is a *cross-reference-driven decomposition* rather than a *statutory-text-driven decomposition*. The heuristic from §3.1 applies: each criterion should only become a separate directive if it satisfies the independent assessment test.

In the Hygiene Code case, the 10 criteria *are* independently assessable (CQC inspects each one), so decomposition is justified — but only when the Hygiene Code itself is formalised as a normative instrument. Until then, the text-based reference in `applicabilityCondition` is sufficient.

**Principle:** Cross-referenced instruments should be formalised before their internal structure drives decomposition of the referring instrument. Don't decompose a directive to match an unformalised external structure.

### 5.2 Granularity determines the useful resolution of cross-references

If obligations are very coarsely modelled (parent obligations only), cross-references can only point at broad targets: "Regulation 12 relates to Regulation 17." This is true but uninformative. At sub-clause level, cross-references become meaningful: "Regulation 12(2)(g) (medicines management) requires compliance with the Medicines Act 1968 prescribing requirements." The three-tier decomposition (§3.2) provides sufficient resolution for useful cross-referencing without requiring exhaustive decomposition.

---

## 6. Vocabulary Extensions Required

### 6.1 Summary of proposed changes to `ontara-governance.ttl`

| Change type | Item | Details |
|---|---|---|
| New object property | `crossReferencesRegulation` | Symmetric. Domain: `DeonticDirective`. Range: `DeonticDirective`. |
| New object property | `qualifiedBy` | Not symmetric. Domain: `DeonticDirective`. Range: `DeonticDirective`. |
| New object property | `crossReferencesInstrument` | Not symmetric by default. Domain: `NormativeInstrument`. Range: `NormativeInstrument`. |
| New object property | `amendsInstrument` | Not symmetric. Domain: `NormativeInstrument`. Range: `NormativeInstrument`. |
| New object property | `supersedesInstrument` | Not symmetric. Domain: `NormativeInstrument`. Range: `NormativeInstrument`. |
| New data property | `crossReferenceNote` | Domain: `DeonticDirective`. Range: `xsd:string`. |

These are additive changes — no existing classes, properties, or individuals need modification. The 5 new object properties and 1 new data property bring the governance ontology to 25 object properties and 17 data properties.

### 6.2 When to implement

These vocabulary extensions should be implemented when the next regulation is formalised (likely Regulation 17, Good Governance). At that point, the cross-reference properties will have concrete individuals to link. Adding the properties to the ontology schema before they have instances is architecturally sound (the properties exist as potential) and maintains schema-first discipline.

---

## 7. Design Decisions

| ID | Decision | Rationale |
|---|---|---|
| S132-D1 | Three-tier standard decomposition: statutory (T1, individuals) → guidance (T2, individuals) → evidential (T3, data property text) | Empirically validated by the MVP. Balances actionable compliance checking against modelling overhead. Promotion from T3 to T2 requires explicit domain expertise judgement. |
| S132-D2 | Independent assessability as the primary decomposition criterion | Aligns with how regulators actually assess compliance. Prevents both under- and over-decomposition. |
| S132-D3 | Five new cross-reference object properties covering patterns P2–P5 | Each pattern maps to a distinct semantic relationship. Separate properties maintain precision and support distinct SPARQL query patterns. |
| S132-D4 | `crossReferenceNote` data property as escape valve | Acknowledges that not all cross-references warrant structural modelling. Provides a pathway for textual references to be promoted to structural links as the ontology matures. Respects [[concept-non-constraining\|J3]]. |
| S132-D5 | Cross-referenced instruments should be formalised before driving decomposition of referring obligations | Prevents premature decomposition driven by external structure that is not yet in the knowledge graph. |
| S132-D6 | Vocabulary extensions are additive; implemented when next regulation is formalised | Schema-first discipline. No changes to existing individuals required. |

---

## 8. Open Questions

| ID | Question | Implications |
|---|---|---|
| S132-Q1 | Should `crossReferencesRegulation` be symmetric or directed? | Symmetric is simpler and reflects the intuition that "A references B" implies "B is referenced by A." But in practice, legislative cross-references are often one-directional (Reg 12 says "subject to Reg 22" but Reg 22 doesn't say "applies to Reg 12"). Directed-with-inverse-property might be more precise. |
| S132-Q2 | What is the right next regulation to formalise after Regulation 12? | Regulation 17 (Good Governance) is the strongest candidate because it governs the monitoring of all other regulations, creating mandatory cross-references. Regulation 13 (Safeguarding) is the second candidate due to overlap with Regulation 12. The choice determines which cross-reference patterns get exercised first. |
| S132-Q3 | Should T2b tenant-specific guidance directives live in the framework library or in a tenant-specific ontology file? | The framework library is platform-level shared infrastructure ([[concept-multi-tenancy\|A13]]). Tenant-specific directives might pollute a shared library. But separating them complicates the `containsDirective` linkage from the framework. This relates to the activation tier design (not yet implemented). |

---

## 9. Register Connections

### 9.1 Existing concepts exercised

| Concept | How exercised |
|---|---|
| [[concept-non-constraining\|J3]] (non-constraining) | T3 evidential specs as promotable strings (S132-D1); `crossReferenceNote` as escape valve (S132-D4) |
| [[concept-multi-tenancy\|A13]] (multi-tenancy) | T2b tenant-specific guidance directives; framework library vs tenant-level decomposition (S132-Q3) |
| [[principle-two-meta-model-distinction\|A4]] (two meta models) | Cross-reference properties connect to the dual-stack question: framework library (SMM) vs activation (BMM) |
| [[concept-authority-zones\|B29]] (authority zones) | Governance ontology remains OWL-authoritative; decomposition heuristics are domain-expertise-authoritative |
| [[ontara-ref-master-register\|B30]] (deontic directive vocabulary) | Extended with cross-reference semantics |
| [[ontara-ref-master-register\|B31]] (governance framework library) | Granularity heuristics govern library content |
| [[ontara-ref-master-register\|B33]] (normative instrument taxonomy) | Inter-instrument cross-references extend instrument relationships |

### 9.2 New concepts for registration

None. The proposed vocabulary extensions are refinements of existing concepts (B30, B33), not new architectural concepts.

---

*Discussion paper produced 4 April 2026 (Session 132). Resolves S121-Q2 (W-013: decomposition granularity) and S121-Q4 (W-014: legislative cross-references) based on empirical evidence from the CQC Governance MVP (Sessions 130–131).*
