# Session 83 Report

**Date:** 28 March 2026
**Session type:** Housekeeping / Discussion (mixed)
**Focus:** YAML frontmatter batch standardisation and StakeholderModel cross-element weight assessment

---

## Summary

Session 83 addressed both items under Priority B from the [[session-82-report-2026-03-28|Session 82]] preparation note.

**B1: YAML frontmatter batch standardisation.** A full audit of the Ontara vault identified 27 substantial documents lacking the YAML frontmatter convention established in [[session-80-report-2026-03-28|Session 80]] (§5.0 of the [[ontara-workflow-development-guide|workflow guide]]). The documents spanned standing reference documents, guides, discussion papers across all five thematic subfolders, and the non-technical overview. An instruction set was produced for Claude Code specifying exact values for the four minimum fields (`tags`, `date`, `status`, `session`) for each document, grouped by priority. Claude Code executed the batch: all 27 documents now have conformant frontmatter. Additionally, the [[ontara-ref-vision-architecture|Vision and Architecture Reference]] had its header reformatted — concatenated fields split onto separate lines and `Replaces:` changed to `Previous version:` per the [[session-80-report-2026-03-28|Session 80]] convention.

**B2: StakeholderModel cross-element weight assessment.** The three candidates from §5.8 of the [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|detailed design paper]] were assessed against the 20 domain instantiations implemented in [[session-81-report-2026-03-28|Session 81]] (GSL 7, Cafe 6, Paws 7). The assessment applied the [[ontara-ref-weighted-relationship-heuristics-and-config|heuristics (H1–H5)]] and tested each candidate against real domain evidence:

- **[[concept-stakeholder-model|CooperativeArrangement]] → [[concept-stakeholder-model|StakeholderRelationship]] (moderate):** In all three domains ([[domain-gsl|GSL]] shared care protocol, [[domain-cafe|Cafe]] delivery platform, [[domain-paws|Paws]] vet partnership), the cooperative arrangement subsumes the stakeholder relationship — there is no separate, parallel StakeholderRelationship for the same entity. The weight would lack an independently instantiated target. **Not added.**
- **[[concept-stakeholder-model|ReferralPathway]] → [[concept-stakeholder-model|StakeholderRelationship]] (moderate):** Same pattern — referral pathways exist within broader relationship contexts that aren't separately modelled as StakeholderRelationships. **Not added.**
- **[[concept-stakeholder-model|ExternalDependency]] → [[concept-stakeholder-model|CooperativeArrangement]] (moderate):** The "escalation" rationale describes a potential future state transition, not a current structural coupling. No domain instantiates both for the same entity. **Not added.**

**Decision:** None of the three candidates are added at this time. The assessment finds that in practice, StakeholderModel elements serve distinct relationship categories — entities are modelled as one element type or another, not as overlapping instances of both. The candidates remain documented in §5.8 of the [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|detailed design paper]] for reassessment if future domain evidence shows co-instantiation.

---

## Register Concepts Exercised

- **[[principle-discipline-as-load-bearing-structure|A9]] (discipline as load-bearing structure)** — the entire B1 work is an exercise of A9. YAML frontmatter enables Obsidian property-based search and filtering across the vault; documents without it are invisible to property queries.
- **[[concept-weighted-relationships|B14]] (weighted relationships)** — the B2 assessment applied the [[ontara-ref-weighted-relationship-heuristics-and-config|heuristics (H1–H5)]] and [[ontara-ref-weighted-relationship-directionality-definition|directionality definition]] to evaluate candidate weights against domain evidence.
- **[[concept-cross-domain-validation|J1]] (cross-domain validation)** — the B2 assessment tested candidates across all four demonstrator domains ([[domain-gsl|GSL]], [[domain-cafe|Cafe]], [[domain-paws|Paws]], and implicitly [[domain-suds|Suds]]).
- **[[concept-non-constraining|J3]] (non-constraining)** — the decision to defer rather than add speculative weights preserves the weight model's precision without foreclosing future addition.

No new register concepts introduced. No register updates required.

---

## Tier 1 Principles

| Principle | How honoured |
|---|---|
| [[principle-discipline-as-load-bearing-structure|A9]] (discipline) | B1 applies a standing convention systematically across the vault. B2 applies the weight heuristics rigorously rather than adding speculative weights. |
| [[concept-cross-domain-validation|J1]] (cross-domain validation) | B2 tested all three candidates against real domain instantiations across [[domain-gsl|GSL]], [[domain-cafe|Cafe]], and [[domain-paws|Paws]]. |
| [[concept-co-evolution|J2]] (co-evolution) | Not directly exercised — no model or tooling changes this session. |
| [[concept-non-constraining|J3]] (non-constraining) | B2 decision explicitly preserves future optionality — candidates remain documented for reassessment. |

---

## Carried Forward

- **Priority A (Stage 4 graph rendering refinements)** — viewport fitting and bidirectional edge separation. Carried forward since [[session-75-report-2026-03-27|Session 75]]. Code work. Addresses [[ontara-workflow-emergent-ideas-log|E001]].
- **Priority C items** — [[concept-dual-stack-architecture|BSMM]] General vocabulary elaboration scoping ([[ontara-ref-master-register|B25]]); [[ontara-stage-4-high-level-plan-2026-03-21|Stage 4]] Phases 2–5. Not addressed this session.

---

*Session 83 report written 28 March 2026.*
