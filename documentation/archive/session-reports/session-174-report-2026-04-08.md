---
tags:
  - session-report
date: 2026-04-08
status: complete
session: 174
---
# Session 174 Report — 8 April 2026

## Session Type

Mixed: Discussion → Planning

## Summary

Session 174 was a significant exploratory session that established a new workstream direction for the Ontara project. Beginning from Ella's long-held interest in a state-driven architecture, the session explored the role of state, state transition, and status on the Ontara platform, developed the concept of an Ontara Portal as a user-facing platform shell, and produced both a [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|discussion paper]] and a [[ontara-stage8-plan-high-level-s.174-portal|Stage 8 high-level plan]].

### Key outcomes

1. **State/status distinction established.** Three related but distinct concepts formalised: state (the actual condition of an entity), state transition (governed by lifecycle definitions), and status (a concern-specific projection of state for a particular audience). Status is a comprehension operation over state — connecting to the [[ontara-discussion-comprehension-architecture-2026-03-19|comprehension architecture]].

2. **Ontara Portal concept.** A new user-facing platform, distinct from the [[ontara-ref-shell-commands|Ontara Console]] (architect/developer view). Organised around the state-driven operator paradigm — the operator's primary view is a landscape of stateful entities with status projections. The operator experience is mediated through multiple concurrent states of components that the operator configures and instantiates.

3. **Module architecture.** Modules as the primary unit of lifecycle management — composable, connectable, nestable. A viable running business is a composed assembly of modules. Three empirical module roles identified (business, analytical, generative) as a working taxonomy. Modules are model concepts (modelled in SysML), not runtime presentation concepts — consistent with [[principle-model-generates-everything|A3]].

4. **Epistemic dimension and comparative simulation.** Operators can create sibling module variants for comparison, connecting to the [[concept-coordinate-framework|coordinate framework (A12)]] and [[concept-coordinate-space-snapshots|coordinate space snapshots (L8)]]: same structure with different assumptions, or same assumptions with different structure. Generative modules feed synthetic data; analytical modules present comparisons. Progressive fidelity allows iterating from simplified to production-like conditions.

5. **Progressive governance.** Governance is available, not imposed during experimentation. The enforcement boundary is at the promotion path from simulation to production, not during experimentation. The platform makes governance explorable.

6. **Discussion paper produced.** [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|"The Ontara Portal: State-Driven Operator Experience and Module Architecture"]] — 16 sections including full design milestone critique with Ella's responses, alternative approaches and precedent survey, and 5 critique observations/watchpoints.

7. **Stage 8 plan produced.** [[ontara-stage8-plan-high-level-s.174-portal|Five-phase plan]]: Empty Shell → Module Lifecycle → Domain Context and Composition → Simulation and Comparison → Governance and Promotion. Prototyping-led ethos. SvelteKit + SQLite stack. Estimated 19–31 sessions.

### Design decisions (exploratory, not binding)

- **S174-D1:** The Ontara Portal is a separate application from the Ontara Console
- **S174-D2:** Modules are modelled in SysML (model concepts, not runtime-only)
- **S174-D3:** The module lifecycle should be decomposed into multiple intersecting lifecycles (installation, operational, epistemic)
- **S174-D4:** Domain coherence constraint — everything under a domain shares a common ontological frame
- **S174-D5:** Governance enforcement boundary is at the promotion path, not during experimentation
- **S174-D6:** Stage 8 technology stack: SvelteKit + Svelte 5 + Tailwind v4 + Flowbite Svelte + SQLite

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Module configuration as representation; activation as execution; promotion path as the experience of A1 |
| [[principle-self-describing-system\|A2]] | Portal as the primary surface for self-description to users |
| [[principle-model-generates-everything\|A3]] | Directional: modules are model concepts; prototype uses hand-coded definitions with SysML modelling to follow |
| [[principle-two-meta-model-distinction\|A4]] | Portal unifies BMM (business configuration) and SMM (system operation) at the experience layer |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Prototype ethos does not mean careless work |
| [[principle-intrinsic-self-knowledge\|A10]] | Status projections dynamically computed from module state |
| [[concept-coordinate-framework\|A12]] | Epistemic dimension of modules maps to [[concept-coordinate-space-snapshots\|coordinate space snapshot types (L8)]] |
| [[concept-multi-tenancy\|A13]] | Domain lifecycle as operational expression of tenancy; multi-tenant from the start |
| [[concept-co-evolution\|J2]] | Build what we can see; co-evolution of portal and module vocabulary |
| [[concept-non-constraining\|J3]] | Prototype architecture must not foreclose production evolution or third-party extensibility |
| [[concept-operational-simulation\|L5]] | Module activation conceptually invokes the [[concept-operational-simulation\|operational simulation]] |
| [[concept-valence\|L7]] | [[concept-valence\|Valence]] shapes analytical module output |

## Emergent Ideas

No new [[ontara-workflow-emergent-ideas-log|emergent ideas log]] entries this session. The portal concept and module architecture are captured in the [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|discussion paper]].

## Observations and Watchpoints

| ID | Summary | Source | Proposed work type |
|---|---|---|---|
| S174-CQ-1 | Comprehension architecture untested against runtime compositional complexity | Discussion paper critique | CON, RGV |
| S174-CQ-2 | SysML v2 constructs for module identity/lifecycle/composition not yet identified | Discussion paper critique | BMM, KGO |
| S174-CQ-3 | Eight-state lifecycle should decompose into intersecting lifecycles | Discussion paper critique | BMM, CON |
| S174-CQ-4 | Promotion path is safety-critical interface; enforcement at promotion, not experimentation | Discussion paper critique | GSL, GOV |
| S174-CQ-5 | Module taxonomy is empirical/emergent, not fundamental | Discussion paper critique | BMM, CON |

## Open Questions

None deferred — all questions from the discussion are captured in the [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|discussion paper]] §14.

## Tier 1 Principles

A1, A2, A3, A4, A9, A10, A12, A13, J2, J3 were all relevant and honoured. The state-driven paradigm is a significant new surface for expressing many of these principles.
