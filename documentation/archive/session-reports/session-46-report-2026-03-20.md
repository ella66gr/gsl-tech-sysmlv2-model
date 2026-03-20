# Session 46 Report — Phase 3 Design: Comprehension Architecture and Intrinsic Self-Knowledge

**Date:** 20 March 2026
**Session type:** Design discussion + document production
**Duration:** Extended session
**Participants:** Ella Green, Claude (Opus 4.6)

---

## 1. Summary

This session was primarily a design discussion that significantly deepened the comprehension architecture and identified a need for a structured project review before proceeding with Phase 3 implementation. No code was written. Four important documents were produced.

**Key results:**
- **26 purposive `@UserFacing` descriptions drafted** for all BMM `part def`s (12 rewrites + 14 new), establishing a description style guide for Register 1 content.
- **Intrinsic self-knowledge principle identified** — system explanations must be dynamically computed from live model state, not stored as static text. The dividing-line test: "if the model changes and no human edits a description, does the explanation become wrong?"
- **Unity principle established** — the same weighted relationship model must inform comprehension, reasoning, simulation, governance, and assembly guidance. One knowledge model, multiple applications. No separate, disconnected knowledge structures.
- **Weighted relationships introduced** as a foundational concept, with ordinal classification (strong/moderate/weak) as the starting point, designing for hybrid (structural baseline + human overrides).
- **Research into reasoning formalisms** — semiring soft-constraints, fuzzy MCDM, and Probabilistic Soft Logic identified as relevant formalisms for Ontara's weighted reasoning needs.
- **Option 3 chosen for comprehension data architecture** — comprehension structure modelled in SysML, not in generator logic or view-layer assembly. Consistent with A3 (model generates everything) and the intrinsic self-knowledge principle.
- **Project review identified as necessary** before proceeding with Phase 3 implementation. Current project structure has gaps in concept tiering, cross-cutting concern tracing, and governing document currency.

---

## 2. Context

Session 45 completed Stage 3 Phase 2 (Glossary view) and produced the initial comprehension architecture discussion paper identifying three registers of comprehension. The Session 46 preparation note framed Phase 3 as two sub-concerns: 3a (improve authored description quality) and 3b (explore generated comprehension content / Register 2 prototype).

---

## 3. Discussion and Design Decisions

### 3.1 Description style guide

The session established a style guide for `@UserFacing` descriptions through iterative drafting:

- **Purposive:** Answers "why should I care?" and "what does this mean for my service?"
- **Systemic:** Conveys that the system holds and tracks this as a concrete, actionable concept — not just a label. This is novel and needs to be made explicit.
- **Drillable:** References to related concepts are natural link/tooltip targets for future interactivity.
- **Plain phrasing:** No implied hidden complexity. "Every activity is an activity of one of these types" — not "every activity has a type" (which implies an additional property or connection).
- **Contract language:** "When you assign one of these types to an activity, the system will use that information to..." — explicit interaction between user action and system response.

### 3.2 Comprehension data architecture: Option 3

Three options were evaluated:

| Option | Description | Decision |
|---|---|---|
| 1. View-only assembly | Glossary Svelte page composes from existing JSON | Rejected — not portable or reusable |
| 2. Generated JSON artefact | Generator produces comprehension-oriented JSON | Rejected — creates parallel knowledge structure outside the model |
| **3. Modelled in SysML** | **Comprehension structure is part of the model** | **Chosen — consistent with A3, C6, and the intrinsic self-knowledge principle** |

Ella's reasoning: "This is so much a part of what the model and ethos of modelling everything in one place is all about, that this self-knowledge structure should be in the SysML." No pressure for MVP-style early prototype.

### 3.3 Intrinsic self-knowledge principle

Ella identified a fundamental distinction: purposive descriptions don't arise just because someone writes better text — they arise because the system is dynamically responsive to its own structure, function, flow, relations and content. Self-knowledge is not painted on or bolted on; it is intrinsic.

