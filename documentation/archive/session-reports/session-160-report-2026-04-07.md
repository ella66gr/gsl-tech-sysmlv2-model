---
tags:
  - session-report
date: 2026-04-07
status: current
session: 160
---
# Session 160 — Report

**Date:** 7 April 2026
**Session type:** Discussion / Planning (mixed)
**Previous session:** 159 (Stage 7 formal closure, strategic snapshot refresh)

---

## Summary

Session 160 established the **[[ontara-discussion-clinical-domain-intake-framework-2026-04-07|Clinical Domain Intake Framework]]** — a structured methodology for characterising service domains, ingesting them into the Ontara platform, and using the intake process to validate platform vocabulary fitness and identify extension points. This is the project's post-[[stage7-plan-s.148-reasoning-metamodel|Stage 7]] direction: domain-exercising work to validate that the reasoning, governance, and clinical vocabularies fit real domain content.

The session began with a roadmap decision. With Stage 7 formally closed and all five phases complete, eight candidate workstreams were evaluated. Domain-exercising work was selected as the highest priority, on the grounds that the reasoning metamodel's 42 OWL classes are structurally validated but have never been populated with real domain content. The risk is representational inadequacy — vocabulary that is logically consistent but doesn't fit the domains it's meant to describe. This risk increases in cost (not detectability) as subsequent workstreams build layers on top of unvalidated assumptions.

The primary deliverable is a substantial discussion paper: **"[[ontara-discussion-clinical-domain-intake-framework-2026-04-07|Clinical Domain Intake Framework: A Methodology for Domain Characterisation, Ingestion, and Platform Fitness Validation]]."** The paper builds explicitly on the [[domain-paws|Paws]] demonstrator intake precedent (Sessions 43–44) and introduces three components:

1. **A feature taxonomy** — eight typed dimensions characterising clinical service domains (pathway topology, decision structure, temporal profile, risk profile, governance density, stakeholder complexity, information intensity, financial structure). Explicitly provisional — expected to grow as more domains reveal new dimensions.

2. **A proforma intake schema** — ten structured sections mapping domain features to specific meta model elements (BMM part defs, reasoning classes, governance vocabulary, OGMS primitives). Designed as a *post-hoc completeness checklist*, not a fill-in template. The Paws precedent established that the richest domain insights come from writing a narrative domain description first; the proforma verifies completeness afterwards.

3. **A coverage map concept** — six coverage statuses (Full, Partial, Gap–clear extension point, Gap–structural, Out of scope, Contextual) with branching-point annotations recording which dimension of constraint is responsible and where in the meta model the extension point lies. Lightened for first use — coverage observations embedded in the design note rather than a heavy formal artefact.

The [[domain-ears|Ears]] (Community Ear Care) Perplexity workup was introduced and analysed against the framework. The workup covers ten sections mapping well onto the BMM's six concerns plus clinical-specific dimensions. Key observations: the clinical pathway exercises the [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning metamodel]] (triage decisions, contraindication screening, procedure selection); the governance landscape (CQC, NMC, NICE, GDPR Article 9) exercises the [[ontara-discussion-deontic-governance-architecture-2026-04-03|deontic vocabulary]] at depth; the safety framework maps to STAMP/STPA structures.

A structured critique of the paper (exercising the newly established [[ontara-workflow-guide|workflow guide]] commitment 5) identified four genuine concerns, all accepted and implemented: the feature taxonomy's provisionality needed strengthening; the coverage map was too heavy for first use; the proforma should be narrative-first, proforma-second; and the representational self-assessment concept is [[ontara-workflow-emergent-ideas-log|EIL]]-worthy.

Eight design decisions were recorded (S160-D1 through S160-D8). Five open questions were identified (S160-Q1 through S160-Q5).

## Additional work completed

- **[[ontara-workflow-guide|Workflow guide]] §7.1 table fix.** Five wikilinks in the staleness thresholds table were corrected: three wrong filenames (foundations papers), two unescaped pipes ([[ontara-ref-strategic-snapshot|strategic snapshot]], [[ontara-ref-vision-architecture|V&A reference]]). The classic pipe-escaping regression documented in §12.
- **[[ontara--architecture-papers-index-READ-ORDER--|Architecture Papers Index]] contents index.** A 16-entry Obsidian-native contents index was added. Ella moved the file to `01 Ontara START HERE/`.
- **[[ontara-workflow-guide|Workflow guide]] §1 — commitment 5 added.** "Genuine critique at design milestones" established as a governing commitment, with operational detail added to §2.2 Work standing rules. Structured five-point critique framework: logical coherence, significant omissions, alternative approaches, untested assumptions, risks.
- **[[ontara-workflow-emergent-ideas-log|EIL]] entry E027.** "Platform representational self-assessment as a distinct form of self-knowledge" — the coverage map as a new flavour of [[principle-self-describing-system|A2]]/[[principle-intrinsic-self-knowledge|A10]], and [[concept-coordinate-framework|A12]] applied to domains as points in feature space. Routing deferred pending [[domain-ears|Ears]] intake experience.

## Register concepts exercised

- **[[principle-self-describing-system|A2]]** (self-describing system) — the coverage map extends self-description to representational capacity
- **[[concept-cross-domain-validation|A5]]** (validate in toy domains) — [[domain-ears|Ears]] as the clinical "toy domain"
- **[[principle-discipline-as-load-bearing-structure|A9]]** (discipline as load-bearing structure) — the intake methodology as disciplined, repeatable process
- **[[principle-intrinsic-self-knowledge|A10]]** (intrinsic self-knowledge) — coverage map as self-knowledge about representational reach
- **[[concept-coordinate-framework|A12]]** (coordinate framework) — domains as points in feature space (new application)
- **[[concept-multi-tenancy|A13]]** (multi-tenancy) — the intake framework is how tenants enter the platform
- **[[concept-co-evolution|J2]]** (co-evolution) — intake drives both model validation and tooling requirements
- **[[concept-non-constraining|J3]]** (non-constraining) — branching-point annotation preserves extensibility

## Emergent ideas captured

- **[[ontara-workflow-emergent-ideas-log|E027]]** — Platform representational self-assessment as a distinct form of self-knowledge

## Tier 1 principles and how they were honoured

- **[[principle-separation-representation-execution|A1]]** (separation of representation and execution) — the intake framework produces representational artefacts; execution follows from them
- **[[principle-model-generates-everything|A3]]** (model generates everything) — discussion of where the feature taxonomy lives in the model (S160-Q1)
- **[[principle-discipline-as-load-bearing-structure|A9]]** (discipline) — systematic methodology rather than ad hoc domain exploration; [[ontara-workflow-guide|workflow guide]] strengthened with commitment 5
- **[[concept-coordinate-framework|A12]]** (coordinate framework) — extended to domains as points in feature space
- **[[concept-multi-tenancy|A13]]** (multi-tenancy) — the intake framework operationalises tenant instantiation
- **[[concept-co-evolution|J2]]** (co-evolution) — the framework drives both vocabulary validation and tooling design
- **[[concept-non-constraining|J3]]** (non-constraining) — explicit branching points preserve future extensibility
