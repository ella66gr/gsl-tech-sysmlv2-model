---
tags:
  - governance
  - review
date: 2026-04-03
status: current
session: 123
---
# Session 123 — Systematic Documentation Review Findings

**Date:** 3 April 2026 (Session 123)
**Purpose:** Third systematic documentation review under [[ontara-workflow-development-guide|workflow guide]] §7.3 convention. Previous reviews: Session 95 (22 findings), Session 108 (18 findings). This review covers Sessions 109–122 (15 sessions of activity since the last review).
**Scope:** All standing reference documents, foundations papers, discussion papers, guides, reference documents, the emergent ideas log, and the concept graph.

---

## Contents

- [[#1. Summary|§1. Summary]]
- [[#2. Staleness Findings|§2. Staleness Findings]]
- [[#3. Terminology and Consistency Findings|§3. Terminology and Consistency Findings]]
- [[#4. Structural and Governance Findings|§4. Structural and Governance Findings]]
- [[#5. Conceptual Precision and Accuracy Findings|§5. Conceptual Precision and Accuracy Findings]]
- [[#6. Emergent Ideas Log Findings|§6. Emergent Ideas Log Findings]]
- [[#7. Lost or Forgotten Topics|§7. Lost or Forgotten Topics]]
- [[#8. Integration Opportunities|§8. Integration Opportunities]]
- [[#9. Findings Summary Table|§9. Findings Summary Table]]

---

## 1. Summary

This is the third systematic documentation review under the §7.3 convention. The period since the last review (Sessions 109–122) has been highly productive: Stage 5 Phase 2 was fully implemented and closed (Sessions 111–120), a major vault restructure was completed (Session 120), the deontic governance workstream was opened with a substantial discussion paper (Session 121), and the architecture papers index was consolidated (Session 121).

The overall health of the documentation is good. The Session 108 findings have been substantially addressed — F1 (vision reference) was refreshed at Session 109, F5/F6/F11 (SBMM paper) were fixed at Session 110, F18 (console data source convention) was established in the workflow guide. However, several documents have now exceeded their staleness thresholds again, and the rapid pace of Sessions 111–122 has introduced new drift in some older documents.

**Finding count:** 19 findings across 8 categories.

---

## 2. Staleness Findings

### F1 — Concept Graph Index: 15 sessions stale [Fix: schedule refresh]

**Document:** [[ontara - concept-graph-index|Concept Graph Index]]
**Current version:** Session 108
**Threshold:** 5 sessions
**Overage:** 15 sessions (Session 108 → Session 123)

This is the most significant staleness finding. The index has not been refreshed since Session 108, significantly exceeding its 5-session threshold. Specific gaps:

- The concept notes inventory table lists 45 concepts — the actual count is still 45, but two registered concepts that are frequently referenced lack individual notes: B28 (three-stratum knowledge graph architecture, registered Session 99) and B29 (authority zones, registered Session 99). These should have concept notes as wikilink targets.
- The "Architectural Principles" table references "Architecture Principles (v2)" in the Source column — this should be updated to v3 (Session 96 refresh).
- The A4 row in the principles table says "BMM/BSMM separation" — should read "BMM/SMM separation" (BSMM→SMM rename, Session 92). This was likely missed because the Session 94 concept graph refresh predated the terminology pass reaching this document.
- The "Two Meta Models" section body text says "Currently distributed across Foundation, ServiceDelivery, Platform, Knowledge, Operations, PatternCatalogue" — this remains accurate but does not mention `architectural-structure.sysml` (Session 87) or the six capability groups design (Session 76, B25), which are now significant SMM-side artefacts.
- The Paws domain row says "General vocabulary only" — Paws has had full StakeholderModel instantiation since Session 81 (7 instantiations). This should read "General vocabulary + StakeholderModel".
- The deferred item `deferred-string-to-typed-ref-migration` is listed as an active deferred item but was resolved in Session 58. While the note itself carries a `resolved` tag and full resolution section, the Concept Graph Index presents it without qualification alongside genuinely open deferred items.

**Classification:** Schedule fix — refresh the Concept Graph Index. Priority A (significantly overdue).

### F2 — Vision and Architecture Reference: 14 sessions stale [Fix: schedule refresh]

**Document:** [[ontara-ref-vision-architecture|Vision and Architecture Reference]]
**Current version:** v6, Session 109
**Threshold:** 10 sessions
**Overage:** 14 sessions (Session 109 → Session 123)

The Vision Reference was refreshed to v6 in Session 109 (resolving Session 108's F1). It is now 14 sessions stale, exceeding the 10-session threshold. Missing content:

- Sessions 111–120: Stage 5 Phase 2 in its entirety — disjointness axioms, 14 object properties, 9 cardinality restrictions, Robot + HermiT full OWL 2 DL reasoning, pipeline extension for typed refs and weighted relationship reification, ontological hierarchy and KG status console views. The correspondence graph grew from 306 to 1,378 triples. This is a major omission.
- Session 119: Ontology console view (13th view) — BFO→CCO/IAO→BMM collapsible hierarchy tree + KG Status panel.
- Session 121: Deontic governance discussion paper — the most significant new architectural contribution since Session 73. Not yet reflected in the vision reference.
- §5.8 "Knowledge graph implementation status" will describe Phase 1 only.
- Console view count: document likely says 12; actual is 13 (ontology view added Session 119).
- E021 (global console navigation context) captured Session 119 — not reflected.

**Classification:** Schedule refresh — v7 via archive-before-refresh. Priority B (overdue but less critical than F1 since the strategic snapshot at Session 120 carries the current state).

### F3 — Shell Commands Reference: 70 sessions stale [Fix: schedule refresh]

**Document:** [[ontara-ref-shell-commands|Shell Command Reference]]
**Current version:** Session 53
**Threshold:** Not formally defined (but this is a reference document)

This document has not been updated since Session 53 — 70 sessions ago. It is missing all of the following:

- **Knowledge graph pipeline scripts:** `gen_owl_pipeline.py` (Session 105), `setup_graphdb.py` (Session 101), `validate_kg.py` (Session 106), `reason_kg.py` (Session 115) — four major scripts with their command-line flags and usage patterns.
- **Shared parser:** `sysml_parser.py` (Session 104) — the shared module used by multiple generators.
- **Archive path in §9:** Uses an obsolete vault path (`02 ARCHITECTURE & MODELLING/Ontara/...`) that predates the Session 63 vault restructure.
- **Contents index format:** Uses GFM-style anchors (`[text](#anchor)`) — should be Obsidian-native `[[#heading|display text]]`.

The Shell Commands Reference is a practical working document. Its extreme staleness means a developer (or Claude Code) consulting it for KG pipeline commands would find nothing.

**Classification:** Schedule fix — full refresh. Priority A.

### F4 — Claude Tooling Guide: header says Session 61 [Fix: note for awareness]

**Document:** [[ontara-guide-claude-tooling|Claude Tooling Guide]]
**Current version:** Session 61 (header)
**Notes:** §7 was added in Session 107 (E018 resolution). The body content has been incrementally updated, but the YAML frontmatter and document header still say Session 61. This is cosmetically misleading — the document's content is more current than its header suggests. No formal staleness threshold exists for this document.

**Classification:** Note for awareness — update the header date/session when next touching the document.

### F5 — Non-technical overview: 52 sessions stale [Fix: note for awareness]

**Document:** [[ontara-non-technical-overview|Non-technical Overview]]
**Current version:** Session 71
**Notes:** Written for a non-technical reader (Sam). The document's purpose is stable overview prose, not a session-by-session current state. However, it predates: the dual-stack architecture becoming the central organising concept, the knowledge graph implementation, the ontological grounding work, the governance workstream, and the console growing from ~6 views to 13. The document describes Ontara accurately at a conceptual level but its description of what is built is significantly behind.

**Classification:** Note for awareness — a refresh would be valuable but is not urgent. Could be a good exercise when the platform next reaches a natural resting point.

---

## 3. Terminology and Consistency Findings

### F6 — "Two Meta Models Clarification" document: pervasive BSMM terminology and pre-StakeholderModel content [Note for awareness]

**Document:** [[ontara-architecture-clarification-two-meta-models|Two Meta Models Clarification]]
**Session:** 32

This document uses "Business System Meta Model" (BSMM) throughout — it predates the Session 92 rename. It also lists only five BMM concerns (predating the Session 76–81 StakeholderModel addition). Its YAML header uses old `source_repo`/`source_path` fields that reference a pre-Session-63 repo structure.

The document is archived as `status: completed` and is primarily historical. The live reference for the two meta model distinction is now in the [[ontara-architecture-platform-principles|Architecture Principles]] paper and the [[ontara-ref-strategic-snapshot|strategic snapshot]]. However, the Architecture Papers Index still links to it under "Business Meta Model" as a current reference, which could mislead a reader.

**Classification:** Note for awareness — consider adding a "superseded by" note at the top of the document, or updating the Architecture Papers Index description to flag it as historical.

### F7 — Concept Graph Index: residual "BSMM" in A4 principles row [Fix now]

As noted in F1, the A4 principle row says "BMM/BSMM separation". This should read "BMM/SMM separation".

**Classification:** Fix now — single term replacement.

### F8 — Session 34 KG architecture paper: GFM contents index and old YAML [Note for awareness]

**Document:** [[ontara-discussion-knowledge-graph-architecture-2026-03-15|KG Architecture (Session 34)]]

Uses GFM-style contents index anchors and old YAML header format (`source_repo`, `source_path`, `Project: GenderSense (GSL)`). The Architecture Papers Index correctly notes this is "Superseded in scope by the Session 97 KG architecture paper" — but the document itself carries no such annotation. A reader finding it via search or backlinks would not know it is largely historical.

**Classification:** Note for awareness — add a "Superseded" header note.

---

## 4. Structural and Governance Findings

### F9 — Research & Background Index: 20 sessions stale [Fix: check]

**Document:** [[ontara - index-research-background|Research & Background Index]]
**Current version:** Session 103
**Threshold:** 5 sessions
**Overage:** 20 sessions

No new research documents appear to have been added to `06 Ontara Research & Background Notes` since Session 103 (the file listing matches the index entries). If that is accurate, no content update is needed — but the YAML `date`/`session` should be updated to confirm it was verified current.

However, the deontic governance paper (Session 121) references Donohue (2017) "Toward a BFO-Based Deontic Ontology" as a key external source. If a Perplexity or Claude research document was produced during the governance workstream preparation, it should be captured here. Worth checking with Ella.

**Classification:** Check — verify no new research documents are unindexed. Update YAML to current session if verified clean.

### F10 — Duplicate file deletion: carried forward but possibly already resolved [Verify]

The Session 123 prep note carries forward "Delete the duplicate index file: `DUPLICATE-TO-DELETE-ontara - index-exploratory-discussion-papers.md` in `04 Ontara Architecture`." However, the current directory listing of `04 Ontara Architecture` does not contain this file. It may have been deleted during the Session 120 vault restructure or by Ella between sessions.

**Classification:** Verify with Ella — if already deleted, close this carried-forward item.

### F11 — Deferred item O25 resolved but concept graph still lists it as active [Fix now]

The [[deferred-string-to-typed-ref-migration|deferred-string-to-typed-ref-migration]] note is correctly tagged as `resolved` in its YAML and has a full Resolution section documenting the Session 58 closure. However, the Concept Graph Index's Deferred Items table lists all three deferred items equally, without distinguishing resolved from active. A reader scanning the index would not know O25 is closed.

**Classification:** Fix now — add "(resolved)" annotation in the Concept Graph Index deferred items table, or remove it from the "Deferred" section and note it in the "Two-Layer Architecture" prose.

### F12 — Vault structure description in workflow guide §6.2 uses old folder names [Fix: schedule]

The workflow guide §6.2 "Vault structure" table lists 8 subfolders with the old naming convention (e.g. "01 Ontara - START HERE", "02 Ontara Platform Development", "05 Ontara Exploratory & Discussion Papers"). The Session 120 vault restructure reduced the count to 7 subfolders with updated names (e.g. "01 Ontara START HERE", "02 Ontara Development", "04 Ontara Architecture"). The memory system records the updated structure, but the workflow guide's own §6.2 has not been updated.

**Classification:** Schedule fix — update §6.2 to reflect the Session 120 restructure. Priority B (the memory system carries the correction, but the workflow guide is the canonical reference and should be accurate).

---

## 5. Conceptual Precision and Accuracy Findings

### F13 — Concept Graph Index: A4 principle description says "Two Meta Models Clarification" as source [Note for awareness]

The A4 row in the principles table cites [[ontara-architecture-clarification-two-meta-models|Two Meta Models Clarification]] as its source. While historically accurate, the current authoritative statement of A4 is in the [[ontara-architecture-platform-principles|Architecture Principles (v3)]] paper. The Two Meta Models Clarification document is largely historical (see F6). The source attribution is not wrong but is misleading about where a reader should go to understand A4 today.

**Classification:** Note for awareness — update the source reference when refreshing the index (F1).

### F14 — B28 and B29 lack concept notes [Fix: create during enrichment]

B28 (three-stratum knowledge graph architecture) and B29 (authority zones for round-trip governance) were registered in the master register at Session 99. Both are T2 structural commitments with binding architectural significance. Neither has an individual concept note in `03 Ontara Concept Graph/concepts/`. These are frequently referenced across multiple documents (the KG architecture paper, the strategic snapshot, the emergent ideas log), so creating wikilink-target concept notes would improve vault navigability.

**Classification:** Fix — create `concept-three-stratum-graph.md` and `concept-authority-zones.md` during the enrichment pass or as a follow-up task.

---

## 6. Emergent Ideas Log Findings

### F15 — E021 remains unrouted (2 sessions) [Note for awareness]

E021 (global console navigation context with journey capture) was captured Session 119. It remains unrouted, which is appropriate given its recency — it was flagged for a dedicated design session in the Session 121 forward planning discussion, established as Priority 2 workstream. No action needed beyond confirming that the routing is tracked.

**Classification:** Note for awareness — appropriately unrouted; tracked in forward planning.

### F16 — E011 and E013 status annotations confirmed adequate [No action]

Both E011 (IG/cybersecurity) and E013 (ontologically-informed console views) received explicit "Deferred" status annotations at Session 110 (resolving Session 108's F15/F16). These are appropriately deferred with rationale. No further action needed.

E011 is partially subsumed by the governance workstream — the deontic governance paper (Session 121) explicitly notes in S121-Q7 that "the governance framework library subsumes part of this — GDPR, NHS DSPT, and Cyber Essentials could be frameworks in the library." This connection should be noted in E011's routing status when the log is next reviewed.

**Classification:** No action needed (E013). Minor update for E011 — note partial subsumption by governance workstream.

### F17 — Six new concepts from deontic governance paper (§17.2) not yet registered [Carry forward]

The deontic governance paper §17.2 proposes six new concepts for registration: deontic directive vocabulary, governance framework library, framework activation and obligation binding, normative instrument taxonomy, compliance as coordinate dimension, and supervised ingestion pipeline. These are not yet in the master register. The Session 123 prep note carries this forward as part of "continue the governance workstream."

**Classification:** Carry forward — registration should happen when the governance workstream resumes.

---

## 7. Lost or Forgotten Topics

### F18 — `reason_kg.py --save-summary` has been carried forward for 3 sessions [Note for awareness]

The task to run `reason_kg.py --save-summary` to replace the mock `reasoning-summary.json` with a live version has been carried forward since Session 120. It is a quick operational task that keeps being deferred in favour of higher-priority work. The mock data in the console's KG Status panel will show placeholder values until this is run.

**Classification:** Note for awareness — carry forward. Quick task, low priority, but the mock data could mislead a console user.

### F19 — Ears demonstrator (Session 97) has seen no progress in 26 sessions [Note for awareness]

The Ears demonstrator domain (community ear care) was outlined in Session 97 as the fifth demonstrator and second clinical domain, specifically motivated by OGMS (Ontology for General Medical Science) adoption. Domain notes exist ([[domain-ears|domain-ears.md]]), and it was assessed as a candidate workstream in the Session 121 forward planning discussion, but no implementation work has been done. The strategic snapshot correctly describes its status as "Outlined."

This is appropriately deferred — the governance workstream, Stage 5 Phase 2, and console work have taken priority. However, the project still has no second clinical pathway validating the meta model's clinical modelling claims. Risk R2 in the strategic snapshot acknowledges this.

**Classification:** Note for awareness — not forgotten, but the longest-standing unaddressed risk (R2). The deontic governance workstream may provide a natural integration point (S121-Q6 asks "How should the Ears demonstrator relate to this workstream?").

---

## 8. Integration Opportunities

### IO1 — Deontic governance paper + Ears demonstrator

The [[ontara-discussion-deontic-governance-architecture-2026-04-03|deontic governance paper]] (Session 121) explicitly identifies this integration opportunity in S121-Q6. CQC registration requirements, clinical safety standards, and NHS DSPT are all elaborated as archetype governance frameworks in the paper. The [[domain-ears|Ears]] demonstrator could exercise these frameworks as a clinical tenant, simultaneously validating the governance architecture and addressing R2 (no second clinical pathway).

### IO2 — E011 (IG/cybersecurity) + Governance Framework Library

The governance framework library concept (Session 121) provides the natural architectural home for GDPR, NHS DSPT, and Cyber Essentials — all of which were identified in [[ontara-workflow-emergent-ideas-log|E011]] as IG/cybersecurity modelling concerns. When E011 is eventually scoped, its scope will be substantially narrowed by the governance framework library architecture already in place. The E011 log entry should reference this when next updated.

### IO3 — B28/B29 concept notes + KG architecture paper cross-linking

Creating concept notes for B28 (three-stratum graph) and B29 (authority zones) would enable wikilink enrichment of the [[ontara-discussion-knowledge-graph-architecture-2026-04-01|KG architecture paper]], the [[ontara-ref-strategic-snapshot|strategic snapshot]], the [[ontara-workflow-emergent-ideas-log|emergent ideas log]] entries E019/E020, and future governance workstream documents that reference the [[concept-knowledge-graph|knowledge graph's]] internal structure.

---

## 9. Findings Summary Table

| # | Finding | Category | Classification | Priority |
|---|---|---|---|---|
| F1 | Concept Graph Index: 15 sessions stale | Staleness | Schedule refresh | High |
| F2 | Vision reference: 14 sessions stale | Staleness | Schedule refresh | Medium |
| F3 | Shell Commands Reference: 70 sessions stale | Staleness | Schedule refresh | High |
| F4 | Claude Tooling Guide: header date stale | Staleness | Note for awareness | Low |
| F5 | Non-technical overview: 52 sessions stale | Staleness | Note for awareness | Low |
| F6 | Two Meta Models Clarification: BSMM + 5 concerns | Terminology | Note for awareness | Low |
| F7 | Concept Graph Index: "BSMM" in A4 row | Terminology | Fix now | Low |
| F8 | Session 34 KG paper: GFM index + no superseded note | Terminology | Note for awareness | Low |
| F9 | Research & Background Index: 20 sessions stale | Structural | Check | Medium |
| F10 | Duplicate file: possibly already deleted | Structural | Verify | Low |
| F11 | O25 deferred item shown as active in CG Index | Structural | Fix now | Low |
| F12 | Workflow guide §6.2: old folder names | Structural | Schedule fix | Medium |
| F13 | CG Index: A4 source attribution misleading | Precision | Note for awareness | Low |
| F14 | B28 and B29 lack concept notes | Precision | Create notes | Medium |
| F15 | E021 unrouted (2 sessions) | Emergent ideas | Note for awareness | — |
| F16 | E011 partial subsumption by governance | Emergent ideas | Minor update | Low |
| F17 | Six governance concepts not yet registered | Emergent ideas | Carry forward | Medium |
| F18 | `reason_kg.py --save-summary` carried 3 sessions | Lost topics | Carry forward | Low |
| F19 | Ears demonstrator: 26 sessions, no progress | Lost topics | Note for awareness | Low |

**Action summary:**
- **Fix now (2):** F7 (BSMM→SMM in CG Index), F11 (O25 resolved annotation in CG Index)
- **Schedule refresh (3):** F1 (Concept Graph Index — high), F2 (Vision reference v7 — medium), F3 (Shell Commands Reference — high)
- **Schedule fix (1):** F12 (workflow guide §6.2 folder names)
- **Check (1):** F9 (Research & Background Index)
- **Verify (1):** F10 (duplicate file deletion)
- **Create notes (1):** F14 (B28, B29 concept notes)
- **Carry forward (2):** F17 (governance concepts registration), F18 (`reason_kg.py --save-summary`)
- **Minor update (1):** F16 (E011 subsumption note)
- **Note for awareness (7):** F4, F5, F6, F8, F13, F15, F19

**Comparison with previous reviews:**
- Session 95: 22 findings across 10 categories (first review — broad baseline)
- Session 108: 18 findings across 7 categories (strong productivity period; several high-priority fixes)
- Session 123: 19 findings across 8 categories (steady state; staleness is the primary theme)

The dominant pattern is **staleness from rapid progress** — the project has moved quickly through Sessions 109–122 and several reference documents have fallen behind. There are no fundamental conceptual errors, no conflicting documents, and no significant forgotten topics. The vault's intellectual health is good; it needs a maintenance pass to catch up.

---

*Findings document produced 3 April 2026, Session 123.*
