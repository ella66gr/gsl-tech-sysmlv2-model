---
tags:
  - session-report
date: 2026-04-05
status: current
session: 147
---
# Session 147 — Report

**Date:** 5 April 2026
**Type:** Discussion
**Session number:** 147

---

## Summary

Session 147 paused before resolving the Session 146 reasoning metamodel design decisions (S146-D1 to D8) and instead stepped back to review the [[concept-coordinate-framework|coordinate framework (A12)]] in the light of the [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning metamodel]], the [[ontara-discussion-comprehension-architecture-2026-03-19|comprehension architecture]], the [[ontara-discussion-deontic-governance-architecture-2026-04-03|governance vocabulary]], and the [[ontara-architecture-decision-knowledge-evaluation|knowledge evaluation architecture]]. Ella's instinct was that foundational pieces must stay in step before further commitments are made.

The session produced a substantial consolidation paper — [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited: Integration with the Reasoning Metamodel]] — that identifies four contradictions/ambiguities in the current architecture, resolves them, and proposes seven design decisions (S147-D1 to D7).

### Phase 1: Coordinate Framework Review

Claude loaded and compared four primary documents: the [[ontara-research-(perplexity) - ontologies & domain coordinates|Perplexity research on domain coordinates]], the [[ontara-discussion-coordinate-framework-2026-03-22_1|coordinate framework paper (Session 59)]], the [[ontara-discussion-temporality-reference-frames-2026-03-22-v2.1|temporality paper (Session 59)]], and the [[ontara-discussion-institutionalised-reasoning-2026-04-05|institutionalised reasoning paper (Session 146)]]. The comparison identified four areas where the reasoning metamodel's claims about the coordinate framework introduced contradictions or ambiguities:

1. **Epistemic modality** — two overlapping but non-identical schemes (seven provenance modalities from [[concept-epistemic-modality|B17]] vs five snapshot types from [[concept-coordinate-space-snapshots|L8]] vs evidential confidence from the reasoning metamodel)
2. **Region overloading** — the undifferentiated Region concept being asked to serve as therapeutic ranges, goals, governance boundaries, probability distributions, preference gradients, formalisation frontiers, and classification regions
3. **[[principle-deterministic-over-probabilistic|A6]] tension** — the three-tier reasoning stack unable to accommodate structured probabilistic reasoning (validated risk calculators, Bayesian diagnostic reasoning)
4. **BFO/PROV-O non-alignment** — the [[ontara-discussion-ontological-grounding-2026-03-22|ontological grounding paper]] and the reasoning metamodel making slightly different claims about the upper ontology stack

### Phase 2: Secondary Paper Review

At Ella's request, Claude reviewed four additional papers for their interaction with the consolidation paper agenda:

- **[[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge (Session 46)]]** — substantial impact. The [[principle-unity-principle|unity principle (A11)]] was born here; Register 2+ (inferential self-knowledge) converges with the reasoning metamodel's evidence architecture; the three interpretive frames for weights (costs/preferences, fuzzy judgements, probabilities) were first identified here and have remained stable across 100 sessions.
- **[[ontara-architecture-decision-knowledge-evaluation|Knowledge Evaluation Architecture (Session 11)]]** — moderate impact. The five-layer SystemStateAssessment ([[concept-five-layer-self-knowledge|F1/C6]]) is the first concrete implementation of coordinate-space reasoning; remediation classification maps onto constraint geometry.
- **[[ontara-discussion-comprehension-architecture-2026-03-19|Comprehension Architecture (Session 45)]]** — moderate impact, mostly subsumed into the intrinsic self-knowledge paper. Added the demonstrators-as-pedagogical-anchors insight.
- **[[ontara-discussion-governance-granularity-and-cross-references-2026-04-04|Governance Granularity and Cross-References (Session 132)]]** — significant impact. The three-tier decomposition's T2/T3 boundary is itself a coordinate-space boundary (the FormalisationFrontier region subtype); cross-reference properties are constraints on governance-space trajectories.

### Phase 3: Discussion Paper Production

The consolidation paper was produced with 15 sections covering: epistemic vocabulary reconciliation (three orthogonal dimensions that compose), Region taxonomy enrichment (seven subtypes grounded in BFO), constraint geometry formalisation (HardConstraints as boundaries, SoftConstraints as cost fields, GradedRules as truth fields), comprehension–reasoning convergence (Register 2+ and SEPIO+PROV-O are the same pattern), BFO/PROV-O alignment (dual subclassing), A6 reformulation (deterministic paths through probabilistically characterised landscapes), adjacent technologies (PROV-O/CCO overlap, OWL expressivity limits, openEHR alignment, Temporal as provenance source, SHACL), and revised Stage 7 phasing (Phase 0 coordinate consolidation before Phase 1 reasoning foundation).

The paper explicitly references all eleven contributory documents plus three Perplexity research papers, establishing a cross-reference web that prevents silent regression and amnesic lacunae.

Ella instructed that this paper should be actively considered for its relevance with every significant piece of work undertaken — it is a consolidation document that touches nearly every major architectural commitment.

### Phase 4: IG, Cybersecurity, and BI Considerations

Ella raised whether information governance, cybersecurity, robustness, and performance concerns should influence design at this stage. Analysis concluded that the existing architectural boundaries (vocabulary vs instance, platform vs tenant, type vs data) align naturally with IG and security requirements. Three observations were captured as emergent ideas:

- **E023** — The provenance architecture is inherently IG-sensitive because provenance instances *are* clinical data; the type/instance separation already enforced by [[concept-authority-zones|B29]] and [[concept-multi-tenancy|A13]] is the natural encryption boundary.
- **E024** — Pseudonymisation and anonymisation are describable as [[concept-coordinate-framework|coordinate-framework]] transformations on the identity axis.
- **E025** — Coordinate axes are structurally close to BI dimensions; the epistemic reconciliation enables clean actual/projected/simulated filtering for analytics.

## Documents Produced

1. **Discussion paper:** `ontara-discussion-coordinate-framework-revisited-2026-04-05.md` — placed directly in vault at `04 Ontara Architecture/`
2. **Emergent Ideas Log:** Three new entries (E023, E024, E025) added directly to vault

## Register Concepts Exercised

Existing concepts exercised or identified for update: [[principle-deterministic-over-probabilistic|A6]], [[principle-intrinsic-self-knowledge|A10]], [[principle-unity-principle|A11]], [[concept-coordinate-framework|A12]], [[concept-multi-tenancy|A13]], [[concept-weighted-relationships|B14]], [[concept-temporal-reference-frames|B16]], [[concept-epistemic-modality|B17]], [[concept-ontology-stack|B19]], [[concept-authority-zones|B29]], B30–B35, [[concept-five-layer-self-knowledge|C6]], F1, [[concept-cross-domain-validation|J1]], [[concept-valence|L7]], [[concept-coordinate-space-snapshots|L8]], [[concept-goal-seeking-computation|L9]]. No new concepts proposed — this is a consolidation paper.

## Governance Actions This Session

- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] updated with E023, E024, E025

## Open Items Carried Forward

- S146-D1 to D8 (reasoning metamodel design decisions) — unresolved, pending this paper's consolidation
- S147-D1 to D7 (this session's design decisions) — proposed, awaiting confirmation
- S147-Q1 to Q5 (this session's open questions) — raised
- [[ontara-ref-work-items|W-026]] (Stage 7 implementation plan) — open, revised by this session's Phase 0 proposal
- [[ontara-ref-work-items|W-027]] (Architecture Papers Index update) — open, now needs to include this session's paper too
