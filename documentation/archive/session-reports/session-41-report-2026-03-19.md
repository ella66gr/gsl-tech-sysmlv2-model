# Session 41 Report — Stage 2 Phase 3: Suds Full BMM Coverage

**Date:** 19 March 2026
**Session type:** Planning and implementation
**Duration:** Standard session
**Participants:** Ella Green, Claude (Opus 4.6)

---

## 1. Summary

This session completed Stage 2 Phase 3 — expanding the Suds demonstrator to full BMM coverage comparable to Cafe (formerly CSW). Eleven new `part` usages were added across five BMM `part def` types, bringing Suds from ~39 to 50 elements. A [[suds-domain-design|Suds design note]] was written documenting General/Tailored observations. Additionally, a domain filter was added to the coverage matrix, the coverage matrix control panel was redesigned, and all three demonstrator domain display labels were renamed (CSW → Cafe, simplified Suds and Paws labels).

---

## 2. Context

Sessions 38–40 completed Stage 2 Phases 1, 2, and 4 — the critical path through tag metadata, generator extension, and the Component Catalogue view. Phase 3 (Suds expansion) was the next priority: the largest remaining block of model content work and the primary evidence for whether the BMM vocabulary generalises.

---

## 3. Phase 3 Implementation

### 3.1 Coverage Audit

A systematic audit compared every BMM `part def` against Cafe and Suds instantiation. The audit identified five gaps where Cafe had instances but Suds did not: DifferentiationClaim, CatalogueEntry, ExternalReference, ActivityCostAllocation, and additional UnitEconomics.

### 3.2 Model Changes

Eleven new `part` usages added to `suds.sysml`:

| `part def` | New Suds instances | Notes |
|---|---|---|
| **DifferentiationClaim** | `reliableTurnaround`, `transparentPricing` | Laundry-specific competitive claims |
| **CatalogueEntry** | `standardWashCatalogue`, `delicatesWashCatalogue`, `expressWashCatalogue` | Uses generic BMM CatalogueEntry directly — no domain-typed specialisation (P3-D1). Stronger generalisation test than Cafe's typed CoffeeShop::CatalogueEntry. |
| **ExternalReference** | `coshhGuidance`, `detergentSafetyDataSheet` | Added to SudsGovernance with new import. Strengthens governance story. |
| **ActivityCostAllocation** | `washCycleCostAllocation`, `receiveAndTagCostAllocation` | First domain to exercise this `part def`. Previously O6 uninstantiated. |
| **UnitEconomics** | `delicatesWashEconomics`, `expressWashEconomics` | Expanded from standard-only. Three offerings with meaningfully different economics. |

All additions are `part` usages of existing General BMM vocabulary. No new `part def`s were needed.

### 3.3 Pre-existing Issue Found

The `sudsValueProposition` (from Session 37) uses `promiseStatement` as an attribute name, but the BMM `ValueProposition` defines `description` (not `promiseStatement`) and also expects `evidenceBasis`. The `:>>` redefinition of `promiseStatement` will fail in Syside because no such attribute exists on the `part def`. Flagged for correction.

### 3.4 Generator Re-run

Generator confirmed Suds at 50 elements (up from 39). Coverage matrix shows new green cells for DifferentiationClaim, CatalogueEntry, ExternalReference, and ActivityCostAllocation.

---

## 4. Console Improvements

### 4.1 Coverage Matrix Domain Filter

Added domain column visibility toggles to the coverage matrix. The filter controls are in a dedicated control panel above the table — toggle chips (pill-shaped, filled primary colour when active, outlined when inactive) for each domain. "Show all" link appears when any domains are hidden. Table columns hide/show reactively. Prevents hiding the last remaining domain.

### 4.2 Coverage Matrix Control Panel Redesign

The filter bar was restructured from a flat row of controls into a visually distinct bordered panel containing all controls: Domains (toggle chips), Meta Model Layer (dropdown), Coverage Status (dropdown), Search (text input), and count display.

### 4.3 Domain Label Renaming

All three demonstrator domain display labels were simplified:

| Before | After |
|---|---|
| CSW (Coffee Shop) | Cafe |
| Suds (Laundry) | Suds |
| Paws (Dog Grooming) | Paws |

Changes applied to: generator config (`gen_model_introspection.py`), sidebar navigation (`+layout.svelte`), and all three domain placeholder pages. Internal identifiers (package names, file paths, domain key `"csw"`) unchanged — display layer only.

