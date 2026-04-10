---
tags:
  - session-report
date: 2026-04-10
status: current
session: 193
---
# Session 193 — Report

**Date:** 10 April 2026
**Type:** Discussion (with session recovery)
**Principal output:** [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks — Toward a Live, Model-Grounded Ontara System]]

---

## Summary

Session 193 was a recovery and continuation session following the premature termination of Session 192 due to an erroneous token consumption/reporting issue. Session 192 had completed the Claude Tooling Guide currency refresh and was mid-way through producing a discussion paper when it terminated. The primary goal of Session 193 was to produce that paper accurately and completely.

### Session open

The full session open sequence was followed. The [[ontara-workflow-guide|workflow guide]], Session 192 preparation note, [[ontara-ref-work-items|work item tracker]], [[ontara-ref-strategic-snapshot|strategic snapshot]], and [[ontara-ref-master-register|master register]] Tier 1 quick reference were all read. The Session 192 transcript was provided by Ella as a file (placed in Downloads and read via MCP) to establish what had been accomplished before the premature close.

**Currency check findings at O2:**
- [[ontara-ref-strategic-snapshot|Strategic snapshot]]: due at ~S193 (7-session threshold from S186) — flagged but not acted on this session; deferred to S194 when Stage 9 planning will give it richer content to incorporate
- [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]]: also due for review at ~S193 — flagged; lightweight check deferred to S194

