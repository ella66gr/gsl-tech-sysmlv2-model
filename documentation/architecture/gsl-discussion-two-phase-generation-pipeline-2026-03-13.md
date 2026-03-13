# Discussion Paper: Two-Phase Generation Pipeline & Integration Architecture

**Project:** GenderSense (GSL)
**Date:** 13 March 2026
**Session:** 24
**Status:** Discussion paper — captures architectural thinking for future workstream
**Context:** Conversation during CSW Extension Phase 5 planning. Arises from consideration of how to scale the generator-based model-to-implementation bridge as the system grows.

---

## 1. The Problem

The GSL architecture is model-driven: SysML v2 is the source of truth, and generators bridge from the model to running code. Four generators exist today:

| Generator | Input | Output |
|---|---|---|
| `gen_typescript_types.py` | SysML `part def`, `enum def` | TypeScript interfaces and union types |
| `gen_temporal_workflow.py` | SysML action flow with `@TemporalActivity`, `@TemporalSignal` metadata | Temporal workflow stub (`fulfilDrink.ts`) |
| `gen_state_machines.py` | SysML state machine with transitions and signals | XState machine definition |
| `gen_mermaid_pathway.py` | SysML action flow steps and decision nodes | Mermaid diagram and static SVG |

These generators produce *domain artefacts* — types, workflow stubs, state machines, diagrams. Each is valuable on its own. But each generated artefact must also be *integrated* into the running application: types must be exported from the shared package, the workflow must be registered with the Temporal worker, the state machine must be imported by the workflow, the SVG must be served by SvelteKit. Today that integration is done by hand.

As the number and variety of generated artefacts grows — constraint evaluators, decision table engines, composition builders, outcome evaluators, UI components, API route stubs — the manual integration work scales linearly with each new generator. The question is: **can the integration itself be generated, and if so, how should that capability be architected?**

---

## 2. The Two-Phase Generation Pipeline

The core idea is to separate generation into two distinct phases with different concerns:

### Phase 1: Domain Generators

These read the SysML model and produce domain-specific artefacts. They understand the model semantics but know nothing about the target application's framework, file layout, or wiring conventions.

**Input:** SysML model (`.sysml` files or, in future, Syside Automator API)
**Output:** Domain artefacts + a generation manifest

Each domain generator produces:
- The artefact itself (TypeScript file, workflow stub, state machine, etc.)
- A manifest entry describing what was produced, its type, its dependencies, and its intended role

The manifest is the contract between Phase 1 and Phase 2. A simplified example:

```json
{
  "generatedAt": "2026-03-13T10:00:00Z",
  "modelSource": "model/domain/coffeeshop.sysml",
  "artefacts": [
    {
      "id": "types-coffeeshop",
      "type": "typescript-interfaces",
      "path": "generated/types.ts",
      "exports": ["OrderState", "DrinkSize", "MenuItem", "CatalogueEntry"],
      "generator": "gen_typescript_types"
    },
    {
      "id": "workflow-fulfil-drink",
      "type": "temporal-workflow",
      "path": "generated/fulfil-drink-workflow.ts",
      "taskQueue": "coffee-shop",
      "activities": ["validateOrder", "recordOrder", "prepareDrink", "recordPreparation"],
      "signals": ["baristaStarted", "drinkReady", "drinkCollected"],
      "dependencies": ["types-coffeeshop", "statemachine-order-lifecycle"],
      "generator": "gen_temporal_workflow"
    },
    {
      "id": "statemachine-order-lifecycle",
      "type": "xstate-machine",
      "path": "generated/order-lifecycle-machine.ts",
      "states": ["placed", "inPreparation", "ready", "collected", "cancelled"],
      "dependencies": ["types-coffeeshop"],
      "generator": "gen_state_machines"
    },
    {
      "id": "constraint-max-outstanding",
      "type": "constraint-evaluator",
      "path": "generated/constraint-max-outstanding.ts",
      "constraintName": "maxOutstandingOrders",
      "appliesTo": "validateOrder",
      "dependencies": ["types-coffeeshop"],
      "generator": "gen_constraint_evaluator"
    }
  ]
}
```

