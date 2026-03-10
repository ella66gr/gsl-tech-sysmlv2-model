# Plan: Coffee Shop Demonstrator Integration into Project Development

**Project:** GenderSense (GSL)
**Date:** 10 March 2026 (Session 13)
**Status:** Approved as standing practice
**Source:** `gsl-coffeeshop-demonstrator-discussion.md` (Session 12 conversation)
**Companion:** `gsl-plan-business-meta-model-implementation-2026-03-10.md`

---

## 1. Purpose

Establish the coffee shop demonstrator as a standing development practice across all future GSL project work. Each time a new architectural capability is developed in the GenderSense model, the team looks for the coffee shop equivalent and builds it. This document defines the rationale, the operating principles, the concrete demonstrator extensions mapped to planned work, and the boundaries of what does and does not belong in the demonstrator.

---

## 2. Rationale

The coffee shop demonstrator has proven its value across four dimensions:

**De-risking.** Every major architectural pattern validated in the coffee shop was subsequently applied to the clinical domain with confidence: Temporal workflows, XState lifecycle enforcement, two-layer action flows, metadata-driven generation, CDR integration (EHRbase), governance audits, and openEHR archetype design. Each validation de-risked the corresponding clinical implementation.

**Consolidation.** The coffee shop domain is small enough to hold entirely in your head. When the Knowledge Layer work pushed to the edge of technical understanding, the coffee shop provides a context where the machinery is visible without domain complexity obscuring it. A constraint check on a coffee order is the same architecture as a constraint check on hormone therapy eligibility — but the former is something you can reason about completely.

**Communication.** The "Sam test" — can you explain what you've built to a non-technical colleague by pointing at a coffee shop analogue? If a coffee shop dashboard says "3 orders are overdue, here's why, here's what should happen next" and the same architecture says "4 patients have overdue monitoring bloods, here's why, here's what should happen next," the analogy carries the explanation without requiring any technical understanding.

**Feedback.** The toy domain reveals architectural assumptions that clinical complexity can obscure. If a pattern feels awkward or over-engineered for a coffee shop, it's worth questioning whether the complexity is essential or accidental. If it feels natural and productive for a coffee shop, it's likely sound.

---

## 3. Operating Principles

### 3.1 The Standing Question

At session planning time, for each new capability: **"What is the coffee shop equivalent?"**

- If there is a natural analogue → scope and build it (typically one stage within the session)
- If the analogue would be forced or artificial → note why in the session report and proceed directly to clinical
- If uncertain → default to building it; the cost of a small demonstrator extension is low and the learning payoff is usually positive

### 3.2 Scope Discipline

The demonstrator is validation and learning, not a parallel product. If a demonstrator extension is taking more than one session, the scope needs trimming. The coffee shop exists to exercise the architecture at minimal cost, not to become its own development programme.

Concrete guideline: each demonstrator extension should be completable as a single stage (roughly 30–60 minutes of session time), producing a small number of model elements, a generated output, or a UI addition. If it's growing beyond that, ask: "Am I building a coffee shop feature or validating an architectural pattern?"

### 3.3 File Location

All demonstrator work lives in the existing `exercises/coffeeshop-demonstrator/` directory structure:

- Model extensions → `exercises/coffeeshop-demonstrator/model/`
- Generated output → `exercises/coffeeshop-demonstrator/generated/` or `exercises/coffeeshop-demonstrator/src/generated/`
- Application code → `exercises/coffeeshop-demonstrator/src/`
- Spikes → `exercises/coffeeshop-demonstrator/spikes/` (if needed)

The coffee shop model files are separate from the main `model/` directory. The coffee shop imports from the main model's Foundation::MetadataLibrary (already established) but does not import clinical domain packages.

### 3.4 Documentation

Each demonstrator extension is recorded in the session report under a standing section: "Coffee Shop Demonstrator Extension." The entry notes: what capability was demonstrated, what was built, what was learned, and whether the clinical implementation can proceed with confidence.

### 3.5 Git Practice

Demonstrator extensions are committed as their own atomic commits (e.g. "Coffee shop: add constraint evaluation at validateOrder step") to keep the history clean and the demonstrator work identifiable.

---

## 4. Already-Planned Demonstrator Extension: Knowledge Layer

The conversation in the source document identified three increments for a Coffee Shop Knowledge Layer Extension. These are the immediate demonstrator work and should be completed before the Business Meta Model phases begin.

### Increment 1 — Constraint Evaluation at a Pathway Step

**What it demonstrates:** The full constraint evaluation chain — SysML constraint def → generated evaluator → Temporal activity invocation → structured EvaluationResult with explanation.

**Concrete work:**

- Add a coffee shop constraint def to the coffee shop SysML model: "a customer cannot place a new order while they have an uncollected order"
- Run `gen_constraint_evaluator.py` against the coffee shop model (may need minor config change for file path)
- Wire the generated evaluation function into the existing `validateOrder` Temporal activity
- The evaluation produces a structured EvaluationResult: pass ("no outstanding orders") or fail ("customer has uncollected order X placed at time Y")

