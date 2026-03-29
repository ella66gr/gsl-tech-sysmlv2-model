---
tags:
  - session-report
date: 2026-03-29
status: current
session: 87
---
# Session 87 Report — 29 March 2026

**Session type:** Implementation
**Date:** 29 March 2026

---

## Summary

Session 87 implemented the [[ontara-ref-master-register|ArchitecturalSection concept (B27)]] in SysML v2 — the first step in the implementation sequence designed in [[session-86-report-2026-03-29|Session 86]]. The session produced a complete, Syside-validated `.sysml` file containing a single `ArchitecturalSection` part def instantiated 20 times, one for each section of the [[concept-dual-stack-architecture|dual-stack architecture]], with full metadata annotation stacks.

This is the first model content on the [[principle-two-meta-model-distinction|BSMM]] side of the architecture to be formally implemented as SysML — the 20 [[ontara-ref-master-register|architectural sections]] now exist as first-class model citizens alongside the 34 BMM elements.

---

## What Was Built

### ArchitecturalSection SysML implementation

A new top-level package `ArchitecturalStructure` in `model/architectural-structure.sysml` containing:

**Enumerations (3 new):**
- `ArchitecturalGroup` — six values: `sharedFoundation`, `leftStack`, `rightStack`, `crossCutting`, `greenContainer`, `infrastructure`
- `Formalism` — four values: `owl2dl`, `sysmlV2`, `runtime`, `mixed`
- `ImplementationStatus` — four values: `implemented`, `designed`, `referenced`, `notStarted`

**Metadata definition (1 new):**
- `ArchitecturalLocation` — four String attributes: `representationalModalitySummary`, `persistenceSummary`, `interfacesSummary`, `domainIllustrationSummary`. Complements `@PurposiveDescription` (which carries the purpose facet). Realises [[ontara-workflow-emergent-ideas-log|E016]] from the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]].

**Part definition (1 new):**
- `ArchitecturalSection` — eight attributes: `name` (String, kebab-case identifier), `displayName` (String), `group` (ArchitecturalGroup enum), `presentationOrder` (Integer), `primaryFormalism` (Formalism enum), `persistenceMechanism` (String), `implementationStatus` (ImplementationStatus enum), `docKey` (String, linking to vault prose).

**Part usages (20):**
All 20 sections of the [[concept-dual-stack-architecture|dual-stack architecture]], each carrying `@UserFacing`, `@PurposiveDescription`, and `@ArchitecturalLocation` metadata annotations with condensed summaries distilled from the [[ontara-discussion-architectural-campus-walk-2026-03-28|campus walk discussion paper]] (Sessions 84–85).

| Group | Sections | Count |
|---|---|---|
| Shared foundation | BFO | 1 |
| Left stack | Domain Ontologies, BMM General Vocabulary, Business Instance, Operational Domains, Business Process Patterns | 5 |
| Right stack | System Ontological Categories, BSMM General Vocabulary, System Instance, System Domains, Operational Simulation | 5 |
| Cross-cutting | Reflective Simulation | 1 |
| Green container | Rules and Constraints | 1 |
| Infrastructure | Terminology and Information Carriers, Mapping Ontology, Knowledge Graph, SysML v2, openEHR, Temporal, Operator | 7 |

### Validation approach

Two-phase Syside validation as specified in the [[ontara-discussion-architectural-section-implementation-design-2026-03-29|implementation design paper]] (§8.1):
1. Pilot file with part def, enums, metadata def, and two example instances (`bfo` and `operationalSimulation`) — validated clean.
2. Complete file with all 20 instances — validated clean.

This confirmed: metadata annotations on `part` usages (not just `part def`s) work correctly in Position A; the `@ArchitecturalLocation` metadata def with four String attributes parses cleanly; same-package enum resolution in `:>>` redefinitions works for all three enum types; eight `:>>` redefinitions per `part` usage is well within Syside's capacity.

---

## Design Decisions Executed

All five decisions from the [[ontara-discussion-architectural-section-implementation-design-2026-03-29|implementation design paper]] ([[session-86-report-2026-03-29|Session 86]]) were executed:

1. **Name-based identity.** Each section has a kebab-case `name` attribute (String value) and a camelCase SysML part usage identifier. Ordering via `presentationOrder` attribute, not identity.
2. **Single part def, 20 instances.** The [[ontara-ref-master-register|I9]] (part def / part) distinction is load-bearing — all sections share the same structural shape.
3. **Single `@ArchitecturalLocation` metadata def** with four attributes, complementing `@PurposiveDescription`.
4. **Short summaries in model, full prose in vault.** The model-as-index / vault-as-body pattern ([[ontara-workflow-emergent-ideas-log|E017]]). Each summary is one to two sentences; `docKey` links to the campus walk paper.
5. **Provisional package placement.** New top-level `ArchitecturalStructure` package with explicit provisional doc block, pending [[ontara-ref-master-register|BSMM vocabulary elaboration (B8)]].

