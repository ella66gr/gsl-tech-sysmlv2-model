---
tags:
  - session-report
date: 2026-04-05
status: current
session: 142
---
# Session 142 — Report

**Date:** 5 April 2026
**Session type:** Discussion (§3.2)
**Stage/Phase:** Stage 6, Block A Step 1

---

## Summary

Session 142 produced the Block A discussion paper "Domain Identity in the Dual-Stack Architecture" — the first deliverable of the Domain Identity and Governance Convergence workstream (Stage 6). The paper revises and extends the [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|Session 59 domain identity paper (B15)]] to resolve five design questions arising from the [[concept-dual-stack-architecture|dual-stack architecture (B21)]], [[concept-knowledge-graph|knowledge graph (B22)]], and [[ontara-discussion-deontic-governance-architecture-2026-04-03|governance vocabulary (B30–B35)]].

## Work Completed

The session addressed all five design questions identified in the Stage 6 plan §3.2:

**Q1 — Dual-stack placement.** Domain identity is split into `DomainIdentity` (BMM-side: regulatory tier, jurisdiction, regulated activities, purpose, vocabulary scope) and `DomainConfiguration` (SMM-side: canonical key, display label, package path, model path, lifecycle state). Connected by a bidirectional horizontal mapping. This follows the S121-Q1 precedent (GovernanceFramework / GovernanceFrameworkActivation split). Decision S142-D1.

**Q2 — OWL representation and BFO grounding.** The key insight: `DomainIdentity` is not the real-world service business — it is the platform's formal *specification* of a domain. This makes it an IAO `plan_specification` (information content entity), not a BFO `material entity`. `DomainConfiguration` is grounded as an IAO `data_item`. Both are information *about* the domain, avoiding the real-entity vs model-artefact confusion entirely. Decision S142-D2.

**Q3 — A13 promotion.** The paper recommends promoting A13 (multi-tenancy) from T1 candidate to binding Tier 1 principle. Evidence: 83 sessions of cross-domain validation, the governance activation tier's conceptual dependency on multi-tenancy, and the principle governing architectural structure rather than constraining clinical content. Decision S142-D3.

**Q4 — Interaction with governance activation.** Three new properties on `DomainIdentity` support the activation tier's applicability assessment: `jurisdiction` (Jurisdiction enum), `regulatedActivities` (RegulatedActivity enum, multi-valued), and `organisationalForm` (OrganisationalForm enum). No explicit service model manifest — the knowledge graph provides reachability via SPARQL. Decision S142-D4.

**Q5 — Revised attribute set.** The Session 59 attributes are preserved but distributed across the two `part def`s. `DomainPurpose` becomes multi-valued to resolve S59-Q4 (Paws dual purpose). Three new enums: `Jurisdiction` (5 values, UK devolution structure), `RegulatedActivity` (13 values, CQC HSCA 2008 Schedule 1), `OrganisationalForm` (4 values). Decisions S142-D6, S142-D7.

The paper also specifies the complete OWL class design: separate namespace (`ontara-domain:`), 2 classes, 6 enumeration classes, 8 object properties, 8 data properties, axioms (disjointness, enumeration closure, functional properties, minimum cardinality), and an example individual (Cafe). Decision S142-D5.

All four Session 59 open questions are resolved (§10 of the paper).

## Design Decisions

| ID | Decision | Rationale |
|---|---|---|
| S142-D1 | Split into DomainIdentity (BMM) + DomainConfiguration (SMM) | Follows S121-Q1 precedent; dual-stack discipline; clean activation tier interface |
| S142-D2 | DomainIdentity → IAO:plan_specification; DomainConfiguration → IAO:data_item | Both are information content entities — avoids BFO material entity confusion |
| S142-D3 | Promote A13 to binding T1 | 83 sessions of validation; governance tier depends on it; governs structure not content |
| S142-D4 | No service model manifest on DomainIdentity | Knowledge graph provides reachability; the graph is the manifest |
| S142-D5 | Separate OWL namespace (ontara-domain:) | Follows S125-D1 governance namespace precedent |
| S142-D6 | DomainPurpose multi-valued [1..*] | Resolves S59-Q4 (Paws dual purpose) |
| S142-D7 | Three new enums: Jurisdiction, RegulatedActivity, OrganisationalForm | Required for governance activation applicability assessment |

## Register Concepts Exercised

[[principle-separation-representation-execution|A1]] (separation of representation and execution), [[principle-self-describing-system|A2]] (self-describing system), [[principle-model-generates-everything|A3]] (model generates everything), [[principle-two-meta-model-distinction|A4]] (two meta model distinction), [[principle-discipline-as-load-bearing-structure|A9]] (discipline as load-bearing structure), [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge), [[principle-unity-principle|A11]] (unity principle), [[concept-multi-tenancy|A13]] (multi-tenancy — promotion recommended), [[concept-horizontal-mappings|B12]] (horizontal mappings), [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|B15]] (domain identity), [[concept-dual-stack-architecture|B21]] (dual-stack architecture), [[concept-knowledge-graph|B22]] (knowledge graph), [[concept-bfo-ontological-grounding|B23]] (BFO/OWL 2 DL), [[concept-three-stratum-knowledge-graph|B28]] (three-stratum KG), [[concept-authority-zones|B29]] (authority zones), [[concept-co-evolution|J2]] (co-evolution), [[concept-non-constraining|J3]] (non-constraining).

## Emergent Ideas

No new emergent ideas captured this session. The work was focused execution of a planned deliverable.

## Open Questions

None arising from this session. All five design questions are resolved. Implementation questions (SysML syntax choices, OWL pipeline approach) will be addressed in subsequent Block A sessions.

## Tier 1 Principles

| Principle | How honoured |
|---|---|
| A1 | Domain properties move from execution-layer config to representation layer |
| A3 | Generator and OWL pipeline derive from model — propagation chain extended |
| A4 | Explicit dual-stack placement with horizontal mapping — the defining exercise |
| A9 | Strict adherence to workflow, rigorous dual-stack discipline |
| A10 | System knows its domains from model state |
| A13 | Recommended for promotion to binding T1. Entire paper is the structural expression of multi-tenancy |
| J2 | Design addresses model, OWL, generator, and console together |
| J3 | Architecture supports future domains, jurisdictions, and regulated activities without structural changes |

## Deliverables

- Discussion paper: "Domain Identity in the Dual-Stack Architecture" — placed in vault at `04 Ontara Architecture/`

---

*Session 142, 5 April 2026. Discussion session. Block A Step 1 of the Domain Identity and Governance Convergence workstream (Stage 6).*
