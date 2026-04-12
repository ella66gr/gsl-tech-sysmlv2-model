---
tags:
  - session-report
date: 2026-04-12
status: current
session: 198
type: discussion
workstream: ARC
---
# Session 198 — Surface Architecture Discussion Paper

> `= this.file.path`

**Date:** 12 April 2026
**Type:** Discussion
**Workstream:** Architecture (ARC) — Stage 9 foundation
**Previous session:** [[session-197-report-2026-04-12|Session 197]] (BS Substrate and Bindings discussion paper)

---

## Summary

Session 198 produced the [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|Surface Architecture and Bindings discussion paper]], the parallel treatment of the operator surface to complement the [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|Session 197 substrate paper]]. Together, the two papers constitute the architectural foundation from which the Stage 9 plan can be drawn — substrate (Session 197) and surface (Session 198).

The session also completed [[ontara-ref-work-items|W-041]] (Research & Background Index currency check), which had been carried forward from Sessions 196 and 197 as two sessions overdue.

The structured critique (per [[ontara-workflow-guide|workflow guide]] §1 commitment 5 / §2.2) was performed and is recorded in §15 of the surface paper itself, with testable predictions carried forward as watchpoints into the [[ontara-ref-work-items|OW register]].

## What was done

### W-041 — Research & Background Index currency check

The R&B Index in `/02 ONTARA/06 Ontara Research & Background Notes` was checked against the actual folder contents. One unindexed arrival was identified: [[ontara-research-(perplexity) - interface-and-interaction|Interface and Interaction (Perplexity research)]] — fittingly the very document that fed Option A's substantive work this session. The Index was updated via MCP `edit_file` to:

- Update the header to "Session 198 (12 April 2026) — currency check, 16 files indexed."
- Add the new entry under Perplexity Research with a description of its content (alternatives to the Unix shell, hybrid and intent-based interfaces, embedded AI agents, domain-specific graphical shells, DAG-based workflow views, bounded agent roles, capability matrices, Ask/Plan/Simulate/Act mode design, approval-first execution).
- Add a forward-link to the new Surface Architecture discussion paper produced in this session.

W-041 is complete. The R&B Index Document Currency Register entry is updated to reflect S198 refresh.

### Option A — Surface Architecture discussion paper

The main work of the session. The paper is approximately 7,500 words across 15 sections, structured to parallel the shape of the Session 197 substrate paper. Filename: `ontara-discussion-surface-architecture-and-bindings-2026-04-12.md` (parallel to `bs-substrate-and-bindings`, signalling the connection between the two papers).

**Structure of the paper:**

| Section | Purpose |
|---|---|
| §1 | Purpose and scope; relationship to the Perplexity research |
| §2 | The operator's relationship to the model; three audiences, one workspace; A13 multi-tenancy at the surface |
| §3 | The three-layer interaction model: operational / expert / intent |
| §4 | The workspace structure: scope rail, canvas, dock; seven named work surfaces; binding registry as Model Map sub-surface |
| §5 | Bounded agent roles: the roster, why no agent has Approve, the intersection rule for delegation |
| §6 | The capability matrix: human role × action class, agent role × action class, matrix vs policy distinction |
| §7 | **Action class reframed through bindings** — the principal Ontara-specific extension |
| §8 | Ask / Plan / Simulate / Act modes; mode visibility |
| §9 | Approval as a first-class interaction primitive; the plan/verify pattern |
| §10 | The surface reads the substrate (queries against KG-resident BR/BS); freshness propagation |
| §11 | The Stage 8 portal in light of this paper (malleable prior art; substrate gap; not a constraint) |
| §12 | Implications for the architecture (seven points) |
| §13 | Ten open questions for Stage 9 planning |
| §14 | Register connections; principles engaged; concepts to add or revise; observations and watchpoints |
| §15 | Critique observations and watchpoints (structured critique pass) |

**Key architectural positions:**

1. **The three-layer interaction model** (operational / expert / intent) is an architectural distinction in the *kind* of interaction, not a UI structure. Treating the intent layer as architecturally distinct is necessary because it has different properties from the other two — goal-oriented, mode-aware, agent-mediated, approval-gated.

2. **Bounded agency** is the design pattern for AI mediation. There is no general super-agent. The initial roster is: Ontara Guide, Model Analyst, Query Copilot, Workflow Orchestrator, Governance Sentinel, Release Steward. Each has a distinct identity, ceiling, and audit profile. No agent holds Approve as a default permission. The intersection rule for delegation is the load-bearing safety property.