**Key property:** Domain generators are *framework-agnostic*. The TypeScript types generator doesn't know whether they'll be used in a SvelteKit app, a Next.js app, or a standalone Node service. The workflow generator doesn't know how the Temporal worker is configured. This separation is what makes the generators reusable across the coffee shop and the clinical system.

### Phase 2: Integration Generators

These read the generation manifest and produce the wiring code that connects the domain artefacts to the target application. They understand the application's framework conventions but know nothing about the SysML model semantics.

**Input:** Generation manifest + integration configuration (framework, file layout conventions, registration patterns)
**Output:** Glue code — barrel exports, worker registrations, route definitions, component registrations, configuration fragments

Examples of what Phase 2 generators produce:

| Integration concern | Generated output |
|---|---|
| **Package exports** | Barrel `index.ts` in `@coffeeshop/shared` that re-exports all generated types |
| **Temporal worker registration** | `worker-activities.ts` that imports and registers all generated activities |
| **SvelteKit route stubs** | `+server.ts` files in the correct route directories for generated API endpoints |
| **State machine registration** | Import map connecting workflow IDs to their state machine definitions |
| **Constraint wiring** | Activity wrapper that calls constraint evaluators at the correct pathway steps |
| **Composition builder registration** | Map of archetype IDs to generated composition builder functions |

**Key property:** Integration generators are *model-agnostic*. They read the manifest — which describes artefact types, paths, exports, and dependencies — and produce the wiring. They don't need to parse SysML or understand clinical domain concepts. They need to understand the target framework (SvelteKit file conventions, Temporal worker API, TypeScript module resolution).

### The Boundary Between Phases

The manifest is the interface contract. Phase 1 generators are responsible for correct domain artefacts and accurate manifest entries. Phase 2 generators are responsible for correct framework integration given a valid manifest.

This boundary means:
- A new domain generator (e.g. `gen_outcome_evaluator`) only needs to produce artefacts and manifest entries — it doesn't need to know how integration works
- A new target framework (e.g. migrating from SvelteKit to another framework) only requires new Phase 2 integration generators — the domain generators and manifest are unchanged
- Testing is cleanly separable: domain generators are tested against model semantics, integration generators are tested against framework conventions

---

## 3. Integration Patterns

Several established approaches exist for how Phase 2 integration can work. These are not mutually exclusive — different artefact types may use different patterns within the same system.

### 3.1 Convention-Based Discovery (File System as Registry)

The simplest pattern. Generated artefacts are placed in directories that the framework scans automatically.

**Where this works well:**
- **SvelteKit routing:** Generate a `+server.ts` in `src/routes/api/[resource]/` and SvelteKit picks it up automatically. No explicit registration needed.
- **Temporal activity bundles:** Place activity files in a `generated/activities/` directory; the worker startup script uses `glob` or a dynamic import to register everything in that directory.

**Advantages:** No explicit registration code to generate. Adding a new artefact means adding a file. Framework conventions handle discovery.

**Disadvantages:** Implicit — harder to understand what's registered and why. Relies on naming and placement conventions being strictly followed. Error messages when conventions are violated can be opaque.

**GSL applicability:** High for SvelteKit routes and potentially for Temporal activities. The file-based routing system is already effectively doing this for hand-written pages.

### 3.2 Manifest-Driven Code Generation

Phase 2 generates explicit registration code from the manifest. The generated code is committed to the repository and runs as normal application code.

**Where this works well:**
- **Barrel exports:** Generate `index.ts` from the manifest's `exports` list
- **Worker configuration:** Generate `worker-config.ts` that imports and registers activities
- **Route maps:** Generate a `routes.ts` that maps API paths to handler functions

**Advantages:** Explicit and inspectable — you can read the generated glue code and understand what's happening. Works with any framework (no convention dependency). Errors are traceable.

**Disadvantages:** Requires regeneration when artefacts change. Must handle merge with any hand-written code in the same files (or keep generated and hand-written code strictly separate).