This led to the authored/intrinsic test (§2.2 of the discussion paper) and the concept of `@Comprehension` metadata as a *traversal schema* (recipe for constructing explanations) rather than a *content template* (stored explanations).

### 3.4 Unity principle

Ella's key insight: the same factors must bear on explanatory descriptions as on projections, question-answering, self-knowledge, prediction, risk assessment, simulation, and governance. "I don't want a separate and disconnected set of knowledge terms that need to be manually or independently maintained."

This establishes a foundational architectural commitment: one weighted relationship model, consumed by all subsystems.

### 3.5 Weighted relationships

Relationships between elements are characterised by strength of interaction effect. Ella agreed with the recommendation to start with ordinal classification (strong/moderate/weak) and design for hybrid (structural baseline + human overrides), following [[concept-design-decision-lifecycle|J12]].

### 3.6 Inference engine connection and weighted reasoning research

Ella connected the comprehension architecture to the inference/logic engine — the system should reason about what follows from its current state, not just describe structure. Ella also brought research into probabilistic and weighted reasoning formalisms (semiring soft-constraints, fuzzy MCDM, Probabilistic Soft Logic), identifying costs/preferences and fuzzy human judgements as the primary interpretive frames for Ontara, with probabilistic reasoning also relevant for clinical decision support contexts.

### 3.7 Project review decision

Ella asked whether the project structure is currently fit for purpose for capturing, surfacing, and advocating for existing principles and supporting new foundational ideas. Four gaps were identified:

1. **Register is flat where the architecture is layered** — no tiering of concept influence
2. **Governing documents don't reflect current depth** — vision reference and strategic snapshot are dated
3. **Cross-cutting concerns aren't explicitly traced** — principles that affect multiple workstreams can fall between phases
4. **Discussion paper → binding commitment pipeline is informal** — insights from discussion papers aren't systematically absorbed

**Decision:** Undertake a structured project review before Phase 3 implementation.

---

## 4. Design Decisions

| # | Decision | Choice | Rationale |
|---|---|---|---|
| S46-D1 | Comprehension data architecture | Option 3: modelled in SysML | A3, C6, intrinsic self-knowledge principle. No parallel knowledge structures. |
| S46-D2 | Weight classification approach | Start (b) ordinal, design for (d) hybrid | J12. Gain experience before committing to numeric weights. |
| S46-D3 | Register 1 description style | Purposive, systemic, drillable, plain, contract language | Sam-facing. System holds and tracks concepts. No implied hidden complexity. |
| S46-D4 | Phase 3 sequencing | Project review first, then implementation | Project structure gaps identified. Review needed to ensure new principles are properly integrated. |
| S46-D5 | 3a and 3b together | Simultaneous, not sequential | Improving a description naturally raises the question of what else the system could explain. |

---

## 5. Documents Produced

1. **Phase 3 Draft Descriptions** — `phase-3-draft-descriptions-2026-03-20.md` — 26 purposive `@UserFacing` descriptions (12 rewrites + 14 new) with style guide and drill target annotations. Container artifact for Ella to download and review.

2. **Intrinsic Self-Knowledge Discussion Paper** — `ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20.md` — extends the Session 45 comprehension architecture with four new contributions: intrinsic self-knowledge principle, inference engine connection, weighted relationships, and the unity principle. Includes research context on reasoning formalisms. Container artifact → Obsidian `Exploratory & Discussion Papers/`.

3. This session report — container artifact → Obsidian `Session Reports, Prep & Handover/`.

4. Session 47 preparation note — container artifact → Obsidian `Session Reports, Prep & Handover/`.

---

## 6. New Concepts Introduced