3. **The capability matrix** (human role × agent role × action class × scope) is the formal expression of authority. The matrices set default ceilings; the policy classification of any specific action sits on top of the matrices. The matrix is the floor; binding-grounded computation is the everyday default; explicit policy is the ceiling.

4. **Action class reframed through bindings** is the principal Ontara-specific contribution to the framework. An action's risk classification is *computable* from properties of the binding declaration (instantiation mode, freshness/fidelity profile, production marker, authority zone), not asserted by case-by-case policy judgment. This closes the loop with the Session 197 substrate paper: the binding registry is the operational substrate from which surface-level risk classifications are computed.

5. **Ask / Plan / Simulate / Act** are the four explicit modes of Agent Studio. The mode is always visible. The progression is always Ask → Plan → (optionally Simulate) → Act, with explicit transitions. Skipping Plan is impossible. Act mode does not improvise; it executes structured plans that have cleared their gates.

6. **Approval is a first-class interaction primitive**, not a UI bolt-on. Approval artefacts are structured entities with their own lifecycle, stored in the BS substrate, with full PROV-O provenance. The approval lifecycle (Pending / Approved / Rejected / Withdrawn / Executed / Expired) is recorded as substrate events. Separation of duties is enforced through the approval primitive: even a Tenant Admin cannot self-approve high-impact actions in their own scope.

7. **The plan/verify pattern** emerges naturally from putting Plan, Simulate, Act, and Approval together as first-class primitives. It happens to align well with regulated-care expectations about how operational decisions should be made and recorded.

8. **The surface reads from and writes proposals against the substrate.** The seven canvas surfaces and four dock panels query the KG-resident BR/BS; the surface does not maintain duplicate state. The surface initiates, the components execute, the bindings observe, the substrate updates. This loop is the same whether the binding is real or synthetic.

9. **Freshness propagation** is the surface-side application of A2 and A10 at the model–reality boundary. Bindings carrying freshness/fidelity profiles means the surface can — and should — render freshness as a visible property of what it shows.

10. **The Stage 8 portal is reframed**, not preserved. It is malleable prior art whose substrate (SQLite, hand-seeded module catalogue) is wrong; whose architectural intuitions (state-driven dashboard, lifecycle composition, progressive governance, prerequisite-gated promotion, comparative simulation, schema-driven configuration) survive into the new architecture; and whose missing pieces (Agent Studio, Model Map, Workflow Graph, binding registry, full approval primitive, Evidence Trail) require substantial extension. See [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|the Stage 8 portal discussion paper]] for the prototype design that this paper now reframes.

### Structured critique

The structured critique was performed during drafting, per the workflow guide §1 commitment 5 and §2.2. Findings were recorded in §15 of the paper itself, embedded in the artefact they qualify rather than carried in chat alone. Seven concerns identified:

1. The paper relies heavily on Perplexity-derived material; the binding-grounded reframing in §7, the multi-tenancy treatment in §2.2, and the §11 portal section are the principal Ontara-specific tests of the source.
2. The seven-surface structure is asserted, not derived from first principles.
3. The capability matrix and binding-grounded computation may not cleanly decompose; implementation may discover the two layers cannot be separated.
4. The approval lifecycle is sketched, not specified; real workflows often have additional states.
5. The intent layer is the most novel and the least tested; the four-mode design may need revision after first implementation contact.
6. The portal reframing in §11 may be larger than acknowledged — closer to a rebuild than a reframing.
7. The relationship to the Ontara Console (Q2) is unresolved and architecturally significant.

Four "did not find" reassurances were also recorded: no fundamental conceptual error in the bounded-agent commitment; no hidden user-sophistication assumption; no conflict with the Session 197 substrate paper; no conflict with existing Tier 1 principles.

Five testable predictions were carried forward as watchpoints into the OW register at C2 (see §14.3 of the paper and the OW updates in C2 below).

### Conversation observation captured

One observation from conversation that was not part of the formal critique: Ella's catch on the Session 198 O4 conflation between the OW register's work-type taxonomy (a development-task tracking mechanism) and the surface paper's capability matrix (a runtime authority mechanism). The two are different layers and have no relationship. The conflation was a Claude error and was withdrawn before drafting began. No watchpoint needed — the correction was made in real time and didn't propagate into the paper. Recorded here as a small process observation: Claude should be more careful about distinguishing internal-development concepts from architectural-runtime concepts when they share words like "role" or "matrix".

