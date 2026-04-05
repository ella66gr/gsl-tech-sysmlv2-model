---
tags:
  - session-report
date: 2026-04-03
status: complete
session: 114
---
# Session 114 Report — 3 April 2026

**Session type:** Implementation + Housekeeping
**Focus:** [[session-111-stage5-phase2-plan|Stage 5 Phase 2]] Step 3 (cardinality restrictions) + README currency check
**Preparation note:** [[session-114-preparation-note]]
**Previous session:** [[session-113-report-2026-04-02|Session 113]]

---

## Contents

- [[#1. Session Objectives|§1. Session Objectives]]
- [[#2. What Was Done|§2. What Was Done]]
- [[#3. Design Decisions|§3. Design Decisions]]
- [[#4. Validation Results|§4. Validation Results]]
- [[#5. Axiom File Summary|§5. Axiom File Summary]]
- [[#6. Register Connections|§6. Register Connections]]
- [[#7. Files Changed|§7. Files Changed]]

---

## 1. Session Objectives

Two priorities from the [[session-114-preparation-note|preparation note]]:

- **Priority A:** Repo README.md currency check (10-session threshold, last updated Session 104).
- **Priority B:** [[session-111-stage5-phase2-plan|Stage 5 Phase 2]] Step 3 — existential and cardinality restrictions on the 13 object properties declared in Step 2.

Both completed.

---

## 2. What Was Done

### Memory edit: Phase 2 plan location

At session start, Claude spent excessive tool calls searching for the [[session-111-stage5-phase2-plan|Phase 2 plan]] in the wrong locations. A memory edit was added recording the correct path: `02 Ontara Development/Ontara Plans/Stage 5/`.

### Priority A: README.md currency check

The repo `README.md` was 10 sessions stale (Session 104). Six updates applied:

1. Renamed `gen_ontara_bmm.py` → `gen_owl_pipeline.py` in the repo structure tree and Key Commands section (old filename no longer exists).
2. Added `sysml_parser.py`, `validate_kg.py`, `ontara` CLI, and `ontology/axioms/` to the repo structure tree.
3. Refreshed the Current State section from Session 104 to Session 114 — describes Phase 1 complete, Phase 2 Steps 1–2 complete, Step 3 next.
4. Updated session count in Companion Knowledge Base section (72+ → 113+).
5. Updated session number in Development Methodology section.
6. Updated footer timestamp.

### Priority B: Stage 5 Phase 2 Step 3 — cardinality restrictions

**Design decision S111-D1 resolved** as option (a): faithful SysML multiplicity mapping.

| SysML multiplicity | OWL restriction |
|---|---|
| `[0..1]` | `maxCardinality 1` (no existential — zero is valid) |
| `[1]` | `exactly 1` (existential + max) |
| `[0..*]` | unconstrained (no restriction needed) |
| `[1..*]` | `minCardinality 1` (existential) |

Option (b) — treating all refs as existential regardless of lower bound — was rejected. It would assert things the [[ontara-service-business-meta-modelling|BMM]] doesn't claim and would put the ontology and SysML in disagreement about what's required, undermining the [[ontara-ref-master-register|authority zone]] ([[ontara-ref-master-register|B29]]) architecture.

**Assessment of 13 object properties:**

Nine functional properties (SysML multiplicity `[1]`) each received an `owl:qualifiedCardinality "1"` restriction on their domain class:

| Domain class | Property | Range class |
|---|---|---|
| ValueProposition | hasTargetSegment | CustomerSegment |
| InventoryRecord | hasCatalogueEntry | CatalogueEntry |
| ActivityCostAllocation | hasAllocatedActivityType | ActivityType |
| ActivityBudget | hasBudgetActivityType | ActivityType |
| ActivityRecord | hasActivityType | ActivityType |
| ResourceInstance | hasResourceType | ResourceType |
| ResourceConstraint | hasAffectedResource | ResourceType |
| RevenueStream | hasPricingModel | PricingModel |
| UnitEconomics | hasOffering | ServiceOffering |

Four non-functional properties (SysML multiplicity `[0..*]`) were correctly left unconstrained: hasLinkedResource, hasRelatedGovernanceRequirement, hasRelatedServiceOffering, hasEnabledServiceOffering.

The axiom file ontology header was updated: `rdfs:comment` and `owl:versionInfo` now reflect Steps 1–3.

---

## 3. Design Decisions

| # | Decision | Resolution | Session |
|---|---|---|---|
| S111-D1 | How SysML multiplicity maps to OWL restrictions | Option (a): faithful to SysML semantics. `[0..1]` → maxCardinality 1; `[1]` → exactly 1; `[0..*]` → unconstrained; `[1..*]` → minCardinality 1. | 114 |

---

## 4. Validation Results

Three validation criteria from the [[session-114-preparation-note|preparation note]] were met:

1. **Consistency check** — [[concept-ontology-stack|HermiT]] reasoner passed clean with all 9 cardinality restrictions loaded. [[concept-ontology-stack|Protégé]] metrics confirmed: 291 axioms, 98 logical axioms, 13 object properties, 9 functional properties, 49 classes, 43 SubClassOf axioms.

2. **Deliberate cardinality violation test** — Three test individuals were added to `ontara-bmm-axioms.ttl`: `TestVP` (a ValueProposition) with `hasTargetSegment` pointing to both `TestSegA` and `TestSegB` (CustomerSegment individuals declared as distinct via `AllDifferent`). HermiT correctly detected the inconsistency — the functional property forces `sameAs` while `AllDifferent` forbids it. The violation was resolved visually in Protégé (red class highlighting, contradictory inferences visible). Protégé crashed during the contradiction state, which is expected behaviour when navigating an inconsistent ontology.

3. **Clean after removal** — Test individuals removed from the Turtle file. Protégé reloaded. HermiT re-run — ontology confirmed consistent with no unsatisfiable classes.

---

## 5. Axiom File Summary

`ontology/axioms/ontara-bmm-axioms.ttl` now contains:

| Category | Count | Detail |
|---|---|---|
| Union classes | 6 | One per BMM concern group |
| AllDisjointClasses | 1 | Six concern groups mutually disjoint |
| Object properties | 13 | 9 functional (`[1]`), 4 non-functional (`[0..*]`) |
| Cardinality restrictions | 9 | `qualifiedCardinality "1"` on each functional property's domain class |

---

## 6. Register Connections

### Tier 1 principles exercised

| Principle | How exercised |
|---|---|
| [[principle-model-generates-everything\|A3]] (Model generates everything) | Cardinality restrictions derived from SysML multiplicity — the model is the source |
| [[principle-discipline-as-load-bearing-structure\|A9]] (Discipline) | Systematic assessment of all 13 properties; deliberate violation test; README currency check at threshold |
| [[principle-intrinsic-self-knowledge\|A10]] (Intrinsic self-knowledge) | The [[concept-knowledge-graph\|knowledge graph]] now knows structural constraints, not just taxonomy |
| [[concept-co-evolution\|J2]] (Co-evolution) | Axioms and validation advancing together |

### Tier 2 concepts exercised

| Concept | How exercised |
|---|---|
| [[concept-ontology-stack\|B23]] (OWL 2 DL) | Full reasoner exercised — [[concept-ontology-stack\|HermiT]] consistency check and violation detection |
| [[ontara-ref-master-register\|B28]] (Three-stratum graph) | Domain graph enriched with structural constraints |
| [[ontara-ref-master-register\|B29]] (Authority zones) | Cardinality restrictions are OWL-authoritative axioms derived from SysML structural intent — faithful mapping respects both authority zones |

---

## 7. Files Changed

**Repo:**
- `README.md` — currency check (6 updates)
- `ontology/axioms/ontara-bmm-axioms.ttl` — 9 cardinality restrictions added, ontology header updated

**Vault:**
- (session report and preparation note placed this session)

---

*Session 114 report written 3 April 2026.*
