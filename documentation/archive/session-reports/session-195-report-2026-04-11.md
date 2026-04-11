---
tags:
  - session-report
date: 2026-04-11
status: complete
session: 195
---
# Session 195 Report — Model and Meta Model Distinction

**Date:** 11 April 2026
**Session type:** Discussion
**Stage:** Stage 9 planning (pre-planning)

---

## Summary

Session 195 was planned as a Stage 9 planning discussion, working through Q1–Q7 from the [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] paper. However, when we began addressing Q1 (where does BMM runtime state live?), a fundamental terminology problem emerged that required resolution before the planning questions could be meaningfully addressed.

The core insight: **BMM (Business Meta Model) is not the same as BM (Business Model)**. The meta model is the vocabulary/structure layer — what kinds of business concepts CAN exist. The actual model is the instantiation for THIS specific business — what this business IS and how it IS right now. The same distinction applies on the right stack: **SMM (System Meta Model) is not SM (System Model)**.

This distinction is implicit in the [[ontara-discussion-architectural-campus-walk-2026-03-28|Architectural Campus Walk]], which describes "BMM General Vocabulary" (Section 3) separately from "Business Instance" (Section 4). However, the Campus Walk uses "Business Model" and "Business System Model" loosely to describe entire stacks rather than the specific architectural constructs that should bear those names.

The session produced a discussion paper capturing the terminology clarification, the architectural representation gap identified, and seven open questions that must be resolved before Stage 9 planning can proceed.

---

## What Was Established

### Terminology clarifications

| Term | Meaning |
|---|---|
| BMM | Business Meta Model — vocabulary layer (34 `part def`s) |
| BM | Business Model — actual model of THIS business (not meta model) |
| SMM | System Meta Model — vocabulary layer (capability groups) |
| SM | System Model — actual model of THIS system (not meta model) |

### Architectural representation gap

The current architecture diagram shows:
- BMM and SMM clearly (vocabulary layers)
- Something like BM Configuration (Business Instance, Section 4)
- Something like SM Configuration (System Instance, Section 9)
- Something like SM Runtime State (Operational Simulation, Section 11)

But does NOT clearly show:
- BM Runtime State — where live business facts accumulate
- BM and SM as first-class architectural sections
- Horizontal runtime mappings (SM events → BM updates)
- The connection between SM and actual execution agents

### Methodological approach agreed

A bidirectional review of the architecture:
- **Top-down:** From well-understood ontological/meta model layers downward
- **Bottom-up:** From execution and runtime state upward
- **Meeting in the middle:** Where the two directions converge or fail to converge reveals what extensions the architecture requires

The sections at the bottom of both stacks may not yet be properly understood, described, delimited, or scoped.

---

## Deliverables

| Deliverable | Location |
|---|---|
| Discussion paper: Model and Meta Model: Clarifying the Architectural Representation | [[ontara-discussion-model-meta-model-distinction-2026-04-11]] |

---

## Register Activity

### Concepts exercised

| Code | Concept | How exercised |
|---|---|---|
| [[principle-two-meta-model-distinction\|A4]] | Two meta model distinction | The entire session is about making A4 spatially and terminologically precise |
| [[principle-separation-representation-execution\|A1]] | Separation of representation and execution | The question of whether SM is representation or execution is A1 made concrete |
| [[concept-dual-stack-architecture\|B21]] | Dual-stack architecture | Subject of the discussion |
| [[concept-architectural-section\|B27]] | Architectural section | Unit of analysis for the bidirectional review |

### Concepts newly introduced

None. This session clarified terminology for existing concepts rather than introducing new ones.

### Gaps identified

The architecture diagram requires extension to properly represent BM and SM as first-class concepts, distinct from BMM and SMM.

---

## Emergent Ideas Captured

None this session. The discussion was focused on clarifying existing architectural structure rather than generating new ideas.

---

## Observations and Watchpoints

| Summary | Source | Work type |
|---|---|---|
| Campus Walk sections may need revision to properly represent BM and SM | Discussion of terminology gap | ARC |
| "Business Process Patterns" (Section 6) spans meta model and model levels — may need to be split or clarified | Analysis of Campus Walk §6 | ARC |
| "Operational Simulation" (Section 11) may be SM Runtime State, but its relationship to execution is unclear | Analysis of Campus Walk §11 | ARC |
| The bottom of both stacks may not yet be properly understood, described, delimited, or scoped | Methodological discussion | ARC |

---

## Open Questions

All seven open questions from §7 of the discussion paper remain open. They are documented there and will be addressed in the bidirectional review proposed for subsequent sessions.

---

## Principles Honoured

| Principle | How honoured |
|---|---|
| [[principle-two-meta-model-distinction\|A4]] | The session exists to clarify A4's implications for architectural representation |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Pausing to fix terminology before proceeding with planning |
| [[concept-co-evolution\|J2]] | Recognising that model content, console representation, and architectural documentation must co-evolve |

---

## Session Statistics

- Session type: Discussion
- Duration: One full session
- Primary output: Discussion paper establishing terminology and framing for architectural review

---

*Session 195 report. GenderSense Limited.*
