---
tags:
  - session-report
date: 2026-04-01
status: current
session: 94
---
# Session 94 Report — 1 April 2026

**Session type:** Mixed (console styling + governance refresh)
**Date:** 1 April 2026

---

## Summary

Session 94 delivered three substantial outcomes: a console dark mode background refinement, a comprehensive [[ontara - concept-graph-index|Concept Graph Index]] refresh (18 sessions overdue), and a systematic BSMM→SMM vault document rename pass across four major reference documents and multiple concept graph notes.

---

## 1. Console Dark Mode Background (Priority A verification + visual refinement)

Console commit verified complete (Priority A from [[session-93-report-2026-03-31|Session 93]] prep note). A dark mode background refinement was applied to `app.css`:

- Dark mode body background changed from `var(--color-secondary-800)` (`#323f4b`) to `#29343f` — a midpoint between secondary-800 and secondary-900 (`#1f2933`), providing better differentiation from the left-hand navigation while being visually darker than the previous value.
- The full secondary-900 was tried first but was too close to the nav background; the midpoint value was selected after visual review.

---

## 2. Concept Graph Index Refresh (Priority C)

The [[ontara - concept-graph-index|Concept Graph Index]] was 18 sessions stale (last refreshed Session 75, threshold 5). A comprehensive refresh was completed:

### Metrics updated
- Weighted relationships: 79 → **96**
- Weighted elements: 27 → **33**
- Register count reference: ~180 → **~190**
- Concept notes count: 43 → **45** (two new notes created)

### New concept notes created
- **[[concept-stakeholder-model]]** (C7) — the sixth BMM concern, with implementation details from Sessions 76–81
- **[[concept-architectural-section]]** (B27) — the [[concept-architectural-section|ArchitecturalSection]] `part def` representing the 20 [[concept-dual-stack-architecture|dual-stack]] sections, implemented Session 87

### Broken wikilink fixed
- Heuristics reference: versioned filename → stable filename [[ontara-ref-weighted-relationship-heuristics-and-config|heuristics and configuration reference]]

### BSMM→SMM terminology (within index)
- Two Meta Models section updated with SMM terminology and six capability groups
- BMM concern list updated to include [[concept-stakeholder-model|StakeholderModel]]
- BMM/BSMM section label in concept inventory corrected to BMM/SMM

### Domain notes updated
- **[[domain-paws]]** — [[concept-stakeholder-model|StakeholderModel]] (7 instantiations, Session 81) and GovernanceMapping coverage added
- **[[domain-cafe]]** — BMM Coverage section added with [[concept-stakeholder-model|StakeholderModel]] (6 instantiations, Session 81)

### Deferred item refreshed
- **[[deferred-system-meta-model-extraction]]** — context updated to reflect the [[concept-dual-stack-architecture|dual-stack architecture]] (Session 73), [[ontara-ref-master-register|B25]] (Session 76), [[concept-architectural-section|ArchitecturalSection B27]] (Session 87), and SMM rename (Session 92). Resolution criteria updated.

### YAML frontmatter and provenance
- YAML frontmatter added to index: `session: 94`, `date: 2026-04-01`, `status: current`
- Provenance line updated with comprehensive Session 94 entry

---

## 3. BSMM→SMM Vault Document Pass (Priority D)

A systematic pass updating "BSMM" terminology to "SMM" across major vault reference documents. This completes the rename that was executed in the codebase (model files, generator, console) during [[session-93-report-2026-03-31|Session 93]].

### [[ontara-ref-vision-architecture|Vision and Architecture Reference]] (11 edits)
- §2.1 Layer 4: "Business System Meta Model (BSMM)" → "System Meta Model (SMM)" with rename note
- §2.2 dual-stack description: "BMM and BSMM" → "BMM and SMM"
- Right-stack table: "BSMM General vocabulary" → "SMM General vocabulary"
- Horizontal mappings table: "BSMM" → "SMM"
- §2.3 full SMM description rewritten with rename note and SMM terminology throughout
- Mapping tiers: "General BSMM / Tailored BSMM" → "General SMM / Tailored SMM"
- §3.1 Component Catalogue: "BMM/BSMM" → "BMM/SMM"
- §3.1 Architecture view: "First BSMM-side" → "First SMM-side"
- §6.1 operational simulation: "BSMM made live" → "SMM made live"
- §7.6 two registers: "BSMM side/content" → "SMM side/content"
- §10 A4 one-liner: "BSMM" → "SMM"
- §11 carried forward: "first BSMM-side" → "first SMM-side"

