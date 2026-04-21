# GenderSense SysML Model — Strategic Snapshot

**Date:** 11 March 2026
**Prepared by:** Claude (from direct review of the complete codebase)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice

---

## 1. What This Project Is

GenderSense Limited is building a model-driven clinical service management platform for gender-affirming healthcare. The `gsl-sysml-model` project is the representation layer: a SysML v2 model that serves as the single source of truth for what the business is, how its clinical services work, what rules govern them, and how the technology platform supports them.

The architectural thesis — validated through a running coffee shop demonstrator application and now extended across the full business system — is that the model generates the execution layer rather than merely documenting it. Process knowledge lives in the model. Clinical data structure lives in openEHR archetypes. Decision rules live in constraints. When anything changes, the change happens in the representation layer and propagates to execution via generation or configuration.

This is not a paper exercise. The model produces running code.

---

## 2. Scale and Maturity

### The model

| Metric | Value |
|---|---|
| Top-level packages | 10 (Enterprise, Foundation, Knowledge, ServiceDelivery, Platform, Operations, BusinessModel, BusinessScenarios, BusinessStrategy, GenderSense root) |
| Total packages | 72 |
| Model files | 10 `.sysml` files, 364 KB total |
| Largest file | `knowledge.sysml` — 114 KB |
| Use case definitions | 100+ |
| Constraint definitions | 8 (evaluable, with formal satisfy traceability to requirements) |
| Decision tables | 2 (17 rows total, clinical vocabulary) |
| Entity lifecycle state machines | 4 (Episode, Prescription, LabResult, Referral) |
| Requirement definitions | 8 (regulatory, with satisfy chain to constraints) |
| Outcome definitions | 10 |
| Metadata definitions | 13 (9 Foundation + 4 Temporal) |
| Enum definitions | 25+ in CommonTypes, 9 clinical vocabulary, business model enums |

### The generation pipeline

| Generator | Input | Output | Status |
|---|---|---|---|
| Package hierarchy | All `.sysml` files | Terminal view, Markdown, OPML, HTML mindmap, OmniOutliner | Production — `gsl` CLI |
| Constraint evaluator | Constraint defs + evaluation specs | 3 TypeScript files: types, evaluators, spec registry | Production — 8 constraints |
| Decision table evaluator | Decision table defs + rows | TypeScript lookup + evaluate functions | Production — 2 tables, 17 rows |
| System manifest | All `.sysml` files | JSON structural manifest (8 inventory sections) | Production |
| Projection engine | Scenario parameters | 24-month financial projections, sensitivity, comparison | Production — 2 scenarios |
| Temporal workflow | Orchestration action defs with metadata | Temporal async workflow TypeScript | Demonstrator |
| State machine | State defs | XState v5 machine definitions | Demonstrator |
| TypeScript types | Structural model | TypeScript interfaces + enums | Demonstrator |
| Mermaid pathway | Domain action defs | Mermaid diagrams | Demonstrator |

### The coffee shop demonstrator

A running pnpm monorepo application: SvelteKit web frontend, Temporal workflow engine, XState lifecycle enforcement, EHRbase openEHR CDR. Six model files in the exercise directory including business model, resource/financial, and scenario extensions that prove every major architectural pattern generalises to a non-clinical domain. Four generators produce executable artefacts from the SysML model.

### Documentation

| Category | Count | Content |
|---|---|---|
| Session reports | 24 | Complete project journal, every decision recorded |
| Plans | 18 | Phase-by-phase implementation plans, all executed or tracked |
| Architecture documents | 8 | Validated patterns, principles, design rationale, meta-modelling |
| Guides | 3 | Repo conventions, editing guide, GitHub setup |
| Syntax reference | v3.11 (12 prior versions archived) | Every verified pattern, reserved word trap, Syside behaviour |

### Development cadence

19 working sessions across 7 days (5–11 March 2026). The project re-engaged after a 7-month break during which studio development was the focus. The prior engagement established the coffee shop demonstrator (Phases A–D) and initial SysML v2 fluency.

---

## 3. Architectural Achievements

### The three-tier reasoning stack is modelled and partially generated

Tier 1 (deterministic constraints) is fully modelled in SysML and generates TypeScript evaluators. Eight clinical constraints with formal satisfy traceability to regulatory requirements, evaluation specs with input derivations, and a generated spec registry. Tier 2 (DMN-style decision tables) is modelled as a reusable SysML v2 pattern and generates TypeScript lookup/evaluate functions. Two clinical tables (regimenSelection, stabilityAssessment) with 17 rows and nine clinical vocabulary enums. Tier 3 (ML/LLM advisory) is architecturally specified as interface-only — the correct decision at this stage.

### The five-layer self-knowledge architecture exists in the model

Structural self-knowledge (Layer 1) is generated as the system manifest JSON. Goal-state knowledge (Layer 3) is generated as the constraint spec registry. The LogicEngine package contains 21 part defs including ConstraintEvaluator tiers, OperationalStateAggregator, GapAnalyser, GoalProjector, AssessmentOrchestrator, and supporting types. Layers 2 (operational state), 4 (gap analysis), and 5 (remediation) are structurally defined but not yet generated or runtime-exercised.

