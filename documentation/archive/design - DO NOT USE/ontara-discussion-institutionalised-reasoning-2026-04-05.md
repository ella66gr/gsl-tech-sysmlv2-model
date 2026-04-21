---
tags:
  - architecture
  - discussion
  - reasoning
date: 2026-04-05
status: working
session: 146
---
# Institutionalised Reasoning: A Reasoning Metamodel for the Ontara Platform

*Ontara Platform — Discussion Paper*

**Date:** 5 April 2026 (Session 146)
**Purpose:** Architectural analysis of the reasoning, problem-solving, and heuristic capabilities that Ontara should host as first-class platform components. Establishes the conceptual framework for Stage 7.
**Status:** Working document — architectural exploration and design.
**Depends on:** [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture (Sessions 73–74)]], [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture (Session 121)]], [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture (Session 97)]], [[ontara-research-(perplexity) - reasoning-problem-solving-heuristics|Reasoning, Problem Solving, and Heuristics (Perplexity research)]], [[ontara-research-(perplexity) - probabilistic-reasoning|Probabilistic and Weighted Reasoning (Perplexity research)]]

---

## Contents

- [[#1. The Core Proposition|§1. The Core Proposition]]
- [[#2. What Ontara Already Has|§2. What Ontara Already Has]]
- [[#3. What the Research Proposes|§3. What the Research Proposes]]
- [[#4. Architectural Placement — Where Reasoning Lives|§4. Architectural Placement — Where Reasoning Lives]]
- [[#5. The Five Reasoning Clusters|§5. The Five Reasoning Clusters]]
- [[#6. Decision Mode Routing|§6. Decision Mode Routing]]
- [[#7. Heuristics as First-Class Objects|§7. Heuristics as First-Class Objects]]
- [[#8. Safety and Resilience Structures|§8. Safety and Resilience Structures]]
- [[#9. The Evidence and Explanation Cluster|§9. The Evidence and Explanation Cluster]]
- [[#10. Relationship to Existing Commitments|§10. Relationship to Existing Commitments]]
- [[#11. Probabilistic and Soft Reasoning Formalisms|§11. Probabilistic and Soft Reasoning Formalisms]]
- [[#12. Formalism Placement — OWL, SysML, or Runtime|§12. Formalism Placement — OWL, SysML, or Runtime]]
- [[#13. Cross-Domain Validation|§13. Cross-Domain Validation]]
- [[#14. Design Decisions|§14. Design Decisions]]
- [[#15. Open Questions|§15. Open Questions]]
- [[#16. Register Connections|§16. Register Connections]]

---

## 1. The Core Proposition

The Perplexity research paper proposes that Ontara should be understood as a platform for **institutionalised reasoning**: not just storing models and executing workflows, but hosting multiple explicit problem-solving regimes that can be selected, composed, constrained, audited, and learned from over time.

This is a significant reframing. The existing architecture treats reasoning as something that happens *within* specific system capabilities — the knowledge layer evaluates constraints (F1–F7), the governance vocabulary tracks obligations (B30–B35), the simulation architecture projects and seeks goals (L5–L9). What the research proposes is that these are all instances of a more general capability: **reasoning as a platform service**, with its own metamodel, its own vocabulary, and its own architectural position.

The implications are substantial. If reasoning is a first-class platform capability with its own metamodel, then:

- Every act of reasoning — whether a clinical decision, a resource allocation, a governance check, or a strategic projection — is a **typed, traceable, auditable object** in the knowledge graph.
- The platform can distinguish between different **kinds** of reasoning (deterministic rule application, expert judgement, hypothesis testing, constraint satisfaction, safety analysis) and select the appropriate regime for each problem type.
- **Heuristics** — the practical shortcuts and ordering principles that experts use — become declarative platform objects rather than procedural code buried in application logic.
- **Evidence and explanation** are first-class concerns, not afterthoughts. Every claim the system makes is linked to its evidential basis and can explain itself.
- **Provenance** — who reasoned what, when, using what knowledge, producing what conclusion — is structurally guaranteed, not retroactively assembled.

This is not an expansion of scope. It is a deepening of architectural commitment. The platform already claims to be self-describing ([[principle-self-describing-system|A2]]), to make governance a first-class concern ([[principle-clinical-governance-first-class|A8]]), and to use deterministic auditable reasoning ([[principle-deterministic-over-probabilistic|A6]]). The reasoning metamodel makes these claims structurally enforceable rather than aspirationally stated.

---

## 2. What Ontara Already Has

Before proposing new architecture, it is essential to map what already exists. The reasoning metamodel does not start from nothing — it organises, extends, and connects capabilities that are already committed or directionally established.

### 2.1 The three-tier reasoning stack (A6)

The earliest reasoning commitment: Tier 1 (constraints and safety checks — deterministic), Tier 2 (decision tables and Prolog — inspectable logic), Tier 3 (ML/LLM — advisory only, never authoritative for clinical decisions). This is a coarse classification of reasoning *modes*. The research paper's capability families are a much richer elaboration of the same insight: different problem types require different reasoning approaches.

### 2.2 The knowledge layer (F1–F7)

The five-layer SystemStateAssessment (F1) is already a reasoning architecture: observe (manifest, query Temporal/CDR), orient (goal-state projection from requirements), decide (gap analysis, deficit classification), act (remediation — automatic, recommended, or advisory). This maps directly onto the OODA loop structure that the research paper identifies as a core framework. The knowledge layer *is* a reasoning engine; it simply hasn't been recognised as an instance of a more general pattern.

### 2.3 The deontic governance vocabulary (B30–B35)

The governance workstream already provides a normative structure: obligations, permissions, prohibitions, source instruments, framework libraries, activation binding. The research paper's "Knowledge and Norms" cluster (KnowledgeArtifact, KnowledgeSource, Constraint, Policy, Guideline, RuleSet) overlaps substantially with what is already built in `ontara-governance.ttl`. The governance vocabulary is the normative layer of the reasoning metamodel — it already exists.

### 2.4 The simulation architecture (L5–L9)

The operational simulation (L5), reflective simulation (L6), valence (L7), coordinate space snapshots (L8), and goal-seeking computation (L9) form a reasoning architecture for the runtime layer. Goal-seeking computation is explicitly a constraint-satisfaction search over the coordinate space. The reflective simulation reads from all architectural layers and produces guidance. These are reasoning capabilities — they simply haven't been framed as instances of a typed reasoning metamodel.

### 2.5 Weighted relationships (B14) and the unity principle (A11)

The weighted relationship model is already a heuristic: "if A changes, how much does B need reassessment?" The five heuristics (H1–H5) governing weight assignment are already documented. The unity principle says one knowledge model informs comprehension, reasoning, simulation, governance, and assembly guidance. The reasoning metamodel is the structural realisation of this principle — it provides the framework within which the unity principle operates.

### 2.6 The coordinate framework (A12)

Coordinate space snapshots (L8) already distinguish five epistemic types: current, historical, goal, hypothetical, projected. This is precisely the research paper's "epistemic layer" — facts, claims, confidence, uncertainty. The coordinate framework provides the representational space; the reasoning metamodel provides the vocabulary for what happens *within* that space.

### 2.7 Reasoning formalisms research (M7)

M7 has been a horizon item since Session 46 — semiring soft-constraints, fuzzy MCDM, Probabilistic Soft Logic were identified as candidate formalisms for weighted reasoning. The reasoning metamodel provides the architectural framework within which M7's candidate formalisms would be deployed. M7 is not resolved by this paper, but it gains a home.

### 2.8 Summary: what's new vs what's reorganised

| Existing capability | Reasoning metamodel equivalent | Status |
|---|---|---|
| Three-tier reasoning stack (A6) | Decision mode routing | Extends — richer classification |
| Five-layer SystemStateAssessment (F1) | OODA decision cycle pattern | Reorganises — same structure, new framing |
| Governance vocabulary (B30–B35) | Normative structure (KnowledgeSource, Constraint, Policy) | Already built — connects directly |
| Simulation architecture (L5–L9) | Operational/runtime reasoning layer | Already committed — gains typed vocabulary |
| Weighted relationships (B14) | Heuristic layer primitive | Already built — recognised as heuristic |
| Coordinate framework (A12) | Epistemic layer / state space | Already committed — reasoning operates within it |
| Reasoning formalisms (M7) | Capability family deployment targets | Gains architectural home |
| **Evidence/explanation cluster** | **Claims, evidence lines, provenance** | **Genuinely new** |
| **Goal/obstacle model** | **Intentional structure** | **Genuinely new** |
| **STAMP/STPA safety structures** | **Safety reasoning beyond governance** | **Genuinely new** |
| **FRAM resilience modelling** | **Work-as-done vs work-as-imagined** | **Genuinely new** |
| **Decision mode routing (Cynefin)** | **Explicit context classification** | **Genuinely new** |
| **Heuristics as declarative objects** | **Heuristic packs** | **Genuinely new** |

The genuinely new elements cluster in three areas: (a) the evidence/explanation/provenance architecture, (b) the intentional structure (goals, obstacles, measures), and (c) the safety/resilience extension (STAMP/STPA, FRAM). Decision mode routing and heuristic packs are new mechanisms but address recognised needs.

---

## 3. What the Research Proposes

The research paper provides three progressively detailed views.

### 3.1 Capability families

Seven families of reasoning capability, each proposed as a platform service pattern:

1. **Goal formulation and decomposition** — goals, subgoals, success criteria, trade-offs, stop conditions.
2. **Search and planning** — constraint satisfaction, scheduling, pathway compliance, resource allocation.
3. **Diagnostic and explanatory reasoning** — hypothesis generation, evidence evaluation, differential pruning.
4. **Safety and risk reasoning** — control structures, hazard identification, unsafe control action detection.
5. **Sensemaking under uncertainty** — probe-sense-respond, hypothesis portfolios, adaptive monitoring.
6. **Governance and assurance** — policy resolution, approval gates, audit, monitoring.
7. **Heuristics** — goal ordering, resource, risk, diagnostic, coordination, and governance heuristics.

### 3.2 Core frameworks

Eight frameworks mapped to Ontara components: OODA loops (decision cycles), recognition-primed decision models (expert pattern matching), clinical reasoning support (hypothesis-driven), constraint satisfaction (scheduling, compliance), root cause analysis (incident investigation), STAMP/STPA (safety as constraint enforcement), FRAM (resilience and work-as-done), NIST AI RMF (AI governance). The key design principle: these are **composable**, not alternatives.

### 3.3 Proposed metamodel

Approximately 30 classes across five clusters: intentional (ReasoningContext, Goal, Obstacle, Measure, Risk), operational (Decision, Task, Plan, Action, State, Event), knowledge/norms (KnowledgeArtifact, KnowledgeSource, Constraint, Policy, Heuristic), evidence/explanation (Claim, EvidenceLine, EvidenceItem, Explanation, ConfidenceAssessment), and provenance/governance (ReasoningActivity, Agent, Role, Approval, AuditRecord). The paper provides both a UML view (for architectural communication) and an OWL view (for semantic implementation), with PROV-O alignment for provenance.

### 3.4 Four metamodel rules

1. Every Decision must have at least one KnowledgeSource or explicitly state that it is exploratory.
2. Every Claim that can affect care, allocation, or compliance must link to an EvidenceLine and a ReasoningActivity.
3. Every Goal should be vulnerable to explicit Obstacle analysis.
4. Every runtime artifact should be versioned and attributable to agents.

### 3.5 Four-layer meta-level separation

1. **Epistemic** — facts, claims, evidence, confidence, uncertainty.
2. **Intentional** — goals, obstacles, preferences, priorities, trade-offs.
3. **Operational** — decisions, tasks, plans, events, states, temporal constraints.
4. **Governance** — authorities, policies, roles, approvals, accountabilities, audit.

---

## 4. Architectural Placement — Where Reasoning Lives

This is the first major design question: where does the reasoning metamodel sit in the existing Ontara architecture?

### 4.1 Not a third meta model

The reasoning metamodel is not a third meta model alongside the BMM and SMM. It is an **extension of the SMM** — specifically, it elaborates the "Evaluation & Reasoning" capability group (B25, group 3) and parts of "Observation & Self-Knowledge" (group 4). The two-meta-model distinction (A4) is preserved: the BMM describes *what* a service business is; the SMM describes *how* the system works, including how it reasons.

However, the reasoning metamodel is distinctive within the SMM in that its classes are exercised by every BMM concern. Governance reasoning applies to GovernanceMapping (C5). Resource reasoning applies to ResourcePlanning (C3). Financial reasoning applies to FinancialPlanning (C4). Clinical reasoning applies to ServiceDelivery (C2). This makes it similar in character to Activity Awareness (C6) — a cross-cutting dimension rather than a concern-specific capability.

### 4.2 The dual-stack position

In the dual-stack architecture (B21):

- **Left stack (BMM):** The intentional structure (Goals, Obstacles, Measures) sits at the business instance level. Business goals are business content — they belong to the tenant's service model. The normative structure (governance obligations binding to BMM elements) already lives here via B32 (framework activation and obligation binding).

- **Right stack (SMM):** The reasoning infrastructure (ReasoningComponent types, Decision structures, Heuristic packs, Safety structures, Evidence architecture) sits in the SMM vocabulary and system instance levels. These are system capabilities, not business content.

- **Horizontal mappings:** A Goal (BMM) maps to a GoalDecomposer and PathwayPlanner (SMM). An Obligation (BMM/governance) maps to a ConstraintEnforcer and PolicyResolver (SMM). A ServiceOffering (BMM) maps to Decision and Plan structures (SMM) that govern how it is delivered.

- **Runtime layers:** ReasoningActivity instances, Claims, Evidence, and AuditRecords are operational simulation content — they exist in the bottom two layers of both stacks, governed by rules and constraints.

### 4.3 The knowledge graph position

In the three-stratum knowledge graph (B28):

- **Domain graph:** Reasoning metamodel classes as OWL vocabulary — `ontara-reasoning.ttl` or similar, following the pattern established by `ontara-governance.ttl` (B35). PROV-O alignment for provenance classes.
- **Correspondence graph:** Mapping records between SysML reasoning structures and OWL reasoning vocabulary.
- **Authority zones (B29):** OWL-authoritative for class axioms, property characteristics, and imported upper ontology alignment (PROV-O, SEPIO). SysML-authoritative for structural decomposition — which ReasoningComponent types exist, how they compose, what their interfaces are.

### 4.4 Proposed architectural position statement

**The reasoning metamodel is a cross-cutting extension of the SMM** that provides the typed vocabulary for all reasoning activity across the platform. It sits in the right-hand stack of the dual-stack architecture, in the SMM vocabulary layer, with horizontal mappings to BMM concerns at every level. Its OWL representation lives in the domain graph as a hand-authored ontology module (like `ontara-governance.ttl`), with PROV-O as an imported upper ontology for provenance classes.

---

## 5. The Five Reasoning Clusters

The research paper's five clusters map onto Ontara as follows.

### 5.1 Intentional cluster (Goals, Obstacles, Measures)

This is the **purpose** layer — what the system is trying to achieve and what blocks it.

**What's new:** Ontara currently has goal-related concepts scattered across multiple locations. Valence (L7) is the operator's conception of good vs bad. Goal-seeking computation (L9) searches for action sequences. GoalProjector (F5) projects financial goals. But there is no unified Goal metamodel — no formal structure for goal refinement, obstacle analysis, goal conflict, or measure evaluation.

**Ontara-specific design:** Goals in Ontara have a distinctive character because of the coordinate framework (A12). A Goal is not just a desired state — it is a **region in coordinate space** that the system is trying to reach or maintain. An Obstacle is a condition that constrains the trajectory. A Measure is a projection onto a specific axis. This is richer than the generic goal-oriented requirements engineering model because it inherits the temporal, epistemic, and multi-dimensional structure of the coordinate framework.

**Design implication:** The Goal class should reference coordinate space locations. Goal refinement is decomposition along coordinate axes. Obstacle analysis identifies constraints on trajectories. This connects L9 (goal-seeking computation) to the intentional cluster structurally, not just conceptually.

### 5.2 Operational cluster (Decisions, Tasks, Plans, States, Events)

This is the **action** layer — how reasoning translates into operational effect.

**What exists:** The five-layer SystemStateAssessment (F1) already provides observe-orient-decide-act structure. Temporal workflows (L5) are plan execution. The pathway model (D6) is task decomposition. Decision tables (F6) are typed decisions.

**What's new:** The research paper's contribution is **typing** these structures. Not just "a decision was made" but "a TriageDecision was made, requiring these inputs, using this knowledge artifact, authorised by this source, producing this claim with this evidence." The Decision Requirements Graph pattern from DMN is particularly relevant — it structures decisions into dependency graphs with explicit inputs, knowledge sources, and sub-decisions.

**Design implication:** The existing F1–F7 knowledge layer becomes one instance of the operational cluster. Clinical pathway decisions, resource allocation decisions, governance compliance decisions, and financial projection decisions are all typed Decision instances with different ReasoningComponent implementations.

### 5.3 Knowledge and norms cluster (KnowledgeArtifacts, Constraints, Policies, Heuristics)

This is the **authority** layer — what knowledge is used and what rules apply.

**What exists:** The governance vocabulary (B30–B35) covers normative instruments, obligations, and framework libraries. The PatternCatalogue is a knowledge artifact. The weighted relationship model is a knowledge structure. Clinical guidelines would be knowledge artifacts.

**What's new:** The explicit separation of **KnowledgeSource** (the authority — a policy body, a regulation, a clinical guideline committee) from **KnowledgeArtifact** (the executable logic — a rule set, a heuristic, a constraint). The governance vocabulary partially has this (NormativeInstrument is a source, DeonticDirective is an artifact), but the general pattern extends beyond governance to clinical knowledge, operational knowledge, and design knowledge.

**Design implication:** The governance vocabulary's existing class hierarchy becomes a subtype hierarchy within the broader Knowledge and Norms cluster. `ontara-gov:NormativeInstrument` is a specialisation of `KnowledgeSource`. `ontara-gov:DeonticDirective` is a specialisation of `KnowledgeArtifact`. No existing classes are displaced — they gain a parent framework.

### 5.4 Evidence and explanation cluster (Claims, EvidenceLines, Provenance)

This is the **justification** layer — why the system believes what it says.

**What's genuinely new:** Ontara currently has no formal evidence architecture. The governance vocabulary tracks *what* obligations exist and *whether* they are satisfied, but not the evidential basis for compliance assessments. The comprehension architecture explains *what the model contains*, but not *why a specific runtime conclusion was reached*. The three-tier reasoning stack (A6) requires auditability, but doesn't define what an audit trail looks like structurally.

**The SEPIO pattern:** The research paper draws on the Scientific Evidence and Provenance Information Ontology (SEPIO), which models claims, evidence lines (organised bodies of evidence), evidence items, methods, tools, and agents. Combined with PROV-O (entities, activities, agents), this gives a complete provenance architecture for reasoning.

**Design implication:** This is the largest genuinely new contribution. Every reasoning activity produces claims; every claim is supported by evidence lines; every evidence line traces to evidence items with provenance. In regulated care, this is the structural guarantee that the system can explain not just *what* it decided, but *why*, *using what knowledge*, *at what confidence level*, and *who was responsible*. This directly serves A2 (self-describing system), A6 (auditable reasoning), and A8 (governance as first-class concern).

### 5.5 Provenance and governance cluster (ReasoningActivities, Agents, Approvals, Audit)

This is the **accountability** layer — who did what, when, and with what authority.

**What exists:** PROV-O is already within Ontara's ontological reach (BFO/CCO/IAO stack). The governance vocabulary tracks source instruments. The audit evidence patterns from the coffee shop demonstrator (D16, D17, D18) established the principle.

**What's new:** Making PROV-O a structural import for the reasoning metamodel. Every ReasoningActivity is a `prov:Activity`. Every Decision, Claim, and KnowledgeArtifact is a `prov:Entity`. Every Agent is a `prov:Agent`. The `prov:wasGeneratedBy`, `prov:used`, `prov:wasAssociatedWith`, `prov:wasDerivedFrom` properties provide the provenance backbone.

**Design implication:** PROV-O should be added to the ontology import stack. This is an extension of the existing BFO → CCO/IAO → domain ontology pattern (B19), adding PROV as a platform-level import alongside CCO and IAO.

---

## 6. Decision Mode Routing

The research paper proposes a Cynefin-based decision mode selector as a first-class platform component. This is architecturally significant because it addresses a real gap: Ontara currently has no mechanism for declaring "this problem space requires exploratory reasoning" vs "this problem space requires deterministic rule application."

### 6.1 The four domains mapped to Ontara

| Cynefin domain | Ontara reasoning regime | Example |
|---|---|---|
| **Clear** | Deterministic rules, checklists, eligibility logic. Tier 1 of A6. | Medication interaction check, appointment eligibility, data validation |
| **Complicated** | Expert analysis, model-based trade-off, optimisation, simulation. Tier 2 of A6. | Treatment pathway selection, resource allocation optimisation, financial projection |
| **Complex** | Probe-sense-respond, hypothesis portfolios, adaptive monitoring, learning loops. | Novel clinical presentation, service redesign, emerging regulatory landscape |
| **Chaotic** | Emergency stabilisation, hard safety constraints, rapid escalation. | Critical incident response, safeguarding alert, system failure recovery |

### 6.2 Relationship to A6

The three-tier reasoning stack (A6) is a different cut of the same problem. A6 classifies by *mechanism* (deterministic, inspectable logic, probabilistic). Cynefin classifies by *problem character* (ordered vs unordered). Both classifications are needed:

- A Clear domain problem uses Tier 1 mechanisms.
- A Complicated domain problem uses Tier 2 mechanisms, possibly with Tier 3 advisory support.
- A Complex domain problem uses Tier 3 exploratory methods under Tier 1 safety constraints.
- A Chaotic domain problem uses Tier 1 hard constraints with rapid human escalation.

The decision mode selector combines both: problem domain determines which mechanisms are valid, and what the escalation and override paths are.

### 6.3 Implementation approach

Decision mode routing could be implemented as a property of ReasoningContext. Every reasoning episode declares (or inherits from its domain model) a context classification. The platform selects appropriate ReasoningComponent types based on this classification. This is a *platform-level* capability, not a per-tenant configuration — the platform knows what reasoning regimes it supports, and the domain model declares which regimes apply where.

---

## 7. Heuristics as First-Class Objects

The research paper identifies six classes of heuristic and proposes "heuristic packs" as attachable platform objects. This is architecturally interesting because Ontara already has heuristics — they just aren't represented as such.

### 7.1 What's already heuristic

- The five weight assignment heuristics (H1–H5) governing weighted relationships.
- The three remediation categories (F4) — "default to Recommended" is a heuristic.
- The validate-in-toy-domains principle (A5) is a development heuristic.
- The concentric rings of modelling rigour (B3) are heuristics for how much detail to model.

### 7.2 What the research paper adds

The proposal is to make heuristics **declarative, versionable, attachable objects** rather than implicit conventions. A Heuristic is a subclass of KnowledgeArtifact. It declares its applicability conditions, its ordering or selection logic, and its authority basis. Heuristic packs group related heuristics for a domain, regulatory context, or service line.

### 7.3 Ontara-specific heuristic families

| Family | Example | Current status |
|---|---|---|
| Goal ordering | Do prerequisite, high-risk, irreversible, or high-information-gain tasks first | Implicit in pathway design |
| Resource | Prefer scarce-resource preservation, continuity-preserving allocations | Not formalised |
| Risk | Escalate on red-flag combinations, uncertainty plus severity, vulnerable-population markers | Implicit in clinical practice |
| Diagnostic | Generate hypotheses broadly, prune using discriminating evidence | Implicit in clinical reasoning |
| Coordination | Minimise handoff count, maximise accountability continuity | Implicit in service design |
| Governance | Require human review when confidence is low, novelty is high, explanation is weak | Partially captured in F4 remediation categories |

### 7.4 Design implication

Heuristics should be representable in OWL (as instances with properties declaring applicability, ordering logic, and authority) and exercisable at runtime. A heuristic is not a hard constraint — it is a *preference ordering* that can be overridden with justification. This connects naturally to the evidence/explanation cluster: when a heuristic is overridden, the override is a ReasoningActivity with a Claim justifying the departure.

---

## 8. Safety and Resilience Structures

The research paper proposes STAMP/STPA and FRAM as platform capabilities. These go beyond the existing governance vocabulary.

### 8.1 STAMP/STPA — safety as constraint enforcement

STAMP (Systems-Theoretic Accident Model and Processes) treats safety as the enforcement of constraints across hierarchical control structures. STPA (System-Theoretic Process Analysis) identifies unsafe control actions. This is structurally richer than a risk register — it models the **control relationships** that maintain safety, and identifies how those controls can fail.

**Ontara relevance:** Healthcare is a control system. Clinicians control treatment. Governance bodies control clinicians. Policies control governance bodies. CQC controls healthcare providers. Each level has control actions that can be unsafe (provided when not needed, not provided when needed, provided too early/late, provided too long/short). STPA gives a systematic way to identify these failure modes.

**Relationship to existing architecture:** The governance vocabulary (B30–B35) models obligations. STAMP/STPA would model the **control structure** through which obligations are enforced, and the **failure modes** of that enforcement. This is complementary, not overlapping — the governance vocabulary says "you must do X"; the safety structure says "here are the ways the system could fail to ensure X happens."

### 8.2 FRAM — resilience and work-as-done

FRAM (Functional Resonance Analysis Method) models the gap between work-as-imagined (the process model) and work-as-done (what actually happens). It treats performance variability as normal, not deviant, and looks for resonance patterns where variabilities combine.

**Ontara relevance:** The operational simulation (L5) models work-as-imagined. FRAM would provide the vocabulary for modelling work-as-done and the gap between them. In healthcare, this gap is where most quality and safety issues live — the process says one thing, the actual practice is adapted to local conditions, and the adaptations sometimes combine in ways that produce harm.

**Design implication:** FRAM structures (functions, couplings, variability, adaptations) could be represented as a vocabulary extension in the domain graph, exercised during the reflective simulation (L6). The reflective simulation already "reads from all layers and produces guidance" — FRAM gives it a structured way to reason about performance variability and adaptation patterns.

### 8.3 Caution

Both STAMP/STPA and FRAM are substantial frameworks. The reasoning metamodel should provide the **architectural slots** for safety and resilience structures without committing to a specific implementation depth at this stage. The design should support these frameworks without requiring them to be fully built before other reasoning capabilities are usable.

---

## 9. The Evidence and Explanation Cluster

This is the largest genuinely new contribution and deserves detailed treatment.

### 9.1 Why evidence architecture matters

In regulated care, the ability to say "the system decided X" is necessary but insufficient. The system must also be able to say:

- **What knowledge was used** — which guideline, which policy, which rule set, which version.
- **What evidence was considered** — which observations, which prior cases, which computed findings.
- **What confidence level applies** — how strong is the evidential basis, are there countervailing considerations.
- **Who was responsible** — which agent (human or system) performed the reasoning, with what authority.
- **What alternatives were considered** — was this the only option, or were others rejected and why.

This is not a nice-to-have. It is the structural basis for clinical governance ([[principle-clinical-governance-first-class|A8]]), auditable reasoning ([[principle-deterministic-over-probabilistic|A6]]), and the self-describing system ([[principle-self-describing-system|A2]]).

### 9.2 The SEPIO + PROV-O pattern

The research paper proposes combining two established ontological patterns:

**SEPIO** (Scientific Evidence and Provenance Information Ontology) provides: Claims (interpreted propositions), EvidenceLines (organised bodies of evidence supporting or challenging a claim), EvidenceItems (individual pieces of evidence), Methods (how evidence was obtained), ConfidenceAssessment (how strong the evidence is).

**PROV-O** (W3C Provenance Ontology) provides: Entities (things that exist), Activities (things that happen), Agents (things that act), and the relationships between them: `wasGeneratedBy`, `used`, `wasAssociatedWith`, `wasDerivedFrom`, `wasAttributedTo`.

Combined, they provide a complete evidence-to-provenance architecture: a Claim is supported by EvidenceLines, generated by a ReasoningActivity, which used KnowledgeArtifacts and InputData, and was associated with an Agent.

### 9.3 Ontara-specific evidence architecture

In Ontara's context, this means:

- A **compliance assessment** (governance) produces a Claim ("Regulation 12(2)(a) is satisfied") supported by an EvidenceLine containing EvidenceItems (specific observations, audit records, documented procedures). The assessment is a ReasoningActivity associated with an Agent (the governance system or a human reviewer).

- A **clinical pathway decision** produces a Claim ("treatment continuation is indicated") supported by EvidenceLines containing clinical observations, guideline references, and prior case comparisons. The decision is a ReasoningActivity using specific KnowledgeArtifacts (the clinical guideline, the patient's care record).

- A **resource allocation decision** produces a Claim ("this staffing configuration is adequate") supported by EvidenceLines containing demand forecasts, capacity data, and regulatory requirements. The allocation is a ReasoningActivity constrained by Obligations (from the governance vocabulary) and Heuristics (from the heuristic layer).

### 9.4 Design implication

The evidence/explanation cluster should be implemented as an OWL module (`ontara-reasoning.ttl` or subdivided further) importing PROV-O and adopting SEPIO patterns. This extends the ontology import stack (B19) to: BFO → CCO/IAO → **PROV-O** → domain ontologies (governance, reasoning, domain identity).

---

## 10. Relationship to Existing Commitments

### 10.1 Principles honoured

| Principle | How the reasoning metamodel honours it |
|---|---|
| A1 (Separation of representation and execution) | Reasoning structures are represented in the model (OWL/SysML); execution happens in the operational simulation. Changes to reasoning capability happen in representation. |
| A2 (Self-describing system) | The evidence/explanation cluster makes the system's reasoning self-describing — it can explain what it decided, why, and with what confidence. |
| A3 (Model generates everything) | ReasoningComponent types are defined in the model; runtime reasoning instances are generated/guided by the model. |
| A4 (Two meta model distinction) | The reasoning metamodel extends the SMM. Goals and Obstacles sit in the BMM. Horizontal mappings connect them. |
| A6 (Deterministic/auditable reasoning) | The evidence architecture makes auditability structural. Decision mode routing ensures deterministic methods are used where required. |
| A8 (Governance as first-class concern) | The governance vocabulary connects directly to the reasoning metamodel's normative cluster. |
| A10 (Intrinsic self-knowledge) | Claims and Explanations are dynamically generated from reasoning activities, not stored as static text. |
| A11 (Unity principle) | The reasoning metamodel provides the single framework within which weighted relationships, governance constraints, simulation parameters, and comprehension traversals all operate. |
| A12 (Coordinate framework) | Goals are regions in coordinate space. Reasoning operates over coordinate space trajectories. |
| A13 (Multi-tenancy) | ReasoningComponent types and Heuristic packs are platform-level; their deployment is per-tenant configuration. |

### 10.2 Concepts extended

| Concept | How the reasoning metamodel extends it |
|---|---|
| M7 (Reasoning formalisms) | Gains an architectural home — semiring soft-CSP, fuzzy MCDM, and PSL deploy into typed ReasoningComponent slots (§11) |
| F1 (SystemStateAssessment) | Becomes one instance of the OODA decision cycle pattern |
| B25 group 3 (Evaluation & Reasoning) | Gains a typed vocabulary and metamodel structure |
| L6 (Reflective simulation) | Gains FRAM-style resilience analysis as a reasoning mode |
| L9 (Goal-seeking computation) | Connects to the formal Goal/Obstacle/Measure structure |
| B30–B35 (Governance vocabulary) | Governance becomes one instance of the normative cluster, with evidence/explanation traceability |

### 10.3 Potential tensions

| Tension | Resolution approach |
|---|---|
| A6 says "deterministic, never probabilistic for authoritative decisions." The reasoning metamodel includes complex/exploratory reasoning modes. | Preserved — Cynefin routing makes the boundary explicit. Complex-domain reasoning produces Claims with ConfidenceAssessments, not authoritative decisions. Authoritative clinical decisions still require deterministic paths. The distinction is structural, not aspirational. |
| A3 says "model generates everything." Some reasoning components are runtime-configured, not model-generated. | A3 applies to the *types*, not the *instances*. The model defines ReasoningComponent types and their interfaces; runtime instances are generated/instantiated from those types. Analogous to how the model defines part defs and domains instantiate parts. |
| The reasoning metamodel is large (~30 classes). Does it violate J3 (non-constraining)? | The metamodel defines vocabulary, not implementation. Deploying specific reasoning capabilities is incremental and modular. The architecture defines the slots; filling them is a series of future workstreams. |

---

## 11. Probabilistic and Soft Reasoning Formalisms

The [[ontara-research-(perplexity) - probabilistic-reasoning|Perplexity research on probabilistic and weighted reasoning]] identified three formalism families directly relevant to the reasoning metamodel. These are candidate implementations for M7 (reasoning formalisms) and must be architecturally accommodated — not as afterthoughts, but as first-class considerations that shape the metamodel's class structure.

### 11.1 The three formalism families

**Semiring soft-constraints** replace Boolean satisfaction with values from an abstract semiring (costs, probabilities, preferences). A single constraint logic framework can express classical CSPs, weighted CSPs, fuzzy CSPs, and optimisation over costs or preferences. This is the natural formalism for the Constraint class in the knowledge/norms cluster — but it means **Constraint must accommodate soft as well as hard constraints**. A hard constraint (obligation violation) and a soft constraint (cost preference) are structurally different: the first is a boundary that cannot be crossed; the second is a preference gradient that influences choice. The metamodel needs this distinction.

**Fuzzy MCDM** (multi-criteria decision-making) represents stakeholder judgements as fuzzy sets with membership degrees in [0,1] rather than hard thresholds. "Low risk", "acceptable delay", "high automation" become graded assessments that can be aggregated with weights and fuzzy operators. This is the natural formalism for the **complicated-domain** reasoning regime in the Cynefin classification (§6). When the platform needs to rank design alternatives or operational configurations using stakeholder judgements expressed linguistically, that is fuzzy MCDM — not deterministic rules (clear domain) and not exploratory sensemaking (complex domain). The discussion paper's Cynefin mapping in §6 should be understood as implying fuzzy MCDM as the specific mechanism for complicated-domain reasoning that involves human judgement.

**Probabilistic Soft Logic (PSL)** combines first-order rule templates with soft truth values in [0,1], solving for the most probable assignment via convex optimisation. PSL is the candidate for graded business rules — "if process is highly automated then staff load is low, unless exceptions are high." This sits between deterministic rules (Tier 1 of A6) and fully probabilistic inference (Tier 3 of A6), occupying a middle ground where rules have degrees of applicability rather than binary truth. The typed ReasoningComponent hierarchy should include a **SoftRuleEvaluator** or **GradedLogicComponent** type to accommodate this.

### 11.2 The three interpretive frames for weights

The probabilistic reasoning research identifies three interpretive frames for the weighted relationships that already exist in the platform (B14):

1. **Costs and preferences** — weights represent optimisation targets. Interpreted via semiring operations (min+, max×). Used for configuration search, trade-off analysis, resource allocation.
2. **Fuzzy human judgements** — weights represent degrees of membership or expert opinion. Interpreted via fuzzy operators. Used for multi-criteria ranking, stakeholder preference aggregation, linguistic assessment.
3. **Probabilities** — weights represent likelihoods. Interpreted via probabilistic logic. Used for clinical decision support, risk assessment, predictive analytics.

These frames are semantically distinct. A ConfidenceAssessment that represents a probability ("70% likelihood of successful outcome") is structurally different from one that represents a fuzzy membership degree ("moderately suitable") or a preference weight ("this option is preferred at strength 0.7"). The evidence/explanation cluster's ConfidenceAssessment class (§9) should carry an interpretive frame declaration so that downstream reasoning knows which mathematical operations are valid.

This connects directly to B14 (weighted relationships), which already notes that the weight model supports three interpretive frames. The reasoning metamodel makes this distinction structural rather than implicit.

### 11.3 The pragmatic reasoning stack

The probabilistic reasoning research proposes a concrete three-layer implementation architecture:

1. **Knowledge and preference model** — semiring soft-CSP model of the design/operational space, overlaid with fuzzy MCDM components capturing stakeholder value judgements.
2. **Projection and simulation** — simulate candidate configurations, feed simulation outputs into the soft-constraint and fuzzy layers for evaluation, ranking, and trade-off visualisation.
3. **Inferential self-knowledge** — sensitivity analysis (which preferences and constraints are most influential), targeted elicitation when preferences are underspecified ("if we must halve cost, are you willing to accept a 10% increase in patient waiting time?").

This three-layer stack maps directly onto the reasoning metamodel:

- Layer 1 maps to the **knowledge/norms cluster** (KnowledgeArtifacts including Constraints, Heuristics, and Policies) combined with the **intentional cluster** (Goals, Preferences, Measures).
- Layer 2 maps to the **operational cluster** (Decisions, Plans, Tasks) exercised within the **operational simulation** (L5) and evaluated by the **reflective simulation** (L6).
- Layer 3 maps to the **evidence/explanation cluster** (Claims, ConfidenceAssessments, Explanations) combined with **intrinsic self-knowledge** (A10) — the system can explain which constraints are driving its recommendations and what would change if preferences shifted.

### 11.4 Implications for the Constraint class

The Constraint class proposed in §5.3 must be revised to accommodate the hard/soft distinction:

- **HardConstraint** — a boundary that cannot be violated. Governance obligations (from the deontic vocabulary), safety constraints (from STAMP/STPA), deterministic eligibility rules. Violation is a system failure.
- **SoftConstraint** — a preference or cost that influences but does not determine choice. Attached to a semiring for combination (min+ for costs, max× for probabilities, fuzzy operators for judgements). Violation is a trade-off, not a failure.
- **GradedRule** — a PSL-style soft logical rule with a truth value in [0,1]. Neither a hard boundary nor a simple preference — a graded assertion about how the world works. Used for business rules that are "usually true" or "true to a degree."

This three-way distinction is essential. Without it, the platform conflates governance obligations (hard), stakeholder preferences (soft), and business heuristics (graded) — which is precisely the entanglement that the design principle in §3.4 ("separate hard constraints from soft preferences and from heuristics") warns against.

### 11.5 Implications for M7

M7 (reasoning formalisms) is no longer just a horizon item waiting for an architectural home. The reasoning metamodel provides the home, and the probabilistic reasoning research provides the candidate tenants:

- **Semiring soft-CSP** deploys into the Constraint/Heuristic layer for optimisation, trade-off analysis, and scenario comparison.
- **Fuzzy MCDM** deploys into the Decision layer for multi-criteria ranking under stakeholder judgement.
- **PSL** deploys as a GradedLogicComponent for soft business rules and graded inference.
- **Bayesian updating** deploys as BayesianUpdater, RiskCalculator, and PrognosticModel components for diagnostic reasoning, risk assessment, and predictive analytics (§11.6).
- **Tau Prolog** (F6, already validated) remains the Tier 2 deterministic logic engine for compound deficit reasoning and "why not" explanations.

The reasoning metamodel doesn't resolve M7 — it structures the space within which M7's candidates compete and compose. Each formalism has a typed slot; the platform can support multiple formalisms simultaneously for different reasoning contexts.

### 11.6 Bayesian reasoning, predictive modelling, and diagnostic probability

The formalisms discussed in §11.1–§11.5 address optimisation (semiring), vague judgement (fuzzy), and graded rules (PSL). But there is a fourth family that is architecturally distinct and clinically fundamental: **Bayesian reasoning** — the structured updating of beliefs in light of evidence.

#### Why Bayesian reasoning is architecturally distinct

Bayesian reasoning is not a variant of soft-constraint optimisation or fuzzy judgement. It is a different epistemic operation. The other formalisms answer "what is the best configuration?" or "how well does this option satisfy these criteria?" Bayesian reasoning answers a more fundamental question: **"given what I now know, how should I update what I believe?"**

In clinical medicine, this is the foundation of diagnostic reasoning. A clinician starts with a prior probability (prevalence, clinical suspicion based on presentation), observes evidence (test results, symptoms, history, examination findings), and computes a posterior probability using likelihood ratios. Pre-test probability → test with known sensitivity and specificity → post-test probability. This is how evidence-based medicine actually works at the point of care, and it is how Ontara must reason when supporting clinical decisions.

In gender medicine specifically, Bayesian reasoning applies to:

- **Monitoring decisions.** When to re-test hormone levels — the decision depends on prior levels, expected trajectory, individual variation, and the discriminating power of the test at different time points. A deterministic rule ("re-test at 3 months") ignores all of this.
- **Risk stratification.** Cardiovascular risk modelling on hormone therapy — validated risk calculators (QRISK, Framingham) produce probabilistic outputs that are updated as new data accumulates. The risk is not a fixed category; it is a posterior probability that shifts with each new observation.
- **Treatment response prediction.** Individual response to hormonal treatment varies. A Bayesian approach represents the population response as a prior, updates with the individual's observed response, and produces a posterior estimate that guides dose adjustment.
- **Differential diagnosis.** When a patient presents with symptoms that could have multiple causes, diagnostic reasoning is inherently Bayesian — each piece of evidence shifts the probability distribution across candidate explanations.

#### Architectural position within the reasoning metamodel

Bayesian reasoning occupies a specific position that the current three-tier reasoning stack (A6) handles poorly:

- **Tier 1** (deterministic rules) cannot represent probability. It can say "if X then Y" but not "X increases the probability of Y by a factor of 3.5."
- **Tier 2** (decision tables, Prolog) can encode logic but not probabilistic updating. Tau Prolog can do "why not" explanations but not "how likely."
- **Tier 3** (ML/LLM — advisory only) is too broad. Validated risk calculators are not "ML" in the unconstrained sense — they are structured probabilistic models with known performance characteristics, published validation data, and clinical governance around their use.

The reasoning metamodel needs a position between Tier 2 and Tier 3 — call it **structured probabilistic reasoning**. These are models that:

- Have explicit mathematical structure (Bayes' theorem, logistic regression, Cox proportional hazards, survival models).
- Produce probabilistic outputs with known uncertainty characteristics.
- Are validated against defined populations with published performance metrics (sensitivity, specificity, calibration, discrimination).
- Are updatable with new evidence in a principled way (prior → evidence → posterior).
- Are *not* opaque ML models — their structure is inspectable and their assumptions are explicit.

This is consistent with A6's intent. A6 says "clinical decisions use inspectable, deterministic logic — never probabilistic inference for *authoritative* decisions." The key word is "authoritative." A Bayesian risk calculator does not make the authoritative decision — the clinician does. But the calculator provides structured probabilistic evidence that informs the decision, and the platform must be able to represent, execute, and trace that reasoning.

#### Typed components for probabilistic reasoning

The ReasoningComponent hierarchy (discussed in S146-Q5) should include:

- **BayesianUpdater** — takes a prior probability and evidence with known likelihood ratios, produces a posterior probability. Used for diagnostic reasoning, monitoring decision support, and risk assessment.
- **RiskCalculator** — a validated population-level risk model (QRISK, Framingham, etc.) that takes patient characteristics and produces a risk probability with confidence intervals. A subtype of BayesianUpdater with additional metadata: validation population, performance metrics, clinical governance status, version.
- **PrognosticModel** — a time-to-event or trajectory model (survival analysis, growth curve modelling) that produces probabilistic predictions about future states. Used for treatment response prediction, disease progression modelling, and resource demand forecasting.
- **PredictiveAnalytics** — population-level probabilistic analysis (cohort risk profiles, outcome prediction, demand modelling). Distinct from individual-level clinical reasoning but using the same probabilistic formalism.

These are all deterministic in their *mechanism* (given the same inputs and model, they produce the same outputs) but probabilistic in their *output* (the output is a probability, not a binary decision). This is the distinction A6 needs to accommodate: the reasoning process is inspectable and reproducible; the output is a probability that informs rather than replaces clinical judgement.

#### Connection to the evidence architecture

Bayesian reasoning connects naturally to the SEPIO-pattern evidence architecture (§9):

- A **prior probability** is itself a Claim with an EvidenceLine (population prevalence data, clinical judgement, previous assessments).
- **Test results and observations** are EvidenceItems that shift the probability.
- The **posterior probability** is a new Claim generated by a ReasoningActivity (the BayesianUpdater), with full provenance: what prior was used, what evidence was incorporated, what model was applied, what the resulting probability is.
- The **ConfidenceAssessment** on the posterior Claim carries an interpretive frame of "probability" (per §11.2), distinguishing it from fuzzy membership or preference weight. It may also carry uncertainty bounds (credible intervals, confidence intervals) as additional properties.

This gives clinical reasoning full traceability: the system can show not just "the cardiovascular risk is 12%" but "the risk was estimated at 12% using QRISK3 (v2024.1), based on these inputs [listed], updating a prior of 8% from the previous assessment on [date], with a 95% confidence interval of 9–16%." That level of reasoning transparency is what A2 (self-describing system) and A8 (governance as first-class concern) demand in a clinical context.

#### Relationship to the coordinate framework

Bayesian reasoning has a natural expression in the coordinate framework (A12). A prior probability defines a probability distribution over a region of coordinate space. Evidence narrows that distribution. The posterior is a refined distribution — a more precise location in the space. Sequential Bayesian updating is a trajectory through probability space, where each observation moves the distribution.

This connects to coordinate space snapshots (L8): a snapshot with epistemic type "predicted" carries a probability distribution, not a point estimate. Goal-seeking computation (L9) over probabilistic states becomes optimisation under uncertainty — finding action sequences that maximise the probability of reaching the goal region. This is substantially richer than deterministic goal-seeking, and it is what clinical decision support actually requires.

#### Design implication

The probabilistic reasoning capability should be represented as:

- **OWL vocabulary** — classes for BayesianUpdater, RiskCalculator, PrognosticModel, PredictiveAnalytics within the reasoning metamodel. Properties for prior, posterior, likelihood, confidence interval, validation metadata.
- **SysML structure** — ReasoningComponent subtypes with interfaces declaring required inputs (prior, evidence, model parameters) and outputs (posterior, confidence, explanation).
- **Runtime** — ReasoningActivity instances recording each probabilistic computation with full PROV-O provenance.

This gives Bayesian reasoning architectural parity with deterministic rules, soft constraints, and fuzzy judgement — not as an afterthought permitted by a single-sentence caveat in A6, but as a first-class reasoning capability with its own typed components, its own evidence trail, and its own place in the metamodel.

---

## 12. Formalism Placement — OWL, SysML, or Runtime

Following the dual-formalism architecture (B23, B29), each element of the reasoning metamodel needs explicit formalism placement.

### 12.1 OWL-authoritative elements

- Class axioms for reasoning metamodel types (ReasoningContext, Goal, Decision, Claim, etc.)
- Property characteristics (domain, range, cardinality)
- PROV-O import and subclass declarations
- SEPIO-pattern evidence structures
- Heuristic type taxonomy
- Integration with governance vocabulary (`ontara-gov:` namespace)

### 12.2 SysML-authoritative elements

- Structural decomposition of ReasoningComponent types
- Interface definitions between reasoning components
- Configuration of which components are available per domain
- Metadata annotations linking reasoning components to BMM concerns

### 12.3 Runtime elements (neither OWL nor SysML — operational data)

- ReasoningActivity instances (provenance records)
- Claims and EvidenceLines (produced at runtime)
- Decision records (audit trail)
- Coordinate space state during reasoning

### 12.4 Shared-constrained elements

- Labels, definitions, and annotations on reasoning classes
- Goal/Obstacle definitions (authored in BMM, semantically validated in OWL)

---

## 13. Cross-Domain Validation

Following A5 (validate in toy domains first) and J1 (cross-domain validation), the reasoning metamodel must validate in at least two demonstrator domains.

### 12.1 Cafe demonstrator

| Reasoning capability | Cafe exercise |
|---|---|
| Decision (TriageDecision) | Order priority determination: rush orders, complex customisations, large groups |
| Constraint (scheduling) | Barista availability, equipment capacity, ingredient stock |
| Goal/Obstacle | Goal: fulfil all orders within SLA. Obstacle: equipment failure, staff absence |
| Heuristic (resource) | Prefer continuity — same barista completes the drink they started |
| Evidence/Claim | Claim: "order fulfilled within SLA." Evidence: timestamps, workflow completion record |

### 12.2 Suds demonstrator

| Reasoning capability | Suds exercise |
|---|---|
| Decision (EligibilityDecision) | Fabric type determines wash programme — rule-based eligibility |
| Constraint (COSHH compliance) | Chemical handling constraints on process sequencing |
| Safety (STAMP-lite) | Control structure: operator controls machine settings, COSHH governs operator, HSE governs COSHH |
| Heuristic (goal ordering) | Do high-temperature washes first (energy efficiency), do delicates last (reduced risk) |
| Evidence/Claim | Claim: "COSHH requirements satisfied for this batch." Evidence: chemical inventory, operator training record |

### 12.3 GSL (production tenant)

The full evidence/explanation architecture is most needed here. Clinical pathway decisions, governance compliance assessments, treatment continuation decisions, and resource allocation all require the complete reasoning metamodel with formal evidence trails, confidence assessments, and provenance.

---

## 14. Design Decisions

The following design decisions are proposed for resolution during this session or carried forward to the Stage 7 plan.

### S146-D1: Architectural placement of reasoning metamodel

**Proposed:** The reasoning metamodel is a cross-cutting extension of the SMM, not a third meta model. It extends SMM capability group 3 (Evaluation & Reasoning) and provides typed vocabulary for all reasoning activity.

**Rationale:** Preserves A4 (two meta model distinction). Reasoning is *how the system works*, not *what a business is*. Goals and Obstacles are BMM-side (business content); ReasoningComponents are SMM-side (system capability). Horizontal mappings connect them.

### S146-D2: PROV-O as platform-level ontology import

**Proposed:** Add PROV-O (W3C Provenance Ontology) to the ontology import stack at platform level, alongside CCO and IAO.

**Rationale:** PROV-O provides the standard vocabulary for entities, activities, agents, and their relationships. Reasoning metamodel classes subclass PROV-O classes. This is consistent with the ontology stack pattern (B19) and the authority zone approach (B29).

### S146-D3: Separate OWL module for reasoning vocabulary

**Proposed:** Create `ontara-reasoning.ttl` as a hand-authored OWL module in `ontology/reasoning/`, following the pattern established by `ontara-governance.ttl` (B35).

**Rationale:** Consistent with the existing architecture. Separate namespace (`ontara-reasoning:` or `ontara-rsn:`). OWL-authoritative for class axioms and property characteristics. Lives in the domain graph (B28).

### S146-D4: Goal/Obstacle model uses coordinate space references

**Proposed:** Goals reference coordinate space regions (A12). Obstacles are constraints on trajectories. Measures are projections onto coordinate axes. This grounds the intentional cluster in the coordinate framework rather than treating it as an independent structure.

**Rationale:** The coordinate framework is already committed as a T1 candidate. Goals, obstacles, and measures gain dimensional structure from it. Goal-seeking computation (L9) becomes structurally connected to the formal Goal class.

### S146-D5: Decision mode routing via ReasoningContext classification

**Proposed:** Decision mode (clear/complicated/complex/chaotic) is a property of ReasoningContext, not a separate routing service. ReasoningContexts inherit classification from their domain model position or receive it through explicit declaration.

**Rationale:** Keeps the classification close to the reasoning episode. Avoids a separate routing infrastructure. The domain model declares "clinical pathway exceptions are complex-domain problems"; the platform activates appropriate reasoning components based on this declaration.

### S146-D6: Heuristics as OWL individuals with typed properties

**Proposed:** Heuristics are represented as OWL individuals (instances of `ontara-rsn:Heuristic` subclasses) with properties declaring applicability conditions, ordering logic, and authority basis. Heuristic packs are collections of heuristics attachable to domains, service lines, or regulatory contexts.

**Rationale:** Makes heuristics first-class knowledge graph citizens. Versionable, queryable, traceable. Override of a heuristic is a ReasoningActivity with provenance.

### S146-D7: Evidence architecture adopts SEPIO pattern

**Proposed:** Claims, EvidenceLines, and EvidenceItems follow the SEPIO (Scientific Evidence and Provenance Information Ontology) structural pattern, adapted for Ontara's domain. Not a direct SEPIO import (SEPIO is biomedical-focused), but the structural pattern of claim → evidence line → evidence items with methods and confidence.

**Rationale:** SEPIO provides a well-tested pattern for structured evidence. Combining with PROV-O gives complete evidence-to-provenance traceability. Adapted rather than imported because Ontara's evidence domain spans clinical, governance, operational, and financial reasoning, not just biomedical.

### S146-D8: Three-way constraint distinction (hard, soft, graded)

**Proposed:** The Constraint class is split into three subtypes: HardConstraint (boundary that cannot be violated — governance obligations, safety constraints), SoftConstraint (preference or cost that influences but does not determine choice — attached to a semiring for combination), and GradedRule (PSL-style soft logical rule with truth value in [0,1]). This distinction is structural, not notional.

**Rationale:** The [[ontara-research-(perplexity) - probabilistic-reasoning|probabilistic reasoning research]] identifies three formalism families that require structurally different constraint representations. Conflating governance obligations, stakeholder preferences, and graded business rules is the entanglement the reasoning metamodel is designed to prevent. The three-tier reasoning stack (A6) already makes a coarser version of this distinction; D8 makes it explicit in the metamodel.

---

## 15. Open Questions

### S146-Q1: Scope of Stage 7

How much of the reasoning metamodel should Stage 7 implement? Candidates for phasing:

- **Phase 1 (Foundation):** Core classes (ReasoningContext, Goal, Decision, Claim), PROV-O import, evidence architecture. OWL module structure.
- **Phase 2 (Depth):** Heuristic packs, decision mode routing, constraint satisfaction integration.
- **Phase 3 (Safety/Resilience):** STAMP/STPA structures, FRAM patterns.
- **Phase 4 (Console):** Reasoning explorer view, evidence browser, decision trace visualisation.

### S146-Q2: Relationship to A6 evolution

Should A6 (deterministic/auditable reasoning) be reformulated in light of the reasoning metamodel? The current formulation is mechanism-focused (three tiers). The reasoning metamodel provides a richer framework. Should A6 remain as is (a specific principle about clinical decisions) while the reasoning metamodel provides the general framework?

### S146-Q3: PROV-O import scope

PROV-O is a W3C standard with a large vocabulary. What subset is needed? Minimum: `prov:Entity`, `prov:Activity`, `prov:Agent`, plus core properties (`wasGeneratedBy`, `used`, `wasAssociatedWith`, `wasDerivedFrom`, `wasAttributedTo`). Is a larger subset needed, or is the core sufficient?

### S146-Q4: Naming — "Reasoning" or something else?

"Institutionalised Reasoning" is descriptive but long. The OWL module needs a namespace. Candidates: `ontara-reasoning:`, `ontara-rsn:`, `ontara-reason:`. The register section needs a letter. Current sections go to O; reasoning could be P (Reasoning and Problem-Solving Concepts) or integrated into existing sections (B for structural concepts, L for simulation-adjacent).

### S146-Q5: Typed ReasoningComponent hierarchy

The research paper proposes a detailed subtype hierarchy (DecisionComponent → TriageDecision, PlanningComponent → PathwayPlanner, etc.). How deep should the initial hierarchy go? Start with the abstract types and let the hierarchy emerge through use (J12 — design decision lifecycle), or define the full taxonomy upfront?

### S146-Q6: Relationship to the Evaluation & Reasoning capability group (B25)

B25 defines six SMM capability groups. Group 3 is "Evaluation & Reasoning." The reasoning metamodel substantially elaborates this group. Should B25 be updated to reference the reasoning metamodel? Should the capability group structure be revised?

### S146-Q7: FRAM and work-as-done

FRAM is conceptually attractive but architecturally complex. Should the reasoning metamodel provide FRAM-ready slots without committing to a specific FRAM implementation? Or should FRAM be deferred entirely and addressed in a separate workstream?

---

## 16. Register Connections

### 15.1 Existing concepts exercised or extended

| Concept | How exercised/extended |
|---|---|
| A2 (Self-describing system) | Evidence/explanation cluster makes reasoning self-describing |
| A4 (Two meta model distinction) | Reasoning metamodel positioned as SMM extension |
| A6 (Deterministic/auditable reasoning) | Decision mode routing makes A6 structurally enforceable |
| A8 (Governance as first-class concern) | Governance vocabulary connects to reasoning metamodel |
| A11 (Unity principle) | Reasoning metamodel provides the unified framework |
| A12 (Coordinate framework) | Goals as coordinate space regions |
| B21 (Dual-stack architecture) | Reasoning sits in right stack with horizontal mappings |
| B25 (SMM capability groups) | Elaborates group 3 (Evaluation & Reasoning) |
| B28 (Three-stratum KG) | Reasoning vocabulary in domain graph |
| B29 (Authority zones) | OWL-authoritative for class axioms |
| B30–B35 (Governance vocabulary) | Governance becomes normative cluster instance |
| F1 (SystemStateAssessment) | Becomes OODA decision cycle instance |
| L5–L9 (Simulation architecture) | Gains typed reasoning vocabulary |
| M7 (Reasoning formalisms) | Gains architectural home |

### 15.2 Candidate new concepts for registration

| Proposed code | Concept | Tier | Summary |
|---|---|---|---|
| B40 | Reasoning metamodel | T2 | Cross-cutting SMM extension providing typed vocabulary for all reasoning activity |
| B41 | Evidence architecture (SEPIO + PROV-O) | T2 | Structured evidence-to-provenance traceability for all reasoning |
| B42 | Decision mode routing | T2 | Cynefin-based problem classification determining reasoning regime selection |
| B43 | Heuristic layer | T2 | Declarative heuristics as first-class platform objects |
| B44 | Intentional structure (Goals/Obstacles) | T2 | Formal goal decomposition, obstacle analysis, and measure evaluation |
| B45 | Safety and resilience structures | T3 | STAMP/STPA and FRAM-ready architectural slots |
| B46 | Structured probabilistic reasoning | T2 | Bayesian updating, validated risk calculators, prognostic models as first-class reasoning components with full evidence traceability |

---

*Discussion paper produced Session 146, 5 April 2026. Informed by [[ontara-research-(perplexity) - reasoning-problem-solving-heuristics|Perplexity research on reasoning, problem solving, and heuristics]] and [[ontara-research-(perplexity) - probabilistic-reasoning|Perplexity research on probabilistic and weighted reasoning]]. This paper establishes the conceptual framework for Stage 7 and proposes eight design decisions (S146-D1 to D8) and seven open questions (S146-Q1 to Q7) for resolution.*