### [[ontara-ref-master-register|Master Register]] (8 edits)
- Tier 1 A4 one-liner: "Business System Meta Model" → "System Meta Model"
- A4 full entry: updated with "stakeholders" in BMM concern list, "System Meta Model" with rename note
- A4 cross-cutting touchpoints: "all BSMM work" → "all SMM work"
- B1: Layer 4 description updated with SMM and rename note
- B8: renamed from "Business System Meta Model — currently implicit" to "System Meta Model — currently distributed" with comprehensive update including B27 implementation
- B11 and B12: "BMM and BSMM" / "General BSMM" → "BMM and SMM" / "General SMM"
- B25: header "BSMM" → "SMM", description updated
- B26: "Each BSMM General concept" → "Each SMM General concept"

### [[ontara-ref-strategic-snapshot|Strategic Snapshot]] (6 edits)
- §2.2 horizontal mappings: "General BSMM / Tailored BSMM" → "General SMM / Tailored SMM"
- §2.2 rename caveat: updated to reflect codebase complete (S93), vault documents updated (S94)
- §2.7 right-side vocabulary: "BSMM vocabulary" → "SMM vocabulary"
- §3.1 elements row: "BSMM elements" → "SMM elements"
- §3.6 concept graph notes count: 67 → ~82 (corrected with 45 concepts)
- §4.2 current state: three workstream status rows updated (dual-stack, campus walk, rename), §4.3 priorities updated

### Concept Graph Principle Note ([[principle-two-meta-model-distinction|A4]])
- Description updated from "business system meta model" to "System Meta Model (SMM)" with rename note

---

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[principle-two-meta-model-distinction\|A4]] (Two meta model distinction) | Central to the BSMM→SMM rename — the naming decision for the system meta model |
| [[principle-discipline-as-load-bearing-structure\|A9]] (Discipline as load-bearing structure) | [[ontara - concept-graph-index|Concept graph]] refresh (18 sessions overdue), systematic vault rename pass — governance maintenance |
| [[principle-self-describing-system\|A2]] (Self-describing system) | Reference documents and concept graph now accurately describe the current platform state |
| [[concept-co-evolution\|J2]] (Co-evolution) | Documentation updated to reflect codebase terminology changes |
| [[concept-architectural-section\|B27]] (Architectural section) | New concept note created |
| [[concept-stakeholder-model\|C7]] (StakeholderModel) | New concept note created; domain notes updated with coverage data |

No new register concepts introduced. No concepts contradicted or retired.

---

## Emergent Ideas

No new emergent ideas captured this session.

---

## Open Questions / Deferred Items

- **Visual architecture map Phase 2** — Priority B from prep note, not started this session. Remains next priority for console work. Design in [[ontara-discussion-visual-architecture-page-2026-03-31|visual architecture page discussion paper]] §10.
- **`@ArchitecturalLocation` / `@PurposiveDescription` SysML annotation strings** — still reference "BSMM" in places. Deferred per Code instructions.
- **`bsmm-general-vocabulary` section name** — structural SysML identifier; architecture map display override stays.
- **Historical discussion papers** — some still reference "BSMM" in body text. These are working documents recording decisions as they were made; updating body text is lower priority.
- **Systematic documentation review** — first trigger at ~Session 95 per §7.3 of [[ontara-workflow-development-guide|workflow guide]].
- **Console commit** — Session 94 dark mode change needs committing.

---

## Tier 1 Principles Relevant to This Session

| Principle | How honoured |
|---|---|
| [[principle-discipline-as-load-bearing-structure\|A9]] (Discipline as load-bearing structure) | Primary driver — concept graph refresh and systematic rename pass |
| [[principle-self-describing-system\|A2]] (Self-describing system) | Platform documentation now accurately reflects current terminology and state |
| [[principle-two-meta-model-distinction\|A4]] (Two meta model distinction) | SMM rename sharpens the naming to better parallel BMM; vault documents now consistent |
| [[concept-co-evolution\|J2]] (Co-evolution) | Documentation kept in sync with codebase terminology |
| [[concept-non-constraining\|J3]] (Non-constraining) | No architectural decisions made or foreclosed |

---

*Session 94 report written 1 April 2026.*
