---
tags:
  - session-report
date: 2026-04-04
status: current
session: 132
---
# Session 132 — Report

**Date:** 4 April 2026
**Type:** Discussion (mixed — annotation + design)

---

## Summary

Session 132 addressed three work items from the [[ontara-ref-work-items|work item tracker]]. W-019 (Phase F paper annotations) was completed as a quick opening task. W-013 (decomposition granularity) and W-014 (legislative cross-references) were resolved jointly in a single discussion paper. W-010 (global console navigation context) received initial design work as a separate discussion paper.

No code changes were made. No model files were modified. The session produced two discussion papers and annotated two existing papers. No repo-affecting changes beyond the vault.

## Work Completed

### W-019 — Phase F paper annotations (completed)

Annotated two discussion papers to cross-reference the [[session-130-stage5-cqc-governance-mvp-plan|CQC Governance MVP]] completion (Sessions 130–131):

- **[[ontara-discussion-deontic-owl-class-design-2026-04-03|OWL class design paper]]** (Session 125) §12.4: Added a callout block summarising the MVP (21 individuals, 10-file stack CONSISTENT, 23/23 SPARQL). Inline annotations on the "Activation tier classes" bullet (library tier exercised, activation deferred) and the "CQC archetype" bullet (marked completed).
- **[[ontara-discussion-deontic-governance-architecture-2026-04-03|Governance architecture paper]]** (Session 121) §15: Added a callout block noting partial realisation of the CQC archetype — library tier concrete, activation and operational tiers remain as future work. §16.2 S121-Q5 annotated as resolved.

Both papers were edited in-place via MCP `edit_file`.

### W-013 + W-014 — Decomposition granularity and legislative cross-references (resolved)

Produced a joint discussion paper: [[ontara-discussion-governance-granularity-and-cross-references-2026-04-04|Decomposition Granularity and Legislative Cross-References]].

**Decomposition granularity (S121-Q2):** Proposed a three-tier standard decomposition validated by the MVP experience: T1 (statutory obligations, OWL individuals), T2 (guidance directives, OWL individuals), T3 (evidential specifications, data property strings). The primary decomposition criterion is independent assessability — can the sub-components have different compliance states? A T2b sub-tier was identified for tenant-specific guidance directives, connecting granularity to [[concept-multi-tenancy|multi-tenancy (A13)]]. At the recommended level, a full CQC Fundamental Standards framework would contain approximately 150–300 directive individuals — manageable for hand-authoring and trivial for GraphDB.

**Legislative cross-references (S121-Q4):** Identified five cross-reference patterns encountered in the MVP (vertical hierarchy, intra-regulation, inter-instrument, conditional activation, temporal supersession). Pattern 1 is already modelled. Proposed five new object properties and one new data property to cover patterns 2–5. Key heuristic: a textual reference should become a structural property only when it changes the normative force of the directive. Vocabulary extensions are additive and should be implemented when the next regulation is formalised.

Six design decisions (S132-D1 through S132-D6) and three open questions (S132-Q1 through S132-Q3) recorded.

### W-010 — Global console navigation context (initial design)

Produced a discussion paper: [[ontara-discussion-console-navigation-context-2026-04-04|Global Console Navigation Context]].

Designed a Svelte 5 reactive NavigationStore distributed via setContext, with an opaque state contract (routes define their own captureState/restoreState callbacks), semantic navigation stack (recording not just "where" but "why"), breadcrumb trail UI, NavLink convenience component, sessionStorage backup, and journey export. Three implementation phases: Phase 1 (foundation + glossary/ontology migration), Phase 2 (full console adoption + semantic labels), Phase 3 (live journey graph). Proposed I18 (global console navigation context, T3) for registration in the [[ontara-ref-master-register|master register]].

