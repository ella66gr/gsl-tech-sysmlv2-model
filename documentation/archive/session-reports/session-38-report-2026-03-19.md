# Session 38 Report — Element Grouping, Stage 2 Planning and Phase 1

**Date:** 19 March 2026
**Session type:** Discussion, planning, and implementation
**Duration:** Extended session
**Participants:** Ella Green, Claude (Opus 4.6)

---

## 1. Summary

This session began with a foundational discussion on element grouping, viewpoints, and human comprehension that reshaped the Stage 2 plan. Three design questions were resolved. The Stage 2 detailed implementation plan was produced. Phase 1 of Stage 2 (tag and comprehension metadata in SysML) was implemented, encountering and resolving several Syside syntax issues along the way.

---

## 2. Pre-Session Housekeeping

- **Session 37 commit:** All Stage 1 work (console, Suds model, generator, generated JSON — 26 files, +51K lines) committed and pushed to GitHub as `36883f9`.
- **Suds SysML validation:** Confirmed — all SysML parses clean in Syside/VS Code.
- **Suds design note:** Not yet written — remains a deferred item for Phase 3.

---

## 3. Discussion: Element Grouping, Viewpoints and Comprehension

A major discussion on how the Component Catalogue should present elements. Captured in [[ontara-discussion-element-grouping-viewpoints-comprehension-2026-03-19|discussion document]].

**Key outcomes:**

- **Terminology:** "Element" agreed as the generic term for any discrete thing in the system.
- **Comprehension principle:** The 3–5 chunk principle (Cowan, 2001) governs presentation and interaction, not model structure. The catalogue must present elements in comprehensible groups with progressive decomposition.
- **Model vs presentation:** SysML packages provide one grouping axis. Legitimate groupings cut across packages (by concern, by task, by role, by domain). The catalogue needs multi-axis "group by" as a core interaction.
- **Ontological vs perspectival groupings:** Some groupings reflect what things are (package structure, BMM concerns); others reflect how users need to see them. Anticipated perspectival groupings belong in the model (A3); ad hoc ones belong in the console layer. The boundary is empirical — learn from use.
- **Multi-level coherence:** A new principle (loosely defined) — the property of a model and its tooling that allows users to work at any level of abstraction where the view is coherent, self-contained, comprehensible, and connected to levels above and below. Subsumes: aggregation/decomposition, hierarchical dissolution/crystallisation of detail, cross-level relationships, recursive 3–5 chunk application.
- **Not a meta meta model:** The meta model operates at multiple layers of abstraction — these are not different models stacked on each other.
- **Opinionated and open structure:** Some structure is designed by the architect; some is open for users. Both needed.
- **Rigidity vs chaos:** Multi-level coherence occupies the middle ground — structured enough to be navigable, flexible enough to evolve.
- **Lawnmower example:** Ella's hand-drawn lawnmower model (7 components, 3 grouped views) crystallised the grouping/viewpoint requirement.

---

## 4. Three Design Questions Resolved

### Question 1: Component granularity (O19)

**Resolved.** The atomic unit in the catalogue is an element (typically a `part def`). Grouping is a presentation/viewpoint concern, not fixed model granularity. O19 is answered by providing flexible, multi-axis grouping rather than defining a fixed component size.

### Question 2: Tag metadata mechanism (O17)

**Resolved.** A single `@CatalogueTag` metadata def with named attributes per dimension (`bmmConcern`, `classification`). New dimensions added as new attributes. General/Tailored treated as an ordinary tag dimension with no privileged status. Originally proposed as a general-purpose `@Tag` with string dimension/value pairs, but Syside's one-annotation-per-metaclass constraint made this unworkable — multiple `@Tag` annotations on one element fail.

### Question 3: Coverage matrix not-applicable vs not-yet-modelled

**Deferred.** Coverage matrix remains binary for Stage 2. Console-layer annotation for N/A if needed. The lifecycle pattern applies: many freedoms will become opinionated configuration when the system goes into use.

---

## 5. Design Decision Lifecycle (J12)

A new methodology concept identified and added to the master register:

**freedom → experimentation → discovered convention → opinionated configuration → (revisable)**

This is the pragmatic expression of J3 (non-constraining architecture) across time. Non-constraining at the beginning does not mean uncommitted forever; committed does not mean irreversible.

---

## 6. Stage 2 Detailed Plan

Produced [[ontara-stage-2-plan-2026-03-19|Stage 2 detailed implementation plan]] with six phases:

1. Tag metadata in SysML ← **completed this session**
2. Generator extension — catalogue JSON
3. Suds full BMM coverage
4. Component Catalogue view (core)
5. SysML viewpoint/view investigation
6. Suds governance traceability

Critical path: Phase 1 → Phase 2 → Phase 4. Estimated 8–11 sessions total.

---

## 7. Phase 1 Implementation

### What was built