### The business meta model is a quantitative planning instrument

Not merely a structural description. Two fully parameterised business model variants (Lean Clinical, Full Platform) produce 24-month financial projections with monthly granularity: patient acquisition, clinical and subscription revenue, multi-category costs, margin, cumulative cash flow, clinician utilisation. Sensitivity analysis varies key parameters ±20%. Scenario comparison produces an investment estimate differential (£22K vs £90K capital requirement). The projection engine reads parameters from the SysML model — the model is the source of truth for business planning as well as clinical service design.

### The two-layer action flow pattern is proven

Domain layer (governance audience, Mermaid diagrams) and orchestration layer (runtime, Temporal workflows) are generated from the same SysML model. Validated in the coffee shop demonstrator with full durable execution including worker crash recovery and XState lifecycle enforcement. The hormone therapy initiation pathway has both layers modelled with metadata annotations marking generation targets.

### Satisfy traceability works (with discovered boundaries)

The chain from regulatory requirement → constraint → evaluation spec → generated evaluator is structural and machine-navigable. The significant finding in Phase 7 that `satisfy requirement X by partUsage` fails (the `by` target must be a constraint, not a part) is precisely documented, and a clean workaround pattern (ObjectiveCapabilityMapping) maintains equivalent traceability for objective→capability links.

### The coffee shop demonstrator principle is institutionalised

Every major architectural capability developed in the GenderSense model has a corresponding demonstrator validation. The practice is documented, the session report format includes a standing section, and 11 demonstrator validations are complete covering Temporal orchestration, XState lifecycle, two-layer action flows, metadata-driven generation, SvelteKit UI, Mermaid diagrams, openEHR CDR integration, Temporal→CDR integration, entity views, population governance audit, and openEHR metadata traceability. The business meta model extensions (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, Scenarios, Steering, Strategy) each have coffee shop parity.

---

## 4. Strategic Position

### What the model enables that doesn't exist yet

The model is currently ahead of the implementation. This is by design — the representation layer is the long-term investment, and the execution layer is derived from it. The major capabilities that are modelled but not yet running in an execution environment are:

- **Clinical constraint evaluation at runtime.** The full chain (SysML → generated evaluator → Temporal activity → EvaluationResult → audit record) is designed and partially generated but has not executed end-to-end in a running system. The coffee shop Knowledge Layer increments are the planned validation step.
- **Decision table evaluation at runtime.** Generated evaluators exist but haven't been wired into a workflow.
- **System self-assessment.** The five-layer architecture is structurally modelled but Layer 2 (operational state queries), Layer 4 (gap analysis), and Layer 5 (remediation) have no runtime artefact.
- **Population-level governance audit.** The CDR exercise validated the pattern for a single rule. Scaling to the full constraint set across a patient cohort is designed but not built.
- **The second clinical pathway.** The architecture was designed around one pathway. Generalisation to a second pathway is the most important structural test remaining.

### What the model proves

- SysML v2 is a viable single-source-of-truth modelling language for a complete business system, from strategic intent through clinical service delivery to technology platform.
- Model-driven generation of Temporal workflows, XState state machines, TypeScript types, constraint evaluators, decision table evaluators, and financial projections works at practical scale.
- The openEHR CDR integration pattern (workflow-driven and form-driven composition commits, AQL entity views, population-level governance queries) is validated and ready for clinical content.
- The business meta model structures (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, ScenarioModelling, Strategy) are domain-agnostic — proven by instantiation in both healthcare and coffee shop domains.
- The coffee shop demonstrator practice is an effective de-risking mechanism for architectural development.

### What the model doesn't yet prove

- That the architecture generalises across multiple clinical pathways (only one is fully modelled).
- That the Knowledge layer self-knowledge architecture produces useful runtime output (modelled but not executed).
- That SysML v2 port definitions and connections work in Syside for platform interface modelling.
- That the generation pipeline can be sustained at scale (currently regex-based; Syside Automator is the intended replacement).
- That the projection engine parameters reflect real clinical economics (currently illustrative).

---

## 5. Technical Debt and Known Limitations

### Deliberate deferrals (correctly deferred)

- **Prolog/Tier 2 implementation** — Tau Prolog feasibility validated (spike passed 16/16 tests, 2.4ms/query). Implementation waits for compound inference demand from a second pathway.
- **ML/LLM/Tier 3** — Interface-only until data volume and regulatory clarity justify implementation.
- **Clinical archetype design** — CDR integration patterns validated; clinical content depends on pathway breadth.
- **FHIR bridge, SNOMED CT binding** — NHS interoperability concerns that follow clinical data implementation.

### String-typed cross-references (technical debt)

Three cross-domain references remain informal: ServiceOffering→ClinicalPathways, ScenarioComparison→ScenarioDefinition, ResourceConstraint→Regulation requirement defs. Each is a string attribute where a typed `ref` would provide structural traceability. The first is medium priority (becomes relevant with a second pathway); the others are low priority.

### Generator fragility