---

## 5. Documents Produced

- [[ontara-stage-2-plan-phase-3-implementation-2026-03-19|Phase 3 Implementation Plan]] — detailed plan with 7 chunks, design decisions P3-D1 through P3-D7
- [[suds-domain-design|Suds Domain Design Note]] — General/Tailored observations, coverage summary, meta model gap analysis, cross-domain methodology recommendations
- [[ontara-master-register-design-concepts-2026-03-17|Master Register]] updated (O6, O13, O14, changelog)
- This session report
- Next session preparation note

---

## 6. Decisions Made

| Decision | Rationale |
|---|---|
| Use generic BMM CatalogueEntry for Suds, not domain-typed specialisation (P3-D1) | Stronger generalisation test. Suds has no product model. Validates CatalogueEntry works for service catalogues. |
| Place ExternalReference instances in SudsGovernance (P3-D2) | COSHH references are governance-adjacent. Keeps governance story coherent. |
| Add ActivityCostAllocation as new ground (P3-D3) | Suds becomes first domain to exercise this `part def`. Contributes to resolving O6. |
| No new `part def`s (P3-D5) | All additions are instances of General vocabulary. Validates BMM generality. |
| Rename CSW → Cafe in display layer only (Session 41) | "Cafe" sits better alongside "Suds" and "Paws". Internal identifiers unchanged. |
| Domain filter as toggle chips in control panel, not clickable table headers | First iteration (clickable headers) was not discoverable. Dedicated control panel with obviously interactive chips is clearer. |

---

## 7. Master Register Updates

| Entry | Change |
|---|---|
| **O6** | Updated — ActivityCostAllocation now has 2 Suds instances. Three BMM `part def`s remain uninstantiated (down from four). |
| **O13** | Updated — Suds expanded to full BMM coverage (Session 41, ~50 elements). Design note written. |
| **O14** | Updated — Coverage matrix domain filter added. |

**Concepts exercised:** [[concept-cross-domain-validation|J1]] (cross-domain validation), [[concept-co-evolution|J2]] (co-evolution), [[principle-coffeeshop-first|A5]] (validate in toy domains), B11 (General/Tailored — discovered through CatalogueEntry provisionType observations), [[concept-governance-in-toy-domains|J8]] (governance in toy domains — ExternalReference), A8 (governance first-class), [[concept-design-decision-lifecycle|J12]] (design decision lifecycle — domain filter iterated from v1 to v2 based on feedback), I6 (filtered views — domain filter), I12 (console as architect's tool — low-friction for Ella).

---

## 8. Stage 2 Exit Criteria — Status

- [x] `@CatalogueTag` metadata def exists and validates in Syside
- [x] `@UserFacing` metadata def exists and validates in Syside
- [x] BMM `part def`s tagged with "concern" and "classification" dimensions
- [x] At least 10–15 BMM `part def`s have `@UserFacing` metadata (10 currently)
- [x] Generator produces JSON with tag facets, user-facing metadata, facet summaries
- [x] Component Catalogue view working with multi-axis "group by" and element detail
- [x] Catalogue displays friendly names where available, falls back to SysML identifiers
- [x] Suds model has full BMM coverage comparable to Cafe *(Session 41)*
- [x] Suds design note written with General/Tailored observations *(Session 41)*
- [ ] COSHH satisfy traceability chain completed *(Phase 6)*
- [ ] SysML viewpoint/view investigation completed with findings *(Phase 5)*
- [x] Cross-links between catalogue and coverage matrix working
- [ ] Stage 3 detailed plan produced

---

## 9. Next Steps

1. **Phase 5: SysML viewpoint/view investigation** — independent research session. Can run any time.
2. **Phase 6: Suds governance traceability** — complete the COSHH `requirement → constraint → satisfy → audit evidence` chain. The ExternalReference instances added in this session become evidence targets.
3. **Stage 3 detailed plan** — once Phases 5 and 6 are complete, produce the Stage 3 plan.
4. **Pre-existing fix:** Correct `sudsValueProposition` attributes (`promiseStatement` → `description`, add `evidenceBasis`).
5. **Syside validation:** Ella to validate the expanded `suds.sysml` in Syside.

---

*Session report prepared 19 March 2026. Session 41.*
