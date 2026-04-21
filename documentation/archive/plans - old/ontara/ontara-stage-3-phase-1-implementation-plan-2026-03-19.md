# Ontara — Stage 3 Phase 1: Paws Domain Model — Detailed Implementation Plan

**Date:** 19 March 2026 (Session 44)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** For agreement before implementation
**Parent plan:** Stage 3 Detailed Plan (Session 43)
**Prerequisite:** Stage 2 complete (13/13 exit criteria met)

---

## 1. Objective

Create the Paws (dog grooming) demonstrator domain model — the third domain for cross-domain validation (J1). Paws is an appointment-based personal service business, deliberately different from Cafe (immediate retail) and Suds (batch processing). The domain exercises all five BMM concerns using the existing General vocabulary without introducing new Tailored part defs.

---

## 2. Design Decisions (agreed in Session 44 discussion)

| # | Question | Decision | Rationale |
|---|---|---|---|
| P1-D1 | Does BMM accommodate appointment-based services? | Yes, without strain | `ServiceOffering` with `estimatedDurationWeeks = 0` and `pricingBasis` as string handle appointment services. Scheduling is an operational concern, not a meta model gap. |
| P1-D2 | Client/pet relationship | Note as cross-domain observation; do not force new part def | The paying customer is the `CustomerSegment`. The animal is the service subject — analogous to a patient in GSL. Observation captured in design note for future meta model discussion. Separate discussion planned. |
| P1-D3 | Governance posture | General professional governance, not specific regulatory | No equivalent of COSHH. Animal Welfare Act 2006 duty of care, public liability insurance, H&S. Exercises `GovernanceRequirement` and `AuditEvidenceRecord` but without `constraint def` / `satisfy` chain (obligations are general, not expressible as Boolean predicates). |
| P1-D4 | New Tailored part defs? | No | Validation goal: existing General vocabulary handles three structurally different service businesses. |

---

## 3. Scope — What Gets Built

### 3.1 SysML Model File

**File:** `exercises/paws-demonstrator/model/paws.sysml`

**Package structure** (following Suds pattern — two main packages plus governance):

| Package | Imports | Coverage |
|---|---|---|
| `PawsBusinessModel` | `ServiceConcept::*`, `ActivityModel::*` | Service concept + activity model |
| `PawsResourceFinancial` | `ResourcePlanning::*`, `FinancialPlanning::*` | Resources + financial model |
| `PawsGovernance` | `GovernanceMapping::*`, `ServiceConcept::ExternalReference` | Governance requirements + audit evidence |

### 3.2 BMM Coverage — Planned Element Usages

**ServiceConcept** (PawsBusinessModel):

| Part def | Planned usages | Notes |
|---|---|---|
| `ValueProposition` | 1 | Quality care for pets with transparent pricing |
| `ServiceOffering` | 3 | Full groom, wash & tidy, nail trim / add-on services |
| `CustomerSegment` | 2 | Walk-in / booking (individual pet owners), regular / subscription (multi-pet, repeat) |
| `Channel` | 2 | Shop/walk-in, online booking |
| `DifferentiationClaim` | 2 | Breed-specific expertise, gentle handling / low-stress environment |
| `CatalogueEntry` | 3 | One per service offering |
| `ExternalReference` | 1–2 | Animal Welfare Act reference, breed grooming standards |

**ActivityModel** (PawsBusinessModel):

| Part def | Planned usages | Notes |
|---|---|---|
| `ActivityType` | 7–8 | Check-in & assess, groom/wash/dry/style, nail trim, quality check, return to owner + enabling (equipment maintenance) + governance (welfare check) + overhead (booking management) |
| `ActivityGranularity` | 5 | One per activity category (service delivery = tracked, others at appropriate levels) |
| `ActivityCostAllocation` | 2 | Grooming labour, consumables |

**ResourcePlanning** (PawsResourceFinancial):

| Part def | Planned usages | Notes |
|---|---|---|
| `ResourceType` | 5–6 | Groomer, grooming equipment (tables, dryers, clippers), shop premises, grooming consumables (shampoo, products), booking system, PPE/first aid |
| `Capability` | 1 | Deliver a grooming appointment |
| `CapacityModel` | 1 | Standard day capacity |
| `ResourceConstraint` | 1 | Animal welfare duty of care |

**FinancialPlanning** (PawsResourceFinancial):

| Part def | Planned usages | Notes |
|---|---|---|
| `RevenueStream` | 1 | Grooming service revenue |
| `CostDriver` | 3–4 | Labour, consumables, rent, equipment maintenance |
| `UnitEconomics` | 3 | One per service offering |
| `PricingModel` | 1 | Per-appointment with breed/size surcharges |

**GovernanceMapping** (PawsGovernance):

| Part def | Planned usages | Notes |
|---|---|---|
| `GovernanceRequirement` | 1 | Animal welfare duty of care (general, not specific regulation) |
| `AuditEvidenceRecord` | 3 | Public liability insurance cert, incident log, first aid kit inspection |
| `ExternalReference` | 1 | Animal Welfare Act 2006 reference |

**Total estimated elements:** ~50–55 (comparable to Suds at ~50).

### 3.3 Elements NOT Exercised

| Part def | Status | Notes |
|---|---|---|
| `ActivityBudget` | Remains uninstantiated (O6) | Would need a planning scenario; not natural for a toy domain. Could be addressed later if needed. |
| `ActivityRecord` | Remains uninstantiated (O6) | Runtime concept — instances would be generated by the system, not modelled statically. |
| `InventoryRecord` | Remains uninstantiated | Grooming consumables stock tracking — possible but low priority. |
| `FinancialProjection` | Not included | Would need a scenario. Paws is simpler than GSL; projection adds complexity without validating new vocabulary. |
| `ResourceInstance` | Not included | Planning-level capacity instances. Could add if time allows. |
| `ObjectiveCapabilityMapping` | Not included | Requires strategic objectives. Out of scope for a toy domain demonstrator. |

