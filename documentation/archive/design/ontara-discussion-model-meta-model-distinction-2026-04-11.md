---
tags:
  - discussion
  - architecture
  - terminology
date: 2026-04-11
status: working
session: 195
---
# Model and Meta Model: Clarifying the Architectural Representation

> `= this.file.path`

*Ontara Platform — Discussion Paper*
**Date:** 11 April 2026 (Session 195)
**Status:** Working document — captures discussion state, does not resolve all uncertainties

---

## Contents

- [[#1. Context and Purpose|§1. Context and Purpose]]
- [[#2. The Terminological Problem|§2. The Terminological Problem]]
- [[#3. Definitions|§3. Definitions]]
- [[#4. The Architectural Representation Gap|§4. The Architectural Representation Gap]]
- [[#5. The Operator's Perspective|§5. The Operator's Perspective]]
- [[#6. Configuration and Runtime State|§6. Configuration and Runtime State]]
- [[#7. Open Questions and Uncertainties|§7. Open Questions and Uncertainties]]
- [[#8. Proposed Next Steps|§8. Proposed Next Steps]]
- [[#9. Register Connections|§9. Register Connections]]
- [[#Related Documents|Related Documents]]

---

## 1. Context and Purpose

This paper captures a terminological and architectural clarification that emerged during Session 195 planning discussions for Stage 9 (connecting the stacks). The discussion began with Q1 from the [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] paper — "where does BMM runtime state live?" — but immediately revealed a more fundamental problem: the terminology itself was imprecise, and the current architecture diagram does not unambiguously represent all the concepts that need to be represented.

The [[ontara-discussion-architectural-campus-walk-2026-03-28|Architectural Campus Walk]] (Sessions 84–85) was a significant piece of architectural work that captured important ideas and ways of thinking. However, as is the nature of evolving complex ideas, some ambiguities were not visible at the time. This paper identifies those ambiguities and prepares the ground for resolving them.

### 1.1 Why this matters

The dual-stack architecture is load-bearing for the entire Ontara platform. If the terminology is imprecise — if "BMM" and "business model" are used interchangeably when they refer to different things — then architectural discussions will be confused, implementation will be inconsistent, and the operator's understanding of the system will be compromised.

Stage 9 (connecting the stacks) cannot proceed until the architectural representation is unambiguous. Specifically:

- Where BM runtime state lives (the original Q1) cannot be answered until BM is properly situated in the architecture
- How horizontal runtime mappings work (Q2) cannot be designed until SM and BM are clearly distinguished from SMM and BMM
- What "module derived from model" means (Q3) cannot be specified until we know which model we're deriving from

---

## 2. The Terminological Problem

The Campus Walk document titles the left stack as "The Left Stack — Business Model" and the right stack as "The Right Stack — Business System Model." However, examination of the actual sections described reveals a conflation of two distinct levels:

**The meta model level** — vocabulary and structure; what kinds of things CAN exist

**The model level** — actual models of THIS business and THIS system; what things DO exist and how they ARE right now

The terminology "BMM" (Business Meta Model) and "SMM" (System Meta Model, formerly "BSMM") correctly identifies the meta model level. But the Campus Walk uses "business model" and "business system model" loosely to describe entire stacks that include both meta model content and model content.

This is not a pedantic distinction. A meta model is a vocabulary — a set of templates and structural rules. An actual model is an instantiation of that vocabulary for a specific business or system. The operator has a "business model" in mind (what they tell the bank manager); this is not the same as the BMM, which is the vocabulary that structures how that business model is represented.

---

## 3. Definitions

The following definitions are proposed to establish terminological clarity. They should be used consistently in all subsequent architectural discussion.

### 3.1 Meta model terms

| Term                | Abbreviation | Definition                                                                                                                                                                                                    |
| ------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Business Meta Model | BMM          | The vocabulary and structural templates that define what kinds of business concepts can exist. The 34 `part def`s across six concerns. Domain-neutral. This is meta model content.                            |
| System Meta Model   | SMM          | The vocabulary and structural templates that define what kinds of system concepts can exist. The six capability groups ([[concept-smm-general-vocabulary\|B25]]). Domain-neutral. This is meta model content. |

### 3.2 Model terms

| Term | Abbreviation | Definition |
|---|---|---|
| Business Model | BM | The actual model of THIS specific business. Not a meta model. What this business IS and how it IS right now. Instantiates the BMM vocabulary. Domain-specific (Cafe, Paws, GSL, etc.). |
| System Model | SM | The actual model of THIS specific system. Not a meta model. What this system IS and how it IS right now. Instantiates the SMM vocabulary. Domain-specific. |

### 3.3 Terminological note: "Business System Model"

The Campus Walk uses "Business System Model" for the right stack. This was intended to mean "the model of the systems used by the business" (hence "business system" as a compound). For economy of expression, this paper uses "System Model" (SM). The meaning is preserved: SM is the model of the systems that realise this business's operations.

### 3.4 The meta model / model distinction

A meta model defines vocabulary and structure. A model uses that vocabulary and structure to represent something specific.

| Level | Left Stack | Right Stack |
|---|---|---|
| Meta model | BMM — what kinds of business concepts can exist | SMM — what kinds of system concepts can exist |
| Model | BM — what THIS business actually is | SM — what THIS system actually is |

This distinction is already implicit in the Campus Walk's separation of "BMM General Vocabulary" (Section 3) from "Business Instance" (Section 4). But the distinction is not carried through consistently, and the architecture diagram does not clearly show BM and SM as first-class architectural concepts.

---

## 4. The Architectural Representation Gap

Examining the current architecture diagram (the console's Platform Architecture map, 20 sections across 6 groups), several observations emerge:

### 4.1 What the diagram shows

**Left stack (top to bottom):**
- BFO — shared upper ontology
- Domain Ontologies — OWL 2 DL, Implemented
- BMM General Vocabulary — SysML v2, Implemented; "maps to" relationship to SMM
- Business Instance — SysML v2, Implemented; "realised by" relationship to System Instance
- Operational Domains — SysML v2, Designed; "realised by" relationship to System Domains
- Business Process Patterns — SysML v2, Designed; "executed as" relationship to Operational Simulation

**Right stack (top to bottom):**
- System Ontological Categories — OWL 2 DL, Referenced
- SMM General Vocabulary — SysML v2, Designed
- System Instance — SysML v2, Designed
- System Domains — SysML v2, Designed
- Operational Simulation — Runtime, Designed

**Cross-cutting:**
- Reflective Simulation — Mixed, Designed (positioned to the right, reading from multiple layers)

**Rules & Constraints Container:**
- Wraps Operational Domains, Business Process Patterns, System Domains, and Operational Simulation
- Rules and Constraints section at the bottom

**Infrastructure:**
- Terminology and Information Carriers, Mapping Ontology, Knowledge Graph, SysML v2, openEHR, Temporal
- Operator at the bottom

### 4.2 What the diagram does NOT clearly show

**The Business Model (BM) as a first-class concept.** The diagram shows "Business Instance" (Section 4) which might be part of BM, but:
- Where does BM runtime state live? (Today's revenue, current inventory, customer relationships)
- Is BM = Business Instance + something else?
- The accumulated, dynamic facts about how the business actually IS right now are not clearly situated

**The System Model (SM) as a first-class concept.** The diagram shows "Operational Simulation" (Section 11) marked as Runtime, which might be SM or SM runtime state, but:
- The connection between Operational Simulation and actual execution agents (Temporal, apps, humans) is architecturally implicit
- Temporal sits in Infrastructure, somewhat disconnected from the stack above
- Is SM = System Instance + Operational Simulation? Or something else?

**The horizontal runtime mappings.** The Connecting the Stacks paper (Q2, [[ontara-ref-observation-watchpoint-register|OW-33]]) identifies that when an SM event occurs (workflow completes), it should update BM state (increment revenue, update inventory). This event-driven connection is not represented in the diagram.

**The relationship between model and execution.** The operator's question "is this a model OF execution, or IS it the execution?" is not architecturally resolved. If SM is a model of what the system is doing, then execution happens somewhere else. If SM IS the execution, then there's no separation between model and reality.

### 4.3 The "Business Process Patterns" ambiguity

The Campus Walk describes Business Process Patterns (Section 6) as operating at "three abstraction levels: archetypes (universal), patterns (BMM-parameterised), and instances/sketches (domain-specific)."

This is confusing because:
- Archetypes are universal — this is meta model content
- Patterns are BMM-parameterised — this is also meta model content (using meta model vocabulary)
- Instances/sketches are domain-specific — this is model content

So Section 6 spans both meta model and model levels. This is not necessarily wrong, but it complicates the question of what belongs to BM.

### 4.4 The "Operational Simulation" question

The Campus Walk describes Operational Simulation (Section 11) as "the bottom of the right stack — where the system is live" and "the SMM made operational."

Is this:
- SM runtime state (the live execution facts)?
- SM itself at runtime (the whole system model running)?
- The actual execution happening (not a model of it)?

The phrase "SMM made operational" suggests the meta model vocabulary instantiated and running. But what we need is the SM (model, not meta model) at runtime — the live state of THIS system.

---

## 5. The Operator's Perspective

A useful grounding for this discussion is the operator's perspective.

The operator (Sam, for Paws; Ella, for GSL) has a "business model" in mind. This is what they tell the bank manager, what they explain to their family, what guides their daily decisions. It includes:

- What services they offer
- Who their customers are
- How they price and deliver
- What resources they have
- How the business is performing (revenue, costs, growth, customer satisfaction)

This mental model is the BM. It is not a meta model — it is the actual model of THIS business.

Ontara should embody this BM as a concrete architectural construct. The operator should be able to query "how is my business doing?" and receive answers in business language, sourced from BM runtime state.

Similarly, the operator has a mental model of "the system" — the technology and processes that run the business. Bookings come through a website. Payments are processed electronically. Staff schedules are managed. This is the SM — the model of how THIS business's systems work.

When the system does something (processes a payment, completes a groom), that action should:
1. Be tracked in SM runtime state (workflow completed, transaction recorded)
2. Flow through to BM runtime state (revenue incremented, customer history updated)

This is the event-driven horizontal runtime mapping: SM events trigger BM updates.

---

## 6. Configuration and Runtime State

One framing that emerged from the discussion is that each actual model (BM, SM) has two aspects:

### 6.1 Configuration

The static structure — decisions, relationships, constraints, what this business/system has been configured to be. This is established at design time and changes relatively slowly.

For BM: The five service offerings, the pricing rules, the staff roster, the room assignments — what Paws has decided to be.

For SM: The workflow configurations, the integration endpoints, the database choices, the access control policies — how Paws's systems are configured.

### 6.2 Runtime state

The live, dynamic facts — current values, active processes, accumulated measures. This changes continuously during operation.

For BM: Today's revenue, current inventory levels, customer relationships, orders served — how Paws actually IS right now.

For SM: Active workflows, queue depths, processing times, resource utilisation — what Paws's systems are doing right now.

### 6.3 The relationship

This framing suggests:

- **BM = BM Configuration + BM Runtime State**
- **SM = SM Configuration + SM Runtime State**

Whether this is the correct framing is an open question. The Campus Walk's "Business Instance" (Section 4) might be BM Configuration. The "Operational Simulation" (Section 11) might be SM Runtime State. But:

- Where is BM Runtime State?
- Is "Business Instance" exactly BM Configuration, or does it include other content?
- What is the relationship between SM Runtime State and execution?

---

## 7. Open Questions and Uncertainties

The following questions remain unresolved. They are documented here honestly, not to be papered over but to be addressed in subsequent work.

### 7.1 Section mapping

**Q7.1:** How do the existing Campus Walk sections map to BM and SM?

The Campus Walk describes:
- Section 3: BMM General Vocabulary
- Section 4: Business Instance
- Section 5: Operational Domains
- Section 6: Business Process Patterns
- Section 8: SMM General Vocabulary
- Section 9: System Instance
- Section 10: System Domains
- Section 11: Operational Simulation

Which of these belong to BM vs BMM, and SM vs SMM? A plausible mapping:

| Section | Current name | Proposed classification |
|---|---|---|
| 3 | BMM General Vocabulary | BMM (meta model) |
| 4 | Business Instance | BM Configuration? |
| 5 | Operational Domains | BM? Or meta model? |
| 6 | Business Process Patterns | Mixed (meta model and model)? |
| 8 | SMM General Vocabulary | SMM (meta model) |
| 9 | System Instance | SM Configuration? |
| 10 | System Domains | SM? |
| 11 | Operational Simulation | SM Runtime State? |

But this mapping is uncertain. Section 5 (Operational Domains) is described as "how the business actually operates" — which sounds like BM. Section 6 (Business Process Patterns) spans abstraction levels. Section 10 (System Domains) is described as both model content and "running code."

### 7.2 BM runtime state location

**Q7.2:** Where does BM Runtime State live architecturally?

This is the original Q1 from the Connecting the Stacks paper, now properly framed. Options discussed:

- Portal SQLite (alongside module configuration)
- Separate service
- Knowledge graph

But the question cannot be answered until BM Runtime State has an unambiguous architectural home — a section in the diagram.

### 7.3 Model vs execution

**Q7.3:** Is SM a model OF execution, or IS it the execution?

The Operational Simulation (Section 11) is marked "Runtime." But:

- If SM is a model of what execution is doing, then execution happens somewhere else (Temporal, apps, humans in Infrastructure) and feeds state back into SM
- If SM IS the execution, then there's no separation between model and reality

The distinction matters for understanding what "the system model at runtime" means and where events originate.

### 7.4 Horizontal mappings at different levels

**Q7.4:** How do horizontal mappings work at vocabulary, configuration, and runtime levels?

The Campus Walk describes:
- "maps to" at vocabulary level (BMM → SMM)
- "realised by" at instance level (Business Instance → System Instance)
- "executed as" at the dynamic level (Business Process Patterns → Operational Simulation)

Are these three different kinds of mapping? Are there also horizontal runtime mappings (SM Runtime State → BM Runtime State) that are not yet represented?

### 7.5 Reflective Simulation relationship

**Q7.5:** What is the Reflective Simulation's relationship to BM and SM?

Section 12 (Reflective Simulation) "reads from every layer of the architecture" and produces "trajectories, projections, anomaly detection, what-if scenarios."

Does it:
- Read FROM BM and SM as sources?
- Produce derived knowledge that BECOMES PART OF BM or SM?
- Sit ALONGSIDE BM and SM as a third thing?

### 7.6 Infrastructure and execution agents

**Q7.6:** How do execution agents connect to SM?

The diagram shows Temporal in Infrastructure. Apps and humans that perform work are not explicitly shown. The connection between these execution agents and the Operational Simulation is architecturally implicit.

Are execution agents:
- Part of SM?
- Separate from SM but feeding events into it?
- The substrate on which SM runs?

---

## 8. Proposed Next Steps

The discussion identified a clear path forward: a bidirectional section-by-section review of the current architecture diagram, working both top-down and bottom-up on both stacks, to clarify what each section is doing, to discover where the two directions meet in the middle and to establish how the diagram needs to be modified and extended.
### 8.1 Why bidirectional

Working only top-down would impose structure from the well-understood ontological and meta model layers onto the less-understood runtime and execution layers. This risks forcing the bottom of the architecture into categories that may not fit, although it is helpful to identify those parts of the meta models at higher level, which are reasonably well established already. 

Working bottom-up — from execution and runtime state upward through the stack — would help discover what is actually happening at the levels where model meets reality. At the very bottom, it should be possible to identify what the business operator is interacting with at the most immediate, tangible level where the business is actually being done, ‘at the coalface’.

The sections at the bottom of both stacks (Operational Simulation, Business Process Patterns, the relationship to Temporal and execution agents) are precisely where our current understanding is weakest. These sections may not yet be properly understood, described, delimited, or scoped.

The two directions should meet in the middle. The areas where they converge — or fail to converge — will help to inform what extensions or revisions the architecture requires.

### 8.2 The review process

For each section, from both directions, ask:

1. What is this section's purpose, precisely stated?
2. Is this meta model content, model content, or both?
3. If model content, is it configuration or runtime state?
4. What are its inputs and outputs?
5. What does it receive from above / below?
6. What does it provide to above / below?
7. Does it need to be split, merged, renamed, or extended?

**Top-down perspective:** What does this section's upper neighbour require of it? How does the vocabulary/structure layer constrain or enable what this section can contain?

**Bottom-up perspective:** What does execution actually produce? What state actually accumulates? What do the runtime sections need from the layers above them?

### 8.3 Expected outcomes

This bidirectional review is expected to produce:

1. A revised section list with clearer delineation of meta model vs model
2. Explicit placement of BM and SM in the architecture
3. Identification of where BM Runtime State should be represented
4. Clarification of the relationship between SM and execution
5. Representation of horizontal runtime mappings
6. Terminology cleanup (deprecating ambiguous terms)
7. Possible discovery of missing sections or misplaced content at the runtime/execution levels

### 8.4 Deliverable

A revised architecture diagram (or specification for one) that unambiguously represents all concepts, with a nomenclature table ensuring consistent terminology. The revision should reflect discoveries from both top-down and bottom-up analysis.

---

## 9. Register Connections

### 9.1 Observations and watchpoints

| ID | Summary | Status | Work type |
|---|---|---|---|
| [[ontara-ref-work-items\|OW-32]] | Portal module catalogue architecturally dishonest — names not derived from model | active | CON, BMM |
| [[ontara-ref-work-items\|OW-33]] | Horizontal runtime mappings entirely unimplemented | active | BMM, CON, GOV |
| [[ontara-ref-work-items\|OW-34]] | Adding runtime instance data to KG would expand its role | active | KGO, BMM |
| [[ontara-ref-work-items\|OW-35]] | Stage 9 connection sequence needs acceptance criteria | active | GOV |

This paper directly addresses the conceptual prerequisites for OW-32, OW-33, and OW-34. Until BM and SM are clearly situated, these items cannot be properly resolved.

### 9.2 Principles relevant to this discussion

| Principle | Relevance |
|---|---|
| [[principle-two-meta-model-distinction\|A4]] | The entire discussion is about making A4 spatially and terminologically precise |
| [[principle-separation-representation-execution\|A1]] | The question of whether SM is representation or execution is A1 made concrete |
| [[principle-model-generates-everything\|A3]] | Understanding what "the model" is (BM? SM? BMM? SMM?) is prerequisite to A3 |
| [[principle-self-describing-system\|A2]] | The system must be able to describe itself — which requires unambiguous architecture |

### 9.3 Related register entries

| Entry | Relevance |
|---|---|
| [[concept-dual-stack-architecture\|B21]] | Dual-stack architecture — the subject of this discussion |
| [[concept-architectural-section\|B27]] | Architectural section — the unit of analysis |
| [[concept-horizontal-mappings\|B12]] | Horizontal mappings — need clarification at multiple levels |

---

## Related Documents

- [[ontara-discussion-architectural-campus-walk-2026-03-28|Architectural Campus Walk (Sessions 84–85)]] — the source of the 20-section architecture this paper examines
- [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks (Sessions 192–193)]] — the Stage 9 planning paper whose Q1 triggered this discussion
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture (Session 73/74)]] — the foundational architecture paper
- [[ontara-ref-strategic-snapshot|Strategic Snapshot]] — current project orientation
- [[ontara-ref-master-register|Master Concept Register]] — all register references
- [[ontara-ref-work-items|Observation and Watchpoint Register]] — OW-32 through OW-37

---

*Discussion paper produced in Session 195 (11 April 2026). Working document — captures discussion state, does not resolve all uncertainties. To be followed by section-by-section review working down the diagram from top to bottom. GenderSense Limited.*