### Enum naming adaptation

The design paper's kebab-case enum values (e.g. `shared-foundation`) were adapted to camelCase (e.g. `sharedFoundation`) because SysML v2 identifiers do not permit hyphens. This is consistent with the project's established enum naming convention throughout the model.

### Part usage naming

Three part usage identifiers received a `Section` suffix to avoid potential name collisions: `sysmlV2Section`, `openehrSection`, `temporalSection`, `operatorSection`. Other names are naturally unambiguous.

---

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[ontara-ref-master-register\|B27 (architectural section)]] | The concept being implemented — now a first-class model citizen |
| [[concept-dual-stack-architecture\|B21 (dual-stack architecture)]] | The architecture whose 20 sections are now modelled |
| [[ontara-ref-master-register\|B8 (BSMM implicit gap)]] | Provisional package placement explicitly acknowledges this |
| [[ontara-ref-master-register\|I9 (part def / part distinction)]] | Load-bearing: single part def, 20 instances |
| [[principle-two-meta-model-distinction\|A4 (two meta model distinction)]] | Architectural sections are BSMM content — system architecture, not business |
| [[principle-model-generates-everything\|A3 (model generates everything)]] | Section metadata is extractable by generators |
| [[principle-intrinsic-self-knowledge\|A10 (intrinsic self-knowledge)]] | Short summaries are self-contained model content; full prose linked via docKey |
| [[principle-unity-principle\|A11 (unity principle)]] | Same comprehension metadata patterns serve architectural sections as BMM elements |
| [[concept-co-evolution\|J2 (co-evolution)]] | Model content created; generator and console work queued as next steps |
| [[concept-non-constraining\|J3 (non-constraining)]] | Name-based identity preserves ordering flexibility; provisional placement preserves BSMM design freedom |
| [[principle-discipline-as-load-bearing-structure\|A9 (discipline as load-bearing structure)]] | Two-phase validation before bulk population; systematic five-facet template |

### Emergent Ideas Log

No new emergent ideas this session. [[ontara-workflow-emergent-ideas-log|E016]] (`@ArchitecturalLocation` metadata def) and [[ontara-workflow-emergent-ideas-log|E017]] (model-as-index / vault-as-body pattern) from [[session-86-report-2026-03-29|Session 86]] were both realised in this implementation.

---

## Open Questions

None new. The remaining open questions from the [[ontara-discussion-architectural-campus-walk-2026-03-28|campus walk paper]] §12 (questions 5–9: BSMM vocabulary content, system ontological categories completeness, operational domain representation, [[concept-reflective-simulation|reflective simulation]] formalism, tenant activation model) remain open and are not prerequisites for the generator/console work.

---

## Tier 1 Principles Honoured

| Principle | How honoured |
|---|---|
| [[principle-separation-representation-execution\|A1 (separation of representation and execution)]] | Architectural sections are representational model content; execution characteristics are described, not enacted |
| [[principle-self-describing-system\|A2 (self-describing system)]] | The architecture now describes its own structural regions as first-class model content |
| [[principle-model-generates-everything\|A3 (model generates everything)]] | All section metadata is generator-extractable; JSON output structure designed (§5.6 of [[ontara-discussion-architectural-section-implementation-design-2026-03-29\|design paper]]) |
| [[principle-two-meta-model-distinction\|A4 (two meta model distinction)]] | Explicit BSMM classification with provisional package placement |
| [[principle-discipline-as-load-bearing-structure\|A9 (discipline as load-bearing structure)]] | Two-phase validation; systematic condensation from [[ontara-discussion-architectural-campus-walk-2026-03-28\|campus walk]] source |
| [[principle-intrinsic-self-knowledge\|A10 (intrinsic self-knowledge)]] | Summaries are self-contained; proportionate trade-off with docKey linkage acknowledged |
| [[principle-unity-principle\|A11 (unity principle)]] | Same annotation patterns (@UserFacing, @PurposiveDescription, @ArchitecturalLocation) as BMM elements |
| [[concept-co-evolution\|J2 (co-evolution)]] | Model content produced; generator and console work planned as immediate next steps |
| [[concept-non-constraining\|J3 (non-constraining)]] | Name-based identity; provisional package; no foreclosure of future BSMM design |

---

*Session 87 report. GenderSense Limited.*
