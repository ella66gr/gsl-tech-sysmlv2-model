---
tags:
  - session-report
date: 2026-04-12
status: current
session: 197
---
# Session 197 Report

> `= this.file.path`

**Date:** 12 April 2026
**Session type:** Discussion (architecture)
**Workstream:** Architecture (ARC) — preparation for Stage 9
**Previous session:** [[session-196-report-2026-04-12|Session 196]]
**Preparation note for next session:** [[session-198-preparation-note|Session 198 preparation note]]

---

## Contents

- [[#1. Session Summary|§1. Session Summary]]
- [[#2. Work Done|§2. Work Done]]
- [[#3. Architectural Conclusions|§3. Architectural Conclusions]]
- [[#4. Discussion Paper Produced|§4. Discussion Paper Produced]]
- [[#5. Register Concepts|§5. Register Concepts]]
- [[#6. Observations and Watchpoints|§6. Observations and Watchpoints]]
- [[#7. Tier 1 Principles Engaged|§7. Tier 1 Principles Engaged]]
- [[#8. Open Questions|§8. Open Questions]]
- [[#9. Governance Actions This Session|§9. Governance Actions This Session]]
- [[#10. Next Steps|§10. Next Steps]]

---

## 1. Session Summary

Session 197 was a discussion session focused on resolving conceptual ambiguities in the dual-stack architecture before Stage 9 planning can proceed. The session built on the three preceding discussion papers ([[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]], [[ontara-discussion-model-meta-model-distinction-2026-04-11|Model and Meta Model]], [[ontara-discussion-architectural-clarification-2026-04-12|Architectural Clarification]]) and on a new Omnigraffle architecture diagram that Ella produced incorporating the Session 196 four-layer model and bottom-up clarifications.

Three architectural matters that were previously unresolved or imprecisely formulated were settled in this session:

1. The static/dynamic duality of models, removing the need for the malformed term "metamodel runtime state".
2. The representational substrate of the Business System (BS) — the knowledge graph, with specialised stores referenced through bindings for content that does not fit triples.
3. The pattern by which the BS connects to real and simulated components — observational binding, distinguished from classical digital twinning.

A discussion paper was produced consolidating these conclusions and providing the architectural foundation for Stage 9 planning.

---

## 2. Work Done

### 2.1 Reading and orientation (O1–O3)

Claude read the [[ontara-workflow-guide|workflow guide]], the [[session-197-preparation-note|Session 197 preparation note]], the [[ontara-ref-strategic-snapshot|strategic snapshot]] (S194), the [[ontara-ref-work-items|work item tracker]] (with Document Currency Register, OW register, Active items table), [[ontara-ref-master-register|Master Register]] Tier 1, the [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]], and the five session-specific reference documents named in the session prompt: the [[ontara-discussion-architectural-clarification-2026-04-12|architectural clarification]] (S196), the [[ontara-discussion-model-meta-model-distinction-2026-04-11|model/meta-model distinction]] (S195), [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] (S192–193), the [[ontara-s192-discussion-connecting-everything|S192 Connecting Everything sketch]], and the Perplexity research note on interface and interaction.

Document Currency Register check at O2 confirmed all standing reference documents within threshold, with the Research & Background Index one session overdue (last refreshed S189, due ~S196). This was flagged for a check that has not yet been performed in this session — see §9.

Relevant OW items for ARC scope identified at O3: OW-32, OW-33, OW-34, OW-35, OW-37. OW-37 (architecture diagram extension) was the centre of gravity for the session.

### 2.2 Diagram review

Ella presented a revised architecture diagram (Omnigraffle, embedded in §1a of the [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|discussion paper]]) that extends the current console architecture map with several substantive moves: the four-layer model from Session 196 made spatially explicit per stack; BM and SM as first-class architectural sections distinct from BMM/SMM and from runtime aspects; a domain-specific meta model row inserted between General BMM/SMM and the model layer; Business Representation (BR) on the left and Business System (BS) on the right as Layer 4 sections; the Formalism Boundary as a real horizontal section rather than a decorative line; constraint containers split into Structural and Functional; real and simulated activity boxes drawn separately at the bottom and connected upward into BS; Reflective Simulation extended to span the full vertical height with two new capabilities (History analysis and Counterfactual analysis); Customer Portal and Developer Console relocated into Infrastructure.

Claude walked through the diagram section by section identifying what each move clarified, what it left open, and what it revealed about gaps in the existing terminology.

### 2.3 The "metamodel runtime state" correction

In response to Claude's first attempt to talk about "BMM runtime state" as the thing that needed an architectural home, Ella corrected the framing: meta models do not have runtime state. A vocabulary is the same set of templates and structural rules whether or not any specific business is currently doing anything. Models, on the other hand, can be dynamic — and a dynamic model intended to represent something else for some useful purpose is a simulation in the standard sense.

This correction was load-bearing for the rest of the session. It dissolved a category error that had been carried forward from [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] and the [[ontara-discussion-model-meta-model-distinction-2026-04-11|model/meta-model paper]], and replaced it with the cleaner static/dynamic duality of models.

### 2.4 The representational substrate question

Ella asked for a brief view on what the representational substrate of the BS actually is. Claude proposed: the knowledge graph, extended to hold dynamic instance data alongside the vocabulary and structural content it already holds, with five converging reasons (reasoning integration, structural alignment with the SM, named graph machinery for instantiation strata, bindings as model content, mapping rules as model content).

Ella confirmed and added the crucial boundary: typed semantic content sits in the [[concept-knowledge-graph|KG]]; long-form, free-form, or relatively unstructured content (such as clinical records in OpenEHR) is already taken care of in stores designed for it. Claude developed this into the substrate boundary pattern: KG for typed semantic content, specialised stores for content that doesn't fit triples, references via bindings — generalising the model-as-index pattern from [[ontara-discussion-architectural-section-implementation-design-2026-03-29|architectural sections]] to all content types.

### 2.5 The twinning question

Ella raised the concern that having tried to avoid digital twinning, it now seemed there was no avoiding it unless every component were built as an integral part of the model, which is neither necessary nor desirable. Claude developed the distinction between classical digital twinning (a parallel running model maintaining autonomous state, requiring continuous reconciliation) and observational binding (a model that observes real components through declared bindings, with no parallel autonomous state and therefore no reconciliation problem). The pattern works identically for synthetic-generator bindings used in simulated instantiations.

### 2.6 Discussion paper drafted

A discussion paper consolidating the session's architectural conclusions was drafted as a discussion document, written for the next session's reader. The paper deliberately presents conclusions cleanly rather than documenting the session's comprehension traversal. It is the architectural foundation from which the Stage 9 plan can be drawn.

---

## 3. Architectural Conclusions

The session reached the following conclusions, captured in the discussion paper:

**The static/dynamic duality of models.** A model has both a static aspect (configurational structure) and a dynamic aspect (evolving state). Both belong to the model. Meta models do not have runtime state. The terms "BMM runtime state" and "SMM runtime state" are category errors and are retired.

**BR and BS as the dynamic aspects of BM and SM.** Business Representation (BR) is the BM in its dynamic mode of operation — the model representing the actual state of the business in the world. Business System (BS) is the SM in its dynamic mode — the model representing the live state of the system that runs the business. Neither is "below" the model layer; they are aspects of it.

**The four-layer model resolves into three layers.** What [[ontara-discussion-architectural-clarification-2026-04-12|Session 196]] distinguished as Layer 3 (Configured model) and Layer 4 (Generated output) is more accurately understood as the static and dynamic aspects of a single model layer. Foundation, Meta model vocabulary, Model — with the model layer having two aspects.

**Unity of the BS across instantiation modes.** The BS is one model, instantiated in real mode (bound to actual infrastructure) or simulated mode (bound to synthetic generators). The structure, state machines, and mapping rules are invariant; only the bindings vary. Real and simulated instantiations can coexist.

**The representational substrate of the BS is the knowledge graph.** This is a material expansion of the KG's role, anticipated by [[ontara-ref-work-items|OW-34]]. The expansion is the architecturally honest answer; engineering challenges around write throughput, transaction semantics, and round-trip diff under continuous mutation must be addressed in Stage 9 design.

**BR sits in the same substrate by the same logic.** PostgreSQL or equivalent relational stores may have a role only as a derogation justified by concrete requirements that the KG cannot meet.

**The substrate boundary pattern.** Typed semantic content lives in the KG; long-form, free-form, large or unstructured content lives in specialised stores (OpenEHR for clinical narrative being the canonical case); bindings carry references between them. This generalises the model-as-index pattern.

**Bindings are first-class model elements.** They declare what model element they correspond to, how state change becomes a BS event, how instructions become actions, and what freshness/fidelity profile they provide. Six characteristic binding types: rich event-stream, API-polled, webhook-receiving, human-mediated, inferential, synthetic-generator.

**Observational binding, not classical twinning.** The BS observes real components rather than running a parallel autonomous implementation of them. There is therefore no reconciliation problem because there is no parallel state to reconcile.

**Horizontal mapping rules are first-class model content.** They live in the KG as declarative content, are reasoning-tractable, and execute identically across real and simulated instantiations. The exact rule language (SHACL, SPARQL Update, a domain-specific OWL vocabulary, or a combination) is a Stage 9 design question.

---

## 4. Discussion Paper Produced

[[ontara-discussion-bs-substrate-and-bindings-2026-04-12|The Business System: Substrate, Bindings, and the Dynamic Aspect of Models]] — 12 sections, including 10 open questions for Stage 9 planning, register connections, and observations to deposit.

The paper supersedes the "BMM runtime state" / "SMM runtime state" formulations used in [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] §6 and the [[ontara-discussion-model-meta-model-distinction-2026-04-11|model/meta-model paper]] §6. Editorial updates to those papers are flagged in the OW register entries (§6 below) for completion before Stage 9 plan production.

---

## 5. Register Concepts

The discussion paper proposes the following register changes for the C2 update and any subsequent registration session:

| Concept | Section | Status | Note |
|---|---|---|---|
| BR (Business Representation) | B (Structural Architecture Concepts) | Newly named | The dynamic aspect of BM |
| BS (Business System) | B | Newly named | The dynamic aspect of SM |
| Static/dynamic duality of models | A or B | New structural insight | May warrant amendment to [[principle-two-meta-model-distinction\|A4]] or [[concept-dual-stack-architecture\|B21]] |
| Binding | B | New first-class model element | Connects BS model elements to real or simulated components |
| Horizontal mapping rule | B | New first-class model element | The connecting layer of the dual stack at the configured-model level |
| Substrate boundary pattern | D (Validated Architectural Patterns) | New pattern | KG for typed semantic content, specialised stores for unstructured content, references via bindings |
| Observational binding | D | New pattern | Distinguishes the architecture from classical digital twinning |
| KG role expansion to runtime instance substrate | B (amendment to [[concept-knowledge-graph\|B22]]) | Amendment | The KG is now the canonical substrate for BR and BS as well as for vocabulary and structural content |

These are proposals for the next session's C2 update. They are not yet committed in the master register itself.

---

## 6. Observations and Watchpoints

The following observations from this session should be deposited in the [[ontara-ref-work-items|OW register]] at C2:

| Summary | Work type | Notes |
|---|---|---|
| The static/dynamic duality of models is a structural insight that may warrant a register entry of its own; check whether existing [[principle-two-meta-model-distinction\|A4]] or [[concept-dual-stack-architecture\|B21]] formulations need amendment | ARC, GOV | Surfaced this session; relevant whenever architectural foundations are revised |
| The KG's role expansion to runtime instance substrate has engineering consequences (write throughput, transactions, named graph organisation, query load, round-trip diff relationship) that must be designed before commitment | KGO, ARC | OW-34 reframed and sharpened by this paper |
| The binding registry surfaces a new console view ("which model elements have live infrastructure bound to them, with what freshness") that connects to Connecting the Stacks Q6 | CON, ARC | New console view candidate; depends on binding vocabulary being defined |
| The horizontal mapping rule vocabulary is a new generation target — the pipeline will need to handle declarative rule content and the console will need to display it | KGO, CON | New work area opened by this paper |
| Freshness/fidelity propagation from bindings into BR and into L6's analytical output is a cross-cutting design question that touches comprehension architecture and operator surface design alike | RGV, CON | Surfaced this session |
| The retirement of "BMM/SMM runtime state" terminology requires updates to [[ontara-discussion-connecting-the-stacks-2026-04-10\|Connecting the Stacks]] and [[ontara-discussion-model-meta-model-distinction-2026-04-11\|the model/meta-model paper]] | GOV | Editorial; should be done before Stage 9 plan production |
| The Perplexity research on interface and interaction (operator workspace, agent roles, capability matrix, Ask/Plan/Simulate/Act modes) is a substantial body of architectural input on the surface side that has not yet been folded into the architecture; warrants its own discussion paper | ARC, CON, GOV | Read in this session but deliberately not folded into the substrate paper. Surface architecture is a parallel workstream that will need to converge with the substrate work before Stage 9 plan finalisation |
| OW-37 (architecture diagram extension) is partially progressed by the Session 197 discussion paper, which provides the conceptual framing for the BR/BS additions, but the diagram itself still needs revision and Campus Walk II remains to be done | ARC, GOV | Update OW-37 status to reflect conceptual progress |

OW-37 should be updated at C2 to reflect that the conceptual prerequisites for Campus Walk II and the diagram revision are now in place via the Session 197 discussion paper. The visual diagram revision and the section-by-section walk remain.

---

## 7. Tier 1 Principles Engaged

| Principle | How it was honoured |
|---|---|
| [[principle-separation-representation-execution\|A1]] | The observational binding pattern is A1 made operational at the boundary between the model and reality. The session deepened the operational reading of A1 |
| [[principle-self-describing-system\|A2]] | Bindings carry freshness/fidelity profiles as model content — A2 made concrete at the model–reality boundary |
| [[principle-model-generates-everything\|A3]] | Bindings and mapping rules are model content; the binding registry should ultimately be generable from the model |
| [[principle-two-meta-model-distinction\|A4]] | The BR/BS framing is the dual stack made dynamic; the static/dynamic duality may warrant an amendment to A4 |
| [[principle-deterministic-over-probabilistic\|A6]] | Mapping rules are declarative, inspectable, and reasoning-tractable — A6 preserved at the runtime boundary |
| [[principle-discipline-as-load-bearing-structure\|A9]] | The session followed workflow guide §1 commitment 5 (genuine critique at design milestones) and §1 commitment 1 (Ella leads, Claude supports) — Claude proposed substrate options and waited for Ella's confirmation rather than committing on her behalf |
| [[principle-intrinsic-self-knowledge\|A10]] | Freshness/fidelity in bindings is intrinsic self-knowledge: the system computes its own confidence from declared metadata, not from human-edited descriptions |
| [[principle-unity-principle\|A11]] | The unity of the model across instantiation modes is A11 made concrete |
| [[concept-co-evolution\|J2]] | The binding vocabulary and the mapping rule vocabulary are new generation targets that will require co-evolved tooling |
| [[concept-non-constraining\|J3]] | The substrate boundary pattern preserves optionality: specialised stores are first-class for content that needs them, KG is canonical for typed semantic content, bindings declare the boundary explicitly |
| [[concept-multi-tenancy\|A13]] | Bindings and mapping rules are tenant-specific (configured-model level), preserving the platform/tenant separation |

---

## 8. Open Questions

Ten open questions for Stage 9 planning are documented in §11 of the discussion paper and not duplicated here.

Two additional questions surfaced during the session that are not in the paper:

- Whether the surface-side architectural work (operator workspace, agent roles, capability matrix from the Perplexity research) should be developed as its own discussion paper before Stage 9 planning, or folded into the Stage 9 plan production process.
- Whether the diagram revision and Campus Walk II should be done before Stage 9 plan production or in parallel with it.

Both are scope questions for Session 198 to decide.

---

## 9. Governance Actions This Session

- O2 currency check performed against the Document Currency Register: all standing reference documents within threshold except R&B Index (one session overdue, due ~S196). The R&B Index check was flagged in the prep note for early in S197 but was not performed during the session — work was redirected to architecture discussion. Carry forward to S198.
- No reference documents were refreshed.
- No periodic governance tasks were completed.
- No work items in the Active Work Items table were resolved (the table was empty at session open).
- One discussion paper was produced ([[ontara-discussion-bs-substrate-and-bindings-2026-04-12|BS Substrate and Bindings]]).
- OW register updates pending at C2: OW-37 status update; new OW items deposited per §6 above.

---

## 10. Next Steps

Documented in the [[session-198-preparation-note|Session 198 preparation note]]. Summary: Session 198 should decide between several candidate workstreams that follow from the Session 197 discussion paper, including diagram revision, Campus Walk II, surface-architecture discussion paper production, editorial updates to Connecting the Stacks and the model/meta-model paper, and Stage 9 plan production. The R&B Index check carries forward.

---

*Session 197 report. Discussion session producing the BS Substrate and Bindings discussion paper as the architectural foundation for Stage 9 planning. Three architectural matters resolved: the static/dynamic duality of models, the KG as the BS substrate, and observational binding as the connection pattern. GenderSense Limited.*