**GSL applicability:** High. The existing barrel export in `@coffeeshop/shared/src/index.ts` is already a manual version of this pattern. Automating it from the manifest is a natural first step.

### 3.3 Runtime Discovery (Registry Pattern)

Generated artefacts register themselves at runtime using a central registry. Each artefact calls a `register()` function during module initialisation.

**Where this works well:**
- **Spring Boot auto-configuration** — generated `@Configuration` classes are classpath-scanned
- **Plugin architectures** — each generated module exports a registration function

**Advantages:** No separate integration generation step. Adding a new artefact is self-contained.

**Disadvantages:** Runtime cost. Order-of-registration dependencies. TypeScript/ESM module initialisation order is less predictable than Java classpath scanning. Hard to tree-shake.

**GSL applicability:** Low for the current architecture. The TypeScript/SvelteKit stack doesn't have a natural classpath-scanning equivalent. Could work for Temporal activities (worker startup is a natural registration point) but adds complexity without clear benefit over manifest-driven generation.

### 3.4 Build-Time Transformation (Compiler Plugins / Vite Plugins)

Integration happens during the build step. A Vite plugin reads the manifest and transforms the application's module graph — injecting imports, registering routes, or modifying configuration.

**Where this works well:**
- **Vite plugins for auto-import** (e.g. `unplugin-auto-import`)
- **Nuxt's module system** — Nuxt plugins can scan directories and register routes/components at build time
- **SvelteKit adapters** — transform the application for different deployment targets

**Advantages:** Transparent to application code. No generated glue files to maintain.

**Disadvantages:** Build tool coupling. Harder to debug. Vite plugin API has constraints (especially around SSR). Significant development effort for the plugin itself.

**GSL applicability:** Medium-term possibility. A Vite plugin that reads the generation manifest and auto-injects imports would be elegant, but the development cost is high relative to manifest-driven code generation. Worth noting as a future optimisation, not an initial approach.

### Recommended Starting Point

**Manifest-driven code generation (3.2)** is the right first step for GSL. It's explicit, inspectable, framework-independent at the Phase 1 layer, and straightforward to implement. The manifest already has a natural home (the system manifest concept from the Knowledge Layer). Convention-based discovery (3.1) can complement it for SvelteKit routes where file placement is the natural integration mechanism.

---

## 4. What Can Be Generated: Entity Classes

The following table maps the SysML model elements to the classes of artefact that domain generators can produce, with the integration concern for each.

### Currently Generated

| SysML source | Domain artefact | Integration concern |
|---|---|---|
| `part def`, `enum def` | TypeScript interfaces and union types | Barrel export in shared package |
| Action flow with `@TemporalActivity`, `@TemporalSignal` | Temporal workflow stub | Worker activity registration |
| State machine def with transitions | XState machine definition | Import by workflow |
| Action flow steps | Mermaid diagram + SVG | Static asset serving |

### Designed but Not Yet Built

| SysML source | Domain artefact | Integration concern |
|---|---|---|
| `constraint def` with `@LogicRule` / `@SafetyConstraint` | Constraint evaluator function | Wiring into Temporal activity at correct pathway step |
| Decision table (tabular constraint patterns) | Decision table evaluator / lookup function | Wiring into workflow routing logic |
| `@OpenEhrArchetype` metadata on part defs | Composition builder (TypeScript function producing canonical JSON) | Registration in CDR client; mapping from domain type to builder |
| `OutcomeDefinition` usages | Outcome evaluation function | Wiring into governance audit pipeline |
| Manifest generator (structural inventory) | System Model Manifest JSON | Consumption by self-assessment dashboard |

### Potential Future Generations

