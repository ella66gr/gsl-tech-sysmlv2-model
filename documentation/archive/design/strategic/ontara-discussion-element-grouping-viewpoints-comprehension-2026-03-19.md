# Ontara — Discussion: Element Grouping, Viewpoints and Comprehension

**Date:** 19 March 2026 (Session 38)
**Participants:** Ella Green, Claude (Opus 4.6)
**Status:** Discussion document — captures reasoning, not decisions
**Location:** `02 ARCHITECTURE & MODELLING/Discussion Papers/`

---

## 1. Context and Motivation

During Stage 2 planning for the Ontara Console, the question arose: what constitutes a "component" in the Component Catalogue? The initial framing (from the high-level plan) was narrow — should it be a single `part def` or a curated group of related `part def`s? Discussion revealed that the question is much more fundamental than this, touching the relationship between model structure, presentation structure, and human comprehension.

This document captures the discussion and its implications for the Ontara platform architecture.

---

## 2. The Comprehension Principle

Cognitive science research on working memory converges on a capacity of roughly **3–5 meaningful chunks** in the focus of attention (Cowan, 2001; revised from Miller's earlier "7 ± 2" for raw items). A chunk is a meaningful unit — its internal complexity is absorbed by familiarity or structure, so the limiting factor is the number of chunks, not the total information content.

**Design implications (from the research):**

- Aim for 3–5 top-level items in any group a user must hold in mind simultaneously.
- Use progressive decomposition: each group of 3–5 items can itself be decomposed into 3–5 sub-items, and so on. The user navigates levels, never holding more than a handful at any one level.
- Grouping axes should serve the user's current task and perspective, not just the system's internal organisation.
- Gestalt principles (proximity, similarity, common region) support visual grouping that reduces perceived complexity before cognition engages.

**Critical distinction:** The 3–5 chunk principle governs **presentation and interaction**, not model structure. A model subject may be composed of 7, 15, or 50 elements. The principle says: when presenting those elements for human comprehension and manipulation, group them so the user works with a handful at any given moment, with the ability to drill down or aggregate up.

---

## 3. The Lawnmower Example

Ella illustrated the principle with a hand-drawn lawnmower model decomposed into 7 component sections:

1. Wheels/skids
2. Propulsion
3. Roller
4. Blades
5. Handle
6. Frame/body
7. Collection bin

Three views of the same lawnmower show different components highlighted (red: wheels/propulsion/roller; orange: blades/handle; green: frame/collection bin), illustrating how the same model can be presented through different groupings that serve different purposes.

**Key observations from the example:**

- **A prospective customer** might see these as swappable feature modules on a configurator website — "choose your propulsion type (combustion / electric battery / mains electric)." Their grouping is driven by purchase decisions.
- **A design engineer** might use the same modular view to think about product line modularisation (seeing through the customer's eyes), but will also need to decompose each module further for detailed design, and may need cross-cutting views ("which modules share a mounting interface?", "which components are affected by switching power source?").
- **We cannot predict all legitimate decompositions and groupings.** Some are anticipatable (the customer view, the engineer's structural view, a compliance view), but others will emerge from use.

---

## 4. Terminology Agreement

**"Element"** is the agreed generic term for any discrete thing in the system — a `part def`, a `part` usage, a requirement, a metadata annotation, a pattern, or any other identifiable construct. This avoids overloading "component" (which has specific meaning in the Component Catalogue context and in UI frameworks).

---

## 5. Grouping Structure: Model vs Presentation

### 5.1 The SysML package hierarchy is one grouping, not the only one

The SysML model organises elements into packages. This is a single hierarchy driven by engineering concerns — namespace management, dependency control, logical architecture. An element lives in exactly one package.

But legitimate groupings cut across the package hierarchy. Examples:

- **By BMM concern:** "Everything involved in pricing" spans PricingModel, RevenueStream, CostDriver, UnitEconomics — drawn from the FinancialPlanning package, but a user might also want to see how pricing connects to ServiceOffering (in ServiceConcept) and to CostAllocation (in ActivityModel).
- **By task:** "Everything I need to set up a subscription service" cuts across service concept, activity model, financial model, and possibly governance.
- **By role:** A compliance officer's view groups governance requirements, satisfy chains, and audit evidence — drawn from multiple packages and multiple meta model layers.
- **By domain comparison:** "How does pricing work in CSW vs Suds vs Paws?" groups the same meta model element's instantiations across domains.

### 5.2 Two kinds of grouping

The discussion identified a useful analytical distinction:

- **Ontological groupings** reflect what things *are* — the BMM concern structure, the General/Tailored classification, the package hierarchy. These are properties of the model itself.
- **Perspectival groupings** reflect how a particular viewer *needs to see* things — role-oriented views, task-oriented selections, comprehension-oriented clusters. These are properties of the relationship between the model and its user.

However, this distinction is **not a clean separation into "model" vs "presentation."** Some perspectival groupings are stable and anticipatable enough to be architectural knowledge — a compliance officer's view of the system is not an ad hoc preference; it's a legitimate, recurring viewpoint that the platform should know about and support. Others are genuinely ad hoc — "the four elements I'm working on this afternoon."

### 5.3 The data/metadata relativity principle

What constitutes "data" and what constitutes "metadata" is arbitrary relative to purpose and perspective. A tag that is metadata from the model engineer's perspective may be primary data from the catalogue browser's perspective. A grouping that is a presentation convenience from the architect's perspective may be a fundamental organising principle from the end user's perspective.

This means the system should not enforce a rigid hierarchy where some constructs are "real model content" and others are "merely presentation metadata." Groupings, viewpoints, and classifications are first-class elements with the same standing as structural model content — they just serve different purposes.

---

## 6. Implications for Ontara Architecture

### 6.1 The model must be able to express viewpoints

Anticipated, stable perspectival groupings belong in the SysML model, consistent with A3 (model generates everything). If the platform knows that a compliance officer needs a particular view of the system, that knowledge should be modelled, not buried in console UI code.

SysML v2 provides `viewpoint def` and `view def` constructs that are designed for this purpose. Their adequacy for Ontara's needs has not yet been assessed — this is an investigation item.

### 6.2 The console must support dynamic grouping beyond what the model anticipates

Not all legitimate viewpoints can be anticipated. The console needs a grouping/filtering mechanism that goes beyond rendering pre-modelled viewpoints. This includes:

- Dynamic "group by" controls (group by BMM concern, by domain, by General/Tailored, by tag dimension, by package).
- User-defined collections ("save this group of elements as a named set for later").
- Progressive decomposition at every level — the user should always be able to drill into a group and see its contents grouped into a further handful of sub-groups.

### 6.3 The boundary between modelled and dynamic groupings is an empirical question

We do not yet know which groupings will prove stable enough to model in SysML and which should remain dynamic in the console. The right approach is:

1. Build the Component Catalogue with dynamic grouping capability in the console, informed by metadata already in the model.
2. Use the experience of building and using the catalogue to learn which groupings are needed.
3. Investigate SysML v2 viewpoint/view constructs for expressiveness and Syside support.
4. Defer the decision on where the boundary sits until we have empirical evidence.

This directly applies J3 (non-constraining architecture) — we must not lock in a mechanism that forecloses future options.

### 6.4 The comprehension principle applies recursively

Whatever grouping mechanism we adopt, it must support presentation of 3–5 chunks at every level, with progressive decomposition. This is not just a UI design guideline — it is a structural requirement of the grouping mechanism itself. A viewpoint that presents 30 ungrouped elements to the user has failed, regardless of how well-modelled it is.

### 6.5 Convention over configuration — not yet

The DHH / Rails philosophy of "convention over configuration" (extract the framework from the application you are actually building) applies to Ontara, but we are not yet at the stage where we can confidently extract conventions. The lawnmower example shows that legitimate uses of the modelling system are more varied than we can currently predict. Locking in conventions prematurely risks constraining future development (violating J3). The current priority is to build flexible mechanisms and learn from using them.

---

## 7. Relationship to Existing Concepts

| Register entry | Connection |
|---|---|
| A3 (model generates everything) | Anticipated viewpoints belong in the model. Dynamic/ad hoc groupings are a console-layer extension, not a contradiction of A3. |
| B11 (General/Tailored) | One grouping axis among many. Important but not privileged above other axes. |
| I6 (filtered views) | Filtering narrows; grouping restructures. Both needed. The Component Catalogue needs "group by" as well as "filter by." |
| I7 (Component Catalogue) | The catalogue's presentation layer must support multi-level, multi-axis grouping with progressive decomposition. The atomic unit is an element (typically a `part def`); groupings are the comprehension layer over those elements. |
| I10 (tagging system) | Tags are one mechanism for enabling dynamic grouping. But tagging alone is not sufficient — groupings may also be defined by structural relationships, by viewpoint definitions, or by user curation. |
| I12 (console as architect's tool) | The architect (Ella) is the first user. The grouping mechanism must serve her cognitive style: top-down delimitation, working with a handful of elements at a time, progressive decomposition. |
| I14 (comprehension layer) | This discussion deepens the comprehension layer concept. Comprehension is not just friendly names and descriptions — it is fundamentally about presenting the right elements, in the right groupings, at the right level of detail, for the user's current purpose. |
| J3 (non-constraining) | The grouping mechanism must not foreclose future viewpoint definitions or grouping axes. Flexibility over premature convention. |
| J10 (retrospective bootstrapping) | Build the tool, use it, learn what groupings are actually needed, then formalise. |
| J11 (bottom-up meets top-down) | Bottom-up: discover useful groupings through use. Top-down: capture them in the model when they prove stable. |

---

## 8. Open Questions

1. **SysML v2 viewpoint/view support:** How expressive are `viewpoint def` and `view def`? Does Syside support them? Can they express arbitrary element selections with hierarchical grouping? This is an investigation item for the model infrastructure track.
2. **Grouping persistence:** Where do user-defined groupings live — in the console's local storage, in a separate data store, or (for stable ones) promoted into the SysML model? This connects to the broader question of what the console's own data model looks like.
3. **Grouping as element:** If a curated grouping is first-class, does it have its own identity, metadata, version history? Can one grouping reference another? This starts to look like a model-of-groupings, which needs careful thought to avoid recursive complexity.
4. **Cross-domain grouping:** Can a grouping span domains (e.g., "how pricing works in CSW, Suds, and Paws")? This is essential for cross-domain comparison (J1) but may require groupings that reference elements from different model files.
5. **Component granularity (O19):** This question is now reframed. The atomic unit in the catalogue is an element. Groupings provide the "component" experience — a coherent set of elements presented as a unit. O19 is answered not by defining a fixed granularity but by providing flexible grouping.

---

## 9. Implications for Stage 2 Planning

This discussion reshapes the Stage 2 plan in several ways:

- **The Component Catalogue view** needs a "group by" control as a core interaction, not just filters. This is more ambitious than the high-level plan's "browsable list with tag-based filtering."
- **The tagging system (I10)** is more central than originally framed — it's a primary mechanism for enabling dynamic grouping, not just a filtering convenience.
- **SysML viewpoint/view investigation** should be added to the model infrastructure track as a research item — understand the mechanism before committing to it.
- **O19 (component granularity)** is resolved in principle: the atomic unit is an element; grouping is a presentation/viewpoint concern, not a model-structure concern.
- **The comprehension layer (I14)** is deepened: comprehension = right elements + right groupings + right level of detail + right names and descriptions, all relative to the user's current purpose.

---

## 10. Decision Status

| Item | Status |
|---|---|
| "Element" as generic term | **Agreed** |
| Atomic unit in catalogue is an element (typically `part def`) | **Agreed** |
| Grouping is a presentation/viewpoint concern, not fixed model granularity | **Agreed** |
| Multi-level, multi-axis grouping governed by 3–5 chunk principle | **Agreed in principle** |
| Anticipated viewpoints belong in the SysML model | **Agreed in principle** — mechanism TBD |
| Console must support dynamic grouping beyond modelled viewpoints | **Agreed in principle** |
| SysML viewpoint/view investigation needed | **Agreed** — scheduled for Stage 2 model infrastructure track |
| Boundary between modelled and dynamic groupings | **Deferred** — empirical, learn from use |
| User-defined groupings on the roadmap | **Agreed** — timing TBD |

---

*Discussion document prepared 19 March 2026. Session 38.*
