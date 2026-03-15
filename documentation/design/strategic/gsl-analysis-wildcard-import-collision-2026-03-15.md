# Wildcard Import Name Collision — Analysis and Architectural Recommendations

**Date:** 15 March 2026 (Session 30)
**Context:** CatalogueEntry name collision discovered and fixed during Concept Graph workstream Stage 2. This document analyses the broader risk and proposes a robust import convention.

---

## 1. The Problem

When two wildcard imports (`private import A::*;` and `private import B::*;`) both export a type with the same name, Syside resolves the ambiguity silently. There is no warning or error at the import site. The consuming file uses whichever definition Syside happens to pick. If the two definitions have different attribute types (e.g. one has `provisionType : ProvisionType` and the other has `provisionType : String`), the error surfaces downstream as a type-mismatch on `:>>` redefinition — not at the point of ambiguity.

This is a **silent failure mode** that produces errors distant from the root cause, making diagnosis difficult.

### Why this matters architecturally

The project's meta model design *deliberately* gives domain types and meta model types the same names. `CatalogueEntry` is a business meta model concept in `BusinessModel::ServiceConcept` and a domain-specific type in `CoffeeShop`. This is correct design — the domain type is the concrete instantiation of the abstract meta model concept. But it means **every meta model concept that shares a name with a domain type is a collision risk** in any file that imports both.

As the project adds more domains and more meta model concepts, the collision surface grows. An addictions service would likely have its own `CatalogueEntry`, `InventoryRecord`, `ExternalReference` — all sharing names with the meta model.

---

## 2. Current Collision Map

### Active collision (fixed)

| Type name | Package A | Package B | Collides in file | Status |
|---|---|---|---|---|
| `CatalogueEntry` | `CoffeeShop` | `BusinessModel::ServiceConcept` | `coffeeshop-business-model.sysml` | **Fixed** — qualified as `CoffeeShop::CatalogueEntry` |

### Latent collisions (not yet triggered)

These names exist in both imported namespaces of `coffeeshop-business-model.sysml` but are not currently used as types in that file. They would produce silent errors if someone added a `part x : ExternalReference` or `part x : InventoryRecord` usage.

| Type name | Package A | Package B | Collides in file | Status |
|---|---|---|---|---|
| `ExternalReference` | `CoffeeShop` | `BusinessModel::ServiceConcept` | `coffeeshop-business-model.sysml` | **Latent** — no usages of this type in file |
| `InventoryRecord` | `CoffeeShop` | `BusinessModel::ResourcePlanning` | `coffeeshop-business-model.sysml` | **Latent** — no usages; note: `ResourcePlanning::*` is not directly imported but could be via future change |

### No current collision

| File | Imports | Collision risk |
|---|---|---|
| `coffeeshop-archetypes.sysml` | `Foundation::MetadataLibrary::*` only | **None** — single external import |
| `coffeeshop-resource-financial.sysml` | `BusinessModel::ResourcePlanning::*`, `BusinessModel::FinancialPlanning::*` | **None** — no CoffeeShop import, no name overlap between ResourcePlanning and FinancialPlanning |
| `coffeeshop-scenarios.sysml` | `BusinessScenarios::*`, `BusinessStrategy::*`, `BusinessModel::ResourcePlanning::ObjectiveCapabilityMapping`, `Knowledge::LogicEngine::*`, `Foundation::CommonTypes::*` | **Low** — no CoffeeShop import; types are distinct across these packages |
| `gendersense.sysml` (root) | All packages via `*` | **Theoretical** — root assembly imports everything but declares no usages, so collisions cannot manifest |

### Future collision risk (predictable)

When GSL clinical development begins, a `GenderSense` domain package will likely define:
- `CatalogueEntry` (FormularyEntry — or named differently, mitigating the risk)
- `ExternalReference` (SPC/BNF links)
- `InventoryRecord` (clinical stock)
- `Order` / `ClinicalPlan` (potentially sharing names)

Any file that imports both `GenderSense::*` and `BusinessModel::ServiceConcept::*` will face the same collision pattern.

---

## 3. Architectural Options

### Option A: Status quo + qualification (current approach)

When a collision occurs, qualify the ambiguous type: `CoffeeShop::CatalogueEntry` instead of bare `CatalogueEntry`.

**Pros:** Minimal change. Works. No import restructuring.
**Cons:** Relies on discovering collisions after they occur. The silent failure mode means they may go undetected. New developers (or a future Claude instance) may not know to qualify. Does not prevent the problem — only fixes it after it appears.

### Option B: Replace domain wildcard imports with explicit sub-package imports

Instead of `private import CoffeeShop::*;`, import only the specific sub-namespaces needed:

```sysml
private import CoffeeShop::MenuItem;
private import CoffeeShop::Drink;
private import CoffeeShop::FoodItem;
// etc. — but NOT CatalogueEntry, ExternalReference, InventoryRecord
```

**Pros:** Eliminates collision at source. Makes import intent explicit.
**Cons:** Specific named cross-project imports were found not to work in Session 29 (`private import Foundation::CommonTypes::PersistencePolicy;` failed). However, `private import BusinessModel::ServiceConcept::ServiceOffering;` works in `business-scenarios.sysml` (Session 19). **The Session 29 finding may be specific to deeply nested or recently-added types, or to Foundation specifically.** This needs verification before relying on it.

### Option C: Domain types never share meta model names

