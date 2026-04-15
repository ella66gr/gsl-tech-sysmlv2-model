---
tags:
  - architecture
  - foundations
date: 2026-04-15
status: current
session: 216
---
# Ontara — Platform Modelling Strategy

> `= this.file.path`

**Purpose:** The modelling strategy for the Ontara platform — what the canonical formalism is, why the engineering projection exists alongside it, how the model is structured, what it generates, and the principles that govern modelling decisions. This document is one of three foundations papers; the others are [[ontara-architecture-platform-principles|Architecture Principles]] and [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]].
**Audience:** The project founder, development collaborators, and technically capable readers seeking to understand the modelling approach and its rationale.
**Status:** Standing reference document. Uses a stable filename — versioning is expressed here, not in the filename.
**Staleness threshold:** 15 sessions or major architectural changes.

### Version History

| Version | Session | Date | Summary of changes |
|---|---|---|---|
| v5 | 216 | 15 April 2026 | **Full conceptual rewrite incorporating 46 sessions of development (S170–S216).** Restructured around the strengthened [[principle-two-meta-model-distinction\|A4]] committed in [[ontara-architecture-platform-principles\|Architecture Principles v5]] §3 (six strata, two sides, ten architectural loci). The two-formalism framing is inverted: under the binding KG-canonical commitment ([[concept-knowledge-graph\|B22]] promoted in Architecture Principles v5 §5.6), the Knowledge Graph in OWL 2 DL is the canonical formalism and SysML v2 is the engineering projection of selected content. The "Two Formalisms" treatment (v4.1 §11) is rewritten as §3 — the canonical formalism and its projection — and is moved earlier in the paper because it sets the vocabulary that every other section uses. The four-level distinction ([[ontara-ref-master-register\|B40]]) — metamodel / configured model / runtime instance / realising component — is the modelling-strategy expression of the strengthened A4 and is introduced explicitly in §2. The package architecture (v4.1 §7) is rewritten as §5 against the six-stratum × two-side grid. The runtime-state acronym BS is renamed to **SR (System Runtime state)** throughout for symmetry with BR (Business Representation), per [[ontara-ref-work-item-tracker\|OW-85]]. The five-layer SystemStateAssessment treatment is reframed against the SRS in §6.4. The five-principle unification hypothesis ([[ontara-ref-work-item-tracker\|OW-77]]) Test 2 is run section by section and reported in §2.5. The Domain Portability Architecture (DPA, [[ontara-ref-work-item-tracker\|W-053]]) is held as writing discipline throughout per [[ontara-ref-work-item-tracker\|OW-83]]: no paragraph forecloses it. Surface architecture vocabulary (B41–B44, J15) is acknowledged in §10 forward direction. Stage 8 portal and the Stage 9 architectural foundation papers are incorporated. v4.1 archived by Ella to [[—— HISTORY & ARCHIVE INDEX ——\|07 Ontara History & Archive]] before drafting began. **Drafting workflow:** full-rewrite container artifact per [[ontara-ref-work-item-tracker\|OW-212-1]] / [[ontara-ref-work-item-tracker\|OW-211-5]], replacing v4.1 wholesale at the canonical filename. Source for the structural reframing: [[ontara-architecture-platform-principles\|Architecture Principles v5]] §3, §5, §7.3 and the [[w-049-pms-v5-scoping-note\|W-049 PMS v5 scoping note]] |
| v4.1 | 170 | 7 April 2026 | Light touch-up: stale metrics updated throughout (12→13-file stack, 43→66 SPARQL queries, 26→42 reasoning classes, 11→12 query groups). Ears status updated from "outlined" to "analytical intake complete". Stage 7 Phases 2–4 and closure reflected. §12 Forward Direction updated. Related document version numbers corrected. No structural or conceptual changes. Archived as `SUPERSEDED-ontara-architecture-platform-modelling-strategy-2026-04-15.md` |
| v4 | 154 | 6 April 2026 | Major refresh incorporating 58 sessions of development (S96–S154). OWL 2 DL knowledge graph implemented (12-file stack, 43-query SPARQL suite, HermiT consistency, round-trip diff); `@BfoType` annotation (34/34); OWL pipeline and KG tooling in generation pipeline; deontic governance vocabulary and CQC MVP; domain identity implemented (dual-stack split); reasoning metamodel (26 OWL classes, evidence architecture, three-way constraint hierarchy); A6 reformulated as four-category scheme; A13 promoted to binding T1; PROV-O platform-level import; comprehension–reasoning convergence; console 13 views; Ears outlined; register ~212 concepts across 16 sections (A–P) |
| v3 | 96 | 1 April 2026 | BSMM→SMM terminology; [[concept-stakeholder-model\|StakeholderModel]] sixth concern (34 elements, 96 weights); package count 11→12 (ArchitecturalStructure); `@ArchitecturalLocation` annotation; console 12 views; dual-stack and simulation in forward direction; stale wikilinks fixed. Archived as [[SUPERSEDED-ontara-architecture-platform-modelling-strategy-v3-s96\|v3 (Session 96)]] |
| v2 | 65 | 24 March 2026 | Full revision. Archived as [[SUPERSEDED-ontara-platform-modelling-strategy-v2-s65\|v2 (Session 65)]] |
| v1 | ~8 | 4 March 2026 | Original. Archived as [[SUPERSEDED-ontara-platform-sysml-modelling-strategy-v1\|v1]] |

---

## Contents