**Active work items:** None — the [[ontara-ref-work-items|work item tracker's]] active table was empty going into this session.

**OW items noted at O3:** OW-12 (intake methodology cost), OW-30 (portal visual monotony), OW-31 (concept graph content currency), and the vocabulary validation watchpoints (OW-02 through OW-11 various), all remaining active and unchanged. See [[ontara-ref-work-items|Observation and Watchpoint Register]].

### Primary work — discussion paper

The main deliverable of the session was the discussion paper [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks — Toward a Live, Model-Grounded Ontara System]], produced from the S192 transcript. The paper captures:

- The four-plus-one things that need to connect (model, console, portal, execution layer, customer UI) and the observation that only one real connection currently exists (model → console)
- The process execution options considered (A–D) and why Options A/B are the right territory, with C and D set aside
- The three paths to connection (1/2/3) and the clarification that Paths 1 and 3 are the same destination — concrete-first, starting with the cafe as the proving ground
- The architecturally significant clarification from Ella about two distinct runtime states: SMM state (workflow instances, queue depths, operational metrics) and BMM state (business facts, cumulative measures, revenue, inventory) are genuinely distinct, require separate stores, separate update paths, and separate query mechanisms
- The shared infrastructure / strict model binding principle: the same tools can appear on both sides of the stack, but every piece of runtime infrastructure must explicitly declare which model element it implements
- Eight formal design decisions (S192-D1 through S192-D8)
- Seven open questions (Q1–Q7) forming the agenda for Stage 9 planning
- Four observations and watchpoints
- Register connections across [[principle-separation-representation-execution|A1]], [[principle-model-generates-everything|A3]], [[principle-two-meta-model-distinction|A4]], [[principle-deterministic-over-probabilistic|A6]], [[principle-unity-principle|A11]], [[concept-dual-stack-architecture|B21]], [[concept-knowledge-graph|B22]], [[concept-operational-simulation|L5]], [[concept-co-evolution|J2]], [[concept-non-constraining|J3]]

### Key architectural clarification (S192)

The most significant architectural moment in the S192 discussion was Ella's clarification of what the dual stack means at runtime. This deserves explicit note in the session record:

The BMM and SMM do not merely describe the same reality from different angles — they track different kinds of state that both change as a result of a service episode, each in their own terms. The workflow returning to its resting state after an order is fulfilled is an SMM fact. The business's daily order count incrementing is a BMM fact. The horizontal mappings at runtime are the rules that update BMM state as a consequence of SMM episode completion. Without them, the dual stack is an architectural description without operational reality.

This clarification has direct implications for Stage 9: the platform needs both a BMM runtime state store and an SMM state feed (from Temporal), and the portal operator needs to see both.

---

## Register concepts exercised

- [[principle-separation-representation-execution|A1]] — framed as the governing principle for the model-binding discipline at deployment infrastructure level
- [[principle-model-generates-everything|A3]] — S192-D7 (module catalogue derived from model) and the model-binding discipline are expressions of A3
- [[principle-two-meta-model-distinction|A4]] — the two-distinct-runtime-states clarification is the operational expression of A4
- [[principle-deterministic-over-probabilistic|A6]] — noted in connection with horizontal mapping implementation (Q2) and governance observability
- [[principle-unity-principle|A11]] — open question raised: does A11 govern the runtime mappings, or are they a separate structure?
- [[concept-dual-stack-architecture|B21]] — §6 of the paper extends the dual-stack architecture paper with runtime state specifics
- [[concept-knowledge-graph|B22]] — Q1 raises whether the KG's role expands to include runtime instance data
- [[concept-operational-simulation|L5]] — the connection sequence is framed as progressive realisation of L5 ("the SMM made live")
- [[concept-co-evolution|J2]] — connection sequence must co-evolve model, portal, and execution infrastructure
- [[concept-non-constraining|J3]] — shared infrastructure / strict model bindings is a J3 decision

No new concepts introduced to the register this session. No concepts retired.

---

## Emergent ideas captured

None added to the Emergent Ideas Log this session. The discussion paper itself captures the ideas at sufficient fidelity.

---

## Observations and watchpoints

| # | Summary | Work type | Source | Notes |
|---|---|---|---|---|
| S192-OW-A | Portal module catalogue is architecturally dishonest — uses BMM concept names but not connected to BMM. Must be addressed before further operational features are built on top | CON, BMM | S192 discussion | Corresponds to S192-D7. To be deposited in OW register at C2 |
| S192-OW-B | Horizontal runtime mappings (SMM episode completion → BMM state update) are entirely unimplemented and their implementation pattern is an open design question. May be the central design challenge of Stage 9 | BMM, CON, GOV | S192 discussion | To be deposited in OW register at C2 |
| S192-OW-C | Adding runtime instance data to the KG would significantly expand its role from vocabulary/structural store to operational runtime store; has implications for the round-trip diff engine and query load | KGO, BMM | S192 discussion | Not a Stage 9 blocker but must be decided before BMM runtime state store is implemented |
| S192-OW-D | Connection sequence (Q5) needs explicit acceptance criteria at Stage 9 plan time | GOV | S192 discussion | Standard practice — flag for Stage 9 planning |

---

## Open questions / deferred items

All seven open questions (Q1–Q7) from the discussion paper are outstanding and form the agenda for Stage 9 planning. The most pressing are:

- **Q1** — Where does BMM runtime state live?
- **Q2** — How are the horizontal mappings implemented?
- **Q3** — What does "module derived from model" actually mean at the data level?

These three need positions before a Stage 9 plan can be properly scoped. Q4–Q7 are secondary but should be addressed within the Stage 9 planning session.

---

## Deferred governance

- **[[ontara-ref-strategic-snapshot|Strategic snapshot]] refresh** — due at ~S193 but deferred to S194. Stage 9 planning will produce richer content to incorporate.
- **[[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]] review** — due at ~S193. Lightweight check; deferred to S194.

---

## Tier 1 principles — this session

| Principle | Honoured? | Notes |
|---|---|---|
| A1 | Yes | Paper's central direction is making A1 real at deployment infrastructure level |
| A3 | Yes | S192-D7 and model-binding discipline are A3 expressions |
| A4 | Yes | Two-runtime-state clarification deepens A4's operational meaning |
| [[principle-discipline-as-load-bearing-structure|A9]] | Yes | Full session open sequence followed; close sequence being followed in order |

| J2 | Yes | Connection sequence must co-evolve model, portal, execution — noted explicitly |
| J3 | Yes | Shared infrastructure / strict model bindings preserves optionality |
