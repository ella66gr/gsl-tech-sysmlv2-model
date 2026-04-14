---
tags:
  - plan
  - implementation
  - foundations
  - w-049
date: 2026-04-14
status: working
session: 208
---
# Session 208 — Foundations Papers Full Refresh Plan

> Implementation plan for W-049: full rewrite of the three foundations papers to incorporate all material developments since their last conceptual refresh (S154). Drafted at O5.

**Prepared by:** Claude (Session 208)
**Date:** 14 April 2026
**Scope:** Full conceptual rewrite of [[ontara-architecture-platform-principles|Architecture Principles]], [[ontara-architecture-platform-modelling-strategy|Platform Modelling Strategy]], and [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]]
**Target versions:** v5, v5, v4 respectively
**Work item:** [[ontara-ref-work-item-tracker|W-049]]
**Session type:** Housekeeping / foundations refresh (per [[ontara-workflow-guide|workflow guide]] §3.4)

---

## Contents

- [[#1. Objective and Scope|§1. Objective and Scope]]
- [[#2. Rationale|§2. Rationale]]
- [[#3. What Has Changed Since S154|§3. What Has Changed Since S154]]
- [[#4. Integration Opportunities|§4. Integration Opportunities]]
- [[#5. Paper-by-Paper Treatment|§5. Paper-by-Paper Treatment]]
- [[#6. Sequence and Pacing|§6. Sequence and Pacing]]
- [[#7. Procedure|§7. Procedure]]
- [[#8. Cross-Paper Consistency Rules|§8. Cross-Paper Consistency Rules]]
- [[#9. Deliverables and Success Criteria|§9. Deliverables and Success Criteria]]
- [[#10. Risks and Mitigations|§10. Risks and Mitigations]]
- [[#11. Dependencies and Deferred|§11. Dependencies and Deferred]]

---

## 1. Objective and Scope

Refresh all three foundations papers to the current architectural state of the platform, incorporating 54 sessions of development (S154–S208). The aim is not incremental touch-up of §12 but **full conceptual rewriting** of sections where the underlying vocabulary has shifted, combined with preservation of stable sections where no shift has occurred.

**In scope:**
- [[ontara-architecture-platform-principles|Architecture Principles]] — v4.1 → **v5**
- [[ontara-architecture-platform-modelling-strategy|Platform Modelling Strategy]] — v4.1 → **v5**
- [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]] — v3.1 → **v4**
- Cross-paper consistency pass (terminology, cross-references, shared vocabulary)
- Related Documents sections updated across all three
- Standing concept notes in [[—— CONCEPT GRAPH PURPOSE ——|03 Ontara Concept Graph]] checked for source drift per the [[ontara-workflow-guide|workflow guide]] §7.1 convention

**Out of scope for this session:**
- Master register additions for S197–S199 concepts (the remaining [[ontara-ref-work-item-tracker|W-043]] follow-up — defer to a dedicated session)
- Campus Walk II and architecture diagram revision ([[ontara-ref-work-item-tracker|W-045]])
- Vision & Architecture Reference further refresh (already v12, current)
- Individual concept note rewrites beyond targeted source-drift fixes

---

## 2. Rationale

Three reasons, in ascending order of importance.

**2.1 Cognitive friction reduction.** At present a reader approaching the project via the [[ontara-ref-strategic-snapshot|strategic snapshot]] or [[ontara-ref-vision-architecture|V&A v12]] encounters Stage 9 vocabulary (four-layer model, BR/BS/bindings, surface families, experience-API/BFF, user bands) and then, stepping down to the foundations, finds vocabulary frozen at the end of Stage 7 Phase 1. The mental translation between the two layers costs effort, introduces doubt, and makes the foundations papers feel disconnected from the live architecture.

**2.2 Structural harmony and integration.** A sizeable project with conceptual fracture between its orientation documents and its foundations papers cannot grow cleanly. Stage 9 work will depend on the foundations papers as the stable reference for principles (why) and vocabulary (what). If the papers do not carry the new vocabulary, Stage 9 discussions will either ignore them or work around them — and either outcome erodes the discipline of having foundations papers in the first place.

**2.3 Opportunity cost — integration and cross-pollination.** This is the decisive argument. Individual Stage 8 and Stage 9 discussion papers each developed their contribution in isolation, with tight bandwidth and a specific question to answer. A full-rewrite refresh of the foundations is the first structured opportunity since S154 to see the whole set of developments simultaneously and ask whether the concepts hold together as a coherent extended architecture — or whether the act of bringing them together surfaces new insights, tensions, or consolidations that none of the individual papers could produce. Concretely, at least three integration opportunities are visible already:

1. The **four-layer vocabulary** (metamodel / configured model / runtime instance / realising component) from S195/S199 is not yet reconciled with [[principle-two-meta-model-distinction|A4]]'s two-metamodel framing in the foundations papers. A4 needs an amendment (or an explicit extension) that locates the four levels against the two-metamodel commitment.
2. The **three-way constraint hierarchy** from Stage 7 and the **constraint hierarchy → UI affordance mapping** (D28) from S207 are architecturally continuous: constraint classification at the reasoning level determines affordance grammar at the surface level. This is a cross-stage insight that neither Stage 7 nor the S199/S207 work stated explicitly.
3. The **static/dynamic duality of models** from S197 (BR/BS as dynamic aspects of BM/SM) intersects with the [[concept-dual-stack-architecture|dual-stack architecture (B21)]] of S73. The dual stack described structural layers; S197 adds a dynamic/static axis. How these two framings compose is foundational material.

These are not merely documentary updates — they are architectural consolidations that the foundations papers are the natural home for.

---

## 3. What Has Changed Since S154

### 3.1 Stage 7 completion (S152 → S159)

- **Phase 2** (S155): Heuristic packs (6 typed subtypes with HeuristicPack container), decision mode routing (4 Cynefin-mapped DecisionMode individuals), constraint satisfaction structures (CombinationAlgebra with 4 named individuals). 34 classes, 50/50 SPARQL.
- **Phase 3** (S156–S157): STAMP/STPA control structures (SafetyConstraint, ControlStructure, ControlLoop, ControlAction, UnsafeControlAction with 4 STPA type individuals), FRAM-ready slots (FRAMFunction, VariabilityProfile). 42 classes, 56/56 SPARQL.
- **Phase 4** (S158): Console integration — Reasoning Vocabulary Explorer (42 classes in 7 colour-coded functional modules, 15 individuals, 50 properties, 32 cross-module axioms), KG Status extensions.
- **Formal closure** (S159): 33/35 success criteria met. P4-2 (evidence browser) and P4-3 (decision trace) deferred pending instance data.

### 3.2 Clinical Domain Intake Framework and Ears (S160–S168, W-015)

- **Methodology paper** — [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|Clinical Domain Intake Framework]] (S160). Structured methodology for domain characterisation, ingestion, and platform fitness validation. Feature taxonomy, proforma intake schema, coverage map concept.
- **Ears as first clinical domain intake** — five artefacts across S161–S167: domain description, vertical connection map, coverage map (86.2% Full across 65 proforma fields), reasoning instance population (~83 individuals exercising 25/42 classes), design note (vocabulary adequacy confirmed at Ears-level complexity).
- **Observation and Watchpoint Register established** (S167) — 12 initial items, 9-code work type taxonomy, integrated into workflow guide at O3/§2.2/C2/§5.1. A structural governance innovation.
- **SPARQL suite extension to 66 queries in 12 groups** (S168), including the new Ears Instance group.

### 3.3 Stage 8 — The Ontara Portal (S174–S185)

The most conceptually substantial missing block. The portal is **completely absent** from the foundations papers.

- **Portal discussion paper** — [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal: State-Driven Operator Experience]] (S174). State-driven operator paradigm, module architecture, composable module lifecycle, progressive governance, promotion path.
- **Stage 8 plan** (S174, 5 phases, 19–31 sessions estimated).
- **Phase 1** (S175): Portal empty shell — user auth, domain CRUD, multi-domain switching.
- **Phase 2** (S176): Module lifecycle — 7-module catalogue (later 10), schema-driven configuration, two intersecting lifecycle state machines (installation + operational), dashboard as state landscape with inline lifecycle actions.
- **Phase 3** (S177–S178): Domain context model (BMM-concern-structured), module wiring via BMM concern overlap, composition guidance with lifecycle impact warnings.
- **Phase 4** (S179–S181): **Epistemic dimension** as settable property (production / hypothesis / projection), simulation with batch event generation (Poisson / log-normal distributions), comparative analytics, 10-module catalogue (6 business + 2 generative + 2 analytical).
- **Phase 5** (S182–S185): **Progressive governance** (exploratory / advisory / enforced), 20 typed constraints (8 hard, 6 soft, 6 graded), promotion wizard with 5-prerequisite flow, demotion, production visual treatment, lifecycle governance guards.
- **Stack**: SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 + SQLite (better-sqlite3). Warm teal theme. A second first-class application alongside the Ontara Console.
- **Stage 8 formally closed** (S185) — 11 sessions, within the 19–31 estimate.

### 3.4 Concept graph note programme (W-039/W-040, S189–S191)

6 principle notes rewritten to current quality standard (A1, A2, A3, A4, A7, A8). 9 new notes (B11, B12, B25, B30–B32, B34–B35, H1). 27 rewrites. Concept count 60 → 70. All 4 concept graph templates updated. Relevant to the foundations papers in that the concept graph is now considerably richer than the papers' related-concept references indicate, and several rewritten notes carry material that should reflect into the papers.

### 3.5 Stage 9 architectural foundation (S192–S200)

The largest conceptual block and the hardest to absorb. Five major discussion papers:

**3.5.1 Connecting the Stacks (S192–S193).** The thesis for Stage 9. Eight design decisions (S192-D1 to D8). Seven open questions (Q1–Q7) that remain the core outstanding design questions. Key clarifications:
- SMM runtime state and BMM runtime state are architecturally distinct, requiring separate stores and update paths.
- Horizontal mappings at runtime are the rules keeping both sides synchronised — possibly the central design challenge of Stage 9.
- Portal module catalogue must be derived from the SysML model (S192-D7).
- Coffee shop demonstrator is the concrete proving ground for connecting the islands.

**3.5.2 Model and Meta Model Distinction (S195).** The **four-layer vocabulary** — Foundation → Metamodel → Configured model → Generated output. BM/SM as configured models distinct from BMM/SMM. Operational Simulation clarified as one-model-multiple-instantiation (not digital twin). This is a fundamental clarification that requires [[principle-two-meta-model-distinction|A4]] to be amended or extended.

**3.5.3 BS Substrate and Bindings (S197).** BR/BS as dynamic aspects of BM/SM. KG as substrate for runtime state. Observational binding pattern. Horizontal mapping rule vocabulary. Binding registry. Static/dynamic duality of models formalised. This reframes the [[concept-dual-stack-architecture|dual-stack architecture (B21)]] by adding a dynamic/static axis to the structural vocabulary.

**3.5.4 The Architect-Analyst Workspace (S198/S200).** Band 6 surface architecture. Three-layer interaction model (operational / expert / intent). Bounded agent roster with capability matrix. Ask / Plan / Simulate / Act modes. **Action class as binding-derived** — the principal Ontara-specific contribution: risk classification computable from binding metadata rather than hand-asserted.

**3.5.5 Surface Families: Headless Composition (S199).** Seven working user bands (non-constraining per [[concept-non-constraining|J3]]). Headless five-layer architecture. **Experience-API / BFF layer** as a Stage 9 addition. State placement discipline. Four-level vocabulary given its own section and applied rigorously. Cross-domain validated against Cafe (S199), Paws (S206), Suds (S207) — seven bands held against three structurally different demonstrators.

### 3.6 Partial W-043 register additions (S207)

Not yet in the foundations papers, but should be reflected where relevant:
- **B40** — four-level distinction (T2)
- **B41** — sophistication gradient / user bands (T2)
- **B42** — surface family (T2)
- **B43** — experience API / BFF layer (T2)
- **B44** — headless five-layer architecture (T2)
- **J15** — state placement discipline (T2)
- **D28** — constraint hierarchy → UI affordance mapping (T4 discussion)
- **D29** — governance dashboard pattern (T4 discussion)
- **A4 amendment note** — pointing to B40 as the deeper articulation of the four-level discipline.
- **J3 cross-cutting touchpoint extended** — non-constraining bands stance.

---

## 4. Integration Opportunities

This is where the full-rewrite approach earns its keep. A light §12 touch-up would miss all of these. A full rewrite lets us state them cleanly.

### 4.1 A4 amendment — the four-level discipline

[[principle-two-meta-model-distinction|A4]] currently says: two meta models, BMM and SMM, connected by horizontal mappings at every tier. S195 showed that the live discipline is actually a **four-level stack**: Foundation (BFO etc.) → Metamodel (BMM/SMM) → Configured model (BM/SM) → Generated output (runtime instances, realising components). A4 needs extending to make this explicit. The extension should preserve A4's original claim (the two-metamodel commitment) and add the four-level refinement as a structural elaboration.

**Action.** Amend A4's statement in Architecture Principles §3. Cross-reference B40 once it is registered. Carry the same amendment through to SBMM §2 and §9 and Platform Modelling Strategy §7.

### 4.2 Constraint hierarchy as architectural spine

Stage 7 established the three-way constraint hierarchy (HardConstraint / SoftConstraint / GradedRule) at the reasoning metamodel level. S207 D28 established that the same hierarchy maps to three distinct UI affordance types at multiple bands. This is not a coincidence — it is evidence that **the constraint hierarchy is an architectural spine running from reasoning to surface**, and the same canonical constraint state surfaces at multiple bands without per-surface re-implementation. The experience-API / BFF layer is the locus of the assembly.

**Action.** Add a cross-cutting discussion in Architecture Principles §7 (Governance as a First-Class Concern) or a new §7.5, and in Platform Modelling Strategy §6.2. State the insight explicitly. Reference D28. Reference the [[principle-unity-principle|unity principle (A11)]] — the constraint hierarchy is the latest domain in which A11's one-model-informs-all commitment is empirically validated.

### 4.3 Static/dynamic duality composed with the dual stack

S197 added a dynamic/static axis to the dual-stack architecture. Where the dual stack describes structural layers (vocabulary → instance → operational), the S197 framing adds that each model layer has two aspects — static (BM/SM content) and dynamic (BR/BS runtime state). These compose orthogonally: any architectural section can be characterised by its place on the vertical stack AND its place on the static/dynamic axis.

**Action.** In Architecture Principles §5.5 (dual-stack architecture), add a subsection on the static/dynamic duality. In Platform Modelling Strategy §7, reflect the same framing. In SBMM §9 (two meta models), clarify that BM and BR are distinct aspects of the business model layer — BM is configured structure, BR is runtime state.

### 4.4 Portal as second first-class application

The foundations papers currently treat the Ontara Console as the canonical application built on the platform. The portal is now a second first-class application with a fundamentally different purpose (operator experience rather than architect/analyst experience). The foundations papers must acknowledge this, and Platform Modelling Strategy in particular should reflect the portal as a first-class consumer of model content.

**Action.** In Architecture Principles, the portal is referenced in context where applications are discussed. In Platform Modelling Strategy §10 (generation pipeline) and §12 (current state), the portal appears as a new consumer; the portal module catalogue's model-derived commitment (S192-D7) is noted. In SBMM §7 (mapping to existing system model), the portal's BMM-concern-structured domain context is noted as the first direct consumer of BMM structure at runtime.

### 4.5 Sophistication gradient and surface families

The seven user bands are a new architectural vocabulary for **user role differentiation** that the foundations papers have no current language for. They are not an RBAC scheme and not a staff-banding scheme — they are a sophistication gradient capturing how a user relates to the substrate. This is genuinely new structural vocabulary and the foundations papers need to incorporate it.

**Action.** Add language for user bands and surface families to Architecture Principles §5 or a new §5.8 (Surface Architecture). Cross-reference B41/B42/B43/B44. Note that the gradient is non-constraining per [[concept-non-constraining|J3]] — it is a working hypothesis, validated cross-domain but revisable.

### 4.6 Bounded agents and binding-grounded action class

S198's bounded agent roster and the action-class-as-binding-derived principle are architectural additions that intersect with [[principle-discipline-as-load-bearing-structure|A9]] and [[principle-model-generates-everything|A3]]. The architectural positions:
- Bounded agents have distinct identities with capability matrices — an agent extending its own capabilities is a design smell.
- Action class risk classification is computed from binding metadata (instantiation mode, freshness profile, production marker, authority zone) — not from prompt cleverness.

These are principle-level commitments. A9 should be extended with an "agent guided by model truth" clause. A3 should be extended to cover the agent layer.

**Action.** In Architecture Principles §1 (Separation Principle) and §10 (Guiding Constraints), add language about bounded agents and action class. Consider whether this warrants a new §8.5 or appendix on the agent architecture.

### 4.7 Systematic update to the comprehension architecture discussion

The comprehension architecture sections of all three papers speak about three registers. Session 147's convergence finding (S147-D7) — that the inferential register and the reasoning metamodel's evidence architecture are the same pattern — is partially reflected, but the implications for the foundations papers have not been fully worked through. With Stage 7 complete and Ears intake validated at instance level, the comprehension architecture sections can now speak with more confidence about what has been proven and what remains speculative.

**Action.** Update §2 (Architecture Principles), §3.2 (Platform Modelling Strategy), and §4 (SBMM) to reflect the post-Stage-7, post-Ears state.

---

## 5. Paper-by-Paper Treatment

### 5.1 Architecture Principles (v4.1 → v5)

**Character of changes:** Medium-heavy. Most sections need content updates; several need structural extension; the version history grows.

| Section | Treatment |
|---|---|
| Header and version history | Add v5 row. Bump dates. Update staleness threshold note if needed |
| §1 Separation Principle | Minor updates — add portal and bounded-agent context; add the A9 "agent guided by model truth" clause |
| §1.1 Generation pipeline as bridge | Update counts (13-file stack, 66 queries). Note the portal as a new consumer of model content |
| §2 Self-Describing System | Update §2.3 Reasoning architecture to reflect Stage 7 full closure (Phases 2–4). Note D28 constraint hierarchy → surface mapping |
| §3 Two Meta Models | **Amend to introduce the four-level discipline (S195).** A4 remains the commitment; the four levels are the elaboration. Cross-reference forthcoming B40 |
| §4 Multi-Tenancy | Add Ears to demonstrator list with intake-complete status. Minor updates |
| §5 Foundational Architecture | §5.5 (dual-stack): add static/dynamic duality subsection (S197). New §5.8 or §5.9: Surface Architecture (user bands, surface families, experience-API/BFF layer) |
| §6 Clinical Data Architecture | Minor — no Stage 8/9 changes affect this |
| §7 Governance as a First-Class Concern | Add §7.5 or equivalent: constraint hierarchy as architectural spine (Stage 7 ↔ S207 D28 insight). Extend the deontic governance section with Ears instance validation |
| §8 External Service Integration | Minor — possibly a note about bindings as the generalisation of the integration concept (S197) |
| §9 Data Availability and Aggregation | Update to reflect BR/BS as substrate (S197), KG as runtime store (OW-34, OW-39) |
| §10 Guiding Constraints | Add new constraint or amend existing — "agent guided by model truth" (A9 extension). Add a constraint reflecting state placement discipline (J15) |
| Appendix A | Minor additions if relevant — possibly a new pattern entry for the surface-side patterns |
| Related Documents | Add all Stage 9 foundation papers. Add Stage 8 papers. Update V&A to v12. Update SBMM to v4 and Platform Modelling Strategy to v5 |

**Anticipated length change:** +15% to +25%.

### 5.2 Platform Modelling Strategy (v4.1 → v5)

**Character of changes:** Heavy. This paper is the most affected because the modelling strategy is the layer where Stage 8 and Stage 9 most clearly land.

| Section | Treatment |
|---|---|
| Header and version history | Add v5 row |
| §1 Executive Summary | Rewrite to reflect Stage 7 closure, Ears intake, Stage 8 complete, Stage 9 foundation papers. The "since then the modelling approach has matured substantially" bullet list needs a significant extension |
| §2 Background and Context | §2.3 reference to Architecture Principles — update to v5. Minor otherwise |
| §3 Case for Comprehensive Modelling | §3.2 Comprehension architecture — reflect post-Stage-7 state |
| §4 Modelling Value Across the Business | §4.1: add a new area — operator experience modelling (portal). §4.2: governance framework formalisation is now fully validated (CQC MVP) |
| §5 Mapping Legacy Artefacts | Minor or no change |
| §6 Knowledge, Decision Support, Reasoning | §6.1: four-category reasoning scheme stays. §6.2: Stage 7 full closure — Phases 2–4 content (heuristic packs, decision mode routing, STAMP/STPA, FRAM-ready slots). §6.5 and §6.6: reflect Ears reasoning instances (~83 individuals). **New §6.7 (or extend §6.2): the constraint hierarchy as architectural spine (cross-stage insight)** |
| §7 Two Meta Models and Package Architecture | **Amend to reflect four-level vocabulary (S195).** Add BR/BS substrate (S197). Portal treatment needs significant addition — how the portal consumes model content (domain context as BMM-concern-structured). New subsection on the portal's relationship to the model |
| §8 Annotation and Metadata System | Minor updates. Consider whether any new annotations have emerged (none in recent sessions, but check) |
| §9 Structural Principles for the Model | §9.3 General/Tailored: Ears status. §9.4 Cross-domain validation: add Stage 8 and Stage 9 cross-domain work |
| §10 Generation Pipeline | Update counts (13-file stack, 66 queries). Add portal generators once they exist (S192-D7). Note the binding-registry target (OW-41) |
| §11 Two Formalisms | Update counts. Note the KG's expanded role as runtime substrate (OW-39). Reflect the S197 reframing — OWL as ontological semantics stays, but KG role now broader |
| §12 Current State and Forward Direction | **Full rewrite.** Stage 7 closed. Ears complete. Stage 8 complete. Stage 9 foundation laid. Forward direction: Stage 9 plan finalisation, connecting the stacks, experience-API/BFF design, horizontal mapping implementation |
| §13 Summary | Full rewrite to match |
| Related Documents | Full refresh |

**Anticipated length change:** +25% to +40%. This is the heaviest paper.

### 5.3 Service Business Meta Modelling (v3.1 → v4)

**Character of changes:** Medium. BMM vocabulary is genuinely stable; the changes are about how BMM interacts with the rest of the architecture.

| Section | Treatment |
|---|---|
| Header and version history | Add v4 row |
| §1 Purpose and Intent | Minor — update to reflect multi-tenancy and domain registry state |
| §2 Conceptual Framework | §2.1 six concerns: stable. §2.2 relationships: possibly note BR (runtime state) as the dynamic aspect of each concern. §2.4 activity awareness: possibly minor |
| §3 BMM Vocabulary | The 34 elements are stable. No vocabulary changes. §3.2 domain identity: already current. Check whether anything in the deontic governance or reasoning work introduces BMM-side elements (probably not) |
| §4 Comprehension Architecture and the BMM | §4.3 three-register model: update to reflect Stage 7 closure and Ears instance validation. Clarify post-Session-147 convergence findings |
| §5 Cross-Domain Validation | §5.3 validation findings: add Ears (analytical intake complete, clinical domain, sector-regulated, vocabulary adequate at Ears-level complexity). Add cross-domain validation of S199 seven-band framing (three domains so far) |
| §6 Package Structure | Minor — stable |
| §7 Mapping to the Existing System Model | **Substantial update.** Portal domain context model as first direct consumer of BMM concern structure at runtime. Module wiring via concern overlap. Composition guidance via concern intersection. This is where Stage 8 most clearly touches the BMM |
| §8 Business Model Variants | Minor — no significant changes |
| §9 Two Meta Models | **Amend to introduce four-level vocabulary.** BM and SM as configured models distinct from BMM and SMM. BR/BS as dynamic runtime state. This is the SBMM locus for the S195/S197 clarifications |
| §10 Simulation | Minor — possibly add a note about the portal's simulation infrastructure as a partial operational simulation (L5) prototype |
| §11 BMM in the Knowledge Graph | Update counts. Note the KG's expanded role as runtime substrate for BR |
| §12 Forward Direction | Update — Stage 7 closed, Ears complete, Stage 8 complete, Stage 9 foundation laid. Remove items that are done |
| Related Documents | Add all Stage 9 foundation papers, Stage 8 papers. Update V&A to v12, Architecture Principles to v5, Platform Modelling Strategy to v5 |

**Anticipated length change:** +10% to +20%. The lightest of the three.

---

## 6. Sequence and Pacing

The decision of which paper to refresh first matters because each informs the others.

**Recommended sequence:**

1. **Architecture Principles first.** Reason: it is the conceptual anchor for the other two. The four-level discipline amendment, the agent layer additions, the static/dynamic duality, the surface architecture section — all of these are principle-level commitments that the other two papers then reference. Getting them right once, in the most compact paper, means the second and third passes can cite them rather than re-invent them.

2. **Platform Modelling Strategy second.** Reason: it is the heaviest rewrite, and it depends on Architecture Principles being stable. Once the principles are settled, the modelling strategy can work out how those principles are realised in the package architecture, generation pipeline, and two-formalism architecture.

3. **Service Business Meta Modelling third.** Reason: it is the lightest rewrite and benefits from the first two being done. SBMM's §7 (mapping to existing system model) and §9 (two meta models) can reference the already-settled Architecture Principles §3/§5.5 and Platform Modelling Strategy §7 rather than re-derive the positions.

**Cross-paper consistency pass after all three.** A final pass across all three papers checks that cross-references match (e.g., SBMM's reference to Architecture Principles v5 is correct, not v4.1), that terminology is uniform, and that the four-level vocabulary is stated identically where it appears in more than one place.

**Pacing.** This is almost certainly more than one session, given the size. My estimate:
- Architecture Principles refresh: one focused session (substantive but contained).
- Platform Modelling Strategy refresh: one focused session, possibly one and a half given its size.
- SBMM refresh: one focused session.
- Cross-paper consistency pass: half a session.
- **Total: 3.5–4 sessions.**

The current session (S208) should, in my view, focus on **Architecture Principles alone** — drafting it end-to-end with full agreement on the integration opportunities before moving on. This gives us a concrete first paper to review, establishes the vocabulary for the other two, and is a natural stopping point if context constraints or energy suggest pausing.

**Alternative interpretation.** If you want to go harder in this single session, we could complete Architecture Principles in the first half and begin Platform Modelling Strategy in the second. I would not recommend attempting all three in one session — the quality ceiling drops sharply when the refresh becomes mechanical rather than considered.

---

## 7. Procedure

For each paper, the procedure is identical:

**Step 1 — Archive-before-refresh (Ella).** You duplicate the paper via Obsidian UI into `07 Ontara History & Archive`, renaming with `SUPERSEDED-` prefix and versioned suffix (e.g. `SUPERSEDED-ontara-architecture-platform-principles-v4.1-s170.md`). Confirm to me that the archive copy is in place. This preserves wikilinks across ~60+ references.

**Step 2 — Section-by-section review (Ella + Claude).** We walk through the paper section by section against the treatment in §5. For each section I propose the specific changes; you agree, adjust, or redirect. No edits are made until the plan for that paper is settled. This is the bandwidth-intensive step.

**Step 3 — Execute edits via MCP `filesystem:edit_file` (Claude).** Targeted edits based on the agreed plan. For very heavy sections (e.g. Platform Modelling Strategy §12), multiple sequential edits.

**Step 4 — Read-through verification (Claude).** Read the post-edit paper in full. Verify: (a) the header version history is updated, (b) all agreed changes are in place, (c) no cross-reference is broken, (d) tables with wikilinks use escaped pipes, (e) contents index uses Obsidian-native `[[#heading|display text]]` format (the standing regression per workflow guide §5.0).

**Step 5 — Concept graph source drift check (Claude).** Per workflow guide §7.1, scan concept graph principle and concept notes whose `source:` YAML field or `## Source` section references the refreshed paper. Update source references where they are now stale.

**Step 6 — Update the work item tracker's Document Currency Register (Claude).** At C2. Update the Last refreshed column to S208 (or S209 etc.), update the Next due column, update the Notes to record what was refreshed and how.

**Step 7 — At session close (Claude).** Per §2.3 of the workflow guide: session report, preparation note, work item tracker updates including W-049 status, reference document updates, emergent ideas log review, vault placement, wikilink enrichment, repo archive commands.

---

## 8. Cross-Paper Consistency Rules

These rules apply across all three papers. Failing any of them is a regression.

1. **Four-level vocabulary must be stated identically.** Foundation → Metamodel → Configured model → Generated output. No variation in order, no paraphrasing.
2. **"Metamodel" spelling.** W-047 normalised to "metamodel" (one word, no hyphen) across the vault for common-noun uses. Formal artefact names ("Business Meta Model (BMM)", "System Meta Model (SMM)", "two meta model distinction" as principle name) retain their existing spacing. This must hold across all three papers.
3. **BMM / SMM / BM / SM / BR / BS vocabulary must be used precisely.** BMM and SMM are meta models. BM and SM are configured models (tenant-specific). BR and BS are runtime state. No sloppy "BMM runtime state" phrasing.
4. **Register counts must match.** T1/T2/T3/T4 counts, total concept counts, BMM elements, SMM classes, SPARQL queries, ontology files. All three papers must cite the same numbers. Canonical source: the strategic snapshot refreshed at S203, updated for any register additions since.
5. **Related Documents must cross-reference correctly.** Architecture Principles v5 ↔ Platform Modelling Strategy v5 ↔ SBMM v4. V&A v12. Strategic Reference. Master Concept Register. Work Item Tracker.
6. **Concept code references must be live wikilinks.** Every A/B/C/D/J/etc. code must resolve to a concept graph note. Where a note does not exist and should, it is created per workflow guide §8.4.
7. **Tables with wikilinks must use escaped pipes** (`[[file\|text]]`). This is the recurring regression (§12 known pitfall in workflow guide). Check every table in every paper.
8. **Contents indices must use Obsidian-native format** (`[[#heading|display text]]`). This is the other recurring regression (§5.0 of workflow guide). Check every contents index.
9. **Vault document locations are wikilinks only, never path strings.** Per workflow guide §13 and OW-36 convention reinforced S194.

---

## 9. Deliverables and Success Criteria

**Deliverables:**
- [[ontara-architecture-platform-principles|Architecture Principles v5]]
- [[ontara-architecture-platform-modelling-strategy|Platform Modelling Strategy v5]]
- [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling v4]]
- Three `SUPERSEDED-` archive copies in [[—— HISTORY & ARCHIVE INDEX ——|07 Ontara History & Archive]]
- Updated [[ontara-ref-work-item-tracker|work item tracker]] — Document Currency Register for all three papers; W-049 status `open` → `done`
- Session report and preparation note at close
- Any concept graph note source-drift fixes

**Success criteria:**
- [ ] All three papers reflect Stage 7 full closure (Phases 2–4)
- [ ] All three papers reflect Ears clinical domain intake and validation
- [ ] All three papers reflect Stage 8 portal as a first-class application (Stage 8 currently absent)
- [ ] All three papers incorporate the four-level vocabulary from S195
- [ ] All three papers reflect the BR/BS substrate and bindings framing from S197
- [ ] All three papers reflect the surface architecture material from S198/S199 where relevant
- [ ] A4 has been amended with the four-level discipline
- [ ] The constraint hierarchy → UI affordance mapping insight (D28) is stated in Architecture Principles and Platform Modelling Strategy
- [ ] The static/dynamic duality is stated in Architecture Principles §5.5
- [ ] The agent layer additions to A9 and A3 are made
- [ ] Cross-paper consistency rules (§8) all hold
- [ ] Version history tables updated
- [ ] Concept graph source references updated for stale entries
- [ ] Work item tracker updated with W-049 complete and document currency rows updated
- [ ] All three papers render correctly in Obsidian (contents indices work, wikilinks resolve)

---

## 10. Risks and Mitigations

| # | Risk | Mitigation |
|---|---|---|
| R1 | Scope creep — the refresh uncovers more changes than anticipated and the session runs long | The plan explicitly permits stopping after any one paper. Architecture Principles alone is a valid outcome for S208 |
| R2 | Conceptual fracture mid-session — we find that two recent pieces of thinking conflict and the refresh exposes the conflict | Flag it in the moment, capture it as an emergent idea, continue with the less-contested material. Do not attempt to resolve an architectural tension in a housekeeping session |
| R3 | Register count drift — I quote stale numbers that the strategic snapshot does not yet reflect | Cross-check every quoted count against the S203 strategic snapshot and the work item tracker at the moment of use |
| R4 | Wikilink/table regression — the standing pitfalls re-emerge | Apply the cross-paper consistency rules at §8. Run a targeted final check on every table and contents index before finalising each paper |
| R5 | A4 amendment wording that doesn't hold up under challenge | Draft in place, then pause and critique per workflow guide §2.2. This is exactly the "critique at design milestones" trigger. Structured critique before proceeding |
| R6 | Concept graph source drift not caught | Per workflow guide §7.1, the scan is mandatory. Do not skip |
| R7 | Pacing misjudgement — tackling too much and producing lower-quality output | Explicitly plan to stop at a natural break. Quality over quantity |
| R8 | Parallel work interaction — W-043 master register additions are still pending and may conflict with the foundations papers amendments | The foundations papers should state their amendments in narrative form, referencing forthcoming register entries (B40, B43, etc.) where needed. The register is then updated in a subsequent session to match. The foundations papers lead; the register catches up |

---

## 11. Dependencies and Deferred

**Dependencies (must be in place before the refresh proceeds):**
- [[ontara-ref-work-item-tracker|Work item tracker]] current (is, as of S207)
- [[ontara-ref-strategic-snapshot|Strategic snapshot]] current (is, S203 — slightly stale on registrations but good enough)
- All five Stage 9 discussion papers available (are)
- Archive-before-refresh performed by Ella for each paper as we come to it

**Deliberately deferred to later sessions:**
- [[ontara-ref-work-item-tracker|W-043]] master register additions for S197/S198/S199 concepts (still outstanding for BR/BS, bindings, operator workspace, etc.)
- [[ontara-ref-work-item-tracker|W-045]] Campus Walk II and architecture diagram revision
- Individual concept note rewrites beyond source drift fixes
- Strategic snapshot refresh (approaching ~S210 threshold — may be needed alongside or after the foundations refresh)
- Vision & Architecture Reference further refresh (already v12, current)

---

*Plan drafted at O5 by Claude, Session 208. To be reviewed and agreed with Ella before any edits are made. Plan itself is a working document and will be placed in the vault at [[02 Ontara Development/Ontara Plans/]] once agreed.*

GenderSense Limited.
