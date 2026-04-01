---
tags:
  - session-report
date: 2026-04-01
status: current
session: 97
---
# Session 97 Report — 1 April 2026
> `= this.file.path`

**Session type:** Discussion
**Focus:** Knowledge graph architecture and ontological grounding implementation — bringing BFO, domain ontologies, and the knowledge graph to life at the top of the dual-stack architecture.

---

## Summary

Session 97 was a major architectural discussion session that resolved five foundational questions about implementing the ontological grounding layers of the [[concept-dual-stack-architecture|dual-stack architecture]]. The session produced thirteen decisions (nine binding, two directional, two deferred), two emergent ideas (E019, E020), a new demonstrator domain ([[domain-ears|Ears]]), and a comprehensive discussion paper.

This session marks Ontara's transition from "BFO is mandatory" (decided Session 73, twenty-four sessions ago) to a concrete, engineered implementation architecture for the knowledge graph.

---

## Decisions Made

### Q1 — How to bring in BFO

**OWL 2 DL direct.** Author ontologies in Turtle/Manchester syntax using Protégé. Build a Python-owned bidirectional mapping pipeline for SysML v2 ↔ OWL synchronisation. openCAESAR/OML was thoroughly evaluated via Perplexity Pro research covering seven specific questions about ecosystem maturity, Flexo-SysMLv2 status, round-trip capability, toolchain, and risk. Key finding: OML does not solve the round-trip problem — it changes how you author ontologies, not how the two formalisms communicate. OML is parked as a potential future authoring convenience, not an architectural dependency.

### Q2 — Mid-level ontologies

**Platform-level (binding):** BFO + CCO + IAO. CCO provides enterprise/service business semantics; IAO grounds the comprehension architecture and information artefacts.

**Healthcare sector (binding):** OGMS. Driven by the new [[domain-ears|Ears (Community Ear Care)]] demonstrator — Ontara's fifth demonstrator domain, second clinical domain, and the OGMS adoption driver. OGMS will be extended where GAHT modelling requires precision beyond its base vocabulary; the three-entity distinction (gender identity as BFO quality, gender incongruence as ICD-11 classification, gender dysphoria as OGMS symptom) was established as the modelling approach.

**Directional:** OCE (commercial exchange), GSSO (gender/sex/sexual orientation). **Deferred:** OBI (biomedical investigations).

### Q3 — Triple store

**GraphDB Free** as primary triple store (best developer experience, built-in OWL-Horst reasoning, fast queries, free). **HermiT or Pellet** as external pipeline step for full OWL 2 DL consistency checking and classification. Fuseki as open-source fallback. Stardog for future re-evaluation if production needs in-line DL reasoning. The SPARQL endpoint abstraction ensures the store is a swappable component.

### Q4 — The mapping discipline

**Domain-semantic, not notation-semantic.** Map meaning, not syntax. The knowledge graph captures what BMM/SMM concepts *mean* ontologically, not the SysML notation they're authored in.

**Three-stratum graph architecture (E019):** Metamodel graph (SysML traceability), domain graph (BFO-grounded semantics — the canonical layer), correspondence graph (explicit mapping records with provenance and authority zones).

**Authority zones (E020):** SysML-authoritative (structural engineering), OWL-authoritative (ontological semantics), shared-constrained (labels, definitions, annotations with explicit merge rules).

**Five-stage Python pipeline:** Parse SysML → project to mapping IR → map to OWL/RDF → reason/validate → round-trip diff.

### Q5 — Relationship to existing SysML model

**Additive, not disruptive.** The existing model gains `@BfoType` metadata annotations. Everything else is new infrastructure alongside what exists. The knowledge graph is a parallel representation, not a replacement.

### IRI scheme

`https://ontara.dev/ontology/` for vocabulary, `https://ontara.dev/data/` for instance data. Ontara owns the `ontara.dev` TLD.

---

## New Demonstrator Domain

