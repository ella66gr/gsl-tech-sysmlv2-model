---
tags:
  - session-report
date: 2026-04-12
status: current
session: 196
---
# Session 196 — Report


**Date:** 12 April 2026
**Type:** Discussion (architectural review)
**Duration:** Standard session
**Workstream:** Architecture (ARC)

## Summary

Architectural review session focused on clarifying the dual-stack architecture's layer structure and the relationship between meta models, configured models, and generated outputs. Working from hand-drawn sketches, the session established a four-layer model for each stack and clarified the one-model-multiple-instantiation pattern for Operational Simulation.

## Work completed

### Architectural clarification through bottom-up reasoning

Starting from first principles — real customers doing real business activities — Ella's hand-drawn diagrams surfaced several conceptual clarifications:

1. **Four-layer model established:** Each stack has four distinct layers:
   - Foundation (BFO + domain/system ontologies)
   - Meta model vocabulary (BMM/SMM — the `part def`s)
   - Configured model (BM/SM — the `part` assemblies for THIS business)
   - Generated output (Business Status / Runtime Execution System)

2. **Horizontal relationships clarified:**
   - Structural mappings at vocabulary and configuration levels (BMM↔SMM, BM↔SM)
   - Runtime data flow at the generated output level (Runtime → Business Status)

3. **Operational Simulation pattern clarified:** Not a digital twin (two parallel systems kept in sync). Instead: one execution model (SM), multiple instantiation modes:
   - Real instance — connected to actual apps, devices, people
   - Simulation instance(s) — computation-only, for projections and what-ifs
   - The "Operational Simulation" section in the console diagram therefore *includes* the real-world instance

4. **Reflective Simulation role clarified:** System self-consciousness that observes all instances (real and simulated), spawns simulation instances for analysis, compares trajectories, produces guidance, and works with embedded AI to serve the operator.

### Console diagram assessment

Identified what the current console diagram got right (Operational and Reflective Simulation existing; dual-stack structure) and what needs correction:
- "Business Instance" / "System Instance" naming should be "Business Model (BM)" / "System Model (SM)"
- Four-layer structure not visible
- Business Status absent
- Generative relationships not shown
- One-model-multiple-instantiation pattern not conveyed

### Draft architecture diagram attempted

A draft SVG architecture diagram was produced via the visualizer tool. While not fully satisfactory, it captured the essential layer structure and can inform future diagram production by a more capable tool.

## Deliverables

| Deliverable | Location | Status |
|---|---|---|
| Architectural clarification note | `04 Ontara Architecture/ontara-discussion-architectural-clarification-2026-04-12.md` | ✅ Created |
| Draft architecture diagram | Inline in session (SVG) | ✅ Produced (for reference) |

## Governance actions

- **Research & Background Index check:** Flagged as due at O2 but deferred — architectural discussion took priority.

## Work items

### OW-37 status
**OW-37** (Architecture diagram requires extension to properly represent BM and SM) — progressed substantially. The conceptual clarification is complete; the actual diagram revision and Campus Walk II remain as follow-on work.

### No new W-items created
The architectural clarification note captures the session's findings for use in future diagram and Campus Walk work.

## Technical observations

- Claude Chat Opus 4.5's diagram production capabilities via `visualize:show_widget` are functional but limited for complex architectural diagrams. More sophisticated tools (Claude Opus 4.6 or manual production) may be needed for the final Campus Walk II diagram.

## Key insights

1. **The SysML structure is correct:** BMM defines vocabulary (`part def`), demonstrators instantiate it (`part`). The Paws file exemplifies the right pattern.

2. **The console diagram naming is confusing:** "Business Instance" and "System Instance" suggest runtime instantiation rather than configured model content. "Business Model" and "System Model" would be clearer.

3. **Layer 4 is absent from the console:** Business Status (accumulated business data) is not represented; the generative relationship from BM/SM to their outputs is not shown.

4. **Simulation is not twinning:** The architecture does not propose parallel systems kept in sync. It proposes one model instantiated in different modes — fundamentally cleaner.

## Next steps

1. **Campus Walk II:** Reassess all 20 sections against the four-layer model
2. **Revised architecture diagram:** Produce a comprehensive diagram with proper tooling
3. **Console diagram update:** Rename "Business Instance" / "System Instance" and add missing elements
4. **Stage 9 planning:** With architectural foundations clarified, Stage 9 planning can proceed

## Session metrics

- **Console/repo commits:** None (discussion session)
- **Ontology changes:** None
- **SPARQL queries:** None
- **Vault documents created:** 1 (architectural clarification note)
- **Register updates:** None required

---

*Session 196 complete. Architectural review achieved core clarification goals. Campus Walk II and diagram revision identified as follow-on work.*