### 3.4 Design Note

**File:** Obsidian `Demonstrators/Paws (Dog Grooming)/paws-design-note-2026-03-19.md`

Content:
- Domain description and structural characteristics
- General/Tailored classification for each element (expect all General)
- Comparison with Cafe and Suds — what Paws exercises differently
- Service subject observation: customer ≠ service recipient (pet), analogy to GSL patient
- Governance posture: general professional vs specific regulatory
- BMM vocabulary adequacy assessment — any strain points?

### 3.5 Generator Re-run

After model is written and validated in Syside, re-run the introspection generator to produce updated JSON with three-domain coverage matrix. This will update the Ontara Console's coverage matrix and Component Catalogue.

---

## 4. Implementation Steps

### Step 1: Create directory structure (Claude Chat)

Create `exercises/paws-demonstrator/model/` directory.

### Step 2: Write `paws.sysml` (Claude Chat)

Write the full model file in a single pass, following the established patterns from Suds. Three packages: `PawsBusinessModel`, `PawsResourceFinancial`, `PawsGovernance`.

**Conventions to follow:**
- Position A (prefix) for `@CatalogueTag` — wait, this applies only to `part def` declarations in the BMM, not to part usages in exercises. Part usages in exercises do not carry `@CatalogueTag`. Confirmed by checking Suds: no `@CatalogueTag` on usages.
- Doc blocks on all elements explaining the domain reasoning
- File header block with session reference, date, structural differences from Cafe/Suds
- Standard imports: `private import ScalarValues::*;` and domain-appropriate BMM sub-packages
- No `@CatalogueTag` or `@UserFacing` on exercise usages (these go on `part def`s in the BMM, not on instances)

**Reserved word check:** Review all planned identifier names against §10 of the syntax reference. Key risks for a dog grooming domain:
- `type` — reserved. Use `groomType` or `serviceType`
- `standard` — reserved. Use `standardGroom` or similar compound name
- `action` — reserved. Avoid as attribute name
- `breed` — safe (not reserved)
- `size` — safe (confirmed in CSW as `DrinkSize`)
- `appointment` — safe (not reserved)
- `duration` — safe (not reserved)

### Step 3: Ella validates in Syside

Ella opens the file in Syside and checks for parse errors, reference resolution, and cross-project import resolution.

### Step 4: Write design note (Claude Chat)

Produce the Paws design note as a container artifact. Ella downloads to Obsidian.

### Step 5: Generator re-run (Claude Code)

**Instructions for Claude Code:**

```
cd ~/Developer/gsl-tech/gsl-sysml-model
python scripts/gen_model_introspection.py
```

Verify the output JSON includes Paws domain data alongside Cafe and Suds. Check that:
- Coverage matrix shows three domains
- New Paws elements appear in the element listing
- No errors in generator output

### Step 6: Verify console (Ella)

Open the Ontara Console and check:
- Coverage matrix shows Cafe/Suds/Paws columns
- Component Catalogue shows Paws instantiation counts
- No rendering errors

---

## 5. Session Allocation

| Session | Work | Deliverables |
|---|---|---|
| Session 44 (this session) | Steps 1–2: create directory, write `paws.sysml` | Model file ready for Syside validation |
| Session 44 or 45 | Step 4: write design note | Design note artifact |
| Session 45 | Steps 3, 5, 6: Syside validation, generator re-run, console verification | Three-domain coverage operational |

---

## 6. Register Concepts Exercised

| Concept | How |
|---|---|
| J1 (cross-domain validation) | Third domain — threshold for confident generalisation |
| A5 (validate in toy domains) | Appointment-based service, structurally different from Cafe/Suds |
| C1–C6 (five concerns) | Full BMM coverage across all packages |
| B11 (General/Tailored) | All elements expected to be General — validates vocabulary breadth |
| J8 (governance in toy domains) | General professional governance with audit evidence |
| N1 (doc block labels) | All doc blocks identify meta model affiliation |
| D9 (metadata-driven generation) | Generator re-run produces three-domain data |
| J2 (co-evolution) | Console reflects new domain immediately via generator |

---

## 7. Exit Criteria

Phase 1 is complete when:

- [ ] `exercises/paws-demonstrator/model/paws.sysml` exists and parses clean in Syside
- [ ] Three packages: PawsBusinessModel, PawsResourceFinancial, PawsGovernance
- [ ] ~50 element usages covering all five BMM concerns
- [ ] Design note written with General/Tailored classification and cross-domain observations
- [ ] Generator re-run produces JSON with three-domain coverage
- [ ] Console coverage matrix shows Cafe/Suds/Paws
- [ ] Master register updated (O13, and any new observations)
- [ ] Service subject observation captured for future discussion

---

## 8. Claude Code / Cowork Task Summary

| Task | Tool | Notes |
|---|---|---|
| Directory creation | Claude Chat (MCP) | Simple filesystem operation |
| Model writing | Claude Chat | Design judgement required; follows established patterns |
| Design note | Claude Chat | Container artifact |
| Generator re-run | Claude Code | Mechanical: run existing script, verify output |
| Console verification | Ella | Requires browser |
| `@CatalogueTag` bulk application | N/A | Not needed — tags go on part defs (BMM), not usages (exercises) |

---

*Plan prepared 19 March 2026 (Session 44). For agreement before implementation.*
