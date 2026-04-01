---
tags:
  - governance
  - review
date: 2026-04-01
status: current
session: 95
---
# Ontara — Systematic Documentation Review: Findings

*Ontara Platform — Review Document*

**Date:** 1 April 2026 (Session 95)
**Purpose:** First systematic documentation review as mandated by §7.3 of the [[ontara-workflow-development-guide|workflow guide]] (convention established [[session-93-report-2026-03-31|Session 93]]). A critical examination of all vault documentation for inconsistencies, redundant material, obsolete ideas, lost/forgotten topics, unrouted ideas, integration opportunities, and conceptual precision.
**Status:** Working document — findings to be acted on as categorised below.

---

## Contents

- [[#1. Summary|§1. Summary]]
- [[#2. Inconsistencies|§2. Inconsistencies]]
- [[#3. Terminology — BSMM→SMM Residual References|§3. Terminology — BSMM→SMM Residual References]]
- [[#4. Stale Metrics and Counts|§4. Stale Metrics and Counts]]
- [[#5. Redundant or Confusing Material|§5. Redundant or Confusing Material]]
- [[#6. Unrouted Emergent Ideas|§6. Unrouted Emergent Ideas]]
- [[#7. Lost or Forgotten Topics|§7. Lost or Forgotten Topics]]
- [[#8. Integration Opportunities|§8. Integration Opportunities]]
- [[#9. Conceptual Precision Issues|§9. Conceptual Precision Issues]]
- [[#10. Structural and Housekeeping Items|§10. Structural and Housekeeping Items]]
- [[#11. Action Summary|§11. Action Summary]]

---

## 1. Summary

This review examined the three foundations papers, the strategic snapshot, the vision reference, the master register, the Architecture Papers Index, the discussion papers index, the emergent ideas log, and the workflow guide. The vault is in good structural health overall — the governance practices established in Sessions 78–83 and reinforced since are working well. The issues found fall into three broad categories:

1. **Two foundations papers are stale** — the [[ontara-platform-architecture-principles|Architecture Principles]] (Session 64, 31 sessions ago) and the [[ontara-platform-modelling-strategy|SysML Modelling Strategy]] (Session 65, 30 sessions ago) have exceeded their 15-session staleness threshold and contain materially outdated content.
2. **BSMM→SMM terminology residue** — several documents, including the two stale foundations papers and some register entries, still use "BSMM" where "SMM" is now standard.
3. **A handful of emergent ideas have been sitting unrouted for an extended period** — E007, E009, E010, E011, E013 are all unrouted or partially routed, some since Session 53. See [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]].

---

## 2. Inconsistencies

### F-2.1 Architecture Principles §3 contradicts current BMM state (fix now)

The [[ontara-platform-architecture-principles|Architecture Principles]] paper (Session 64) says the BMM has **"28 elements across five concerns"** and refers to the system meta model as **"Business System Meta Model (BSMM)"** throughout §3. The BMM now has **34 elements across six concerns** ([[concept-stakeholder-model|StakeholderModel]] added Sessions 76–81), and "BSMM" was renamed to "SMM" in Session 92. This is a direct factual contradiction with the current state.

The paper also references a wikilink to the now-archived two meta models clarification document without noting its historical status.

### F-2.2 Architecture Principles §2 uses outdated comprehension metrics (fix now)

§2.1 states "28/28 coverage" for both authored and structural registers, and §2.2 states "79 `@WeightedRelationship` annotations." Current: 34/34 and 96 respectively. These are concrete factual claims that mislead a reader.

### F-2.3 SysML Modelling Strategy §1 uses outdated BMM metrics (fix now)

The executive summary states "28 elements across five concerns" and "10 navigable views" (now 12). §3 references the outdated "BSMM" terminology throughout. §7 references "11 top-level packages" (now 12, with `ArchitecturalStructure`). The comprehension and console sections need similar metric updates.

### F-2.4 SysML Modelling Strategy §1 references SBMM paper with broken wikilink (fix now)

The purpose line references `[[SUPERSEDED-ontara-service-business-meta-modelling-v1|Service Business Meta Modelling]]` — this should point to the current document `[[ontara-service-business-meta-modelling|Service Business Meta Modelling]]`, not the superseded v1.

### F-2.5 Master register B21 summary still says "BSMM" (fix now)

The B21 (dual-stack architecture) and L5 (operational simulation) entries in the master register still use "BSMM" in their summaries rather than "SMM". The Session 94 pass updated the reference documents but appears to have missed these individual register entries.

### F-2.6 Architecture Papers Index — SBMM paper title says "five-concern" (schedule fix)

The Business Meta Model section of the Architecture Papers Index describes the Service Business Meta Modelling paper as "the five-concern business meta model." This should be "six-concern" since the Session 82 revision incorporated StakeholderModel.

### F-2.7 [[ontara-ref-master-register|Master register]] YAML frontmatter `session:` field is stale (fix now)

The master register's YAML frontmatter says `session: 88` but was last updated Session 93/94. The `date:` field also says `2026-03-30` but the register history shows Session 93 updates on 31 March. These should be kept current.

---

## 3. Terminology — BSMM→SMM Residual References

The Session 93/94 rename pass updated reference documents ([[ontara-ref-strategic-snapshot|strategic snapshot]], [[ontara-ref-vision-architecture|vision reference]], [[ontara-ref-master-register|master register]], [[ontara - concept-graph-index|concept graph index]]) and the codebase (model files, generator, console). However, the following documents still contain "BSMM" references that should be "SMM":

### Documents requiring a terminology pass (schedule fix)

| Document | Location | Scope |
|---|---|---|
| Architecture Principles v2 | Foundations | §3 heading and body text, §5.4, §7.4, multiple occurrences |
| SysML Modelling Strategy v2 | Foundations | §1, §7, §8, multiple occurrences |
| Dual-stack architecture discussion paper | Foundational Architecture | Throughout (working document) |
| Architectural campus walk paper | Foundational Architecture | Throughout (working document) |
| Architectural section implementation design | Foundational Architecture | Some occurrences |
| StakeholderModel and BSMM vocabulary discussion | BMM Design | Title and body (historical — may keep with annotation) |
| Component catalogue discussion | BMM Design | Some occurrences |
| Process specification layer | Service Delivery | Some occurrences |
| Knowledge graph architecture | Knowledge & Platform | Some occurrences |
| Master register entries B21, L5, O2, O7 | Reference | Summary text still says "BSMM" |

**Recommendation:** The two foundations papers need full refreshes (they're past staleness threshold anyway — see §4). For discussion papers, add a brief annotation at the top noting the terminology change rather than rewriting working documents: *"Note: This paper uses 'BSMM' (Business System Meta Model), which was renamed to 'SMM' (System Meta Model) in Session 92."* The register entries should be updated directly.

---

## 4. Stale Metrics and Counts

### F-4.1 [[ontara-platform-architecture-principles|Architecture Principles v2]] — 31 sessions stale (schedule fix: full refresh)

Written Session 64. Staleness threshold: 15 sessions. Now 31 sessions past threshold. Major changes since Session 64 that are not reflected:

- [[concept-stakeholder-model|StakeholderModel]] (sixth BMM concern) — 6 new `part def`s, 17 new weights
- [[concept-dual-stack-architecture|Dual-stack architecture]] (Session 73) — BFO/OWL mandatory, [[concept-knowledge-graph|knowledge graph]] commitment
- BMM elements: 28 → 34. Weighted relationships: 79 → 96. Concerns: 5 → 6
- Console views: referenced as ~10, now 12 (Architecture, Weighted Relationship Graph upgraded to 3D)
- BSMM → SMM rename
- BFO status upgraded from "candidate" (§5.4) to "mandatory" (Session 73)
- Simulation architecture ([[concept-operational-simulation|L5]]–[[concept-goal-seeking-computation|L9]]) now conceptually designed
- Visual architecture map exists

### F-4.2 [[ontara-platform-modelling-strategy|SysML Modelling Strategy v2]] — 30 sessions stale (schedule fix: full refresh)

Written Session 65. Staleness threshold: 15 sessions. Same category of issues as the Architecture Principles — outdated BMM counts, BSMM terminology, console views count, package count, and missing the entire dual-stack and ontological grounding story.

### F-4.3 Architecture Papers Index — partially stale (fix now)

The SBMM reference uses "five-concern" (should be six). The register count says "~180" (should be ~190). Session 93 updated some entries but missed these.

---

## 5. Redundant or Confusing Material

### F-5.1 Service Business Meta Modelling and StakeholderModel discussion papers — overlap (note for awareness)

The [[ontara-service-business-meta-modelling|SBMM paper]] was revised at Session 82 to incorporate [[concept-stakeholder-model|StakeholderModel]] as the sixth concern. The [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|StakeholderModel discussion paper]] (Session 76) and [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|detailed design paper]] (Session 78) still exist as standalone working documents. This is architecturally correct — the discussion papers capture the reasoning, the foundations paper captures the settled result — but a reader encountering the Session 76 paper might not realise that its proposals have been fully implemented and absorbed. The paper's status should note this.

### F-5.2 Two Meta Models Clarification — may be confusing in isolation (note for awareness)

The [[ontara-architecture-clarification-two-meta-models|Two Meta Models Clarification]] document predates the BSMM→SMM rename and the StakeholderModel. Its core message ([[principle-two-meta-model-distinction|A4]]: the distinction between what a business *is* and how a system *works*) remains valid, but terminology and examples are outdated. Since this document's content has been fully absorbed into the [[ontara-platform-architecture-principles|Architecture Principles]] and [[ontara-service-business-meta-modelling|Service Business Meta Modelling]] papers, it could be archived with a pointer to the current documents.

---

## 6. Unrouted Emergent Ideas

Reviewing all 18 entries in the emergent ideas log:

| Entry | Status | Age (sessions) | Assessment |
|---|---|---|---|
| E007 | Not routed | 42 | Hookmark cross-boundary linking. Low priority given current workflow stability. Recommend: mark as "deferred — revisit if cross-boundary reference fragility becomes a practical problem." |
| E009 | Not routed | 37 | CostDriver.linkedResource `[0..1]` → `[0..*]`. Small, concrete model improvement. Recommend: schedule as a quick task when next working on the SysML model. |
| E010 | Partially routed | 34 | Obsidian CLI enables Code vault access. The CLI is now in routine use (Sessions 61+). The workflow guide and tooling guide could be updated with practical experience. Recommend: mark as substantially routed; remaining workflow guide refinements are incremental. |
| E011 | Not routed | 33 | IG/cybersecurity as foundational modelling concern. This is a significant future workstream, not something that can be quickly routed. Current status (captured, B20 registered as T2) is appropriate. The scoping discussion paper remains needed but is not urgent. Recommend: no action beyond noting the continued relevance. |
| E013 | Not routed | 25 | Ontologically-informed console view differentiation. Future direction dependent on B18/B19 implementation. Correctly deferred. Recommend: no action. |

**Three entries warrant attention:** E007 (stale — should be explicitly deferred or retired), E009 (actionable — small model fix), E010 (partially routed — should be marked as substantially complete).

---

## 7. Lost or Forgotten Topics

### F-7.1 Stage 4 Phase 1 formal closure (note for awareness)

The prep note from Session 92 identified "Stage 4 Phase 1 formal closure" as a governance task. This has not yet been done. Phase 1 (weighted relationship graph) is substantially complete following the 3D WebGL rebuild (Sessions 90–91), but no formal closure statement has been made in the register or strategic snapshot.

### F-7.2 Suds demonstrator BMM coverage gap (note for awareness)

Suds has "Full BMM (5 concerns)" in the strategic snapshot's demonstrator table — but the BMM now has 6 concerns. Suds has not received StakeholderModel instantiations (Sessions 81 gave those to GSL, Cafe, and Paws). This is a known gap but isn't explicitly tracked anywhere. Either Suds should receive StakeholderModel content or the gap should be recorded in Section O of the register.

### F-7.3 Claude Tooling Guide — E018 update still pending (schedule fix)

The Session 95 prep note mentions "Claude Tooling Guide update still pending" for E018 (MCP edits don't trigger Vite HMR). The workflow guide §12 was updated but the tooling guide was not. Small fix.

### F-7.4 Session report count in strategic snapshot (fix now)

The strategic snapshot says "64 (Sessions 28–92)" for session reports. Sessions 93 and 94 reports now exist, making this 66 (Sessions 28–94).

---

## 8. Integration Opportunities

### F-8.1 Foundations papers refresh as a consolidated workstream (schedule fix)

Both Architecture Principles and SysML Modelling Strategy are past their staleness thresholds. Rather than refreshing them individually across two sessions, they could be tackled together in a single dedicated governance session (or substantial portion of one). This would also be the natural moment to complete the BSMM→SMM terminology update across both papers simultaneously.

### F-8.2 Model-as-index pattern (E017) — candidate for Pattern Catalogue (note for awareness)

[[ontara-workflow-emergent-ideas-log|E017]] (model-as-index / vault-as-body) was noted in Session 86 as a candidate for the PatternCatalogue if it proves reusable beyond architectural sections. It has now been successfully applied (Session 87 implementation), but remains a single use case. Worth monitoring — if a second use case emerges (e.g., rich PatternCatalogue descriptions), it should be promoted to a validated pattern.

---

## 9. Conceptual Precision Issues

### F-9.1 "Five-layer self-knowledge" (D7) vs "Two registers of self-knowledge" (§7.6 of vision reference) — potential confusion (note for awareness)

D7 in the [[ontara-ref-master-register|register]] describes "five-layer self-knowledge" (from the early SystemStateAssessment architecture). The [[ontara-ref-vision-architecture|vision reference]] §7.6 (added Session 88) introduces "two registers of self-knowledge: business and platform." These are not contradictory — D7 describes the *depth* of self-knowledge (five layers of assessment), while §7.6 describes the *scope* (business vs platform) — but the relationship between them isn't made explicit anywhere. A reader could be confused about whether these are competing or complementary frameworks.

### F-9.2 Strategic snapshot §4.1 — Session 87 still says "First BSMM-side model content" (fix now)

This is accurate as a historical description (it *was* called BSMM at that time), but is inconsistent with the rest of the document which uses SMM. Should read "First SMM-side model content" for consistency.

---

## 10. Structural and Housekeeping Items

### F-10.1 Vault git commit reminder (note for awareness)

Per §7.1 of the [[ontara-workflow-development-guide|workflow guide]], Claude should remind Ella to commit/push the vault repo every 5 sessions. Session 95 is the threshold since the Session 94 commit was confirmed. Ella should commit the vault repo if any changes have accumulated.

### F-10.2 Research & Background index — currency check (schedule fix)

Per §7.1, the Research & Background index should be checked every 5 sessions for unindexed documents. This has not been verified since Session 79 (16 sessions ago). A quick scan is warranted.

---

## 11. Action Summary

### Fix now (this session, if time permits)

| # | Finding | Scope | Est. effort |
|---|---|---|---|
| F-2.5 | Register entries B21, L5 — BSMM→SMM in summaries | 2 targeted edits | Small |
| F-2.7 | Register YAML frontmatter session/date stale | 2 field edits | Trivial |
| F-4.3 | Architecture Papers Index — "five-concern" and register count | 2 text edits | Small |
| F-7.4 | Strategic snapshot session report count | 1 text edit | Trivial |
| F-9.2 | Strategic snapshot §4.1 "First BSMM-side" → "First SMM-side" | 1 text edit | Trivial |

### Schedule fix (next 1–3 sessions)

| # | Finding | Scope | Est. effort |
|---|---|---|---|
| F-4.1 | Architecture Principles v2 — full refresh | Substantial rewrite | 1 dedicated session |
| F-4.2 | SysML Modelling Strategy v2 — full refresh | Substantial rewrite | 1 dedicated session |
| F-8.1 | Combined foundations refresh (F-4.1 + F-4.2) | Both papers + BSMM→SMM pass | Could be a single focused session |
| F-3 | BSMM→SMM annotation on discussion papers | ~8 papers, 1-line annotation each | Small (part of a housekeeping pass) |
| F-7.3 | Claude Tooling Guide — E018 update | 1 targeted edit | Small |
| F-10.2 | Research & Background index currency check | 1 directory scan + index update | Small |

### Note for awareness (no immediate action required)

| # | Finding | Notes |
|---|---|---|
| F-5.1 | SBMM/StakeholderModel paper overlap | Architecturally correct; consider status annotation |
| F-5.2 | Two Meta Models Clarification — outdated | Content absorbed; candidate for archiving |
| F-7.1 | Stage 4 Phase 1 formal closure pending | Should be done when next reviewing Stage 4 status |
| F-7.2 | Suds lacks StakeholderModel instantiations | Track explicitly or schedule implementation |
| F-8.2 | E017 model-as-index — Pattern Catalogue candidate | Monitor for second use case |
| F-9.1 | D7 five-layer vs §7.6 two-register self-knowledge | Complementary but relationship not documented |
| F-10.1 | Vault git commit reminder | 5-session threshold reached |

---

*Systematic documentation review completed 1 April 2026 (Session 95). First review under the §7.3 convention. Next review due ~Session 110.*