- **`@CatalogueTag` metadata def** in `Foundation::MetadataLibrary` — attributes: `bmmConcern` (String), `classification` (String).
- **`@UserFacing` metadata def** in `Foundation::MetadataLibrary` — attributes: `friendlyName` (String), `shortDescription` (String).
- **`@CatalogueTag` applied** to all 24 BMM `part def`s in `business-model.sysml` — 7 ServiceConcept, 5 ActivityModel, 7 ResourceCapability, 5 FinancialModel. All classified as "General".
- **`@UserFacing` applied** to 11 key BMM `part def`s: CustomerSegment, ValueProposition, ServiceOffering, ActivityType, ResourceType, Capability, RevenueStream, CostDriver, UnitEconomics, PricingModel, plus one additional.
- **`private import Foundation::MetadataLibrary::*;`** added to `BusinessModel` package.

### Syntax findings (recorded in syntax reference v3.14)

| Finding | Detail |
|---|---|
| **One annotation per metaclass per element** | Stacking two `@Tag` annotations on the same `part def` fails: "Metadata feature must be typed by exactly one metaclass." Solution: use a single metadata def with multiple attributes. |
| **`concern` triggers parsing error** | Despite not being in the KerML reserved words list, `attribute concern : String;` fails in Syside with "Unexpected 'concern'". Use `bmmConcern` instead. |
| **Metadata import required** | `@CatalogueTag` in `business-model.sysml` was not resolved until `private import Foundation::MetadataLibrary::*;` was added to the `BusinessModel` package. The original "must be typed by exactly one metaclass" error was a cascade from the unresolved reference. |
| **Position A (prefix) works** | Metadata annotations placed before (prefix to) a `part def` parse correctly when the import is present. This is now the adopted convention. |
| **Position B (inside body) also works** | Annotations inside the `part def` body work too (as per the existing `@OpenEhrArchetype` pattern in CSW archetypes). Position A adopted for new work; the CSW precedent was exploratory and is not binding. |

### Commits

- `d4183e0` — Session 37 Stage 1 work (committed at start of session, prior to Session 38 work)
- `c1ea305` — Session 38 Stage 2 Phase 1: `@CatalogueTag`, `@UserFacing`, syntax reference v3.14

---

## 8. Decisions Made

| Decision | Rationale |
|---|---|
| "Element" as generic term | Avoids overloading "component" |
| Multi-axis "group by" as core catalogue interaction | Comprehension principle; multi-level coherence |
| `@CatalogueTag` with named dimension attributes | Syside one-per-metaclass constraint; single annotation per element |
| General/Tailored as ordinary tag, no privileged status | Uniform tagging; may evolve |
| Coverage matrix stays binary (Stage 2) | Premature to distinguish N/A vs not-yet-modelled |
| Position A (prefix) for metadata annotations | More visible, avoids inheritance question, keeps metadata separate from structural content |
| Carry Position A forward; don't retrofit `@OpenEhrArchetype` | CSW pattern was exploratory; consistency for new work |
| `bmmConcern` not `concern` | Syside parser conflict |

---

## 9. Master Register Updates

| Entry | Change |
|---|---|
| **J12 (new)** | Design decision lifecycle: freedom → experimentation → discovered convention → opinionated configuration → (revisable) |
| **O17** | Partially addressed — `@CatalogueTag` metadata def defined and applied. Tagging system now exists in SysML. Full catalogue view and dynamic grouping remain Stage 2 Phase 4. |
| **O19** | Resolved in principle — atomic unit is an element; grouping is a presentation concern. |
| **O20** | Partially addressed — `@UserFacing` metadata def defined and applied to 11 BMM `part def`s. Console rendering and glossary remain future phases. |

---

## 10. Documents Produced

- [[ontara-discussion-element-grouping-viewpoints-comprehension-2026-03-19|Element Grouping, Viewpoints and Comprehension]] — discussion document in `Discussion Papers/`
- [[ontara-stage-2-plan-2026-03-19|Stage 2 Detailed Implementation Plan]] — in `Ontara/Plans/`
- This session report

---

## 11. Next Steps

1. **Phase 2: Generator extension** — extend `gen_model_introspection.py` to extract `@CatalogueTag` and `@UserFacing` metadata and produce catalogue-ready JSON with facet summaries.
2. **Phase 3: Suds full BMM coverage** — expand Suds model, write design note. Can run in parallel with Phase 2.
3. **Phase 4: Component Catalogue view** — build the `/catalogue` page with multi-axis grouping. Depends on Phase 2.
4. **Phase 5: SysML viewpoint/view investigation** — independent research, can run any time.
5. **Phase 6: Suds governance traceability** — strengthen COSHH satisfy chain.
6. **Update the Stage 2 plan** to reflect `@CatalogueTag` (not `@Tag`) and `bmmConcern` (not `concern`), and add the import requirement as a standing note.

---

*Session report prepared 19 March 2026. Session 38.*