**What it validates:** That the Phase 5 generators are genuinely domain-agnostic — the same generator that produces hormone therapy constraint evaluators produces coffee order constraint evaluators.

### Increment 2 — Decision Table for Drink Routing

**What it demonstrates:** The decision table pattern producing explainable recommendations.

**Concrete work:**

- Model a coffee shop decision table: drink type + size + time of day → preparation method + estimated time + staffing
- Run `gen_decision_table_evaluator.py` against the coffee shop model
- Wire the generated lookup function into the workflow
- A barista or manager can see: "this drink was routed to cold path because it's an iced latte and it's after 2pm"

**What it validates:** That the decision table generator handles a different domain's row data correctly.

### Increment 3 — System Self-Assessment

**What it demonstrates:** The five-layer self-knowledge pattern simplified but genuine.

**Concrete work:**

- Use the manifest generator to produce a coffee shop structural inventory
- Build a scheduled Temporal cron workflow that runs the governance audit pattern: orders today, matching preparation events, overdue orders
- Wrap the result in a SystemStateAssessment-shaped output
- Add a dashboard page to the existing SvelteKit app: "The coffee shop has processed 47 orders today. 3 orders are awaiting preparation beyond the 10-minute target. The preparation completion rate is 93%."

**What it validates:** The self-knowledge architecture producing visible, useful output in a running system.

### Estimated scope

One to two sessions for all three increments, given that all infrastructure (generators, Temporal, SvelteKit, EHRbase) is already in place.

---

## 5. Demonstrator Extensions Mapped to Business Meta Model Phases

Each phase of the Business Meta Model implementation plan has a corresponding coffee shop demonstrator extension. These are intentionally lightweight — the goal is to prove the structural shape, not to build a full coffee shop business model.

### Phase 1 Extension — ServiceConcept and ActivityModel

**Coffee shop equivalent:** The coffee shop has an implicit service concept. Make it explicit.

**Concrete work:**

- Add to the coffee shop SysML model:
  - One CustomerSegment: walk-in customers
  - One ServiceOffering: drink order (referencing the existing fulfil-drink pathway)
  - One Channel: counter service
- Model the activity taxonomy for the coffee shop:
  - Service delivery: make drinks (already modelled as pathway steps)
  - Service-enabling: prep ingredients, clean equipment
  - Governance: health & safety checks, stock rotation
  - Development: barista training, menu development
  - Overhead: till reconciliation, supplier payments
- Tag each with ActivityGranularity: service delivery at tracked level (pathway produces events), everything else at envelope level

**What it validates:** That the ServiceConcept and ActivityModel part defs accommodate a simple service business. If they feel over-engineered for a coffee shop, the abstractions may need simplifying.

**Estimated scope:** One stage (30 minutes).

### Phase 2 Extension — ResourcePlanning and FinancialPlanning

**Coffee shop equivalent:** Model what a coffee shop needs to operate and what it costs.

**Concrete work:**

- ResourceTypes: barista, espresso machine, counter space, ingredient stock
- One Capability: "serve a drink" (requires barista + machine + ingredients + counter)
- CapacityModel: "with 1 barista, maximum 30 drinks/hour"
- RevenueStream: per-drink pricing (£3.50 average)
- CostDrivers: barista hourly rate (£12/hr), ingredient cost per drink (£0.80), overhead (rent, utilities, insurance)
- UnitEconomics: revenue per drink £3.50, cost per drink £1.90, margin per drink £1.60

**What it validates:** That the ResourcePlanning and FinancialPlanning structures produce meaningful unit economics for a simple business. The numbers are instantly verifiable.

**Estimated scope:** One stage (30 minutes).

### Phase 3 Extension — ScenarioModelling

**Coffee shop equivalent:** Two scenarios for the same coffee shop.

**Concrete work:**

- ScenarioDefinition "Small Kiosk": 1 barista, 50 drinks/day, limited menu, low rent
- ScenarioDefinition "Full Café": 3 baristas, 200 drinks/day, food menu, high street rent
- ProjectionParameters for each
- GrowthAssumptions: small kiosk grows linearly to 80 drinks/day; full café starts higher but has seasonal variation

**What it validates:** That the ScenarioDefinition structure can capture meaningfully different business configurations and that the parameter sets are sufficient to distinguish them.

**Estimated scope:** One stage (30 minutes).

### Phase 4 Extension — Projection Engine Verification

**Coffee shop equivalent:** Run the projection engine against coffee shop scenarios.

**Concrete work:**

- Add coffee shop scenario parameters to the projection engine (or run it with coffee shop values)
- Produce 12-month projections for both Small Kiosk and Full Café
- Verify by hand: "Small Kiosk at month 6 should be making 65 drinks/day × £1.60 margin = £104/day = ~£2,300/month margin. Is that what the engine says?"

**What it validates:** That the projection engine formulas are correct. The coffee shop numbers are simple enough that hand verification is trivial — errors will be spotted immediately. This is a more reliable validation than checking clinical projections where the relationships are harder to reason about.

**Estimated scope:** One stage (30 minutes), concurrent with Phase 4 main work.

### Phase 6 Extension — Operational Steering

**Coffee shop equivalent:** Forecast vs actuals for a coffee shop.