| SysML source | Domain artefact | Integration concern |
|---|---|---|
| `part def` with `@PersistencePolicy` | Database migration / schema DDL | Database migration runner; seed data |
| `CatalogueEntry` usages | Seed data SQL or JSON | Database initialisation scripts |
| Action flow with CDR commit steps | API route handlers (SvelteKit `+server.ts`) | File placement in route directory (convention-based) |
| `part def` with UI metadata (hypothetical) | Svelte component skeletons | Page composition and routing |
| `ServiceOffering` with `Channel` | API contract / OpenAPI spec fragment | Documentation; client generation |
| `ResourceType` + `Capability` | Capacity model configuration | Projection engine parameter input |
| `ScenarioDefinition` | Projection engine scenario dict | Projection engine configuration |
| State machine + UI state mapping | Form state management (what fields are visible/editable in each state) | Component props and conditional rendering |

### The Generatability Spectrum

Not everything should be generated. The value of generation follows a spectrum:

**High value (generate):**
- Artefacts that are structurally derived from the model with minimal creative judgment — types, enums, state machine definitions, schema DDL, barrel exports, worker registrations
- Artefacts that must stay in sync with the model — if the model changes, the artefact must change in lockstep

**Medium value (generate skeleton, hand-finish):**
- Workflow stubs — the structure (activity sequence, signal points, error handling pattern) is generated, but activity implementations contain domain logic that requires human judgment
- Composition builders — the archetype mapping structure is generated, but clinical data transformations may need clinical reasoning
- API route handlers — the route structure and request/response types are generated, but validation logic and error handling may need refinement

