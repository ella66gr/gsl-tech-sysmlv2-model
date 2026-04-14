---
tags:
  - session-report
date: 2026-04-14
status: current
session: 210
---
# Session 210 Report

> `= this.file.path`

**Date:** 14 April 2026
**Session type:** Implementation — Architecture Principles v5 drafting (first substantive v5 session)
**Workstream:** [[ontara-ref-work-item-tracker|W-049]] — foundations papers full refresh (v5 drafting phase)

---

## Contents

- [[#1. Summary|§1. Summary]]
- [[#2. What Was Done|§2. What Was Done]]
- [[#3. Architectural Findings|§3. Architectural Findings]]
- [[#4. Register Concepts Exercised|§4. Register Concepts Exercised]]
- [[#5. Emergent Ideas|§5. Emergent Ideas]]
- [[#6. Observations and Watchpoints|§6. Observations and Watchpoints]]
- [[#7. Open Questions and Deferred Items|§7. Open Questions and Deferred Items]]
- [[#8. Tier 1 Principles and How They Were Honoured|§8. Tier 1 Principles and How They Were Honoured]]
- [[#9. Governance Actions|§9. Governance Actions]]
- [[#10. Deliverables|§10. Deliverables]]

---

## 1. Summary

Session 210 executed the first substantive drafting of Architecture Principles v5 under [[ontara-ref-work-item-tracker|W-049]]. Three of the load-bearing sections were drafted in full: §3 (The Stratified Two-Side Architecture), §5 (Foundational Architecture, nine subsections), and §2 (The Self-Describing System). The structural critique discipline (workflow guide §1 commitment 5, §2.2) was applied at three gates during the session — after §3, after §5, and after §2 — and all three gates passed.

Two substantive architectural decisions were committed in the draft: the KG-canonical commitment promoted [[concept-knowledge-graph|B22]] from directional to binding, and [[concept-coordinate-framework|A12]] was promoted from Tier 1 candidate to binding Tier 1 on the strength of the operational realisation provided by the State Representation Stratum. The runtime-state acronym on the system side was renamed from BS to **SR (System Runtime state)** for symmetry with BR, resolving [[ontara-ref-work-item-tracker|OW-85]].

The five-principle unification hypothesis ([[ontara-ref-work-item-tracker|OW-77]]) was tested progressively against the draft and passed Test 1 cleanly for Architecture Principles v5 — [[principle-self-describing-system|A2]], [[principle-intrinsic-self-knowledge|A10]], [[principle-unity-principle|A11]], [[concept-coordinate-framework|A12]], and [[concept-coordinate-space-snapshots|L8]] are all stateable as consequences of the strengthened A4 without introducing new content not derivable from A4. This is the substantive architectural finding of the session at the unification level.

The draft was approached as a full rewrite rather than as targeted edits to v4.1. This was an agreed methodological departure from the S208 foundations refresh plan (which anticipated targeted `edit_file` operations) after explicit discussion of the risks of in-place editing of long documents where conceptual changes propagate through nearly every section. Ella archived v4.1 via the Obsidian UI to `07 Ontara History & Archive` before drafting began. The v5 draft is held outside the canonical filename as a partial draft (`ontara-architecture-platform-principles-v5-DRAFT-s210.md`) pending completion in subsequent sessions.

Approximately 11,000 words of new foundational prose were drafted across §3, §5, and §2. The remaining sections (§1, §4, §6–§10, Appendix, Related Documents) are held as TBD placeholders for S211 completion — each is either a light edit to substantively current v4.1 material or a medium edit incorporating Stage 8 / Stage 9 findings that do not need the strengthened A4 framework to land.

The strategic snapshot refresh decision (§2 Priority A2 of the S210 preparation note) was made at O4 with Ella choosing Option 2 — defer full refresh to S211. This is the first acknowledged threshold breach since the 7-session convention was adopted; the breach is noted in §9 below as an explicit governance exception with commitment to refresh at S211.

---

## 2. What Was Done

### 2.1 Session open

The session opened with Claude reading the preparation note, workflow guide, work item tracker, strategic snapshot header, and master register Tier 1 in full. The Document Currency Register check at O2 showed the strategic snapshot at exactly the 7-session threshold (refreshed S203, current session S210). All other reference documents were comfortably current. The OW register scan at O3 identified the items directly relevant to v5 drafting — [[ontara-ref-work-item-tracker|OW-76]], [[ontara-ref-work-item-tracker|OW-77]], [[ontara-ref-work-item-tracker|OW-79]], [[ontara-ref-work-item-tracker|OW-80]], [[ontara-ref-work-item-tracker|OW-81]], [[ontara-ref-work-item-tracker|OW-82]], [[ontara-ref-work-item-tracker|OW-83]], [[ontara-ref-work-item-tracker|OW-84]], [[ontara-ref-work-item-tracker|OW-85]], [[ontara-ref-work-item-tracker|OW-86]] — all as active at session open.

O4 scope agreement covered the strategic snapshot decision (resolved as Option 2), the §3 critique gate confirmation, the A12 promotion handling, the prohibition 5 placement, and the BS → SR rename. All six decisions were agreed before drafting began.

### 2.2 Methodological departure — full rewrite rather than targeted edits

Ella raised a methodology concern at the start of drafting: substantial `edit_file` operations against long pre-existing documents have historically produced bumbling and fumbling, and a full rewrite might be cleaner. Claude evaluated the options in detail — five arguments for full rewrite (character of changes is conceptual not editorial; "nothing persists by antiquity" licence; five-principle unification may make v5 more compact; in-place editing failure modes; and the fact that filename identity rather than content identity is what preserves the ~60+ wikilinks to the paper) versus one argument for surgical edits (preservation of v4.1 passages that are still correct). The preservation concern was better addressed by reading v4.1 carefully first and treating its load-bearing passages as quotation-grade rather than by editing in place.

The agreed workflow became: archive v4.1 via Obsidian UI; Claude reads v4.1 + integrated workshop document + foundations refresh plan; Claude produces a structural plan for v5 sign-off; Claude drafts v5 as a container artifact outside the canonical filename; the draft replaces v4.1 at the canonical filename only when complete. This is a deliberate departure from the S208 foundations refresh plan's §7 procedure ("execute edits via MCP `filesystem:edit_file`"), adopted for this refresh on the specific ground that the conceptual changes propagate through nearly every section and targeted edits would be fragile.

### 2.3 The structural plan for v5 and sign-off

Claude produced a detailed structural plan covering: the overall shape of v5 (10 sections plus appendix, same section count as v4.1); a section-by-section treatment showing what survives from v4.1, what is substantially new, and what is reorganised; a priority order for S210 (§3 → critique → §5 → §2); the critique gate at §3 completion; the handling of three open questions (A12 promotion, prohibition 5 placement, BS → SR rename); and the five-principle unification hypothesis tracking mechanism. Ella signed off on the structural plan with the explicit instruction that we could take as much resource as needed for quality — "we want the best result".

Ella shared two versions of the working architecture diagram during the session: version 1.0 at the start (showing the six strata, BR/BS pairing, and the activity flows) and version 1.1 later in the session (with BS renamed to SR, simulated/projected activity relocated inside the Reflective Simulation box, and real-world activity moved below the Infrastructure band). Both versions were treated as orientation rather than as canonical — the v5 prose states the strengthened A4 in terms the diagram is converging toward rather than in terms of any single diagram snapshot.

### 2.4 §3 — The Stratified Two-Side Architecture

§3 was drafted first as the load-bearing section of v5. The section sources from §4 (Draft D2) of the [[WORKSHOP-s208-a4-reformulation-INTEGRATED|integrated workshop document]], adapted for the foundations-paper register and voice.

The section structure followed D2: principle statement → §3.1 six strata (Foundation, Formalism Boundary, Metamodel, Configured Model, State Representation, Platform Realisation) → §3.2 two sides (business, system) → §3.3 compositional structure with the ten-loci grid table → §3.4 five prohibitions → §3.5 eight enables → §3.6 historical lineage. The section explicitly states **ten loci, not eleven** (correcting the S208 delta's arithmetic error per OW-86). The section uses **SR throughout**, not BS, per the OW-85 rename. The DPA-informed writing discipline (OW-83) was held throughout — no paragraph forecloses portability, and platform-global content is explicitly framed as "subject to the Domain Portability Architecture being designed".

The §3 critique gate was run at completion. All five critique dimensions (logical coherence, significant omissions, alternative approaches, untested assumptions, risks) were evaluated. Coherence was good with one tightening opportunity considered and deferred (the five-relationships sentence in §3.1 — kept as is). One omission was flagged for §5 handling (the General/Tailored sub-structuring at the Metamodel stratum — fixed after §5 was drafted). Two alternative approaches were considered and rejected on principled grounds. Three assumptions were named and shown to be robust or explicitly held. Three risks were named with mitigations. §3 passed the gate.

Ella signed off on §3 with the explicit confirmation to proceed to §5 in the same session.

### 2.5 §5 — Foundational Architecture

§5 was drafted in full across nine subsections. The treatment was:

- **§5.1 The coordinate framework** — substantively current from v4.1 with one major addition: [[concept-coordinate-framework|A12]] was committed for promotion from Tier 1 candidate to binding Tier 1. The promotion rests on the strengthened A4 operationalising A12 through the SRS (the SRS *is* the coordinate space made queryable). This resolves [[ontara-ref-work-item-tracker|OW-84]] in the draft; the master register update is a W-043 follow-up.
- **§5.2 Domain identity** — light update for Ears intake.
- **§5.3 Temporal reference frames** — light update.
- **§5.4 Ontological grounding** — light updates.
- **§5.5 The dual-stack architecture, reframed** — substantially rewritten. [[concept-dual-stack-architecture|B21]] now a consequence of the strengthened A4 rather than a freestanding commitment. Static/dynamic duality from S197 absorbed. A paragraph on General/Tailored sub-structuring at the Metamodel stratum was added after the initial §5 draft, fixing the omission flagged in the §5 critique.
- **§5.6 Ontological formalism and the knowledge graph** — substantially rewritten. The KG-canonical commitment was made binding, promoting [[concept-knowledge-graph|B22]] from directional. Consequences stated plainly: hand-authored OWL modules as first-class canonical content; the round-trip diff engine reframed as projection-fidelity verification; the SysML model as not a complete view of the platform (OW-79); portable format RDF constraint; Formalism Boundary stratum lopsidedness.
- **§5.7 The State Representation Stratum** — new subsection, ~2,200 words, the longest in §5. Sources from §6 (SRS Definitive Inventory) and §7 (Real-World vs Synthetic Resolution) of the integrated workshop document. Structured as: what the SRS contains (seven kinds of content); what the SRS does not contain; the four defining properties of SRS content; the simulation architecture (L5–L9) as expressions of the SRS rather than independent capabilities; and the real-world vs synthetic indistinguishability finding. The last of these is registered as the operational realisation of OW-76.
- **§5.8 The Platform Realisation Stratum and bindings** — new subsection. PRS contents named; bindings as typed contracts at the SRS/PRS boundary; action class as a deterministic computation from binding metadata (the S198 principal contribution); the A9 extension on bounded agents ("agent guided by model truth, not by prompt cleverness"). Binding declaration vocabulary explicitly deferred as a Stage 9 design concern with OW-46 as the surfacing mechanism.
- **§5.9 Surface architecture** — new subsection. User bands (B41), surface families (B42), experience-API / BFF layer (B43), headless five-layer architecture (B44), state placement discipline (J15), the constraint hierarchy as architectural spine (forward reference to §7, D28 candidate), and the Stage 8 portal reframed as a band 5 surface within a larger surface family (absorbing the OW-55 / S200 reframing).

The §5 critique gate was run at completion of §5. Logical coherence held with one structural observation (§5.7's length is architecturally justified — kept as one subsection with five sub-subsections). Three omission candidates were evaluated: the General/Tailored fix (made), the reasoning metamodel detail's home (confirmed as §2), and the Ontara Console treatment (confirmed as adequate at the current level). Two alternatives were considered and rejected (A12 promotion deferral; keeping L5–L9 as a separate subsection). Two assumptions were named. Two risks were named with mitigations. §5 passed the gate.

The General/Tailored omission fix was applied after Ella's sign-off to proceed to §2, via a targeted `str_replace` adding a single paragraph to §5.5.

### 2.6 §2 — The Self-Describing System

§2 was drafted as the section where the five-principle unification hypothesis (OW-77) gets its Test 1 treatment. The six sub-subsections are: §2.1 the comprehension architecture (three registers, reframed against the SRS); §2.2 weighted relationships and the unity of the model (A11 given a strengthened operational reading); §2.3 the reasoning metamodel as cross-cutting SMM extension; §2.4 the five-principle unification (the explicit test); §2.5 what the unification means for downstream work; §2.6 what survives from v4.1.

The unification test was run explicitly for each of the five principles in §2.4, with each test structured identically (principle statement → strengthened-A4 reading → test result). **All five principles passed Test 1.** The composite result is reported plainly in the draft: the hypothesis holds for Architecture Principles v5.

This is the substantive architectural finding of S210 at the unification level. v5 §2 is substantially more compact than v4.1's §2 because A2, A10, A11 no longer each carry their own "why self-description is possible" argument — the argument happens once (the SRS is homogeneous and queryable) and all three principles follow. This is the unification's practical payoff: the paper is tighter without losing substance.

The §2 critique gate was run at completion. Logical coherence held. Two omission questions were considered and both resolved as no omission (A2 tested strictly enough; A6 not part of the hypothesis scope). Two alternatives were considered and rejected (cautious reporting; restructure mirroring v4.1). Three assumptions were named — the test fairness (derivations shown to be from §3 content, not smuggled), the transfer to implementation (explicitly deferred to Test 5 / Stage 9), and the choice of which five principles to test (defended). Two risks were named — the unification claim being misread as retirement, and Tests 2/3 failing — both with mitigations in the prose. §2 passed the gate.

### 2.7 What was not done

The following sections remain as TBD placeholders in the v5 draft and are deferred to S211:

- §1 (The Separation Principle) — light to medium edit
- §4 (Multi-Tenancy) — light edit
- §6 (The Clinical Data Architecture) — minimal edit
- §7 (Governance as a First-Class Concern) — medium edit with new subsection on constraint hierarchy as architectural spine
- §8 (External Service Integration) — minimal edit
- §9 (Data Availability and Aggregation) — medium edit
- §10 (Guiding Constraints) — medium edit including prohibition 5 from §3 as a guiding constraint
- Appendix A — minimal edit
- Related Documents — full refresh

Each section is either a light or medium edit to substantively current v4.1 material, or a medium addition (§7 constraint hierarchy spine) that does not need the strengthened A4 framework to land cleanly. S211 is positioned to complete v5 as a focused session.

The master register additions for v5 (A12 promotion formalised; B40 four-level distinction added; prohibition 5 placed in Section A or Section N; B21 amendment to reflect consequence-of-A4 status; B22 promotion formalised) are explicitly W-043 follow-up work and are not undertaken in this session.

---

## 3. Architectural Findings

### 3.1 The five-principle unification hypothesis holds for Architecture Principles v5 (Test 1)

The principal architectural finding of S210. [[principle-self-describing-system|A2]], [[principle-intrinsic-self-knowledge|A10]], [[principle-unity-principle|A11]], [[concept-coordinate-framework|A12]], and [[concept-coordinate-space-snapshots|L8]] can each be stated as a consequence of the strengthened A4 in v5 without introducing new content not derivable from A4. The test is run explicitly in v5 §2.4 with each principle's derivation documented. The composite result is that v5 §2 is substantially more compact than v4.1 §2, because A2, A10, A11 no longer carry their own arguments about why self-description is possible — the argument happens once (the SRS is homogeneous, queryable, and read by every subsystem as a realising component at the PRS) and all three principles follow.

**Implications.** Test 1 is one of five tests the integrated workshop document §9.3 defines. Tests 2 and 3 (Platform Modelling Strategy v5, SBMM v4) remain to be run in subsequent v5 drafting sessions. Tests 4 and 5 are longer-horizon (register treatment; Stage 9 falsifiable predictions). The hypothesis is so far holding for the principles that v5 has touched; if Tests 2 and 3 also pass, the hypothesis holds across the full foundations paper set and the project has a substantially more compact principled foundation than v4.1 offered. If Test 2 or Test 3 fails, the hypothesis is partial, and the partial result is itself useful — it would identify which principle has content not derivable from A4.

### 3.2 Two binding commitments promoted in the draft

Two architectural commitments were promoted from candidate / directional status to binding status in the v5 draft:

- **[[concept-knowledge-graph|B22]] (the knowledge graph as canonical store)** — promoted from directional to binding. The Session 73 formulation had committed the project to OWL 2 DL in a triple store as the *eventual* canonical representation, conditional on round-trip translation preserving all aspects of the model without degradation. By Session 137, the round-trip diff engine was complete and the conditional was satisfied. Continuing to hold KG-canonical as directional was understating the architectural reality. v5 §5.6 makes the promotion explicit with consequences stated plainly: hand-authored OWL modules are first-class canonical content; the round-trip diff engine verifies projection fidelity not canonical derivation; the SysML model is not a complete view of the platform; portable formats must be RDF-based. This is the resolution of OW-79.

- **[[concept-coordinate-framework|A12]] (the coordinate framework)** — promoted from Tier 1 candidate to binding Tier 1. A12 has been held as a candidate since Session 59 — a principle the project committed to in spirit but not in operational fact, awaiting a structural commitment that would make it cash out. The strengthened A4 is that commitment: the SRS *is* the coordinate space made queryable, each snapshot is a position in the space, the Region taxonomy catalogues kinds of region expressible as queries, and the constraint geometry maps the three-way constraint hierarchy onto coordinate-space structures. v5 §5.1 commits the promotion. This is the resolution of OW-84.

Both promotions are committed in the v5 draft and will be formalised in the master register as W-043 follow-up work.

### 3.3 The BS → SR rename

The runtime-state acronym on the system side has been renamed from **BS** (Business System runtime state, per S197) to **SR (System Runtime state)** throughout Architecture Principles v5. The rationale is symmetry: the acronym family now reads BMM/SMM at the Metamodel stratum, BM/SM at the Configured Model stratum, and BR/SR at the State Representation Stratum — each tier with matching first letters by side. The previous "BS" name collided phonetically with BSMM (the old pre-S92 name for SMM) and looked like it belonged on the business side because "B" marks business elsewhere in the architecture. The rename is cheap, the symmetry payoff is permanent, and v5 is the first paper to introduce the runtime-state acronyms in their canonical form so v5 is the right place to make the change. This is the resolution of OW-85.

The integrated workshop document, S197, S208, and earlier session artefacts still contain BS. These are working-history artefacts of the strengthened A4's emergence and are not retroactively rewritten; Architecture Principles v5 is the canonical source for the SR name going forward. A one-line note in v5's version history records the rename explicitly with reference to OW-85.

### 3.4 The ten loci

The S208 delta stated that the strengthened A4 produces eleven architectural loci in the stratum/side grid. The S209 integrated workshop document corrected the count to ten (2 shared strata + 4 split strata × 2 sides = 10). v5 §3.3 states the correct count of ten throughout, both in the grid table and in the prose. This is the resolution of OW-86 in the draft.

### 3.5 The real-world vs synthetic indistinguishability finding landed at foundations level

The finding that real-world and synthetic activity produce structurally identical SRS content (differing only by epistemic tagging and by which realising components are bound at the SRS/PRS boundary) is stated in full in v5 §5.7.5. This is one of the most substantive architectural findings from Session 208, first stated in the integrated workshop document §7, now landed in a foundations paper. The finding unifies the Stage 8 promotion path, the S197 observational binding pattern, and the [[concept-operational-simulation|operational simulation]] concept into a single architectural picture. The resolution of OW-76.

### 3.6 Three workbench-to-foundations transfers

Three architectural findings from S197, S198, and S199 were transferred from discussion-paper status to foundations-paper status in v5:

- **Bindings as typed contracts at the SRS/PRS boundary** (from S197) landed in v5 §5.8, with binding metadata properties (instantiation mode, freshness profile, production marker, authority zone) explicitly named.
- **Action class as a deterministic computation from binding metadata** (from S198) landed in v5 §5.8 as a consequence of the structural location of bindings, with the A9 extension on bounded agents as the operator-surface expression.
- **Surface families and the headless five-layer architecture** (from S199) landed in v5 §5.9 as foundational vocabulary, with B41/B42/B43/B44/J15 named in the prose and the constraint-hierarchy-as-architectural-spine finding (D28) cross-referenced.

These transfers turn discussion-paper material into foundations-paper commitments. The discussion papers remain as the working-out steps; v5 is where the commitments become part of the paper set that anchors the project.

---

## 4. Register Concepts Exercised

### 4.1 Tier 1 principles exercised

All 12 T1 principles were engaged during the session, in varying depth:

- **[[principle-two-meta-model-distinction|A4]]** — the session's focal principle. Strengthened formulation drafted in v5 §3 as the stratified two-side architecture. Supersedes the original S64 formulation.
- **[[principle-separation-representation-execution|A1]]** — framed in §3 as sharpened by the SRS/PRS boundary. §1 drafting deferred to S211.
- **[[principle-self-describing-system|A2]]** — tested in §2.4 as a consequence of the strengthened A4. Test passed.
- **[[principle-model-generates-everything|A3]]** — held in the §3 prohibitions (prohibition 1 cross-stratum conflation is the operational expression of A3 at the principle level).
- **[[principle-deterministic-over-probabilistic|A6]]** — mentioned in §2.3 reasoning metamodel treatment. Not part of the unification test (not one of the five principles in the hypothesis scope).
- **[[principle-discipline-as-load-bearing-structure|A9]]** — extended in §5.8 as "agent guided by model truth, not by prompt cleverness". The extension lands in §10 as a guiding constraint in a later v5 session.
- **[[principle-intrinsic-self-knowledge|A10]]** — tested in §2.4. Test passed.
- **[[principle-unity-principle|A11]]** — tested in §2.4 with a strengthened operational reading. Test passed.
- **[[concept-coordinate-framework|A12]]** — promoted from T1 candidate to binding T1 in §5.1. Tested in §2.4. Test passed.
- **[[concept-multi-tenancy|A13]]** — §4 drafting deferred to S211.
- **[[concept-co-evolution|J2]]** — the v5 drafting work is itself an exercise of J2 (co-evolution of model and tooling) at the foundations-paper level: the paper and the architectural reality evolve together.
- **[[concept-non-constraining|J3]]** — held as the DPA-informed writing discipline throughout. No paragraph forecloses portability.

### 4.2 Tier 2 structural commitments exercised

- **[[concept-knowledge-graph|B22]]** — promoted from directional to binding in §5.6.
- **[[concept-dual-stack-architecture|B21]]** — reframed in §5.5 as a consequence of the strengthened A4 rather than a freestanding commitment. W-043 follow-up will update the master register entry to reflect this.
- **[[concept-authority-zones|B29]]** — preserved as the formalism boundary content at §3.1 (Stratum 2) and §5.6.
- **[[concept-knowledge-graph|B24]]** — the mapping ontology, located at the Formalism Boundary stratum in §3.1.
- **[[concept-domain-identity|B15]]**, **[[concept-temporal-reference-frames|B16]]**, **[[concept-epistemic-modality|B17]]** — preserved substantively in §5.2 and §5.3.
- **[[concept-operational-simulation|L5]]**, **[[concept-reflective-simulation|L6]]**, **[[concept-valence|L7]]**, **[[concept-coordinate-space-snapshots|L8]]**, **[[concept-goal-seeking-computation|L9]]** — all absorbed into §5.7 as expressions of the SRS rather than independent capabilities. L8 specifically tested in §2.4 and passed.
- **[[concept-stakeholder-model|C7]]** — referenced in §3.2's description of the business side.

### 4.3 Newly-introduced concepts committed in the draft

Concepts named in v5 prose that will be added to the master register as W-043 follow-up:

- **Six strata** (Foundation, Formalism Boundary, Metamodel, Configured Model, State Representation, Platform Realisation) as the vertical compositional commitment of the strengthened A4. Candidate register entry.
- **Two sides** (business side, system side) as the horizontal compositional commitment, retiring the "BMM side / SMM side" category error. Candidate register entry.
- **Ten architectural loci** as the minimal content frame of the platform. Candidate register entry (or standing convention).
- **State Representation Stratum (SRS)** as the stratum containing all runtime model-grounded instance content. New Tier 2 structural commitment.
- **Platform Realisation Stratum (PRS)** as the stratum containing realising components. New Tier 2 structural commitment.
- **Formalism Boundary stratum** as its own architectural locus. New Tier 2 structural commitment.
- **SR (System Runtime state)** as the renamed system-side runtime state. Replaces BS.
- **Prohibition 5** (metamodel runtime confusion) as a category-error prohibition. Placement in Section A (principle) or Section N (standing convention) is a register decision tracked as an open question for S211.
- **B40 (four-level distinction)** — already partially registered from S207 as T2; v5 §3 strengthens the four-level claim into the six-stratum frame.
- **B41 (sophistication gradient / user bands)**, **B42 (surface family)**, **B43 (experience-API / BFF layer)**, **B44 (headless five-layer architecture)**, **J15 (state placement discipline)** — already registered from S207; v5 §5.9 lifts them to foundations-paper status.
- **D28 (constraint hierarchy → UI affordance mapping)**, **D29 (governance dashboard pattern)** — already registered as T4 candidates from S207; v5 references them forward as validated-pattern candidates pending implementation.

---

## 5. Emergent Ideas

No new emergent ideas were surfaced during the session that warrant deposit in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] ([[concept-inception-capture|J13]]). The session was a tightly-focused drafting exercise against an already well-prepared source (the [[WORKSHOP-s208-a4-reformulation-INTEGRATED|integrated workshop document]] from S209), and the architectural ideas that were exercised were all already captured either as OW items, as master register candidates, or as existing concept notes. The Emergent Ideas Log review at C5 will consider whether any existing entries should have their routing status updated in light of v5 drafting progress, but no new deposits are expected.

---

## 6. Observations and Watchpoints

### 6.1 Observations surfaced during the session

The session surfaced the following observations for the OW register at C2:

**OW-210-1: General/Tailored sub-structuring at the Metamodel stratum needs explicit foundations-paper treatment beyond the v5 §5.5 paragraph.** The paragraph added to §5.5 is a brief statement that the Metamodel stratum is internally structured into General and Tailored sub-bands and that this sub-structuring is within the stratum rather than at a stratum boundary. The detailed treatment — criteria for promoting content between General and Tailored, how Tailored extensions hook into the General core, how the sub-structuring shows up in SBMM vocabulary — belongs in SBMM v4 and is explicitly deferred there. This is a watchpoint for SBMM v4 drafting.
- **Work type:** GOV, BMM
- **Source:** S210 §5 critique and fix
- **Status:** active

**OW-210-2: v5 §5.9's claim that the Stage 8 portal "is" a band 5 surface rests on the S199 §6.5 idealised walk-through, not on an audit of the actual Stage 8 portal feature set.** This is an inherited concern from OW-64 (deposited at S200), which tracks the need for a Stage 9 audit of the portal's features against the band 5 claim. v5 §5.9 is honest that the reframing is a re-description rather than a built-from-scratch claim, but a reader could over-read it. Flag for the Stage 9 portal reframing workstream.
- **Work type:** ARC, CON
- **Source:** S210 §5 critique (inherited from OW-64)
- **Status:** active; cross-references OW-64

**OW-210-3: The five-principle unification hypothesis test result depends on derivations that use additional §3 content beyond the strengthened A4 statement itself.** Specifically, the test for A2 depends on "the comprehension architecture is the SRS-facing surface" (stated in §3.5 enables item 8), the test for A10 depends on "prohibition 1 forbids PRS components writing to Metamodel-stratum content" (stated in §3.4), and the test for A11 depends on "every subsystem reads through bindings into the same SRS" (stated in §3.1 Stratum 6). These additional commitments are all §3 content and the test is therefore fair, but a stricter reader might argue the derivations smuggle in commitments. The framing in §2.4 is careful ("consequence of the strengthened A4 plus …"), but the qualification deserves monitoring across Tests 2 and 3.
- **Work type:** GOV, ARC
- **Source:** S210 §2 critique
- **Status:** active

**OW-210-4: The static/dynamic duality of models (S197) is now absorbed as the boundary between the Configured Model stratum and the State Representation Stratum rather than as an axis added to the dual stack.** This reframing, stated in v5 §5.5, supersedes the S197 paper's explicit framing without retracting S197's substantive findings. The concept graph note for B21 (dual-stack architecture) will need to reflect this reframing when the register update is undertaken as W-043 follow-up.
- **Work type:** ARC, GOV
- **Source:** S210 §5.5 drafting
- **Status:** active

**OW-210-5: The v5 draft's treatment of the reasoning metamodel in §2.3 is substantively preserved from v4.1 but is now structurally located under the strengthened A4 — every reasoning metamodel instance is SRS content.** This is a framing shift rather than a content shift. A reader familiar with v4.1 §2.3 will see the same classes and the same architectural positions; a reader new to v5 will see them as consequences of the SRS being queryable. Both readings are correct. Monitor for reader feedback on whether the v5 framing is clearer or more confusing than v4.1's.
- **Work type:** GOV
- **Source:** S210 §2 drafting
- **Status:** active

### 6.2 Watchpoints carried forward

The following watchpoints from earlier sessions were honoured during S210 drafting and remain active:

- **[[ontara-ref-work-item-tracker|OW-62]]** — S198 paper sentence-by-sentence audit for residual "one operator surface" framing. v5 §5.9 treats the Stage 8 portal as a band 5 surface, consistent with the S200 revision; the OW-62 audit itself is not v5 work.
- **[[ontara-ref-work-item-tracker|OW-63]]** — seven-band framing as working hypothesis. v5 §5.9 states the bands as non-constraining per J3 and working-hypothesis status, consistent with OW-63.
- **[[ontara-ref-work-item-tracker|OW-64]]** — portal-as-band-5 claim resting on idealised walk-through. Cross-referenced in OW-210-2 above.
- **[[ontara-ref-work-item-tracker|OW-65]]** — band handoff protocols. Not addressed in v5; remains active for Stage 9 surface design.

### 6.3 Watchpoints resolved in v5

Several OW items surfaced at S208 / S209 for v5 drafting discipline are now resolved or substantially resolved by the v5 draft:

- **[[ontara-ref-work-item-tracker|OW-76]]** (real-world vs synthetic indistinguishability) — stated in full in v5 §5.7.5. Finding is now foundations-paper content.
- **[[ontara-ref-work-item-tracker|OW-77]]** (five-principle unification hypothesis) — Test 1 passed in §2.4. The hypothesis holds for this paper. Surfacing remains active for Tests 2 and 3.
- **[[ontara-ref-work-item-tracker|OW-79]]** (SysML not a complete view of the platform) — stated explicitly in v5 §5.6. Will need to be stated again in Platform Modelling Strategy v5 §11 when that paper is drafted.
- **[[ontara-ref-work-item-tracker|OW-80]]** (Formalism Boundary as its own stratum) — stated explicitly in v5 §3.1 (Stratum 2) and §5.6. Resolved.
- **[[ontara-ref-work-item-tracker|OW-81]]** (activity flows are not a stratum) — stated explicitly in v5 §3.1. Resolved.
- **[[ontara-ref-work-item-tracker|OW-82]]** (guidance reports as instance content in the SRS) — stated in v5 §5.7.1. Resolved.
- **[[ontara-ref-work-item-tracker|OW-83]]** (DPA-informed writing discipline) — held throughout v5 drafting. No paragraph forecloses portability. Resolved for this paper; remains active for Platform Modelling Strategy v5 and SBMM v4.
- **[[ontara-ref-work-item-tracker|OW-84]]** (A12 promotion) — committed in v5 §5.1. The register-level action is W-043 follow-up.
- **[[ontara-ref-work-item-tracker|OW-85]]** (BS → SR rename) — committed throughout v5. Resolved.
- **[[ontara-ref-work-item-tracker|OW-86]]** (ten loci, not eleven) — stated correctly in v5 §3.3. Resolved.

---

## 7. Open Questions and Deferred Items

### 7.1 Open questions for subsequent v5 sessions

- **Prohibition 5 register treatment.** Where does "metamodel runtime confusion as category error" belong in the master register — as a Section A principle, as a Section N standing convention, or as one of v5 §10's guiding constraints (the default proposal from the S210 structural plan)? Decision required when v5 §10 is drafted in a subsequent session.
- **The Platform Modelling Strategy v5 treatment of OW-79.** SysML v2 is not a complete view of the platform. v5 §5.6 states this in Architecture Principles; Platform Modelling Strategy v5 §11 will need to state it again and spell out the implications for anyone reading the SysML model as a single source of truth. Decision is about how strong the framing should be in that paper.
- **Tests 2 and 3 of the unification hypothesis.** To be run as Platform Modelling Strategy v5 and SBMM v4 are drafted.

### 7.2 Deferred items

- **§1, §4, §6–§10, Appendix, Related Documents of v5** — held as TBD placeholders in the v5 draft, to be completed in S211 as a focused session. Each is either a light or medium edit to substantively current v4.1 material or a medium addition that does not need the strengthened A4 framework to land cleanly.
- **Strategic snapshot refresh** — deferred to S211 per Option 2 at O4. Governance exception noted in §9 below.
- **W-043 master register additions** — still deferred until v5 vocabulary is fully settled. After v5 is complete, a dedicated session will add the new Tier 2 structural commitments (SRS, PRS, Formalism Boundary stratum, SR rename), amend B21 (dual-stack as consequence of A4), formalise B22 and A12 promotions, and place prohibition 5 in the register.
- **W-045 Campus Walk II and architecture diagram revision** — still deferred until v5 settles the strata framing.
- **W-052 glossary build** — still deferred as a dedicated session.
- **W-053 DPA design** — still deferred as a future workstream.

---

## 8. Tier 1 Principles and How They Were Honoured

- **[[principle-separation-representation-execution|A1]]** — honoured by the drafting process itself. v5 is representation (the architectural prose); the v4.1 archive and the integrated workshop document are earlier representations that v5 supersedes. No execution-layer change is required for v5 to take effect. The §3.5 enables item 5 (bindings have a precise structural home) is the operational expression of A1 at the principle level, and §3.4 prohibition 1 (cross-stratum conflation) is the operational expression of the representation-execution boundary as a structural commitment.
- **[[principle-self-describing-system|A2]]** — honoured as the subject of v5 §2. The drafting explicitly tests A2 as a consequence of the strengthened A4 via the comprehension architecture being the SRS-facing surface. Test passed.
- **[[principle-model-generates-everything|A3]]** — honoured by the §3.4 prohibitions discipline, which prevents cross-stratum conflation of generated code with source of truth, and by the §5.6 KG-canonical commitment, which keeps the canonical form as the KG and generated SysML as a projection.
- **[[principle-two-meta-model-distinction|A4]]** — the session's focal principle. Strengthened formulation drafted in full in §3. The stratified two-side architecture is the canonical v5 statement of A4.
- **[[principle-deterministic-over-probabilistic|A6]]** — honoured by §2.3's treatment of structured probabilistic reasoning as realising components at the PRS that write Claims with priors and posteriors (and therefore provenance) into the SRS, preserving auditability.
- **[[principle-discipline-as-load-bearing-structure|A9]]** — honoured by the structured critique discipline applied at three gates during the session (after §3, after §5, after §2). Each gate was run against all five critique dimensions. Each section passed. A9 was also extended in §5.8 to cover bounded agents: "agent guided by model truth, not by prompt cleverness".
- **[[principle-intrinsic-self-knowledge|A10]]** — tested in §2.4 as a consequence of the discipline that realising components do not write to Metamodel-stratum or Configured-Model-stratum content. Test passed.
- **[[principle-unity-principle|A11]]** — tested in §2.4 with a strengthened operational reading: the reason there are no separate disconnected knowledge structures is that every subsystem reads through bindings into the same SRS. Test passed.
- **[[concept-coordinate-framework|A12]]** — promoted from T1 candidate to binding T1 in §5.1. Tested in §2.4. Test passed.
- **[[concept-multi-tenancy|A13]]** — honoured by the DPA-informed writing discipline (§3.1 SRS description, §4 forward reference, §5.6 portable format constraint). v5 §4 itself remains TBD but the A13 framing is preserved and sharpened.
- **[[concept-co-evolution|J2]]** — honoured implicitly: the v5 drafting work evolves the foundations paper alongside the architectural reality rather than ahead of it or behind it. The integrated workshop document and the v5 drafting are co-evolved.
- **[[concept-non-constraining|J3]]** — honoured by the DPA-informed writing discipline throughout. No paragraph in v5 §3, §5, or §2 forecloses the DPA. J3 is also honoured by the surface architecture content in §5.9, which states the seven bands as non-constraining working hypothesis.

Workflow guide §1 commitment 5 (structured critique at design milestones) was honoured by three critique gates during the session — after §3, after §5, and after §2. All three gates passed. The critique discipline was itself load-bearing for the session's quality and was not skipped or hurried.

---

## 9. Governance Actions

The following governance actions were taken during S210:

1. **v4.1 archived to [[—— HISTORY & ARCHIVE INDEX ——|07 Ontara History & Archive]]** by Ella via Obsidian UI before drafting began, with the archive copy named `SUPERSEDED-ontara-architecture-platform-principles-v4.1-14-04-26-s210.md`. This preserves wikilinks across the ~60+ references to the paper while enabling the full rewrite in a separate container artifact.

2. **Strategic snapshot refresh deferred to S211 (Option 2).** The [[ontara-ref-strategic-snapshot|strategic snapshot]] was at the 7-session threshold at S210 open. Ella elected at O4 to defer the refresh to S211 rather than interrupt the v5 drafting. **This is the first acknowledged threshold breach since the 7-session convention was adopted**, and is recorded here as an explicit governance exception. The breach is by one session (S210 → S211). Commitment: the strategic snapshot will be refreshed at S211 at the latest, and the S211 preparation note will flag this as a priority.

3. **v5 draft produced as container artifact** at `ontara-architecture-platform-principles-v5-DRAFT-s210.md`, held outside the canonical filename as a partial draft pending completion in subsequent sessions. The canonical `ontara-architecture-platform-principles.md` still contains v4.1 content. v5 will replace it wholesale when the draft is complete enough.

4. **Methodological departure from the S208 foundations refresh plan** — the plan anticipated targeted `edit_file` operations on v4.1; S210 executed a full rewrite in a separate container artifact instead. Rationale captured in §2.2 of this report. The S208 plan remains a valid reference for section-by-section treatment, but its §7 procedure (execute edits via MCP `filesystem:edit_file`) is superseded for the Architecture Principles v5 refresh by the full-rewrite workflow.

5. **Structured critique applied at three gates.** After §3, after §5, and after §2. All three gates passed. The critiques are documented in the chat record and summarised in §2 of this report.

6. **[[ontara-ref-work-item-tracker|Work item tracker]] updates** will be made at C2 to reflect W-049 in-progress status (no status change — remains in-progress with substantial v5 progress), add S210 observations to the OW register (OW-210-1 through OW-210-5), and update the Document Currency Register to note the strategic snapshot threshold breach.

7. **[[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] review** at C5 — no new deposits expected (see §5 above).

---

## 10. Deliverables

The session produced:

1. **[[ontara-architecture-platform-principles-v5-DRAFT-s210|Architecture Principles v5 (partial draft)]]** — container artifact placed in [[—— DEVELOPMENT INDEX ——|02 Ontara Development]]/Ontara WORKSHOP. Approximately 11,000 words of new foundational prose drafted across §3, §5 (nine subsections), and §2 (six sub-subsections). All other sections held as TBD placeholders for S211 completion. When v5 is complete in a subsequent session, it will replace v4.1 at the canonical [[ontara-architecture-platform-principles|Architecture Principles]] filename.

2. **[[session-210-report-2026-04-14|This session report]]** — S210 report placed in the session reports folder for Sessions 201–210.

3. **[[session-211-preparation-note|S211 preparation note]]** — S211 preparation note placed in the session reports folder for Sessions 211–220.

Cross-references to the container artifacts will be made in the work item tracker and the emergent ideas log at C2.

---

*Session 210 report. S210 is the first substantive drafting session of Architecture Principles v5 under W-049. Three load-bearing sections (§3, §5, §2) are drafted, with three structured critique gates passed. The five-principle unification hypothesis Test 1 passes cleanly for this paper. Two architectural commitments are promoted in the draft (B22 to binding; A12 to binding T1). The BS → SR rename is resolved. The next session continues v5 drafting for the remaining light and medium sections (§1, §4, §6–§10, Appendix, Related Documents) and addresses the strategic snapshot refresh deferred from S210.*

GenderSense Limited.