## Register concepts exercised, confirmed, or newly introduced

### Tier 1 principles exercised

Per the surface paper §14.1, this session's work directly engaged: A1, A2, A3, A4, A8, A9, A10, A11, A13, J2, J3. None of these were modified — they were applied as governing constraints.

### New concepts proposed (not yet added to the register)

The surface paper §14.2 proposes the following candidate register additions, which are deferred to the W-043 master register update session (likely Session 199 or 200):

- Operator workspace as a structural architectural concept (Section B or I)
- Three-layer interaction model (operational / expert / intent) as a structural pattern (Section D once realised, B until then)
- Bounded agency as a design pattern (Section D)
- Capability matrix as a structural concept governing authority resolution (Section A or B)
- Action class as binding-derived (Section B, alongside the Session 197 binding entries)
- Approval artefact as a first-class structural element (Section B or C5)
- Plan/verify pattern as a validated workspace pattern (Section D, once realised)
- Mode-aware agent interaction (Ask / Plan / Simulate / Act) (Section D or J)

The Perplexity research's recurring theme — "build an agent guided by model truth, not by prompt cleverness" — may itself warrant a register entry as a guiding principle. Possibly an extension of A9.

These are candidates, not commitments. They will be evaluated alongside the Session 197 register additions as part of W-043.

## Observations and watchpoints

The following observations and watchpoints were surfaced during the session and are deposited in the OW register at C2 below.

| # | Summary | Work type(s) | Source |
|---|---|---|---|
| 1 | Three-layer interaction model (operational / expert / intent) is the architectural framing for the operator surface. Stage 9 design must treat the three layers as separable concerns even when they share UI real estate | ARC, CON | Surface paper §3 |
| 2 | Bounded agent roster is the design pattern for AI mediation in the workspace. Adding capabilities to an existing agent rather than creating a new bounded agent should be treated as a design smell | ARC, CON | Surface paper §5 |
| 3 | Action class risk classification is computable from binding metadata (instantiation mode, freshness profile, production marker, authority zone). Vocabulary design for the binding declaration must include these properties | ARC, KGO | Surface paper §7; ties into S197 Q1 |
| 4 | Approval is a first-class entity in the substrate with its own lifecycle and PROV-O provenance, not a UI bolt-on. Approval artefacts must be added to the BMM or platform vocabulary as structural elements | BMM, ARC, GOV | Surface paper §9 |
| 5 | The Stage 8 portal requires substrate replacement (SQLite → KG-resident BR/BS), not just feature extension. The reframing is large and should be sequenced carefully across Stage 9 phases | CON, ARC | Surface paper §11 |
| 6 | Model Map's relationship to the existing Ontara Console is unresolved (surface paper Q2). Two options: collapse the console into the workspace, or define the integration precisely between two applications. Decision required during Stage 9 planning | ARC, CON | Surface paper §13 Q2 |
| 7 | The workspace itself should be model-generated rather than hardcoded UI logic. Capability matrices, agent ceilings, action class definitions, and approval lifecycles should be model content that the platform reasons about | ARC, BMM | Surface paper §12.3 |
| 8 | Bounded agents must have distinct identities for audit purposes. The agent instantiation model (separate processes vs separate prompts vs something else) is open and has cost, latency, and boundary-strength implications | CON, GOV | Surface paper §13 Q5 |
| 9 | Freshness propagation from bindings into surface-level rendering is a cross-cutting concern that touches Overview, Workflow Graph, Model Map, and the agent layer. Visual treatment should be consistent across surfaces | CON | Surface paper §10.3; relates to OW-42 |
| 10 | Workspace state (selections, opened panels, conversation history) is not BR/BS content but has provenance value and privacy implications. Persistence and audit treatment is open | CON, GOV | Surface paper §13 Q10 |

### Critique-derived predictions (carried forward as watchpoints; subset of the above)

These five testable predictions, recorded in §15.3 of the paper, are captured as part of OW items 1, 2, 4, 5 above. They will be checked when relevant work arrives:

- The seven-surface structure will not survive first implementation unchanged.
- The four-mode design will require user testing to confirm it is intelligible.
- The capability matrix and binding-grounded computation may not cleanly decompose.
- The approval lifecycle will need additional states.
- The portal reframing may be substantial enough to count as a rebuild.