| Concept | Description | Proposed register location |
|---|---|---|
| **Intrinsic self-knowledge principle** | System explanations computed dynamically from live model state. The test: if the model changes and no human edits, does the explanation become wrong? | **Tier 1 / Section A** (foundational principle) |
| **Unity principle** | One weighted relationship model informs all subsystems. No separate knowledge structures. | **Tier 1 / Section A** (foundational principle) |
| **Comprehension traversal schema** | `@Comprehension` metadata declares how to construct an explanation, not what it says. Recipe, not script. | Section I (extends I14) |
| **Weighted relationships** | Interaction strength on relationships. Ordinal now, hybrid later. | Section B or K |
| **Inferential comprehension (Register 2+)** | Comprehension layer reasons about implications, not just structure. Uses C6 machinery. | Sharpens I14, C6 |
| **Authored/intrinsic content distinction** | Clear dividing line for what goes in `@UserFacing` vs `@Comprehension`. | Sharpens I14 |

**Note:** These entries should be added to the master register during the Session 47 project review, not as ad-hoc additions now. The review will establish the tiering structure first.

---

## 7. Master Register — Deferred to Review

Master register updates are **deferred to the Session 47 project review** by deliberate decision. The review will:

1. Introduce tiered concept classification (Tier 1–4)
2. Add the new concepts from this session at appropriate tiers
3. Update existing entries (I14, C6, K) to reflect the deepened architecture
4. Establish cross-cutting concern tracing

Updating the register piecemeal before the tiering structure exists would be counterproductive.

---

## 8. Concepts Exercised

- [[concept-co-evolution|J2]] (co-evolution) — comprehension content must keep pace with model and tooling
- [[concept-design-decision-lifecycle|J12]] (design decision lifecycle) — ordinal weights as experimentation before convention
- [[concept-non-constraining|J3]] (non-constraining) — weight model designed not to foreclose numeric/hybrid future
- J10 (retrospective bootstrapping) — project review triggered by recognising governance gaps
- J11 (bottom-up meets top-down) — glossary UX observation → foundational architectural principles
- [[principle-model-generates-everything|A3]] (model generates everything) — comprehension structure belongs in SysML
- A9 (discipline as load-bearing structure) — project review as structural reinforcement

---

## 9. Phase 3 Status

Phase 3 implementation has **not begun**. The session produced design documents and identified the need for a project review before implementation. The Phase 3 implementation plan will be produced after the review establishes the tiered register and updated governing documents.

**Phase 3 scope (as currently understood):**
1. Register 1: Apply 26 purposive descriptions to `@UserFacing` metadata
2. Register 2 foundation: Design and implement `@Comprehension` metadata with traversal schema
3. Syntax spike: Test `ref` inside `metadata def`
4. Ordinal weight classification: Design and pilot on Activity Type

**Estimated effort:** 3–4 sessions (after review).

---

## 10. Next Steps

1. **Session 47: Project review.** Tier the register, update governing documents, establish cross-cutting concern tracing, absorb Session 45 and 46 discussion paper implications.
2. **Session 48+: Phase 3 implementation.** Produce detailed implementation plan reflecting the review's outputs, then build.
3. **Queued discussion (carried forward):** Service subject ≠ customer — meta model implications.

---

## 11. Git Commands

No code changes this session. No commit needed.

---

## 12. Documents for Repo Archive

The following documents should be copied to `documentation/archive/` in the repo after the Session 47 review (when governing documents are updated):
- Intrinsic self-knowledge discussion paper → `documentation/archive/discussions/`
- Session 46 report → `documentation/archive/sessions/`

---

## 13. Correction Noted

§4.6 of the discussion paper states that "true probabilities are less central" to Ontara's needs. Ella identified that this is too narrow: clinical decision support tools legitimately use Bayesian and other probabilistic reasoning to assist pathway selection, even though authoritative clinical decisions remain deterministic (A6). The weight model should support all three interpretive frames (costs/preferences, fuzzy judgements, *and* probabilities), with the probabilistic frame applicable in clinical decision support contexts. This correction should be applied when the discussion paper is finalised.

---

*Session report prepared 20 March 2026. Session 46.*