Adopt a naming convention where domain-specific types always use domain-prefixed names: `CswCatalogueEntry`, `GslFormularyEntry`. The meta model retains the generic `CatalogueEntry`.

**Pros:** Eliminates collision risk entirely. Names are unambiguous everywhere.
**Cons:** Breaks the current naming pattern (domain types deliberately mirror meta model names for clarity). Adds cognitive overhead — you have to remember `CswCatalogueEntry` is the coffee shop instantiation of `CatalogueEntry`. Ugly.

### Option D: Separate domain and meta model imports — never import both via wildcards into the same file

Adopt a **convention**: if a file imports a domain package via wildcard (`CoffeeShop::*`), it must not also import meta model packages that export overlapping names via wildcard. Instead, it uses only the domain types and accesses meta model types via explicit qualification (`BusinessModel::ServiceConcept::CatalogueEntry`).

**Pros:** Clear rule that prevents collisions. No naming changes. No reliance on specific named imports working.
**Cons:** Requires discipline and documentation. Could be forgotten.

### Option E: Structural separation — domain business models don't import both meta model and domain packages via wildcard

Restructure the coffee shop business model file so that it does not need both import namespaces. For example:
- Meta model usages (CustomerSegment, ServiceOffering, Channel, ActivityType) come from `BusinessModel::*` imports.
- Domain model usages (CatalogueEntry instances) could move to a separate file that only imports `CoffeeShop::*`.

**Pros:** Each file has a single, clear import context. No ambiguity possible.
**Cons:** File proliferation. The coffee shop business model is currently a single coherent file — splitting it by import context fragments a logical unit.

---

## 4. Recommendation

**Adopt Option D as the standing convention, with Option A as the fallback.**

The rule: **When a file imports a domain package (e.g. `CoffeeShop::*`), any meta model types that share names with domain types must be accessed via explicit qualification (`BusinessModel::ServiceConcept::CatalogueEntry`), never via bare name from a wildcard import.**

In practice this means:

1. **Domain-model files** (e.g. `coffeeshop.sysml`) have no collision risk — they only import their own types.

2. **Domain business model files** (e.g. `coffeeshop-business-model.sysml`) import both meta model packages and domain packages. These are the collision-prone files. The convention: always use the domain-qualified type for usages that need the domain-specific definition (e.g. `CoffeeShop::CatalogueEntry` for catalogue entries with enum-typed attributes).

3. **Meta model files** (e.g. `business-model.sysml`, `foundation.sysml`) have no collision risk — they only define types, not domain-specific usages.

4. **New domain additions** (GSL clinical, addictions) follow the same pattern: their business model extension files qualify domain types when meta model names overlap.

### Documentation

Add to `gsl-guide-repo-conventions.md`:

> **Import collision convention:** When a `.sysml` file imports both a domain package (e.g. `CoffeeShop::*`) and a meta model package (e.g. `BusinessModel::ServiceConcept::*`) via wildcards, and both export types with the same name, always use the fully qualified domain type for usages (e.g. `CoffeeShop::CatalogueEntry`, not bare `CatalogueEntry`). This prevents silent type-mismatch errors caused by Syside's ambiguous name resolution.
>
> Known shared names: `CatalogueEntry`, `ExternalReference`, `InventoryRecord`. This list will grow as meta model concepts are added.

### Immediate actions

1. ✅ **CatalogueEntry** — already fixed with `CoffeeShop::CatalogueEntry` qualification.
2. **Add a comment to `coffeeshop-business-model.sysml`** listing the known collision-prone names — already done in the import note.
3. **Document the convention** in the repo conventions guide (Stage 4 of the concept graph workstream).
4. **Syntax reference update** — add the wildcard import collision finding.

---

## 5. Specific Named Import Investigation

The Session 29 finding that `private import Foundation::CommonTypes::PersistencePolicy;` fails contradicts the Session 19 finding that `private import BusinessModel::ServiceConcept::ServiceOffering;` works. Both are cross-project specific named imports.

Possible explanations:
- The failure is specific to recently-added types (PersistencePolicy was just added in Session 29; ServiceOffering has existed since Session 14).
- The failure is specific to Foundation (which has nested sub-packages deeper than BusinessModel).
- The failure was transient (Syside caching or workspace indexing issue).

**Recommendation:** Do not rely on specific named imports as the primary collision mitigation strategy until this inconsistency is understood. The qualification approach (Option D) works regardless and is verified.

If a future session wants to investigate, test:
- `private import Foundation::CommonTypes::PersistencePolicy;` (failed Session 29 — re-test)
- `private import CoffeeShop::CatalogueEntry;` (untested)
- `private import BusinessModel::ServiceConcept::CatalogueEntry;` (untested)

---

## 6. Future-Proofing Checklist

When adding a new meta model `part def` or `enum def`:

1. **Check the name against all domain packages.** Does the same name exist in `CoffeeShop`, or will it exist in `GenderSense` or `Addictions`?
2. **If yes:** add the name to the "known collision-prone names" list in the repo conventions and in the import note of any domain business model file that imports both namespaces.
3. **If a domain business model file uses the type:** qualify it with the domain prefix.

When creating a new domain:

1. **Check domain type names against meta model names.** Document any overlaps.
2. **In the domain's business model extension file:** use qualified types for any overlapping names from the first commit.

---

*Analysis prepared 15 March 2026 (Session 30). Triggered by CatalogueEntry name collision discovered during Concept Graph workstream execution.*
