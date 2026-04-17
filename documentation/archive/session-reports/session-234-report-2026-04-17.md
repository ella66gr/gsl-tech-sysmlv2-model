---
session: 234
date: 2026-04-17
type: session_report
tags:
  - session_report
---

# Session 234 Report

**Date:** 17 April 2026
**Type:** Architecture / design
**Workstreams:** Stage 9 / Stage 10 scoping (new); BRL and experience-API thinking (new)

---

## Work done

Session scoped at open as governance / housekeeping ([[ontara-ref-work-item-tracker|W-079]] OMM rename + [[ontara-guide-claude-tooling|Claude Tooling Guide]] refresh). Ella redirected the session to architectural thinking she wished to open up: introducing Stage 10 and revisiting Stage 9, treating them as joint concerns.

**Provocation 1 — the octagon placeholder.** Ella drew attention to the "Communication Bus" octagon in the 12 April 2026 architecture diagram (version 1.1.3) — an honest acknowledgement that something has to mediate between the State Representation Stratum ([[principle-two-meta-model-distinction|SRS]]) and the Platform Realisation Stratum (PRS) realising components, and the real-world activity flow, but an inadequate name and decomposition. Ella had commissioned [[ontara-research-(perplexity) - canonical-binding-projection-layer|Perplexity research]] into the architectural answer, arriving at the Canonical Binding and Projection Layer proposal.

**Provocation 2 — the experience-API.** Ella paired the BRL work with the experience-API / BFF layer named in [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199]] §4.4 but never developed. The two concerns are architecturally distinct but must be scoped together because they share engineering substrate (identity, provenance, constraint gating, canonical edge contract) and both depend on [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|bindings]] being first-class model content.

**Claude misstep and correction.** Claude's first response read the "considered together" framing as a risk of conflation and structured the reply around a distinction Ella had already drawn — condescending in effect. Claude acknowledged this and corrected course. The intellectual origination of both the BRL emphasis and the experience-API emphasis is Ella's.

**Key architectural move — the indistinguishability constraint.** Ella stated: real-world and simulated / projected business service activity must hit the DSR in exactly the same way, indistinguishable in all but epistemic tag. This became the disciplining constraint for the BRL design and the reason the synthetic-generator realiser must be first-class in the BRL from the start, not retrofitted. Aligns with [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|S197]] §4's unity of the model across instantiation modes.

**Joint scoping conversation.** Walked through three Stage 9 / Stage 10 split options (horizontal by layer; vertical by demonstrator; diagonal by capability completeness). Settled on a working proposal: Option C modified — BRL fully scoped and three realiser classes implemented in Stage 9 (event-stream, human-mediated, synthetic-generator), substrate engineering done, experience-API designed but minimally implemented; Stage 10 builds the experience-API across bands and adds remaining realiser classes.

**Discussion paper produced.** [[ontara-discussion-brl-and-experience-api-2026-04-17|The Binding Realisation Layer and the Experience-API: Two Layers, Considered Together]] — consolidates the Session 234 thinking for further discussion and feeds the dedicated BRL and experience-API papers that are expected downstream.

---

## Decisions made

- **Naming.** The layer at the PRS ⇄ SRS boundary is the **Binding Realisation Layer** (BRL). "Canonical Binding and Projection Layer" rejected on vocabulary-collision grounds (canonical and projection already doing other work in Ontara).
- **Two distinct layers.** The BRL (below-and-into SRS) and the experience-API / BFF (above SRS) are architecturally distinct but must be scoped jointly because of shared engineering substrate.
- **Indistinguishability as a design constraint.** Real and simulated activity reach DSR identically modulo epistemic tag. The synthetic-generator realiser is a first-class member of the realiser family, not a later addition.
- **Working Stage 9 / Stage 10 split.** Option C modified, to be ratified or revised by the dedicated BRL and experience-API discussion papers.
- **No decision this session** on whether mapping-rule firings ([[ontara-ref-work-item-tracker|OW-33]]) live inside the BRL or adjacent to it — carried forward as §12 Q4 in the paper.
- **No decision this session** on whether realisers are generated from binding declarations or hand-written with validation — carried forward as §12 Q3 in the paper.

---

## Concepts exercised or introduced

- [[concept-knowledge-graph|B22]] (KG-canonical) — exercised at the substrate boundary: external systems do not speak OWL; the BRL is where that commitment is honoured.
- [[principle-separation-representation-execution|A1]], [[principle-model-generates-everything|A3]], [[principle-unity-principle|A11]] — exercised throughout the BRL thinking. [[principle-two-meta-model-distinction|A4]] (strengthened) provides the strata framing.
- B46 ([[ontara-discussion-bs-substrate-and-bindings-2026-04-12|binding]], T2 candidate) — the BRL is its runtime realisation.
- Candidate new register entries identified (not committed): BRL, experience-API / BFF, canonical edge contract, realiser family, synthetic-generator realiser, indistinguishability constraint.

---

## Open questions

Ten open questions carried forward in §12 of the discussion paper, spanning canonical edge contract shape (Q1), binding declaration vocabulary (Q2), realiser generation vs hand-writing (Q3), mapping-rule placement (Q4), human-mediated binding structure across the two layers (Q5), per-band experience-API contracts (Q6), state-placement across the two layers (Q7), authority-zone propagation (Q8), simulation scenario authoring location (Q9), DPA survival check ([[ontara-ref-work-item-tracker|OW-83]]) (Q10). These feed the dedicated BRL and experience-API discussion papers.

Governance / housekeeping items originally scoped for S234 ([[ontara-ref-work-item-tracker|W-079]] OMM rename + [[ontara-guide-claude-tooling|Claude Tooling Guide]] refresh) deferred — to be re-scoped at S235 O4.

---

## W-numbers opened, progressed, or closed

- [[ontara-ref-work-item-tracker|W-079]] (OMM rename + DCR refresh): deferred from S234 scope; remains open, Priority B, overdue on DCR.
- [[ontara-guide-claude-tooling|Claude Tooling Guide]] DCR refresh: deferred from S234 scope; remains at threshold.
- **Two new workstreams opened** by the discussion paper — [[ontara-ref-work-item-tracker|W-080]] (BRL discussion paper) and [[ontara-ref-work-item-tracker|W-081]] (experience-API discussion paper), both Priority B.

---

## Documents produced or updated

- [[ontara-discussion-brl-and-experience-api-2026-04-17|The Binding Realisation Layer and the Experience-API: Two Layers, Considered Together]] — new discussion paper, placed in WORKSHOP folder by Ella
- [[session-234-report-2026-04-17|Session 234 report]] — this document
- [[session-235-preparation-note|Session 235 preparation note]] — prep note

---