**Low value (don't generate):**
- UI layout and design — visual design involves aesthetic judgment that models don't capture well
- Clinical decision logic — the *structure* of a decision table can be generated, but the *content* (which clinical values, which thresholds) requires clinical expertise
- Error messages and user-facing text — tone, context-sensitivity, and accessibility considerations
- Test cases — while property-based tests can be generated from constraints, meaningful integration tests require understanding of the system's operational context

**The "generate skeleton, hand-finish" category is the most architecturally interesting.** It requires a generation pattern that produces a usable starting point without overwriting hand-written additions on regeneration. This is the "protected regions" problem — and it's where the two-phase pipeline pays off, because the Phase 1 generator produces a clean domain artefact, and hand-written code lives in a separate layer that the Phase 2 integration generator wires together.

---

## 5. Architectural Implications

### 5.1 Layer Separation: Model → Domain Artefacts → Integration Glue → Running Application

The two-phase pipeline implies a strict four-layer architecture for generated code:

```
┌─────────────────────────────────────┐
│  Layer 1: SysML Model               │  Source of truth
│  (.sysml files in Syside Modeler)   │  Human-authored, version-controlled
└──────────────┬──────────────────────┘
               │ Phase 1 generators
               ▼
┌─────────────────────────────────────┐
│  Layer 2: Domain Artefacts           │  Generated, framework-agnostic
│  (types.ts, workflow stubs,          │  Committed to repo in generated/
│   state machines, evaluators)        │  Never hand-edited
└──────────────┬──────────────────────┘
               │ Phase 2 integration generators
               ▼                         (reads manifest)
┌─────────────────────────────────────┐
│  Layer 3: Integration Glue           │  Generated, framework-specific
│  (barrel exports, worker config,     │  Committed to repo in generated/
│   route registrations)               │  Never hand-edited
└──────────────┬──────────────────────┘
               │ Standard imports
               ▼
┌─────────────────────────────────────┐
│  Layer 4: Application Code           │  Hand-written
│  (activity implementations,          │  Uses Layer 2 types and Layer 3 wiring
│   page components, business logic)   │  Protected from regeneration
└─────────────────────────────────────┘
```

**Critical rule:** Layers 2 and 3 are fully regenerable from the model. They should never contain hand-written code. Application code (Layer 4) imports from Layers 2 and 3 but is never overwritten by generators.

This maps to the existing project structure:

| Layer | Current location | Example |
|---|---|---|
| 1: Model | `model/domain/*.sysml` | `coffeeshop.sysml` |
| 2: Domain artefacts | `generated/` (or `src/generated/`) | `types.ts`, `order-lifecycle-machine.ts` |
| 3: Integration glue | `src/generated/` or framework-specific locations | Barrel exports, worker config (currently hand-written) |
| 4: Application code | `src/`, `packages/*/src/` | Activity implementations, Svelte pages, API routes |

### 5.2 Regeneration Safety

The four-layer separation solves the "regeneration overwrites my changes" problem. Layers 2 and 3 are regenerated freely. Layer 4 is never touched by generators. The boundary is enforced by convention (and could be enforced by tooling — a pre-commit hook that checks for hand-edits in `generated/` directories).

When the model changes:
1. Re-run Phase 1 generators → new domain artefacts in Layer 2
2. Re-run Phase 2 generators → new integration glue in Layer 3
3. **Layer 4 may need manual updates** if the model change altered interfaces (e.g. a new field on a part def means the activity implementation needs to handle it). The manifest diff can highlight what changed, guiding the developer.

### 5.3 Manifest as Architectural Asset

The generation manifest becomes a first-class architectural asset — not just a build artefact. It's the queryable record of what the system contains, what was generated from what, and how things connect. This aligns directly with the Knowledge Layer's structural inventory concept:

- The manifest generator (already designed, not yet built) produces the system's self-knowledge about its own structure
- The generation manifest extends this with provenance: not just "the system contains a constraint evaluator for maxOutstandingOrders" but "this evaluator was generated from constraint def X in model file Y, and is wired into activity Z"

This provenance chain — model element → generated artefact → integration point → running code — is the foundation for the system's ability to reason about its own architecture. When the self-assessment layer asks "do I have a constraint evaluator for this pathway step?", it can answer by reading the manifest.

### 5.4 Implications for the Coffee Shop Demonstrator

The coffee shop currently has four generators that produce Layer 2 artefacts. Layer 3 (integration glue) is entirely hand-written. The two-phase pipeline would:

1. Add a manifest output to each existing generator
2. Build a Phase 2 generator that reads the manifest and produces:
   - `packages/shared/src/generated/index.ts` (barrel export)
   - `packages/temporal/src/generated/worker-config.ts` (activity registration)
   - Potentially: `packages/web/src/lib/generated/route-map.ts` (API route metadata for the UI)
3. Validate the pipeline by demonstrating that adding a new domain artefact (e.g. a constraint evaluator from KL Increment 1) requires only a Phase 1 generator run + Phase 2 integration run, with no hand-written glue

### 5.5 Implications for the Clinical System

The clinical system will have significantly more generated artefacts than the coffee shop: multiple pathways, multiple constraint sets, terminology bindings, archetype-to-composition mappings, formulary-driven UI configurations. The manual integration burden would be substantial. The two-phase pipeline makes this tractable:

- **New clinical pathway:** Phase 1 generates workflow, state machine, types, constraint evaluators, composition builders. Phase 2 generates the barrel exports, worker registrations, route stubs, and UI component skeleton. The clinical team writes the activity implementations and refines the UI.
- **Formulary update:** Phase 1 regenerates catalogue types and decision table evaluators. Phase 2 regenerates integration glue. Application code is unchanged (it already handles the interfaces).
- **New regulatory constraint:** Phase 1 generates the constraint evaluator. Phase 2 wires it into the correct pathway step. No other code changes.

---

## 6. Prototyping and Validation Strategy

### 6.1 Prototype Scope

The prototype should validate the two-phase concept without requiring a large upfront build. The minimum viable prototype:

1. **Manifest format definition** — JSON schema for the generation manifest
2. **Manifest output from one existing generator** — extend `gen_typescript_types.py` to produce a manifest alongside the types file
3. **One Phase 2 integration generator** — a script that reads the manifest and produces the barrel export for `@coffeeshop/shared`
4. **Demonstrate the regeneration loop** — change the SysML model (add an attribute to a part def), re-run Phase 1, re-run Phase 2, verify the barrel export updates automatically

This is roughly one session stage of work and proves the concept without changing any application behaviour.

### 6.2 Incremental Extension Path

After the prototype validates, extend incrementally:

| Step | What's added | What's validated |
|---|---|---|
| **Prototype** | Manifest format + type generator manifest + barrel export generator | Manifest as contract between phases |
| **Step 2** | Manifest output from all four existing generators | Multi-generator manifest aggregation |
| **Step 3** | Temporal worker registration generator (Phase 2) | Framework-specific integration generation |
| **Step 4** | New domain generator (constraint evaluator, KL Increment 1) | End-to-end: new model element → domain artefact → integration glue → running code |
| **Step 5** | Manifest diff tooling | Change impact analysis: "model changed X, which affects artefacts Y and Z" |
| **Step 6** | Syside Automator as Phase 1 input (replacing text-based parsing) | Proper semantic model access; eliminates parser bugs |

### 6.3 Coffee Shop as Validation Vehicle

Per the standing demonstrator practice, the coffee shop validates the generation pipeline before it's applied to the clinical system. The validation criteria:

- **Can a new menu item type (e.g. adding a "Smoothie" category with blending-specific attributes) flow from SysML model change through both generator phases to running application with no manual glue code?**
- **Does regeneration after a model change leave application code (Layer 4) untouched?**
- **Is the manifest accurate enough to support system self-knowledge queries?** ("What constraint evaluators exist? Which pathway steps do they apply to? When were they last generated?")

### 6.4 Timing

This workstream is naturally sequenced *after* the CSW Extension phases that exercise the existing generators more heavily (Phase 10: Meta Model Update will regenerate types and potentially workflows). It also benefits from KL Increment 1 (constraint evaluation), which adds a new generator to the pipeline — a good test case for the two-phase approach.

Suggested placement: after CSW Extension Phase 10, as a short focused workstream (2–3 sessions) that formalises the generation architecture before clinical pathway work begins.

---

## 7. Relationship to Existing Work Analysis Items

| Work analysis item | Relationship |
|---|---|
| **§7 Generators — Designed but Not Built** | Each planned generator (constraint evaluator, composition builder, outcome evaluator, projection generator) would be a Phase 1 domain generator producing manifest entries |
| **§7 Generator bugs** | The text-based parsing bugs reinforce the case for Syside Automator as a Phase 1 input source. The two-phase architecture doesn't solve parsing bugs, but it does isolate them: a parsing bug affects only the domain artefact, not the integration glue |
| **§4 Knowledge Layer — Full manifest generation** | The generation manifest and the system manifest converge. Both describe "what the system contains." The generation manifest adds provenance |
| **§3 SysML Model — Cross-references not yet formalised** | Formalising `ref` relationships in SysML gives generators richer input — e.g. a formal `ref` from `ServiceOffering` to `ClinicalPathway` would let a Phase 1 generator produce the API route structure automatically |
| **Coffee Shop KL Increment 1** | First test case for a new Phase 1 generator (constraint evaluator) flowing through the two-phase pipeline |

---

## 8. Open Questions

1. **Manifest granularity:** Should each generator produce its own manifest fragment (aggregated by Phase 2), or should all generators write to a single shared manifest? Fragments are simpler for independent generator development; a single manifest is simpler for Phase 2 consumption.

2. **Hand-finished artefacts:** For "generate skeleton, hand-finish" artefacts, how is the boundary between generated and hand-written code managed? Options include separate files (generated interface + hand-written implementation), protected regions (markers in the generated file that the generator preserves), or a composition pattern (generated base class, hand-written subclass).

3. **Syside Automator timeline:** The text-based parsers are fragile. Syside Automator provides proper semantic model access. Is there a timeline for Automator maturity that should influence when to invest in the generation pipeline?

4. **Generation as CI step:** Should generation be a CI/CD step (generators run on every commit that touches `.sysml` files) or an explicit developer action? CI is more robust but adds pipeline complexity.

5. **Manifest versioning:** When the manifest format evolves, how do Phase 2 generators handle older manifest versions? Schema versioning with migration, or strict version matching?

---

*Discussion paper prepared 13 March 2026 (Session 24). Captures architectural thinking from conversation during CSW Extension Phase 5 planning. Not yet a committed workstream — intended to inform future planning.*