**Ears (Community Ear Care Service)** — Ontara's fifth demonstrator domain and second clinical domain. A community-based ear care service built around ear irrigation for cerumen impaction. Simple procedural pathway: referral → assessment → pre-treatment → intervention → post-procedure check → follow-up. Exercises all six BMM concerns and OGMS clinical primitives. Architecturally, Ears is to clinical modelling what [[domain-cafe|Cafe]] is to non-clinical BMM modelling. Domain note created at [[domain-ears|domain-ears.md]]; demonstrators index updated.

---

## Emergent Ideas Captured

- **E019 — Three-stratum knowledge graph architecture.** Metamodel / domain / correspondence graph strata. The correspondence graph is the first-class mapping layer that makes round-trip tractable. The critical insight: most SysML↔OWL mapping projects fail because they bury correspondence assumptions in code rather than treating them as first-class architecture.

- **E020 — Authority zones for round-trip governance.** SysML-authoritative vs OWL-authoritative vs shared-constrained constructs. Analogous to [[principle-separation-representation-execution|A1]] applied at the formalism boundary. The operational discipline that prevents synchronisation fragility.

Both captured in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] with full context and connections.

---

## Deliverables

1. **Discussion paper:** [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture and Ontological Grounding Implementation]] — comprehensive treatment of all five questions, decisions, mapping architecture, pipeline design, IRI scheme, and forward plan.
2. **Domain note:** [[domain-ears|Ears (Community Ear Care Service)]] — outline of the new clinical demonstrator domain.
3. **Demonstrators index update** — Ears added.
4. **Emergent Ideas Log update** — E019 and E020 captured with full context.
5. **Perplexity research document** — [[ontara-research-(perplexity) - ontologies & knowledge-graphs|OML/openCAESAR ecosystem investigation]] (seven questions). Placed in [[ontara - index-research-background|07 Research & Background]].

**Key reference documents consulted:** [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding for the Coordinate Framework]] (Session 59), [[ontara-research-(perplexity) - ontologies & domain coordinates|Perplexity: Ontologies and Domain Coordinates]], [[ontara-research-(perplexity) - ontology-dsl-mapping-sync|Perplexity: Ontology-DSL Mapping and Sync]].

---

## Register Concepts Exercised

### Tier 1 principles

| Principle | How exercised |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Applied at the formalism boundary: authority zones determine which formalism is authoritative for which content |
| [[principle-self-describing-system\|A2]] | Knowledge graph extends self-description to ontological semantics |
| [[principle-model-generates-everything\|A3]] | Refined: the combined SysML + OWL representation generates everything |
| [[principle-two-meta-model-distinction\|A4]] | Domain graph reflects BMM/SMM distinction with BFO grounding |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Authority zones and correspondence graph are disciplined practices |
| [[principle-intrinsic-self-knowledge\|A10]] | Operates over the domain graph |
| [[principle-unity-principle\|A11]] | Domain graph is the single semantic authority |
| [[concept-co-evolution\|J2]] | Knowledge graph evolves alongside SysML model and console |
| [[concept-non-constraining\|J3]] | All decisions verified non-constraining; SPARQL abstraction enables store switching |

### Structural concepts directly exercised

- [[ontara-ref-master-register|B18]] (BFO — mandatory) — implementation architecture defined
- [[ontara-ref-master-register|B22]] (knowledge graph as canonical store) — three-stratum architecture designed
- [[ontara-ref-master-register|B23]] (OWL 2 DL as mandatory) — authoring and reasoning approach defined
- [[ontara-ref-master-register|B24]] (mapping ontology) — correspondence graph is the concrete realisation

---

## Open Questions

1. The complete BFO mapping table for all 34 BMM `part def`s needs careful, element-by-element work. Some mappings (e.g. `ResourceType` as potentially polymorphic between material artefact and agent) will require design decisions.
2. The `@BfoType` metadata def syntax needs checking against the [[ontara-ref-master-register|SysML v2 syntax reference]] and validating in Syside.
3. CCO's eleven sub-ontologies need assessment for which specific sub-ontologies are needed immediately vs which can be imported incrementally.
4. The [[ontara - index-research-background|Research & Background index]] needs updating to include the new [[ontara-research-(perplexity) - ontologies & knowledge-graphs|Perplexity research document]] (already placed).

---

*Session 97 report written 1 April 2026.*
