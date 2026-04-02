---
tags:
  - governance
  - review
date: 2026-04-02
status: current
session: 108
---
# Session 108 — Systematic Documentation Review Findings

**Date:** 2 April 2026 (Session 108)
**Purpose:** Second systematic documentation review under [[ontara-workflow-development-guide|workflow guide]] §7.3 convention. First review was Session 95 (22 findings across 10 categories). This review covers Sessions 96–107 (13 sessions of activity since the last review).
**Scope:** All standing reference documents, foundations papers, discussion papers, guides, and the emergent ideas log.

---

## Contents

- [[#1. Summary|§1. Summary]]
- [[#2. Staleness Findings|§2. Staleness Findings]]
- [[#3. Terminology and Consistency Findings|§3. Terminology and Consistency Findings]]
- [[#4. Factual Accuracy Findings|§4. Factual Accuracy Findings]]
- [[#5. Structural and Governance Findings|§5. Structural and Governance Findings]]
- [[#6. Emergent Ideas Log Findings|§6. Emergent Ideas Log Findings]]
- [[#F18 — Console data sources stale; no periodic check convention exists [New convention needed]|§6a. Console Currency Finding (F18)]]
- [[#7. Findings Summary Table|§7. Findings Summary Table]]

---

## 1. Summary

This review examined 10 core documents and the emergent ideas log, covering the period since the Session 95 review. The project has been highly productive in this period — Stage 5 Phase 1 (knowledge graph implementation, Sessions 100–107), Stage 4 Phase 1 formal closure, two foundations papers refreshed to v3, and substantial governance work. The overall health of the documentation is good, but several documents have now exceeded their staleness thresholds and one document carries significant accumulated terminology debt.

**Finding count:** 18 findings across 7 categories.

---

## 2. Staleness Findings

### F1 — Vision and Architecture Reference: 19 sessions stale [Fix: schedule refresh]

**Document:** [[ontara-ref-vision-architecture|Vision and Architecture Reference]]
**Current version:** v5, Session 89
**Threshold:** 10 sessions
**Overage:** 19 sessions (Session 89 → Session 108)

This is the most significant staleness finding. The Vision and Architecture Reference is missing all of the following:

- Sessions 90–91: 3D WebGL weighted relationship graph with 14 interactive features (the document still describes D3.js as the implementation)
- Session 92: Visual architecture map Phase 1 — interactive spatial rendering of dual-stack sections
- Sessions 92–94: BSMM→SMM rename across codebase and vault
- Session 95: First systematic documentation review
- Session 96: Foundations papers refresh to v3
- Sessions 97–98: Knowledge graph architecture (9 binding decisions, three-stratum graph, authority zones, @BfoType mapping)
- Session 99: @BfoType annotations applied to all 34 BMM elements
- Sessions 100–107: Entire Stage 5 Phase 1 (GraphDB setup, OWL pipeline, SPARQL validation — 24,663 domain triples, 306 correspondence triples)
- Emergent Ideas Log count is wrong (says "17 entries E001–E017"; actual is 20, E001–E020)
- Related Documents section lists Emergent Ideas Log as "17 entries"

This document is now substantially behind the project state. A v6 refresh via archive-before-refresh is overdue.

**Classification:** Schedule fix — v6 refresh should be Priority A for this or the next session.

### F2 — Strategic snapshot: needs post-S107 update [Fix: note for awareness]

**Document:** [[ontara-ref-strategic-snapshot|Strategic Reference]]
**Current version:** Session 106 refresh
**Threshold:** 5 sessions

The strategic snapshot is 2 sessions stale (Session 106 → Session 108). This is within the 5-session threshold. However, §4.3 "What comes next" still lists "Stage 5 Phase 1 Step 6 — documentation and governance" as the first immediate priority, and carried forward governance items (BSMM→SMM annotation pass, E018, Stage 4 Phase 1 formal closure) — all of which were completed in Session 107. The snapshot's §4.2 table should mark both Stage 5 Phase 1 and Stage 4 Phase 1 as formally closed.

**Classification:** Note for awareness — not yet at threshold, but the "what comes next" section is now factually incorrect in its first two priorities.

### F3 — Foundations papers: within threshold [No action]

All three foundations papers were refreshed to v3 in Session 96 (12 sessions ago). The 15-session staleness threshold has not been exceeded. No refresh needed.

### F4 — Concept Graph Index: staleness unknown [Fix: check]

The [[ontara - concept-graph-index|Concept Graph Index]] was refreshed in Session 94 (14 sessions ago). Threshold is 5 sessions. If concept notes have been created since Session 94 (likely, given E019 and E020 routing produced B28 and B29 concept notes in Session 99), the index needs refreshing.

**Classification:** Fix now — check and refresh if needed.

---

## 3. Terminology and Consistency Findings

### F5 — Service Business Meta Modelling: pervasive "BSMM" terminology [Fix: schedule]

**Document:** [[ontara-service-business-meta-modelling|Service Business Meta Modelling]]
**Session:** 82/90

This document still uses "BSMM" extensively throughout, despite the BSMM→SMM rename (Session 92). The Session 107 prep note confirms the BSMM→SMM discussion paper annotation pass is complete, but this foundations paper was revised in Session 82 (pre-rename) and verified in Session 90 (where the verification was specifically about the StakeholderModel incorporation, not a terminology pass). Specific instances:

- §9 heading: "The Two Meta Models" — correct, but body text references "BSMM" in the mapping tree diagram and throughout §9.1–9.3
- §7.9 gaps table: "BSMM extraction as named meta model"
- §11.2: "BSMM extraction"
- Multiple table cells contain piped wikilinks that may need escaped-pipe checking

A terminology annotation note was added to this paper during the Session 107 annotation pass, but the underlying text has not been changed.

**Classification:** Schedule fix — this is the last major document carrying pervasive BSMM terminology. A targeted find-and-replace pass would be proportionate (not a full refresh).

### F6 — Service Business Meta Modelling: Session 82 header, no version history table [Fix: schedule]

This document's header says "Date: 28 March 2026 (Session 82 revision)" but does not have a version history table like the other two foundations papers (which gained version history tables in Session 96). The Session 96 scope was Architecture Principles and Modelling Strategy; SBMM was not refreshed at that time.

**Classification:** Schedule fix — add a version history table when next touching this document.

### F7 — Workflow guide: §3.4 "Stage 4 Phase 1 begun" reference is stale [Fix now]

The weighted relationship graph description in the vision reference (§3.4) still describes "D3.js force-directed graph and configuration table operational (Session 72). Graph rendering refinements outstanding." This was replaced by the 3D WebGL implementation in Sessions 90–91 and formally closed in Session 107. However, this is in the Vision Reference (F1), not the workflow guide itself. The workflow guide's own content appears current.

**Classification:** Subsumed by F1 — will be fixed in the vision reference refresh.

---

## 4. Factual Accuracy Findings

### F8 — Strategic snapshot §3.5: pipeline description incomplete [Note for awareness]

The strategic snapshot §3.5 describes the generation pipeline and KG tooling but does not mention the `@BfoType` extraction capability added to `gen_model_introspection.py` in Session 103. The `@BfoType` annotation type should be listed alongside the other annotation types the generator extracts.

**Classification:** Note for awareness — minor, will be caught in the next snapshot refresh.

### F9 — Service Business Meta Modelling: element counts say "48 total" but BMM elements are "34" [Verify]

§3.3 of the SBMM paper gives a total of 48 elements (34 core BMM + 11 BusinessScenarios + 3 BusinessStrategy). The strategic snapshot and all other documents consistently say "34 BMM elements." The 48 count is correct for the total BMM vocabulary including projection/strategy elements, but the distinction between "34 core BMM elements" and "48 total BMM vocabulary" could cause confusion — especially since the strategic snapshot and vision reference both say "34 elements across 6 concerns."

**Classification:** Note for awareness — the documents are internally consistent (34 core + 14 projection/strategy = 48), but the double count risks confusion.

### F10 — Vision reference §3.4: Stage 4 Phase 1 described as "substantially complete" [Stale]

The vision reference says "Phase 1 (weighted relationship graph) is built — D3.js force-directed graph and configuration table operational (Session 72). Graph rendering refinements outstanding." This is now doubly stale: (a) the implementation was rebuilt as 3D WebGL in Sessions 90–91, and (b) Phase 1 was formally closed in Session 107.

**Classification:** Subsumed by F1.

### F11 — Ontological grounding section in SBMM paper (§11.4) says "directional commitment — not yet implemented" [Stale]

§11.4 says ontological grounding is "a directional commitment — not yet implemented." As of Session 107, Stage 5 Phase 1 is complete with BFO/CCO/IAO loaded into GraphDB, all 34 BMM elements mapped via @BfoType annotations and pipeline-generated OWL, and 10/10 SPARQL validation queries passing. B18 (BFO) was upgraded to binding in Session 73; B23 (OWL 2 DL) is binding. The statement is factually incorrect as of the current project state.

**Classification:** Schedule fix — should be corrected when the SBMM paper is next touched (could be combined with F5/F6).

---

## 5. Structural and Governance Findings

### F12 — Architecture Papers Index: currency unknown [Fix: check]

The [[Ontara - Architecture Papers Index|Architecture Papers Index]] has a 10-session threshold. Its last update is not recorded in my current reads. Since Sessions 97–98 produced the KG architecture paper and @BfoType mapping paper, and these are significant architectural papers, the index likely needs updating.

**Classification:** Fix now — check and update if needed.

### F13 — Repo README.md: next check due Session 114 [No action]

The Session 108 prep note records that the repo README currency check was performed in Session 104 with the next check at Session 114. No action needed.

### F14 — Vault git commit reminder [Awareness]

The prep note records "Last noted Session 106." The 5-session cadence means the next reminder is due at Session 111. No action needed now but worth noting.

---

## 6. Emergent Ideas Log Findings

### F15 — Three entries unrouted for 45+ sessions [Review]

Three entries in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] have remained unrouted for extended periods:

- **E007** (Hookmark cross-boundary references, Session 53) — 55 sessions unrouted. The core question (systematic vs selective Hookmark adoption) has not been revisited. The caveat about Git operations breaking Hookmark links may have reduced its utility. Consider whether to retire, route to a convention note, or mark as deferred.
- **E009** (CostDriver.linkedResource multiplicity fix, Session 58) — 50 sessions unrouted. This is a straightforward code change that keeps being deferred. The prep note carries it forward as Priority B item 1.
- **E010** (Obsidian CLI vault access, Session 61) — 47 sessions unrouted. The CLI capability was established; the full workflow implications were "to be explored in a future session." The workflow guide has not been revised to reflect CLI-enabled Code capabilities. Consider whether this has been overtaken by practical experience.

**Classification:** Review — assess whether these should be routed, retired, or explicitly deferred with a rationale.

### F16 — Two entries unrouted for 35+ sessions [Review]

- **E011** (IG/cybersecurity as foundational concern, Session 62) — 46 sessions unrouted. Acknowledged as a significant future workstream but no scoping paper has been produced. The strategic snapshot carries it as a risk (R8-related) and horizon item. This is appropriately deferred but should be explicitly marked as such in the log.
- **E013** (Ontologically-informed console view differentiation, Session 70) — 38 sessions unrouted. Captured for "future architectural planning" — no concrete action taken. Explicitly noted as "not actionable in Stage 4." This is appropriately deferred.

**Classification:** Note for awareness — these are appropriately deferred but the log entries could benefit from explicit "deferred: [rationale]" status annotations.

### F17 — E014 status says "Partially" but concepts are registered and architecture captured [Review routing status]

[[ontara-workflow-emergent-ideas-log|E014]] (Coordinate space snapshots and goal-seeking computation) is marked "Routed: Partially" with the note "Formal discussion paper formalising snapshot taxonomy and goal-seeking architecture not yet produced." However, L8 and L9 are registered, concept notes exist, and the architecture is captured in the dual-stack discussion paper §8. The "formal discussion paper" may not be needed — the concept is substantially routed. Consider updating to "Routed: Substantially" or "Routed: Fully" with an acknowledgement that a standalone paper may be produced if the simulation workstream becomes active.

**Classification:** Fix now — update routing status.

---

### F18 — Console data sources stale; no periodic check convention exists [New convention needed]

The [[ontara-ref-vision-architecture|Ontara Console]]'s Platform Architecture page (and other model-driven views) renders data from `model-introspection.json`, generated from the SysML model. While the generation pipeline keeps structural data in sync automatically, **several categories of model content can silently drift** from the actual project state because they encode status or descriptive claims that are not updated by implementation work elsewhere.

**Categories of driftable content:**

1. **`implementationStatus` on architectural sections.** These enum values in `architectural-structure.sysml` do not auto-update when implementation work advances a section. Stage 5 Phase 1 (Sessions 100–107) advanced at least four sections without updating their status badges:
   - **BFO** — currently `referenced`; BFO 2020 is loaded and queryable in GraphDB → should be `implemented`
   - **Knowledge Graph** — currently `referenced`; GraphDB operational with 24,663 domain triples, pipeline, and validation suite → should be `implemented` (Phase 1 scope)
   - **Domain Ontologies** — currently `referenced`; CCO and IAO loaded into GraphDB → should be `implemented`
   - **Mapping Ontology** — currently `referenced`; correspondence graph (306 triples) is the concrete realisation of B24 → should be `designed` or `implemented`

2. **`@ArchitecturalLocation` summary strings.** Short prose that can become factually incorrect. BFO's `persistenceSummary` currently says "not yet implemented" — now false. Knowledge Graph descriptions will need updating as Phase 2 work proceeds.

3. **`@PurposiveDescription` on BMM and architectural elements.** Less likely to drift (purpose vs status), but should be spot-checked periodically.

4. **Hardcoded content in Svelte components.** The `REFLECTIVE_CAPABILITIES` array, `DISPLAY_OVERRIDES` map, `HORIZONTAL_MAPPINGS` array, and `INFRA_SECTIONS` list in the Architecture map page (`console/src/routes/architecture/map/+page.svelte`) are not model-driven. Any structural change to the architecture requires a manual code update.

**Proposed convention — Console Data Source Currency Check:**

Add to the workflow guide §7.1 staleness thresholds table:

| Artefact | Maximum staleness | Mandatory refresh trigger |
|---|---|---|
| `architectural-structure.sysml` implementation statuses and `@ArchitecturalLocation` summaries | 10 sessions | Any stage or phase boundary that changes a section's implementation state |
| Console hardcoded content (component arrays, display overrides) | 10 sessions | New architectural sections, renamed sections, or new console views |

The check should be lightweight: at session open, if the session number is a multiple of 10 (or a stage/phase has just closed), Claude scans the architectural section `implementationStatus` values against the current project state and flags mismatches. This can be done in 2–3 minutes as part of O2 (currency check).

**Immediate action required:** Update `implementationStatus` for BFO, Knowledge Graph, Domain Ontologies, and Mapping Ontology in `architectural-structure.sysml`, and update the corresponding `@ArchitecturalLocation` summary strings where they contain stale claims. Then regenerate `model-introspection.json` and verify in the console. This is a Code task.

**Classification:** New convention — add to workflow guide §7.1; schedule Code task for implementation status updates.

---

## 7. Findings Summary Table

| # | Finding | Category | Classification | Priority |
|---|---|---|---|---|
| F1 | Vision reference 19 sessions stale | Staleness | Schedule refresh | High |
| F2 | Strategic snapshot §4.3 priorities now incorrect | Staleness | Note for awareness | Low |
| F3 | Foundations papers within threshold | Staleness | No action | — |
| F4 | Concept Graph Index: staleness unknown | Staleness | Check now | Medium |
| F5 | SBMM paper: pervasive BSMM terminology | Terminology | Schedule fix | Medium |
| F6 | SBMM paper: no version history table | Terminology | Schedule fix | Low |
| F7 | Vision ref §3.4 Stage 4 description stale | Accuracy | Subsumed by F1 | — |
| F8 | Strategic snapshot §3.5 missing @BfoType extraction | Accuracy | Note for awareness | Low |
| F9 | SBMM "48 total" vs "34 BMM" count distinction | Accuracy | Note for awareness | Low |
| F10 | Vision ref §3.4 Stage 4 Phase 1 status stale | Accuracy | Subsumed by F1 | — |
| F11 | SBMM §11.4 says ontological grounding "not yet implemented" | Accuracy | Schedule fix | Medium |
| F12 | Architecture Papers Index: currency unknown | Governance | Check now | Medium |
| F13 | Repo README.md: next check Session 114 | Governance | No action | — |
| F14 | Vault git commit: next reminder Session 111 | Governance | No action | — |
| F15 | Three emergent ideas unrouted 45+ sessions | Emergent ideas | Review | Medium |
| F16 | Two emergent ideas unrouted 35+ sessions | Emergent ideas | Note for awareness | Low |
| F17 | E014 routing status understated | Emergent ideas | Fix now | Low |
| F18 | Console data sources stale; no periodic check convention | Console currency | New convention + Code task | High |

**Action summary:**
- **Fix now (3):** F4 (Concept Graph Index check), F12 (Architecture Papers Index check), F17 (E014 routing status)
- **Schedule refresh (1):** F1 (Vision reference v6 — high priority, this or next session)
- **Schedule fix (3):** F5 (SBMM terminology pass), F6 (SBMM version history table), F11 (SBMM §11.4 correction)
- **New convention + Code task (1):** F18 (add console data source check to workflow guide §7.1; update four `implementationStatus` values and stale `@ArchitecturalLocation` summaries in `architectural-structure.sysml`)
- **Review (1):** F15 (three long-unrouted emergent ideas)
- **Note for awareness (5):** F2, F8, F9, F14, F16
- **No action (3):** F3, F13, F14
- **Subsumed (2):** F7, F10 (both covered by F1)

---

*Findings document produced 2 April 2026, Session 108. Updated with F18 (console data source currency check).*