**Concrete work:**

- PeriodActuals: "Week 1: sold 240 drinks (projected 250). Revenue £840 (projected £875). Ingredient cost £210 (projected £200)."
- VarianceAnalysis: "Revenue shortfall £35. Decomposition: volume variance -£35 (240 vs 250 drinks). Price variance £0. Cost variance: -£10 unfavourable (ingredients £0.875/drink vs budget £0.80 — waste higher than planned)."
- This could be modelled in the SysML or just run through the projection engine with actuals comparison

**What it validates:** That the variance decomposition structure produces meaningful, attributable explanations for a simple business. If the explanation makes sense for "we sold fewer coffees because it rained," it will make sense for "we saw fewer patients because GP referrals were lower than projected."

**Estimated scope:** One stage (30 minutes), concurrent with Phase 6 main work.

---

## 6. Capabilities Without Natural Coffee Shop Analogues

The following capabilities should proceed directly to clinical implementation without a demonstrator step:

| Capability | Why no demonstrator |
|---|---|
| SNOMED CT terminology binding | Clinical vocabulary — no coffee equivalent |
| FHIR bridge / NHS interoperability | NHS-specific integration |
| Clinical archetype selection from CKM | Clinical Knowledge Manager is a clinical resource |
| GP shared care protocols | Clinical handoff pattern without a meaningful coffee analogue |
| Patient consent models | Legally specific to healthcare |
| Professional governance (GMC, CQC) | Regulatory specificity |

The demonstrator covers structural and dynamic architectural patterns. Domain-specific clinical content goes straight to the clinical model.

---

## 7. Demonstrator Status and History

### Completed demonstrator validations

| Capability | Phase | Sessions | What was validated |
|---|---|---|---|
| Temporal workflow orchestration | Coffee Shop Demonstrator Phase A | 1–2 | Durable workflow execution, activity retry, signal handling |
| XState lifecycle enforcement | Coffee Shop Demonstrator Phase C | 3 | State machine enforcement integrated with Temporal |
| Two-layer action flow | Coffee Shop Demonstrator Phase B | 2 | Domain layer + orchestration layer from same SysML model |
| Metadata-driven generation | Coffee Shop Demonstrator Phase B | 2 | SysML metadata annotations → generated TypeScript |
| SvelteKit web UI + signals | Coffee Shop Demonstrator Phase C | 3 | Real-time state visibility, signal dispatch from browser |
| Mermaid pathway diagrams | Coffee Shop Demonstrator Phase D | 4 | Governance documentation from same model |
| openEHR CDR (EHRbase) | CDR Exercise Phase A | 1–2 | Local CDR, archetype design, template upload, composition round-trip |
| Temporal → CDR integration | CDR Exercise Phase B | 3 | Workflow activities commit compositions |
| Entity views (AQL) | CDR Exercise Phase C | 4 | Type-based queries, process view vs entity view |
| Population governance audit | CDR Exercise Phase D | 5 | Expected vs actual compositions, gap identification |
| `@OpenEhrArchetype` metadata | CDR Exercise Phase E | 6 | Model-CDR traceability |

### Planned demonstrator extensions

| Capability | Source plan | Status |
|---|---|---|
| Constraint evaluation at pathway step | This plan, section 4 increment 1 | Planned — next |
| Decision table for drink routing | This plan, section 4 increment 2 | Planned — next |
| System self-assessment | This plan, section 4 increment 3 | Planned — next |
| ServiceConcept + ActivityModel | This plan, section 5 Phase 1 | Planned |
| ResourcePlanning + FinancialPlanning | This plan, section 5 Phase 2 | Planned |
| ScenarioModelling (two scenarios) | This plan, section 5 Phase 3 | Planned |
| Projection engine verification | This plan, section 5 Phase 4 | Planned |
| Operational steering (forecast vs actuals) | This plan, section 5 Phase 6 | Planned |

---

## 8. Integration with Session Workflow

### Session planning checklist addition

When planning each session's work, add:

1. **What architectural capability is being developed this session?**
2. **Is there a coffee shop demonstrator extension for this capability?**
   - If yes → scope it as one stage. Include in the session plan.
   - If no → note why. Proceed directly to clinical.
3. **When in the session should the demonstrator stage run?**
   - Option A: demonstrator first, then clinical (de-risking pattern)
   - Option B: clinical first, then demonstrator (consolidation pattern)
   - Option C: interleaved (when the demonstrator and clinical work inform each other)
   - Default: demonstrator first (validates before committing to clinical complexity)

### Session report addition

Each session report includes a standing section:

```
## Coffee Shop Demonstrator Extension

**Capability demonstrated:** [name]
**What was built:** [brief description]
**What was learned:** [findings, surprises, architectural feedback]
**Clinical implementation confidence:** [high / moderate / needs further work]
```

If no demonstrator work was done, the section reads: "No demonstrator extension this session. Reason: [capability has no natural coffee shop analogue / deferred to next session / etc.]"

---

*Plan prepared 10 March 2026 (Session 13). Establishes the coffee shop demonstrator as a standing development practice for all future GSL project work.*