- [[#1. Executive Summary|§1. Executive Summary]]
- [[#2. The Modelling Frame|§2. The Modelling Frame]]
- [[#3. The Canonical Formalism and Its Projection|§3. The Canonical Formalism and Its Projection]]
- [[#4. The Comprehension Architecture and Self-Description|§4. The Comprehension Architecture and Self-Description]]
- [[#5. The Two Metamodels and the Package Architecture|§5. The Two Metamodels and the Package Architecture]]
- [[#6. Knowledge, Decision Support, and Reasoning|§6. Knowledge, Decision Support, and Reasoning]]
- [[#7. Modelling Value Across the Business|§7. Modelling Value Across the Business]]
- [[#8. The Annotation and Metadata System|§8. The Annotation and Metadata System]]
- [[#9. Structural Principles for the Model|§9. Structural Principles for the Model]]
- [[#10. The Generation Pipeline|§10. The Generation Pipeline]]
- [[#11. Mapping Legacy Artefacts|§11. Mapping Legacy Artefacts]]
- [[#12. Current State and Forward Direction|§12. Current State and Forward Direction]]
- [[#13. Summary|§13. Summary]]
- [[#Critique Observations and Watchpoints|Critique Observations and Watchpoints]]
- [[#Related Documents|Related Documents]]

---

## 1. Executive Summary

The Ontara platform is built on a single canonical formalism — OWL 2 DL held in the Knowledge Graph — with SysML v2 as an engineering projection of selected content. The Knowledge Graph carries the platform's metamodel vocabulary, its tenant configurations, and its runtime instance content, all queryable in one vocabulary throughout. The SysML projection is used for human authoring of the parts of the model that benefit from SysML's structural and behavioural expressiveness; it is a complete view of those parts and only those parts. Hand-authored OWL modules — for governance, domain identity, reasoning, and clinical instance content — are first-class canonical content with no SysML projection at all.

This is a substantial reframing of the modelling strategy from v4.1, which presented OWL and SysML as two complementary formalisms each authoritative in its own domain. The Stage 5 round-trip diff engine (Session 137) closed the round-trip condition that the original B22 commitment had been waiting on, and the architectural reality has been KG-canonical since then. [[ontara-architecture-platform-principles|Architecture Principles v5]] §5.6 (Session 211) made the commitment binding by promoting [[concept-knowledge-graph|B22]] from directional to binding. This paper (PMS v5) projects the binding commitment into modelling-strategy terms.

The modelling strategy is downstream of the **stratified two-side architecture** committed to in [[ontara-architecture-platform-principles|Architecture Principles v5]] §3: six ontological strata (Foundation, Formalism Boundary, Metamodel, Configured Model, State Representation, Platform Realisation) running vertically, two sides (business, system) running through the strata where they are divided. The modelling vocabulary is precise at four levels — **metamodel / configured model / runtime instance / realising component** — registered as [[ontara-ref-master-register|B40]]. These four levels are how the strengthened A4 expresses itself in modelling work: every model element has a determinable level, every cross-level claim is named explicitly, and category errors that conflate the levels (notably the "metamodel runtime state" phrasing retired in Architecture Principles v5 §3.4 and treated in this paper at §5) are made impossible.

The two metamodels — Business Metamodel (BMM) and System Metamodel (SMM) — sit at the Metamodel stratum, each internally structured into General (sector-agnostic) and Tailored (sector-specific) content. The BMM is structurally complete at the General level (Session 81): 36 `part def`s plus 2 `requirement def`s across six concerns, plus the `Foundation::DomainRegistry` sub-package. The SMM is more distributed: an explicit core in `ArchitecturalSection` (B27), the deontic governance vocabulary, the domain identity vocabulary, the 42-class reasoning metamodel, and structural placeholders across the Foundation, Knowledge, ServiceDelivery, Platform, and Operations packages. The reasoning metamodel (Stage 7, Sessions 146–158, formally closed S159) is itself a cross-cutting SMM extension and provides the OWL vocabulary for institutionalised reasoning that the platform exercises across every domain that uses it.

The runtime instance content of the platform — every snapshot, every reasoning Claim, every governance assessment outcome, every workflow execution record, every binding observation — lives at the **State Representation Stratum (SRS)**, persisted as Knowledge Graph triples and queryable in the same vocabulary as the configured model content it instantiates. This is the modelling-strategy consequence of the strengthened A4 that has the largest practical effect: the comprehension architecture, the reasoning vocabulary, the governance vocabulary, and the simulation architecture (L5–L9) are not five independent capabilities the platform builds in parallel — they are facets of one underlying commitment, the SRS as the homogeneous queryable stratum, exercised by realising components reading and writing it through bindings at the boundary with the Platform Realisation Stratum.

The modelling philosophy that opened previous versions of this paper is preserved: the model is a large sheet of paper on which areas of key relationships and concepts are pencilled in at varying levels of detail. Clinical pathways occupy the inner ring of maximum rigour and full generation. Supporting infrastructure occupies a middle ring of structural clarity. Business context occupies an outer ring of architectural documentation. The model earns its keep ([[concept-model-earns-its-keep|J4]]) by generating something or making a non-obvious relationship visible — if modelling something merely restates the obvious, that is a signal to stop. What is new in v5 is the architectural precision about *what* is being modelled at each level: the rings are not three depths of the same activity, they are activities at different strata with different canonical representations and different consumers.

Four demonstrator domains validate that the BMM vocabulary generalises across structurally different service businesses: [[domain-cafe|Cafe]] (immediate retail, full model + running application), [[domain-suds|Suds]] (batch processing, BMM + COSHH governance), [[domain-paws|Paws]] (appointment-based personal service, General vocabulary), and [[domain-ears|Ears]] (community ear care, sector-regulated, analytical intake complete S160–168). [[concept-multi-tenancy|Multi-tenancy (A13)]] — promoted to binding Tier 1 in Session 142 — establishes that every domain is a tenant instantiation; GenderSense Limited is the most important tenant but is not structurally privileged.

The five-principle unification hypothesis ([[ontara-ref-work-item-tracker|OW-77]]) — that A2, A10, A11, A12, and L8 are facets of one underlying commitment rather than five independent ones — was tested in [[ontara-architecture-platform-principles|Architecture Principles v5]] §2.4 (Test 1 passed) and is tested again in this paper (Test 2 passed; reported in §2.5). The hypothesis is holding across the foundations papers. SBMM v4 will run Test 3.

This paper holds writing discipline against the **Domain Portability Architecture (DPA, [[ontara-ref-work-item-tracker|W-053]])** throughout, per [[ontara-ref-work-item-tracker|OW-83]]: no paragraph forecloses tenant content portability. KG-canonical makes the DPA's natural format space clear — any portable format must be RDF-based or RDF-derivable — but the DPA itself is a future workstream, not a v5 design activity.


---

## 2. The Modelling Frame

The modelling strategy is downstream of the architectural commitments stated in [[ontara-architecture-platform-principles|Architecture Principles v5]]. This section names the structural vocabulary the rest of the paper uses, the four levels at which modelling work is precise, the way the modelling activity is located in the strengthened A4 grid, and the result of the five-principle unification hypothesis as it bears on modelling.

### 2.1 The stratified two-side architecture, in modelling terms

[[ontara-architecture-platform-principles|Architecture Principles v5]] §3 commits the platform to **six ontological strata** running vertically and **two sides** running through the strata where they are divided. The frame is not restated here; what matters for modelling is what each stratum is the locus of, and which formalism is canonical at each stratum.

| Stratum | What it contains | Canonical formalism |
|---|---|---|
| **1. Foundation** | BFO 2020, CCO, IAO, PROV-O, OGMS — the upper and mid-level ontological grounding stack. Shared between both sides | OWL 2 DL (exclusively) |
| **2. Formalism Boundary** | The bilingual crossing: mapping ontology, correspondence graph, `@BfoType` annotations, OWL pipeline mapping rules, [[concept-authority-zones\|authority zone declarations]]. Shared between both sides | Both — the only stratum whose content is intrinsically bilingual |
| **3. Metamodel** | The structural vocabulary: BMM (business side) and SMM (system side). Each internally split into General (sector-agnostic) and Tailored (sector-specific) | OWL 2 DL canonical; SysML v2 projection of selected content |
| **4. Configured Model** | Tenant-specific configurations: Business Model (BM, business side) and System Model (SM, system side), one each per tenant | OWL 2 DL canonical; SysML v2 projection of selected content |
| **5. State Representation (SRS)** | All runtime model-grounded instance content: snapshots tagged by epistemic character, reasoning instances, governance instances, guidance reports, workflow execution records, binding observations | OWL 2 DL throughout (Knowledge Graph triples). No SysML projection |
| **6. Platform Realisation (PRS)** | The running infrastructure: realising components that enact configured models — GraphDB, Temporal, EHRbase, the Customer Portal, the Developer Console, terminology services, the Syside Modeler. Mixed-formalism by nature | Mixed — depends on the realising component |

Two sides — **business** and **system** — run through the strata where the strata are divided. Foundation and Formalism Boundary are shared. Metamodel, Configured Model, State Representation, and Platform Realisation are each split into a business-side content and a system-side content, with the two sides connected only through explicit horizontal mappings at the strata where they are distinct.

The modelling strategy operates principally at the Metamodel stratum (where modelling vocabulary is authored), at the Configured Model stratum (where tenants are configured against the metamodel), and at the boundary into the State Representation Stratum (where the runtime instance content the model predicts and shapes lives). Foundation and Formalism Boundary content is largely settled (the ontological grounding stack is established; the boundary mechanisms exist and work). The Platform Realisation stratum is the consumer of modelling output — realising components are generated from or bound to configured model content, and their interactions with SRS content are mediated by bindings.

Modelling vocabulary is precise about which stratum any given piece of content lives at. A `part def` in the SysML projection is Metamodel-stratum content; a `part` usage in a tenant's domain file is Configured-Model-stratum content; a snapshot of a tenant's current state is SRS content; a Temporal workflow run that produced part of the snapshot is a realising component at the PRS. These are different kinds of thing at different strata. Conflating them — treating a metamodel concept as if it had runtime state, treating a generated artefact as if it were the source of truth, treating a workflow execution record as if it were configured model content — is a category error that the strengthened A4 explicitly rules out (Architecture Principles v5 §3.4 prohibitions 1–5).

### 2.2 The four-level distinction (B40)

The modelling-strategy expression of the strengthened A4 is the **four-level distinction**, registered as [[ontara-ref-master-register|B40]]:

| Level | Stratum | What it is |
|---|---|---|
| **Metamodel** | Metamodel stratum | The structural vocabulary — BMM `part def`s, SMM `part def`s, OWL classes, OWL object properties. The kinds of thing that can be talked about |
| **Configured model** | Configured Model stratum | A tenant's configuration of the metamodel — which General elements apply, which Tailored extensions are activated, what specific values and relationships hold for this tenant. The particular thing that has been talked about for this tenant |
| **Runtime instance** | State Representation Stratum | An instance of a configured model element holding state at a particular moment, tagged by epistemic character. The thing that exists and is doing something now (or did, will, would, might) |
| **Realising component** | Platform Realisation Stratum | The running machinery that enacts configured models by populating the SRS and executing activity flows. The thing that makes the configured model operational |

The four levels are the operational grammar of modelling work. Every model element belongs to exactly one level. Every cross-level claim is named explicitly: "this metamodel concept has the following configured model instances", "this configured model element produces runtime instances of the following kind", "this runtime instance was produced by the following realising component". Implicit cross-level identification — for example, treating a SysML `part def` as if it had runtime state, or treating a Temporal workflow as if it were the source of truth for the process it runs — is a defect.

The four-level distinction was made explicit in [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199]] §2 as a discipline emerging from cross-domain walk-throughs that exposed the costs of conflation. It was registered as B40 in the master register at S199. PMS v5 makes it the core organising principle of modelling work, replacing the older "meta model versus instance" two-level framing that v4.1 used in places.

**The metamodel and configured model levels are static.** They do not have runtime state because they are not runtime entities. Phrasings such as "BMM runtime state", "the runtime state of the SMM", "BMM/SMM runtime state" — common in the project's prose before Session 208 — are category errors and have been retired. The substantive question such phrasings have been used to ask — "where does the runtime state of business model instances live?" — is answered by the SRS: runtime state lives at the State Representation Stratum, persisted as Knowledge Graph triples, populated by realising components binding into the SRS from below. The five category errors retired by Architecture Principles v5 §3.4 — cross-stratum conflation, cross-side identification, Foundation duplication, projection mistaken for canonicity, and metamodel runtime confusion — are all directly relevant to modelling discipline; the metamodel runtime confusion is the one with the highest historical regression rate and is treated more fully in §5 of this paper.

### 2.3 Architecture Principles v5 as the upstream

This paper does not restate Architecture Principles v5 — it references it. The principal sections referenced throughout this paper are:

- **[[ontara-architecture-platform-principles|Architecture Principles v5]] §3** — the strengthened A4: six strata, two sides, ten architectural loci, the compositional grid
- **§3.4** — the five category errors: cross-stratum conflation, cross-side identification, Foundation duplication, projection mistaken for canonicity, metamodel runtime confusion
- **§5.1** — [[principle-coordinate-framework|A12]] (coordinate framework) promoted to binding Tier 1
- **§5.6** — [[concept-knowledge-graph|B22]] (Knowledge Graph as canonical store) promoted to binding
- **§5.7** — the State Representation Stratum: what it contains, what it does not contain, the four defining properties of SRS content, the simulation architecture as expressions of the SRS, and §5.7.5 (real-world and synthetic activity indistinguishable at the SRS level)
- **§5.8** — the Platform Realisation Stratum and bindings
- **§5.9** — surface architecture (B41–B44, J15)
- **§7.3** — the constraint hierarchy as architectural spine (S207 D28, second empirical anchor for [[principle-unity-principle|A11]])

When this paper makes a structural claim about the architecture, the canonical statement is in Architecture Principles v5 and this paper references it. When this paper makes a claim about modelling activity, the canonical statement is here and Architecture Principles v5 references this one. The boundary is held: modelling-strategy-specific content lives here; architectural-commitment content lives in the principles paper.

### 2.4 Cross-cutting writing disciplines

Five disciplines are held throughout this paper:

1. **DPA-informed writing discipline ([[ontara-ref-work-item-tracker|OW-83]]).** No paragraph forecloses the Domain Portability Architecture. Tenant content boundaries are kept clean; cross-tenant references are explicit; per-tenant content does not hard-couple to platform-instance-specific identifiers. The DPA is not designed in this paper; it is held as a known structural concern.
2. **Four-level vocabulary used rigorously.** Metamodel / configured model / runtime instance / realising component. Where the v4.1 prose used "meta model" and "instance" as a two-term scheme, v5 uses the four-term scheme. The two-term scheme is preserved as historical vocabulary in version-history entries and in references to earlier sessions.
3. **SR (System Runtime state) throughout.** The acronym BS (Business System) used in S197, S208, and the integrated workshop document is renamed to SR for symmetry with BR. PMS v5 uses SR throughout. Documents that use BS predating Architecture Principles v5 remain valid working artefacts and are not retroactively rewritten.
4. **Cross-reference, do not restate.** Architecture Principles v5 §3 / §3.4 / §5 / §7.3 — referenced rather than reproduced. The boundary between this paper and the principles paper is held by discipline; restatement would create scaffolding-vs-content awkwardness in both papers and risk the two going out of sync at the next refresh.
5. **No retired phrasings.** No "BMM runtime state". No "SMM runtime state". No "BS" as runtime-state acronym. No "BMM side" / "SMM side" as terms for the two columns of the architecture (the columns are *sides*; the metamodels live at one stratum within those sides). Every occurrence of the retired phrasings in v4.1 has been rewritten in v5 against the four-level vocabulary or against the precise stratum-and-side terminology.

### 2.5 The five-principle unification — Test 2

[[ontara-ref-work-item-tracker|OW-77]] tests whether [[principle-self-describing-system|A2]] (self-describing system), [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge), [[principle-unity-principle|A11]] (unity principle), [[principle-coordinate-framework|A12]] (coordinate framework), and [[concept-coordinate-space-snapshots|L8]] (coordinate space snapshots) can be derived from the strengthened A4 — the SRS as the homogeneous queryable stratum — without introducing new content. Test 1 ([[ontara-architecture-platform-principles|Architecture Principles v5]] §2.4) passed for that paper. Test 2 is the same test applied to this paper.

The test is: can each of the five principles be stated in PMS v5 as a consequence of the strengthened A4 plus material already in Architecture Principles v5 §3 / §5, without introducing new content not derivable from those sources?

| Principle | Where PMS v5 invokes it | Test 2 derivation | Verdict |
|---|---|---|---|
| **A2** (self-describing) | §1, §4 | "Self-description is the SRS being queryable in the same vocabulary as the configured model that instantiates it." Cross-references Architecture Principles v5 §2.1 and §3.5. No new content | **Pass** |
| **A10** (intrinsic self-knowledge) | §4, §8 | "System explanations are dynamically computed from live SRS content via metadata-driven traversal. The boundary between authored and intrinsic content is the boundary between the Metamodel/Configured Model strata (authored) and the SRS (intrinsic)." Cross-references Architecture Principles v5 §2.4. No new content | **Pass** |
| **A11** (unity) | §1, §4, §6.2 | "One weighted relationship model, one canonical SRS, one query vocabulary." Two empirical anchors stated by reference: comprehension–reasoning convergence (S147-D7); constraint hierarchy as architectural spine (S207 D28, Architecture Principles v5 §7.3). No new content | **Pass** |
| **A12** (coordinate framework) | §6.2 | "The SRS is the coordinate space made queryable; reasoning metamodel constraint hierarchy maps onto coordinate-space structures; goal-seeking computation is pathfinding through constrained coordinate space." Cross-references Architecture Principles v5 §5.1. No new content | **Pass** |
| **L8** (coordinate-space snapshots) | §6.4, §6.5 | "L8 is the SRS's epistemic tagging mechanism — snapshots tagged by epistemic character. The five-layer SystemStateAssessment is the natural behaviour of the SRS when queried across epistemic tags." Cross-references Architecture Principles v5 §5.7.1. No new content | **Pass** |

**Test 2 result: passes for PMS v5.** All five principles can be stated as consequences of the strengthened A4 plus content already established in Architecture Principles v5 §3 and §5. No new content is introduced that is not derivable from those sources.

**Cumulative result so far.** Test 1 (Architecture Principles v5) passed. Test 2 (PMS v5) passes. Test 3 (SBMM v4) remains to run; it is expected to lean on Architecture Principles v5 §5.5 (Metamodel stratum General/Tailored sub-structuring) more heavily than Tests 1 or 2 did, because SBMM v4 is the foundations paper where the General/Tailored distinction lives at full detail. Tests 4 and 5 are longer-horizon (register treatment; Stage 9 falsifiable predictions).

The hypothesis is **holding across the foundations papers**. The principles survive as separately named commitments in the register because they are useful as separate names for aspects of the one underlying fact, but each is now structurally anchored in the strengthened A4 rather than holding its own load as an independent claim. The consequence for PMS v5 is that §4 (the comprehension architecture and self-description) and §6.2 (the reasoning metamodel and coordinate framework) are substantially more compact than their v4.1 counterparts: the principles do not each need their own argument because the argument lives once in Architecture Principles v5 §3 / §5.

The cumulative dependency on Architecture Principles v5 §3 / §5 is real — Test 2 derivations in this paper lean on the same v5 §3 commitments that Test 1 leaned on, plus §5.6 (KG-canonical) and §5.1 (A12 binding T1). [[ontara-ref-work-item-tracker|OW-89]] records this dependency for Test 1; [[ontara-ref-work-item-tracker|OW-215-1]] records it for Test 2. The unification hypothesis remains a derivation hypothesis (the principles can be derived from A4 plus surrounding architectural content), not a reduction hypothesis (the principles do not collapse into A4 alone). This is a fair recording, not a defect.

---

## 3. The Canonical Formalism and Its Projection

The single most important modelling commitment in v5 is the **KG-canonical commitment**: the canonical formalism for the platform's model content is OWL 2 DL held in the Knowledge Graph, and SysML v2 is the engineering projection of selected content. [[concept-knowledge-graph|B22]] was promoted from directional to binding in [[ontara-architecture-platform-principles|Architecture Principles v5]] §5.6 (Session 211); this section projects that commitment into modelling-strategy terms. The architectural reality has been KG-canonical since the round-trip diff engine closed the round-trip condition in Session 137; v5 makes the commitment explicit and uses it as the organising principle for the rest of the paper.

This section was v4.1 §11 (The Two Formalisms). Its move to §3 reflects the fact that under KG-canonical, the choice of canonical formalism sets the vocabulary that every subsequent section uses. The "two complementary formalisms" framing of v4.1 was a true description of the project's earlier orientation but is no longer the structural reality.

### 3.1 One canonical formalism, with a projection

Under KG-canonical, the architecture is **not** "two coequal formalisms (OWL and SysML) that compose with the strata". It is **"one canonical formalism (OWL in the KG) with a secondary engineering projection (SysML) used for human authoring of selected content"**. The shift is substantial in its consequences and in the writing discipline it requires.

The canonical content lives in the Knowledge Graph as OWL 2 DL. The SysML projection exists for the parts of that canonical content where SysML's structural and behavioural expressiveness — `part def` and `part`, action flows, state machines, requirements, constraints, the `metadata def` system, the cross-package `ref` mechanism — gives the human author leverage that authoring directly in OWL would not. The OWL pipeline (`gen_owl_pipeline.py`, Sessions 105–117) materialises the canonical OWL form of SysML-projectable content. The canonical content is the OWL output of the pipeline together with the hand-authored OWL modules that have no SysML projection at all.

The relationship between the two formalisms is:

| | Canonical formalism (OWL in the KG) | Engineering projection (SysML v2) |
|---|---|---|
| **Authority** | Canonical — the source of truth for the platform's model content | Projection — a faithful view of those parts of the canonical content that have a SysML projection |
| **Coverage** | Complete — covers every stratum where model content exists | Partial — covers only the parts of the Metamodel and Configured Model strata that have a SysML projection |
| **Authoring** | Hand-authored modules for content that has no SysML projection (governance, domain identity, reasoning metamodel, PROV-O core subset, clinical reasoning instances). Pipeline-produced classes and properties for content authored in SysML | Hand-authored for the structural and behavioural content that benefits from SysML's expressiveness. Read by the pipeline, never written by it |
| **Persistence** | GraphDB (production triple store), 13-file ontology stack loaded and HermiT-verified CONSISTENT | `.sysml` files in the repository, parsed by the generation pipeline, validated in the Syside Modeler |
| **Verification** | OWL 2 DL consistency checking (Robot + HermiT); SPARQL validation suite (66 queries in 12 groups); round-trip diff against the SysML projection (288 semantic units, 0 discrepancies) | Round-trip diff is a verification of projection fidelity — that the projection round-trips faithfully against the canonical, not that the canonical is correctly derived from anything else |

### 3.2 The Formalism Boundary stratum

The crossing between the canonical formalism and the projection lives at the Formalism Boundary stratum (Architecture Principles v5 §3.1, stratum 2). This is the architectural locus where OWL meets SysML; its content exists to make the projection from canonical to projected work, and to make the inverse traversal — from a SysML element to its canonical OWL identity — explicit and queryable.

The Formalism Boundary stratum contains five kinds of content:

1. **The mapping ontology** ([[concept-knowledge-graph|B24]]) — declarative mapping rules expressing how SysML elements become OWL classes, properties, and individuals
2. **The correspondence graph** (E019, the third stratum of the [[concept-knowledge-graph|three-stratum graph (E019)]] architecture) — explicit provenance-tracked records linking each SysML element to its OWL counterpart (1,378 triples)
3. **`@BfoType` annotations** — the SysML-side input to the OWL pipeline, declaring for each `part def` the BFO 2020 category and mid-level ontology parent that the pipeline uses to generate correctly classified OWL classes
4. **The OWL pipeline mapping rules** — the active machinery that reads `@BfoType` and other annotations and produces the correctly classified OWL output
5. **[[concept-authority-zones|Authority zone declarations (B29, E020)]]** — the metadata governing which formalism is authoritative for which content (SysML-authoritative for structure and behaviour, OWL-authoritative for ontological semantics and axioms, shared-constrained for labels and definitions)

Under KG-canonical, the Formalism Boundary stratum is **lopsided in favour of OWL**: its content exists to serve the projection from canonical OWL into the SysML view, and the canonical side is authoritative throughout. This does not retire authority zones; it sharpens what they are doing. SysML-authoritative content for structure and behaviour is content where the human authors directly in SysML and the pipeline produces the OWL counterpart; OWL-authoritative content for ontological semantics is hand-authored OWL with no SysML counterpart; shared-constrained content (labels, definitions) is content where both formalisms can carry the value but consistency is maintained by the pipeline. The authority zones tell the human author where to author and tell the pipeline what to verify.

### 3.3 Why OWL 2 DL is the canonical formalism

Five capabilities of OWL 2 DL make it the appropriate canonical formalism for the platform's model content. None of these capabilities is achievable in SysML v2.

**Open-world reasoning and automatic classification.** OWL 2 DL provides description-logic reasoning over the platform's vocabulary: a class can be defined by necessary and sufficient conditions, and the reasoner places instances and subclasses in their correct positions in the hierarchy automatically. The platform exploits this for ontological grounding (the BMM classes inherit through their `@BfoType`-declared parents in the mid-level ontologies), for governance reasoning (deontic obligations and prohibitions are subclasses of HardConstraint, with the reasoner placing them correctly), and for reasoning metamodel inference (the dual subclassing pattern from S147-D4 places reasoning classes correctly under both BFO and PROV-O parents).

**Consistency checking against ontological axioms.** OWL 2 DL consistency checking (HermiT via Robot) detects contradictions in the model's axiomatic structure. The 13-file ontology stack is verified CONSISTENT after every load. Without this verification, the platform's vocabulary could silently develop axiomatic contradictions that would surface only when the reasoning engines attempted to use the affected content.

**Importing existing OBO Foundry ontologies directly.** BFO 2020, CCO, IAO, PROV-O, and OGMS exist as OWL artefacts in the OBO Foundry. They are imported directly into the platform's ontology stack and used as the ontological grounding stratum without any translation. The same content in SysML would require a manual transcription that would inevitably go out of sync with the OBO Foundry sources.

**SPARQL semantic querying.** SPARQL queries against the Knowledge Graph have full semantic awareness — they can use class hierarchy, property characteristics, and inferred triples directly. The 66-query SPARQL validation suite (12 groups) exercises this every time the pipeline runs. The same queries against a SysML model would require a query language that does not yet exist for SysML v2 at production maturity.

**Formal TBox/ABox separation mapping naturally onto the four-level distinction.** OWL's TBox (terminological axioms — class definitions, property definitions, axioms about how the vocabulary fits together) and ABox (assertional axioms — instance content, relationship assertions, named individuals) provide a formal separation between vocabulary and instance content that is natural for the four-level distinction. The metamodel and configured model levels are TBox content (the configured model is a populated extension of the metamodel TBox); the runtime instance level is ABox content. The boundary is enforced by the OWL formalism rather than maintained by convention.

### 3.4 Why SysML v2 is the engineering projection

Three capabilities of SysML v2 make it the appropriate engineering projection for the parts of the canonical content where it is used. The capabilities listed below are the ones SysML provides that OWL 2 DL alone does not provide at the same level of authoring ergonomics; they are not capabilities that override the canonical commitment.

**Structural and behavioural expressiveness with one model.** SysML v2 holds structural definitions (`part def`, `attribute`, `ref`), behavioural models (action flows, state machines), requirements and constraints (`requirement def`, `constraint def`), and metadata annotations in one semantically typed model. A human author working on structural and behavioural content can express all of it in one place. The 2018 SHC work used three separate formalisms (use case diagrams for purpose, BPMN for process, UML class diagrams for technology structure) that could not reference each other formally; SysML v2 closes those gaps by providing a unified model where every kind of content participates in a single queryable structure.

**The `metadata def` mechanism.** SysML v2's `metadata def` and metadata usage (`@`) provide a typed, model-native way to attach generation hints, comprehension schemas, user-facing descriptions, catalogue tags, BFO classifications, and weighted relationships to any model element. The annotations are themselves model content — they participate in the type system, are queryable, and survive into the OWL pipeline output as canonical content. The annotation system is the connective tissue of both the comprehension architecture (§4) and the generation pipeline (§10), and it is the primary mechanism by which SysML-authored content carries the metadata the pipeline needs to produce correctly classified OWL output.

**Code generation targets.** The model-to-application generators (§10) read SysML and produce TypeScript types, constraint evaluators, decision table evaluators, JSON data for the console, financial projections, and the system manifest. SysML's structural and behavioural expressiveness gives the generators a clean source to work from. OWL, while canonical for the model content itself, is not as direct a source for application-level code generation; the generators benefit from working against the SysML projection.

**What SysML v2 is not used for.** SysML v2 is not used for ontological grounding (BFO, CCO, IAO, PROV-O, OGMS — these are OWL Foundation-stratum content). It is not used for the governance vocabulary, the domain identity vocabulary, the reasoning metamodel vocabulary, or the clinical reasoning instances — these are hand-authored OWL modules with no SysML counterpart. It is not used for the State Representation Stratum (SRS content is OWL throughout). It is not used for the Platform Realisation Stratum (the running infrastructure is what it is — Temporal, EHRbase, GraphDB, the front-end applications — and is not a model). The SysML projection is for the parts of the Metamodel and Configured Model strata where its expressiveness benefits the human author.

### 3.5 Hand-authored OWL modules are first-class canonical content

A direct consequence of KG-canonical is that the **hand-authored OWL modules are first-class canonical content with no SysML projection**. Their relationship to "the model" was previously slightly awkward because they had no SysML counterpart; under KG-canonical, they are simply canonical content that does not happen to have a projection. They are loaded directly into the 13-file stack alongside the pipeline-produced content and are validated by the same QA layers (HermiT consistency, SPARQL validation).

The current hand-authored OWL modules are:

| Module | Namespace | Purpose | Sessions |
|---|---|---|---|
| `ontara-governance.ttl` | `ontara-gov:` | Deontic governance vocabulary — Obligation, Prohibition, Permission, RegulatoryPower; normative instruments; CQC Regulation 12 individuals | 121–131 |
| `ontara-domain.ttl` | `ontara-domain:` | Domain identity vocabulary — DomainIdentity and DomainConfiguration as OWL classes, regulatory tier and other enumerations | 144 |
| `ontara-reasoning.ttl` | `ontara-rsn:` | Reasoning metamodel vocabulary — 42 classes covering reasoning contexts, evidence architecture, three-way constraint hierarchy, decision modes, knowledge sources, structured probabilistic types, STAMP/STPA safety control structures | 150–157 |
| `prov-core.ttl` | `prov:` | Core subset of PROV-O sufficient for the reasoning metamodel's provenance grounding | 148–150 |
| `ears-reasoning-instances.ttl` | `ontara-ears:` | ~83 reasoning instance individuals from the Ears clinical domain intake exercising 25 of the 42 reasoning metamodel classes | 166 |

Future hand-authored OWL modules will join this set. The strategic placement is: structural and behavioural content where SysML's expressiveness wins → SysML projection with OWL pipeline producing canonical. Ontological-vocabulary content where OWL-only is natural → hand-authored OWL with no projection. Instance content from clinical domains where the analytical work happens at OWL-individual granularity → hand-authored or generator-produced OWL instances.

### 3.6 The SysML model is not a complete view of the platform

A reader who picks up the SysML v2 model and assumes it shows them everything the platform contains is wrong. The SysML model is a complete view only of the parts that are projectable — the parts of the Metamodel and Configured Model strata where SysML is used as the engineering projection. It does not contain:

- The Foundation stratum (BFO, CCO, IAO, PROV-O, OGMS — OWL only)
- The Formalism Boundary stratum (the mapping ontology, the correspondence graph, the `@BfoType` annotations are in SysML but the rules they participate in and the correspondence triples they produce are at the Formalism Boundary stratum, not the Metamodel stratum)
- The hand-authored OWL modules listed in §3.5 (governance, domain identity, reasoning metamodel, PROV-O core, clinical reasoning instances)
- The State Representation Stratum (snapshots, reasoning instances, governance instances, guidance reports, workflow execution records, binding observations — all SRS content is OWL only)
- Most of the Platform Realisation Stratum (the running infrastructure has no model representation by design — it is the realising components, and they are what they are)

This is registered as the substantive observation [[ontara-ref-work-item-tracker|OW-79]] from S208. PMS v5 makes it explicit because the SysML projection's incompleteness is the consequence of KG-canonical that has the highest practical risk of being missed by readers who have spent time with the SysML model but not with the canonical KG.

The implication for downstream development is straightforward: when the question is "what does the platform contain?", the answer is in the canonical KG (the 13-file ontology stack plus its loaded content). When the question is "what is the structural and behavioural content of this Metamodel-stratum or Configured-Model-stratum element?", the answer is in the SysML projection if the element has one, or in the hand-authored OWL module if it does not. Tooling that needs to navigate model content end-to-end navigates the KG; tooling that operates on structural and behavioural content navigates the SysML projection.

### 3.7 Authoring asymmetry and a known concern

A consequence of KG-canonical worth naming is the **engineering asymmetry in authoring ergonomics**. The SysML projection has mature tooling (the Syside Modeler, the language server, the syntax reference, the parser) and a comfortable authoring workflow for structural and behavioural content. The hand-authored OWL modules are authored in plain text editors against the OWL 2 Manchester or Turtle syntax, with verification via Robot and HermiT runs — workable but with much less ergonomic support.

This asymmetry is acceptable as long as the SysML projection is used for the content where its expressiveness wins and the hand-authored OWL is used for the content where the OWL-only authoring is natural. It will become uncomfortable if the canonical KG grows large enough that authoring directly against it becomes a routine activity — at which point investment in OWL-side authoring tooling will be needed. This is registered as [[ontara-ref-work-item-tracker|OW-78]] (KG-canonical engineering authoring-parity asymmetry); the watchpoint is that the asymmetry is a future tooling concern, not a present blocker, but it should be tracked rather than ignored.

A related observation: the console currently has no view of the hand-authored OWL modules as navigable model content. They appear in the Ontology view's KG Status panel as triple counts, and their classes appear in the BFO hierarchy view, but there is no equivalent of the Component Catalogue or the Glossary that lets a user browse the hand-authored content as model material. This is registered as [[ontara-ref-work-item-tracker|OW-215-3]] for a future console workstream — not a v5 concern, but worth flagging because §3.5 brings it into focus.

### 3.8 Quality assurance keeps the canonical and the projection in sync

Three layers of automated quality assurance keep the canonical content and the SysML projection in sync:

1. **SPARQL validation** — 66 queries in 12 groups checking structural and semantic correctness of the canonical content (BMM classes, properties, weighted relationship individuals, governance individuals, domain individuals, reasoning instances, correspondence triples)
2. **OWL 2 DL reasoning** — HermiT (via Robot) checking logical consistency across the 13-file stack after every load
3. **Round-trip diff** — 288 semantic units verifying that the SysML projection round-trips faithfully against the canonical KG, authority-zone-aware so that SysML-authoritative content and OWL-authoritative content are checked correctly

Under KG-canonical, the round-trip diff is reframed: it verifies projection fidelity (the SysML projection is a faithful view of the canonical), not canonical derivation (the canonical is not derived from the SysML projection — it is the source of truth, with SysML as a view of selected content). This is the linguistic shift from v4.1's framing; the underlying machinery is unchanged.

### 3.9 Implications for downstream work

The KG-canonical commitment has three concrete implications for downstream modelling work:

**Authoring decisions are made deliberately.** New content that is structural and behavioural and benefits from SysML's expressiveness goes in the SysML projection with appropriate `@BfoType` and other annotations to drive the OWL pipeline. New content that is ontological-vocabulary or instance content that does not benefit from SysML's expressiveness goes in a hand-authored OWL module or as generator-produced OWL instances. The decision is made at the point of authoring, not retrospectively.

**Documentation references the canonical content.** When a paper or a register entry references model content, it references the canonical content (by OWL class IRI or by equivalent canonical identifier) rather than the SysML projection alone. The SysML projection is referenced where the structural and behavioural content of a particular element is the relevant detail; the canonical is referenced where the model content as platform content is the relevant detail. This discipline avoids the silent assumption that the SysML projection is the complete view.

**Tool boundaries are explicit.** When tooling reads model content, it reads from the canonical (the KG) for cross-stratum or cross-module navigation; it reads from the SysML projection for structural and behavioural detail of projectable content. The Ontara Console currently reads from `model-introspection.json` (a generator output) for most of its views — this is a derived artefact from the SysML projection, not direct KG access. Live SPARQL against the KG is a future console capability ([[ontara-workflow-emergent-ideas-log|E022]] / Stage 5 Phase 4); when it lands, it will give the console direct access to the canonical content.


---

## 4. The Comprehension Architecture and Self-Description

The Ontara platform knows what it is, what it is doing, why, and what rules govern it ([[principle-self-describing-system|A2]]). This section states what self-description means in modelling-strategy terms, names the comprehension architecture as its operational realisation, and treats the modelling implications. The full architectural treatment lives in [[ontara-architecture-platform-principles|Architecture Principles v5]] §2; this section projects that treatment into the work the modelling strategy does to make self-description happen.

### 4.1 The three registers

The comprehension architecture (Sessions 45–58, [[ontara-discussion-comprehension-architecture-2026-03-19|Comprehension Architecture discussion paper]]) addresses how the system knows what it contains and how to explain itself. Three registers of content provide the answer.

| Register | Content | Source |
|---|---|---|
| **Authored** | Human-written purposive descriptions — why an element exists and what it does for the service | `@PurposiveDescription` metadata at the Metamodel and Configured Model strata. 34/34 BMM coverage; 20/20 architectural section coverage |
| **Structural** | Facts the model already knows — type, relationships, containment, patterns, domain instantiations | Dynamically computed from SRS queries against metamodel and configured-model content via `@Comprehension` metadata traversal schemas. 34/34 BMM coverage |
| **Inferential** | Derived explanations beyond what any single element states — analogies, gap analysis, impact propagation, evidence-backed claims | Produced by reasoning-metamodel-grounded realising components reading SRS content and writing further SRS content (Claims, EvidenceLines, ConfidenceAssessments) via PROV-O provenance. The inferential register and the SEPIO+PROV-O evidence architecture are the same pattern (S147-D7 convergence) |

Under the strengthened A4, the three registers map cleanly onto the strata. Authored content is at the Metamodel and Configured Model strata — it is the hand-written content that exists in the model itself. Structural content is dynamically computed from SRS queries — the same queries that answer "what is the state of the business" also answer "what does the business contain and how is it structured", because the configured model content and its SRS instance content share one vocabulary. Inferential content is what reasoning-metamodel-grounded realising components at the Platform Realisation Stratum produce when they read SRS content and write further SRS content (Claims and Evidence) back into it. All three registers are, structurally, SRS operations — either reading from the SRS (structural) or reading and writing the SRS (inferential) or authored at the strata the SRS instantiates (authored).

### 4.2 The intrinsic/authored boundary

The [[principle-intrinsic-self-knowledge|intrinsic self-knowledge principle (A10)]] governs the boundary: if the model changes and no human edits a description, does the explanation become wrong? If yes, that content must be intrinsic — dynamically computed from live model state, not stored as static text.

Under the strengthened A4 the test becomes a structural property rather than a discipline. Authored content at the Metamodel and Configured Model strata cannot be "wrong" when the lower strata change because it is the reference the lower strata derive from. Intrinsic content at the SRS cannot be stale because it is recomputed as realising components write into it. The intrinsic/authored boundary is the boundary between the static upper strata (where authored content lives) and the dynamic SRS (where intrinsic content lives), with prohibition 1 of [[ontara-architecture-platform-principles|Architecture Principles v5]] §3.4 (no realising component writes to Metamodel-stratum or Configured-Model-stratum content) ensuring that authored content cannot be silently rewritten by runtime activity.

The modelling-strategy implication is that the **authoring discipline is per-stratum**. Authored content at the Metamodel stratum is hand-edited by humans — typically Ella in Ontara's current single-architect arrangement — through the SysML projection (for projectable content) or through hand-authored OWL modules (for non-projectable content). Authored content at the Configured Model stratum is hand-edited by tenant configuration activities — also currently human, with future tooling on the horizon (the dual-canvas construction kit, see §12). Structural content at the SRS is dynamically computed at query time and is never authored. Inferential content at the SRS is produced by reasoning realising components and is never authored either, though the reasoning vocabulary that shapes it is authored at the Metamodel stratum.

### 4.3 Weighted relationships and the unity of the model

96 `@WeightedRelationship` annotations across 33 weighted elements express the strength of interaction between BMM concepts. These relationships are directional and non-commutative: the weight on A → B answers "if A changes, how much does B need reassessment?", and the reverse B → A is independently assessed. Weights do not net off, average, or combine — they are structural facts about the model's topology.

The weight model supports three interpretive frames — costs and preferences, fuzzy human judgements, and probabilities — formalised in the reasoning metamodel as named individuals (`ProbabilityFrame`, `FuzzyMembershipFrame`, `PreferenceWeightFrame`), stable since their first identification in Session 46. Weighted relationships have canonical OWL representation: 96 reified individuals in `ontara-bmm-weights.ttl` (702 triples), loaded into the knowledge graph alongside the BMM classes and object properties.

The [[principle-unity-principle|unity principle (A11)]] commits the platform to one weighted relationship model informing comprehension, reasoning, simulation, governance, and assembly guidance — no separate, disconnected knowledge structures. Under the strengthened A4, A11 has an operational reading that is stronger than its original formulation: the reason there are no separate structures is structural. The weighted relationships are at the Metamodel stratum (as `@WeightedRelationship` metadata with OWL reification), and every subsystem that uses them is a realising component at the PRS that reads them through bindings into the same SRS. There is not five subsystems each carrying their own weighted-relationship machinery; there is one SRS that every subsystem queries through its bindings.

A11 is empirically validated at two layers. **At the reasoning layer** by the comprehension–reasoning convergence of Session 147 (S147-D7) — the inferential register and the SEPIO+PROV-O evidence architecture were identified as the same pattern, not two patterns that happen to look similar. **At the surface layer** by the constraint hierarchy → UI affordance mapping finding from Session 207 (S207 D28, treated in [[ontara-architecture-platform-principles|Architecture Principles v5]] §7.3) — the three-way constraint hierarchy maps to three distinct UI affordance types at multiple bands, with the same canonical constraint state surfacing consistently without per-surface re-implementation. Both findings are the same claim: one canonical model, surfacing consistently through every realising component that reads it.

Under the strengthened A4, neither finding is an empirical surprise. Both are what the architecture structurally commits to. The modelling-strategy consequence is that the weighted relationships do not need separate generator-side support per consuming subsystem; they need one canonical representation in the KG (which they have, in `ontara-bmm-weights.ttl`) and queryable access for every consumer through the standard SRS query interface.

### 4.4 What the comprehension architecture is for

The comprehension architecture is not a documentation feature added to a platform that would otherwise be opaque. It is the operator-facing surface of the State Representation Stratum. The Ontara Console (currently 13 views) is a realising component at the PRS that reads SRS content through bindings and renders the three registers — authored content as text, structural content as queries against the SRS, inferential content as the outputs of reasoning realising components — for the human user.

The modelling-strategy implications are:

**The annotation system carries the comprehension content.** `@PurposiveDescription`, `@UserFacing`, `@Comprehension`, `@WeightedRelationship`, `@CatalogueTag`, `@ArchitecturalLocation`, `@BfoType` — all are part of the comprehension architecture's content. The annotation system is treated more fully in §8.

**The console is a consumer, not a source.** The console renders model content; it does not author it. New comprehension features in the console are realising-component features that consume canonical content; they do not require new model content unless the existing canonical content does not yet carry what the new feature wants to render.

**Cross-cutting comprehension is structurally trivial.** Under the strengthened A4, "show me everything in the platform that is governance content" is a SPARQL query against the SRS that filters by ontological category, not a separate index that has to be maintained. The unity principle (A11) means there is one canonical model to query against, regardless of which subsystem authored the content.

**Co-evolution remains the discipline.** [[concept-co-evolution|J2]] (no modelling without the tool that makes it legible; no tool without model content that exercises it) continues to govern the relationship between model extensions and console features. The modelling-strategy expression of J2 is: when adding to the model, identify the comprehension surface and ensure it is built or planned; when adding a comprehension surface, identify the model content it requires and ensure that content exists.

---

## 5. The Two Metamodels and the Package Architecture

The package structure is organised around the **two metamodels** at the Metamodel stratum: the Business Metamodel (BMM, business side) and the System Metamodel (SMM, system side). Together they sit at the third stratum of the strengthened A4's six-stratum frame, and their content is the structural vocabulary that tenant configurations populate at the Configured Model stratum and that runtime instance content instantiates at the State Representation Stratum.

This section was v4.1 §7. Its rewrite reflects the strengthened A4 framing: the "two meta models" are no longer the principal architectural commitment they were treated as in v4.1, because the strengthened A4 frames them as one stratum within the larger six-stratum × two-side grid. They remain critical — the Metamodel stratum is the load-bearing stratum for the platform's vocabulary — but they are critical *because* the strengthened A4 makes them critical, not as a freestanding architectural fact.

### 5.1 The four-level distinction within the Metamodel stratum

Modelling work at the Metamodel stratum operates at the metamodel level of the four-level distinction (B40, §2.2). Metamodel-stratum content defines the kinds of thing that can be talked about; configured model content is what gets talked about for a particular tenant; runtime instance content is what is actually happening or could happen for that tenant; realising components are the running machinery.

This means the metamodel-stratum work that the BMM and SMM define is **structural vocabulary work**, not instance work. A BMM `part def` defines a kind of thing — `ServiceOffering`, `PaymentArrangement`, `ClinicalConsultation` — that a tenant's BM can have instances of. The tenant's BM at the Configured Model stratum holds the instances (with their tenant-specific names, descriptions, relationships); the SRS at the State Representation Stratum holds the runtime state of those instances (a particular consultation booked at a particular time with a particular patient and a particular clinician). The metamodel does not have runtime state — it has vocabulary. Conflating these is the metamodel runtime confusion that prohibition 5 of Architecture Principles v5 §3.4 retires; v5 of this paper uses the four-level vocabulary throughout to make the conflation impossible.

### 5.2 The Business Metamodel

The BMM defines the structural template for any service business, independent of technology. Its content is at the Metamodel stratum on the business side. The canonical representation is in OWL (34 BMM classes + 14 object properties + 96 reified weighted relationship individuals + correspondence triples, produced by the OWL pipeline from the SysML projection); the SysML projection is the primary authoring surface for new BMM content.

The BMM is structurally complete at the General level (Session 81): 36 `part def`s + 2 `requirement def`s across six concern packages, plus `Foundation::DomainRegistry` (`DomainIdentity` + `DomainConfiguration`, Session 143). All elements carry full annotation stacks (§8). General/Tailored decomposition ([[concept-general-tailored-decomposition|B11]]) classifies each element as sector-agnostic (General) or sector-specific (Tailored) — within the Metamodel stratum, not as a stratum boundary.

The six concerns of a service business (C1–C5, C7) are the principal organising structure of the BMM:

| Package | Concern | What it covers |
|---|---|---|
| **ServiceConcept** | C1 | What value is delivered, to whom, and why it is worth paying for |
| **ActivityModel** | C2 | How value is produced and delivered — processes, workflows, outcomes |
| **ResourcePlanning** | C3 | What resources and capabilities are required |
| **FinancialPlanning** | C4 | How money flows — revenue, costs, pricing, projections |
| **GovernanceMapping** | C5 | Regulatory requirements, governance, risk, learning |
| **[[concept-stakeholder-model\|StakeholderModel]]** | C7 | Relationships, partnerships, cooperative delivery, community, participation — the relational boundary. Six General elements (proposed Session 76, designed Session 78, implemented Session 81) |

Activity Awareness (C6) is the cross-cutting dimension — every unit of activity is visible across all six concerns.

The BMM packages live under the `BusinessModel` top-level package, with companion packages `BusinessScenarios` and `BusinessStrategy`. 12 BMM attributes have been migrated from String to typed `ref` (Session 58), enabling cross-package weight traversal and semantic navigation.

The detailed treatment of the BMM vocabulary, including the criteria for promoting content between General and Tailored, the full enumeration of the 36 `part def`s, and the way Tailored extensions hook into the General core, belongs in [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]] rather than here. PMS v5 names the BMM and its scope; SBMM v4 holds the detail. This boundary discipline is held throughout this section, tracked as [[ontara-ref-work-item-tracker|OW-87]].

### 5.3 The System Metamodel

The SMM defines the structural template for how a business system works. Its content is at the Metamodel stratum on the system side. The canonical representation is in OWL; the SysML projection holds the structural and behavioural content of those parts of the SMM that have a SysML projection — currently `ArchitecturalSection` and the structural placeholders in the Foundation, Knowledge, ServiceDelivery, Platform, and Operations packages.

The SMM is more distributed than the BMM. Its content lives at four loci:

**Explicit SMM core in SysML.** `ArchitecturalSection` (B27, Session 87): 1 `part def`, 20 `part` usages encoding the [[concept-dual-stack-architecture|dual-stack architecture]], 3 enums (`ArchitecturalGroup`, `Formalism`, `ImplementationStatus`), 1 `metadata def` (`@ArchitecturalLocation`), 6 concern-group disjointness declarations in OWL, 14 object properties, 9 cardinality restrictions, 96 reified weighted relationship individuals. The first SMM-side model content. Lives in the `ArchitecturalStructure` top-level package.

**Domain identity in SysML and OWL.** `DomainIdentity` and `DomainConfiguration` (Sessions 142–144): 2 `part def`s in `Foundation::DomainRegistry`, 6 enums in `Foundation::CommonTypes`, 8 domain instances. The dual-stack split places business intent on the business side (`DomainIdentity` carrying regulatory tier, purpose, jurisdiction) and system settings on the system side (`DomainConfiguration` carrying vocabulary scope, governed activities, organisational form), connected by an explicit horizontal mapping at the Configured Model stratum. OWL counterpart: `ontara-domain.ttl` (2 classes, 6 enumeration classes, 8+8 properties, 8 individuals).

**Hand-authored OWL modules extending the SMM beyond SysML.** Three substantial modules that are first-class canonical SMM content with no SysML projection (per the §3 KG-canonical reframing — these are no longer "extending the SMM beyond SysML" in the v4.1 sense; they are simply canonical SMM content that does not happen to have a projection):

- **Deontic governance vocabulary** (`ontara-governance.ttl`, Sessions 121–131): 19 classes, 6 enumeration classes, 24 named individuals, 23 object properties, 17 data properties. CQC Regulation 12 formalised as 21 individuals (Session 131).
- **Reasoning metamodel vocabulary** (`ontara-reasoning.ttl`, Sessions 150–157): 42 classes, 15 named individuals, 40 object properties, 10 datatype properties, 2 cross-module governance alignment axioms, 7 PROV-O dual-subclassed classes. The reasoning metamodel is a cross-cutting SMM extension (S146-D1) — it lives in the SMM at the Metamodel stratum and its instance content lives at the SRS.
- **PROV-O core subset** (`prov-core.ttl`, Sessions 148–150): the provenance grounding for the reasoning metamodel.

**Structural placeholders distributed across packages.** Foundation, Knowledge, ServiceDelivery, Platform, and Operations packages contain SMM concept placeholders that have not yet been promoted into a named navigable package structure (gap O2 in the [[ontara-ref-master-register|master register]]). The SMM General vocabulary is organised into six capability groups (B25): Persistence & Data Management, Process Orchestration, Evaluation & Reasoning, Observation & Self-Knowledge, Integration & Communication, Identity & Access — with an architectural role axis (B26) as secondary classification.

A future workstream will promote the implicit SMM concepts distributed across the Foundation, Knowledge, ServiceDelivery, Platform, and Operations packages into a named, navigable package structure. The SysML section name `bsmm-general-vocabulary` is retained as a structural identifier for the SMM core.

Under the strengthened A4, the SMM's distribution across these four loci is honest about the architectural reality: SMM content exists at multiple stations of the Metamodel stratum, with different canonical representations (SysML projection for some, hand-authored OWL for others), but all of it is metamodel content on the system side and is queryable as one body of vocabulary in the canonical KG.

### 5.4 The package structure

The model contains 12 top-level packages (~74 packages total). Each package is located by its meta-model affiliation (BMM, SMM, or cross-cutting) and its current state.

| Package | Meta model | Purpose | Current state |
|---|---|---|---|
| **Enterprise** | SMM | Organisation, regulation, strategy, risk | Structural placeholders |
| **Foundation** | SMM (cross-cutting) | MetadataLibrary, CommonTypes, StatePatterns, GenerationPipeline, DomainRegistry (Session 143) | Active. MetadataLibrary is the home of all annotation `metadata def`s |
| **Knowledge** | SMM | ClinicalDecisionSupport, ConstraintLibrary, LogicEngine, DecisionModels, OutcomeFramework, LearningCycles, Analytics | Architectural documentation; evaluation patterns designed |
| **ServiceDelivery** | SMM | PatientJourney, ClinicalPathways, Consent, CoachingSupport, ClinicalGovernance, ClinicalEntities | Structural skeleton; Cafe demonstrates pathway and lifecycle patterns |
| **Platform** | SMM | PatientPortal, Booking, EHR, Forms, Messaging, VideoConsulting, LabInterface, Prescribing, Payments, Documents, Identity, Orchestration, Integration | Structural design; Cafe demonstrates EHR, Orchestration, Payments |
| **Operations** | SMM | Finance, People, Marketing, CRM, Reporting | Structural placeholders |
| **ArchitecturalStructure** | SMM | [[concept-architectural-section\|ArchitecturalSection]] (B27): 20 `part` usages encoding the dual-stack | Active. First SMM-side model content (Session 87) |
| **BusinessModel** | BMM | 36 `part def`s + 2 `requirement def`s across six concerns with full annotation stacks. Domain identity (DomainRegistry sub-package, Session 143). BMM structurally complete at General level | Active |
| **BusinessScenarios** | BMM | Scenario comparison and financial projection | Active. Cafe and GSL scenarios modelled |
| **BusinessStrategy** | BMM | Strategic objectives, business direction | Active. GSL strategic objectives modelled |
| **PatternCatalogue** | Cross-cutting | 22 validated patterns, 8 principles, 43 typed `ref` relationships, 33 domain instantiations | Active |
| **GenderSense** (root) | Configured Model | GSL-specific business model instance, clinical pathway models, tenant-level configuration | Active. The first production tenant. Lives at the Configured Model stratum, not the Metamodel stratum |

The GenderSense package is correctly framed under the strengthened A4 as **Configured Model stratum content for one specific tenant**, not as Metamodel-stratum content. Its content is the BM and SM instance content for the GenderSense tenant, populating the BMM and SMM vocabulary with GSL-specific values, relationships, and configurations. Other tenants would have their own Configured-Model-stratum packages of equivalent kind. The demonstrator domains (Cafe, Suds, Paws, Ears) are similarly Configured-Model-stratum content for their respective tenants.

### 5.5 Demonstrator domain files

Four demonstrator domains validate that the BMM vocabulary generalises across structurally different service businesses ([[concept-cross-domain-validation|J1]]). Each demonstrator is a tenant at the Configured Model stratum, with its content authored in SysML (for the projectable parts) and held canonically in the KG.

| Domain | Files | Character | BMM coverage |
|---|---|---|---|
| [[domain-cafe\|Cafe]] | 9 `.sysml` (4 business model + 5 domain model) | Immediate retail, walk-in, 2-minute cycle | Full model + running application (the Coffee Shop Demonstrator). [[concept-stakeholder-model\|StakeholderModel]]: 6 instantiations |
| [[domain-suds\|Suds]] | 1 `.sysml` | Batch processing, turnaround promises, item tracking | Full BMM + COSHH governance traceability chain. StakeholderModel: 6 instantiations (Session 108) |
| [[domain-paws\|Paws]] | 1 `.sysml` | Appointment-based, customer ≠ service recipient | General vocabulary + StakeholderModel: 7 instantiations |
| [[domain-ears\|Ears]] | — (analytical intake) | Community ear care, clinical pathway | Analytical intake complete (S160–168). Domain description, vertical connection map, coverage map (86.2% Full), ~83 reasoning instance individuals (25/42 reasoning classes), design note. 13-file stack, 66/66 SPARQL |

Under the [[concept-multi-tenancy|multi-tenancy principle (A13)]] — promoted to binding Tier 1 in Session 142 — every domain is a tenant instantiation. Domain identity is structurally expressed across SysML, OWL, and the generation pipeline (Sessions 142–144). [[ontara-architecture-platform-principles|Architecture Principles v5]] §4 holds the multi-tenancy commitment; this paper notes that the modelling-strategy consequence is that demonstrator content is at the Configured Model stratum, not the Metamodel stratum, and that this distinction is what makes new tenants addable without metamodel changes.

### 5.6 Package design principles

Several principles govern the package architecture:

**Foundation as shared vocabulary.** The Foundation package is imported by everything else. Metadata definitions, common types, reusable state machine patterns, generation pipeline configuration, and domain identity infrastructure live here.

**ClinicalEntities separation.** Core domain entities are separated from the pathways that operate on them. Entities are the nouns with lifecycle state machines; pathways are the verbs.

**ServiceDelivery/Platform split.** Mirrors the [[pattern-two-layer-action-flow|two-layer action flow (D6)]]. ServiceDelivery is the domain layer. Platform is the orchestration/infrastructure layer. Connected through allocation relationships.

**Regulation as a first-class package.** Regulatory requirements have their own home in Enterprise::Regulation, with `satisfy` relationships enabling cross-cutting traceability ([[principle-clinical-governance-first-class|A8]]). Under the deontic governance vocabulary (Sessions 121–131), the OWL representation extends this with formal deontic modalities, cross-references to normative instruments, and connections to the reasoning metamodel's constraint hierarchy.

**Authoring-locus discipline under KG-canonical.** New BMM or SMM content goes in the SysML projection if it is structural and behavioural and benefits from SysML's expressiveness. New SMM content goes in a hand-authored OWL module if it is ontological-vocabulary content (governance, reasoning, domain identity) that does not benefit from SysML. Either way, the canonical content lives in the KG; the SysML projection (if it exists) is a view of selected canonical content.


---

## 6. Knowledge, Decision Support, and Reasoning

A distinctive feature of the Ontara modelling strategy is the explicit treatment of knowledge, decision logic, and reasoning as first-class architectural concerns rather than afterthoughts. The reasoning metamodel (Stage 7, Sessions 146–158, formally closed S159) transformed this from a design direction into concrete, implemented vocabulary. Under the strengthened A4, the reasoning metamodel is a cross-cutting SMM extension whose runtime instance content lives at the SRS, queryable in the same vocabulary as everything else there.

### 6.1 The four-category reasoning scheme

The system's reasoning capabilities are organised through the **four-category reasoning scheme** ([[principle-deterministic-over-probabilistic|A6]], reformulated Session 148 as a T1 amendment). Under the strengthened A4, the scheme operates against SRS content: each category's outputs are SRS instance content of the relevant reasoning metamodel classes, written by realising components at the PRS through bindings into the SRS.

**Category 1 — Deterministic rules.** Constraint evaluation, eligibility rules, safety checks. Implemented via constraint evaluators generated from the SysML model. Fully traceable, always auditable. When the system says a patient is not eligible, the exact chain of inference is available — and it is queryable as SRS content. Tau Prolog has been validated for compound deficit reasoning (16/16 tests, <4ms/query).

**Category 2 — Inspectable logic.** DMN-style decision tables for clinical protocol decisions. Deterministic and auditable, but more expressive for multi-factor evaluation. Decision tables are generated from the model and can be read and validated by clinicians. Decision invocations and their outcomes are SRS content; the trail from a decision back through the table back to the configured model element it was applied to back to the metamodel concept is queryable.

**Category 3 — Structured probabilistic.** Bayesian risk assessment, prognostic modelling, predictive analytics — with validated models, explicit assumptions, and full provenance. Given first-class architectural status through the A6 reformulation (Session 148). The reasoning metamodel provides four specialised types: BayesianUpdater, RiskCalculator, PrognosticModel, PredictiveAnalytics — each carrying validation metadata and priors/posteriors typed as Claims for provenance traceability. Under the strengthened A4, these are realising components at the PRS that read SRS content and write Claims back into the SRS; their "structured" character is the property that their priors and posteriors are themselves Claims with provenance, queryable in the same vocabulary as everything else.

**Category 4 — Opaque probabilistic.** ML/LLM-augmented intelligence. Pattern recognition, natural language processing, predictive analytics without full provenance. Powerful but probabilistic, and always advisory rather than authoritative. Under the strengthened A4, opaque-probabilistic outputs that enter the platform must enter as Claims with provenance pointing to the opaque component as the source — the opaqueness is a property of the source, not of the SRS content the platform persists.

The crucial principle is that authoritative clinical decisions follow deterministic, inspectable paths (Categories 1–2); structured probabilistic reasoning (Category 3) is permitted with explicit validation and provenance; opaque probabilistic reasoning (Category 4) informs but never overrides. In coordinate-framework language: deterministic paths through a probabilistically characterised landscape.

### 6.2 The reasoning metamodel and the coordinate framework

The [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning metamodel]] (Stage 7, Sessions 146–152) is a cross-cutting SMM extension (S146-D1) that provides the OWL vocabulary for institutionalised reasoning, preserving the four-level distinction. The vocabulary lives at the Metamodel stratum on the system side; tenant-specific configuration of reasoning content lives at the Configured Model stratum; runtime instance content (Claims, Decisions, EvidenceLines, ConfidenceAssessments, control loop evaluations, safety assessments) lives at the SRS; reasoning realising components run at the PRS and read/write the SRS through bindings.

`ontara-reasoning.ttl` (namespace `ontara-rsn:`) contains 42 classes covering: reasoning contexts (ReasoningContext, ReasoningComponent), goals/obstacles/measures (Goal, Obstacle, Measure), decisions/plans (Decision, Plan, DecisionMode with 4 Cynefin-mapped individuals), a three-way constraint hierarchy (HardConstraint, SoftConstraint, GradedRule with CombinationAlgebra), knowledge sources/heuristics (KnowledgeSource, Heuristic with 6 typed subtypes and HeuristicPack), the SEPIO evidence architecture (Claim, EvidenceLine, EvidenceItem, ConfidenceAssessment, InterpretiveFrame), structured probabilistic types (BayesianUpdater, RiskCalculator, PrognosticModel, PredictiveAnalytics), and STAMP/STPA safety control structures (SafetyConstraint, ControlStructure, ControlLoop, ControlAction, UnsafeControlAction) with FRAM-ready slots (FRAMFunction, VariabilityProfile). 15 named individuals include 3 interpretive frames (stable since Session 46), 4 DecisionMode individuals, 4 CombinationAlgebra individuals, and 4 UnsafeControlActionType individuals.

All classes are BFO-grounded and PROV-O-aligned via the dual subclassing pattern (S147-D4): reasoning classes inherit from both BFO and PROV-O parents without multiple inheritance conflicts. The reasoning metamodel does not implement runtime reasoning engines — those are deployment-time concerns governed by [[concept-authority-zones|authority zones (B29)]] and realised by reasoning realising components at the PRS.

**The three-way constraint hierarchy and the coordinate framework.** Three-way constraint hierarchy (S146-D8, S147-D3): HardConstraints are NormativeRegion boundaries (violation is failure — governance obligations are HardConstraints). SoftConstraints are ScalarField cost surfaces (violation has a measurable cost). GradedRules are ScalarField truth-value surfaces (assertions hold to a degree). This connects to the [[principle-coordinate-framework|coordinate framework (A12)]]: [[concept-goal-seeking-computation|goal-seeking computation (L9)]] is pathfinding through constrained coordinate space.

Under the strengthened A4 with A12 promoted to binding Tier 1 ([[ontara-architecture-platform-principles|Architecture Principles v5]] §5.1), the SRS *is* the coordinate space made queryable. Each snapshot is a position in coordinate space; trajectories are sequences of snapshots; the Region taxonomy (StaticBoundary, GoalRegion, NormativeRegion, ProbabilityDistribution, ScalarField, ClassificationRegion, FormalisationFrontier) catalogues the kinds of region expressible as queries against snapshots; the constraint geometry maps the three-way constraint hierarchy onto coordinate-space structures. The modelling-strategy consequence is that the reasoning metamodel and the coordinate framework are not two separate bodies of structural commitment to be implemented in parallel — they are one body, with the reasoning metamodel providing the OWL vocabulary and the coordinate framework providing the geometric interpretation, both projected into operational reality by the SRS.

**The constraint hierarchy as architectural spine (S207 D28).** Stage 9 surface architecture work (S207) established that the same three-way constraint hierarchy maps to three distinct UI affordance types at multiple bands of the sophistication gradient — empirical confirmation that the constraint hierarchy is an architectural spine running from reasoning (where constraints are declared and evaluated) through the experience-API layer (where evaluator outputs are shaped into band-appropriate contracts) to the surface (where they render as band-appropriate affordances). Architecture Principles v5 §7.3 holds the full treatment; PMS v5 references it. The modelling-strategy implication is that the reasoning metamodel is not a reasoning-side-only commitment — it is a commitment that propagates through to the surface, with the same canonical evaluator outputs surfacing consistently at every band where they surface at all. The constraint hierarchy is the second empirical anchor for [[principle-unity-principle|A11]] (the first being the comprehension–reasoning convergence of Session 147).

**Earlier research directions** — semiring soft-constraints, fuzzy MCDM, and Probabilistic Soft Logic — remain relevant as candidate runtime formalisms for the weight model. See [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge discussion]]. Under the strengthened A4, these are candidate realising-component architectures for reasoning subsystems at the PRS; the reasoning metamodel at the Metamodel stratum is the vocabulary they would express their content in.

### 6.3 Logic programming

There is a deliberate decision to preserve an explicit architectural space for logic programming. Logic programming (Prolog-style inference, DMN, constraint solving) provides deterministic, auditable, reproducible reasoning with a complete explanation trace. This is fundamentally different from what LLMs provide and is essential for regulated clinical decision support.

The SysML model defines logic rules as constraints and decision tables as structured value types. The generation pipeline targets constraint evaluators and decision table evaluators at the realising-component level. The metadata library in Foundation provides annotations that the generators use to route each piece of reasoning to the appropriate evaluation tier.

Under the strengthened A4, the runtime evaluation of constraints and decisions produces SRS content (constraint evaluation results, decision invocation records) that is queryable in the same vocabulary as the constraints and decisions themselves. A query that asks "show me all the constraint violations for this patient over the last six months" is a SPARQL query against the SRS, parameterised by the patient identifier and the time range.

### 6.4 The five-layer SystemStateAssessment, reframed against the SRS

The Knowledge layer architecture defines a five-layer assessment pattern. v4.1 stated this as an architectural pattern in its own right; v5 reframes it as **the natural behaviour of the SRS when queried across epistemic tags**. This reframing is one of the substantive new content items v5 must add (per the W-049 PMS v5 scoping note §6.4), because the strengthened A4 makes the five layers structurally trivial in a way that v4.1's framing did not yet recognise.

| Layer | Content | Strengthened A4 reframing |
|---|---|---|
| 1. **Structural** | System manifest — what the system contains | Metamodel stratum content. Queryable from the canonical KG. The system manifest is a generated artefact (`gen_system_manifest.py`) that materialises a particular view of canonical Metamodel-stratum content for a particular consumer; the canonical answer to "what does the system contain" is in the KG |
| 2. **Operational** | Query runtime state — Temporal, CDR, platform | SRS content tagged `current/actual`. BR (business-side current snapshots) and SR (system-side current snapshots, including workflow execution records). A SPARQL query against the SRS named graphs holding current-tagged content |
| 3. **Goal-state** | Project from requirements, constraints, defined outcomes | SRS content tagged `goal`. Goal snapshots are populated by reasoning realising components reading configured model content (requirements, constraints, defined outcomes) and producing snapshots of what the platform's content predicts the state should be. Same query interface as Layer 2 — different epistemic tag |
| 4. **Gap analysis** | Compare operational vs goal-state, produce Deficits | Generic snapshot diffing across epistemic tags. Architecture Principles v5 §3.5 makes this explicit: "Because snapshots are structurally homogeneous across epistemic characters, comparison machinery — gap analysis, counterfactual divergence, projection deviation — is generic snapshot diffing". A reasoning realising component reads BR (current) and the goal-tagged snapshot, computes the difference, and writes Deficits back into the SRS |
| 5. **Remediation** | Classify as automatic, recommended, or advisory | Guidance reports — first-class SRS content (Architecture Principles v5 §5.7.1). A reasoning realising component reads the Deficits, produces guidance reports tagged with the appropriate remediation category, and writes them back into the SRS where consumers (the comprehension architecture, the operator surface) can read them |

The default for any new deficit is "Recommended" — the system never takes automatic clinical action unless the model explicitly permits it. Under the strengthened A4, this is enforced by binding metadata: the realising component handling the deficit is bound to a write into the SRS (the recommendation), not to a side-effecting action against the real world. Promotion of a recommendation to an automatic action is a binding configuration change (the realising component's bindings are reconfigured to side-effect against real-world endpoints), not a code change in the realising component itself.

The reframing has a substantive consequence for how the five-layer pattern is discussed in design work: the layers are not five separate capabilities the platform implements in parallel; they are five queries against the SRS, with the heavier layers (3, 4, 5) requiring reasoning realising components to populate the SRS with the relevant snapshots and reports. The Stage 8 portal exercises layers 1, 2, 4, and 5 in the simulation infrastructure (S183–S185 promotion/demotion operations); a future expansion will exercise layer 3 fully when goal-state snapshots are populated for production tenants.

### 6.5 Outcome tracking and learning cycles

The system records structured outcomes: not just that a patient was treated, but the specific regimen, monitoring results at defined intervals, whether clinical targets were achieved, and any adverse events. Over time this builds a dataset that informs pathway refinement. Under the strengthened A4, structured outcomes are SRS content tagged `current/actual` (the recorded observations) and `historical` (the longitudinal record); learning cycles are reasoning realising components that read the historical content, produce hypothetical or projected snapshots representing proposed pathway refinements, and surface them as guidance reports for clinical governance review.

The learning cycle is: capture structured outcomes → analyse patterns → propose pathway refinement → clinical governance review → update model → regenerate. The model is the mechanism for both capturing and enacting the learning. Under the strengthened A4, the cycle is unified: the analytical activity reads SRS content (operational and historical snapshots), produces SRS content (the proposed refinement as a hypothetical or projected snapshot, with provenance pointing back to the analysis), surfaces the proposal to clinical governance through the comprehension architecture, and on approval triggers a configured-model-stratum update. The boundary between analytical activity and authored content is held by the strata and by the discipline that authored content is hand-edited at the upper strata.

### 6.6 Predictive and adaptive behaviour

Predictive capabilities (trajectory-based dose adjustment suggestions, capacity pressure forecasting) sit at the outer edge of what the model directly generates. The model's contribution is defining the data structures and event streams that feed predictive analytics, and defining the action points where predictions are surfaced to clinicians or operations. The crucial architectural principle is that adaptive features suggest and inform; they do not autonomously alter pathways or override gates. Any pathway change goes through the learning cycle's governance process and results in a model update.

Under the strengthened A4, predictive and adaptive realising components produce SRS content tagged `projected` (forward predictions) or as guidance reports (suggested actions). They do not write to Configured Model stratum content (prohibition 1 of Architecture Principles v5 §3.4). Promotion of a prediction to an enacted change is a configured-model-stratum update activity (human or human-in-the-loop), not a runtime activity. This is the modelling-strategy expression of the [[principle-discipline-as-load-bearing-structure|A9]] extension committed in Architecture Principles v5 §1.3 — the platform's adaptability is structurally bounded; what looks like learning at the surface is structurally a change to the canonical model content authored under governance.


---

## 7. Modelling Value Across the Business

The value proposition of modelling varies across different parts of the business. This section categorises areas by the strength of the model-to-execution pipeline. Under the strengthened A4, "model-to-execution" means model-to-realising-component: the model is the canonical content at the upper strata; execution is what the realising components at the PRS do when they are bound to that content.

### 7.1 Strong model-to-realising-component value

These are areas where the Coffee Shop Demonstrator patterns apply directly and the modelling investment generates realising-component code, governance documentation, ontological classification, or all three.

**Clinical pathway orchestration.** Each clinical pathway maps to a SysML v2 action flow at the domain layer (Configured Model stratum content), generates a Temporal workflow at the orchestration layer (a realising component at the PRS), and produces visual pathway diagrams and compliance audit tables for governance. Runtime workflow execution records are SRS content.

**Entity lifecycle management.** Every entity with state (patient, episode, consultation, prescription, referral, lab result, booking, payment, support ticket) can be modelled as a SysML state machine (Configured Model stratum content), enforced by XState at runtime (a realising component), and audited. Invalid transitions are rejected regardless of what application code requests. Lifecycle state changes are SRS content.

**Service contracts and interfaces.** The interfaces between platform subsystems can be modelled as SysML v2 ports and generate TypeScript types or API schemas. The generated types are realising-component artefacts; the canonical interface definitions are Configured Model stratum content.

**Requirements and constraints traceability.** Clinical governance requirements, CQC obligations, data protection constraints, and safeguarding policies are modelled as SysML requirements with `satisfy`/`verify` relationships to system elements, enabling cross-cutting compliance queries. This is the [[principle-clinical-governance-first-class|satisfy traceability chain (A8)]]. Under the deontic governance vocabulary (Sessions 121–131), the OWL representation extends this with formal deontic modalities, cross-references to normative instruments, and connections to the reasoning metamodel's constraint hierarchy. Constraint evaluations are SRS content; their provenance traces back through the configured model to the metamodel concepts they instantiate.

**Ontological classification.** The `@BfoType` annotations on all 34 BMM elements (Session 99) feed the OWL pipeline, producing correctly parented OWL classes in the knowledge graph at Metamodel-stratum granularity. This enables semantic querying, consistency checking, and cross-domain reasoning that SysML alone cannot provide.

**Business meta model coverage.** The 36 BMM `part def`s describe the structural anatomy of any service business. The generation pipeline extracts these into both the Ontara Console (Coverage Matrix, Component Catalogue, Glossary) and the knowledge graph (34 OWL classes, 14 object properties, 96 reified weighted relationship individuals).

**Comprehension metadata.** The annotation system is generated into both the console and the knowledge graph, providing self-describing content for every model element across both representations. Under the strengthened A4, the canonical comprehension content lives in the KG and the console reads it through the model-introspection JSON (currently a derived artefact from the SysML projection; future direct SPARQL access is a Stage 5 Phase 4 candidate).

### 7.2 Valuable modelling with partial generation

These are areas where the model provides significant structural design value and some generation is feasible, but the model does not generate complete realising components.

**Business operations processes.** Processes such as contract approval, invoice lifecycle, and complaint handling are structurally identical to clinical pathways and could drive Temporal workflows. The model defines the process; some realising-component generation is feasible; but the complete realising component includes integrations with tools like Xero that the model does not replace.

**Forms and questionnaires.** The structure of clinical forms (fields, validation rules, conditional logic, data mappings) is highly amenable to SysML modelling. Generation of form definitions from the model is feasible and worth pursuing.

**Clinical decision support and logic programming.** Decision rules, eligibility criteria, monitoring protocols, and constraint evaluation can be modelled as SysML constraints and decision tables, with generation targeting realising components for [[principle-deterministic-over-probabilistic|deterministic, auditable reasoning (A6)]]. Two generators already produce TypeScript evaluators from the model.

**Governance framework formalisation.** The deontic governance vocabulary demonstrates that regulatory requirements can be formalised in OWL with rich semantic structure. The CQC Regulation 12 MVP (21 individuals, Session 131) is a concrete example. Additional governance frameworks can be formalised incrementally as hand-authored OWL content at the Metamodel stratum.

### 7.3 Architectural documentation value

These are areas where the model primarily serves as structural design documentation, providing the connective tissue for cross-cutting queries.

**Organisational structure.** Roles, teams, governance structures, and responsibility allocations are modelled as parts with allocated responsibilities, but do not generate realising-component code.

**Third-party integrations.** The model defines the boundary contract for each external service, regardless of whether the integration is built or bought. Under the strengthened A4, third-party integrations are realising components at the PRS with bindings into the SRS; the boundary contract is canonical content at the Metamodel stratum.

**Marketing, community, and content.** Processes such as content approval or community onboarding can be modelled, but much of this domain is inherently creative and ad-hoc. The model defines touchpoints and data flows.

**Brand, design, and tone of voice.** Not system-modellable in any meaningful sense. The model can define where brand assets are used and what content types exist, but not what they look like.

---

## 8. The Annotation and Metadata System

SysML v2's `metadata def` mechanism is the backbone of both the generation pipeline and the comprehension architecture. The annotations are defined in `Foundation::MetadataLibrary` and applied to model elements using `@` syntax. The generation pipeline extracts them; the Ontara Console renders them; the OWL pipeline uses them for ontological classification at the Formalism Boundary stratum.

Under the strengthened A4, the annotation system is content at the Metamodel stratum (when applied to metamodel elements) or at the Configured Model stratum (when applied to tenant configuration content). The annotations participate in the canonical content via the OWL pipeline; the SysML projection is the authoring surface where they are written.

### 8.1 Generation annotations

| Annotation | Purpose | Used by |
|---|---|---|
| `@CatalogueTag` | Multi-axis classification — BMM concern, meta model layer, General/Tailored status, domain applicability | Component Catalogue grouping; Coverage Matrix |
| `@UserFacing` | `friendlyName` and `shortDescription` for any element | Glossary; all console views |

### 8.2 Comprehension annotations

| Annotation | Purpose | Coverage |
|---|---|---|
| `@PurposiveDescription` | Authored purposive description — "why does this exist and what does it do for your service?" | 34/34 BMM elements; 20/20 architectural sections |
| `@Comprehension` | Traversal schema for dynamically derived structural self-knowledge — four boolean flags controlling which structural features to surface | 34/34 BMM elements |
| `@WeightedRelationship` | Directed, non-commutative strength of interaction between elements — strong, moderate, or weak | 96 relationships across 33 weighted elements |
| `@ArchitecturalLocation` | Locates an element within the [[concept-dual-stack-architecture\|dual-stack architecture]] — stack, group, position, formalism, implementation status. Under the strengthened A4, the dual-stack is itself a consequence of A4 at the Metamodel and Configured Model strata; the annotation continues to carry the same content with the strengthened framing as its structural background | 20/20 architectural sections (Session 87) |
| `@BfoType` | BFO 2020 category, mid-level ontology parent, and classification justification — the SysML-side input to the OWL pipeline. Lives at the Formalism Boundary stratum as a crossing point from SysML into canonical OWL | 34/34 BMM elements (Session 99) |

### 8.3 Design principles for annotations

**Model-native.** All annotations are SysML v2 metadata definitions, not external configuration. They participate in the model's type system and survive into the canonical OWL output.

**Dual-pipeline friendly.** Each annotation has clear consumers: `gen_model_introspection.py` extracts all annotation types and produces `model-introspection.json` for the console; `gen_owl_pipeline.py` reads `@BfoType` and `@WeightedRelationship` to produce correctly classified OWL classes and reified relationship individuals.

**Authored vs intrinsic.** `@PurposiveDescription` is human-authored content (Register 1 of the comprehension architecture). `@Comprehension` is a traversal schema for dynamically derived content (Register 2). The [[principle-intrinsic-self-knowledge|A10]] test determines which category any given content belongs to; under the strengthened A4 the boundary between authored and intrinsic is the boundary between the upper strata and the SRS (§4.2).

**Extensible.** New metadata definitions can be added to the MetadataLibrary as new architectural needs emerge. The generation pipelines discover annotations by type; new types are automatically picked up.

### 8.4 The doc block convention under the six-stratum frame

Every `part def` or `metadata def` in the SysML projection carries a doc block identifying its meta model affiliation: `/* business meta model concept */` or `/* system meta model concept */`. This is a standing convention (N1 in the [[ontara-ref-master-register|master register]]) that ensures the [[principle-two-meta-model-distinction|two meta model distinction (A4)]] is maintained at the source level.

Under the strengthened A4, the doc block convention is reframed slightly: it records the **stratum-and-side locus** of the element, of which the BMM/SMM affiliation is the most common case (Metamodel stratum, business or system side). When SysML is used to project Configured Model stratum content (as it is for the demonstrator domains and for GenderSense), the doc block records the configured-model affiliation explicitly. The discipline is that every element's locus in the strengthened A4 grid is recorded at the source level, by the most natural mechanism the formalism supports — the doc block convention for SysML-projected content, the OWL class IRI structure for hand-authored OWL content (where the namespace prefix carries the affiliation).

The category errors retired by Architecture Principles v5 §3.4 prohibitions are made impossible at the source level by this discipline: a doc block that identifies an element as Metamodel-stratum business-side content makes a runtime-state claim about that element a category error visible in the source.

---

## 9. Structural Principles for the Model

### 9.1 Concentric rings of modelling rigour

The model is organised in concentric rings of decreasing modelling rigour. Under the strengthened A4, the rings remain a useful organising metaphor for *modelling investment*, but the rings are not strata — modelling at every ring operates across the same six-stratum frame, with the rings determining how much of the metamodel and configured-model content for a given area is elaborated.

**Inner ring — Clinical pathway system.** Pathway models, entity lifecycles, governance outputs. Full model-driven realising-component generation. Maximum rigour. Heavy investment at the Metamodel and Configured Model strata; rich SRS content; mature realising components at the PRS.

**Middle ring — Supporting infrastructure.** Service interfaces, data models, forms, booking, patient portal, messaging. Modelled for structural clarity and interface generation, with varying degrees of code generation. Lighter elaboration at the Configured Model stratum; SRS content where the realising component populates it; realising components at the PRS that exist but may not be fully generated from the model.

**Outer ring — Business context.** Organisational structure, back office processes, marketing, partnerships. Modelled at a higher level of abstraction for traceability and architectural documentation. Mostly Metamodel-stratum content with light Configured Model elaboration; SRS content limited to what is needed for traceability; realising components are typically third-party tools with model-defined boundary contracts.

All three rings live in the same model and can reference each other. The inner ring receives the most modelling investment; the outer ring accepts that the model is a useful map rather than the territory itself.

### 9.2 Co-evolution of model and tooling

The [[concept-co-evolution|co-evolution principle (J2)]] is Tier 1 governing: no modelling without the tool that makes it legible; no tool without model content that exercises it. Under the strengthened A4, J2 has a stratum-aware reading: model content at the Metamodel and Configured Model strata earns its keep through realising-component or comprehension-architecture support that consumes it; realising-component or comprehension-architecture work earns its keep through the model content it exercises.

In practice this means that model extensions and Ontara Console features are built together. When the comprehension annotations were added to the model, the Glossary view was extended to render them. When the weighted relationships were populated, the 3D WebGL graph was built to visualise them. When the BFO classifications were applied, BFO category badges appeared in the Glossary and Component Catalogue, and the Ontology view was built to render the hierarchy.

This principle prevents two failure modes: a model that grows richer but remains invisible (no tooling to surface it), and tooling that grows more sophisticated but has nothing to show (no model content to exercise it).

### 9.3 General and Tailored decomposition

Within each metamodel (BMM and SMM), components are classified as General (sector-agnostic) or Tailored (sector-specific) per [[concept-general-tailored-decomposition|B11]]. The Paws demonstrator was deliberately built using exclusively General BMM vocabulary to validate that the General tier is sufficient for a simple service business. The Suds demonstrator exercises both General vocabulary and Tailored governance (COSHH requirements). GSL, as a sector-regulated healthcare service, will exercise the full Tailored vocabulary.

The General/Tailored distinction is *within* the Metamodel stratum, not a stratum boundary. Both kinds of content are metamodel content; both are canonical in the Knowledge Graph; both can be projected into SysML where appropriate. The architectural diagrams that show two horizontal sub-bands within the Metamodel row (General above, Tailored below) are a useful visualisation, not a stratum-level distinction. The detailed treatment of General versus Tailored — including the criteria for promoting content between the two and the way Tailored extensions hook into the General core — belongs in [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]] rather than here, tracked as [[ontara-ref-work-item-tracker|OW-87]].

### 9.4 Cross-domain validation

Every metamodel concept and pattern should validate in at least two domains ([[concept-cross-domain-validation|J1]]). Four demonstrator domains validate across structurally different businesses. The three-domain validation threshold has been met for BMM vocabulary. The reasoning metamodel (Stage 7 Phase 1) achieved cross-domain validation at 24/24 PASS against Cafe and Suds. SMM validation beyond the reasoning metamodel currently relies primarily on the Cafe demonstrator. The Stage 9 Surface Families work (S199, S206, S207) further validated the surface-side vocabulary against three structurally different demonstrators (Cafe immediate retail, Paws appointment-based, Suds batch processing).

### 9.5 Avoiding over-modelling

Not every area benefits from formal modelling to the same depth. The guiding principle is that the model should earn its keep ([[concept-model-earns-its-keep|J4]]) by either generating something (realising-component code, documentation, ontology, diagrams) or by making a non-obvious structural relationship visible. If modelling something merely restates the obvious, that is a signal to stop. The package structure permits elaboration but does not require it.

### 9.6 Non-constraining architecture

Architectural decisions should not foreclose future development paths ([[concept-non-constraining|J3]]). Clean abstractions, loose coupling, and discoverable structure mean that a decision made today can be revisited without cascading refactoring. The [[concept-design-decision-lifecycle|design decision lifecycle (J12)]] — freedom → experimentation → discovered convention → opinionated configuration → revisable — deliberately preserves freedom at early stages.

A specific application of J3 is the **DPA-informed writing discipline ([[ontara-ref-work-item-tracker|OW-83]])** held throughout v5: no paragraph in this paper, and no commitment made in this refresh, forecloses the Domain Portability Architecture. Tenant content boundaries are kept clean; cross-tenant references are explicit; per-tenant content does not hard-couple to platform-instance-specific identifiers in ways that would break under round-trip. The DPA itself is [[ontara-ref-work-item-tracker|W-053]] — a future workstream, not a v5 design activity.

### 9.7 State placement discipline (J15)

Surface-side state placement discipline (J15) — band-appropriate content lives in band-appropriate loci — is the surface-side application of [[principle-unity-principle|A11]]. The same canonical truth (a constraint violation, a workflow status, an audit evidence record) surfaces at multiple bands through different contracts, but the canonical truth itself lives once in the SRS. PMS v5 acknowledges J15; the substantive treatment lives in [[ontara-architecture-platform-principles|Architecture Principles v5]] §5.9 and the Stage 9 surface architecture papers ([[ontara-discussion-surface-architecture-and-bindings-2026-04-12|S198]], [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199]], S207).

---

## 10. The Generation Pipeline

### 10.1 Model-to-realising-component generators

Eight operational generators produce artefacts from the SysML projection. All SysML-reading generators share `sysml_parser.py` (Session 104) as a common parser module. Under the strengthened A4, these generators read Metamodel-stratum and Configured-Model-stratum content from the SysML projection and produce realising-component artefacts (TypeScript types, evaluators, Mermaid diagrams) and console-consumed JSON.

| Generator | Output | Consumer |
|---|---|---|
| `gen_model_introspection.py` | `model-introspection.json` — extracts all metadata annotations including `@BfoType` (Session 103) and `architecturalSections` (20 entries) | Ontara Console (all 13 views) |
| `gen_owl_pipeline.py` | SysML → OWL/Turtle via declarative mapping rules. Five outputs: `ontara-bmm.ttl` (34 classes), `ontara-bmm-properties.ttl` (14 object properties), `ontara-bmm-weights.ttl` (96 reified individuals, 702 triples), `ontara-correspondence.ttl` (1,378 triples), `mapping-ir.json`. Under KG-canonical, this generator materialises the canonical OWL form of SysML-projectable content | Knowledge graph (canonical store) |
| `gen_concept_graph.py` | 6 Mermaid views + Obsidian concept graph notes | Knowledge base navigation |
| `gen_package_hierarchy.py` | Package structure visualisation | Console Package Navigator |
| `gen_system_manifest.py` | `system-manifest.json` | Self-knowledge (F1 Layer 1 / Layer 1 of the five-layer SystemStateAssessment per §6.4) |
| `gen_constraint_evaluator.py` | `constraint-evaluators.ts`, `constraint-specs.ts` | Runtime constraint evaluation realising components (A6 Category 1) |
| `gen_decision_table_evaluator.py` | `decision-table-evaluators.ts` | Runtime decision table realising components (A6 Category 2) |
| `projection_engine.py` | Financial scenario comparison | Business planning |

### 10.2 Knowledge graph tooling

Five scripts manage the knowledge graph infrastructure:

| Script | Purpose |
|---|---|
| `setup_graphdb.py` | GraphDB repository creation and ontology stack loading (BFO 2020, CCO, IAO) |
| `validate_kg.py` | SPARQL validation suite — 66 queries in 12 groups |
| `reason_kg.py` | Robot + HermiT full OWL 2 DL consistency checking. 13-file ontology stack |
| `diff_kg.py` | Round-trip diff engine — 288 semantic units, authority-zone-aware. Under KG-canonical, the diff verifies projection fidelity (the SysML projection is a faithful view of the canonical), not canonical derivation |
| `kg_utils.py` | Shared KG utilities — GraphDB connection, SPARQL execution, IRI shortening |

### 10.3 Two-phase architecture

The generation pipeline follows a two-phase design: Phase 1 generators are model-aware and framework-agnostic (read SysML, produce domain artefacts and manifest). Phase 2 generators are model-agnostic and framework-aware (read manifest and domain artefacts, produce wiring for the target framework). The phase separation means the choice of execution framework — the realising-component implementation — can change without rewriting the domain generators.

### 10.4 The four-layer generated code architecture

| Layer | Content | Editability | Strengthened A4 locus |
|---|---|---|---|
| 1. SysML projection | Source of truth for projectable content | Hand-maintained | Metamodel and Configured Model strata, projectable parts |
| 2. Domain artefacts | Generated types, state machines, constraints | Never hand-edited; freely regenerable | Realising-component artefacts at the PRS, generated from Metamodel/Configured-Model content |
| 3. Integration glue | Generated wiring for target framework | Never hand-edited; freely regenerable | Realising-component glue at the PRS |
| 4. Application code | Hand-written, imports from L2/L3 | Never overwritten by generators | Realising-component application code at the PRS |

The strict layering ensures regeneration safety. Generated files carry `DO NOT EDIT` headers with timestamp and source reference (N5).

### 10.5 Generators fail loudly, degrade gracefully

Unparseable SysML expressions emit TODO placeholders in the generated output, never broken code (N6). This means a partial model produces partial but valid output. The generators serve as executable specifications for future migration to the Syside Automator API, which will provide semantic model access replacing the current regex-based parsers.

---

## 11. Mapping Legacy Artefacts

The 2018 SHC/MedMind work and other legacy projects provide a significant head start. Each diagram type maps to SysML v2 (the engineering projection) as follows. Under the strengthened A4, legacy artefacts map to SysML-projectable content at the Metamodel and Configured Model strata; the canonical OWL representation is produced by the OWL pipeline from the SysML projection.

### 11.1 Use case diagrams

SysML v2 has `use case` as a language element with `include` and `extend` relationships. The semantic content maps directly. The recommended approach is to model use cases in SysML v2 for semantic traceability while accepting that presentation-quality use case diagrams may be produced separately for communication purposes.

### 11.2 BPMN processes

This is the most significant and most valuable transition. BPMN process maps map almost directly to SysML v2 action flows at the domain layer. Activities become action nodes. Swim lanes become partitions or allocations to structural parts. Data objects become typed items flowing through the action flow, each with its own lifecycle state machine.

What SysML v2 gains over BPMN is integration: data objects are typed and traceable, preconditions reference constraints on entity state, constraints trace to requirements, and requirements are verifiable by runtime checks. What is lost is the richness of the BPMN event model. The Coffee Shop Demonstrator handles this pragmatically through orchestration-layer Temporal metadata annotations.

### 11.3 Top-level process maps

The five-phase patient journey model (Acquisition, Registration, Assessment, Treatment, Follow Up) maps to a top-level SysML v2 action flow in the PatientJourney package. This provides the structural skeleton that detailed pathways elaborate.

### 11.4 Technology component diagrams

The UML class diagram mapping technology components maps to a SysML v2 structural model using part definitions with metadata annotations. Crucially, these structural parts can be formally allocated to action flow steps, enabling impact analysis.

### 11.5 Gathering and synthesising legacy material

There is a fair amount of legacy business analytics material from prior projects and businesses beyond MedMind. Similarities and evolution across these projects suggest value in gathering the various artefacts and synthesising structural patterns, entity catalogues, process inventories, and recurring architectural themes.


---

## 12. Current State and Forward Direction

### 12.1 What has been built

| Area | Status |
|---|---|
| **SysML projection** | 12 top-level packages, ~74 packages total, 12 core `.sysml` files. 36 BMM `part def`s + 2 `requirement def`s + `DomainIdentity`/`DomainConfiguration` with full annotation stacks including `@BfoType`. 1 SMM `part def` ([[concept-architectural-section\|ArchitecturalSection]]), 20 `part` usages, 3 enums, 1 `metadata def`. ~74 packages |
| **PatternCatalogue** | 22 validated patterns, 8 principles, 43 typed `ref` relationships, 33 domain instantiations |
| **Comprehension metadata** | 34/34 `@UserFacing`, 34/34 `@PurposiveDescription`, 34/34 `@Comprehension`, 34/34 `@BfoType`, 96 `@WeightedRelationship` (BMM). 20/20 `@UserFacing`, 20/20 `@PurposiveDescription`, 20/20 `@ArchitecturalLocation` (architectural sections). 12 typed cross-refs |
| **Knowledge graph (canonical)** | 13-file ontology stack. 66-query SPARQL suite (12 groups). HermiT CONSISTENT. Round-trip diff: 288 semantic units, 0 discrepancies. Three layers of automated QA |
| **Hand-authored canonical OWL modules** | Governance vocabulary (19 classes, Sessions 121–126), CQC Reg 12 (21 individuals, Session 131), domain identity (2 classes, Session 144), reasoning metamodel (42 classes, Sessions 150–157), PROV-O core subset (73 triples, Session 150), Ears reasoning instances (~83 individuals, Session 166) |
| **Pipeline-produced canonical OWL** | BMM classes (34), object properties (14), weighted relationship individuals (96, 702 triples), correspondence triples (1,378) |
| **Ontara Console** | 13 views including Reasoning Vocabulary Explorer (S158: 42 classes in 7 modules, 15 named individuals, 50 properties, 32 cross-module axioms). Global navigation context (I19, 6 routes registered). Role under strengthened A4: band 6/7 architect-analyst surface (partial) |
| **Ontara Portal** | Stage 8 closed S185. 10-module catalogue, two intersecting lifecycle state machines, BMM-concern-structured domain context, simulation, comparative analytics, progressive governance with 20 typed constraints (8 hard, 6 soft, 6 graded), promotion/demotion path, lifecycle governance guards. Role under strengthened A4: band 5 surface. Stage 9 substrate replacement (SQLite → KG-resident BR/SR through bindings) is OW-48 |
| **Coffee Shop application** | 9 pages, 19 API routes, Temporal workflows, XState v5, EHRbase CDR, PostgreSQL. A mixed-band legacy surface across bands 2–4 (OW-57 — to be reframed as band-clean surfaces in Stage 9) |
| **Generation pipeline** | 8 model-to-realising-component generators + 5 KG tooling scripts. Shared `sysml_parser.py` and `kg_utils.py` |
| **Demonstrator domains** | Cafe (full + running app), Suds (BMM + COSHH; cross-domain walk-through S207), Paws (General vocabulary; cross-domain walk-through S206), Ears (analytical intake complete S160–168) |
| **Master register** | ~220+ concepts across 16 sections (A–P), four tiers. B40–B44, J15, D28, D29 added at S207 (partial W-043) |
| **Stage 9 architectural foundation** | Four foundation papers complete (S192, S195, S196, S197, S198/S200, S199). Cross-domain walk-throughs at Paws (S206) and Suds (S207). Constraint-hierarchy-as-architectural-spine finding (D28, S207) — second empirical anchor for A11 |
| **Strengthened A4 and Architecture Principles v5** | v5 complete S210–S211. Six strata, two sides, ten architectural loci. KG-canonical binding (B22). A12 binding T1. SRS and PRS strata named. Surface architecture vocabulary in §5.9. §7.3 constraint hierarchy as architectural spine. Five-principle unification Test 1 passed |
| **Platform Modelling Strategy v5** | **This paper, Session 216.** Test 2 of five-principle unification passed |

### 12.2 Forward direction

The forward direction is significantly more concrete than v4.1's was — the strengthened A4 frames many of the questions precisely, and Stage 9 design work has produced substantial scoping for what comes next. Each of the items below is a workstream in its own right; their relative priorities and sequencing are governance decisions tracked in [[ontara-ref-work-item-tracker|the work item tracker]] rather than in this paper.

**Foundations papers refresh completion (W-049 remainder).** [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]] v4 is the third foundations paper. SBMM v4 will hold the General/Tailored detailed treatment that PMS v5 has explicitly deferred ([[ontara-ref-work-item-tracker|OW-87]]). Test 3 of the five-principle unification hypothesis runs as SBMM v4 is drafted. SBMM v4 is expected to lean on Architecture Principles v5 §5.5 (Metamodel stratum General/Tailored sub-structuring) more heavily than Tests 1 or 2 did.

**Glossary build (W-052).** A flat alphabetical standing reference document at `01 —— START HERE ——/ontara-ref-glossary.md`, covering every acronym, project-specific term of art, every concept name, and every internal phrase. Initial build is substantial (~100–200 terms). Maintenance is ongoing — new entries added at session close as new vocabulary is introduced. The proto-glossary in the [[WORKSHOP-s208-a4-reformulation-INTEGRATED|S208 integrated workshop document]] §9 is the seed.

**Domain Portability Architecture (W-053).** The DPA is the design of the portable persistence format and reciprocal import mechanism for tenant content. Requirements are framed in Architecture Principles v5 §4.1 and the integrated workshop document §7. Not a v5 design activity but a substantive workstream in its own right; required before cross-tenant analytical content and platform-global content can be realised in the SRS.

**Stage 9 plan production.** Once the foundations are in place (Architecture Principles v5 complete; PMS v5 complete; SBMM v4 complete), Stage 9 plan production can begin. The seven open questions from [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] (Q1–Q7) are the core outstanding design questions, framed precisely by the strengthened A4 but not resolved by it. Notably:

- **Q1 — KG role expansion to runtime instance substrate.** Engineering questions of write throughput, transaction semantics, named graph organisation, query load, round-trip diff relationship ([[ontara-ref-work-item-tracker|OW-39]]).
- **Q2 — Horizontal mapping implementation.** The rules and machinery that keep both sides synchronised as state changes propagate ([[ontara-ref-work-item-tracker|OW-33]]).
- **Q3 — Module-derived-from-model boundary.** What does S192-D7 mean at the data level ([[ontara-ref-work-item-tracker|OW-32]]).
- **Q4 — Customer kiosk scope.** Band 1 surface in a band 1 surface family.
- **Q5 — Connection sequence and acceptance criteria** ([[ontara-ref-work-item-tracker|OW-35]]).
- **Q6 — Console integration.** The binding registry as a console view candidate ([[ontara-ref-work-item-tracker|OW-40]]).
- **Q7 — Portal-to-console traceability.** How band 5 and band 6 surfaces coordinate across their shared substrate ([[ontara-ref-work-item-tracker|OW-49]]).

**Stage 8 portal reframing (OW-48).** Substrate replacement — SQLite → KG-resident BR/SR through bindings. Substantial enough to count as a rebuild rather than a reframing in places. A Stage 9 concern, not a Stage 8 retrospective.

**Experience-API / BFF layer design (OW-56).** The architectural addition between the SRS and band-specific surfaces — currently absent from Ontara. Contract definition language, deployment topology, composition style, observability are all open decisions. Principal Stage 9 design concern.

**Cafe demonstrator frontend reframing (OW-57).** The 19 API routes and 9 pages embed band-mixed assumptions that need untangling, not refactoring in place. Implementation work for Stage 9.

**Bounded agent implementation.** The [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|S198 architect-analyst workspace paper]] establishes bounded agents as the design pattern for AI mediation. Implementation requires the experience-API layer, the binding metadata vocabulary, the capability matrix, and the action class computation logic. Cross-cutting design decision for agent identity, instantiation model, and audit ([[ontara-ref-work-item-tracker|OW-51]]).

**Counterfactual analysis as a first-class epistemic mode (E030).** The architectural realisation is straightforward under the strengthened A4 — counterfactuals are SRS content with the `counterfactual` epistemic tag, produced by reasoning realising components anchored on historical snapshots. The implementation work is in the reasoning-side realising components and in the comprehension surfaces that surface counterfactual content to operators.

**Hardware peripheral integration (OW-74).** Weight scales (Suds), payment terminals (Cafe), barcode scanners, medical devices (GSL), signature pads. The experience-API layer's contract shapes must accommodate these as input modalities. Stage 9 design concern.

**GSL clinical domain intake.** The next clinical domain after Ears, at production complexity. Will test the structured probabilistic reasoning types ([[ontara-ref-work-item-tracker|OW-05]]), the BMM→reasoning formalisation threshold ([[ontara-ref-work-item-tracker|OW-07]]), and the meta-constraint pattern generality ([[ontara-ref-work-item-tracker|OW-06]]). The most important workstream for production value.

**SMM elaboration.** Promoting the implicit SMM concepts distributed across Foundation, Knowledge, ServiceDelivery, Platform, and Operations into a named, navigable package structure (gap O2 in the master register). A long-standing item that becomes more pressing as the SMM-side content grows.

**Live SPARQL in the console.** Stage 5 Phase 4 candidate. Direct console access to the canonical KG content rather than via the model-introspection JSON. Would close [[ontara-workflow-emergent-ideas-log|E022]] and unblock several future console workstreams that need cross-stratum or cross-module navigation that the JSON does not support.

**Dual-canvas construction kit.** Business Canvas for composing business models; System Canvas for technology components; connected by horizontal mappings. A long-horizon vision that the strengthened A4 frames precisely — the canvases are authoring tools at the Configured Model stratum, with horizontal mappings explicit at the stratum where the sides are distinct.

**Syside Automator migration.** Semantic model access replacing regex-based parsers. Targeted for when the Automator API stabilises.

**GraphRAG as KG consumption pattern (E026).** Exploiting the canonical knowledge graph through retrieval-augmented generation. A future research direction; the canonical content is the natural source.

### 12.3 Methodology and methodological observations

**Cross-domain validation across CSW, Suds, Paws.** The discipline that every metamodel concept and pattern should validate in at least two domains ([[concept-cross-domain-validation|J1]]) has held across 200+ sessions. The Stage 9 surface architecture work added Ears and the cross-domain walk-throughs at Paws (S206) and Suds (S207) to the validation set; the seven user bands held against three structurally different demonstrators.

**Co-evolution.** Model and console tooling built together ([[concept-co-evolution|J2]]). Under the strengthened A4 with the SRS as the operator-facing surface, co-evolution gets a sharper expression: consumer surfaces (the console, the portal, future band-specific surfaces) are realising components that read SRS content; their co-evolution discipline ensures that the canonical content has consumers.

**Non-constraining.** Decisions must not foreclose future paths ([[concept-non-constraining|J3]]). The most prominent application in v5 is the DPA-informed writing discipline (OW-83) — no v5 commitment makes Domain Portability Architecture impossible to add later.

**Full-rewrite-over-targeted-edits for documents with significant conceptual change ([[ontara-ref-work-item-tracker|OW-211-5]] / [[ontara-ref-work-item-tracker|OW-212-1]]).** Architecture Principles v5 (S210 partial draft + S211 completion in WORKSHOP container) and the strategic snapshot S212 refresh both confirmed the methodology. PMS v5 (this paper) is the third application; the per-section workflow assignment in the [[w-049-pms-v5-scoping-note|W-049 PMS v5 scoping note]] §2 took the principle as its organising rule.

**Critique at design milestones.** Workflow guide §1 commitment 5 / §2.2. Architecture Principles v5 had its critique pass distributed across S210 and S211 (per-section critique observations); the W-049 PMS v5 scoping note had its critique at §7. PMS v5's critique observations are recorded in the dedicated section below.


---

## 13. Summary

The Ontara modelling strategy is built on one canonical formalism — OWL 2 DL held in the Knowledge Graph — with SysML v2 as an engineering projection of selected content. This is the v5 reframing: v4.1 held OWL and SysML as two complementary formalisms each authoritative in its own domain; v5 commits to KG-canonical ([[concept-knowledge-graph|B22]] promoted from directional to binding in [[ontara-architecture-platform-principles|Architecture Principles v5]] §5.6) and uses the commitment as the organising principle for the modelling strategy. The architectural reality has been KG-canonical since the round-trip diff engine closed the round-trip condition in Session 137; v5 makes the commitment explicit and uses it as the structural ground for everything else.

The modelling strategy is downstream of the **stratified two-side architecture** committed to in [[ontara-architecture-platform-principles|Architecture Principles v5]] §3: six ontological strata — Foundation, Formalism Boundary, Metamodel, Configured Model, State Representation, Platform Realisation — running vertically; two sides — business, system — running through the strata where they are divided. Modelling work operates principally at the Metamodel and Configured Model strata (where vocabulary and tenant configuration are authored) and at the boundary into the State Representation Stratum (where the runtime instance content the model predicts and shapes lives). The Foundation, Formalism Boundary, and Platform Realisation strata are largely settled; the SRS is the homogeneous queryable stratum that makes self-description, the unity principle, the coordinate framework, and the simulation architecture all expressions of one structural commitment rather than independent capabilities.

The four-level distinction ([[ontara-ref-master-register|B40]]) — **metamodel / configured model / runtime instance / realising component** — is the modelling-strategy expression of the strengthened A4. Every model element belongs to exactly one level. Every cross-level claim is named explicitly. Implicit cross-level identification — notably the metamodel runtime confusion that prohibition 5 of Architecture Principles v5 §3.4 retires — is a defect. PMS v5 uses the four-level vocabulary throughout; the older "meta model versus instance" two-term scheme of v4.1 is preserved only as historical vocabulary in version-history entries.

The interlocking commitments that the modelling strategy rests on are: the [[principle-separation-representation-execution|separation of representation and execution (A1)]] under the strengthened A4 as the structural boundary between the upper strata and the Platform Realisation Stratum; the [[principle-model-generates-everything|generation pipeline (A3)]] keeping the canonical content and the realising components in sync; the [[principle-two-meta-model-distinction|stratified two-side architecture (A4)]] as the load-bearing structural commitment; the [[principle-deterministic-over-probabilistic|four-category reasoning scheme (A6)]] ensuring authoritative decisions are inspectable while giving structured probabilistic reasoning first-class status; the [[principle-intrinsic-self-knowledge|comprehension architecture (A10)]] enabling the system to explain itself by querying its own SRS content; and the [[principle-unity-principle|unity principle (A11)]] ensuring that one canonical model surfaces consistently through every realising component that reads it — empirically validated at two layers, by the comprehension–reasoning convergence (S147-D7) at the reasoning level and the constraint-hierarchy-as-architectural-spine finding (S207 D28) at the surface level.

The two metamodels — Business Metamodel (BMM) and System Metamodel (SMM) — sit at the Metamodel stratum, each internally structured into General (sector-agnostic) and Tailored (sector-specific) content. The BMM is structurally complete at the General level with 36 `part def`s + 2 `requirement def`s across six concerns plus the `Foundation::DomainRegistry` sub-package. The SMM is more distributed across explicit SysML core (`ArchitecturalSection`), SysML+OWL pair (domain identity), and three substantial hand-authored OWL modules (governance, reasoning metamodel, PROV-O core subset) that are first-class canonical content with no SysML projection.

The reasoning metamodel (Stage 7, formally closed Session 159) provides the OWL vocabulary for institutionalised reasoning — 42 classes covering reasoning contexts, the SEPIO+PROV-O evidence architecture, the three-way constraint hierarchy, decision modes, knowledge sources, structured probabilistic types, and STAMP/STPA safety control structures. Under the strengthened A4, every instance of these classes is SRS content; the reasoning vocabulary lives at the Metamodel stratum and its instance content lives at the SRS. The five-layer SystemStateAssessment pattern that v4.1 stated as an architectural pattern in its own right is, in v5, the natural behaviour of the SRS when queried across epistemic tags — a substantial simplification.

The five-principle unification hypothesis ([[ontara-ref-work-item-tracker|OW-77]]) has been tested in two of the three foundations papers. **Test 1 passed** for [[ontara-architecture-platform-principles|Architecture Principles v5]] §2.4. **Test 2 passes** for this paper (§2.5). Test 3 ([[ontara-architecture-business-meta-modelling|SBMM v4]]) remains to run. The hypothesis is holding across the foundations papers; the principles survive in the register as separately named commitments because they are useful as separate names for aspects of the one underlying fact, but each is now structurally anchored in the strengthened A4 rather than holding its own load as an independent claim.

The concentric rings of modelling rigour provide a principled gradient from maximum modelling investment (clinical pathways) through structural design (platform infrastructure) to architectural documentation (business context). The model earns its keep by generating something or making a non-obvious relationship visible — and the [[concept-co-evolution|co-evolution principle (J2)]] ensures that modelling and tooling advance together, with the consumer-side surfaces (the console, the portal, future band-specific surfaces) providing the realising-component-side of the J2 discipline.

Four demonstrator domains validate that the BMM vocabulary generalises across structurally different service businesses: Cafe (immediate retail, full model + running application), Suds (batch processing, BMM + COSHH governance), Paws (appointment-based personal service, General vocabulary), and Ears (community ear care, sector-regulated, analytical intake complete). Under [[concept-multi-tenancy|multi-tenancy (A13)]] — binding Tier 1 since Session 142 — every domain is a tenant instantiation; GenderSense Limited is the most important tenant but is not structurally privileged.

The forward direction includes the SBMM v4 refresh (closing W-049), the glossary build (W-052), the Domain Portability Architecture design (W-053), Stage 9 plan production once the foundations are complete, the experience-API / BFF layer design, the bounded agent implementation, the Stage 8 portal substrate replacement, hardware peripheral integration for bands 1 and 2, and the GSL clinical domain intake at production complexity. The [[concept-non-constraining|non-constraining principle (J3)]] ensures these paths remain open while current work proceeds with discipline and precision; the **DPA-informed writing discipline ([[ontara-ref-work-item-tracker|OW-83]])** is the most prominent v5 application of J3 — no commitment in this paper makes per-tenant content portability impossible to add later.

The modelling strategy is, ultimately, a strategy for producing a platform that comprehends itself. The canonical content lives in the Knowledge Graph in one vocabulary throughout. The SysML projection is the comfortable authoring surface for the parts of that canonical content where it earns its keep. The realising components at the Platform Realisation Stratum populate the SRS through bindings, and consumers — the comprehension architecture, the reasoning engines, the operator surfaces, the governance evaluators, the future band-specific surfaces — read the SRS in the same vocabulary, queryable across epistemic tags, with provenance for everything. Self-description, the unity principle, the coordinate framework, and the simulation architecture are not separate features the platform engineers in parallel; they are facets of one underlying commitment, made operationally real by the SRS being homogeneous and queryable. This is the modelling-strategy consequence of the strengthened A4, and it is what the rest of the project's work — Stage 9 implementation, GSL production, all the future bands — proceeds against.

---

## Critique Observations and Watchpoints

Per workflow guide §2.2 and the structured critique discipline, the critique pass for PMS v5 was distributed across the drafting work in this session and is consolidated below. Five categories: logical coherence, significant omissions, alternative approaches considered, untested assumptions, and risks of the chosen direction. Observations of category 1 (actionable now) were addressed in-session; categories 2 (qualifying observations) and 3 (testable predictions) are recorded here and deposited into the OW register at C2 with work type assignments.

### Category 1 — actionable, fixed in session

None substantive. The structural reframing was scoped in advance by the [[w-049-pms-v5-scoping-note|W-049 PMS v5 scoping note]] and the per-section workflow assignment held during drafting; no in-session reframing was forced.

### Category 2 — qualifying observations

**Q1 — PMS v5 §3 retitling and section move.** v5 moves the canonical-formalism content from v4.1 §11 to v5 §3, retitling it from "The Two Formalisms" to "The Canonical Formalism and Its Projection". This is the structural change Ella authorised at S216 open ("v5 should be adopting a fresh approach, unconstrained by legacy thinking"). A reader familiar with v4.1's section ordering will need to adjust; the v5 ordering reflects current understanding rather than v4.1's arc, which is the intended outcome. The section history is preserved in the version history entry. No action required; flagged as a reading-experience qualifying observation.

**Q2 — PMS v5 §5 absorbs the package architecture into a strengthened-A4-framed treatment.** v4.1 §7 was titled "The Two Meta Models and Package Architecture" and treated the two metamodels as the principal architectural commitment. v5 §5 retains the title structure but reframes the two metamodels as one stratum within the larger six-stratum × two-side grid. This is consistent with the strengthened A4 framing in [[ontara-architecture-platform-principles|Architecture Principles v5]] §3 and §5.5. A reader of the section in isolation should note that "the two metamodels" is no longer the principal architectural commitment — it is critical content at one stratum within the larger frame.

**Q3 — General/Tailored detailed treatment deferred to SBMM v4.** PMS v5 §5.2, §5.6, and §9.3 mention the General/Tailored distinction but explicitly defer the detailed treatment (criteria for promotion, hooking mechanism, sub-band mechanics) to SBMM v4. Tracked as [[ontara-ref-work-item-tracker|OW-87]]. PMS v5's discipline is that the boundary is held by deferral, not by silence — readers needing the detailed treatment are pointed to SBMM v4 explicitly.

**Q4 — Cumulative dependency on Architecture Principles v5.** Test 2 derivations in this paper lean on Architecture Principles v5 §3.1, §3.4, §3.5, §5.6, §5.7, §5.1 — the same dependency pattern as Test 1. Recorded as [[ontara-ref-work-item-tracker|OW-215-1]]. The unification hypothesis remains a derivation hypothesis, not a reduction hypothesis: the principles can be derived from the strengthened A4 plus surrounding architectural content in Architecture Principles v5, but they do not collapse into A4 alone. This is a fair recording; not a defect.

### Category 3 — testable predictions / watchpoints

**T1 — KG-canonical engineering authoring-parity asymmetry.** PMS v5 §3.7 names the asymmetry between SysML projection authoring tooling (mature) and hand-authored OWL authoring tooling (basic). Recorded as the existing [[ontara-ref-work-item-tracker|OW-78]] with a sharpened framing: §3.7 names §3.5 (the catalogue of hand-authored modules) as the trigger for when the asymmetry will start to bite. Test: as the canonical KG grows large enough that direct authoring becomes routine, the asymmetry will surface as a workflow constraint. Watchpoint for future tooling workstreams.

**T2 — Hand-authored OWL module navigability in the console.** §3.7 names the lack of console views for the hand-authored OWL modules as navigable model content. They appear as triple counts in the Ontology view's KG Status panel; their classes appear in the BFO hierarchy view; but there is no equivalent of the Component Catalogue or the Glossary. Recorded as [[ontara-ref-work-item-tracker|OW-215-3]]. Test: when a console feature is needed that requires browsing hand-authored content as model material, the absence will be felt.

**T3 — Test 3 strain prediction.** §2.5 records that Test 3 (SBMM v4) is expected to lean on Architecture Principles v5 §5.5 (Metamodel stratum General/Tailored sub-structuring) more heavily than Tests 1 or 2 did. If Test 3 strains — that is, if SBMM v4 cannot derive the principles using only content already in Architecture Principles v5 — the unification hypothesis is partial and the partial result is itself useful (it would identify which principle has content not derivable from A4). Test happens when SBMM v4 is drafted. Recorded as part of [[ontara-ref-work-item-tracker|OW-215-1]].

**T4 — Four-level vocabulary as discipline.** PMS v5 commits to using the four-level vocabulary (metamodel / configured model / runtime instance / realising component) throughout. The discipline will be tested in subsequent papers and in design work. Watchpoint: regression to the v4.1 two-term scheme ("meta model" / "instance") should be flagged at session reviews and at systematic documentation reviews. The retired phrasings ("BMM runtime state", "SMM runtime state", "BS" as runtime-state acronym, "BMM side" / "SMM side" for the two columns) are similarly subject to regression watch.

**T5 — DPA-informed writing discipline survival.** PMS v5 holds writing discipline against the Domain Portability Architecture throughout. The test of whether the discipline has been honoured is whether DPA design work, when it begins as W-053, finds any v5 commitment that forecloses portability. If it does, the discipline failed somewhere; the failure point should be identified and the paper amended. Watchpoint for W-053 design work.

### Category 4 — critique categories not invoked

**Logical coherence** held throughout — no internal contradictions identified. The per-section workflow assignment from the scoping note held; the structural reframing was applied consistently; the Test 2 derivations are stated explicitly and are consistent with Test 1's results. **Alternative approaches** were considered at the scoping note stage (full-rewrite-container vs targeted-edit-sequence) and the full-rewrite-container approach won on the basis of [[ontara-ref-work-item-tracker|OW-211-5]] / [[ontara-ref-work-item-tracker|OW-212-1]]; PMS v5 is the third application of the methodology. **Untested assumptions** are largely about Test 3 and the DPA workstream — both flagged above. **Risks of the chosen direction** were considered at the scoping note stage (PMS v5 ending up restating Architecture Principles v5; §5 package architecture rewrite drifting into BMM/SMM detail belonging in SBMM v4); both were mitigated by writing discipline, with [[ontara-ref-work-item-tracker|OW-87]] as the standing watchpoint for the §5 boundary.

### OW items deposited at S216

The following items are deposited into the OW register at C2 with work type assignments:

| ID | Summary | Work Type | Notes |
|---|---|---|---|
| **S216-O1** | PMS v5 §3 retitling and section move from v4.1 §11 to v5 §3 reflects current understanding under KG-canonical. Reading-experience qualifying observation for readers familiar with v4.1's ordering | GOV | Q1 above |
| **S216-O2** | Test 2 derivations in PMS v5 lean on Architecture Principles v5 §3.1, §3.4, §3.5, §5.6, §5.7, §5.1 — same dependency pattern as Test 1 (OW-89). Cumulative dependency real; unification hypothesis is a derivation hypothesis, not a reduction hypothesis | GOV, ARC | Q4 / T3 above; sharpens [[ontara-ref-work-item-tracker\|OW-215-1]] |
| **S216-O3** | KG-canonical engineering authoring-parity asymmetry (existing [[ontara-ref-work-item-tracker\|OW-78]]) sharpened by PMS v5 §3.7 — §3.5 catalogue of hand-authored modules is the trigger point for when the asymmetry will start to bite | CON, KGO | T1 above |
| **S216-O4** | Four-level vocabulary regression watch. PMS v5 commits to metamodel / configured model / runtime instance / realising component throughout. Regression to v4.1 two-term scheme should be flagged at session reviews and systematic documentation reviews | GOV, METHOD | T4 above |
| **S216-O5** | DPA-informed writing discipline survival. The test of whether the discipline has been honoured is whether DPA design work as W-053 finds any PMS v5 commitment that forecloses portability. Watchpoint for W-053 design work | ARC, GOV | T5 above |

---

## Related Documents

### Foundations papers (companion)

- [[ontara-architecture-platform-principles|Architecture Principles (v5)]] — the upstream foundations paper that PMS v5 derives from. Six strata, two sides, ten architectural loci. KG-canonical binding. A12 binding T1. SRS and PRS strata named. §7.3 constraint hierarchy as architectural spine
- [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling (v3.1)]] — the BMM comprehensive reference. **v4 pending** ([[ontara-ref-work-item-tracker|W-049]] remainder); will hold the General/Tailored detailed treatment ([[ontara-ref-work-item-tracker|OW-87]]) and run Test 3 of the five-principle unification hypothesis

### Stage 9 architectural foundation papers

- [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks (S192)]] — Stage 9 framing, 8 design decisions, 7 open questions
- [[ontara-discussion-model-meta-model-distinction-2026-04-11|Model and Meta Model Distinction (S195)]] — four-layer model; BM and SM as configured models distinct from BMM and SMM
- [[ontara-discussion-architectural-clarification-2026-04-12|Architectural Clarification Note (S196)]] — reflective simulation clarified; operational simulation terminology tightened
- [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|BS Substrate and Bindings (S197)]] — BR/BS as dynamic aspects of BM/SM; KG as substrate; observational binding pattern; horizontal mapping rule vocabulary
- [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|The Architect-Analyst Workspace (S198/S200)]] — band 6 surface architecture; bounded agent roster; binding-grounded action class
- [[ontara-discussion-surface-families-headless-composition-2026-04-13|Surface Families: Headless Composition (S199)]] — seven user bands; headless five-layer architecture; experience-API / BFF layer; state placement discipline; four-level vocabulary

### Strengthened A4 source material

- [[WORKSHOP-s208-a4-reformulation-INTEGRATED|S208/S209 Integrated Workshop Document]] — canonical source for the strengthened A4 (six strata, two sides, ten loci); KG-canonical commitment; A12 promotion; BS → SR rename; DPA section; five-principle unification hypothesis
- [[w-049-pms-v5-scoping-note|W-049 PMS v5 Scoping Note (S215)]] — the per-section workflow assignment, Test 2 framing, and new-content identification for this v5 refresh

### Earlier discussion papers (selected)

- [[ontara-discussion-comprehension-architecture-2026-03-19|Comprehension Architecture (Sessions 45–58)]] — three registers of self-knowledge
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture (Sessions 73–74)]] — the historical foundation paper. [[concept-dual-stack-architecture|B21]] is now a consequence of the strengthened A4 rather than a freestanding commitment
- [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture (Session 97)]] — three-stratum graph (E019), authority zones (B29 / E020)
- [[ontara-discussion-bfo-type-mapping-2026-04-01|@BfoType Mapping (Session 98)]] — the SysML-to-OWL crossing mechanism at the Formalism Boundary stratum
- [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture (Session 121)]] — the obligation vocabulary and three-tier compliance architecture
- [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Domain Identity in the Dual-Stack Architecture (Session 142)]] — the dual-stack split for domain identity
- [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning (Session 146)]] — the reasoning metamodel; SEPIO+PROV-O evidence architecture
- [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited (Session 147)]] — coordinate framework consolidation; Region taxonomy; constraint geometry; comprehension–reasoning convergence (S147-D7). **Standing instruction: actively consider for relevance with every significant piece of work**
- [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal: State-Driven Operator Experience (Session 174)]] — Stage 8 foundation paper
- [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|Clinical Domain Intake Framework (Session 160)]] — domain intake methodology; exercised by Ears (Sessions 161–168)

### Reference and orientation

- [[ontara-ref-vision-architecture|Vision and Architecture Reference (v12)]] — the comprehensive architectural summary
- [[ontara-ref-strategic-snapshot|Strategic Reference]] — current development state and metrics
- [[ontara-ref-master-register|Master Concept Register]] — ~220+ concepts across 16 sections (A–P), four tiers
- [[ontara-ref-work-item-tracker|Work Item Tracker]] — authoritative work item status; Document Currency Register; Observation and Watchpoint Register
- [[ontara-workflow-guide|Development Workflow Guide]] — §2.2 (critique), §7.4 (full-rewrite over targeted-edits)
- [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]] — 11 modelling paradigms with exploitation status
- [[—— ARCHITECTURE INDEX ——|Architecture Papers Index]] — curated reading order for all architecture papers

### Demonstrators

- [[domain-cafe|Cafe]] — immediate retail; full BMM + running application; the standing reference domain ([[pattern-coffee-shop-demonstrator|D21]])
- [[domain-suds|Suds]] — batch processing; full BMM + COSHH governance traceability chain; cross-domain walk-through S207 (constraint-hierarchy-as-architectural-spine finding D28)
- [[domain-paws|Paws]] — appointment-based personal service; General BMM vocabulary + StakeholderModel; cross-domain walk-through S206
- [[domain-ears|Ears]] — community ear care; sector-regulated; analytical intake complete S160–168 (W-015)

### Superseded versions of this paper

- [[SUPERSEDED-ontara-architecture-platform-modelling-strategy-2026-04-15\|Platform Modelling Strategy v4.1 (Session 170, archived by Ella before S216 drafting began)]]
- [[SUPERSEDED-ontara-architecture-platform-modelling-strategy-v3-s96|Platform Modelling Strategy v3 (Session 96)]]
- [[SUPERSEDED-ontara-platform-modelling-strategy-v2-s65|Platform Modelling Strategy v2 (Session 65)]]
- [[SUPERSEDED-ontara-platform-sysml-modelling-strategy-v1|SysML Modelling Strategy v1]] — original

---

*Platform Modelling Strategy v5, Session 216, 15 April 2026. Full conceptual rewrite from v4.1 (Session 170, 7 April 2026) under the strengthened [[principle-two-meta-model-distinction|A4]] committed in [[ontara-architecture-platform-principles|Architecture Principles v5]] §3 and the binding KG-canonical commitment in Architecture Principles v5 §5.6. Test 2 of the five-principle unification hypothesis ([[ontara-ref-work-item-tracker|OW-77]]) passed for this paper. v4.1 archived by Ella to [[—— HISTORY & ARCHIVE INDEX ——|07 Ontara History & Archive]] before drafting began. Drafted as a single full-rewrite container artifact per [[ontara-ref-work-item-tracker|OW-212-1]] / [[ontara-ref-work-item-tracker|OW-211-5]], replacing v4.1 wholesale at the canonical filename.*

*GenderSense Limited.*
