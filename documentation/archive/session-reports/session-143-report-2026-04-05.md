---
tags:
  - session-report
date: 2026-04-05
status: current
session: 143
---
# Session 143 — Report

**Date:** 5 April 2026
**Session type:** Implementation (with minor housekeeping)
**Scope:** Block A, Steps 2–3 of the [[session-141-domain-governance-convergence-plan|Domain Identity and Governance Convergence plan]] — SysML implementation of the [[concept-dual-stack-architecture|dual-stack]] domain identity split (S142-D1).

---

## Summary

Session 143 implemented the domain identity [[concept-dual-stack-architecture|dual-stack]] split designed in the [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Session 142 discussion paper]]. Two new `part def`s — `DomainIdentity` (BMM-side) and `DomainConfiguration` (SMM-side) — were added to `foundation.sysml` in a new `Foundation::DomainRegistry` sub-package, connected by bidirectional [[concept-horizontal-mappings|horizontal mapping]] refs. Six enums were added to `Foundation::CommonTypes`: three original enums from the [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|Session 59 design]] (`RegulatoryTier`, `BmmVocabularyScope`, `DomainPurpose`) and three new enums from the Session 142 extension (`Jurisdiction`, `RegulatedActivity`, `OrganisationalForm`). Domain instances were created for all four domains ([[domain-cafe|Cafe]], [[domain-suds|Suds]], [[domain-paws|Paws]], GSL) with both identity and configuration parts cross-referenced via `ref :>>` redefinitions.

Syside verification produced one finding: `individual` is rejected as an enum literal by Syside despite not appearing in the [[ontara-ref-kerml-reserved-words|KerML reserved word list]]. The literal was renamed to `registeredIndividual`, which is more precise in the CQC/Companies Act context. A second finding was positive: multi-valued `attribute :>>` with tuple syntax works — `attribute :>> field = (EnumType::a, EnumType::b)` parses cleanly for both `[1..*]` and `[0..*]` multiplicities, extending the v3.13 verification of `ref :>>` tuples.

Both findings were recorded in the syntax reference (updated to v3.19) and the [[ontara-ref-kerml-reserved-words|KerML reserved words reference]]. The [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Session 142 discussion paper]] was annotated with the `individual` → `registeredIndividual` implementation note.

Minor housekeeping: an old pre-stage high-level plan (`ontara-high-level-plan-2026-03-18.md`) was moved from the Plans root to `07 Ontara History & Archive/` by Ella.

## What Was Built

**New SysML content in `foundation.sysml` (~210 lines):**

In `Foundation::CommonTypes` — six new `enum def`s:
- `RegulatoryTier` (4 literals) — Session 59 design
- `BmmVocabularyScope` (3 literals) — Session 59 design
- `DomainPurpose` (4 literals) — Session 59 design, S142-D6 multi-valued
- `Jurisdiction` (5 literals) — S142-D7
- `RegulatedActivity` (13 literals) — S142-D7, HSCA 2008 Schedule 1
- `OrganisationalForm` (4 literals) — S142-D7, `registeredIndividual` replacing `individual`

New `Foundation::DomainRegistry` sub-package:
- `DomainIdentity` part def (BMM, 9 attributes/refs) with IAO:plan_specification BFO grounding
- `DomainConfiguration` part def (SMM, 7 attributes/refs) with IAO:data_item BFO grounding
- 8 domain instances (4 identity + 4 configuration), all cross-referenced
- Paws exercises multi-valued `domainPurpose` (pedagogicalAnchoring + crossDomainValidation)
- GSL exercises multi-valued `regulatedActivities` (treatment + diagnosticAndScreeningProcedures)

**Syntax reference updated to v3.19:**
- Multi-valued `attribute :>>` tuple syntax verified (§2)
- `individual` added to reserved/problematic words (§10)
- `registeredIndividual` added to safe enum literals (§3, 97 total)
- Version history entry added

**KerML reserved words updated:**
- New §3 "Syside-rejected words not in either list above" with `individual` entry

**Session 142 discussion paper annotated:**
- Implementation note added to colophon recording the `individual` → `registeredIndividual` rename

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[principle-separation-representation-execution\|A1]] (separation of representation and execution) | Domain properties moved from execution-layer config to representation layer (SysML) |
| [[principle-model-generates-everything\|A3]] (model generates everything) | Domain identity is now a model concept, not scattered config |
| [[principle-two-meta-model-distinction\|A4]] (two meta model distinction) | Explicit BMM/SMM split with [[concept-horizontal-mappings\|horizontal mapping]] |
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline as load-bearing structure) | Rigorous [[concept-dual-stack-architecture\|dual-stack]] placement, syntax reference discipline |
| [[principle-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | System knows its domains from model state |
| [[principle-unity-principle\|A11]] (unity principle) | Single domain identity model serves comprehension, governance, generation, console |
| [[concept-multi-tenancy\|A13]] (multi-tenancy) | First structural expression — four domains as tenant instantiations |
| [[concept-horizontal-mappings\|B12]] (horizontal mappings) | DomainIdentity ↔ DomainConfiguration bidirectional ref |
| B15 (domain identity) | Core concept implemented |
| [[concept-dual-stack-architecture\|B21]] (dual-stack architecture) | Domain identity placed across both stacks |
| [[concept-co-evolution\|J2]] (co-evolution) | Model and reference documentation updated together |
| [[concept-non-constraining\|J3]] (non-constraining) | Design supports future domains, jurisdictions, regulated activities |

## Emergent Ideas

No new emergent ideas captured this session.

## Open Questions

1. **Multi-valued attribute tuple syntax — scale limits.** We verified 2-value tuples for both `[1..*]` and `[0..*]`. Untested: 3+ value tuples, and whether there's a practical limit. Not urgent — the current use cases (Paws dual purpose, GSL two regulated activities) are 2-value.

2. **`@UserFacing` and `@Comprehension` annotations on DomainIdentity.** The [[ontara-discussion-domain-identity-dual-stack-2026-04-05|discussion paper]] (§10.1) recommends these but they were out of scope for this session. Future implementation work.

3. **PatternCatalogue `DomainInstantiation.domain` migration.** The [[ontara-discussion-domain-identity-dual-stack-2026-04-05|discussion paper]] (§12.5) proposes migrating from `String` to `ref domain : DomainIdentity`. Future work following the [[deferred-string-to-typed-ref-migration|O25]] pattern.

## Tier 1 Principles — How Honoured

- **[[principle-separation-representation-execution|A1]]:** Domain properties now live in the representation layer, not execution-layer configuration.
- **[[principle-model-generates-everything|A3]]:** The SysML model is the source of truth for domain identity. Generators will derive from it.
- **[[principle-two-meta-model-distinction|A4]]:** The BMM/SMM distinction is explicitly maintained through the split design with [[concept-horizontal-mappings|horizontal mapping]].
- **[[principle-discipline-as-load-bearing-structure|A9]]:** Syntax reference updated immediately with findings. Reserved words documented. Discussion paper annotated.
- **[[concept-multi-tenancy|A13]]:** Multi-tenancy is structurally expressed for the first time — four domains as tenant instantiations with formal identity.
- **[[concept-co-evolution|J2]]:** Model content and reference documentation co-evolved.
- **[[concept-non-constraining|J3]]:** The design supports adding new domains, jurisdictions, and regulated activities without structural changes.