All generators use regex text parsing. This works because formatting is controlled, but it's inherently brittle. The Syside Automator API (semantic model access) passed all 10 evaluation tests in the Phase 5 spike and is the intended migration path. Automator stability (currently 0.8.5, approaching 1.0) gates the migration.

### SysML v2 constructs not yet exercised

Port definitions and connections (major structural construct for platform interfaces), use case composition (`include`, `extend`, `actor`), metadata def specialisation, and nested `:>>` redefinition are all unverified in Syside. These represent untapped expressive power in the language.

### Projection engine parameters

Revenue, cost, and growth parameters are illustrative placeholders. The engine demonstrates structural capability but does not yet reflect validated clinical pricing. This is an Ella-input dependency, not a technical blocker.

---

## 6. Competitive and Regulatory Positioning

### Self-describing system

The architecture's most distinctive property is that the system can explain itself. Reporting on activity, decision logic, structural semantics, constraints, governance, and entity relationships are first-class capabilities — not afterthoughts layered on after implementation. A clinical governance query ("show me every patient whose monitoring bloods are overdue, why each one is overdue, and what the pathway says should happen next") is a structured evaluation against the same model that generates the running system.

### CQC and clinical safety

The satisfy traceability chain (regulatory requirement → constraint → evaluation spec → generated evaluator → audit record) provides evidence of compliance as a system capability rather than a manual documentation exercise. DCB0129/DCB0160 clinical risk management is materially strengthened when the SysML model that defines the pathway is the same artefact that generates the running code.

### Indemnity profile

A practice that can demonstrate formally defined clinical processes, system enforcement of those processes, and complete audit trails showing conformance presents a stronger risk profile to indemnifiers than one relying on conventional documentation.

### Business planning

The quantitative business model — with scenario comparison, sensitivity analysis, and the operational steering cycle wired to the Knowledge layer's deficit tracking — means that business planning and system architecture share a common representation. A change to the pricing model, a new service offering, or a capacity constraint is modelled in the same language as the clinical pathways it affects.

---

## 7. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **Syside Modeler stalls or is abandoned** | Low | High | SysML v2 is an OMG standard; alternative tooling (Eclipse Papyrus, PlantSysML) exists. Model files are text-based and portable. |
| **Architecture over-investment before clinical validation** | Medium | Medium | Coffee shop demonstrator practice catches abstraction failures early. Second clinical pathway is the key generalisation test. |
| **Solo developer bottleneck** | High | High | The model is thoroughly documented (24 session reports, 8 architecture docs, syntax reference). A competent SysML practitioner could orient within the repo. |
| **Generator maintenance burden at scale** | Medium | Medium | Automator migration replaces fragile regex parsing. Generated files carry source references. |
| **Regulatory landscape change** | Low | Medium | The model separates regulatory requirements from their satisfaction — a new requirement adds a new requirement def and satisfy chain, not a system redesign. |
| **Clinical content complexity exceeds model capacity** | Low | Low | The three-tier reasoning stack and five-layer self-knowledge architecture are designed for complexity growth. Compound deficit reasoning (Prolog) is architecturally reserved. |

---

## 8. Summary Assessment

This is a serious, disciplined piece of model-driven systems engineering applied to healthcare service design. The project has achieved something unusual: a 72-package SysML v2 model that spans from strategic business planning through clinical service delivery to technology platform design, with a working generation pipeline producing executable code, a running demonstrator application validating every major architectural pattern, and a documentation corpus that makes the entire development history traceable.

The architectural thesis — that a single SysML v2 model can serve as the source of truth for a complete business system, generating both runtime execution and governance documentation — is validated. The model is not theoretical; it produces TypeScript evaluators, Temporal workflows, XState state machines, financial projections, and structural manifests.

The three areas of highest strategic value are:

1. **The Knowledge layer** — the three-tier reasoning stack and five-layer self-knowledge architecture. This is the architectural feature most likely to differentiate GenderSense from conventional clinical software. The ability to provide formal, auditable, reproducible reasoning chains for every clinical decision, and to have the system assess its own operational state against its own goals, is not something that can be retrofitted.

2. **The business meta model as a quantitative planning instrument.** The model doesn't just describe the business — it computes projections, compares scenarios, tracks variance, and connects operational steering to the same Knowledge layer that governs clinical decisions. This collapses the gap between business planning and system architecture.

3. **The generation pipeline as the bridge.** The separation of representation from execution, with generation as the mechanism that keeps them in sync, means that the model investment compounds. Every new constraint, pathway, or business rule added to the model automatically extends the generated evaluators, the manifest, and (once the Temporal generator extension is done) the running workflows. The marginal cost of adding the next pathway is lower than the first.

The most important work ahead is exercising the Knowledge layer at runtime (coffee shop increments), modelling a second clinical pathway to prove generalisation, and deepening the use of SysML v2's structural constructs (ports, use case composition, metadata specialisation) to increase the model's formal rigour and generator expressiveness.

The project is well-positioned, well-documented, and architecturally sound.

---

*Strategic snapshot prepared 11 March 2026, based on direct review of the complete `gsl-sysml-model` codebase, documentation corpus, and development history.*
