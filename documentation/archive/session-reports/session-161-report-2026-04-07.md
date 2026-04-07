---
tags:
  - session-report
date: 2026-04-07
status: current
session: 161
---
# Session 161 — Report

**Date:** 7 April 2026
**Session type:** Implementation (mixed — housekeeping + domain content creation)
**Previous session:** 160 (Clinical Domain Intake Framework)

---

## Summary

Session 161 produced the **[[ears-domain-description|Ears (Community Ear Care) domain description]]** — the first clinical domain narrative for the Ontara platform. This is the primary deliverable and the first step in the [[domain-ears|Ears]] intake sequence established by the [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|Clinical Domain Intake Framework]] (Session 160). The session also completed a **Repo README.md currency update** (S149 → S161), clearing the outstanding governance item.

### Ears Domain Description

The [[ears-domain-description|Ears domain description]] follows the [[paws-domain-description|Paws]] precedent (Sessions 43–44): a rich, deeply concrete narrative of a specific fictional business with named staff, personal texture, detailed premises, full financial modelling, and clinical depth. The fictional business is **Ears Community Ear Care Ltd**, a private earwax removal service in Ely, Cambridgeshire, owned and operated by Helen Kemp, a registered nurse with 15 years' NHS experience.

The domain description is substantially richer than the [[paws-domain-description|Paws]] equivalent in three key dimensions that exercise the platform's clinical, [[ontara-discussion-deontic-governance-architecture-2026-04-03|governance]], and [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning]] vocabularies:

1. **Clinical pathway depth.** A five-stage clinical pathway (pre-appointment screening → in-clinic assessment → procedure → post-procedure → domiciliary variation) with specific clinical decision points: red flag triage, contraindication checking (absolute and relative, differentiated by procedure type), procedure selection (irrigation vs microsuction vs combined vs refer), post-procedure outcome assessment, and capacity assessment under the Mental Capacity Act. Each of these maps to a specific [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning vocabulary]] exercise target.

2. **Governance density.** CQC registration and fundamental standards, NMC professional regulation and revalidation, NICE CKS guidance compliance, GDPR Article 9 (special category health data), duty of candour, safeguarding, Mental Capacity Act procedures, clinical audit programme, and clinical supervision structures. This exercises the [[ontara-discussion-deontic-governance-architecture-2026-04-03|deontic governance vocabulary]] at a depth no previous demonstrator has approached.

3. **Safety and risk framework.** Eight clinical risks with likelihood/severity/mitigation, seven operational risks, and an emergency equipment specification. These map to the STAMP/STPA control structures in the [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning vocabulary]] (SafetyConstraint, ControlStructure, ControlLoop, UnsafeControlAction).

The financial model deliberately places the business pre-break-even (estimated £10,800 deficit in year 1), creating financial planning tension that exercises the [[concept-financial-planning|FinancialPlanning]] concern more interestingly than a profitable business would.

Key characters: Helen Kemp (owner/lead clinician — chipped "World's Okayest Nurse" mug, open-water swimmer, cat called Gilbert), Ade Okafor (ear care practitioner — calm with anxious patients, brings cake), Del Finch (receptionist — ex-Royal Mail, hard of hearing in one ear, jar of boiled sweets, Jack Russell called Biscuit), Dr Priya Mehta (advisory GP — monthly lunches at the Almonry).

The domain is classified as **sector-regulated** (RegulatoryTier) — the highest tier among the current demonstrators. The modelling notes (§12) identify six specific reasoning vocabulary exercise targets and seven governance vocabulary exercise targets for subsequent sessions.

### README.md Update

The repo README.md was updated from Session 149 to Session 161, incorporating: Stage 7 (reasoning metamodel) as the lead current state item, PROV-O import, foundations papers refresh to v4/v3, Clinical Domain Intake Framework, updated SPARQL/ontology stack counts (56 queries, 12-file stack), reasoning vocabulary in the repo structure tree, updated key commands descriptions, and current session/document counts.

## Register concepts exercised

- **[[concept-cross-domain-validation|A5]]** (validate in toy domains) — [[domain-ears|Ears]] as the clinical "toy domain," validating platform vocabulary against clinical content
- **[[principle-discipline-as-load-bearing-structure|A9]]** (discipline as load-bearing structure) — systematic intake following the [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|Clinical Domain Intake Framework]] methodology
- **[[concept-coordinate-framework|A12]]** (coordinate framework) — [[domain-ears|Ears]] as a point in domain feature space (pathway topology, decision structure, governance density)
- **[[concept-multi-tenancy|A13]]** (multi-tenancy) — [[domain-ears|Ears]] as a new tenant instantiation, the fourth demonstrator domain entering the platform
- **[[concept-co-evolution|J2]]** (co-evolution) — the domain description drives vocabulary validation requirements for subsequent sessions
- **[[concept-non-constraining|J3]]** (non-constraining) — the modelling notes identify specific vocabulary exercise targets without pre-committing to outcomes

## Emergent ideas captured

None this session. The domain description is a content-creation deliverable, not an exploratory discussion.

## Tier 1 principles and how they were honoured

- **[[principle-self-describing-system|A2]]** (self-describing system) — §12 modelling notes make explicit what the platform should be able to describe about this domain
- **[[concept-cross-domain-validation|A5]]** (validate in toy domains) — [[domain-ears|Ears]] is deliberately lower-complexity than [[domain-gsl|GSL]] while being authentically clinical
- **[[principle-discipline-as-load-bearing-structure|A9]]** (discipline) — followed the [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|intake framework]] methodology and the [[ontara-workflow-guide|workflow guide]] close sequence
- **[[concept-coordinate-framework|A12]]** (coordinate framework) — the domain description implicitly locates [[domain-ears|Ears]] in feature space: simple pathway topology, moderate decision structure, high governance density, moderate stakeholder complexity
- **[[concept-multi-tenancy|A13]]** (multi-tenancy) — [[domain-ears|Ears]] enters the platform as a tenant through the standard intake process
- **[[concept-co-evolution|J2]]** (co-evolution) — the domain description creates demand for vocabulary validation (reasoning instances, governance instances) that will drive subsequent work
- **[[concept-non-constraining|J3]]** (non-constraining) — no architectural decisions made; the domain description is raw material for future validation work