## Open questions deferred to Stage 9 planning

The surface paper §13 lists ten open questions for Stage 9 planning. These should be read alongside the eleven open questions from the Session 197 substrate paper (§11 of that paper). Together, the two papers leave approximately twenty-one open questions to be resolved during Stage 9 plan production. This is appropriate — the two papers establish the architectural foundation; the Stage 9 plan resolves the design questions; implementation tests the resolutions.

## Tier 1 principles relevant to this session and how they were honoured

| Principle | How honoured |
|---|---|
| [[principle-separation-representation-execution\|A1]] | The surface paper's "surface initiates, components execute, bindings observe, substrate updates" loop (§10.2) is A1 made operational at the interaction layer. The Plan/Simulate/Act progression enforces the separation explicitly. |
| [[principle-self-describing-system\|A2]] | Mode visibility (§8.5), freshness propagation (§10.3), the binding-grounded action class (§7), and the structured approval artefact (§9.1) are all surface-level applications of A2. |
| [[principle-model-generates-everything\|A3]] | The capability matrix, agent ceilings, action class definitions, and approval lifecycles are framed as model content rather than hardcoded UI logic (§12.3). The architectural commitment is that the workspace is generated from the model. |
| [[principle-two-meta-model-distinction\|A4]] | The Overview surface shows BR and BS facts side by side (§10.1), making the dual stack visible at the operator surface. |
| [[principle-clinical-governance-first-class\|A8]] | Approval as a first-class primitive (§9), the Governance Sentinel agent (§5.1), and the Governance Lens surface (§4.1) make governance structural rather than bolt-on. |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Bounded agents, the intersection rule for delegation, mode visibility, and approval as a first-class primitive are disciplined working practices propagated to the operator's experience. |
| [[principle-intrinsic-self-knowledge\|A10]] | Freshness annotations (§10.3) and the binding registry sub-surface (§4.2) are surface-level applications of A10. |
| [[principle-unity-principle\|A11]] | The same model, governance vocabulary, bindings, and provenance graph serve all seven canvas surfaces and all four agent modes. There is no separate knowledge structure for the surface. |
| [[concept-multi-tenancy\|A13]] | The workspace is platform infrastructure parameterised by tenant context (§2.2). GSL gets the same workspace every other tenant gets. Explicitly tested against in §2.2. |
| [[concept-co-evolution\|J2]] | The surface paper repeatedly emphasises that the surface, the substrate, and the agent layer must co-evolve. Building one without the others is not viable. |
| [[concept-non-constraining\|J3]] | The seven-surface structure, the four-mode design, and the bounded-agent roster are designed to be extensible — additional surfaces, modes, or agents can be added without restructuring the existing ones. |

## Governance actions this session

- **W-041** (R&B Index currency check) completed. Index updated, Document Currency Register row to be updated at C2.
- **Surface architecture discussion paper** produced (W-044). To be added to the Architecture Papers Index at C3 and tracked as complete in the work item tracker at C2.
- **Structured critique** performed inline as §15 of the paper, with predictions deposited as OW items at C2.

## Session lifecycle notes

- **Session type:** Discussion (single major deliverable) with a small housekeeping task at the start (W-041).
- **Tooling note:** This session ran without container artifact tools available despite the desktop app's Artifacts toggle being enabled. The Session 197 substrate paper and the Session 198 surface paper were both written via MCP `filesystem:write_file` to `/Users/ellagreen/Downloads/`. The mechanism worked but is not the right long-term approach. Worth investigating before [[session-199-preparation-note|Session 199]]; if artifact tooling is restored, normal container artifacts should resume from S199 onward. The gap between "Artifacts toggle on" and "artifact tool available in session" is captured as feedback worth flagging to Anthropic via the thumbs-down mechanism.
- **Process observation:** Claude conflated two distinct concepts at O4 (the OW register's work-type taxonomy with the surface paper's capability matrix). Ella caught it; Claude withdrew the conflation and the surface paper was drafted without that error. Recorded as a small process observation, no watchpoint needed.

---

*Session 198 report. The surface architecture discussion paper is the main deliverable; W-041 is complete; the architectural foundation for Stage 9 (substrate + surface) is now in place. Next session continues toward Stage 9 plan production via either editorial cleanup (W-042), master register update (W-043), Campus Walk II (W-045), or beginning the Stage 9 plan itself.*
