---
tags:
  - session-report
date: 2026-04-07
status: current
session: 162
---
# Session 162 — Report
> `= this.file.path`

**Date:** 7 April 2026
**Session type:** Implementation (mixed with discussion)
**Close status:** Emergency close — session terminated before close sequence. Close steps completed retroactively in Session 163.

---

## Summary

Session 162 produced the [[ontara-ears-vertical-connection-map|Ears vertical connection map]] — the second step of the clinical domain intake sequence (§8.3 of the [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|intake framework]]). This is the first clinical domain exercise of the platform's full representational reach, extending the [[paws-vertical-connection-map|Paws four-layer pattern]] to a six-layer structure incorporating the [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning]] and [[ontara-discussion-deontic-governance-architecture-2026-04-03|governance]] vocabulary stacks.

The session began with a thorough opening sequence (O1–O5), reading the Session 161 preparation note, [[ontara-ref-strategic-snapshot|strategic snapshot]], [[ontara-ref-work-items|work item tracker]], [[ontara-ref-master-register|master register]] Tier 1, the [[ears-domain-description|Ears domain description]], the [[paws-vertical-connection-map|Paws vertical connection map]] (structural precedent), the [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|clinical domain intake framework]], and the [[ontara-discussion-coordinate-framework-revisited-2026-04-05|coordinate framework revisited]] paper (standing instruction).

The vertical connection map was produced as a single document ([[ontara-ears-vertical-connection-map]]) and placed in `05 Ontara Demonstrators/Ears (Community Ear Care)/`. The map traces every element of the Ears domain description through six vocabulary layers: BFO/OGMS ontology → BMM General vocabulary → reasoning vocabulary → governance vocabulary → Ears business instance → generated systems. It includes cross-system traceability, observations on vocabulary fitness, coverage gaps and extension points, a comparison with Paws, design decisions, and register connections.

### Structured critique and extensions

Following the [[ontara-workflow-guide|§1 commitment 5]] milestone critique, the map was extended with two additional sections at Ella's direction:

1. **Domiciliary pathway as composite reasoning structure (§4.7).** This stretched the vocabulary by showing that care setting acts as a composite modifier — the same clinical core gets wrapped in different reasoning, safety, governance, and resource constraints depending on delivery setting. STAMP/STPA ControlStructures compose well (lone worker safety layering on clinical safety — exercising the [[ontara-discussion-coordinate-framework-revisited-2026-04-05|safety and resilience]] vocabulary from Stage 7 Phase 3). A new coverage gap was identified: setting-dependent obligation escalation (§10.6).

2. **Patient communication and engagement (§6.8).** Confirmed that communication is a cross-cutting concern parallel to [[concept-activity-awareness|activity awareness (C6)]], not a missing seventh concern. All 20 identified communication events distribute across existing concerns. A new coverage gap candidate emerged: the "reasoning output → governed communication → stakeholder" three-layer interaction pattern (§10.7).

Nothing broke. The vocabulary accommodated everything through parameterisation, validating the abstraction level. Coverage gaps rose from 5 to 7.

### Design decisions

Seven design decisions were recorded (S162-D1 to S162-D7):

- **S162-D1:** Six-layer structure for clinical domains (extending Paws four-layer pattern)
- **S162-D2:** OGMS primitives mapped at Layer 1 (ClinicalEncounter, ClinicalFinding, Diagnosis, TreatmentProcess, TreatmentOutcome)
- **S162-D3:** Reasoning exercises structured by complexity gradient (triage → capacity assessment)
- **S162-D4:** Governance mapped as obligation chains, not flat lists
- **S162-D5:** Coverage gaps require cross-domain validation before promotion
- **S162-D6:** Domiciliary pathway treated as composite reasoning structure (parameterised by care setting, not a separate pathway)
- **S162-D7:** Patient communication treated as cross-cutting concern parallel to C6, not a seventh BMM concern

---

## Register Concepts Exercised

**Tier 1 principles honoured:**
- **[[principle-self-describing-system|A2]] (self-describing system):** The map exercises the system's ability to trace its own vocabulary through six layers of abstraction
- **[[principle-two-meta-model-distinction|A4]] (two meta model distinction):** BMM and SMM (including reasoning and governance vocabularies) kept distinct through separate layers
- **[[principle-discipline-as-load-bearing-structure|A9]] (discipline):** Six-layer structure applied systematically; extensions added through structured critique rather than ad hoc
- **[[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge):** The map demonstrates that the vocabulary can account for every domain element without requiring bespoke additions
- **[[principle-unity-principle|A11]] (unity principle):** [[concept-weighted-relationships|Weighted relationships]] inform the cross-system traceability analysis
- **[[concept-coordinate-framework|A12]] (coordinate framework):** [[domain-ears|Ears]] mapped as a point in feature space with clinical/reasoning/governance dimensions that [[domain-paws|Paws]] lacks
- **[[concept-multi-tenancy|A13]] (multi-tenancy):** Ears treated as a tenant instantiation, exercising vocabularies that are platform-level not domain-specific
- **[[concept-co-evolution|J2]] (co-evolution):** The map identifies where tooling support would be needed for the vocabulary layers it exercises
- **[[concept-non-constraining|J3]] (non-constraining):** Coverage gaps annotated as extension point candidates, not hard-coded solutions

**Tier 2 concepts exercised:** [[concept-domain-identity|B15]] (domain identity), B18/B19 (BFO/OGMS grounding — first substantive exercise of OGMS clinical primitives), [[concept-dual-stack-architecture|B21]] (dual-stack), [[concept-knowledge-graph|B22]] (knowledge graph), B23 (OWL 2 DL), [[concept-authority-zones|B29]] (authority zones), B30–B35 (governance vocabulary — fully exercised for the first time in a clinical domain), P1–P7 (reasoning and problem-solving concepts — all exercised).

---

## Emergent Ideas

No new emergent ideas were captured during this session. The work validated existing vocabulary rather than surfacing new concepts. The coverage gap candidates (§10.6 and §10.7) are recorded in the [[ontara-ears-vertical-connection-map|vertical connection map]] itself, not as [[ontara-workflow-emergent-ideas-log|EIL]] entries — they are findings of the analysis, not inception-moment insights.

---

## Open Questions and Deferred Items

1. The map assumes OGMS primitives will map cleanly to Ears at OWL instance level — untested at instance level (flagged in the structured critique)
2. Seven coverage gap candidates in §10 require cross-domain validation before any could be promoted to vocabulary extensions
3. Session close was not completed — all close steps deferred to Session 163

---

## Deliverables

| Deliverable | Location |
|---|---|
| [[ontara-ears-vertical-connection-map\|Ears vertical connection map]] | `05 Ontara Demonstrators/Ears (Community Ear Care)/ontara-ears-vertical-connection-map.md` |
