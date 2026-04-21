# Architectural clarification: layers, models, and simulation

**Session 196 | 12 April 2026 | Discussion paper**

## Summary

This note captures architectural clarifications arising from Session 196's bottom-up review of the dual-stack architecture. The session used hand-drawn sketches to reason from first principles about what the architecture actually represents, surfacing several conceptual clarifications needed before Stage 9 planning and Campus Walk II.

---

## 1. The four-layer model

Each stack (business and system) has four distinct layers:

| Layer | BMM/BM stack | SMM/SM stack | Nature |
|---|---|---|---|
| **1. Foundation** | BFO + Domain Ontologies | BFO + System Ontological Categories | Upper ontology + domain extensions (OWL 2 DL) |
| **2. Meta model vocabulary** | BMM General Vocabulary (34 `part def`s) + domain extensions | SMM General Vocabulary (6 capability groups) + domain extensions | Reusable templates (SysML v2) |
| **3. Configured model** | BM — assembly for THIS business | SM — assembly for THIS system | Domain-specific configuration (`part` instantiations) |
| **4. Generated output** | Business Status (accumulated data) | Runtime Execution System (running processes) | Actual operation |

### Key distinctions

- **BMM vs BM**: BMM is the vocabulary (`part def`); BM is the configured model for a specific business (`part` instantiations using that vocabulary). The Paws demonstrator exemplifies this: `part def ValueProposition` in BMM; `part pawsValueProposition : ValueProposition` in BM.

- **SMM vs SM**: Same pattern. SMM provides the vocabulary for describing system capabilities; SM assembles that vocabulary into a specific system configuration.

- **Configuration vs runtime state**: Both BM and SM have configuration (the structural assembly) and runtime state (accumulated facts for BM; execution state for SM). These are conceptually distinct even if not always physically separated.

---

## 2. Horizontal relationships

### Structural mappings (vocabulary and configuration levels)

- **BMM ↔ SMM**: Vocabulary alignment. A `ServiceOffering` (BMM) corresponds to system capabilities that deliver it (SMM).
- **BM ↔ SM**: Configuration correspondence. The business model's service offerings map to the system model's workflow configurations.

These are structural relationships established at design time.

### Runtime data flow (generated output level)

- **Runtime Execution System → Business Status**: Activity records produced by the running system feed into accumulated business state.

This is the horizontal runtime mapping that [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] identified and that Stage 9 needs to implement.

---

## 3. Operational Simulation: one model, multiple instantiation modes

A critical clarification: the architecture does **not** propose a digital twin arrangement (two parallel systems kept in sync). Instead:

**The SM generates a Runtime Execution System definition** — the structure of apps, workflows, integrations, task assignments. This definition can then be **instantiated** in different modes:

| Instantiation mode | Connected to | Purpose |
|---|---|---|
| **Real instance** | Actual apps, devices, real people doing tasks | Running the actual business |
| **Simulation instance(s)** | Computational model only | Projections, what-ifs, counterfactuals, scenario analysis |

The same model structure, different runtime bindings. The real instance has human actors responding to workflow prompts. Simulation instances have computational proxies or pre-scripted behaviours.

**"Operational Simulation" in the console diagram therefore includes the real-world instance** — it is the execution model that can be instantiated in real or simulated modes.

---

## 4. Reflective Simulation: system self-consciousness

The Reflective Simulation provides the system's capacity for self-awareness and analytical reasoning:

- **Observes all instances** (real and simulated)
- **Spawns and orchestrates simulation instances** for analytical purposes
- **Compares trajectories** between real execution and projected outcomes
- **Performs analytical functions**: anomaly detection, option analysis, what-if scenarios, valence assessment, gap analysis, guidance generation
- **Works with embedded AI** to serve the operator's understanding and decision-making

This is the layer where the system reasons about itself and produces guidance for the human operator.

---

## 5. Console diagram assessment

### What the current console diagram got right

- Operational Simulation existing as a section
- Reflective Simulation as a cross-cutting analytical layer
- The capability list for Reflective Simulation (trajectories, projections, anomaly detection, etc.)
- The general dual-stack structure with BMM/SMM vocabulary at the top

### What needs correction or clarification

1. **"Business Instance" and "System Instance" naming** — These should be **"Business Model (BM)"** and **"System Model (SM)"**. "Instance" implies runtime instantiation rather than configured model content.

2. **The four-layer structure is not visible** — The distinction between meta model vocabulary (Layer 2), configured model (Layer 3), and generated output (Layer 4) is not clear in the current diagram.

3. **Business Status is absent** — The accumulated business data (Layer 4 on the BMM side) is not represented.

4. **The generative relationships are not shown** — BM generates the data structure for Business Status; SM generates the Runtime Execution System definition.

5. **The one-model-multiple-instantiation pattern for Operational Simulation** — The diagram doesn't convey that Operational Simulation includes the real instance plus computation-only simulation instances.

6. **Operational Domains, Business Process Patterns, System Domains** — The purpose and layer-placement of these sections needs reassessment against the four-layer model.

---

## 6. Implications for Campus Walk II

The original Campus Walk (Sessions 84–85) described 20 sections based on the understanding at that time. A Campus Walk II is needed to:

1. Reassess each section against the four-layer model
2. Clarify which sections are meta model vocabulary vs configured model vs generated output
3. Properly represent BM and SM as first-class concepts
4. Show Business Status as an architectural section
5. Clarify Operational Simulation's one-model-multiple-instantiation pattern
6. Revise the console diagram to reflect these clarifications

---

## 7. Grounding: real-world activity and the operator

The architecture is grounded at both ends:

**Bottom**: Real-world business service activity — actual customers, actual transactions, actual service delivery. This is what the system exists to support. Simulated activity is the "pretend" version used for projections and analysis.

**Top**: The human business operator — the guidance target for the entire architecture. Every section exists to serve the operator's understanding and agency.

---

## Related documents

- [[ontara-discussion-model-meta-model-distinction-2026-04-11|Model and Meta Model: Clarifying the Architectural Representation]] (Session 195)
- [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] (Sessions 192–193)
- [[ontara-discussion-architectural-campus-walk-2026-03-28|Architectural Campus Walk]] (Sessions 84–85)
- [[ontara-ref-work-items|Work Items]] — OW-37 (architectural diagram extension)

---

*Session 196 discussion paper. To be used as input for Campus Walk II and revised architecture diagram production.*