Five design decisions (S132-D7 through S132-D11) and four open questions (S132-Q4 through S132-Q7) recorded.

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[concept-non-constraining|J3]] (non-constraining) | T3 evidential specs as promotable strings; `crossReferenceNote` as escape valve; NavLink opt-in pattern |
| [[concept-multi-tenancy|A13]] (multi-tenancy) | T2b tenant-specific guidance directives; framework library vs tenant-level decomposition |
| [[principle-two-meta-model-distinction|A4]] (two meta models) | Cross-reference properties connect to dual-stack; framework library (SMM) vs activation (BMM) |
| [[concept-authority-zones|B29]] (authority zones) | Governance ontology remains OWL-authoritative |
| B30 (deontic directive vocabulary) | Extended with cross-reference semantics and granularity heuristics |
| B31 (governance framework library) | Granularity heuristics govern library content |
| B33 (normative instrument taxonomy) | Inter-instrument cross-references extend instrument relationships |
| [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) | Console navigation context — system knows user's exploration path |
| [[principle-unity-principle|A11]] (unity principle) | Navigation serves comprehension, auditing, onboarding, and rationale capture |
| [[concept-comprehension-layer|I14]] (comprehension layer) | Navigation context as part of model comprehension |
| [[principle-discipline-as-load-bearing-structure|A9]] (discipline) | Single navigation system prevents per-page workaround proliferation |
| [[concept-co-evolution|J2]] (co-evolution) | Navigation infrastructure built as cross-linking density demands it |
| [[concept-weighted-relationships|B14]] (weighted relationships) | Journey traces capture which relationships the user followed |

## New Concepts Proposed

| Code | Concept | Tier | Description |
|---|---|---|---|
| I18 | Global console navigation context | T3 | Shared reactive store providing semantic navigation history, page state preservation, breadcrumb trail, and journey capture across all console views |

No new concepts proposed from the governance granularity/cross-reference work (refinements of existing B30, B33).

## Design Decisions

| ID | Decision | Source |
|---|---|---|
| S132-D1 | Three-tier standard decomposition: statutory → guidance → evidential | W-013/W-014 paper |
| S132-D2 | Independent assessability as primary decomposition criterion | W-013/W-014 paper |
| S132-D3 | Five new cross-reference object properties covering patterns P2–P5 | W-013/W-014 paper |
| S132-D4 | `crossReferenceNote` data property as escape valve | W-013/W-014 paper |
| S132-D5 | Cross-referenced instruments should be formalised before driving decomposition | W-013/W-014 paper |
| S132-D6 | Vocabulary extensions are additive; implemented when next regulation is formalised | W-013/W-014 paper |
| S132-D7 | Navigation state in Svelte 5 store + sessionStorage, not URLs | W-010 paper |
| S132-D8 | Page state is opaque to the store — routes define own state shapes | W-010 paper |
| S132-D9 | Stack-worthy = "I went to…"; in-page = "I adjusted…" | W-010 paper |
| S132-D10 | Opt-in adoption — existing routes unchanged until migrated | W-010 paper |
| S132-D11 | Breadcrumb between navbar and content, within sidebar-offset region | W-010 paper |

## Open Questions

| ID | Question | Source |
|---|---|---|
| S132-Q1 | Should `crossReferencesRegulation` be symmetric or directed? | W-013/W-014 paper |
| S132-Q2 | Which regulation to formalise next after Regulation 12? | W-013/W-014 paper |
| S132-Q3 | Should T2b tenant-specific directives live in framework library or tenant ontology file? | W-013/W-014 paper |
| S132-Q4 | Should navigation store persist across full page reloads? | W-010 paper |
| S132-Q5 | How should breadcrumb interact with browser back/forward? | W-010 paper |
| S132-Q6 | NavLink scope — cross-route only, or also intra-page? | W-010 paper |
| S132-Q7 | Maximum useful stack depth? | W-010 paper |

## Emergent Ideas

No new emergent ideas captured this session.

## Tier 1 Principles Honoured

- **[[principle-discipline-as-load-bearing-structure|A9]] (discipline):** Close sequence followed strictly per [[ontara-workflow-development-guide|workflow guide]] — guide read first, steps in order.
- **[[concept-non-constraining|J3]] (non-constraining):** All proposed vocabulary extensions and navigation patterns are additive and opt-in; no existing structures constrained.
- **[[concept-multi-tenancy|A13]] (multi-tenancy):** Governance granularity design explicitly considers the tenant-specific dimension (T2b directives).
- **[[concept-inception-capture|J13]] (inception capture):** [[ontara-workflow-emergent-ideas-log|Emergent ideas log]] reviewed (C5) — no new ideas this session, but log fully current.

---

*Session 132 report produced 4 April 2026.*
